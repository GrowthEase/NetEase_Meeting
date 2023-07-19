// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef LIVEMANAGER_H
#define LIVEMANAGER_H

#include <QObject>
#include "controller/live_ctrl_interface.h"

enum LiveStreamLayout { Gallery_layout = 1, Focus_layout = 2, No_Layout = 3 };

class LiveManager : public QObject {
    Q_OBJECT

private:
    LiveManager(QObject* parent = nullptr);
    ~LiveManager();

public:
    void onLiveStreamStatusChanged(int liveState);
    void initLiveStreamStatus();

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

private:
    bool initLiveInfo();

signals:
    void liveStateChanged(bool isLive, bool isJoin);
    void liveStateChanged(int state);
    void liveUpdateFinished(bool success, QString errMsg);
    void liveStartFinished(bool success, QString errMsg);
    void liveStopFinished(bool success, QString errMsg);

private:
    neroom::NERoomLiveInfo m_liveInfo;
    bool m_liveChatRoomEnable = false;
    bool m_onlyEmployeesAllow = false;
};

#endif  // LIVEMANAGER_H
