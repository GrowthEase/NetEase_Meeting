// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef SETTINGSMANAGER_H
#define SETTINGSMANAGER_H

#include <QObject>
#include "base_type_defines.h"
#include "client_setting_service.h"
#include "models/virtualbackground_model.h"

class SettingsManager : public QObject {
    Q_OBJECT
public:
    explicit SettingsManager(QObject* parent = nullptr);
    enum VideoResolution { VR_DEFAULT = 0, VR_480P = 1, VR_720P = 2, VR_1080P = 3, VR_4K = 4, VR_8K = 5 };
    Q_ENUM(VideoResolution)
    enum UILanguage { UILanguage_zh = 1, UILanguage_en = 2, UILanguage_ja = 3 };
    Q_ENUM(UILanguage)
    enum AudioScenario { UIAudioScenarioSpeech, UIAudioScenarioMusic };
    Q_ENUM(AudioScenario)
    enum SidebarViewMode { VM_MIN = 0, VM_SINGLE = 1, VM_MULTIPLE = 2 };
    Q_ENUM(SidebarViewMode)

    SINGLETONG(SettingsManager);

    Q_PROPERTY(bool enableAudioAfterJoin READ enableAudioAfterJoin WRITE setEnableAudioAfterJoin NOTIFY enableAudioAfterJoinChanged)
    Q_PROPERTY(bool enableVideoAfterJoin READ enableVideoAfterJoin WRITE setEnableVideoAfterJoin NOTIFY enableVideoAfterJoinChanged)
    Q_PROPERTY(bool enableAudioAINS READ enableAudioAINS WRITE setEnableAudioAINS NOTIFY enableAudioAINSChanged)
    Q_PROPERTY(
        bool enableMicVolumeAutoAdjust READ enableMicVolumeAutoAdjust WRITE setEnableMicVolumeAutoAdjust NOTIFY enableMicVolumeAutoAdjustChanged)
    Q_PROPERTY(int audioProfile READ audioProfile WRITE setAudioProfile NOTIFY audioProfileChanged)
    Q_PROPERTY(bool enableAudioEchoCancellation READ enableAudioEchoCancellation WRITE setEnableAudioEchoCancellation NOTIFY
                   enableAudioEchoCancellationChanged)
    Q_PROPERTY(bool enableAudioStereo READ enableAudioStereo WRITE setEnableAudioStereo NOTIFY enableAudioStereoChanged)
    Q_PROPERTY(int faceBeautyLevel READ faceBeautyLevel WRITE setFaceBeautyLevel NOTIFY faceBeautyLevelChanged)

    Q_PROPERTY(bool enableInternalRender READ enableInternalRender WRITE setEnableInternalRender NOTIFY enableInternalRenderChanged)
    Q_PROPERTY(bool mainWindowVisible READ mainWindowVisible WRITE setMainWindowVisible NOTIFY mainWindowVisibleChanged)

    Q_PROPERTY(VideoResolution localVideoResolution READ localVideoResolution WRITE setLocalVideoResolution NOTIFY localVideoResolutionChanged)
    Q_PROPERTY(bool remoteVideoResolution READ remoteVideoResolution WRITE setRemoteVideoResolution NOTIFY remoteVideoResolutionChanged)
    Q_PROPERTY(bool showVirtualBackground READ showVirtualBackground WRITE setShowVirtualBackground NOTIFY showVirtualBackgroundChanged)
    Q_PROPERTY(bool showSpeaker READ showSpeaker WRITE setShowSpeaker NOTIFY showSpeakerChanged)
    Q_PROPERTY(QString cacheDir READ cacheDir WRITE setCacheDir NOTIFY cacheDirChanged)
    Q_PROPERTY(bool enableUnmuteBySpace READ enableUnmuteBySpace WRITE setEnableUnmuteBySpace NOTIFY enableUnmuteBySpaceChanged)
    Q_PROPERTY(
        bool audioDeviceUseLastSelected READ audioDeviceUseLastSelected WRITE setAudioDeviceUseLastSelected NOTIFY audioDeviceUseLastSelectedChanged)
    Q_PROPERTY(bool customRender READ customRender WRITE setCustomRender NOTIFY customRenderChanged)
    Q_PROPERTY(bool unpubAudioOnMute READ unpubAudioOnMute WRITE setUnpubAudioOnMute NOTIFY unpubAudioOnMuteChanged)
    Q_PROPERTY(bool detectMutedMic READ detectMutedMic WRITE setDetectMutedMic NOTIFY detectMutedMicChanged)
    Q_PROPERTY(UILanguage uiLanguage READ uiLanguage CONSTANT)
    Q_PROPERTY(bool mirror READ mirror WRITE setMirror NOTIFY mirrorChanged)
    Q_PROPERTY(bool extendView READ extendView WRITE setExtendView NOTIFY extendViewChanged)
    Q_PROPERTY(SidebarViewMode sidebarViewMode READ sidebarViewMode WRITE setSidebarViewMode NOTIFY sidebarViewModeChanged)

    Q_INVOKABLE bool enableAudioAfterJoin() const;
    Q_INVOKABLE void setEnableAudioAfterJoin(bool enableAudioAfterJoin);

    Q_INVOKABLE bool enableVideoAfterJoin() const;
    Q_INVOKABLE void setEnableVideoAfterJoin(bool enableVideoAfterJoin);

    Q_INVOKABLE bool enableAudioAINS() const;
    Q_INVOKABLE void setEnableAudioAINS(bool enableAudioAINS);

    Q_INVOKABLE int faceBeautyLevel() const;
    Q_INVOKABLE void setFaceBeautyLevel(int level);

    Q_INVOKABLE bool setEnableFaceBeauty(bool enable);
    Q_INVOKABLE bool getEnableBeauty() const { return m_enableBeauty; }

    Q_INVOKABLE void saveFaceBeautyLevel() const;
    Q_INVOKABLE void initFaceBeautyLevel();

    Q_INVOKABLE bool enableInternalRender() const;
    Q_INVOKABLE void setEnableInternalRender(bool enableInternalRender);

    Q_INVOKABLE bool mainWindowVisible() const;
    Q_INVOKABLE void setMainWindowVisible(bool mainWindowVisible);

    Q_INVOKABLE UILanguage uiLanguage() const;
    Q_INVOKABLE void sleepForMS(unsigned long duration) const;

    void updateSettings();

    bool useInternalRender() const;

    bool enableMicVolumeAutoAdjust() const { return m_enableMicVolumeAutoAdjust; }
    int audioProfile() const;
    bool enableAudioEchoCancellation() const { return m_enableAudioEchoCancellation; }

    neroom::NERoomRtcAudioProfileType audioProfileType() const;
    neroom::NERoomRtcAudioScenarioType audioScenarioType() const;
    void setAudioProfile(neroom::NERoomRtcAudioProfileType audioProfileType, neroom::NERoomRtcAudioScenarioType audioScenarioType);

    bool enableAudioStereo() const;
    VideoResolution localVideoResolution() const { return m_localVideoResolution; }
    bool remoteVideoResolution() const { return m_remoteVideoResolution; }

    void setAudioDeviceAutoSelectType(neroom::NEAudioDeviceAutoSelectType audioDeviceAutoSelectType);
    neroom::NEAudioDeviceAutoSelectType audioDeviceAutoSelectType() const { return m_audioDeviceAutoSelectType; }

    int getVirtualBackground() const { return m_virtualBackground; }
    void setVirtualBackground(int virtualBackground);
    void initVirtualBackground(const std::vector<VirtualBackgroundModel::VBProperty>& vbList);
    std::vector<VirtualBackgroundModel::VBProperty> getBuildInVirtualBackground();
    std::vector<VirtualBackgroundModel::VBProperty>& getVirtualBackgroundList();
    bool showVirtualBackground() const;
    QString getVirtualBackgroundPath();

    bool showSpeaker() const { return m_showSpeaker; }

    QString cacheDir() { return m_cacheDir; }
    void setCacheDir(const QString& cacheDir);

    bool enableUnmuteBySpace() { return m_enableUnmuteBySpace; }
    void setEnableUnmuteBySpace(bool enableUnmuteBySpace);

    bool audioDeviceUseLastSelected() const { return m_audioDeviceUseLastSelected; }

    bool customRender() const { return m_customRender; }

    QString audioRecordDeviceUseLastSelected() const { return m_audioRecordDeviceUseLastSelected; }
    void setAudioRecordDeviceUseLastSelected(const QString& audioRecordDeviceUseLastSelected);

    QString audioPlayoutDeviceUseLastSelected() const { return m_audioPlayoutDeviceUseLastSelected; }
    void setAudioPlayoutDeviceUseLastSelected(const QString& audioPlayoutDeviceUseLastSelected);

    bool unpubAudioOnMute();
    bool detectMutedMic();

    bool mirror() const;
    void setMirror(bool newMirror);

    bool extendView() const;
    void setExtendView(bool newExtendView);

    SidebarViewMode sidebarViewMode() const { return m_sidebarViewMode; }
    void setSidebarViewMode(SidebarViewMode newSidebarViewMode) {
        if (m_sidebarViewMode == newSidebarViewMode)
            return;
        m_sidebarViewMode = newSidebarViewMode;
        emit sidebarViewModeChanged();
    }

public slots:
    void setEnableMicVolumeAutoAdjust(bool enableMicVolumeAutoAdjust);
    void setAudioProfile(int audioProfile);
    void setEnableAudioEchoCancellation(bool enableAudioEchoCancellation);
    void setEnableAudioStereo(bool enableAudioStereo);
    void setLocalVideoResolution(VideoResolution localVideoResolution);
    void setLocalVideoFramerate(neroom::NEVideoFramerate framerate);
    void setRemoteVideoResolution(bool remoteVideoResolution);
    void setShowVirtualBackground(bool showVirtualBackground);
    void setShowSpeaker(bool showSpeaker);
    void setAudioDeviceUseLastSelected(const bool& audioDeviceUseLastSelected);
    void setCustomRender(const bool& customRender);
    void setUnpubAudioOnMute(bool unpubAudioOnMute);
    void setDetectMutedMic(bool detectMutedMic);

signals:
    void enableAudioAfterJoinChanged();
    void enableVideoAfterJoinChanged();
    void enableAudioAINSChanged();
    void faceBeautyLevelChanged();
    void enableInternalRenderChanged();
    void mainWindowVisibleChanged();
    void enableMicVolumeAutoAdjustChanged(bool enableMicVolumeAutoAdjust);
    void audioProfileChanged(int audioProfile);
    void enableAudioEchoCancellationChanged(bool enableAudioEchoCancellation);
    void enableAudioStereoChanged(bool enableAudioStereo);
    void localVideoResolutionChanged(VideoResolution localVideoResolution);
    void remoteVideoResolutionChanged(bool remoteVideoResolution);
    void virtualBackgroundChanged(bool enabled, const QString& msg);
    void showVirtualBackgroundChanged(bool showVirtualBackground);
    void showSpeakerChanged(bool showSpeaker);
    void cacheDirChanged();
    void enableUnmuteBySpaceChanged();
    void audioDeviceUseLastSelectedChanged(const bool& audioDeviceUseLastSelected);
    void customRenderChanged(const bool& customRender);
    void unpubAudioOnMuteChanged(bool unpubAudioOnMute);
    void detectMutedMicChanged(bool detectMutedMic);
    void mirrorChanged();
    void extendViewChanged();
    void sidebarViewModeChanged();

private:
    void updateVirtualBackground();
    neroom::NERoomRtcAudioProfileType getProfileTypeFromRoomTemplate() const;
    neroom::NERoomRtcAudioProfileType convertAudioProfile(const std::string& profile) const;
    QString getLogPath();

private:
    bool m_enableAudioAfterJoin = false;
    bool m_enableVideoAfterJoin = false;
    bool m_enableAudioAINS = false;
    bool m_enableBeauty = false;
    int m_FaceBeautyLevel = -1;
    bool m_enableInternalRender = false;
    bool m_mainWindowVisible = false;
    bool m_enableMicVolumeAutoAdjust = true;
    neroom::NERoomRtcAudioProfileType m_audioProfileType = neroom::kNEAudioProfileMiddleQuality;
    neroom::NERoomRtcAudioScenarioType m_audioScenarioType = neroom::kNEAudioScenarioSpeech;
    bool m_enableAudioStereo = false;
    bool m_enableAudioEchoCancellation = true;
    VideoResolution m_localVideoResolution = VR_720P;
    int m_localVideoframerate = -1;
    bool m_remoteVideoResolution = false;
    neroom::NEAudioDeviceAutoSelectType m_audioDeviceAutoSelectType = neroom::kNEAudioDeviceAutoSelectTypeAvailable;
    int m_virtualBackground = 0;
    std::vector<VirtualBackgroundModel::VBProperty> m_buildInVB;
    bool m_showVirtualBackground = true;
    bool m_showSpeaker = true;
    QString m_cacheDir;
    bool m_enableUnmuteBySpace = false;
    bool m_audioDeviceUseLastSelected = false;
    bool m_customRender = false;
    QString m_audioRecordDeviceUseLastSelected;
    QString m_audioPlayoutDeviceUseLastSelected;
    bool m_unpubAudioOnMute = true;
    bool m_detectMutedMic = true;
    bool m_mirror = true;
    bool m_extendView = false;
    SidebarViewMode m_sidebarViewMode = VM_SINGLE;
};

#endif  // SETTINGSMANAGER_H
