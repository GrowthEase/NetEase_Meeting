/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2014-2020 NetEase, Inc.
// All right reserved.

#ifndef LIVEMANAGER_H
#define LIVEMANAGER_H

#include <QObject>
#include "controller/livestream_ctrl_interface.h"

using namespace neroom;

enum LiveStreamLayout { Gallery_layout = 1, Focus_layout = 2, No_Layout = 3 };

class LiveManager : public QObject {
    Q_OBJECT

private:
    LiveManager(QObject* parent = nullptr);
    ~LiveManager();

public:
    void onLiveStreamStatusChanged(int liveState);
    void initLiveStreamStatus(int liveState);

public:
    SINGLETONG(LiveManager)

    Q_INVOKABLE QString getLiveUrl();
    Q_INVOKABLE QString getLiveTittle();
    Q_INVOKABLE QString getLivePassword();
    Q_INVOKABLE bool getLiveChatRoomEnable();
    Q_INVOKABLE bool getLiveAccessEnable();
    Q_INVOKABLE int getLiveLayout();
    Q_INVOKABLE int getLiveUserCount();
    Q_INVOKABLE QJsonArray getLiveUsersList();
    Q_INVOKABLE bool startLive(QJsonObject liveParams);
    Q_INVOKABLE bool updateLive(QJsonObject liveParams);
    Q_INVOKABLE bool stopLive();

signals:
    void liveStateChanged(bool isLive, bool isJoin);
    void liveUpdateFinished(bool success, QString errMsg);
    void liveStartFinished(bool success, QString errMsg);
    void liveStopFinished(bool success, QString errMsg);

private:
    INERoomLivingController* m_liveStreamController = nullptr;
    NEInRoomLiveInfo m_liveParam;
};

#endif  // LIVEMANAGER_H
