// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "setting_prochandler.h"
#include "manager/global_manager.h"
#include "manager/meeting_manager.h"
#include "manager/settings_manager.h"

bool NESettingsServiceProcHandlerIMP::onShowSettingUIWnd(const NS_I_NEM_SDK::NESettingsUIWndConfig& /*config*/,
                                                         const NS_I_NEM_SDK::NESettingsService::NEShowSettingUIWndCallback& cb) {
    YXLOG_API(Info) << "Received show settings UI window request." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        GlobalManager::getInstance()->showSettingsWnd();
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
    });
    return true;
}

void NESettingsServiceProcHandlerIMP::onShowMyMeetingElapseTime(bool show, const NS_I_NEM_SDK::NEEmptyCallback& cb) {
    YXLOG_API(Info) << "Received onShowMyMeetingElapseTime: " << show << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        MeetingManager::getInstance()->setShowMeetingDuration(show);
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
    });
}

void NESettingsServiceProcHandlerIMP::onIsShowMyMeetingElapseTimeEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onIsShowMyMeetingElapseTimeEnabled." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() { cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", MeetingManager::getInstance()->showMeetingDuration()); });
}

void NESettingsServiceProcHandlerIMP::onEnableBeauty(bool enable, const nem_sdk_interface::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onEnableBeauty, enable: " << enable << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        if (GlobalManager::getInstance()->getGlobalConfig()->isBeautySupported() == false) {
            cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, "not support beauty", false);
        } else {
            ConfigManager::getInstance()->setValue("enableBeauty", enable);
            SettingsManager::getInstance()->setEnableFaceBeauty(enable);
            cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", true);
        }
    });
}

void NESettingsServiceProcHandlerIMP::onIsBeautyEnabled(const nem_sdk_interface::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onIsBeautyEnabled." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        if (GlobalManager::getInstance()->getGlobalConfig()->isBeautySupported() == false) {
            cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, "not support beauty", false);
        } else {
            auto beautyEnabled = SettingsManager::getInstance()->getEnableBeauty();
            cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", beautyEnabled);
        }
    });
}

void NESettingsServiceProcHandlerIMP::onSetBeautyValue(int value, const nem_sdk_interface::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onSetBeautyValue, value: " << value << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        if (GlobalManager::getInstance()->getGlobalConfig()->isBeautySupported() == false) {
            cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, "not support beauty", false);
        } else {
            SettingsManager::getInstance()->setFaceBeautyLevel(value);
            cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", value);
        }
    });
}

void NESettingsServiceProcHandlerIMP::onGetBeautyValue(const nem_sdk_interface::NESettingsService::NEIntCallback& cb) {
    YXLOG_API(Info) << "Received onGetBeautyValue." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        if (GlobalManager::getInstance()->getGlobalConfig()->isBeautySupported() == false) {
            cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, "not support beauty", 0);
        } else {
            SettingsManager::getInstance()->initFaceBeautyLevel();
            auto value = SettingsManager::getInstance()->faceBeautyLevel();
            cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", value < 0 ? 0 : value);
        }
    });
}

void NESettingsServiceProcHandlerIMP::onIsLiveEnabled(const nem_sdk_interface::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onIsLiveEnabled." << YXLOGEnd;
    if (GlobalManager::getInstance()->getGlobalConfig()->isLiveStreamSupported() == false) {
        cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, "not support live", false);
    } else {
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", true);
    }
}

void NESettingsServiceProcHandlerIMP::onGetHistoryMeeting(const nem_sdk_interface::NESettingsService::NEHistoryMeetingCallback& cb) {
    YXLOG_API(Info) << "Received onGetHistoryMeeting." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        NS_I_NEM_SDK::NEHistoryMeetingItem item;
        item.meetingNum = ConfigManager::getInstance()->getValue("localLastConferenceId", "").toString().toStdString();
        item.meetingId = ConfigManager::getInstance()->getValue("localLastMeetingUniqueId", "").toString().toLong();
        item.nickname = ConfigManager::getInstance()->getValue("localLastNickname", "").toString().toStdString();
        item.subject = ConfigManager::getInstance()->getValue("localLastMeetingTopic", "").toString().toStdString();
        item.password = ConfigManager::getInstance()->getValue("localLastMeetingPassword", "").toString().toStdString();
        item.shortMeetingNum = ConfigManager::getInstance()->getValue("localLastMeetingshortId", "").toString().toStdString();
        item.sipId = ConfigManager::getInstance()->getValue("localLastSipId", "").toString().toStdString();
        std::list<NS_I_NEM_SDK::NEHistoryMeetingItem> list;
        list.push_back(item);
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", list);
    });
}

void NESettingsServiceProcHandlerIMP::onIsWhiteboardEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onIsWhiteboardEnabled." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        if (GlobalManager::getInstance()->getGlobalConfig()->isWhiteboardSupported() == false) {
            cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, "not support whiteboard", false);
        } else {
            cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", true);
        }
    });
}

void NESettingsServiceProcHandlerIMP::onIsCloudRecordEnabled(const nem_sdk_interface::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onIsRecordEnabled." << YXLOGEnd;
    if (GlobalManager::getInstance()->getGlobalConfig()->isCloudRecordSupported() == false) {
        cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, "not support record", false);
    } else {
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", true);
    }
}

void NESettingsServiceProcHandlerIMP::onSetTurnOnMyVideoWhenJoinMeeting(bool bOn, const NS_I_NEM_SDK::NEEmptyCallback& cb) {
    YXLOG_API(Info) << "Received onSetTurnOnMyVideoWhenJoinMeeting: " << bOn << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
        SettingsManager::getInstance()->setEnableVideoAfterJoin(bOn);
    });
}

void NESettingsServiceProcHandlerIMP::onIsTurnOnMyVideoWhenJoinMeetingEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onSetTurnOnMyVideoWhenJoinMeeting." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() { cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", SettingsManager::getInstance()->enableVideoAfterJoin()); });
}

void NESettingsServiceProcHandlerIMP::onSetTurnOnMyAudioWhenJoinMeeting(bool bOn, const NS_I_NEM_SDK::NEEmptyCallback& cb) {
    YXLOG_API(Info) << "Received onSetTurnOnMyAudioWhenJoinMeeting: " << bOn << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
        SettingsManager::getInstance()->setEnableAudioAfterJoin(bOn);
    });
}

void NESettingsServiceProcHandlerIMP::onIsTurnOnMyAudioWhenJoinMeetingEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onIsTurnOnMyAudioWhenJoinMeetingEnabled." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() { cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", SettingsManager::getInstance()->enableAudioAfterJoin()); });
}

void NESettingsServiceProcHandlerIMP::onSetTurnOnMyAudioAINSWhenInMeeting(bool bOn, const NS_I_NEM_SDK::NEEmptyCallback& cb) {
    YXLOG_API(Info) << "Received onSetTurnOnMyAudioAINSWhenInMeeting: " << bOn << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        if (0 == SettingsManager::getInstance()->audioProfile()) {
            cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
            SettingsManager::getInstance()->setEnableAudioAINS(bOn);
        } else {
            cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, tr("AudioQuality not is AudioQuality_Talk").toStdString());
        }
    });
}

void NESettingsServiceProcHandlerIMP::onIsTurnOnMyAudioAINSWhenInMeetingEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onIsTurnOnMyAudioAINSWhenInMeetingEnabled." << YXLOGEnd;
    cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", SettingsManager::getInstance()->enableAudioAINS());
}

void NESettingsServiceProcHandlerIMP::onSetRemoteVideoResolution(NS_I_NEM_SDK::RemoteVideoResolution enumRemoteVideoResolution,
                                                                 const NS_I_NEM_SDK::NEEmptyCallback& cb) {
    YXLOG_API(Info) << "Received onSetRemoteVideoResolution: " << (int)enumRemoteVideoResolution << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
        SettingsManager::getInstance()->setRemoteVideoResolution(NS_I_NEM_SDK::RemoteVideoResolution_HD == enumRemoteVideoResolution);
    });
}

void NESettingsServiceProcHandlerIMP::onGetRemoteVideoResolution(const NS_I_NEM_SDK::NESettingsService::NERemoteVideoResolutionCallback& cb) {
    YXLOG_API(Info) << "Received onGetRemoteVideoResolution." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "",
           SettingsManager::getInstance()->remoteVideoResolution() ? NS_I_NEM_SDK::RemoteVideoResolution_HD
                                                                   : NS_I_NEM_SDK::RemoteVideoResolution_Default);
    });
}

void NESettingsServiceProcHandlerIMP::onSetMyVideoResolution(NS_I_NEM_SDK::LocalVideoResolution enumLocalVideoResolution,
                                                             const NS_I_NEM_SDK::NEEmptyCallback& cb) {
    YXLOG_API(Info) << "Received onSetMyVideoResolution: " << (int)enumLocalVideoResolution << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
        SettingsManager::getInstance()->setLocalVideoResolution((SettingsManager::VideoResolution)enumLocalVideoResolution);
    });
}

void NESettingsServiceProcHandlerIMP::onGetMyVideoResolution(const NS_I_NEM_SDK::NESettingsService::NELocalVideoResolutionCallback& cb) {
    YXLOG_API(Info) << "Received onGetMyVideoResolution." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", (NS_I_NEM_SDK::LocalVideoResolution)SettingsManager::getInstance()->localVideoResolution());
    });
}

void NESettingsServiceProcHandlerIMP::onSetMyVideoFramerate(NS_I_NEM_SDK::LocalVideoFramerate enumLocalVideoFramerate,
                                                            const NS_I_NEM_SDK::NEEmptyCallback& cb) {
    YXLOG_API(Info) << "Received onSetMyVideoFramerate: " << (int)enumLocalVideoFramerate << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
        SettingsManager::getInstance()->setLocalVideoFramerate((neroom::NEVideoFramerate)enumLocalVideoFramerate);
    });
}

void NESettingsServiceProcHandlerIMP::onSetMyAudioVolumeAutoAdjust(bool bOn, const NS_I_NEM_SDK::NEEmptyCallback& cb) {
    YXLOG_API(Info) << "Received onSetMyAudioVolumeAutoAdjust: " << bOn << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
        SettingsManager::getInstance()->setEnableMicVolumeAutoAdjust(bOn);
    });
}

void NESettingsServiceProcHandlerIMP::onIsMyAudioVolumeAutoAdjust(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onIsMyAudioVolumeAutoAdjust." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() { cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", SettingsManager::getInstance()->enableMicVolumeAutoAdjust()); });
}

void NESettingsServiceProcHandlerIMP::onSetMyAudioQuality(NS_I_NEM_SDK::AudioQuality enumAudioQuality, const NS_I_NEM_SDK::NEEmptyCallback& cb) {
    YXLOG_API(Info) << "Received onSetMyAudioQuality: " << (int)enumAudioQuality << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        auto meetingStatus = MeetingManager::getInstance()->getRoomStatus();
        if (NEMeeting::MEETING_IDLE != meetingStatus) {
            if (cb) {
                cb(NS_I_NEM_SDK::MEETING_ERROR_ALREADY_INMEETING, tr("The last meeting is not end yet.").toStdString());
            }
            return;
        }

        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
        SettingsManager::getInstance()->setAudioProfile(NS_I_NEM_SDK::AudioQuality_Music == enumAudioQuality ? 1 : 0);
    });
}

void NESettingsServiceProcHandlerIMP::onGetMyAudioQuality(const NS_I_NEM_SDK::NESettingsService::NEAudioQualityCallback& cb) {
    YXLOG_API(Info) << "Received onGetMyAudioQuality." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "",
           1 == SettingsManager::getInstance()->audioProfile() ? NS_I_NEM_SDK::AudioQuality_Music : NS_I_NEM_SDK::AudioQuality_Talk);
    });
}

void NESettingsServiceProcHandlerIMP::onSetMyAudioEchoCancellation(bool bOn, const NS_I_NEM_SDK::NEEmptyCallback& cb) {
    YXLOG_API(Info) << "Received onSetMyAudioEchoCancellation: " << bOn << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        if (1 == SettingsManager::getInstance()->audioProfile()) {
            cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
            SettingsManager::getInstance()->setEnableAudioEchoCancellation(bOn);
        } else {
            cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, tr("AudioQuality not is AudioQuality_Music").toStdString());
        }
    });
}

void NESettingsServiceProcHandlerIMP::onIsMyAudioEchoCancellation(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onIsMyAudioEchoCancellation." << YXLOGEnd;
    Invoker::getInstance()->execute(
        [=]() { cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", SettingsManager::getInstance()->enableAudioEchoCancellation()); });
}

void NESettingsServiceProcHandlerIMP::onSetMyAudioEnableStereo(bool bOn, const NS_I_NEM_SDK::NEEmptyCallback& cb) {
    YXLOG_API(Info) << "Received onSetMyAudioEnableStereo: " << bOn << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        auto meetingStatus = MeetingManager::getInstance()->getRoomStatus();
        if (NEMeeting::MEETING_IDLE != meetingStatus) {
            if (cb) {
                cb(NS_I_NEM_SDK::MEETING_ERROR_ALREADY_INMEETING, tr("The last meeting is not end yet.").toStdString());
            }
            return;
        }

        if (1 == SettingsManager::getInstance()->audioProfile()) {
            cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
            SettingsManager::getInstance()->setEnableAudioStereo(bOn);
        } else {
            cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, tr("AudioQuality not is AudioQuality_Music").toStdString());
        }
    });
}

void NESettingsServiceProcHandlerIMP::onIsMyAudioEnableStereo(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onIsMyAudioEnableStereo." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() { cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", SettingsManager::getInstance()->enableAudioStereo()); });
}

void NESettingsServiceProcHandlerIMP::onSetMyAudioDeviceAutoSelectType(NS_I_NEM_SDK::AudioDeviceAutoSelectType enumAudioDeviceAutoSelectType,
                                                                       const NS_I_NEM_SDK::NEEmptyCallback& cb) {
    YXLOG_API(Info) << "Received onSetMyAudioDeviceAutoSelectType: " << (int)enumAudioDeviceAutoSelectType << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
        SettingsManager::getInstance()->setAudioDeviceAutoSelectType((neroom::NEAudioDeviceAutoSelectType)enumAudioDeviceAutoSelectType);
    });
}

void NESettingsServiceProcHandlerIMP::onIsMyAudioDeviceAutoSelectType(const NS_I_NEM_SDK::NESettingsService::AudioDeviceAutoSelectTypeCallback& cb) {
    YXLOG_API(Info) << "Received onIsMyAudioDeviceAutoSelectType." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "",
           (NS_I_NEM_SDK::AudioDeviceAutoSelectType)SettingsManager::getInstance()->audioDeviceAutoSelectType());
    });
}

void NESettingsServiceProcHandlerIMP::onSetMyAudioDeviceUseLastSelected(bool bOn, const NS_I_NEM_SDK::NEEmptyCallback& cb) {
    YXLOG_API(Info) << "Received onSetMyAudioDeviceUseLastSelected, bOn: " << bOn << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
        SettingsManager::getInstance()->setAudioDeviceUseLastSelected(bOn);
        if (!bOn) {
            SettingsManager::getInstance()->setAudioRecordDeviceUseLastSelected("");
            SettingsManager::getInstance()->setAudioPlayoutDeviceUseLastSelected("");
        }
    });
}

void NESettingsServiceProcHandlerIMP::onIsMyAudioDeviceUseLastSelected(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onIsMyAudioDeviceUseLastSelected." << YXLOGEnd;
    Invoker::getInstance()->execute(
        [=]() { cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", SettingsManager::getInstance()->audioDeviceUseLastSelected()); });
}

void NESettingsServiceProcHandlerIMP::onEnableVirtualBackground(bool enable, const NS_I_NEM_SDK::NEEmptyCallback& cb) {
    YXLOG_API(Info) << "Received onEnableVirtualBackground: " << enable << YXLOGEnd;
    if (!GlobalManager::getInstance()->getGlobalConfig()->isVBSupported()) {
        if (cb) {
            cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, "not support virtualbackground");
        }
    } else {
        if (cb) {
            cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
        }
        Invoker::getInstance()->execute([=]() { SettingsManager::getInstance()->setShowVirtualBackground(enable); });
    }
}

void NESettingsServiceProcHandlerIMP::onIsVirtualBackgroundEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onIsVirtualBackgroundEnabled." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        if (!GlobalManager::getInstance()->getGlobalConfig()->isVBSupported()) {
            if (cb) {
                cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, "not support virtualbackground", false);
            }
        } else {
            if (cb) {
                cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", SettingsManager::getInstance()->showVirtualBackground());
            }
        }
    });
}

void NESettingsServiceProcHandlerIMP::onGetBuiltinVirtualBackgrounds(const NS_I_NEM_SDK::NESettingsService::NEVirtualBackgroundCallback& cb) {
    YXLOG_API(Info) << "Received onGetBuiltinVirtualBackgrounds. " << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        if (!GlobalManager::getInstance()->getGlobalConfig()->isVBSupported()) {
            if (cb) {
                cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, "not support virtualbackground", std::vector<NEMeetingVirtualBackground>{});
            }
        } else {
            if (cb) {
                std::vector<VirtualBackgroundModel::VBProperty> tmp = SettingsManager::getInstance()->getBuildInVirtualBackground();
                std::vector<NEMeetingVirtualBackground> virtualBackgrounds;
                std::transform(tmp.begin(), tmp.end(), std::back_inserter(virtualBackgrounds), [](const auto& it) {
                    NEMeetingVirtualBackground vb;
                    vb.path = it.strPath.toStdString();
                    return vb;
                });
                cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", virtualBackgrounds);
            }
        }
    });
}

void NESettingsServiceProcHandlerIMP::onSetBuiltinVirtualBackgrounds(const std::vector<NS_I_NEM_SDK::NEMeetingVirtualBackground>& virtualBackgrounds,
                                                                     const NS_I_NEM_SDK::NEEmptyCallback& cb) {
    std::string strPath;
    for (auto& it : virtualBackgrounds) {
        strPath.append(it.path);
        strPath.append(";");
    }
    YXLOG_API(Info) << "Received onSetBuiltinVirtualBackgrounds, list: " << strPath << YXLOGEnd;
    if (!GlobalManager::getInstance()->getGlobalConfig()->isVBSupported()) {
        if (cb) {
            cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, "not support virtualbackground");
        }
    } else {
        bool bSupported = true;
        for (auto& it : virtualBackgrounds) {
            QString fileName = QString::fromStdString(it.path);
            if (fileName.isEmpty()) {
                continue;
            }
            fileName = fileName.toLower();
            if (fileName.endsWith(".png") || fileName.endsWith(".jpg")) {
            } else {
                bSupported = false;
                break;
            }
        }
        if (!bSupported) {
            if (cb) {
                cb(NS_I_NEM_SDK::MEETING_ERROR_FAILED_PARAM_ERROR, tr("Background image format not supported.").toStdString());
            }
            return;
        }
        if (cb) {
            cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
        }
        Invoker::getInstance()->execute([=]() {
            std::vector<VirtualBackgroundModel::VBProperty> vbList;
            std::transform(virtualBackgrounds.begin(), virtualBackgrounds.end(), std::back_inserter(vbList), [](const auto& it) {
                QString strFilePathTmp = QString::fromStdString(it.path);
#ifdef Q_OS_WIN
                strFilePathTmp.replace("\\", "/");
#endif
                return VirtualBackgroundModel::VBProperty{strFilePathTmp, false, false};
            });

            SettingsManager::getInstance()->initVirtualBackground(vbList);
        });
    }
}

void NESettingsServiceProcHandlerIMP::onEnableUnmuteBySpace(bool enable, const NS_I_NEM_SDK::NEEmptyCallback& cb) {
    YXLOG_API(Info) << "Received onEnableUnmuteBySpace. enable: " << enable << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        SettingsManager::getInstance()->setEnableUnmuteBySpace(enable);
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
    });
}

void NESettingsServiceProcHandlerIMP::onIsUnmuteBySpaceEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onIsUnmuteBySpaceEnabled." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() { cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", SettingsManager::getInstance()->enableUnmuteBySpace()); });
}
