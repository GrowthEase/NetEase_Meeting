/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "client_updator.h"
#include <QCryptographicHash>
#include <QProcess>
#include <QTimer>
#include "components/macxhelper.h"
#include "nemeeting_sdk_manager.h"

#ifdef Q_OS_WIN
#define SetUp_File QString updateFile = QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/newSetup.exe";
#endif

#ifdef Q_OS_LINUX

#endif

#ifdef Q_OS_MAC
#define SetUp_File QString updateFile = QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/newSetup.dmg";
#endif

QString UpdateInfoKey_latestVersionCode = "latestVersionCode";    // int 最新版本码
QString UpdateInfoKey_latestVersionName = "latestVersionName";    // int 最新版本码
QString UpdateInfoKey_currentVersionCode = "currentVersionCode";  // int 当前版本号
QString UpdateInfoKey_url = "url";                                // string 跳转外部下载地址, 此地址不能作为应用内更新下载使用
QString UpdateInfoKey_download_url = "downloadUrl";               // string 应用内更新链接
QString UpdateInfoKey_description = "description";                // string 更新内容详细描述
QString UpdateInfoKey_title = "title";                            // string 更新内容提示
QString UpdateInfoKey_notify = "notify";                          // int 本次更新是否提示用户，0：不提示，1：提示
QString UpdateInfoKey_forceVersionCode = "forceVersionCode";      // long 强制更新的版本码，小于等于此版本号应用需要强制更新
QString UpdateInfoKey_checkCode = "checkCode";                    // string 安装包校验码
QString UpdateInfoRSPKey_Code = "code";
QString UpdateInfoRSPKey_MSG = "msg";

bool ClientUpdateInfoSerializer::read(const QString& path, ClientUpdateInfo& info) {
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly))
        return false;
    QByteArray data = file.readAll();
    file.close();
    //使用json文件对象加载字符串
    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (!doc.isObject())
        return false;
    QJsonObject obj = doc.object();
    info.m_url = obj[UpdateInfoKey_url].toString();
    info.m_download_url = obj[UpdateInfoKey_download_url].toString();
    info.m_checkCode = obj[UpdateInfoKey_checkCode].toString();
    info.m_notify = obj[UpdateInfoKey_notify].toInt();
    info.m_title = obj[UpdateInfoKey_title].toString();
    info.m_description = obj[UpdateInfoKey_description].toString();
    info.m_forceVersionCode = obj[UpdateInfoKey_forceVersionCode].toInt();
    info.m_latestVersionCode = obj[UpdateInfoKey_latestVersionCode].toInt();
    info.m_currentVersionCode = COMMIT_COUNT;
    return true;
}

bool ClientUpdateInfoSerializer::write(const QString& path, const ClientUpdateInfo& info) {
    QJsonObject obj;
    obj.insert(UpdateInfoKey_url, info.m_url);
    obj.insert(UpdateInfoKey_download_url, info.m_download_url);
    obj.insert(UpdateInfoKey_checkCode, info.m_checkCode);
    obj.insert(UpdateInfoKey_notify, info.m_notify);
    obj.insert(UpdateInfoKey_title, info.m_title);
    obj.insert(UpdateInfoKey_description, info.m_description);
    obj.insert(UpdateInfoKey_forceVersionCode, info.m_forceVersionCode);
    obj.insert(UpdateInfoKey_latestVersionCode, info.m_latestVersionCode);
    obj.insert(UpdateInfoKey_currentVersionCode, COMMIT_COUNT);

    QJsonDocument doc(obj);
    QByteArray data = doc.toJson();
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly)) {
        qInfo() << "Failed to open update cache file";
        return false;
    }
    file.write(data);
    file.close();
    return true;
}

int ClientUpdater::getCurrentVersion() const {
    return COMMIT_COUNT;
}

int ClientUpdater::getLatestVersion() const {
    return m_latestVersionCode;
}

ClientUpdater::ClientUpdater(NEMeetingSDKManager* sdk, QObject* parent)
    : m_pSDK(sdk),
      QObject(parent) {
    m_httpManager = new HttpManager;
    SetUp_File
            // 删除自动更新的安装包
            if (QFile::exists(updateFile)) {
        QFile::remove(updateFile);
    }
    // 安装安装包
    connect(this, &ClientUpdater::downloadResultSignal, [=](bool bSucc, const QJsonObject& jsonObject) {
        if (!bSucc || !jsonObject.isEmpty()) {
            return;
        }

#ifdef Q_OS_MACX
        SetUp_File
        YXLOG(Info) << "Start installing updates." << YXLOGEnd;
        QThread* pThread = new QThread(this);
        Macxhelper* pHelper = new Macxhelper(updateFile);
        pHelper->moveToThread(pThread);
        connect(pThread, &QThread::started, pHelper, &Macxhelper::installFromDMG);
        connect(pHelper, &Macxhelper::installFinished, pThread, &QThread::quit);

        QEventLoop loop;
        connect(pThread, &QThread::finished, &loop, &QEventLoop::quit);
        pThread->start();
        loop.exec(QEventLoop::ExcludeUserInputEvents);
        // 删除自动更新的安装包
        if (QFile::exists(updateFile)) {
            QFile::remove(updateFile);
        }
#endif
        qApp->exit(773);
    });
}

void ClientUpdater::lanchApp() {
#if defined(Q_OS_WIN)
    SetUp_File
    YXLOG(Info) << "Start installing updates." << YXLOGEnd;
    QStringList arguments;
    arguments << "/nim-update=true";
    QProcess::startDetached(updateFile, arguments, QStandardPaths::writableLocation(QStandardPaths::DataLocation));
#elif defined(Q_OS_MACX)
    YXLOG(Info) << "Start lanchApp." << YXLOGEnd;
    QProcess::startDetached(qApp->applicationFilePath(), QStringList());
#endif
}

void ClientUpdater::checkUpdate() {
    QString dir_path = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    QDir updateInfoCatchDir(dir_path);
    if (!updateInfoCatchDir.exists()) {
        updateInfoCatchDir.mkpath(dir_path);
    }
    m_updateInfoCatchFilePath = dir_path + "/update_info.cache";

    // 删除更新缓存文件，每次从服务器上拿最新的
    if (QFile::exists(m_updateInfoCatchFilePath)) {
        QFile::remove(m_updateInfoCatchFilePath);
    }

    // 删除自动更新的安装包
    SetUp_File if (QFile::exists(updateFile)) { QFile::remove(updateFile); }

    AppCheckUpdateRequest checkUpdateRequest(getCurrentVersion(), m_pSDK != nullptr ? m_pSDK->neAccountId() : "");
    m_httpManager->postRequest(checkUpdateRequest, [this](int code, const QJsonObject& response) {
        ClientUpdateInfo rspUpdateInfo;
        QJsonObject clientUpdateInfo;
        if (code == 200) {
            QString error_message("");
            if (response.find(QString(UpdateInfoRSPKey_MSG)) != response.end())
                error_message = response[UpdateInfoRSPKey_MSG].toString();

            rspUpdateInfo.m_currentVersionCode = COMMIT_COUNT;
            rspUpdateInfo.m_latestVersionCode = response[UpdateInfoKey_latestVersionCode].toInt();
            rspUpdateInfo.m_url = response[UpdateInfoKey_url].toString();
            rspUpdateInfo.m_download_url = response[UpdateInfoKey_download_url].toString();
            rspUpdateInfo.m_checkCode = response[UpdateInfoKey_checkCode].toString();
            rspUpdateInfo.m_description = response[UpdateInfoKey_description].toString();
            rspUpdateInfo.m_title = response[UpdateInfoKey_title].toString();
            rspUpdateInfo.m_notify = response[UpdateInfoKey_notify].toInt();
            m_latestVersionCode = rspUpdateInfo.m_latestVersionCode;

            if (response.contains(UpdateInfoKey_forceVersionCode))
                rspUpdateInfo.m_forceVersionCode = response[UpdateInfoKey_forceVersionCode].toInt();
            else
                rspUpdateInfo.m_forceVersionCode = 0;

            clientUpdateInfo["url"] = rspUpdateInfo.m_url;
            clientUpdateInfo["downloadUrl"] = rspUpdateInfo.m_download_url;
            clientUpdateInfo["checkCode"] = rspUpdateInfo.m_checkCode;
            clientUpdateInfo["description"] = QString::fromUtf8(QByteArray::fromBase64(rspUpdateInfo.m_description.toUtf8()));
            clientUpdateInfo["title"] = QString::fromUtf8(QByteArray::fromBase64(rspUpdateInfo.m_title.toUtf8()));
            clientUpdateInfo["notify"] = rspUpdateInfo.m_notify;
            clientUpdateInfo["force"] = rspUpdateInfo.m_forceVersionCode;
            clientUpdateInfo["latestVersion"] = rspUpdateInfo.m_latestVersionCode;
            clientUpdateInfo["currentVersion"] = rspUpdateInfo.m_currentVersionCode;

            ClientUpdateInfoSerializer::write(m_updateInfoCatchFilePath, rspUpdateInfo);
            emit checkUpdateSignal(code, static_cast<int>(doCheck(rspUpdateInfo)), clientUpdateInfo);
        } else {
            emit checkUpdateSignal(code, static_cast<int>(UpdateType::unknown), clientUpdateInfo);
        }
    });
};

UpdateType ClientUpdater::doCheck(const ClientUpdateInfo& update_info) const {
    UpdateType ret = UpdateType::theLatestVersion;
    if (update_info.m_forceVersionCode > getCurrentVersion())  //当前版需要强制升级
    {
        ret = UpdateType::hasNewAndForce;
    } else {
        if (update_info.m_latestVersionCode > getCurrentVersion()) {
            if (update_info.m_notify == 0)  //不提示
                ret = UpdateType::hasNewButNotifiless;
            else if (update_info.m_notify == 1)
                ret = UpdateType::hasNewAndNotify;
            else
                ret = UpdateType::hasNewButNotifiless;
        }
    }
    return ret;
}

bool ClientUpdater::update() {
    QString updateInfoFile = QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/update_info.cache";
    ClientUpdateInfo updateInfo;
    if (!ClientUpdateInfoSerializer::read(updateInfoFile, updateInfo)) {
        return false;
    }

    SetUp_File m_pFile = new QFile(updateFile, this);
    if (m_pFile->exists() && !m_pFile->remove()) {
        m_pFile->deleteLater();
        m_pFile = nullptr;
        return false;
    }

    if (!m_pFile->open(QIODevice::WriteOnly)) {
        m_pFile->deleteLater();
        m_pFile = nullptr;
        return false;
    }

    AppDownloadRequest appDownloadRequest(updateInfo.m_download_url, m_pFile);
    m_httpManager->getRequest(
                appDownloadRequest,
                [this](int code, const QJsonObject& response) {
        m_pFile->flush();
        m_pFile->close();
        m_pFile->deleteLater();
        m_pFile = nullptr;

        SetUp_File if (QNetworkReply::OperationCanceledError == code) {
            // 删除自动更新的安装包
            if (QFile::exists(updateFile)) {
                QFile::remove(updateFile);
            }
            return;
        }
        else if (QNetworkReply::NoError == code) {
            do {
                    QString updateInfoFile = QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/update_info.cache";
                    ClientUpdateInfo updateInfo;
                    if (!ClientUpdateInfoSerializer::read(updateInfoFile, updateInfo)) {
                        YXLOG(Error) << "Failed to open update cache file." << YXLOGEnd;
                        break;
                    }

                    if (!QFile::exists(updateFile)) {
                        YXLOG(Error) << "Setup file not found: " << updateFile.toStdString() << YXLOGEnd;
                        break;
                    }

                    QFile file(updateFile);
                    if (file.open(QIODevice::ReadOnly)) {
                        QCryptographicHash hash(QCryptographicHash::Sha1);
                        hash.addData(&file);
                        QString strCheckcode(hash.result().toHex());
                        file.close();
                        if (0 != strCheckcode.compare(updateInfo.m_checkCode, Qt::CaseInsensitive)) {
                            // 删除自动更新的安装包
                            if (QFile::exists(updateFile)) {
                                QFile::remove(updateFile);
                        }
                        YXLOG(Error) << "Checkcode of Setup file does not match, localfile: " << strCheckcode.toStdString()
                                    << ", remotefile: " << updateInfo.m_checkCode.toStdString() << YXLOGEnd;
                        break;
                    }
                }

                emit downloadResultSignal(true, QJsonObject());
                return;
            } while (0);
        }

        emit downloadResultSignal(false, response);
    },
    [this](qint64 bytesReceived, qint64 bytesTotal) {
        float fReceived = bytesReceived / (1024.0 * 1024.0);
        fReceived = ((float)((int)((fReceived + 0.05) * 10))) / 10;

        float fTotal = bytesTotal / (1024.0 * 1024.0);
        fTotal = ((float)((int)((fTotal + 0.05) * 10))) / 10;
        emit downloadProgressSignal(fReceived, fTotal);
    });

    return true;
}

void ClientUpdater::stopUpdate() {
    if (m_httpManager) {
        m_httpManager->abort();
    }
}
