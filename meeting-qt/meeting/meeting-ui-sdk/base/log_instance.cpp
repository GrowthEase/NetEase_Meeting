// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "log_instance.h"
#include <QStandardPaths>
#include <QString>
#include <thread>
#include "version.h"
#ifdef WIN32
#include <process.h>
#else
#include <unistd.h>
#endif

LogInstance* LogInstance::m_instance = nullptr;

LogInstance::LogInstance(char* argv[]) {
    QString logPathEx = qApp->property("logPath").toString();
    auto logLevel = qApp->property("logLevel").toInt();
    if (logPathEx.isEmpty())
        logPathEx = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    auto logPath = logPathEx + "/app/ui";
    QDir logDir;
    if (!logDir.exists(logPath))
        logDir.mkpath(logPath);

    ALogLevel logLevelTmp = logLevel <= 0 ? ALogLevel::Debug : (ALogLevel)ConfigManager::getInstance()->getValue("localLogLevel", logLevel).toInt();
#ifdef WIN32
#else
    logDir.setPath(logPathEx + "/app");
    QString strCrashPath = logDir.absolutePath() + "/";
    QDir dir(QStandardPaths::writableLocation(QStandardPaths::HomeLocation) + "/Library/Logs/DiagnosticReports");
    for (QFileInfo& file : dir.entryInfoList(QStringList("NetEaseMeeting*.crash"), QDir::Filter::Files)) {
        QFile::copy(file.absoluteFilePath(), strCrashPath + file.fileName());
        // QFile::remove(file.absoluteFilePath());
    }
    for (QFileInfo& file : dir.entryInfoList(QStringList("NetEaseMeeting*.ips"), QDir::Filter::Files)) {
        QFile::copy(file.absoluteFilePath(), strCrashPath + file.fileName());
        // QFile::remove(file.absoluteFilePath());
    }
    dir.setPath(strCrashPath);
    int count = 5;
    for (QFileInfo& file : dir.entryInfoList(QStringList("NetEaseMeeting*.crash"), QDir::Filter::Files, QDir::Time)) {
        // qInfo() << file.absoluteFilePath();
        if (count-- > 0) {
            continue;
        }
        QFile::remove(file.absoluteFilePath());
    }
    count = 5;
    for (QFileInfo& file : dir.entryInfoList(QStringList("NetEaseMeeting*.ips"), QDir::Filter::Files, QDir::Time)) {
        // qInfo() << file.absoluteFilePath();
        if (count-- > 0) {
            continue;
        }
        QFile::remove(file.absoluteFilePath());
    }
#endif

    logDir.setPath(logPath);

    ALog::CreateInstance(logDir.absolutePath().toStdString(), "meeting_ui", logLevelTmp);
    ALog::GetInstance()->setShortFileName(true);
    qInstallMessageHandler(&LogInstance::messageHandler);

    QString strLogHeaders;
    strLogHeaders.append("\n===================================================\n");
    strLogHeaders.append("[ModuleName] meeting-ui-sdk\n");
    strLogHeaders.append("[ModuleVersion] ").append(APPLICATION_VERSION).append("\n");
#ifdef WIN32
    strLogHeaders.append("[ProcessId] ").append(QString::number(_getpid())).append("\n");
#else
    strLogHeaders.append("[ProcessId] ").append(QString::number(getpid())).append("\n");
#endif
    strLogHeaders.append("[GitHashCode] ").append(COMMIT_HASH).append("\n");
    strLogHeaders.append("[DeviceInfo]\n");
    strLogHeaders.append("  [DeviceId] ").append(QSysInfo::machineUniqueId()).append("\n");
    strLogHeaders.append("  [Manufacturer] ").append(QSysInfo::prettyProductName()).append("\n");
    strLogHeaders.append("  [CPU_ABI] ").append(QSysInfo::currentCpuArchitecture()).append("\n");
    strLogHeaders.append("[LogLevel] ").append(QString::number(logLevelTmp)).append("\n");
    strLogHeaders.append("===================================================");

    YXLOG(Info) << strLogHeaders.toStdString() << YXLOGEnd;
}

LogInstance::LogInstance() {}

LogInstance::~LogInstance() {
    ALog::DestoryInstance();
}

void LogInstance::messageHandler(QtMsgType, const QMessageLogContext& context, const QString& message) {
    if (message.contains("QML Connections: Implicitly defined onFoo properties in Connections are deprecated")) {
        return;
    }

    if (context.file && !message.isEmpty()) {
        std::string strFileTmp = context.file;
        const char* ptr = strrchr(strFileTmp.c_str(), '/');
        if (nullptr != ptr) {
            char fn[512] = {0};
            sprintf(fn, "%s", ptr + 1);
            strFileTmp = fn;
        }
        const char* ptrTmp = strrchr(strFileTmp.c_str(), '\\');
        if (nullptr != ptrTmp) {
            char fn[512] = {0};
            sprintf(fn, "%s", ptrTmp + 1);
            strFileTmp = fn;
        }
        YXLOG(Info) << "[" << context.file << ":" << context.line << "] " << message.toStdString() << YXLOGEnd;
    }
}
