/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "settings_manager.h"
#include "auth_manager.h"
#include "client_meeting_sdk.h"
#include "controller/beauty_ctrl_interface.h"
#include "controller/video_ctrl_interface.h"
#include "global_manager.h"
#include "meeting_manager.h"
#include "pre_room_service_interface.h"
#include "room_service_interface.h"

SettingsManager::SettingsManager(QObject* parent)
    : QObject(parent) {
    if (ConfigManager::getInstance()->contains("enableInternalRender")) {
        m_enableInternalRender = ConfigManager::getInstance()->getValue("enableInternalRender", false).toBool();
        emit enableInternalRenderChanged();
    }

    connect(AuthManager::getInstance(), &AuthManager::authStatusChanged, [](NEAuthStatus authStatus, const NEAuthStatusExCode& error) {
        if (kAuthLoginSuccessed == authStatus) {
            auto videoController = GlobalManager::getInstance()->getPreRoomService()->getPreRoomVideoController();
            auto accountInfoPtr = AuthManager::getInstance()->getAuthInfo();
            if (videoController && accountInfoPtr && !accountInfoPtr->getPersonalRoomId().empty()) {
                videoController->setInternalRender(SettingsManager::getInstance()->enableInternalRender());
            }
        }
    });
}

bool SettingsManager::enableAudioAfterJoin() const {
    return m_enableAudioAfterJoin;
}

void SettingsManager::setEnableAudioAfterJoin(bool enableAudioAfterJoin) {
    if (enableAudioAfterJoin == m_enableAudioAfterJoin) {
        return;
    }

    m_enableAudioAfterJoin = enableAudioAfterJoin;
    emit enableAudioAfterJoinChanged();

    auto* client = dynamic_cast<NS_I_NEM_SDK::NEMeetingSDKIPCClient*>(NS_I_NEM_SDK::NEMeetingSDKIPCClient::getInstance());
    if (client == nullptr)
        return;
    auto* settingsService = dynamic_cast<NS_I_NEM_SDK::NESettingsServiceIPCClient*>(client->getSettingsService());
    if (settingsService == nullptr)
        return;
    settingsService->notifySettingsChange(NS_I_NEM_SDK::SettingChangType::SettingChangType_Audio, enableAudioAfterJoin);
}

bool SettingsManager::enableVideoAfterJoin() const {
    return m_enableVideoAfterJoin;
}

void SettingsManager::setEnableVideoAfterJoin(bool enableVideoAfterJoin) {
    if (enableVideoAfterJoin == m_enableVideoAfterJoin) {
        return;
    }
    m_enableVideoAfterJoin = enableVideoAfterJoin;
    emit enableVideoAfterJoinChanged();

    auto* client = dynamic_cast<NS_I_NEM_SDK::NEMeetingSDKIPCClient*>(NS_I_NEM_SDK::NEMeetingSDKIPCClient::getInstance());
    if (client == nullptr)
        return;
    auto* settingsService = dynamic_cast<NS_I_NEM_SDK::NESettingsServiceIPCClient*>(client->getSettingsService());
    if (settingsService == nullptr)
        return;
    settingsService->notifySettingsChange(NS_I_NEM_SDK::SettingChangType::SettingChangType_Video, enableVideoAfterJoin);
}

bool SettingsManager::enableFaceBeautyPreview(bool enable) {
    m_enableFaceBeautyAfterJoin = enable;
    if (NEMeeting::MEETING_CONNECTED == MeetingManager::getInstance()->getRoomStatus() && enable == false) {
        return true;
    }

    auto beautyController = MeetingManager::getInstance()->getInRoomBeautyController();
    if (nullptr != beautyController) {
        beautyController->enableBeauty(enable);
    }

    return true;
}

void SettingsManager::initFaceBeautyLevel() {
    if (-1 == m_FaceBeautyLevel) {
        auto beautyController = MeetingManager::getInstance()->getInRoomBeautyController();
        if (nullptr != beautyController) {
            m_FaceBeautyLevel = beautyController->getBeautyFaceValue();
        }
    }
}

int SettingsManager::faceBeautyLevel() const {
    return m_FaceBeautyLevel;
}

void SettingsManager::setFaceBeautyLevel(int level) {
    if (m_FaceBeautyLevel == level) {
        return;
    }
    m_FaceBeautyLevel = level;
    emit faceBeautyLevelChanged();

    auto beautyController = MeetingManager::getInstance()->getInRoomBeautyController();
    if (nullptr != beautyController) {
        beautyController->setBeautyFaceValue(level, false);
    }
}

void SettingsManager::saveFaceBeautyLevel() const {
    auto beautyController = MeetingManager::getInstance()->getInRoomBeautyController();
    if (nullptr != beautyController) {
        beautyController->setBeautyFaceValue(m_FaceBeautyLevel, true);
    }
}

bool SettingsManager::setEnableFaceBeauty(bool enable) {
    if (enable == m_enableFaceBeautyAfterJoin) {
        return true;
    }

    YXLOG(Info) << "setEnableFaceBeauty enable " << enable << YXLOGEnd;
    if (NEMeeting::MEETING_CONNECTED == MeetingManager::getInstance()->getRoomStatus() && enable == false) {
        return true;
    }

    m_enableFaceBeautyAfterJoin = enable;
    emit enableFaceBeautyChanged();

    auto beautyController = MeetingManager::getInstance()->getInRoomBeautyController();
    if (nullptr != beautyController) {
        beautyController->enableBeauty(enable);
    }

    return true;
}

bool SettingsManager::enableFaceBeauty() const {
    return m_enableFaceBeautyAfterJoin;
}

bool SettingsManager::enableInternalRender() const {
    return m_enableInternalRender;
}

void SettingsManager::setEnableInternalRender(bool enableInternalRender) {
    if (enableInternalRender != m_enableInternalRender) {
        m_enableInternalRender = enableInternalRender;
        ConfigManager::getInstance()->setValue("enableInternalRender", enableInternalRender);
        emit enableInternalRenderChanged();
    }

    auto videoController = GlobalManager::getInstance()->getPreRoomService()->getPreRoomVideoController();
    if (videoController) {
        videoController->setInternalRender(enableInternalRender);
    }
}

bool SettingsManager::mainWindowVisible() const {
    return m_mainWindowVisible;
}

void SettingsManager::setMainWindowVisible(bool mainWindowVisible) {
    if (mainWindowVisible == m_mainWindowVisible) {
        return;
    }

    m_mainWindowVisible = mainWindowVisible;
    emit mainWindowVisibleChanged();
}

bool SettingsManager::useInternalRender() const {
    auto meetingStatus = MeetingManager::getInstance()->getRoomStatus();
    return enableInternalRender() && !(NEMeeting::MEETING_CONNECTED == meetingStatus || NEMeeting::MEETING_RECONNECTED == meetingStatus);
}
