// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "config_controller.h"
#include "modules/http/http_manager.h"
#include "modules/http/http_request.h"

NEConfigController::NEConfigController() {}

NEConfigController::~NEConfigController() {}

void NEConfigController::getMeetingConfig(const NEConfigCallback& callback) {
    ConfigRequest request;
    HttpManager::getInstance()->getRequest(request, [=](int code, const QJsonObject& response) {
        if (code == 200) {
            if (response.contains("appConfig")) {
                QJsonObject appConfig = response["appConfig"].toObject();
                if (appConfig.contains("APP_ROOM_RESOURCE")) {
                    QJsonObject roomResource = appConfig["APP_ROOM_RESOURCE"].toObject();
                    if (roomResource.contains("chatroom")) {
                        m_bSupportChatRoom = roomResource["chatroom"].toBool();
                    }
                    if (roomResource.contains("live")) {
                        m_bSupportLive = roomResource["live"].toBool();
                    }
                    if (roomResource.contains("record")) {
                        m_bSupportRecorder = roomResource["record"].toBool();
                    }
                    if (roomResource.contains("sip")) {
                        m_bSupportSip = roomResource["sip"].toBool();
                    }
                    if (roomResource.contains("whiteboard")) {
                        m_bSupportWhiteboard = roomResource["whiteboard"].toBool();
                    }
                }

                if (appConfig.contains("MEETING_BEAUTY")) {
                    QJsonObject beautyConfig = appConfig["MEETING_BEAUTY"].toObject();
                    if (beautyConfig.contains("enable")) {
                        m_bSupportBeauty = beautyConfig["enable"].toBool();
                    }
                }

                if (appConfig.contains("MEETING_VIRTUAL_BACKGROUND")) {
                    QJsonObject beautyConfig = appConfig["MEETING_VIRTUAL_BACKGROUND"].toObject();
                    if (beautyConfig.contains("enable")) {
                        m_bSupportVirtualBackground = beautyConfig["enable"].toBool();
                    }
                }

                if (appConfig.contains("ROOM_END_TIME_TIP")) {
                    QJsonObject endTimeTipConfig = appConfig["ROOM_END_TIME_TIP"].toObject();
                    if (endTimeTipConfig.contains("enable")) {
                        m_bSupportEndTimeTip = endTimeTipConfig["enable"].toBool();
                    }
                }

                if (appConfig.contains("MEETING_CHATROOM")) {
                    QJsonObject chatroomConfig = appConfig["MEETING_CHATROOM"].toObject();
                    if (chatroomConfig.contains("enableImageMessage")) {
                        m_bSupportImageMessage = chatroomConfig["enableImageMessage"].toBool();
                    }
                    if (chatroomConfig.contains("enableFileMessage")) {
                        m_bSupportFileMessage = chatroomConfig["m_bSupportFileMessage"].toBool();
                    }
                }

                if (appConfig.contains("UNPUB_AUDIO_ON_MUTE")) {
                    QJsonObject unpubAudioOnMuteConfig = appConfig["UNPUB_AUDIO_ON_MUTE"].toObject();
                    if (unpubAudioOnMuteConfig.contains("enable")) {
                        m_bUnpubAudioOnMute = unpubAudioOnMuteConfig["enable"].toBool();
                    }
                }
            }
            callback(0, "success");
        } else {
            callback(-1, QString("get meeting config failed: ") + QString::number(code));
        }
    });
}

bool NEConfigController::isBeautySupported() {
    return m_bSupportBeauty;
}

bool NEConfigController::isLiveStreamSupported() {
    return m_bSupportLive;
}

bool NEConfigController::isWhiteboardSupported() {
    return m_bSupportWhiteboard;
}

bool NEConfigController::isCloudRecordSupported() {
    return m_bSupportRecorder;
}

bool NEConfigController::isChatroomSupported() {
    return m_bSupportChatRoom;
}

bool NEConfigController::isSipSupported() {
    return m_bSupportSip;
}

uint32_t NEConfigController::getGalleryPageSize() {
    return m_galleryPageSize;
}

uint32_t NEConfigController::getFocusSwitchInterval() {
    return m_focusSwitchInterval;
}

RecordProxy NEConfigController::getRecordProxy() {
    return m_recordProxy;
}

QString NEConfigController::getlicUrl() {
    return m_beautyLicenseUrl;
}
