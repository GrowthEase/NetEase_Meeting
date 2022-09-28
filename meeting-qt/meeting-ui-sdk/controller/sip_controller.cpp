// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "sip_controller.h"
#include "modules/http/http_manager.h"
#include "modules/http/http_request.h"

NESipController::NESipController() {}

NESipController::~NESipController() {}

void NESipController::invite(const QString& meetingId, const NEInvitation& invitation, const neroom::NECallback<>& callback) {
    SipInviteRequest sipInviteRequest(meetingId, invitation.sipNum, invitation.sipHost);
    HttpManager::getInstance()->postRequest(sipInviteRequest, [=](int code, const QJsonObject& response) {
        if (callback) {
            callback(code, response["msg"].toString().toStdString());
        }
    });
}

void NESipController::getInviteList(const QString& meetingId, const NESipController::NEGetInviteListCallback& callback) {
    GetSipInviteListRequest getSipInviteListRequest(meetingId);
    HttpManager::getInstance()->getRequest(getSipInviteListRequest, [=](int code, const QJsonObject& response) {
        std::vector<NEInvitation> invitationList;
        if (code == 200) {
            QJsonArray inviterList = response["list"].toArray();
            for (auto it : inviterList) {
                QJsonObject object = it.toObject();
                NEInvitation invaitation;
                invaitation.sipNum = object["sipNum"].toString();
                invaitation.sipHost = object["sipHost"].toString();
                invitationList.push_back(invaitation);
            }
        }
        if (callback) {
            callback(code, response["msg"].toString().toStdString(), invitationList);
        }
    });
}
