// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "video_controller.h"
#include "manager/global_manager.h"
#include "manager/meeting_manager.h"

#define ROOMCONTEXT auto roomContext = MeetingManager::getInstance()->getRoomContext();

NEMeetingVideoController::NEMeetingVideoController() {}

NEMeetingVideoController::~NEMeetingVideoController() {}

std::string NEMeetingVideoController::getPinnedUserId() {
    return "";
}

bool NEMeetingVideoController::pinVideo(const std::string& userId, bool on, const neroom::NECallback<>& callback) {
    return true;
}

bool NEMeetingVideoController::askParticipantStartVideo(const std::string& userId, const neroom::NECallback<>& callback) {
    auto messageService = GlobalManager::getInstance()->getMessageService();
    if (messageService) {
        QJsonObject dataObj;
        dataObj["type"] = 2;
        dataObj["category"] = "meeting_control";
        QByteArray byteArray = QJsonDocument(dataObj).toJson(QJsonDocument::Compact);
        messageService->sendCustomMessage(MeetingManager::getInstance()->meetingId().toStdString(), userId, 99, byteArray.data(), callback);
    }
    return false;
}

bool NEMeetingVideoController::stopParticipantVideo(const std::string& userId, const neroom::NECallback<>& callback) {
    ROOMCONTEXT
    if (roomContext) {
        auto rtcController = roomContext->getRtcController();
        if (rtcController) {
            rtcController->muteMemberVideo(userId, callback);
            return true;
        }
    }
    return false;
}

bool NEMeetingVideoController::subscribeRemoteVideoStream(const std::string& userId, bool bHighStream) {
    ROOMCONTEXT
    if (roomContext) {
        auto rtcController = roomContext->getRtcController();
        if (rtcController) {
            return 0 == rtcController->subscribeRemoteVideoStream(userId, bHighStream ? kStreamTypeHigh : kStreamLow);
        }
    }
    return false;
}

bool NEMeetingVideoController::unsubscribeRemoteVideoStream(const std::string& userId) {
    ROOMCONTEXT
    if (roomContext) {
        auto rtcController = roomContext->getRtcController();
        if (rtcController) {
            return 0 == rtcController->unsubscribeRemoteVideoStream(userId);
        }
    }
    return false;
}

bool NEMeetingVideoController::subscribeRemoteVideoSubStream(const std::string& userId) {
    ROOMCONTEXT
    if (roomContext) {
        auto rtcController = roomContext->getRtcController();
        if (rtcController) {
            return 0 == rtcController->subscribeRemoteVideoSubStream(userId);
        }
    }
    return false;
}

bool NEMeetingVideoController::unsubscribeRemoteVideoSubStream(const std::string& userId) {
    ROOMCONTEXT
    if (roomContext) {
        auto rtcController = roomContext->getRtcController();
        if (rtcController) {
            return 0 == rtcController->unsubscribeRemoteVideoSubStream(userId);
        }
    }
    return false;
}

bool NEMeetingVideoController::setupVideoCanvas(const std::string& userId, void* userData, void* window) {
    ROOMCONTEXT
    NERoomVideoView videoView;
    videoView.setup = nullptr != userData;
    if (roomContext) {
        auto rtcController = roomContext->getRtcController();
        if (rtcController) {
            return userId == AuthManager::getInstance()->authAccountId().toStdString()
                       ? 0 == rtcController->setupLocalVideoCanvas(videoView)
                       : 0 == rtcController->setupRemoteVideoCanvas(userId, videoView);
        }
    } else {
        auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
        if (previewRoomContext) {
            auto rtcController = previewRoomContext->getPreviewRoomRtcController();
            if (rtcController) {
                return 0 == rtcController->setupLocalVideoCanvas(videoView);
            }
        }
    }
    return false;
}

bool NEMeetingVideoController::setupSubVideoCanvas(const std::string& userId, void* userData, void* window) {
    ROOMCONTEXT
    NERoomVideoView videoView;
    videoView.setup = nullptr != userData;
    if (roomContext) {
        auto rtcController = roomContext->getRtcController();
        if (rtcController) {
            return userId == AuthManager::getInstance()->authAccountId().toStdString()
                       ? rtcController->setupLocalVideoSubStreamCanvas(videoView)
                       : rtcController->setupRemoteVideoSubStreamCanvas(userId, videoView);
        }
    }
    return false;
}

bool NEMeetingVideoController::enumCameraDevices(std::vector<NEDeviceBaseInfo>& deviceList) {
    deviceList.clear();
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->enumCameraDevices(deviceList);
        }
    }
    return false;
}

bool NEMeetingVideoController::muteMyVideo(bool disable, const neroom::NECallback<>& callback) {
    ROOMCONTEXT
    if (roomContext) {
        auto rtcController = roomContext->getRtcController();
        if (rtcController) {
            disable ? rtcController->muteMyVideo(callback) : rtcController->unmuteMyVideo(callback);
            return true;
        }
    }
    return false;
}

bool NEMeetingVideoController::setupPreviewCanvas(void* userData, void* window, bool highVideoQuality) {
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        NERoomVideoView videoView;
        videoView.setup = nullptr != userData;
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->setupLocalVideoCanvas(videoView);
        }
    }
    return false;
}

bool NEMeetingVideoController::startVideoPreview() {
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->startVideoPreview();
        }
    }
    return false;
}

bool NEMeetingVideoController::stopVideoPreview() {
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->stopVideoPreview();
        }
    }
    return false;
}

bool NEMeetingVideoController::setInternalRender(bool internalRender) {
    return true;
}

// bool NEMeetingVideoController::updateVideoState(nertc::uid_t uid, bool start) {
//    CHECK_ROOMSERVICE
//    auto subscribeHelper = roomServiceEx->getSubscribeHelper();
//    if (!subscribeHelper)
//        return kNEFailed;

//    subscribeHelper->updateVideoState(uid, start);
//    return (bool)kNENoError;
//}

// bool NEMeetingVideoController::updateSubVideoState(nertc::uid_t uid, bool start) {
//    int ret = RtcManager::getInstance()->subscribeSubVideoStream(uid, start);
//    return (bool)ret;
//}

// bool NEMeetingVideoController::enumCameraDevices(std::vector<NEVideoDeviceInfo>& deviceList) {
//    std::lock_guard<std::recursive_mutex> locker(m_devicesLock);
//    YXLOG(Info) << "enumVideoDevices, Capture." << YXLOGEnd;
//    CHECK_INIT
//    if (m_captureDevices.size() == 0)
//        ret = enumCaptureDevices();

//    if (0 == ret) {
//        for (auto& device : m_captureDevices) {
//            deviceList.push_back(device);
//        }
//    }

//    return (bool)ret;
//}

bool NEMeetingVideoController::getSelectedCameraDevice(std::string& deviceId) {
    deviceId.clear();
    auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
    if (previewRoomContext) {
        auto rtcController = previewRoomContext->getPreviewRoomRtcController();
        if (rtcController) {
            return 0 == rtcController->getSelectedCameraDevice(deviceId);
        }
    }
    return false;
}

bool NEMeetingVideoController::selectCameraDevice(const std::string& deviceId) {
    // YXLOG(Info) << "selectCameraDevice, m_deviceId: " << m_deviceId << ", deviceId: " << deviceId << YXLOGEnd;
    if (m_deviceId == deviceId) {
        return true;
    }

    ROOMCONTEXT
    bool bRet = false;
    if (roomContext) {
        auto rtcController = roomContext->getRtcController();
        if (rtcController) {
            bRet = 0 == rtcController->selectCameraDevice(deviceId);
        }
    } else {
        auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
        if (previewRoomContext) {
            auto rtcController = previewRoomContext->getPreviewRoomRtcController();
            if (rtcController) {
                bRet = 0 == rtcController->selectCameraDevice(deviceId);
            }
        }
    }
    if (bRet) {
        m_deviceId = deviceId;
    }
    return bRet;
}

// bool NEMeetingVideoController::setExternalVideoSource(bool enabled) {
//    CHECK_INIT
//    ret = RtcManager::getInstance()->setExternalVideoSource(enabled);
//    if (0 == ret && enabled) {
//        ret = m_videoDeviceManager->setDevice(kNERtcExternalVideoDeviceID);
//        if (0 != ret) {
//            YXLOG(Info) << "Select video capture device: " << kNERtcExternalVideoDeviceID << ", ret: " << ret << YXLOGEnd;
//        }
//    }
//
//    return (bool)ret;
//}

// bool NEMeetingVideoController::pushExternalVideoFrame(const NEVideoFrame& frame) {
//    CHECK_INIT
//    nertc::NERtcVideoFrame rtcFrame;
//    rtcFrame.buffer = frame.buffer;
//    rtcFrame.format = static_cast<nertc::NERtcVideoType>(frame.format);
//    rtcFrame.height = frame.height;
//    rtcFrame.rotation = static_cast<nertc::NERtcVideoRotation>(frame.rotation);
//    rtcFrame.timestamp = frame.timestamp;
//    rtcFrame.width = frame.width;
//    ret = RtcManager::getInstance()->pushExternalVideoFrame(&rtcFrame);
//    return (bool)ret;
//}

bool NEMeetingVideoController::muteAllParticipantsVideo(bool allowUnmuteSelf, const neroom::NECallback<>& callback) {
    ROOMCONTEXT
    if (roomContext) {
        QString strAllMuteType = allowUnmuteSelf ? "offAllowSelfOn" : "offNotAllowSelfOn";
        QString value = strAllMuteType.append("_").append(QString::number(QDateTime::currentMSecsSinceEpoch()));
        roomContext->updateRoomProperty("videoOff", value.toStdString(), "", callback);
        return true;
    }
    return false;
}

bool NEMeetingVideoController::unmuteAllParticipantsVideo(const neroom::NECallback<>& callback) {
    ROOMCONTEXT
    if (roomContext) {
        QString strAllMuteType = "disable";
        QString value = strAllMuteType.append("_").append(QString::number(QDateTime::currentMSecsSinceEpoch()));
        roomContext->updateRoomProperty("videoOff", value.toStdString(), "", callback);
        return true;
    }
    return false;
}

// bool NEMeetingVideoController::setVideoProfileType(NEVideoProfileType videoProfileType) {
//    int ret = RtcManager::getInstance()->setVideoProfileType((nertc::NERtcVideoProfileType)videoProfileType);
//    return (bool)ret;
//}
