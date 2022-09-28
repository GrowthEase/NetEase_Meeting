// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "meeting_controller.h"
#include "controller/rtc_ctrl_interface.h"
#include "manager/auth_manager.h"
#include "manager/global_manager.h"
#include "manager/meeting/share_manager.h"
#include "modules/http/http_manager.h"
#include "modules/http/http_request.h"

NEMeetingController::NEMeetingController() {
    m_pRoomListener = new NEInRoomServiceListener();
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        previewRoomContext->addPreviewRoomListener(m_pRoomListener);
    }
}

NEMeetingController::~NEMeetingController() {
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        previewRoomContext->removePreviewRoomListener(m_pRoomListener);
    }
}

bool NEMeetingController::startRoom(const nem_sdk_interface::NEStartMeetingParams& param,
                                    const NERoomOptions& option,
                                    const neroom::NECallback<>& callback) {
    NERoomInfo roomInfo;
    m_roomInfo = roomInfo;
    m_pRoomContext = nullptr;

    NEMeetingType meetingType = param.meetingId == AuthManager::getInstance()->getAuthInfo().personalRoomId ? personnalType : randomType;
    NEMeetingResources resources;
    resources.live = false;
    resources.chatroom = !option.noChat && GlobalManager::getInstance()->getGlobalConfig()->isChatroomSupported();
    resources.record = !option.noCloudRecord && GlobalManager::getInstance()->getGlobalConfig()->isCloudRecordSupported();
    resources.sip = !option.noSip && GlobalManager::getInstance()->getGlobalConfig()->isSipSupported();
    resources.whiteboard = GlobalManager::getInstance()->getGlobalConfig()->isWhiteboardSupported();
    QJsonObject roomProperties;
    initRoomProperties(roomProperties);
    QJsonObject extraDataObj;
    extraDataObj["value"] = QString::fromStdString(param.extraData);
    roomProperties["extraData"] = extraDataObj;

    for (auto control : param.controls) {
        if (control.type == kControlTypeAudio) {
            QJsonObject audioOffObj;
            if (control.attendeeOff == kAttendeeOffAllowSelfOn) {
                audioOffObj["value"] = QString("offAllowSelfOn").append("_").append(QString::number(QDateTime::currentMSecsSinceEpoch()));
            } else if (control.attendeeOff == kAttendeeOffNotAllowSelfOn) {
                audioOffObj["value"] = QString("offNotAllowSelfOn").append("_").append(QString::number(QDateTime::currentMSecsSinceEpoch()));
            }
            roomProperties["audioOff"] = audioOffObj;
        } else if (control.type == kControlTypeVideo) {
            QJsonObject videoOffObj;
            if (control.attendeeOff == kAttendeeOffAllowSelfOn) {
                videoOffObj["value"] = QString("offAllowSelfOn").append("_").append(QString::number(QDateTime::currentMSecsSinceEpoch()));
            } else if (control.attendeeOff == kAttendeeOffNotAllowSelfOn) {
                videoOffObj["value"] = QString("offNotAllowSelfOn").append("_").append(QString::number(QDateTime::currentMSecsSinceEpoch()));
            }
            roomProperties["videoOff"] = videoOffObj;
        }
    }

    QJsonObject roleBindsObj;
    for (auto iter = param.roleBinds.begin(); iter != param.roleBinds.end(); iter++) {
        QString userId = QString::fromStdString(iter->first);
        NEMeetingRoleType roleType = iter->second;
        QString qstrRoleType;
        if (roleType == normal) {
            qstrRoleType = "member";
        } else if (roleType == host) {
            qstrRoleType = "host";
        } else if (roleType == cohost) {
            qstrRoleType = "cohost";
        }
        roleBindsObj[userId] = qstrRoleType;
    }

    CreateMeetingRequest createMeetingRequest(meetingType, "", resources, roomProperties, QString::fromStdString(param.password), roleBindsObj);
    HttpManager::getInstance()->putRequest(createMeetingRequest, [=](int code, const QJsonObject& response) {
        if (code == 200) {
            std::string roomUniqueId = std::to_string(response["meetingId"].toInt());
            std::string roomSubject = response["subject"].toString().toStdString();
            neroom::NEJoinRoomParams params;
            params.role = "host";
            params.roomUuid = response["roomUuid"].toString().toStdString();
            params.userName = param.displayName;

            std::string shortRoomId = response["shortMeetingNum"].toString().toStdString();
            params.initialProperties.insert(std::make_pair("tag", param.tag));

            NEMeetingType type = (NEMeetingType)response["type"].toInt();
            uint64_t scheduleTimeBegin = response["startTime"].toVariant().toULongLong();
            uint64_t scheduleTimeEnd = response["endTime"].toVariant().toULongLong();

            m_roomInfo.creatorUserId = response["ownerUserUuid"].toString().toStdString();
            m_roomInfo.creatorUserName = response["ownerNickname"].toString().toStdString();

            neroom::NEJoinRoomOptions options;
            GlobalManager::getInstance()->getRoomService()->joinRoom(
                params, options, [=](int code, const std::string& message, INERoomContext* roomContext) {
                    Invoker::getInstance()->execute([=]() {
                        if (code == 0) {
                            if (roomContext) {
                                m_pRoomContext = roomContext;
                                roomContext->addRoomListener(m_pRoomListener);
                                roomContext->addRtcStatsListener(m_pRoomListener);
                                m_roomInfo.displayName = params.userName;
                                m_roomInfo.roomUniqueId = roomUniqueId;
                                m_roomInfo.password = param.password;
                                m_roomInfo.shortRoomId = shortRoomId;
                                m_roomInfo.roomId = params.roomUuid;
                                m_roomInfo.startTime = roomContext->getRtcStartTime();
                                m_roomInfo.type = type;
                                m_roomInfo.screenSharingUserId = roomContext->getRtcController()->getScreenSharingUserUuid();
                                if (NEMeetingType::schduleType == type) {
                                    m_roomInfo.scheduleTimeBegin = scheduleTimeBegin;
                                    m_roomInfo.scheduleTimeEnd = scheduleTimeEnd;
                                }
                                MeetingManager::getInstance()->startJoinTimer();
                                roomContext->getRtcController()->joinRtcChannel(callback);
                            }
                        }

                        if (callback) {
                            callback(code, message);
                        }
                    });
                });
        } else {
            callback(code, response["msg"].toString().toStdString());
        }
    });
    return true;
}

bool NEMeetingController::joinRoom(const nem_sdk_interface::NEJoinMeetingParams& param,
                                   const NERoomOptions& option,
                                   const neroom::NECallback<>& callback) {
    NERoomInfo roomInfo;
    m_roomInfo = roomInfo;
    m_pRoomContext = nullptr;

    GetMeetingInfoRequest getMeetingInfoRequest(QString::fromStdString(param.meetingId));
    HttpManager::getInstance()->getRequest(getMeetingInfoRequest, [=](int code, const QJsonObject& response) {
        if (code == 200) {
            neroom::NEJoinRoomParams params;
            params.role = "host";
            params.roomUuid = response["roomUuid"].toString().toStdString();
            params.userName = param.displayName;
            params.password = param.password;
            params.initialProperties.insert(std::make_pair("tag", param.tag));
            std::string roomUniqueId = std::to_string(response["meetingId"].toInt());
            std::string shortRoomId = response["shortMeetingNum"].toString().toStdString();

            if (response.contains("settings")) {
                auto settings = response["settings"].toObject();
                if (settings.contains("roomInfo")) {
                    auto roomInfo = settings["roomInfo"].toObject();
                    if (roomInfo.contains("roomConfig")) {
                        auto roomConfig = roomInfo["roomConfig"].toObject();
                        if (roomConfig.contains("resource")) {
                            auto resource = roomConfig["resource"].toObject();
                            if (resource.contains("live")) {
                                m_roomInfo.enableLive = resource["live"].toBool();
                            }
                        }
                    }
                }

                if (settings.contains("liveConfig")) {
                    auto liveConfig = settings["liveConfig"].toObject();
                    if (liveConfig.contains("liveAddress")) {
                        m_roomInfo.liveUrl = liveConfig["liveAddress"].toString().toStdString();
                    }
                }
            }

            NEMeetingType type = (NEMeetingType)response["type"].toInt();
            uint64_t scheduleTimeBegin = response["startTime"].toVariant().toULongLong();
            uint64_t scheduleTimeEnd = response["endTime"].toVariant().toULongLong();

            m_roomInfo.creatorUserId = response["ownerUserUuid"].toString().toStdString();
            m_roomInfo.creatorUserName = response["ownerNickname"].toString().toStdString();

            neroom::NEJoinRoomOptions options;
            GlobalManager::getInstance()->getRoomService()->joinRoom(
                params, options, [=](int code, const std::string& message, INERoomContext* roomContext) {
                    Invoker::getInstance()->execute([=]() {
                        if (code == 0) {
                            if (roomContext) {
                                m_pRoomContext = roomContext;
                                roomContext->addRoomListener(m_pRoomListener);
                                roomContext->addRtcStatsListener(m_pRoomListener);
                                MeetingManager::getInstance()->startJoinTimer();
                                roomContext->getRtcController()->joinRtcChannel(callback);
                                m_roomInfo.shortRoomId = shortRoomId;
                                m_roomInfo.roomUniqueId = roomUniqueId;
                                m_roomInfo.displayName = params.userName;
                                m_roomInfo.password = params.password;
                                m_roomInfo.roomId = params.roomUuid;
                                m_roomInfo.startTime = roomContext->getRtcStartTime();
                                m_roomInfo.type = type;
                                m_roomInfo.screenSharingUserId = roomContext->getRtcController()->getScreenSharingUserUuid();
                                if (NEMeetingType::schduleType == type) {
                                    m_roomInfo.scheduleTimeBegin = scheduleTimeBegin;
                                    m_roomInfo.scheduleTimeEnd = scheduleTimeEnd;
                                }
                            }
                        }
                        if (callback) {
                            callback(code, message);
                        }
                    });
                });
        } else {
            callback(code, response["msg"].toString().toStdString());
        }
    });

    return true;
}

bool NEMeetingController::leaveCurrentRoom(bool finish, const neroom::NECallback<>& callback) {
    if (m_pRoomContext) {
        if (finish) {
            m_pRoomContext->endRoom(callback);
        } else {
            m_pRoomContext->leaveRoom(callback);
        }
        m_pRoomContext = nullptr;
        return true;
    }
    return false;
}

INERoomContext* NEMeetingController::getRoomContext() {
    return m_pRoomContext;
}

void NEMeetingController::initRoomProperties(QJsonObject& object) {
    QJsonObject focus;
    focus["value"] = "";
    object["focus"] = focus;
}

void NEMeetingController::initRoomInfo() {
    auto roomContext = getRoomContext();
    if (roomContext) {
        m_roomInfo.lock = roomContext->isRoomLocked();
        m_roomInfo.subject = roomContext->getRoomName();
        m_roomInfo.roomId = roomContext->getRoomUuid();
        m_roomInfo.password = roomContext->getPassword();
        m_roomInfo.startTime = roomContext->getRtcStartTime();
        m_roomInfo.sipId = roomContext->getSipCid();
        m_roomInfo.remainingSeconds = roomContext->getRemainingSeconds();
        auto properties = roomContext->getRoomProperties();
        auto propertiesIter = properties.begin();
        for (propertiesIter; propertiesIter != properties.end(); propertiesIter++) {
            auto key = propertiesIter->first;
            auto value = QString::fromStdString(propertiesIter->second);
            QJsonDocument document = QJsonDocument::fromJson(value.toUtf8());
            QJsonObject Object = document.object();
            if (key == "focus") {
                m_roomInfo.focusAccountId = value.toStdString();
            } else if (key == "extraData") {
                m_roomInfo.extraData = value.toStdString();
            } else if (key == "audioOff") {
                QString type = value.left(value.indexOf("_"));
                if (type == "offAllowSelfOn") {
                    m_roomInfo.allowSelfAudioOn = true;
                    m_roomInfo.audioAllMute = true;
                } else if (type == "offNotAllowSelfOn") {
                    m_roomInfo.allowSelfAudioOn = false;
                    m_roomInfo.audioAllMute = true;
                } else {
                    m_roomInfo.allowSelfAudioOn = true;
                    m_roomInfo.audioAllMute = false;
                }
            } else if (key == "videoOff") {
                QString type = value.left(value.indexOf("_"));
                if (type == "offAllowSelfOn") {
                    m_roomInfo.allowSelfVideoOn = true;
                    m_roomInfo.videoAllmute = true;
                } else if (type == "offNotAllowSelfOn") {
                    m_roomInfo.allowSelfVideoOn = false;
                    m_roomInfo.videoAllmute = true;
                } else {
                    m_roomInfo.allowSelfVideoOn = true;
                    m_roomInfo.videoAllmute = false;
                }
            }
        }
    }
}

void NEMeetingController::resetRoomContext() {
    m_pRoomContext = nullptr;
}

void NEMeetingController::updateDisplayName(const std::string& displayName) {
    m_roomInfo.displayName = displayName;
}

void NEMeetingController::updateFocusAccountId(const std::string& focusAccountId) {
    m_roomInfo.focusAccountId = focusAccountId;
}

void NEMeetingController::updateHostAccountId(const std::string& hostAccountId) {
    m_roomInfo.hostAccountId = hostAccountId;
}

void NEMeetingController::updateIsLock(bool lock) {
    m_roomInfo.lock = lock;
}

void NEMeetingController::updateAudioAllMute(bool audioAllMute) {
    m_roomInfo.audioAllMute = audioAllMute;
}

void NEMeetingController::updateVideoAllmute(bool videoAllmute) {
    m_roomInfo.videoAllmute = videoAllmute;
}

void NEMeetingController::updateAllowSelfAudioOn(bool allowSelfAudioOn) {
    m_roomInfo.allowSelfAudioOn = allowSelfAudioOn;
}

void NEMeetingController::updateAllowSelfVideoOn(bool allowSelfVideoOn) {
    m_roomInfo.allowSelfVideoOn = allowSelfVideoOn;
}
