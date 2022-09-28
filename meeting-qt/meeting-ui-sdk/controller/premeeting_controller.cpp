// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "premeeting_controller.h"
#include <QJsonParseError>
#include "manager/global_manager.h"
#include "modules/http/http_manager.h"
#include "modules/http/http_request.h"

NEPreMeetingController::NEPreMeetingController() {}

NEPreMeetingController::~NEPreMeetingController() {}

bool NEPreMeetingController::scheduleRoom(const nem_sdk_interface::NEMeetingItem& item,
                                          const NEPreMeetingController::NEScheduleRoomItemCallback& callback) {
    NEMeetingType meetingType = schduleType;
    QString subject = QString::fromStdString(item.subject);
    NEMeetingResources resources;
    resources.live = item.enableLive && GlobalManager::getInstance()->getGlobalConfig()->isLiveStreamSupported();
    resources.record = item.setting.cloudRecordOn && GlobalManager::getInstance()->getGlobalConfig()->isCloudRecordSupported();
    resources.sip = !item.noSip && GlobalManager::getInstance()->getGlobalConfig()->isSipSupported();
    resources.chatroom = GlobalManager::getInstance()->getGlobalConfig()->isChatroomSupported();
    resources.whiteboard = GlobalManager::getInstance()->getGlobalConfig()->isWhiteboardSupported();
    QJsonObject roomProperties;
    initRoomProProperties(roomProperties);
    QJsonObject extraDataObj;
    extraDataObj["value"] = QString::fromStdString(item.extraData);
    roomProperties["extraData"] = extraDataObj;

    for (auto control : item.setting.controls) {
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

    if (item.enableLive) {
        QJsonObject liveObj;
        QJsonObject extentionConfig;
        extentionConfig["onlyEmployeesAllow"] = item.liveWebAccessControlLevel == LIVE_ACCESS_APP_TOKEN;
        extentionConfig["liveChatRoomEnable"] = true;
        QByteArray byteArray = QJsonDocument(extentionConfig).toJson(QJsonDocument::Compact);
        liveObj["extensionConfig"] = QString::fromLocal8Bit(byteArray);
        roomProperties["live"] = liveObj;
    }

    QJsonObject roleBindsObj;
    for (auto iter = item.roleBinds.begin(); iter != item.roleBinds.end(); iter++) {
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

    std::string password = item.password;
    int roomConfigId = 40;
    int64_t startTime = item.startTime;
    int64_t endTime = item.endTime;
    CreateMeetingRequest createMeetingRequest(meetingType, subject, resources, roomProperties, QString::fromStdString(password), roleBindsObj,
                                              roomConfigId, startTime, endTime);
    HttpManager::getInstance()->putRequest(createMeetingRequest, [=](int code, const QJsonObject& response) {
        nem_sdk_interface::NEMeetingItem item;
        if (code == 200) {
            if (response.contains("meetingId")) {
                item.meetingUniqueId = response["meetingId"].toVariant().toLongLong();
            }
            if (response.contains("meetingNum")) {
                item.meetingId = response["meetingNum"].toString().toStdString();
            }
            if (response.contains("subject")) {
                item.subject = response["subject"].toString().toStdString();
            }
            if (response.contains("meetingId")) {
                item.meetingUniqueId = response["meetingId"].toVariant().toLongLong();
            }
            if (response.contains("startTime")) {
                item.startTime = response["startTime"].toVariant().toLongLong();
            }
            if (response.contains("endTime")) {
                item.endTime = response["endTime"].toVariant().toLongLong();
            }
            if (response.contains("password")) {
                item.password = response["password"].toVariant().toLongLong();
            }
        }

        if (callback) {
            callback(code, response["msg"].toString().toStdString(), item);
        }
    });
    return true;
}

bool NEPreMeetingController::editRoom(const nem_sdk_interface::NEMeetingItem& item, const NEPreMeetingController::NEEditRoomCallback& callback) {
    QString subject = QString::fromStdString(item.subject);
    NEMeetingResources resources;
    resources.live = item.enableLive;
    resources.record = item.setting.cloudRecordOn;
    resources.sip = !item.noSip;
    QJsonObject roomProperties;
    std::string password = item.password;
    int64_t startTime = item.startTime;
    int64_t endTime = item.endTime;

    QJsonObject extraDataObj;
    extraDataObj["value"] = QString::fromStdString(item.extraData);
    roomProperties["extraData"] = extraDataObj;

    for (auto control : item.setting.controls) {
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

    QJsonObject liveObj;
    QJsonObject extentionConfig;
    extentionConfig["onlyEmployeesAllow"] = item.liveWebAccessControlLevel == LIVE_ACCESS_APP_TOKEN;
    extentionConfig["liveChatRoomEnable"] = true;
    QByteArray byteArray = QJsonDocument(extentionConfig).toJson(QJsonDocument::Compact);
    liveObj["extensionConfig"] = QString::fromLocal8Bit(byteArray);
    roomProperties["live"] = liveObj;

    QJsonObject roleBindsObj;
    for (auto iter = item.roleBinds.begin(); iter != item.roleBinds.end(); iter++) {
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

    qInfo() << "roleBindsObj:" << roleBindsObj;

    EditMeetingRequest editMeetingRequest(item.meetingUniqueId, subject, resources, roomProperties, QString::fromStdString(password), roleBindsObj,
                                          startTime, endTime);
    HttpManager::getInstance()->postRequest(editMeetingRequest, [=](int code, const QJsonObject& response) {
        if (callback) {
            callback(code, response["msg"].toString().toStdString());
        }
    });
    return true;
}

bool NEPreMeetingController::cancelRoom(const int64_t& roomUniqueId, const NEPreMeetingController::NECancelRoomCallback& callback) {
    CancelMeetingRequest cancelMeetingRequest(roomUniqueId);
    HttpManager::getInstance()->deleteRequest(cancelMeetingRequest, [=](int code, const QJsonObject& response) {
        if (code == 200) {
            auto iter = m_meetingList.begin();
            for (iter; iter != m_meetingList.end(); iter++) {
                if (iter->meetingUniqueId == roomUniqueId) {
                    m_meetingList.erase(iter);
                    break;
                }
            }
        }

        if (callback) {
            callback(code, response["msg"].toString().toStdString());
        }
    });
    return true;
}

bool NEPreMeetingController::getRoomItemByUniqueId(const int64_t& roomUniqueId, nem_sdk_interface::NEMeetingItem& item) {
    for (auto it : m_meetingList) {
        if (it.meetingUniqueId == roomUniqueId) {
            item = it;
            return true;
        }
    }
    return false;
}

bool NEPreMeetingController::getRoomList(std::list<nem_sdk_interface::NEMeetingItemStatus> status,
                                         const NEPreMeetingController::NEGetRoomListCallback& callback) {
    QString strStatus;
    int index = 0;
    for (auto it : status) {
        if (index == 0) {
            strStatus.append("?");
        } else {
            strStatus.append("&");
        }
        strStatus.append("states=").append(QString::number(static_cast<int>(it)));
        index++;
    }
    qInfo() << "GetMeetingListRequest strStatus:" << strStatus;

    GetMeetingListRequest getMeetingListRequest(strStatus);
    HttpManager::getInstance()->getRequest(getMeetingListRequest, [=](int code, const QJsonObject& response) {
        std::list<nem_sdk_interface::NEMeetingItem> items;
        if (code == 200) {
            if (response.contains("meetingList")) {
                m_meetingList.clear();
                auto meetingList = response["meetingList"].toArray();
                for (auto it : meetingList) {
                    nem_sdk_interface::NEMeetingItem item;
                    auto obj = it.toObject();
                    if (obj.contains("type")) {
                        NEMeetingType meetingType = static_cast<NEMeetingType>(obj["type"].toInt());
                        if (meetingType != schduleType) {
                            continue;
                        }
                    }
                    if (obj.contains("meetingId")) {
                        item.meetingUniqueId = obj["meetingId"].toVariant().toLongLong();
                    }
                    if (obj.contains("meetingNum")) {
                        item.meetingId = obj["meetingNum"].toString().toStdString();
                    }
                    if (obj.contains("subject")) {
                        item.subject = obj["subject"].toString().toStdString();
                    }
                    if (obj.contains("state")) {
                        item.status = static_cast<nem_sdk_interface::NEMeetingItemStatus>(obj["state"].toInt());
                    }
                    if (obj.contains("startTime")) {
                        item.startTime = obj["startTime"].toVariant().toLongLong();
                    }
                    if (obj.contains("endTime")) {
                        item.endTime = obj["endTime"].toVariant().toLongLong();
                    }
                    if (obj.contains("settings")) {
                        auto settings = obj["settings"].toObject();
                        if (settings.contains("roomInfo")) {
                            auto roomInfo = settings["roomInfo"].toObject();
                            if (roomInfo.contains("password")) {
                                item.password = roomInfo["password"].toString().toStdString();
                            }

                            if (roomInfo.contains("roomConfig")) {
                                auto roomConfig = roomInfo["roomConfig"].toObject();
                                if (roomConfig.contains("resource")) {
                                    auto resource = roomConfig["resource"].toObject();
                                    if (resource.contains("live")) {
                                        item.enableLive = resource["live"].toBool();
                                    }
                                    if (resource.contains("record")) {
                                        item.setting.cloudRecordOn = resource["record"].toBool();
                                    }
                                    if (resource.contains("sip")) {
                                        item.noSip = !resource["sip"].toBool();
                                    }
                                }
                            }

                            if (roomInfo.contains("roleBinds")) {
                                auto roleBindsObj = roomInfo["roleBinds"].toObject();
                                QJsonObject* pRoleBindsObj = reinterpret_cast<QJsonObject*>(&roleBindsObj);
                                QJsonObject::const_iterator it = pRoleBindsObj->constBegin();
                                QJsonObject::const_iterator end = pRoleBindsObj->constEnd();
                                while (it != end) {
                                    auto key = it.key().toStdString();
                                    auto value = it.value().toString();
                                    NEMeetingRoleType roleType = normal;
                                    if (value == "member") {
                                        roleType = normal;
                                    } else if (value == "host") {
                                        roleType = host;
                                    } else if (value == "cohost") {
                                        roleType = cohost;
                                    }
                                    item.roleBinds[key] = roleType;
                                    it++;
                                }
                            }

                            if (roomInfo.contains("roomProperties")) {
                                auto roomProperties = roomInfo["roomProperties"].toObject();
                                if (roomProperties.contains("extraData")) {
                                    auto extraDataObj = roomProperties["extraData"].toObject();
                                    if (extraDataObj.contains("value")) {
                                        item.extraData = extraDataObj["value"].toString().toStdString();
                                    }
                                }
                                if (roomProperties.contains("audioOff")) {
                                    NEMeetingControl control;
                                    control.type = kControlTypeAudio;
                                    auto audioOffObj = roomProperties["audioOff"].toObject();
                                    if (audioOffObj.contains("value")) {
                                        QString value = audioOffObj["value"].toString();
                                        QString type = value.left(value.indexOf("_"));
                                        if (type == "offAllowSelfOn") {
                                            control.attendeeOff = kAttendeeOffAllowSelfOn;
                                        } else if ("offNotAllowSelfOn") {
                                            control.attendeeOff = kAttendeeOffNotAllowSelfOn;
                                        } else {
                                            control.attendeeOff = kAttendeeOffNone;
                                        }
                                    }
                                    item.setting.controls.push_back(control);
                                }
                                if (roomProperties.contains("videoOff")) {
                                    NEMeetingControl control;
                                    control.type = kControlTypeVideo;
                                    auto videoOffObj = roomProperties["videoOff"].toObject();
                                    if (videoOffObj.contains("value")) {
                                        QString value = videoOffObj["value"].toString();
                                        QString type = value.left(value.indexOf("_"));
                                        if (type == "offAllowSelfOn") {
                                            control.attendeeOff = kAttendeeOffAllowSelfOn;
                                        } else if ("offNotAllowSelfOn") {
                                            control.attendeeOff = kAttendeeOffNotAllowSelfOn;
                                        } else {
                                            control.attendeeOff = kAttendeeOffNone;
                                        }
                                    }
                                    item.setting.controls.push_back(control);
                                }
                                if (roomProperties.contains("live")) {
                                    auto liveObj = roomProperties["live"].toObject();
                                    if (liveObj.contains("extensionConfig")) {
                                        auto strExtentionConfig = liveObj["extensionConfig"].toString();
                                        QJsonDocument doc = QJsonDocument::fromJson(strExtentionConfig.toLocal8Bit());
                                        auto extentionConfig = doc.object();
                                        if (extentionConfig.contains("onlyEmployeesAllow") && item.enableLive) {
                                            item.liveWebAccessControlLevel =
                                                extentionConfig["onlyEmployeesAllow"].toBool() ? LIVE_ACCESS_APP_TOKEN : LIVE_ACCESS_NORMAL;
                                        }
                                    }
                                }
                            }
                        }

                        if (settings.contains("liveConfig")) {
                            auto liveConfig = settings["liveConfig"].toObject();
                            if (liveConfig.contains("liveAddress")) {
                                item.liveUrl = liveConfig["liveAddress"].toString().toStdString();
                            }
                        }
                    }

                    m_meetingList.push_back(item);
                }
            }

            callback(code, response["msg"].toString().toStdString(), m_meetingList);
        } else {
            callback(code, response["msg"].toString().toStdString(), m_meetingList);
        }
    });
    return true;
}

void NEPreMeetingController::initRoomProProperties(QJsonObject& object) {
    QJsonObject focus;
    focus["value"] = "";
    object["focus"] = focus;
}
