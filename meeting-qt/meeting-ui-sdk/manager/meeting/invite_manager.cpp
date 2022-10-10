// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "invite_manager.h"
#include "manager/meeting_manager.h"

InviteManager::InviteManager(QObject* parent)
    : QObject(parent) {
    m_sipController = std::make_shared<NESipController>();
}

void InviteManager::getInviteList() {
    m_sipController->getInviteList(MeetingManager::getInstance()->meetingId(),
                                   [=](int error_code, const std::string& error_msg, const std::vector<NEInvitation>& invitations) {
                                       if (error_code == 200) {
                                           m_list.assign(invitations.begin(), invitations.end());
                                           emit sipChanged();
                                       }
                                   });
}

void InviteManager::addSip(const QString& number, const QString& address) {
    NEInvitation invitation;
    invitation.sipNum = number;
    invitation.sipHost = address;
    m_sipController->invite(MeetingManager::getInstance()->meetingId(), invitation, [this](int error_code, const std::string& error_msg) {
        emit error(error_code, QString::fromStdString(error_msg));
        if (error_code == 200) {
            this->getInviteList();
        }
    });
}

std::list<NEInvitation> InviteManager::getSipList() const {
    return m_list;
}
