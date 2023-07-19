// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef GLOBALMANAGER_H
#define GLOBALMANAGER_H

#include "auth_service_interface.h"
#include "controller/chat_ctrl_interface.h"
#include "controller/config_controller.h"
#include "controller/pre_rtc_ctrl_interface.h"
#include "controller/rtc_ctrl_interface.h"
#include "manager/auth_manager.h"
#include "message_service_interface.h"
#include "nos_service_interface.h"
#include "room_kit_interface.h"
#include "room_service_interface.h"
#include "utils/singleton.h"

using namespace neroom;

class NEMessageListener : public INEMessageChannelListener {
    virtual void onReceiveCustomMessage(const NECustomMessage& message) override;
};

class GlobalManager : public QObject {
    Q_OBJECT
public:
    SINGLETONG(GlobalManager);
    ~GlobalManager();

    bool initialize(const QString& appKey, bool bPrivate, const QString& serverUrl, const QString& deviceId, const NEConfigCallback& callback);
    void release();

    INEAuthService* getAuthService();
    INERoomService* getRoomService();
    INEMessageChannelService* getMessageService();
    INENosService* getNosService();
    std::shared_ptr<NEConfigController> getGlobalConfig();
    INEPreviewRoomContext* getPreviewRoomContext();
    INEPreviewRoomRtcController* getPreviewRoomRtcController();

public:
    GlobalManager();
    QString globalAppKey() const;
    void setGlobalAppKey(const QString& globalAppKey);
    void dealMessage(const std::string& data);
    neroom::NESDKVersions getVersions() const;
    QString serverUrl() const { return m_serverUrl; }
    void setLanguage(const std::string& language) { m_language = language; }
    std::string language() const { return m_language; }

private:
    void dealMeetingStatusChanged(const QJsonObject& data);
    void dealAudioOpenRequest();
    void dealVideoOpenRequest();
    void initPrivate();

signals:
    void showSettingsWindow();

public slots:
    void showSettingsWnd();

private:
    NEMessageListener* m_messageListener = nullptr;
    INERoomKit* m_roomkitService = nullptr;
    neroom::INEPreviewRoomContext* m_pPreviewRoomContext = nullptr;
    std::shared_ptr<NEConfigController> m_configController = nullptr;
    QString m_globalAppKey;
    QString m_serverUrl;
    std::string m_language;
};

#endif  // GLOBALMANAGER_H
