// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "settings_manager.h"
#include "auth_manager.h"
#include "client_meeting_sdk.h"
#include "global_manager.h"
#include "meeting_manager.h"
#include "models/virtualbackground_model.h"
#include "nos_service_interface.h"

SettingsManager::SettingsManager(QObject* parent)
    : QObject(parent) {
    qmlRegisterUncreatableType<SettingsManager>("NetEase.Settings.SettingsStatus", 1, 0, "SettingsStatus", "");
    QString customFile = qApp->applicationDirPath() + "/config/custom.ini";
#ifdef Q_OS_MACX
    if (!QFile::exists(customFile)) {
        // YXLOG(Waring) << "customFile not exists: " << customFile.toStdString() << YXLOGEnd;
        customFile = qApp->applicationDirPath() + "/../Resources/config/custom.ini";
    }
#endif

    if (!QFile::exists(customFile)) {
        YXLOG(Error) << "customFile not exists: " << customFile.toStdString() << YXLOGEnd;
    } else {
        QSettings settings(customFile, QSettings::IniFormat);
        settings.sync();
        setCustomRender(0 != settings.value("Render/CustomRender", 0).toInt());
    }

    if (ConfigManager::getInstance()->contains("showVirtualBackground")) {
        m_showVirtualBackground = ConfigManager::getInstance()->getValue("showVirtualBackground", m_showVirtualBackground).toBool();
    }

    if (ConfigManager::getInstance()->contains("virtualBackground")) {
        m_virtualBackground = ConfigManager::getInstance()->getValue("virtualBackground", 0).toInt();
    }

    initVirtualBackground(std::vector<VirtualBackgroundModel::VBProperty>{});

    if (ConfigManager::getInstance()->contains("enableBeauty")) {
        setEnableFaceBeauty(ConfigManager::getInstance()->getValue("enableBeauty", m_enableBeauty).toBool());
    }

    if (ConfigManager::getInstance()->contains("enableInternalRender")) {
        m_enableInternalRender = ConfigManager::getInstance()->getValue("enableInternalRender", false).toBool();
        emit enableInternalRenderChanged();
    }

    if (ConfigManager::getInstance()->contains("localCameraStatusEx")) {
        m_enableVideoAfterJoin = ConfigManager::getInstance()->getValue("localCameraStatusEx", false).toBool();
        emit enableVideoAfterJoinChanged();
    }

    if (ConfigManager::getInstance()->contains("localMicStatusEx")) {
        m_enableAudioAfterJoin = ConfigManager::getInstance()->getValue("localMicStatusEx", false).toBool();
        emit enableAudioAfterJoinChanged();
    }

    if (ConfigManager::getInstance()->contains("localMicAINSStatusEx")) {
        m_enableAudioAINS = ConfigManager::getInstance()->getValue("localMicAINSStatusEx", m_enableAudioAINS).toBool();
        emit enableAudioAINSChanged();
    }

    if (ConfigManager::getInstance()->contains("localEnableAudioStereo")) {
        m_enableAudioStereo = ConfigManager::getInstance()->getValue("localEnableAudioStereo", m_enableAudioStereo).toBool();
        emit enableAudioStereoChanged(m_enableAudioStereo);
    }

    if (ConfigManager::getInstance()->contains("localMicVolumeAutoAdjustStatus")) {
        m_enableMicVolumeAutoAdjust = ConfigManager::getInstance()->getValue("localMicVolumeAutoAdjustStatus", m_enableMicVolumeAutoAdjust).toBool();
        emit enableMicVolumeAutoAdjustChanged(m_enableMicVolumeAutoAdjust);
    }

    if (ConfigManager::getInstance()->contains("localAudioProfileType") && ConfigManager::getInstance()->contains("localAudioScenarioType")) {
        m_audioProfileType =
            (neroom::NERoomRtcAudioProfileType)ConfigManager::getInstance()->getValue("localAudioProfileType", (int)m_audioProfileType).toInt();
        m_audioScenarioType =
            (neroom::NERoomRtcAudioScenarioType)ConfigManager::getInstance()->getValue("localAudioScenarioType", (int)m_audioScenarioType).toInt();
        emit audioProfileChanged(audioProfile());
        emit enableAudioStereoChanged(enableAudioStereo());
    }

    if (ConfigManager::getInstance()->contains("localAudioEchoCancellationStatus")) {
        m_enableAudioEchoCancellation =
            ConfigManager::getInstance()->getValue("localAudioEchoCancellationStatus", m_enableAudioEchoCancellation).toBool();
        emit enableAudioEchoCancellationChanged(m_enableAudioEchoCancellation);
    }

    if (ConfigManager::getInstance()->contains("localVideoResolution")) {
        m_localVideoResolution = (VideoResolution)ConfigManager::getInstance()->getValue("localVideoResolution", (int)m_localVideoResolution).toInt();
        emit localVideoResolutionChanged(m_localVideoResolution);
    }

    if (ConfigManager::getInstance()->contains("remoteVideoResolution")) {
        m_remoteVideoResolution = ConfigManager::getInstance()->getValue("remoteVideoResolution", m_remoteVideoResolution).toBool();
        emit remoteVideoResolutionChanged(m_remoteVideoResolution);
    }

    if (ConfigManager::getInstance()->contains("audioDeviceAutoSelectType")) {
        m_audioDeviceAutoSelectType = (neroom::NEAudioDeviceAutoSelectType)ConfigManager::getInstance()
                                          ->getValue("audioDeviceAutoSelectType", (int)m_audioDeviceAutoSelectType)
                                          .toInt();
    }

    if (ConfigManager::getInstance()->contains("showSpeaker")) {
        m_showSpeaker = ConfigManager::getInstance()->getValue("showSpeaker", m_showSpeaker).toBool();
    }

    if (ConfigManager::getInstance()->contains("localCacheDir")) {
        m_cacheDir = ConfigManager::getInstance()->getValue("localCacheDir", m_cacheDir).toString();
    } else {
        QString logPathEx = getLogPath();
        m_cacheDir = logPathEx.append("_Cache");
        QDir cacheDir;
        if (!cacheDir.exists(m_cacheDir))
            cacheDir.mkpath(m_cacheDir);
    }

    if (ConfigManager::getInstance()->contains("localEnableUnmuteBySpace")) {
        m_enableUnmuteBySpace = ConfigManager::getInstance()->getValue("localEnableUnmuteBySpace", m_enableUnmuteBySpace).toBool();
        emit enableUnmuteBySpaceChanged();
    }

    if (ConfigManager::getInstance()->contains("audioDeviceUseLastSelected")) {
        m_audioDeviceUseLastSelected = ConfigManager::getInstance()->getValue("audioDeviceUseLastSelected", m_audioDeviceUseLastSelected).toBool();
        emit audioDeviceUseLastSelectedChanged(m_audioDeviceUseLastSelected);
    }

    if (m_audioDeviceUseLastSelected) {
        m_audioRecordDeviceUseLastSelected =
            ConfigManager::getInstance()->getValue("audioRecordDeviceUseLastSelected", m_audioRecordDeviceUseLastSelected).toString();
        m_audioPlayoutDeviceUseLastSelected =
            ConfigManager::getInstance()->getValue("audioPlayoutDeviceUseLastSelected", m_audioPlayoutDeviceUseLastSelected).toString();
    }

    if (ConfigManager::getInstance()->contains("localEnableMirror")) {
        m_mirror = ConfigManager::getInstance()->getValue("localEnableMirror", m_mirror).toBool();
    }

    connect(AuthManager::getInstance(), &AuthManager::authStatusChanged, [this](NEAuthStatus authStatus, const NEAuthStatusExCode& error) {
        if (kAuthLoginSuccessed == authStatus) {
            updateSettings();
            updateVirtualBackground();
            initFaceBeautyLevel();
            auto nosService = GlobalManager::getInstance()->getNosService();
            if (nosService) {
                QString path = m_cacheDir + "/" + AuthManager::getInstance()->authAccountId() + "/image";
                nosService->setNosDownloadFilePath(path.toStdString());
            }
        }
    });

    connect(MeetingManager::getInstance(), &MeetingManager::roomStatusChanged, [this](NEMeeting::Status roomStatus) {
        if (NEMeeting::MEETING_CONNECTED == roomStatus) {
            updateSettings();
        }
    });
}

void SettingsManager::updateSettings() {
    setEnableMicVolumeAutoAdjust(enableMicVolumeAutoAdjust());
    setAudioProfile(audioProfile());
    setEnableAudioEchoCancellation(enableAudioEchoCancellation());
    setEnableAudioAINS(enableAudioAINS());
    setLocalVideoResolution(localVideoResolution());
    if (-1 != m_localVideoframerate) {
        setLocalVideoFramerate((neroom::NEVideoFramerate)m_localVideoframerate);
    }
    setRemoteVideoResolution(remoteVideoResolution());
    // setAudioDeviceAutoSelectType(audioDeviceAutoSelectType());
}

bool SettingsManager::enableAudioAfterJoin() const {
    return m_enableAudioAfterJoin;
}

void SettingsManager::setEnableAudioAfterJoin(bool enableAudioAfterJoin) {
    if (enableAudioAfterJoin == m_enableAudioAfterJoin) {
        return;
    }

    m_enableAudioAfterJoin = enableAudioAfterJoin;
    ConfigManager::getInstance()->setValue("localMicStatusEx", m_enableAudioAfterJoin);
    emit enableAudioAfterJoinChanged();

    auto* client = dynamic_cast<NS_I_NEM_SDK::NEMeetingSDKIPCClient*>(NS_I_NEM_SDK::NEMeetingSDKIPCClient::getInstance());
    if (client == nullptr)
        return;
    auto* settingsService = dynamic_cast<NS_I_NEM_SDK::NESettingsServiceIPCClient*>(client->getSettingsService());
    if (settingsService == nullptr)
        return;
    settingsService->notifySettingsChange(NS_I_NEM_SDK::SettingChangType::SettingChangType_Audio, enableAudioAfterJoin, 0);
}

bool SettingsManager::enableVideoAfterJoin() const {
    return m_enableVideoAfterJoin;
}

void SettingsManager::setEnableVideoAfterJoin(bool enableVideoAfterJoin) {
    if (enableVideoAfterJoin == m_enableVideoAfterJoin) {
        return;
    }
    m_enableVideoAfterJoin = enableVideoAfterJoin;
    ConfigManager::getInstance()->setValue("localCameraStatusEx", m_enableVideoAfterJoin);
    emit enableVideoAfterJoinChanged();

    auto* client = dynamic_cast<NS_I_NEM_SDK::NEMeetingSDKIPCClient*>(NS_I_NEM_SDK::NEMeetingSDKIPCClient::getInstance());
    if (client == nullptr)
        return;
    auto* settingsService = dynamic_cast<NS_I_NEM_SDK::NESettingsServiceIPCClient*>(client->getSettingsService());
    if (settingsService == nullptr)
        return;
    settingsService->notifySettingsChange(NS_I_NEM_SDK::SettingChangType::SettingChangType_Video, enableVideoAfterJoin, 0);
}

void SettingsManager::initFaceBeautyLevel() {
    if (-1 == m_FaceBeautyLevel) {
        if (kAuthLoginSuccessed == AuthManager::getInstance()->getAuthStatus()) {
            auto settings = AuthManager::getInstance()->getAccountSettings();
            if (settings.contains("beauty")) {
                auto beauty = settings["beauty"].toObject();
                if (beauty.contains("level")) {
                    YXLOG(Info) << "Set face beauty level by account settings: " << beauty["level"].toInt() << YXLOGEnd;
                    setFaceBeautyLevel(beauty["level"].toInt());
                }
            }
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

    auto rtcController = GlobalManager::getInstance()->getPreviewRoomRtcController();
    if (nullptr == rtcController)
        return;

    if (level == 0) {
        rtcController->enableBeauty(false);
        return;
    }
    rtcController->enableBeauty(true);
    // TODO(Dylan) 看下是否跟移动端对齐，找产品确认
    rtcController->setBeautyEffect(kNERoomBeautyWhiten, (float)level / 10.0);
    rtcController->setBeautyEffect(kNERoomBeautySmooth, (float)0.8 * level / 10.0);
    rtcController->setBeautyEffect(kNERoomBeautyFaceRuddy, (float)level / 10.0);
    rtcController->setBeautyEffect(kNERoomBeautyFaceSharpen, (float)level / 10.0);
    rtcController->setBeautyEffect(kNERoomBeautyThinFace, (float)0.8 * level / 10.0);
}

void SettingsManager::saveFaceBeautyLevel() const {
    QJsonObject obj;
    QJsonObject levelObj;
    levelObj["level"] = m_FaceBeautyLevel;
    obj["beauty"] = levelObj;
    YXLOG(Info) << "Save face beauty level: " << m_FaceBeautyLevel << YXLOGEnd;
    AuthManager::getInstance()->saveAccountSettings(obj);
}

bool SettingsManager::setEnableFaceBeauty(bool enable) {
    if (m_enableBeauty == enable) {
        return false;
    }

    YXLOG(Info) << "setEnableFaceBeauty: " << enable << YXLOGEnd;

    auto rtcController = GlobalManager::getInstance()->getPreviewRoomRtcController();
    if (nullptr != rtcController) {
        rtcController->startBeauty();
        // 不在美颜库初始化后直接启动美颜能力，SDK 目前即使美颜效果为 0 也依然会占用资源
        // rtcController->enableBeauty(enable);
        m_enableBeauty = enable;
        if (enable) {
            if (-1 == m_FaceBeautyLevel) {
                initFaceBeautyLevel();
            } else {
                YXLOG(Info) << "Set face beauty level by exists level settings: " << m_FaceBeautyLevel << YXLOGEnd;
                setFaceBeautyLevel(std::max(m_FaceBeautyLevel, 0));
            }
        }
    }

    return true;
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

    //    auto videoController = GlobalManager::getInstance()->getPreRoomService()->getPreRoomVideoController();
    //    if (videoController) {
    //        videoController->setInternalRender(enableInternalRender);
    //    }
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

bool SettingsManager::enableAudioAINS() const {
    if (neroom::kNEAudioScenarioMusic == m_audioScenarioType) {
        return false;
    }
    return m_enableAudioAINS;
}

void SettingsManager::setEnableAudioAINS(bool enableAudioAINS) {
    auto rtcController = GlobalManager::getInstance()->getPreviewRoomRtcController();
    if (rtcController) {
        if (neroom::kNEAudioScenarioMusic != m_audioScenarioType) {
        } else {
            enableAudioAINS = false;
        }

        rtcController->enableAudioAI(enableAudioAINS);
    }

    if (enableAudioAINS == m_enableAudioAINS) {
        return;
    }

    YXLOG(Info) << "setEnableAudioAINS, enable: " << enableAudioAINS << YXLOGEnd;
    m_enableAudioAINS = enableAudioAINS;
    if (neroom::kNEAudioScenarioMusic != m_audioScenarioType) {
        ConfigManager::getInstance()->setValue("localMicAINSStatusEx", m_enableAudioAINS);
    }
    emit enableAudioAINSChanged();

    auto* client = dynamic_cast<NS_I_NEM_SDK::NEMeetingSDKIPCClient*>(NS_I_NEM_SDK::NEMeetingSDKIPCClient::getInstance());
    if (client == nullptr)
        return;
    auto* settingsService = dynamic_cast<NS_I_NEM_SDK::NESettingsServiceIPCClient*>(client->getSettingsService());
    if (settingsService == nullptr)
        return;
    settingsService->notifySettingsChange(NS_I_NEM_SDK::SettingChangType::SettingChangType_AudioAINS, m_enableAudioAINS, 0);
}

void SettingsManager::setEnableMicVolumeAutoAdjust(bool enableMicVolumeAutoAdjust) {
    auto rtcController = GlobalManager::getInstance()->getPreviewRoomRtcController();
    if (rtcController)
        rtcController->enableAudioVolumeAutoAdjust(enableMicVolumeAutoAdjust);

    if (m_enableMicVolumeAutoAdjust == enableMicVolumeAutoAdjust)
        return;

    YXLOG(Info) << "setEnableMicVolumeAutoAdjust, enable: " << enableMicVolumeAutoAdjust << YXLOGEnd;
    m_enableMicVolumeAutoAdjust = enableMicVolumeAutoAdjust;

    auto* client = dynamic_cast<NS_I_NEM_SDK::NEMeetingSDKIPCClient*>(NS_I_NEM_SDK::NEMeetingSDKIPCClient::getInstance());
    if (client == nullptr)
        return;
    auto* settingsService = dynamic_cast<NS_I_NEM_SDK::NESettingsServiceIPCClient*>(client->getSettingsService());
    if (settingsService == nullptr)
        return;
    settingsService->notifySettingsChange(NS_I_NEM_SDK::SettingChangType::SettingChangType_AudioVolumeAutoAdjust, m_enableMicVolumeAutoAdjust, 0);

    ConfigManager::getInstance()->setValue("localMicVolumeAutoAdjustStatus", m_enableMicVolumeAutoAdjust);
    emit enableMicVolumeAutoAdjustChanged(m_enableMicVolumeAutoAdjust);
}

int SettingsManager::audioProfile() const {
    if (neroom::kNEAudioScenarioMusic == m_audioScenarioType) {
        return 1;
    }

    return 0;
}

void SettingsManager::setAudioProfile(int audioProfile) {
    if (UIAudioScenarioSpeech == audioProfile) {
        // 通话模式，通话模式，统一从 roomkit 获取 profile 配置，上层第一次的默认值使用 kNEAudioProfileMiddleQuality
        setAudioProfile(getProfileTypeFromRoomTemplate(), neroom::kNEAudioScenarioSpeech);
    }
    if (UIAudioScenarioMusic == audioProfile) {
        // 音乐模式
        setAudioProfile(m_audioProfileType, neroom::kNEAudioScenarioMusic);
    }
}

neroom::NERoomRtcAudioProfileType SettingsManager::audioProfileType() const {
    return m_audioProfileType;
}

neroom::NERoomRtcAudioScenarioType SettingsManager::audioScenarioType() const {
    return m_audioScenarioType;
}

void SettingsManager::setAudioProfile(neroom::NERoomRtcAudioProfileType audioProfileType, neroom::NERoomRtcAudioScenarioType audioScenarioType) {
    // 只负责设置，其他所有判断逻辑由调用该接口的地方负责
    auto rtcController = GlobalManager::getInstance()->getPreviewRoomRtcController();
    if (rtcController)
        rtcController->setAudioProfile(audioProfileType, audioScenarioType);

    if (m_audioProfileType == audioProfileType && m_audioScenarioType == audioScenarioType)
        return;

    m_audioScenarioType = audioScenarioType;
    ConfigManager::getInstance()->setValue("localAudioScenarioType", (int)m_audioScenarioType);
    emit audioProfileChanged(audioProfile());

    if (neroom::kNEAudioScenarioMusic == m_audioScenarioType) {
        m_audioProfileType = audioProfileType;
        ConfigManager::getInstance()->setValue("localAudioProfileType", (int)m_audioProfileType);
        if (m_enableAudioAINS) {
            setEnableAudioAINS(false);
        }
    } else {
        if (ConfigManager::getInstance()->contains("localMicAINSStatusEx")) {
            setEnableAudioAINS(ConfigManager::getInstance()->getValue("localMicAINSStatusEx", m_enableAudioAINS).toBool());
        } else {
            setEnableAudioAINS(false);
        }
    }

    auto* client = dynamic_cast<NS_I_NEM_SDK::NEMeetingSDKIPCClient*>(NS_I_NEM_SDK::NEMeetingSDKIPCClient::getInstance());
    if (client == nullptr)
        return;
    auto* settingsService = dynamic_cast<NS_I_NEM_SDK::NESettingsServiceIPCClient*>(client->getSettingsService());
    if (settingsService == nullptr)
        return;

    settingsService->notifySettingsChange(
        NS_I_NEM_SDK::SettingChangType::SettingChangType_AudioQuality, false,
        neroom::kNEAudioScenarioMusic == m_audioScenarioType ? NS_I_NEM_SDK::AudioQuality_Music : NS_I_NEM_SDK::AudioQuality_Talk);
}

void SettingsManager::setEnableAudioEchoCancellation(bool enableAudioEchoCancellation) {
    auto rtcController = GlobalManager::getInstance()->getPreviewRoomRtcController();
    if (rtcController)
        rtcController->enableAudioEchoCancellation(enableAudioEchoCancellation);

    if (m_enableAudioEchoCancellation == enableAudioEchoCancellation)
        return;

    YXLOG(Info) << "setEnableAudioEchoCancellation, enable: " << enableAudioEchoCancellation << YXLOGEnd;
    m_enableAudioEchoCancellation = enableAudioEchoCancellation;

    auto* client = dynamic_cast<NS_I_NEM_SDK::NEMeetingSDKIPCClient*>(NS_I_NEM_SDK::NEMeetingSDKIPCClient::getInstance());
    if (client == nullptr)
        return;
    auto* settingsService = dynamic_cast<NS_I_NEM_SDK::NESettingsServiceIPCClient*>(client->getSettingsService());
    if (settingsService == nullptr)
        return;
    settingsService->notifySettingsChange(NS_I_NEM_SDK::SettingChangType::SettingChangType_AudioEchoCancellation, m_enableAudioEchoCancellation, 0);

    ConfigManager::getInstance()->setValue("localAudioEchoCancellationStatus", m_enableAudioEchoCancellation);
    emit enableAudioEchoCancellationChanged(m_enableAudioEchoCancellation);
}

bool SettingsManager::enableAudioStereo() const {
    return m_enableAudioStereo;
    // return neroom::kNEAudioProfileHighQualityStereo == m_audioProfileType;
}

void SettingsManager::setEnableAudioStereo(bool enableAudioStereo) {
    // 音乐模式下若开启立体声，则始终使用 kNEAudioProfileHighQualityStereo，否则使用 kNEAudioProfileHighQuality
    // 这里一旦调用该接口，就意味着当前一定是音乐模式
    if (m_audioScenarioType != neroom::kNEAudioScenarioMusic)
        return;
    if (m_enableAudioStereo == enableAudioStereo)
        return;
    m_enableAudioStereo = enableAudioStereo;
    ConfigManager::getInstance()->setValue("localEnableAudioStereo", (int)m_enableAudioStereo);
    auto audioProfileType = m_enableAudioStereo ? neroom::kNEAudioProfileHighQualityStereo : neroom::kNEAudioProfileHighQuality;
    YXLOG(Info) << "Enable audio stereo, enable: " << enableAudioStereo << ", audio profile type: " << audioProfileType
                << ", audio scenario type: " << m_audioScenarioType << YXLOGEnd;
    setAudioProfile(audioProfileType, m_audioScenarioType);
}

void SettingsManager::setLocalVideoFramerate(neroom::NEVideoFramerate framerate) {
    auto rtcController = GlobalManager::getInstance()->getPreviewRoomRtcController();
    if (rtcController) {
        rtcController->setLocalVideoFramerate(framerate);
        m_localVideoframerate = (int)framerate;
    }
}

void SettingsManager::setLocalVideoResolution(VideoResolution localVideoResolution) {
    neroom::NEVideoResolution videoProfileType = neroom::kNEVideoProfileHD720P;
    switch (localVideoResolution) {
        case VR_DEFAULT:
            videoProfileType = neroom::kNEVideoProfileUsingTemplate;
            break;
        case VR_480P:
            videoProfileType = neroom::kNEVideoProfileStandard;
            break;
        case VR_720P:
            videoProfileType = neroom::kNEVideoProfileHD720P;
            break;
        case VR_1080P:
            videoProfileType = neroom::kNEVideoProfileHD1080P;
            break;
        case VR_4K:
            videoProfileType = neroom::kNEVideoProfile4KUHD;
            break;
        case VR_8K:
            videoProfileType = neroom::kNEVideoProfile8KUHD;
            break;
        default:
            break;
    }
    INEPreviewRoomRtcController* rtcController = nullptr;
    auto* roomContext = MeetingManager::getInstance()->getRoomContext();
    if (roomContext) {
        YXLOG(Info) << "[SettingsManager] using in room RTC controller" << YXLOGEnd;
        rtcController = roomContext->getRtcController();
    } else {
        YXLOG(Info) << "[SettingsManager] using in preview RTC controller" << YXLOGEnd;
        rtcController = GlobalManager::getInstance()->getPreviewRoomRtcController();
    }
    if (rtcController)
        rtcController->setLocalVideoResolution(videoProfileType);

    YXLOG(Info) << "setLocalVideoResolution, resolution: " << (int)localVideoResolution << YXLOGEnd;
    if (m_localVideoResolution == localVideoResolution)
        return;

    m_localVideoResolution = localVideoResolution;

    auto* client = dynamic_cast<NS_I_NEM_SDK::NEMeetingSDKIPCClient*>(NS_I_NEM_SDK::NEMeetingSDKIPCClient::getInstance());
    if (client == nullptr)
        return;
    auto* settingsService = dynamic_cast<NS_I_NEM_SDK::NESettingsServiceIPCClient*>(client->getSettingsService());
    if (settingsService == nullptr)
        return;
    settingsService->notifySettingsChange(NS_I_NEM_SDK::SettingChangType::SettingChangType_MyVideoResolution, false,
                                          (NS_I_NEM_SDK::LocalVideoResolution)m_localVideoResolution);

    ConfigManager::getInstance()->setValue("localVideoResolution", (int)m_localVideoResolution);
    emit localVideoResolutionChanged(m_localVideoResolution);
}

void SettingsManager::setRemoteVideoResolution(bool remoteVideoResolution) {
    if (m_remoteVideoResolution == remoteVideoResolution)
        return;

    YXLOG(Info) << "setRemoteVideoResolution, HD: " << remoteVideoResolution << YXLOGEnd;
    m_remoteVideoResolution = remoteVideoResolution;

    auto* client = dynamic_cast<NS_I_NEM_SDK::NEMeetingSDKIPCClient*>(NS_I_NEM_SDK::NEMeetingSDKIPCClient::getInstance());
    if (client == nullptr)
        return;
    auto* settingsService = dynamic_cast<NS_I_NEM_SDK::NESettingsServiceIPCClient*>(client->getSettingsService());
    if (settingsService == nullptr)
        return;
    settingsService->notifySettingsChange(
        NS_I_NEM_SDK::SettingChangType::SettingChangType_RemoteVideoResolution, false,
        !m_remoteVideoResolution ? NS_I_NEM_SDK::RemoteVideoResolution_Default : NS_I_NEM_SDK::RemoteVideoResolution_HD);

    ConfigManager::getInstance()->setValue("remoteVideoResolution", m_remoteVideoResolution);
    emit remoteVideoResolutionChanged(m_remoteVideoResolution);
}

void SettingsManager::setAudioDeviceAutoSelectType(neroom::NEAudioDeviceAutoSelectType audioDeviceAutoSelectType) {
    auto rtcController = GlobalManager::getInstance()->getPreviewRoomRtcController();
    if (rtcController)
        rtcController->setAudioDeviceAutoSelectType(audioDeviceAutoSelectType);

    YXLOG(Info) << "setAudioDeviceAutoSelectType, type: " << (int)audioDeviceAutoSelectType << YXLOGEnd;
    if (m_audioDeviceAutoSelectType == audioDeviceAutoSelectType)
        return;

    m_audioDeviceAutoSelectType = audioDeviceAutoSelectType;
    ConfigManager::getInstance()->setValue("audioDeviceAutoSelectType", m_audioDeviceAutoSelectType);
}

void SettingsManager::setCustomRender(const bool& customRender) {
    YXLOG(Info) << "setCustomRender, customRender: " << customRender << YXLOGEnd;
    if (m_customRender == customRender)
        return;
    m_customRender = customRender;
    emit customRenderChanged(m_customRender);
}

bool SettingsManager::unpubAudioOnMute() {
    return m_unpubAudioOnMute && GlobalManager::getInstance()->getGlobalConfig()->isUnpubAudioOnMuteSupported();
}

void SettingsManager::setUnpubAudioOnMute(bool unpubAudioOnMute) {
    YXLOG(Info) << "setUnpubAudioOnMute, unpubAudioOnMute: " << unpubAudioOnMute << YXLOGEnd;
    if (m_unpubAudioOnMute == unpubAudioOnMute)
        return;
    m_unpubAudioOnMute = unpubAudioOnMute;
    emit unpubAudioOnMuteChanged(m_unpubAudioOnMute);
}

bool SettingsManager::detectMutedMic() {
    return m_detectMutedMic;
}

void SettingsManager::setDetectMutedMic(bool detectMutedMic) {
    YXLOG(Info) << "setDetectMutedMic, detectMutedMic: " << detectMutedMic << YXLOGEnd;
    if (m_detectMutedMic == detectMutedMic)
        return;
    m_detectMutedMic = detectMutedMic;
    emit detectMutedMicChanged(m_detectMutedMic);
}

void SettingsManager::setAudioDeviceUseLastSelected(const bool& audioDeviceUseLastSelected) {
    YXLOG(Info) << "setAudioDeviceUseLastSelected, bOn: " << audioDeviceUseLastSelected << YXLOGEnd;
    if (m_audioDeviceUseLastSelected == audioDeviceUseLastSelected)
        return;

    m_audioDeviceUseLastSelected = audioDeviceUseLastSelected;
    emit audioDeviceUseLastSelectedChanged(m_audioDeviceUseLastSelected);
    ConfigManager::getInstance()->setValue("audioDeviceUseLastSelected", m_audioDeviceUseLastSelected);
}

void SettingsManager::setAudioRecordDeviceUseLastSelected(const QString& audioRecordDeviceUseLastSelected) {
    YXLOG(Info) << "setAudioRecordDeviceUseLastSelected, deviceId: " << audioRecordDeviceUseLastSelected.toStdString() << YXLOGEnd;
    if (m_audioRecordDeviceUseLastSelected == audioRecordDeviceUseLastSelected)
        return;

    m_audioRecordDeviceUseLastSelected = audioRecordDeviceUseLastSelected;
    ConfigManager::getInstance()->setValue("audioRecordDeviceUseLastSelected", m_audioRecordDeviceUseLastSelected);
}

void SettingsManager::setAudioPlayoutDeviceUseLastSelected(const QString& audioPlayoutDeviceUseLastSelected) {
    YXLOG(Info) << "setAudioPlayoutDeviceUseLastSelected, deviceId: " << audioPlayoutDeviceUseLastSelected.toStdString() << YXLOGEnd;
    if (m_audioPlayoutDeviceUseLastSelected == audioPlayoutDeviceUseLastSelected)
        return;

    m_audioPlayoutDeviceUseLastSelected = audioPlayoutDeviceUseLastSelected;
    ConfigManager::getInstance()->setValue("audioPlayoutDeviceUseLastSelected", m_audioPlayoutDeviceUseLastSelected);
}

void SettingsManager::setVirtualBackground(int virtualBackground) {
    if (virtualBackground != m_virtualBackground) {
        m_virtualBackground = virtualBackground;
        ConfigManager::getInstance()->setValue("virtualBackground", m_virtualBackground);
    }
}

void SettingsManager::setShowVirtualBackground(bool showVirtualBackground) {
    if (m_showVirtualBackground == showVirtualBackground)
        return;

    m_showVirtualBackground = showVirtualBackground;
    emit showVirtualBackgroundChanged(m_showVirtualBackground);
    ConfigManager::getInstance()->setValue("showVirtualBackground", m_showVirtualBackground);
}

bool SettingsManager::showVirtualBackground() const {
    return GlobalManager::getInstance()->getGlobalConfig()->isVBSupported() && m_showVirtualBackground;
}

QString SettingsManager::getVirtualBackgroundPath() {
    QString logPathEx = getLogPath();
    logPathEx.append("_Files/image/vb/");
    QDir logDir;
    if (!logDir.exists(logPathEx))
        logDir.mkpath(logPathEx);

    return logPathEx;
}

void SettingsManager::setCacheDir(const QString& cacheDir) {
    m_cacheDir = cacheDir;
    emit cacheDirChanged();
    auto nosService = GlobalManager::getInstance()->getNosService();
    if (nosService) {
        QString path = m_cacheDir + "/" + AuthManager::getInstance()->authAccountId() + "/image";
        nosService->setNosDownloadFilePath(path.toStdString());
    }
    ConfigManager::getInstance()->setValue("localCacheDir", cacheDir);
}

void SettingsManager::setEnableUnmuteBySpace(bool enableUnmuteBySpace) {
    m_enableUnmuteBySpace = enableUnmuteBySpace;
    emit enableUnmuteBySpaceChanged();
    ConfigManager::getInstance()->setValue("localEnableUnmuteBySpace", m_enableUnmuteBySpace);
}

void SettingsManager::initVirtualBackground(const std::vector<VirtualBackgroundModel::VBProperty>& vbList) {
    bool bCustom = false;
    if (vbList.empty() && m_buildInVB.empty()) {
        auto vbPath = getVirtualBackgroundPath();
        QDir dir(vbPath);
        std::map<uint64_t, QString> mapVB;
        for (auto& it : dir.entryList(QDir::Files)) {
            int index = it.indexOf("_+_+_");
            if (index <= 0) {
                continue;
            }
            QString time = it.left(index);
            if (time.isEmpty()) {
                continue;
            }
            mapVB[time.toULongLong()] = vbPath + it;
        }

        QString applicationDir = qApp->applicationDirPath();
#ifdef Q_OS_MACX
        applicationDir = applicationDir + "/../Resources/image/vb/";
#else
        applicationDir = applicationDir + "/image/vb/";
#endif

        m_buildInVB.reserve(mapVB.size() + 15);
        m_buildInVB.assign(
            {VirtualBackgroundModel::VBProperty{applicationDir + "null.jpg", applicationDir + "null-thumbnail.jpg", false, false},
             VirtualBackgroundModel::VBProperty{applicationDir + "pexels-pixabay.jpg", applicationDir + "pexels-pixabay-thumbnail.jpg", false, false},
             VirtualBackgroundModel::VBProperty{applicationDir + "bricks.jpg", applicationDir + "bricks-thumbnail.jpg", false, false},
             VirtualBackgroundModel::VBProperty{applicationDir + "interior-design.jpg", applicationDir + "interior-design-thumbnail.jpg", false,
                                                false},
             VirtualBackgroundModel::VBProperty{applicationDir + "meeting-room.jpg", applicationDir + "meeting-room-thumbnail.jpg", false, false},
             VirtualBackgroundModel::VBProperty{applicationDir + "pexels-katerina-holmes.jpg",
                                                applicationDir + "pexels-katerina-holmes-thumbnail.jpg", false, false},
             VirtualBackgroundModel::VBProperty{applicationDir + "whiteboard.jpg", applicationDir + "whiteboard-thumbnail.jpg", false, false}});

        std::transform(mapVB.begin(), mapVB.end(), std::back_inserter(m_buildInVB), [](const auto& it) {
            return VirtualBackgroundModel::VBProperty{it.second, it.second, true, false};
        });
        m_buildInVB.emplace_back(
            VirtualBackgroundModel::VBProperty{"qrc:/qml/images/settings/vb/add.svg", "qrc:/qml/images/settings/vb/add.svg", false, false});
    } else {
        bCustom = true;
        VirtualBackgroundModel::VBProperty front = m_buildInVB.front();
        VirtualBackgroundModel::VBProperty back = m_buildInVB.back();
        m_buildInVB.clear();
        m_buildInVB.reserve(vbList.size() + 2);
        m_buildInVB.emplace_back(front);
        m_buildInVB.insert(std::next(m_buildInVB.begin()), vbList.begin(), vbList.end());
        m_buildInVB.emplace_back(back);
    }

    if (m_virtualBackground >= (int)(m_buildInVB.size() - 1)) {
        setVirtualBackground(0);
        m_buildInVB.begin()->bCurrentSelected = true;
    } else {
        m_buildInVB.at(m_virtualBackground).bCurrentSelected = true;
    }
    if (bCustom) {
        updateVirtualBackground();
    }
}

std::vector<VirtualBackgroundModel::VBProperty>& SettingsManager::getVirtualBackgroundList() {
    return m_buildInVB;
}

std::vector<VirtualBackgroundModel::VBProperty> SettingsManager::getBuildInVirtualBackground() {
    return std::vector<VirtualBackgroundModel::VBProperty>{m_buildInVB.begin() + 1, m_buildInVB.end() - 1};
}

void SettingsManager::updateVirtualBackground() {
    if (!showVirtualBackground()) {
        YXLOG(Info) << "updateVirtualBackground, m_showVirtualBackground is false." << YXLOGEnd;
        return;
    }
    if (m_virtualBackground <= 0) {
        auto rtcController = GlobalManager::getInstance()->getPreviewRoomRtcController();
        if (rtcController) {
            rtcController->enableVirtualBackground(false, NERoomVirtualBackgroundSource{});
        }
    } else {
        auto rtcController = GlobalManager::getInstance()->getPreviewRoomRtcController();
        if (rtcController) {
            VirtualBackgroundModel model;
            auto modelList = model.virtualBackgroundList();
            if (m_virtualBackground < (int)modelList.size()) {
                NERoomVirtualBackgroundSource source;
                source.sourceType = kNEBackgroundImage;
                source.path = modelList.at(m_virtualBackground).strPath.toStdString();
                rtcController->enableVirtualBackground(true, source);
            }
        }
    }
}

neroom::NERoomRtcAudioProfileType SettingsManager::getProfileTypeFromRoomTemplate() const {
    neroom::NERoomRtcAudioProfileType audioProfileType = neroom::kNEAudioProfileMiddleQuality;
    bool usingRoomkitOption = false;
    do {
        auto roomContext = MeetingManager::getInstance()->getRoomContext();
        if (!roomContext)
            break;
        auto localMember = roomContext->getLocalMember();
        auto roomTemplate = roomContext->getRoomTemplate();
        for (auto& role : roomTemplate.roles) {
            if (role.name == localMember->getUserRole().name) {
                usingRoomkitOption = true;
                audioProfileType = convertAudioProfile(role.params.audio.profile);
                YXLOG(Info) << "Get audio profile type from room template, profile type: " << audioProfileType << YXLOGEnd;
                break;
            }
        }
    } while (false);
    if (!usingRoomkitOption) {
        YXLOG(Info) << "Cannot get profile type from neroom template, using default audio profile type: " << audioProfileType << YXLOGEnd;
    }
    return audioProfileType;
}

neroom::NERoomRtcAudioProfileType SettingsManager::convertAudioProfile(const std::string& profile) const {
    if (profile == "DEFAULT") {
        return neroom::kNEAudioProfileDefault;
    } else if (profile == "STANDARD") {
        return neroom::kNEAudioProfileStandard;
    } else if (profile == "STANDARD_EXTEND") {
        return neroom::kNEAudioProfileStandardExtend;
    } else if (profile == "MIDDLE_QUALITY") {
        return neroom::kNEAudioProfileMiddleQuality;
    } else if (profile == "MIDDLE_QUALITY_STEREO") {
        return neroom::kNEAudioProfileMiddleQualityStereo;
    } else if (profile == "HIGH_QUALITY") {
        return neroom::kNEAudioProfileHighQuality;
    } else if (profile == "HIGH_QUALITY_STEREO") {
        return neroom::kNEAudioProfileHighQualityStereo;
    }
    return neroom::kNEAudioProfileMiddleQuality;
}

QString SettingsManager::getLogPath() {
    QString logPathEx = qApp->property("logPath").toString();
    if (logPathEx.isEmpty())
        logPathEx = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
    do {
        if (logPathEx.endsWith("/")) {
            logPathEx = logPathEx.left(logPathEx.size() - 1);
        } else if (logPathEx.endsWith("\\")) {
            logPathEx = logPathEx.left(logPathEx.size() - 1);
        } else {
            break;
        }
    } while (true);
    return logPathEx;
}

void SettingsManager::setShowSpeaker(bool showSpeaker) {
    if (m_showSpeaker == showSpeaker)
        return;

    m_showSpeaker = showSpeaker;
    emit showSpeakerChanged(m_showSpeaker);
    ConfigManager::getInstance()->setValue("showSpeaker", m_showSpeaker);
}

SettingsManager::UILanguage SettingsManager::uiLanguage() const {
    auto language = QString::fromStdString(GlobalManager::getInstance()->language());
    if (language.startsWith("zh")) {
        return UILanguage_zh;
    } else if (language.startsWith("en")) {
        return UILanguage_en;
    } else if (language.startsWith("ja")) {
        return UILanguage_ja;
    }
    return UILanguage_zh;
}

bool SettingsManager::mirror() const {
    return m_mirror;
}

void SettingsManager::setMirror(bool newMirror) {
    if (m_mirror == newMirror)
        return;
    m_mirror = newMirror;
    emit mirrorChanged();
    ConfigManager::getInstance()->setValue("localEnableMirror", m_mirror);
}

void SettingsManager::sleepForMS(unsigned long duration) const {
    std::chrono::steady_clock::time_point cur = std::chrono::steady_clock::now();
    while (std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now() - cur).count() <= duration) {
        std::this_thread::yield();
    }
}

bool SettingsManager::extendView() const {
    return m_extendView;
}

void SettingsManager::setExtendView(bool newExtendView) {
    if (m_extendView == newExtendView)
        return;
    m_extendView = newExtendView;
    emit extendViewChanged();
}
