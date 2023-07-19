// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nem_members_controller.h"

NEMMembersController::NEMMembersController(QObject* parent)
    : QObject(parent)
    , m_invoker(new Invoker) {}

bool NEMMembersController::isValid() const {
    return m_isValid;
}

void NEMMembersController::setIsValid(bool isValid) {
    if (m_isValid != isValid) {
        m_isValid = isValid;
        Q_EMIT isValidChanged();
    }
}

nem_sdk::IMembersController* NEMMembersController::membersController() const {
    return m_membersController;
}

void NEMMembersController::setMembersController(nem_sdk::IMembersController* videoController) {
    if (m_membersController != videoController) {
        m_membersController = videoController;
        if (m_membersController != nullptr) {
            m_membersController->setMeetingMemberEventHandler(this);
            setIsValid(true);
        }
    }
}

QVector<MemberInfo> NEMMembersController::items() const {
    return m_items;
}

void NEMMembersController::onBeforeUserJoin(const std::string& accountId, uint32_t memberCount) {
    Q_UNUSED(accountId)
    Q_UNUSED(memberCount)
}

void NEMMembersController::onAfterUserJoined(const std::string& accountId, bool bNotify) {
    Q_UNUSED(bNotify)
    m_invoker->execute([=]() {
        if (m_membersController) {
            auto member = m_membersController->getMemberInfoById(accountId);
            if (member) {
                Q_EMIT preItemAppended();
                MemberInfo info;
                info.accountId = QString::fromStdString(member->getAccountId());
                info.audioStatus = (NEMAudioController::AudioDeviceStatus)member->getAudioStatus();
                info.videoStatus = (NEMVideoController::VideoDeviceStatus)member->getVideoStatus();
                info.nickname = QString::fromStdString(member->getNickname());
                info.sharing = member->getSharingStatus();
                info.avRoomUid = member->getAvRoomUid();
                m_items.append(info);
                Q_EMIT postItemAppended();
            }
        }
    });
}

void NEMMembersController::onBeforeUserLeave(const std::string& accountId, uint32_t memberIndex) {
    Q_UNUSED(accountId)
    Q_UNUSED(memberIndex)
}

void NEMMembersController::onAfterUserLeft(const std::string& accountId) {
    m_invoker->execute([=]() {
        for (int i = 0; i < m_items.size(); i++) {
            QString qstrAccountId = QString::fromStdString(accountId);
            if (m_items.at(i).accountId == qstrAccountId) {
                Q_EMIT preItemRemoved(i);
                m_items.remove(i);
                Q_EMIT postItemRemoved();
                break;
            }
        }
    });
}

void NEMMembersController::onHostChanged(const std::string& hostAccountId) {
    Q_UNUSED(hostAccountId)
}

void NEMMembersController::onMemberNicknameChanged(const std::string& accountId, const std::string& nickname) {
    Q_UNUSED(accountId)
    Q_UNUSED(nickname)
}

void NEMMembersController::onNetworkQuality(const std::string& accountId, nem_sdk::NetWorkQuality up, nem_sdk::NetWorkQuality down) {
    Q_UNUSED(accountId)
    Q_UNUSED(up)
    Q_UNUSED(down)
}

void NEMMembersController::handleAudioStatusChanged(const QString& accountId, NEMAudioController::AudioDeviceStatus status) {
    if (m_membersController) {
        for (int i = 0; i < m_items.size(); i++) {
            auto item = m_items.at(i);
            if (m_items.at(i).accountId == accountId) {
                item.audioStatus = (NEMAudioController::AudioDeviceStatus)status;
                m_items[i] = item;
                Q_EMIT dataChanged(i);
                break;
            }
        }
    }
}

void NEMMembersController::handleVideoStatusChanged(const QString& accountId, NEMVideoController::VideoDeviceStatus status) {
    if (m_membersController) {
        for (int i = 0; i < m_items.size(); i++) {
            auto item = m_items.at(i);
            if (m_items.at(i).accountId == accountId) {
                item.videoStatus = (NEMVideoController::VideoDeviceStatus)status;
                m_items[i] = item;
                Q_EMIT dataChanged(i);
                break;
            }
        }
    }
}
