/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "global_manager.h"

GlobalManager::GlobalManager() {}

GlobalManager::~GlobalManager() {}

bool GlobalManager::initialize(const QString& appKey, bool bprivate, const QString& deviceId) {
    m_globalService = createNERoomKit();
    if (m_globalService == nullptr)
        return false;

    auto logPath = qApp->property("logPath").toString();
    auto logLevel = qApp->property("logLevel").toInt();
    if (logPath.isEmpty())
        logPath = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    logPath.append("/Native");
    QDir sdkLogDir;
    if (!sdkLogDir.exists(logPath))
        sdkLogDir.mkpath(logPath);

    QString rtclog = logPath;
    rtclog.append("/NeRTC");
    if (!sdkLogDir.exists(rtclog))
        sdkLogDir.mkpath(rtclog);

    sdkLogDir.setPath(logPath);
    QByteArray byteLogDir = sdkLogDir.absolutePath().toUtf8();
    int iCustomClientType = 29;
    if (!ConfigManager::getInstance()->contains("customClientType")) {
        ConfigManager::getInstance()->setValue("customClientType", iCustomClientType);
    } else {
        iCustomClientType = ConfigManager::getInstance()->getValue("customClientType", 29).toInt();
    }

    auto customHost = ConfigManager::getInstance()->getValue("localPaasServerAddress", "").toString();
    QByteArray byteCustomHost = customHost.toUtf8();

    QByteArray byteAppKey = appKey.toUtf8();
    NERoomKitConfig config;
    config.appKey = byteAppKey.data();
    config.iCustomClientType = iCustomClientType;
    config.useAssetServerConfig = bprivate;
    config.host = byteCustomHost.data();
    config.loggerConfig.path = byteLogDir.data();
    config.loggerConfig.level = (NELogLevel)logLevel;
    config.loggerConfig.privateLevel = (NELogLevel)ConfigManager::getInstance()->getValue("localLogLevel", 2).toInt();
    config.deviceId = deviceId.toStdString();
    config.m_uiStringMap = {{kFailed_connect_server, tr("Failed to connect to server, please try agine.").toStdString()},
                            {kFailed_parse_reply, tr("Failed to parse http reply content.").toStdString()}};
    return m_globalService->initialize(config);
}

void GlobalManager::release() {
    m_globalService->release();
    destroyNERoomKit();
}

INEAuthService* GlobalManager::getAuthService() {
    return m_globalService->getAuthService();
}

INEPreRoomService* GlobalManager::getPreRoomService() {
    return m_globalService->getPreRoomService();
}

INERoomService* GlobalManager::getRoomService() {
    return m_globalService->getRoomService();
}

INEInRoomService* GlobalManager::getInRoomService() {
    return m_globalService->getInRoomService();
}

INESettingsService* GlobalManager::getGlobalConfig() {
    return m_globalService->getSettingsService();
}

void GlobalManager::showSettingsWnd() {
    emit showSettingsWindow();
}

QString GlobalManager::globalAppKey() const {
    return m_globalAppKey;
}

void GlobalManager::setGlobalAppKey(const QString& globalAppKey) {
    m_globalAppKey = globalAppKey;
}
