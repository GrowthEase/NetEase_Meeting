// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef NERSIPCONTROLLER_H
#define NERSIPCONTROLLER_H

#include "base_type_defines.h"

/**
 * @brief 邀请通话类型
 */
enum NEInviteType {
    /**
     * p2p
     */
    kInviteP2P = 0,

    /**
     * 多人房间
     */
    kInviteGroup = 1,

    /**
     * 第三方sip
     */
    kInviteSip = 2,
};

/**
 * @brief 邀请通话状态
 */
enum NEInviteStatus {
    /**
     * 邀请中
     */
    kInvite = 0,

    /**
     * 已加入
     */
    kInviteJoined = 1,

    /**
     * 已拒绝
     */
    kInviteRefused = 2,
};

/**
 * @brief 房间邀请信息
 */
typedef struct tagNERoomInvitation {
    QString sipNum;
    QString sipHost;
    NEInviteStatus status = kInvite;
} NEInvitation;

class NESipController {
public:
    using NEGetInviteListCallback = neroom::NECallback<std::vector<NEInvitation>>;

public:
    NESipController();
    ~NESipController();

    void invite(const QString& meetingId, const NEInvitation& invitation, const neroom::NECallback<>& callback = neroom::NECallback<>());
    void getInviteList(const QString& meetingId, const NEGetInviteListCallback& callback);
};

#endif  // NERSIPCONTROLLER_H
