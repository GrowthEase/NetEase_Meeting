// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEETING_PLUGINS_NEM_ENGINE_H_
#define MEETING_PLUGINS_NEM_ENGINE_H_

#include <QObject>
#include "include/global_service_interface.h"

class NEMEngine : public QObject {
    Q_OBJECT
    Q_DISABLE_COPY(NEMEngine)

public:
    explicit NEMEngine(QObject* parent = nullptr);
    virtual ~NEMEngine();

    Q_PROPERTY(bool isValid READ isValid WRITE setIsValid NOTIFY isValidChanged)
    Q_PROPERTY(QString appKey READ appKey WRITE setAppKey NOTIFY appKeyChanged)
    Q_PROPERTY(QString dataDirectory READ dataDirectory WRITE setDataDirectory NOTIFY dataDirectoryChanged)
    Q_PROPERTY(int customClientType READ customClientType WRITE setCustomClientType NOTIFY customClientTypeChanged)
    Q_PROPERTY(bool usePrivateConfig READ usePrivateConfig WRITE setUsePrivateConfig NOTIFY usePrivateConfigChanged)

    Q_INVOKABLE bool initialize();
    Q_INVOKABLE void unInitialize();

    bool isValid() const;
    void setIsValid(bool isValid);

    QString appKey() const;
    void setAppKey(const QString& appKey);

    QString dataDirectory() const;
    void setDataDirectory(const QString& dataDirectory);

    int customClientType() const;
    void setCustomClientType(int customClientType);

    bool usePrivateConfig() const;
    void setUsePrivateConfig(bool usePrivateConfig);

public:
    nem_sdk::IAuthService* getAuthService() const;
    nem_sdk::IDeviceService* getDeviceService() const;
    nem_sdk::IPreMeetingService* getPreMeetingService() const;
    nem_sdk::IMeetingService* getMeetingService() const;

Q_SIGNALS:
    void isValidChanged();
    void appKeyChanged();
    void dataDirectoryChanged();
    void customClientTypeChanged();
    void usePrivateConfigChanged();

private:
    nem_sdk::IGlobalService* m_globalService = nullptr;
    bool m_isValid = false;
    QString m_appKey;
    QString m_dataDirectory;
    int m_customClientType;
    bool m_usePrivateConfig = false;
};

#endif  // MEETING_PLUGINS_NEM_ENGINE_H_
