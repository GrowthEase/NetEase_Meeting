// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "user_controller.h"
#include "manager/global_manager.h"
#include "manager/meeting_manager.h"

#define ROOMCONTEXT auto roomContext = MeetingManager::getInstance()->getRoomContext();

NEMeetingUserController::NEMeetingUserController() {}

NEMeetingUserController::~NEMeetingUserController() {}

bool NEMeetingUserController::changeMyName(const std::string& name, const neroom::NECallback<>& callback) {
    return true;
}

bool NEMeetingUserController::makeHost(const std::string& userId, const neroom::NECallback<>& callback) {
    return true;
}

bool NEMeetingUserController::removeUser(const std::string& userId, const neroom::NECallback<>& callback) {
    ROOMCONTEXT
    if (roomContext) {
        roomContext->kickMemberOut(userId, callback);
    }
    return true;
}

bool NEMeetingUserController::raiseMyHand(bool bRaise, const neroom::NECallback<>& callback) {
    ROOMCONTEXT
    if (roomContext) {
        if (bRaise) {
            roomContext->updateMemberProperty(AuthManager::getInstance()->getAuthInfo().accountId, "handsUp", "1", callback);
        } else {
            roomContext->deleteMemberProperty(AuthManager::getInstance()->getAuthInfo().accountId, "handsUp", callback);
        }
        return true;
    }
    return false;
}

bool NEMeetingUserController::lowerHand(const std::string& userId, const neroom::NECallback<>& callback) {
    ROOMCONTEXT
    if (roomContext) {
        roomContext->updateMemberProperty(userId, "handsUp", "2", callback);
        return true;
    }
    return false;
}

bool NEMeetingUserController::lowerAllHands(const neroom::NECallback<>& callback) {
    return true;
}

bool NEMeetingUserController::muteParticipantAudioAndVideo(const std::string& userId, bool mute, const neroom::NECallback<>& callback) {
    ROOMCONTEXT
    if (roomContext) {
        auto rtcController = roomContext->getRtcController();
        if (rtcController) {
            if (mute) {
                rtcController->muteMemberAudio(userId);
                rtcController->muteMemberVideo(userId, callback);
            } else {
                auto messageService = GlobalManager::getInstance()->getMessageService();
                if (messageService) {
                    QJsonObject dataObj;
                    dataObj["type"] = 3;
                    dataObj["category"] = "meeting_control";
                    QByteArray byteArray = QJsonDocument(dataObj).toJson(QJsonDocument::Compact);
                    messageService->sendCustomMessage(MeetingManager::getInstance()->meetingId().toStdString(), userId, 99, byteArray.data(),
                                                      callback);
                }
            }
            return true;
        }
    }
    return false;
}
