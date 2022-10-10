// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "config_manager.h"
#include <QDebug>
#include <QGuiApplication>
#include <QJsonArray>

#include "base/http_manager.h"
#include "base/http_request.h"
#include "base/nem_auth_requests.h"

ConfigManager* ConfigManager::m_instance = nullptr;

ConfigManager::ConfigManager(QObject* parent)
    : QObject(parent)
    , m_httpManager(new HttpManager(parent)) {
    m_settings = new QSettings();

    initPrivate();
    if (!m_bPrivate) {
        m_aPaasAppKey = getValue("localAppKeyEx", LOCAL_DEFAULT_APPKEY).toString();
        m_aPaasServerAddress = getValue("localServerAddressEx", LOCAL_DEFAULT_SERVER_ADDRESS).toString();
    }
}

void ConfigManager::setSSOLogin(bool sso) {
    if (m_bPrivate) {
        initPrivate();
        return;
    }

    auto test = getTestEnv();
    if (sso) {
        m_aPaasAppKey = !test ? LOCAL_DEFAULT_APPKEY_SSO : LOCAL_DEFAULT_APPKEY_TEST_SSO;
    } else {
        m_aPaasAppKey = !test ? LOCAL_DEFAULT_APPKEY : LOCAL_DEFAULT_APPKEY_TEST;
    }
    setValue("localAppKeyEx", m_aPaasAppKey);

    m_aPaasServerAddress = !test ? LOCAL_DEFAULT_SERVER_ADDRESS : LOCAL_DEFAULT_SERVER_ADDRESS_TEST;
    setValue("localServerAddressEx", m_aPaasServerAddress);
}

bool ConfigManager::getSSOLogin() {
    bool bSSOLogin = m_aPaasAppKey.contains(LOCAL_DEFAULT_APPKEY_SSO) || m_aPaasAppKey.contains(LOCAL_DEFAULT_APPKEY_TEST_SSO);
    qInfo() << "getSSOLogin:" << bSSOLogin;
    return bSSOLogin;
}

void ConfigManager::setNeedSafeTip(bool needSafeTip) {
    m_needSafeTip = needSafeTip;
    emit needSafeTipChanged();
}

void ConfigManager::requestServerAppConfigs() {
    QString timestamp = ConfigManager::getInstance()->getValue("lastConfigTimestamp", "").toString();
    if (timestamp.isEmpty()) {
        timestamp = "0";
    }
    nem_auth::GetAppConfigs request(timestamp);

    m_httpManager->postRequest(request, [this](int code, const QJsonObject& response) {
        if (code == 200) {
            QJsonArray configs = response["configs"].toArray();
            if (configs.size() <= 0) {
                //读取本地配置
                QString appConfigJsonType_1 = getValue("lastAppConfigType_1", "").toString();
                if (appConfigJsonType_1.isEmpty()) {
                    return;
                }

                QJsonDocument jsonDocument = QJsonDocument::fromJson(appConfigJsonType_1.toUtf8().data());
                m_safeTipJson = jsonDocument.object();
                setNeedSafeTip(true);
            } else {
                QJsonObject obj = configs.at(0).toObject();
                m_safeTipJson.insert("content", obj["content"].toString());
                m_safeTipJson.insert("okBtnLabel", obj["okBtnLabel"].toString());
                m_safeTipJson.insert("title", obj["title"].toString());

                if (obj["type"].toInt() == 1) {
                    bool resetConfig = !obj["enable"].toBool();
                    if (resetConfig) {
                        setValue("lastAppConfigType_1", "");
                        return;
                    }

                    setValue("lastAppConfigType_1", QJsonDocument(m_safeTipJson).toJson(QJsonDocument::Compact));
                    setNeedSafeTip(true);
                }
            }

            QString lastConfigTimestamp = response["time"].toVariant().toString();
            setValue("lastConfigTimestamp", lastConfigTimestamp);
        }
    });
}

QJsonObject ConfigManager::getSafeTipContent() const {
    return m_safeTipJson;
}

bool ConfigManager::isDebugModel() {
#ifdef Q_NO_DEBUG
    return false;
#else
    return true;
#endif
}

bool ConfigManager::getTestEnv() const {
    return false;
//    return ConfigManager::getInstance()
//        ->getValue("localUpdateServerAddressEx", LOCAL_DEFAULT_UPDATE_SERVER_ADDRESS)
//        .toString()
//        .contains(LOCAL_DEFAULT_UPDATE_SERVER_ADDRESS_TEST, Qt::CaseInsensitive);
}

void ConfigManager::setTestEnv(bool test) {
    if (!test) {
        ConfigManager::getInstance()->setValue("localServerAddressEx", LOCAL_DEFAULT_SERVER_ADDRESS);
        ConfigManager::getInstance()->setValue("localAppKeyEx", LOCAL_DEFAULT_APPKEY);
        ConfigManager::getInstance()->setValue("localUpdateServerAddressEx", LOCAL_DEFAULT_UPDATE_SERVER_ADDRESS);
        ConfigManager::getInstance()->setValue("localAppConfigsServerAddressEx", LOCAL_DEFAULT_APPCONFIGS_SERVER_ADDRESS);
    } else {
        ConfigManager::getInstance()->setValue("localServerAddressEx", LOCAL_DEFAULT_SERVER_ADDRESS_TEST);
        ConfigManager::getInstance()->setValue("localAppKeyEx", LOCAL_DEFAULT_APPKEY_TEST);
        ConfigManager::getInstance()->setValue("localUpdateServerAddressEx", LOCAL_DEFAULT_UPDATE_SERVER_ADDRESS_TEST);
        ConfigManager::getInstance()->setValue("localAppConfigsServerAddressEx", LOCAL_DEFAULT_APPCONFIGS_SERVER_ADDRESS_TEST);
    }

    ConfigManager::getInstance()->setValue("localNEAccountId", "");
}

QVariant ConfigManager::getValue(const QString& key, const QVariant& defaultValue) {
    return m_settings->value(key, defaultValue);
}

void ConfigManager::setValue(const QString& key, const QVariant& value) {
    return m_settings->setValue(key, value);
}

bool ConfigManager::getLocalDebugLevel() const {
    int minLevel = ConfigManager::getInstance()->getValue("localLogLevel", 2).toUInt();
    return (ALogLevel)minLevel <= Debug;
}

void ConfigManager::initPrivate() {
    QString privateFile = qApp->applicationDirPath() + "/xkit_server.config";
#ifdef Q_OS_MACX
    if (!QFile::exists(privateFile)) {
        // YXLOG(Waring) << "privateFile not exists: " << privateFile.toStdString() << YXLOGEnd;
        privateFile = qApp->applicationDirPath() + "/../Frameworks/NetEaseMeetingClient.app/Contents/MacOS/xkit_server.config";
    }
#endif

    if (!QFile::exists(privateFile)) {
        m_bPrivate = false;
        return;
    } else {
        YXLOG(Info) << "initPrivate, privateFile: " << privateFile.toStdString() << YXLOGEnd;
    }

    if (m_bPrivate) {
        return;
    }
    m_bPrivate = true;

    QFile file(privateFile);
    if (!file.open(QIODevice::ReadOnly)) {
        YXLOG(Error) << "initPrivateConfig open failed, privateFile: " << privateFile.toStdString() << ", error: " << file.errorString().toStdString()
                     << YXLOGEnd;
        return;
    }
    QJsonParseError error;
    QJsonDocument document = QJsonDocument::fromJson(file.readAll(), &error);
    if (error.error == QJsonParseError::NoError) {
        QJsonObject config = document.object();
        if (config.contains("meeting")) {
            auto meeting = config["meeting"].toObject();
            if (meeting.contains("serverUrl")) {
                m_aPaasServerAddress = meeting["serverUrl"].toString();
                if (!m_aPaasServerAddress.endsWith("/")) {
                    m_aPaasServerAddress.append("/");
                }
            }
        }
        if (config.contains("im")) {
            auto im = config["im"].toObject();
            if (im.contains("appkey")) {
                m_aPaasAppKey = im["appkey"].toString();
            }
        }
    } else {
        YXLOG(Error) << "initPrivateConfig failed, error: " << error.errorString().toStdString() << YXLOGEnd;
    }
    file.close();
}

bool ConfigManager::contains(const QString& key) {
    return m_settings->contains(key);
}
