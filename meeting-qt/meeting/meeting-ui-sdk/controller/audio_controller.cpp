// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "audio_controller.h"
#include "controller/rtc_ctrl_interface.h"
#include "manager/global_manager.h"
#include "manager/meeting_manager.h"
#include "manager/settings_manager.h"

#define ROOMCONTEXT auto roomContext = MeetingManager::getInstance()->getRoomContext();

NEMeetingAudioController::NEMeetingAudioController() {}

NEMeetingAudioController::~NEMeetingAudioController() {}

bool NEMeetingAudioController::muteMyAudio(bool mute, neroom::NECallback<> callback) {
    ROOMCONTEXT
    if (roomContext) {
        auto rtcController = roomContext->getRtcController();
        if (rtcController) {
            mute ? rtcController->muteMyAudio(!SettingsManager::getInstance()->unpubAudioOnMute(), callback)
                 : rtcController->unmuteMyAudio(true, callback);
            return true;
        }
    }
    return false;
}

bool NEMeetingAudioController::muteAllParticipantsAudio(bool allowUnmuteSelf, neroom::NECallback<> callback) {
    ROOMCONTEXT
    if (roomContext) {
        QString strAllMuteType = allowUnmuteSelf ? "offAllowSelfOn" : "offNotAllowSelfOn";
        QString value = strAllMuteType.append("_").append(QString::number(QDateTime::currentMSecsSinceEpoch()));
        roomContext->updateRoomProperty("audioOff", value.toStdString(), "", callback);
        return true;
    }
    return false;
}

bool NEMeetingAudioController::unmuteAllParticipantsAudio(neroom::NECallback<> callback) {
    ROOMCONTEXT
    if (roomContext) {
        QString strAllMuteType = "disable";
        QString value = strAllMuteType.append("_").append(QString::number(QDateTime::currentMSecsSinceEpoch()));
        roomContext->updateRoomProperty("audioOff", value.toStdString(), "", callback);
        return true;
    }
    return false;
}

bool NEMeetingAudioController::muteParticipantAudio(const std::string& userId, bool mute, neroom::NECallback<> callback) {
    ROOMCONTEXT
    if (roomContext) {
        auto rtcController = roomContext->getRtcController();
        if (rtcController) {
            if (mute) {
                rtcController->muteMemberAudio(userId, callback);
                return true;
            } else {
                auto messageService = GlobalManager::getInstance()->getMessageService();
                if (messageService) {
                    QJsonObject dataObj;
                    dataObj["type"] = 1;
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

bool NEMeetingAudioController::subscribeRemoteAudioStream(const std::vector<std::string>& userIdList) {
    return true;
}

bool NEMeetingAudioController::unsubscribeRemoteAudioStream(const std::vector<std::string>& userIdList) {
    return true;
}

bool NEMeetingAudioController::subscribeAllRemoteAudioStream() {
    return true;
}

bool NEMeetingAudioController::unsubscribeAllRemoteAudioStream() {
    return true;
}

bool NEMeetingAudioController::enableAudioVolumeIndication(bool enable, int interval) {
    ROOMCONTEXT
    if (roomContext) {
        auto rtcController = roomContext->getRtcController();
        if (rtcController) {
            return 0 == rtcController->enableAudioVolumeIndication(enable, interval);
        }
    }
    return false;
}

bool NEMeetingAudioController::enumPlayoutDevices(std::vector<NEDeviceBaseInfo>& deviceList) {
    deviceList.clear();
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->enumPlayoutDevices(deviceList);
        }
    }
    return false;
}

bool NEMeetingAudioController::enumRecordDevices(std::vector<NEDeviceBaseInfo>& deviceList) {
    deviceList.clear();
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->enumRecordDevices(deviceList);
        }
    }
    return false;
}

bool NEMeetingAudioController::getSelectedPlayoutDevice(std::string& deviceId) {
    deviceId.clear();
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->getSelectedPlayoutDevice(deviceId);
        }
    }
    return false;
}

bool NEMeetingAudioController::getSelectedRecordDevice(std::string& deviceId) {
    deviceId.clear();
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->getSelectedRecordDevice(deviceId);
        }
    }
    return false;
}

bool NEMeetingAudioController::selectPlayoutDevice(const std::string& deviceId) {
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->selectPlayoutDevice(deviceId);
        }
    }
    return false;
}

bool NEMeetingAudioController::selectRecordDevice(const std::string& deviceId) {
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->selectRecordDevice(deviceId);
        }
    }
    return false;
}

uint32_t NEMeetingAudioController::getRecordDeviceVolume() {
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return rtcController->getRecordDeviceVolume();
        }
    }
    return 0;
}

bool NEMeetingAudioController::setRecordDeviceVolume(uint32_t volume) {
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->setRecordDeviceVolume(volume);
        }
    }
    return false;
}

uint32_t NEMeetingAudioController::getPlayoutDeviceVolume() {
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return rtcController->getPlayoutDeviceVolume();
        }
    }
    return 0;
}

bool NEMeetingAudioController::setPlayoutDeviceVolume(uint32_t volume) {
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->setPlayoutDeviceVolume(volume);
        }
    }
    return false;
}

bool NEMeetingAudioController::startRecordDeviceTest() {
    auto roomStatus = MeetingManager::getInstance()->roomStatus();
    if (NEMeeting::MEETING_CONNECTED == roomStatus || NEMeeting::MEETING_RECONNECTED == roomStatus) {
        return false;
    }
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->startRecordDeviceTest();
        }
    }
    return false;
}

bool NEMeetingAudioController::stopRecordDeviceTest() {
    auto roomStatus = MeetingManager::getInstance()->roomStatus();
    if (NEMeeting::MEETING_CONNECTED == roomStatus || NEMeeting::MEETING_RECONNECTED == roomStatus) {
        return false;
    }
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->stopRecordDeviceTest();
        }
    }
    return false;
}

bool NEMeetingAudioController::startPlayoutDeviceTest(const std::string& mediaFile) {
    auto roomStatus = MeetingManager::getInstance()->roomStatus();
    if (NEMeeting::MEETING_CONNECTED == roomStatus || NEMeeting::MEETING_RECONNECTED == roomStatus) {
        return false;
    }
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->startPlayoutDeviceTest(mediaFile);
        }
    }
    return false;
}

bool NEMeetingAudioController::stopPlayoutDeviceTest() {
    auto roomStatus = MeetingManager::getInstance()->roomStatus();
    if (NEMeeting::MEETING_CONNECTED == roomStatus || NEMeeting::MEETING_RECONNECTED == roomStatus) {
        return false;
    }
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->stopPlayoutDeviceTest();
        }
    }
    return false;
}

bool NEMeetingAudioController::adjustRecordingSignalVolume(uint32_t volume) {
    return true;
}

bool NEMeetingAudioController::adjustPlaybackSignalVolume(uint32_t volume) {
    return true;
}

bool NEMeetingAudioController::setPlayoutDeviceMute(bool mute) {
    return true;
}

bool NEMeetingAudioController::getPlayoutDeviceMute() {
    return true;
}

bool NEMeetingAudioController::setRecordDeviceMute(bool mute) {
    return true;
}

bool NEMeetingAudioController::getRecordDeviceMute() {
    return true;
}

int NEMeetingAudioController::enumPlayoutDevices() {
    return true;
}

int NEMeetingAudioController::enumRecordDevices() {
    return true;
}

bool NEMeetingAudioController::getDefaultPlayoutDevice(NEDeviceBaseInfo& deviceInfo) {
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->getDefaultPlayoutDevice(deviceInfo);
        }
    }
    return false;
}

bool NEMeetingAudioController::getDefaultRecordDevice(NEDeviceBaseInfo& deviceInfo) {
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->getDefaultRecordDevice(deviceInfo);
        }
    }
    return false;
}

bool NEMeetingAudioController::startAudioDump() {
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->startAudioDump(neroom::kNEAudioDumpTypePCM);
        }
    }
    return false;
}

bool NEMeetingAudioController::stopAudioDump() {
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->stopAudioDump();
        }
    }
    return false;
}

bool NEMeetingAudioController::enableAudioAI(bool enable) {
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->enableAudioAI(enable);
        }
    }
    return false;
}

bool NEMeetingAudioController::enableAudioEchoCancellation(bool enable) {
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->enableAudioEchoCancellation(enable);
        }
    }
    return false;
}
