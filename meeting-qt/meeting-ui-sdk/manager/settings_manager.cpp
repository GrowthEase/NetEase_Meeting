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

    if (ConfigManager::getInstance()->contains("showVirtualBackground")) {
        m_showVirtualBackground = ConfigManager::getInstance()->getValue("showVirtualBackground", m_showVirtualBackground).toBool();
    }

    if (ConfigManager::getInstance()->contains("virtualBackground")) {
        m_virtualBackground = ConfigManager::getInstance()->getValue("virtualBackground", 0).toInt();
    }

    initVirtualBackground(std::vector<VirtualBackgroundModel::VBProperty>{});

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

    if (ConfigManager::getInstance()->contains("localMicVolumeAutoAdjustStatus")) {
        m_enableMicVolumeAutoAdjust = ConfigManager::getInstance()->getValue("localMicVolumeAutoAdjustStatus", m_enableMicVolumeAutoAdjust).toBool();
        emit enableMicVolumeAutoAdjustChanged(m_enableMicVolumeAutoAdjust);
    }

    if (ConfigManager::getInstance()->contains("localAudioProfileType") && ConfigManager::getInstance()->contains("localAudioScenarioType")) {
        m_audioProfileType =
            (neroom::NEAudioProfileType)ConfigManager::getInstance()->getValue("localAudioProfileType", (int)m_audioProfileType).toInt();
        m_audioScenarioType =
            (neroom::NEAudioScenarioType)ConfigManager::getInstance()->getValue("localAudioScenarioType", (int)m_audioScenarioType).toInt();
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
        auto settings = AuthManager::getInstance()->getAccountSettings();
        if (settings.contains("beauty")) {
            auto beauty = settings["beauty"].toObject();
            if (beauty.contains("level")) {
                m_FaceBeautyLevel = beauty["level"].toInt();
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
    if (nullptr != rtcController) {
        rtcController->setBeautyEffect(kNERoomBeautyWhiten, (float)level / 10.0);
        rtcController->setBeautyEffect(kNERoomBeautySmooth, (float)0.8 * level / 10.0);
        rtcController->setBeautyEffect(kNERoomBeautyFaceRuddy, (float)level / 10.0);
        rtcController->setBeautyEffect(kNERoomBeautyFaceSharpen, (float)level / 10.0);
        rtcController->setBeautyEffect(kNERoomBeautyThinFace, (float)0.8 * level / 10.0);
    }
}

void SettingsManager::saveFaceBeautyLevel() const {
    QJsonObject obj;
    QJsonObject levelObj;
    levelObj["level"] = m_FaceBeautyLevel;
    obj["beauty"] = levelObj;
    AuthManager::getInstance()->saveAccountSettings(obj);
}

bool SettingsManager::setEnableFaceBeauty(bool enable) {
    if (m_enableBeauty == enable) {
        return false;
    }

    auto rtcController = GlobalManager::getInstance()->getPreviewRoomRtcController();
    if (nullptr != rtcController) {
        rtcController->startBeauty();
        rtcController->enableBeauty(enable);
        m_enableBeauty = enable;
        if (enable) {
            auto faceBeautyLevel = std::max(m_FaceBeautyLevel, 0);
            rtcController->setBeautyEffect(kNERoomBeautyWhiten, (float)faceBeautyLevel / 10.0);
            rtcController->setBeautyEffect(kNERoomBeautySmooth, (float)0.8 * faceBeautyLevel / 10.0);
            rtcController->setBeautyEffect(kNERoomBeautyFaceRuddy, (float)faceBeautyLevel / 10.0);
            rtcController->setBeautyEffect(kNERoomBeautyFaceSharpen, (float)faceBeautyLevel / 10.0);
            rtcController->setBeautyEffect(kNERoomBeautyThinFace, (float)0.8 * faceBeautyLevel / 10.0);
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
    if (0 == audioProfile) {
        setAudioProfile(neroom::kNEAudioProfileStandard, neroom::kNEAudioScenarioSpeech);
    } else if (1 == audioProfile) {
        setAudioProfile(m_audioProfileType, neroom::kNEAudioScenarioMusic);
    } else {
    }
}

neroom::NEAudioProfileType SettingsManager::audioProfileType() const {
    return m_audioProfileType;
}

neroom::NEAudioScenarioType SettingsManager::audioScenarioType() const {
    return m_audioScenarioType;
}

void SettingsManager::setAudioProfile(neroom::NEAudioProfileType audioProfileType, neroom::NEAudioScenarioType audioScenarioType) {
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
    return neroom::kNEAudioProfileHighQualityStereo == m_audioProfileType;
}

void SettingsManager::setEnableAudioStereo(bool enableAudioStereo) {
    auto audioProfileType = enableAudioStereo ? neroom::kNEAudioProfileHighQualityStereo : neroom::kNEAudioProfileHighQuality;
    auto rtcController = GlobalManager::getInstance()->getPreviewRoomRtcController();
    if (rtcController)
        rtcController->setAudioProfile(audioProfileType, m_audioScenarioType);

    if (m_audioProfileType == audioProfileType)
        return;

    YXLOG(Info) << "setEnableAudioStereo, enable: " << audioProfileType << YXLOGEnd;
    m_audioProfileType = audioProfileType;

    auto* client = dynamic_cast<NS_I_NEM_SDK::NEMeetingSDKIPCClient*>(NS_I_NEM_SDK::NEMeetingSDKIPCClient::getInstance());
    if (client == nullptr)
        return;
    auto* settingsService = dynamic_cast<NS_I_NEM_SDK::NESettingsServiceIPCClient*>(client->getSettingsService());
    if (settingsService == nullptr)
        return;
    settingsService->notifySettingsChange(NS_I_NEM_SDK::SettingChangType::SettingChangType_AudioEnableStereo, enableAudioStereo, 0);

    ConfigManager::getInstance()->setValue("localAudioProfileType", (int)m_audioProfileType);
    enableAudioStereoChanged(enableAudioStereo);
}

void SettingsManager::setLocalVideoResolution(VideoResolution localVideoResolution) {
    auto rtcController = GlobalManager::getInstance()->getPreviewRoomRtcController();
    if (rtcController) {
        neroom::NEVideoResolution videoProfileType = neroom::kNEVideoProfileHD720P;
        switch (localVideoResolution) {
            case VR_480P:
                videoProfileType = neroom::kNEVideoProfileStandard;
                break;
            case VR_720P:
                videoProfileType = neroom::kNEVideoProfileHD720P;
                break;
            case VR_1080P:
                videoProfileType = neroom::kNEVideoProfileHD1080P;
                break;
            default:
                break;
        }
        rtcController->setLocalVideoResolution(videoProfileType);
    }

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
        m_buildInVB.assign({VirtualBackgroundModel::VBProperty{applicationDir + "null.jpg", false, false},
                            VirtualBackgroundModel::VBProperty{applicationDir + "pexels-pixabay.jpg", false, false},
                            VirtualBackgroundModel::VBProperty{applicationDir + "bricks.jpg", false, false},
                            VirtualBackgroundModel::VBProperty{applicationDir + "interior-design.jpg", false, false},
                            VirtualBackgroundModel::VBProperty{applicationDir + "meeting-room.jpg", false, false},
                            VirtualBackgroundModel::VBProperty{applicationDir + "pexels-katerina-holmes.jpg", false, false},
                            VirtualBackgroundModel::VBProperty{applicationDir + "whiteboard.jpg", false, false}});

        std::transform(mapVB.begin(), mapVB.end(), std::back_inserter(m_buildInVB), [](const auto& it) {
            return VirtualBackgroundModel::VBProperty{it.second, true, false};
        });
        m_buildInVB.emplace_back(VirtualBackgroundModel::VBProperty{"qrc:/qml/images/settings/vb/add.svg", false, false});
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

QString SettingsManager::getLogPath() {
    QString logPathEx = qApp->property("logPath").toString();
    if (logPathEx.isEmpty())
        logPathEx = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
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
