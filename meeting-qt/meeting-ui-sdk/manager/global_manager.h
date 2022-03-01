/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2014-2020 NetEase, Inc.
// All right reserved.

#ifndef GLOBALMANAGER_H
#define GLOBALMANAGER_H

#include "auth_service_interface.h"
#include "controller/audio_ctrl_interface.h"
#include "controller/beauty_ctrl_interface.h"
#include "controller/chat_ctrl_interface.h"
#include "controller/video_ctrl_interface.h"
#include "in_room_service_interface.h"
#include "manager/auth_manager.h"
#include "pre_room_service_interface.h"
#include "room_kit_interface.h"
#include "room_service_interface.h"
#include "settings_service_interface.h"
#include "utils/singleton.h"

using namespace neroom;

class GlobalManager : public QObject {
    Q_OBJECT
public:
    SINGLETONG(GlobalManager);
    ~GlobalManager();

    bool initialize(const QString& appKey, bool bprivate = false, const QString& deviceId = QString());
    void release();

    INEAuthService* getAuthService();
    INEPreRoomService* getPreRoomService();
    INERoomService* getRoomService();
    INEInRoomService* getInRoomService();
    INESettingsService* getGlobalConfig();

public:
    GlobalManager();

    QString globalAppKey() const;
    void setGlobalAppKey(const QString& globalAppKey);

signals:
    void showSettingsWindow();

public slots:
    void showSettingsWnd();

private:
    INERoomKit* m_globalService = nullptr;
    QString m_globalAppKey;
};

#endif  // GLOBALMANAGER_H
