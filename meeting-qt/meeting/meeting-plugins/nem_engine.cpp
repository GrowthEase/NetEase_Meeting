// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nem_engine.h"
#include <QDebug>
#include <QStandardPaths>

NEMEngine::NEMEngine(QObject* parent)
    : QObject(parent) {
    m_globalService = nem_sdk::createGlobalService();
    m_dataDirectory = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
}

NEMEngine::~NEMEngine() {
    if (m_globalService != nullptr) {
        nem_sdk::destroyGlobalService();
    }
}

bool NEMEngine::initialize() {
    if (m_globalService != nullptr) {
        nem_sdk::InitConfig config;
        QByteArray byteAppKey = appKey().toUtf8();
        QByteArray byteDataDirectory = dataDirectory().toUtf8();
        config.appKey = byteAppKey.data();
        config.logDirectory = byteDataDirectory.data();
        config.iCustomClientType = 29;
        config.bPrivate = usePrivateConfig();
        auto result = m_globalService->initialize(config);
        setIsValid(result);
        return result;
    }
    return false;
}

void NEMEngine::unInitialize() {
    if (m_globalService != nullptr) {
        m_globalService->release();
        setIsValid(false);
    }
}

bool NEMEngine::isValid() const {
    return m_isValid;
}

void NEMEngine::setIsValid(bool isValid) {
    if (m_isValid != isValid) {
        m_isValid = isValid;
        Q_EMIT isValidChanged();
    }
}

QString NEMEngine::appKey() const {
    return m_appKey;
}

void NEMEngine::setAppKey(const QString& appKey) {
    if (m_appKey != appKey) {
        m_appKey = appKey;
        Q_EMIT appKeyChanged();
    }
}

QString NEMEngine::dataDirectory() const {
    return m_dataDirectory;
}

void NEMEngine::setDataDirectory(const QString& dataDirectory) {
    if (m_dataDirectory != dataDirectory) {
        m_dataDirectory = dataDirectory;
        Q_EMIT dataDirectoryChanged();
    }
}

int NEMEngine::customClientType() const {
    return m_customClientType;
}

void NEMEngine::setCustomClientType(int customClientType) {
    if (m_customClientType != customClientType) {
        m_customClientType = customClientType;
        Q_EMIT customClientTypeChanged();
    }
}

bool NEMEngine::usePrivateConfig() const {
    return m_usePrivateConfig;
}

void NEMEngine::setUsePrivateConfig(bool usePrivateConfig) {
    if (m_usePrivateConfig != usePrivateConfig) {
        m_usePrivateConfig = usePrivateConfig;
        Q_EMIT usePrivateConfigChanged();
    }
}

nem_sdk::IAuthService* NEMEngine::getAuthService() const {
    if (m_globalService == nullptr)
        return nullptr;
    return m_globalService->getAuthService();
}

nem_sdk::IDeviceService* NEMEngine::getDeviceService() const {
    if (m_globalService == nullptr)
        return nullptr;
    return m_globalService->getDeviceService();
}

nem_sdk::IPreMeetingService* NEMEngine::getPreMeetingService() const {
    if (m_globalService == nullptr)
        return nullptr;
    return m_globalService->getPreMeetingService();
}

nem_sdk::IMeetingService* NEMEngine::getMeetingService() const {
    if (m_globalService == nullptr)
        return nullptr;
    return m_globalService->getMeetingService();
}
