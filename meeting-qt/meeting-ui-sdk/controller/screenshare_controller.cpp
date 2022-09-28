// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "screenshare_controller.h"
#include "manager/auth_manager.h"
#include "manager/meeting/video_manager.h"
#include "manager/meeting_manager.h"

NEMeetingScreenShareController::NEMeetingScreenShareController() {}

NEMeetingScreenShareController::~NEMeetingScreenShareController() {}

bool NEMeetingScreenShareController::startAppShare(void* hwnd, bool preferMotion, const NEMeetingScreenShareController::NEShareCallback& callback) {
    auto rtcControl = MeetingManager::getInstance()->getInRoomRtcController();
    if (rtcControl) {
        auto videoControl = VideoManager::getInstance()->getVideoController();
        if (videoControl) {
            videoControl->setupSubVideoCanvas(AuthManager::getInstance()->authAccountId().toStdString(), this, nullptr);
        }
        rtcControl->startAppShare(hwnd, preferMotion, callback);
        return true;
    }
    return false;
}

bool NEMeetingScreenShareController::startScreenShare(const uint32_t& monitor_id,
                                                      const std::list<void*>& excludedWindowList,
                                                      bool preferMotion,
                                                      const NEMeetingScreenShareController::NEShareCallback& callback) {
    auto rtcControl = MeetingManager::getInstance()->getInRoomRtcController();
    if (rtcControl) {
        auto videoControl = VideoManager::getInstance()->getVideoController();
        if (videoControl) {
            videoControl->setupSubVideoCanvas(AuthManager::getInstance()->authAccountId().toStdString(), this, nullptr);
        }
        rtcControl->startScreenShare(monitor_id, excludedWindowList, preferMotion, callback);
        return true;
    }
    return false;
}

bool NEMeetingScreenShareController::startRectShare(const NERectangle& sourceRectangle,
                                                    const NERectangle& regionRectangle,
                                                    const std::list<void*>& excludedWindowList,
                                                    bool preferMotion,
                                                    const NEMeetingScreenShareController::NEShareCallback& callback) {
    auto rtcControl = MeetingManager::getInstance()->getInRoomRtcController();
    if (rtcControl) {
        auto videoControl = VideoManager::getInstance()->getVideoController();
        if (videoControl) {
            videoControl->setupSubVideoCanvas(AuthManager::getInstance()->authAccountId().toStdString(), this, nullptr);
        }
        rtcControl->startRectShare(sourceRectangle, regionRectangle, excludedWindowList, preferMotion, callback);
        return true;
    }
    return false;
}

bool NEMeetingScreenShareController::stopScreenShare(const NEMeetingScreenShareController::NEShareCallback& callback) {
    auto rtcControl = MeetingManager::getInstance()->getInRoomRtcController();
    if (rtcControl) {
        rtcControl->stopShare(callback);
        return true;
    }
    return false;
}

bool NEMeetingScreenShareController::stopParticipantScreenShare(const std::string& accountId,
                                                                const NEMeetingScreenShareController::NEShareCallback& callback) {
    auto rtcControl = MeetingManager::getInstance()->getInRoomRtcController();
    if (rtcControl) {
        rtcControl->stopMemberShare(accountId, callback);
        return true;
    }
    return false;
}

bool NEMeetingScreenShareController::pauseShare() {
    auto rtcControl = MeetingManager::getInstance()->getInRoomRtcController();
    if (rtcControl) {
        rtcControl->pauseShare();
        return true;
    }
    return false;
}

bool NEMeetingScreenShareController::resumeShare() {
    auto rtcControl = MeetingManager::getInstance()->getInRoomRtcController();
    if (rtcControl) {
        rtcControl->resumeShare();
        return true;
    }
    return false;
}

bool NEMeetingScreenShareController::switchAppShare(void* hwnd, bool preferMotion) {
    auto rtcControl = MeetingManager::getInstance()->getInRoomRtcController();
    if (rtcControl) {
        return 0 == rtcControl->switchAppShare(hwnd, preferMotion);
    }
    return false;
}

bool NEMeetingScreenShareController::switchMonitorShare(const uint32_t& monitor_id, const std::list<void*>& excludedWindowList, bool preferMotion) {
    auto rtcControl = MeetingManager::getInstance()->getInRoomRtcController();
    if (rtcControl) {
        return 0 == rtcControl->switchScreenShare(monitor_id, excludedWindowList, preferMotion);
    }
    return false;
}

bool NEMeetingScreenShareController::startSystemAudioLoopbackCapture() {
    auto rtcControl = MeetingManager::getInstance()->getInRoomRtcController();
    if (rtcControl) {
        return 0 == rtcControl->startSystemAudioLoopbackCapture();
    }
    return false;
}

bool NEMeetingScreenShareController::stopSystemAudioLoopbackCapture() {
    auto rtcControl = MeetingManager::getInstance()->getInRoomRtcController();
    if (rtcControl) {
        return 0 == rtcControl->stopSystemAudioLoopbackCapture();
    }
    return false;
}

bool NEMeetingScreenShareController::systemAudioLoopbackCapture(bool& enable) const {
    auto rtcControl = MeetingManager::getInstance()->getInRoomRtcController();
    if (rtcControl) {
        enable = m_systemAudioLoopbackCapture;
    }
    return false;
}

std::string NEMeetingScreenShareController::getScreenSharingUserId() {
    return MeetingManager::getInstance()->getMeetingInfo().screenSharingUserId;
}
