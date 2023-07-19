// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEETING_PLUGINS_COMPONENTS_MEETING_NEM_MEMBERS_CONTROLLER_H_
#define MEETING_PLUGINS_COMPONENTS_MEETING_NEM_MEMBERS_CONTROLLER_H_

#include <QObject>
#include <QPointer>
#include <QVector>
#include <string>
#include <vector>
#include "components/auth/nem_account.h"
#include "components/meeting/nem_audio_controller.h"
#include "components/meeting/nem_video_controller.h"
#include "meeting/members_ctrl_interface.h"
#include "utils/invoker.h"

typedef struct _tagMemberInfo {
    QString accountId;
    QString nickname;
    quint64 avRoomUid;
    NEMAudioController::AudioDeviceStatus audioStatus;
    NEMVideoController::VideoDeviceStatus videoStatus;
    bool sharing;
} MemberInfo;

class NEMMembersController : public QObject, public nem_sdk::IMembersEventHandler {
    Q_OBJECT
    Q_ENUMS(DeviceStatus)

public:
    explicit NEMMembersController(QObject* parent = nullptr);

    Q_PROPERTY(bool isValid READ isValid NOTIFY isValidChanged)

    bool isValid() const;
    void setIsValid(bool isValid);

    nem_sdk::IMembersController* membersController() const;
    void setMembersController(nem_sdk::IMembersController* videoController);

public:
    QVector<MemberInfo> items() const;

Q_SIGNALS:
    void isValidChanged();
    void preItemAppended();
    void postItemAppended();
    void preItemRemoved(int index);
    void postItemRemoved();
    void dataChanged(int index);

protected:
    void onBeforeUserJoin(const std::string& accountId, uint32_t memberCount) override;
    void onAfterUserJoined(const std::string& accountId, bool bNotify) override;
    void onBeforeUserLeave(const std::string& accountId, uint32_t memberIndex) override;
    void onAfterUserLeft(const std::string& accountId) override;
    void onHostChanged(const std::string& hostAccountId) override;
    void onMemberNicknameChanged(const std::string& accountId, const std::string& nickname) override;
    void onNetworkQuality(const std::string& accountId, nem_sdk::NetWorkQuality up, nem_sdk::NetWorkQuality down) override;

public Q_SLOTS:
    void handleAudioStatusChanged(const QString& accountId, NEMAudioController::AudioDeviceStatus status);
    void handleVideoStatusChanged(const QString& accountId, NEMVideoController::VideoDeviceStatus status);

private:
    bool m_isValid = false;
    nem_sdk::IMembersController* m_membersController = nullptr;
    QVector<MemberInfo> m_items;
    QPointer<Invoker> m_invoker = nullptr;
};

#endif  // MEETING_PLUGINS_COMPONENTS_MEETING_NEM_MEMBERS_CONTROLLER_H_
