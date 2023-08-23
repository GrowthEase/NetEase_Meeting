// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "meeting_controller.h"
#include <QSharedPointer>
#include "controller/rtc_ctrl_interface.h"
#include "manager/auth_manager.h"
#include "manager/global_manager.h"
#include "manager/meeting/share_manager.h"
#include "modules/http/http_manager.h"
#include "modules/http/http_request.h"
#include "statistics/meeting/meeting_event_base.h"

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

    NEMeetingType meetingType = param.meetingNum == AuthManager::getInstance()->getAuthInfo().personalRoomId ? personnalType : randomType;
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
        if (roleType == NEMeetingRoleType::normal) {
            qstrRoleType = "member";
        } else if (roleType == NEMeetingRoleType::host) {
            qstrRoleType = "host";
        } else if (roleType == NEMeetingRoleType::cohost) {
            qstrRoleType = "cohost";
        }
        roleBindsObj[userId] = qstrRoleType;
    }

    auto event = std::make_shared<CreateMeetingEvent>();
    auto createStep = std::make_shared<MeetingEventStepBase>("create_room");
    createStep->SetStartTime(QDateTime::currentDateTime().toMSecsSinceEpoch());
    CreateMeetingRequest createMeetingRequest(meetingType, QString::fromStdString(param.subject), resources, roomProperties,
                                              QString::fromStdString(param.password), roleBindsObj);
    HttpManager::getInstance()->putRequest(createMeetingRequest, [=](int code, const QJsonObject& response) {
        createStep->SetEndTime(QDateTime::currentDateTime().toMSecsSinceEpoch());
        createStep->SetResultCode(code == kHttpResSuccess ? response["code"].toInt() : code);
        createStep->SetStepMessage(code == kHttpResSuccess ? response["msg"].toString().toStdString() : "");
        createStep->SetStepRequestID(code == kHttpResSuccess ? response["requestId"].toString().toStdString() : "");
        createStep->SetServerCost(code == kHttpResSuccess ? response["cost"].toInt() : 0);
        event->AddStep(createStep);
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
            m_roomInfo.roomId = params.roomUuid;
            m_roomInfo.roomUniqueId = roomUniqueId;
            m_roomInfo.roomArchiveId = response["roomArchiveId"].toString().toStdString();
            m_roomInfo.creatorUserId = response["ownerUserUuid"].toString().toStdString();
            m_roomInfo.creatorUserName = response["ownerNickname"].toString().toStdString();
            m_roomInfo.displayName = params.userName;
            m_roomInfo.roomUniqueId = roomUniqueId;
            m_roomInfo.password = param.password;
            m_roomInfo.shortRoomId = shortRoomId;
            m_roomInfo.roomId = params.roomUuid;
            m_roomInfo.type = type;
            if (response.contains("meetingInviteUrl")) {
                m_roomInfo.inviteUrl = response["meetingInviteUrl"].toString().toStdString();
            }
            neroom::NEJoinRoomOptions options;
            // events
            options.enableMyAudioDeviceOnJoinRtc = true;
            event->meeting_number_ = m_roomInfo.roomId;
            event->meeting_id_ = m_roomInfo.roomUniqueId;
            event->room_archive_id_ = m_roomInfo.roomArchiveId;
            event->create_type_ = m_roomInfo.type == NEMeetingType::personnalType ? MeetingCreateType::kPersonal : MeetingCreateType::kRandom;
            auto joinStep = std::make_shared<MeetingEventStepBase>("join_room");
            joinStep->SetStartTime(QDateTime::currentDateTime().toMSecsSinceEpoch());
            GlobalManager::getInstance()->getRoomService()->joinRoom(
                params, options, [=](int code, const std::string& message, INERoomContext* roomContext) {
                    Invoker::getInstance()->execute([=]() {
                        joinStep->SetEndTime(QDateTime::currentDateTime().toMSecsSinceEpoch());
                        joinStep->SetResultCode(code);
                        joinStep->SetStepMessage(message);
                        event->AddStep(joinStep);
                        if (code == 0) {
                            if (roomContext) {
                                m_pRoomContext = roomContext;
                                roomContext->addRoomListener(m_pRoomListener);
                                roomContext->addRtcStatsListener(m_pRoomListener);
                                m_roomInfo.startTime = roomContext->getRtcStartTime();
                                m_roomInfo.screenSharingUserId = roomContext->getRtcController()->getScreenSharingUserUuid();
                                if (NEMeetingType::schduleType == type) {
                                    m_roomInfo.scheduleTimeBegin = scheduleTimeBegin;
                                    m_roomInfo.scheduleTimeEnd = scheduleTimeEnd;
                                }
                                MeetingManager::getInstance()->startJoinTimer();
                                if (param.encryptionConfig.enable) {
                                    const auto& config = param.encryptionConfig;
                                    roomContext->getRtcController()->enableEncryption(config.key, static_cast<neroom::NEEncryptionType>(config.type));
                                } else {
                                    roomContext->getRtcController()->disableEncryption();
                                }
                                auto rtcStep = std::make_shared<MeetingEventStepBase>("join_rtc");
                                rtcStep->SetStartTime(QDateTime::currentDateTime().toMSecsSinceEpoch());
                                roomContext->getRtcController()->joinRtcChannel([=](int code, const std::string& message) {
                                    Invoker::getInstance()->execute([=]() {
                                        rtcStep->SetEndTime(QDateTime::currentDateTime().toMSecsSinceEpoch());
                                        rtcStep->SetResultCode(code);
                                        rtcStep->SetStepMessage(message);
                                        event->AddStep(rtcStep);
                                        GlobalManager::getInstance()->getMeetingEventReporter()->AddEvent(event);
                                    });
                                    callback(code, message);
                                });
                            }
                        } else {
                            GlobalManager::getInstance()->getMeetingEventReporter()->AddEvent(event);
                        }
                        if (callback)
                            callback(code, message);
                    });
                });
        } else {
            callback(code, response["msg"].toString().toStdString());
            GlobalManager::getInstance()->getMeetingEventReporter()->AddEvent(event);
        }
    });
    return true;
}

bool NEMeetingController::joinRoom(const nem_sdk_interface::NEJoinMeetingParams& param,
                                   const NERoomOptions& option,
                                   const neroom::NECallback<>& callback,
                                   const QVariant& extraInfo) {
    NERoomInfo roomInfo;
    m_roomInfo = roomInfo;
    m_roomInfo.roomUniqueId = param.meetingNum;
    m_roomInfo.displayName = param.displayName;
    m_pRoomContext = nullptr;

    auto eventQPointer = extraInfo.value<QSharedPointer<JoinMeetingEvent>>();
    std::shared_ptr<JoinMeetingEvent> event = nullptr;
    if (eventQPointer == nullptr) {
        event = std::make_shared<JoinMeetingEvent>();
    } else {
        auto rawEvent = *(eventQPointer.get());
        event.reset(new JoinMeetingEvent(rawEvent));
    }
    event->meeting_number_ = param.meetingNum;

    auto infoStep = std::make_shared<MeetingEventStepBase>("meeting_info");
    infoStep->SetStartTime(QDateTime::currentDateTime().toMSecsSinceEpoch());
    GetMeetingInfoRequest getMeetingInfoRequest(QString::fromStdString(param.meetingNum));
    HttpManager::getInstance()->getRequest(getMeetingInfoRequest, [=](int code, const QJsonObject& response) {
        infoStep->SetEndTime(QDateTime::currentDateTime().toMSecsSinceEpoch());
        infoStep->SetResultCode(code == kHttpResSuccess ? response["code"].toInt() : code);
        infoStep->SetStepMessage(code == kHttpResSuccess ? response["msg"].toString().toStdString() : "");
        infoStep->SetStepRequestID(code == kHttpResSuccess ? response["requestId"].toString().toStdString() : "");
        event->AddStep(infoStep);
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
            m_roomInfo.roomArchiveId = response["roomArchiveId"].toString().toStdString();
            if (response.contains("meetingInviteUrl")) {
                m_roomInfo.inviteUrl = response["meetingInviteUrl"].toString().toStdString();
            }

            neroom::NEJoinRoomOptions options;
            options.enableMyAudioDeviceOnJoinRtc = true;
            auto joinStep = std::make_shared<MeetingEventStepBase>("join_room");
            joinStep->SetStartTime(QDateTime::currentDateTime().toMSecsSinceEpoch());
            GlobalManager::getInstance()->getRoomService()->joinRoom(
                params, options, [=](int code, const std::string& message, INERoomContext* roomContext) {
                    joinStep->SetEndTime(QDateTime::currentDateTime().toMSecsSinceEpoch());
                    joinStep->SetResultCode(code);
                    joinStep->SetStepMessage(message);
                    event->AddStep(joinStep);
                    Invoker::getInstance()->execute([=]() {
                        if (code == 0) {
                            if (roomContext) {
                                m_pRoomContext = roomContext;
                                roomContext->addRoomListener(m_pRoomListener);
                                roomContext->addRtcStatsListener(m_pRoomListener);
                                MeetingManager::getInstance()->startJoinTimer();
                                if (param.encryptionConfig.enable) {
                                    const auto& config = param.encryptionConfig;
                                    roomContext->getRtcController()->enableEncryption(config.key, static_cast<neroom::NEEncryptionType>(config.type));
                                } else {
                                    roomContext->getRtcController()->disableEncryption();
                                }
                                auto rtcStep = std::make_shared<MeetingEventStepBase>("join_rtc");
                                rtcStep->SetStartTime(QDateTime::currentDateTime().toMSecsSinceEpoch());
                                roomContext->getRtcController()->joinRtcChannel(
                                    [callback, this, event, rtcStep](int code, const std::string& message) {
                                        rtcStep->SetEndTime(QDateTime::currentDateTime().toMSecsSinceEpoch());
                                        rtcStep->SetResultCode(code);
                                        rtcStep->SetStepMessage(message);
                                        event->AddStep(rtcStep);
                                        GlobalManager::getInstance()->getMeetingEventReporter()->AddEvent(event);
                                        callback(code, message);
                                    });

                                m_roomInfo.shortRoomId = shortRoomId;
                                m_roomInfo.roomUniqueId = roomUniqueId;
                                m_roomInfo.displayName = params.userName;
                                m_roomInfo.password = params.password;
                                m_roomInfo.roomId = params.roomUuid;
                                m_roomInfo.startTime = roomContext->getRtcStartTime();
                                m_roomInfo.type = type;
                                m_roomInfo.screenSharingUserId = roomContext->getRtcController()->getScreenSharingUserUuid();
                                event->meeting_id_ = roomUniqueId;
                                event->room_archive_id_ = m_roomInfo.roomArchiveId;
                                if (NEMeetingType::schduleType == type) {
                                    m_roomInfo.scheduleTimeBegin = scheduleTimeBegin;
                                    m_roomInfo.scheduleTimeEnd = scheduleTimeEnd;
                                }
                            }
                        } else {
                            GlobalManager::getInstance()->getMeetingEventReporter()->AddEvent(event);
                        }
                        if (callback) {
                            callback(code, message);
                        }
                    });
                });
        } else {
            callback(code, response["msg"].toString().toStdString());
            GlobalManager::getInstance()->getMeetingEventReporter()->AddEvent(event);
        }
    });

    return true;
}

bool NEMeetingController::leaveCurrentRoom(bool finish, const neroom::NECallback<>& callback) {
    if (m_pRoomContext) {
        if (finish) {
            m_pRoomContext->endRoom([this, callback](int code, const std::string& message) {
                if (callback)
                    callback(code, message);
            });
        } else {
            m_pRoomContext->leaveRoom([this, callback](int code, const std::string& message) {
                if (callback)
                    callback(code, message);
            });
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
