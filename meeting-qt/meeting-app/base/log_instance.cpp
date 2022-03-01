/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

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
#ifdef USE_GOOGLE_LOG
    google::InitGoogleLogging(argv[0]);
    configureGoogleLog();
#else
    auto appDataDir = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    appDataDir.append("/App");
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
    strLogHeaders.append("[DeviceInfo] ");
    strLogHeaders.append("  [DeviceId] ").append(QSysInfo::machineUniqueId()).append("\n");
    strLogHeaders.append("  [Manufacturer] ").append(QSysInfo::prettyProductName()).append("\n");
    strLogHeaders.append("  [CPU_ABI] ").append(QSysInfo::currentCpuArchitecture()).append("\n");
    strLogHeaders.append("[MinLevel] ").append(QString::number(minLevel)).append("\n");
    strLogHeaders.append("===================================================");

    YXLOG(Info) << strLogHeaders.toStdString() << YXLOGEnd;
#endif
}

LogInstance::LogInstance() {}

LogInstance::~LogInstance() {
#ifdef USE_GOOGLE_LOG
    google::ShutdownGoogleLogging();
#else
    ALog::DestoryInstance();
#endif
}

void LogInstance::configureGoogleLog() {
#ifdef USE_GOOGLE_LOG
    google::EnableLogCleaner(10);
    google::SetStderrLogging(google::GLOG_INFO);
#ifdef Q_OS_MACX
    // google::InstallFailureSignalHandler();
    // google::InstallFailureWriter([](const char* data, int size) { YXLOG(Error) << std::string(data, size); });
#endif
    auto appDataDir = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    appDataDir.append("/App");
    QDir logDir = appDataDir;
    if (!logDir.exists(appDataDir))
        logDir.mkpath(appDataDir);

    QByteArray byteLogDir = appDataDir.toUtf8();
    FLAGS_log_dir = byteLogDir.data();
#ifdef Q_NO_DEBUG
    FLAGS_logtostderr = false;
#else
    FLAGS_logtostderr = false;
#endif
    FLAGS_alsologtostderr = false;
    // FLAGS_colorlogtostderr = true;
    FLAGS_logbufsecs = 0;     //
    FLAGS_max_log_size = 10;  // MB
    FLAGS_stop_logging_if_full_disk = true;
    FLAGS_v = ConfigManager::getInstance()->getValue("localLogLevel", 1).toUInt();

    LOG(INFO) << "===================================================";
    LOG(INFO) << "[Product] NetEase IM Meeting";
    LOG(INFO) << "[Website] https://yunxin.163.com/meeting";
    LOG(INFO) << "[Commits] " << COMMIT_HASH;
    LOG(INFO) << "[Version] " << APPLICATION_VERSION;
    LOG(INFO) << "[DeviceId] " << QString(QSysInfo::machineUniqueId()).toStdString();
    LOG(INFO) << "[OSVersion] " << QSysInfo::prettyProductName().toStdString();
    LOG(INFO) << "===================================================";

    qInstallMessageHandler(&LogInstance::messageHandler);
#endif
}

void LogInstance::messageHandler(QtMsgType, const QMessageLogContext& context, const QString& message) {
    if (context.file && !message.isEmpty()) {
        std::string strFileTmp = context.file;
        const char* ptr = strrchr(strFileTmp.c_str(), '/');
        if (nullptr != ptr) {
            char fn[512] = { 0 };
            sprintf(fn, "%s", ptr + 1);
            strFileTmp = fn;
        }
        const char* ptrTmp = strrchr(strFileTmp.c_str(), '\\');
        if (nullptr != ptrTmp) {
            char fn[512] = { 0 };
            sprintf(fn, "%s", ptrTmp + 1);
            strFileTmp = fn;
        }
        YXLOG(Info) << "[" << strFileTmp << ":" << context.line << "] " << message.toStdString() << YXLOGEnd;
    }
}
