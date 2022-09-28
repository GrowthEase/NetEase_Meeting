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
    auto appDataDir = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    appDataDir.append("/app/meeting");
    QDir logDir;
    if (!logDir.exists(appDataDir))
        logDir.mkpath(appDataDir);
    logDir.setPath(appDataDir);

    int minLevel = ConfigManager::getInstance()->getValue("localLogLevel", 2).toUInt();
    ALog::CreateInstance(logDir.absolutePath().toStdString(), "meeting_app", (ALogLevel)minLevel);
    ALog::GetInstance()->setShortFileName(true);
    qInstallMessageHandler(&LogInstance::messageHandler);

    QString strLogHeaders;
    strLogHeaders.append("\n===================================================\n");
    strLogHeaders.append("[ModuleName] meeting-app\n");
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
    strLogHeaders.append("[MinLevel] ").append(QString::number(minLevel)).append("\n");
    strLogHeaders.append("===================================================");

    YXLOG(Info) << strLogHeaders.toStdString() << YXLOGEnd;
}

LogInstance::LogInstance() {}

LogInstance::~LogInstance() {
    ALog::DestoryInstance();
}

void LogInstance::messageHandler(QtMsgType, const QMessageLogContext& context, const QString& message) {
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
        YXLOG(Info) << "[" << strFileTmp << ":" << context.line << "] " << message.toStdString() << YXLOGEnd;
    }
}
