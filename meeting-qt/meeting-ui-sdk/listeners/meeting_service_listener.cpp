// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "meeting_service_listener.h"
#include "manager/chat_manager.h"
#include "manager/device_manager.h"
#include "manager/live_manager.h"
#include "manager/meeting/audio_manager.h"
#include "manager/meeting/invite_manager.h"
#include "manager/meeting/members_manager.h"
#include "manager/meeting/share_manager.h"
#include "manager/meeting/video_manager.h"
#include "manager/meeting/whiteboard_manager.h"
#include "manager/meeting_manager.h"
#include "manager/settings_manager.h"

NEInRoomServiceListener::NEInRoomServiceListener() {}

NEInRoomServiceListener::~NEInRoomServiceListener() {}

void NEInRoomServiceListener::onMemberRoleChanged(const std::string& userUuid, const std::string& beforeRole, const std::string& afterRole) {
    qInfo() << "userUuid: " << QString::fromStdString(userUuid) << "beforeRole: " << QString::fromStdString(beforeRole)
            << "afterRole: " << QString::fromStdString(afterRole);
    MembersManager::getInstance()->onRoleChanged(userUuid, beforeRole, afterRole);
}

void NEInRoomServiceListener::onMemberJoinRoom(const std::vector<SharedMemberPtr>& members) {
    if (members.size() > 0) {
        auto member = members[0];
        YXLOG(Info) << "onMemberJoinRoom, userUuid: " << member->getUserUuid() << YXLOGEnd;
        if (member->getUserUuid() == AuthManager::getInstance()->getAuthInfo().accountId) {
            MeetingManager::getInstance()->onConnected();
        } else {
            MembersManager::getInstance()->onUserJoined(member);
        }
    }
}

void NEInRoomServiceListener::onMemberLeaveRoom(const std::vector<SharedMemberPtr>& members) {
    if (members.size() > 0) {
        auto member = members[0];
        YXLOG(Info) << "onMemberLeaveRoom, userUuid: " << member->getUserUuid() << YXLOGEnd;
        if (member->getUserUuid() == AuthManager::getInstance()->getAuthInfo().accountId) {
            MeetingManager::getInstance()->onDisconnected(kNERoomEndReasonLeaveBySelf);
            return;
        }

        MembersManager::getInstance()->onUserLeft(member);
        if (m_activeSpeaker == member->getUserUuid()) {
            m_activeSpeaker.clear();
            AudioManager::getInstance()->onActiveSpeakerChanged("", "");
        }

        if (member && member->getUserUuid() != AuthManager::getInstance()->authAccountId().toStdString()) {
            AudioManager::getInstance()->onUserSpeakerChanged(std::list<std::string>{});
        }
    }
}

void NEInRoomServiceListener::onRoomEnded(NERoomEndReason reason) {
    YXLOG(Info) << "onRoomEnded, reason: " << reason << YXLOGEnd;
    MeetingManager::getInstance()->onDisconnected(reason);
}

void NEInRoomServiceListener::onMemberJoinRtcChannel(const std::vector<SharedMemberPtr>& members) {
    if (members.size() > 0) {
        auto member = members[0];
        YXLOG(Info) << "onMemberJoinRtcChannel, userUuid: " << member->getUserUuid() << YXLOGEnd;
        if (member->getUserUuid() == AuthManager::getInstance()->getAuthInfo().accountId) {
            MeetingManager::getInstance()->onConnected();
        } else {
            // MembersManager::getInstance()->onUserJoined(member);
        }
    }
}

void NEInRoomServiceListener::onMemberLeaveRtcChannel(const std::vector<SharedMemberPtr>& members) {
    if (members.size() > 0) {
        auto member = members[0];
        YXLOG(Info) << "onMemberLeaveRtcChannel, userUuid: " << member->getUserUuid() << YXLOGEnd;
        MembersManager::getInstance()->onUserLeft(member);
    }
}

void NEInRoomServiceListener::onMemberJoinChatroom(const std::vector<SharedMemberPtr>& members) {}

void NEInRoomServiceListener::onMemberLeaveChatroom(const std::vector<SharedMemberPtr>& members) {}

void NEInRoomServiceListener::onMemberAudioMuteChanged(const SharedMemberPtr& member, bool mute, const SharedMemberPtr& trigger) {
    NEMeeting::DeviceStatus status = NEMeeting::DEVICE_DISABLED_BY_DELF;
    if (mute && trigger &&
        (trigger->getUserUuid() == MembersManager::getInstance()->hostAccountId().toStdString() ||
         MembersManager::getInstance()->isManagerRoleEx(QString::fromStdString(trigger->getUserUuid()))) &&
        member->getUserUuid() == AuthManager::getInstance()->authAccountId().toStdString() &&
        trigger->getUserUuid() != AuthManager::getInstance()->authAccountId().toStdString()) {
        status = NEMeeting::DEVICE_DISABLED_BY_HOST;
    }
    AudioManager::getInstance()->onUserAudioStatusChanged(member->getUserUuid(), !mute ? NEMeeting::DEVICE_ENABLED : status);
    if (mute && m_activeSpeaker == member->getUserUuid()) {
        m_activeSpeaker.clear();
        AudioManager::getInstance()->onActiveSpeakerChanged("", "");
    }

    if (member && !member->getIsAudioOn() && member->getUserUuid() != AuthManager::getInstance()->authAccountId().toStdString()) {
        AudioManager::getInstance()->onUserSpeakerChanged(std::list<std::string>{});
    }
}

void NEInRoomServiceListener::onMemberVideoMuteChanged(const SharedMemberPtr& member, bool mute, const SharedMemberPtr& trigger) {
    NEMeeting::DeviceStatus status = NEMeeting::DEVICE_DISABLED_BY_DELF;
    if (mute && trigger &&
        (trigger->getUserUuid() == MembersManager::getInstance()->hostAccountId().toStdString() ||
         MembersManager::getInstance()->isManagerRoleEx(QString::fromStdString(trigger->getUserUuid()))) &&
        member->getUserUuid() == AuthManager::getInstance()->authAccountId().toStdString() &&
        trigger->getUserUuid() != AuthManager::getInstance()->authAccountId().toStdString()) {
        status = NEMeeting::DEVICE_DISABLED_BY_HOST;
    }
    VideoManager::getInstance()->onUserVideoStatusChanged(member->getUserUuid(), !mute ? NEMeeting::DEVICE_ENABLED : status);
}

void NEInRoomServiceListener::onMemberScreenShareStateChanged(const SharedMemberPtr& member, bool isSharing, const SharedMemberPtr& trigger) {
    Invoker::getInstance()->execute([=]() {
        YXLOG(Info) << "onMemberScreenShareStateChanged, isSharing: " << isSharing << ", userUuid: " << member->getUserUuid() << YXLOGEnd;
        NERoomScreenShareStatus status = kNERoomScreenShareStatusEnd;
        if (!isSharing && trigger &&
            (trigger->getUserUuid() == MembersManager::getInstance()->hostAccountId().toStdString() ||
             MembersManager::getInstance()->isManagerRoleEx(QString::fromStdString(trigger->getUserUuid()))) &&
            member->getUserUuid() == AuthManager::getInstance()->authAccountId().toStdString() &&
            trigger->getUserUuid() != AuthManager::getInstance()->authAccountId().toStdString()) {
            status = kNERoomScreenShareStopByHost;
        } else if (isSharing && WhiteboardManager::getInstance()->whiteboardSharing() && member &&
                   member->getUserUuid() == AuthManager::getInstance()->authAccountId().toStdString()) {
            ShareManager::getInstance()->stopScreenSharing(AuthManager::getInstance()->authAccountId());
            return;
        }

        ShareManager::getInstance()->onRoomUserScreenShareStatusChanged(member->getUserUuid(), isSharing ? kNERoomScreenShareStatusStart : status);
        if (!isSharing && WhiteboardManager::getInstance()->whiteboardSharing()) {
            WhiteboardManager::getInstance()->whiteboardSharingChanged();
            WhiteboardManager::getInstance()->whiteboardSharerAccountIdChanged();
        }
    });
}

void NEInRoomServiceListener::onMemberWhiteboardStateChanged(const SharedMemberPtr& member, bool isSharing, const SharedMemberPtr& trigger) {
    Invoker::getInstance()->execute([=]() {
        YXLOG(Info) << "onMemberWhiteboardStateChanged, isSharing: " << isSharing << ", userUuid: " << member->getUserUuid() << YXLOGEnd;
        NERoomWhiteboardShareStatus status = kNERoomWhiteboardShareStatusEnd;
        if (!isSharing && trigger &&
            (trigger->getUserUuid() == MembersManager::getInstance()->hostAccountId().toStdString() ||
             MembersManager::getInstance()->isManagerRoleEx(QString::fromStdString(trigger->getUserUuid()))) &&
            member->getUserUuid() == AuthManager::getInstance()->authAccountId().toStdString() &&
            trigger->getUserUuid() != AuthManager::getInstance()->authAccountId().toStdString()) {
            status = kNERoomWhiteboardShareStatusStopByHost;
        } else if (isSharing && !ShareManager::getInstance()->shareAccountId().isEmpty() && member &&
                   member->getUserUuid() == AuthManager::getInstance()->authAccountId().toStdString()) {
            WhiteboardManager::getInstance()->closeWhiteboard(AuthManager::getInstance()->authAccountId());
            WhiteboardManager::getInstance()->initWhiteboardStatus();
            return;
        }

        WhiteboardManager::getInstance()->onRoomUserWhiteboardShareStatusChanged(member->getUserUuid(),
                                                                                 isSharing ? kNERoomWhiteboardShareStatusStart : status);
        if (!isSharing && !ShareManager::getInstance()->shareAccountId().isEmpty()) {
            ShareManager::getInstance()->shareAccountIdChanged();
            ShareManager::getInstance()->sharingStatusChaged(ShareManager::getInstance()->shareAccountId(), true);
        }
    });
}

void NEInRoomServiceListener::onReceiveChatroomMessages(const std::vector<SharedChatMessagePtr>& messages) {
    ChatManager::getInstance()->onRecvMsgCallback(messages);
}

void NEInRoomServiceListener::onChatroomMessageAttachmentProgress(const std::string& messageUuid, int64_t transferred, int64_t total) {
    ChatManager::getInstance()->onAttahmentProgressCallback(messageUuid, transferred, total);
}

void NEInRoomServiceListener::onRtcChannelError(int code, const std::string& msg) {
    YXLOG(Error) << "onRtcChannelError, code: " << code << ", msg: " << msg << YXLOGEnd;
}

void NEInRoomServiceListener::onMemberPropertiesChanged(const std::string& userUuid, const std::map<std::string, std::string>& properties) {
    for (auto property : properties) {
        if (property.first == "wbDrawable") {
            bool enable = property.second == "1";
            WhiteboardManager::getInstance()->onRoomUserWhiteboardDrawEnableStatusChanged(userUuid, enable);
        }
        if (property.first == "handsUp") {
            auto value = property.second;
            NEMeeting::HandsUpStatus status = NEMeeting::HAND_STATUS_RAISE;
            if (value == "0") {
                status = NEMeeting::HAND_STATUS_DOWN;
            } else if (value == "1") {
                status = NEMeeting::HAND_STATUS_RAISE;
            } else if (value == "2") {
                status = NEMeeting::HAND_STATUS_REJECT;
            }
            MembersManager::getInstance()->onHandsUpStatusChanged(userUuid, status);
        }
    }
}

void NEInRoomServiceListener::onRoomPropertiesChanged(const std::map<std::string, std::string>& properties) {
    std::string propertie;
    for (auto& it : properties) {
        propertie.append(it.first).append(": ").append(it.second).append(", ");
    }
    if (!propertie.empty()) {
        propertie = propertie.substr(0, propertie.length() - 2);
    }
    YXLOG(Info) << "onRoomPropertiesChanged, properties: " << propertie << YXLOGEnd;
    for (auto property : properties) {
        std::string key = property.first;
        if (key == "focus") {
            std::string value = property.second;
            MeetingManager::getInstance()->getMeetingController()->updateFocusAccountId(value);
            VideoManager::getInstance()->onFocusVideoChanged(value, !value.empty());
        } else if (key == "audioOff" || key == "videoOff") {
            QString value = QString::fromStdString(property.second);
            QString type = value.left(value.indexOf("_"));
            bool isHost = MeetingManager::getInstance()->getMeetingInfo().hostAccountId == AuthManager::getInstance()->getAuthInfo().accountId;
            bool isManager =
                MembersManager::getInstance()->isManagerRoleEx(QString::fromStdString(AuthManager::getInstance()->getAuthInfo().accountId));
            if (type == "offAllowSelfOn") {
                //全体静音/关闭视频，允许自行解除
                if (key == "audioOff") {
                    //关闭本地音频
                    if (!isHost && !isManager) {
                        AudioManager::getInstance()->muteLocalAudio(true);
                        //设置全体静音状态
                        MeetingManager::getInstance()->onRoomMuteStatusChanged(true);
                    }
                    //更新是否需要举手状态
                    MeetingManager::getInstance()->onRoomMuteNeedHandsUpChanged(false);
                    MeetingManager::getInstance()->getMeetingController()->updateAudioAllMute(true);
                    MeetingManager::getInstance()->getMeetingController()->updateAllowSelfAudioOn(true);

                } else if (key == "videoOff") {
                    //关闭本地视频
                    if (!isHost && !isManager) {
                        VideoManager::getInstance()->disableLocalVideo(true);
                        //设置全体视频关闭状态
                        MeetingManager::getInstance()->onRoomMuteAllVideoStatusChanged(true);
                    }
                    //更新是否需要举手状态
                    MeetingManager::getInstance()->onRoomMuteVideoNeedHandsUpChanged(false);
                    MeetingManager::getInstance()->getMeetingController()->updateVideoAllmute(true);
                    MeetingManager::getInstance()->getMeetingController()->updateAllowSelfVideoOn(true);
                }
                //取消举手状态
                if (MembersManager::getInstance()->handsUpStatus()) {
                    MembersManager::getInstance()->handsUp(false);
                }
            } else if (type == "offNotAllowSelfOn") {
                //全体静音/关闭视频，不允许自行解除
                if (key == "audioOff") {
                    //关闭本地音频
                    if (!isHost && !isManager) {
                        AudioManager::getInstance()->muteLocalAudio(true);
                        //设置全体静音状态
                        MeetingManager::getInstance()->onRoomMuteStatusChanged(true);
                        AudioManager::getInstance()->onUserAudioStatusChangedUI(AuthManager::getInstance()->authAccountId(),
                                                                                NEMeeting::DEVICE_DISABLED_BY_DELF);
                    }
                    //更新是否需要举手状态
                    MeetingManager::getInstance()->onRoomMuteNeedHandsUpChanged(true);
                    MeetingManager::getInstance()->getMeetingController()->updateAudioAllMute(true);
                    MeetingManager::getInstance()->getMeetingController()->updateAllowSelfAudioOn(false);
                } else if (key == "videoOff") {
                    //关闭本地视频
                    if (!isHost && !isManager) {
                        VideoManager::getInstance()->disableLocalVideo(true);
                        //设置全体视频关闭状态
                        MeetingManager::getInstance()->onRoomMuteAllVideoStatusChanged(true);
                        VideoManager::getInstance()->onUserVideoStatusChangedUI(AuthManager::getInstance()->authAccountId(),
                                                                                NEMeeting::DEVICE_DISABLED_BY_DELF);
                    }

                    //更新是否需要举手状态
                    MeetingManager::getInstance()->onRoomMuteVideoNeedHandsUpChanged(true);
                    MeetingManager::getInstance()->getMeetingController()->updateVideoAllmute(true);
                    MeetingManager::getInstance()->getMeetingController()->updateAllowSelfVideoOn(false);
                }

            } else if (type == "disable") {
                //取消全体静音/关闭视频
                if (key == "audioOff") {
                    //更新是否需要举手状态
                    MeetingManager::getInstance()->onRoomMuteNeedHandsUpChanged(false);
                    MeetingManager::getInstance()->getMeetingController()->updateAudioAllMute(false);
                    MeetingManager::getInstance()->getMeetingController()->updateAllowSelfAudioOn(true);
                } else if (key == "videoOff") {
                    //更新是否需要举手状态
                    MeetingManager::getInstance()->onRoomMuteVideoNeedHandsUpChanged(false);
                    MeetingManager::getInstance()->getMeetingController()->updateVideoAllmute(false);
                    MeetingManager::getInstance()->getMeetingController()->updateAllowSelfVideoOn(true);
                }

                if (!isHost && !isManager) {
                    if (key == "audioOff") {
                        MeetingManager::getInstance()->onRoomMuteStatusChanged(false);
                    } else if (key == "videoOff") {
                        MeetingManager::getInstance()->onRoomMuteAllVideoStatusChanged(false);
                    }

                    if (MembersManager::getInstance()->handsUpStatus()) {
                        //取消举手状态
                        MembersManager::getInstance()->handsUp(false);
                        //已经举手，直接打开音视频
                        if (key == "audioOff") {
                            AudioManager::getInstance()->muteLocalAudio(false);
                        } else if (key == "videoOff") {
                            if (VideoManager::getInstance()->localVideoStatus() != NEMeeting::DEVICE_ENABLED) {
                                VideoManager::getInstance()->onUserVideoStatusChanged(AuthManager::getInstance()->getAuthInfo().accountId,
                                                                                      NEMeeting::DEVICE_NEEDS_TO_CONFIRM);
                            }
                        }
                    } else {
                        if (key == "audioOff") {
                            if (AudioManager::getInstance()->localAudioStatus() != NEMeeting::DEVICE_ENABLED) {
                                YXLOG(Info) << "onUserAudioStatusChanged, DEVICE_NEEDS_TO_CONFIRM" << YXLOGEnd;
                                AudioManager::getInstance()->onUserAudioStatusChanged(AuthManager::getInstance()->getAuthInfo().accountId,
                                                                                      NEMeeting::DEVICE_NEEDS_TO_CONFIRM);
                            }
                        } else if (key == "videoOff") {
                            if (VideoManager::getInstance()->localVideoStatus() != NEMeeting::DEVICE_ENABLED) {
                                YXLOG(Info) << "onUserVideoStatusChanged, DEVICE_NEEDS_TO_CONFIRM" << YXLOGEnd;
                                VideoManager::getInstance()->onUserVideoStatusChanged(AuthManager::getInstance()->getAuthInfo().accountId,
                                                                                      NEMeeting::DEVICE_NEEDS_TO_CONFIRM);
                            }
                        }
                    }
                }
            }
        }
    }
}

void NEInRoomServiceListener::onVideoFrameData(const std::string& userUuid,
                                               bool bSubVideo,
                                               void* data,
                                               uint32_t type,
                                               uint32_t width,
                                               uint32_t height,
                                               uint32_t count,
                                               uint32_t offset[4],
                                               uint32_t stride[4],
                                               uint32_t rotation) {
    VideoFrame frame;
    frame.type = type;
    frame.width = width;
    frame.height = height;
    frame.count = count;
    frame.rotation = rotation;
    frame.offset = offset;
    frame.stride = stride;
    frame.data = data;

    VideoManager::getInstance()->onReceivedUserVideoFrame(userUuid, frame, bSubVideo);
}

void NEInRoomServiceListener::onRoomLiveStateChanged(NERoomLiveState state) {
    LiveManager::getInstance()->onLiveStreamStatusChanged(state);
}

void NEInRoomServiceListener::onMemberNameChanged(const SharedMemberPtr& member, const std::string& name) {
    MembersManager::getInstance()->onMemberNicknameChanged(member->getUserUuid(), name);
}

void NEInRoomServiceListener::onRoomLockStateChanged(bool locked) {
    MeetingManager::getInstance()->onRoomLockStatusChanged(locked);
}

void NEInRoomServiceListener::onRtcVirtualBackgroundSourceEnabled(bool enabled, NERoomVirtualBackgroundSourceStateReason reason) {
    Invoker::getInstance()->execute([=]() {
        QString reasonTmp;
        switch (reason) {
            case kNERoomVirtualBackgroundSourceStateReasonImageNotExist:
                reasonTmp = QObject::tr("Background image not exist.");
                break;
            case kNERoomVirtualBackgroundSourceStateReasonImageFormatNotSupported:
                reasonTmp = QObject::tr("Background image format not supported.");
                break;
            case kNERoomVirtualBackgroundSourceStateReasonColorFormatNotSupported:
                reasonTmp = QObject::tr("Background color format not supported.");
                break;
            case kNERoomVirtualBackgroundSourceStateReasonDeviceNotSupported:
                reasonTmp = QObject::tr("Device not supported.");
                break;
            default:
                break;
        }
        SettingsManager::getInstance()->virtualBackgroundChanged(enabled, reasonTmp);
    });
}

void NEInRoomServiceListener::onLocalAudioStats(const std::vector<NERoomRtcAudioSendStats>& stats) {}

void NEInRoomServiceListener::onRemoteAudioStats(const std::map<std::string, std::vector<NERoomRtcAudioRecvStats>>& stats) {
    std::vector<NEAudioStats> statsTmp;
    std::list<std::string> nickname;
    for (auto& it : stats) {
        if (!it.second.empty()) {
            MemberInfo memberInfo;
            if (!MembersManager::getInstance()->getMemberByAccountId(QString::fromStdString(it.first), memberInfo) ||
                NEMeeting::DEVICE_ENABLED != memberInfo.audioStatus) {
                continue;
            }

            NEAudioStats audioStats;
            audioStats.userUuid = it.first;
            audioStats.volume = it.second.at(0).volume;
            audioStats.bitRate = it.second.at(0).receivedBitRate;
            audioStats.lossRate = it.second.at(0).audioLossRate;
            statsTmp.emplace_back(audioStats);
            nickname.emplace_back(memberInfo.nickname.toStdString());
        }
    }
    if (!statsTmp.empty()) {
        AudioManager::getInstance()->onRemoteUserAudioStats(statsTmp);
    }

    activeSpeakerVideoUser(statsTmp);
    AudioManager::getInstance()->onUserSpeakerChanged(nickname);
}

void NEInRoomServiceListener::onRtcVideoStats(const std::vector<NEVideoStats>& stats) {
    std::vector<NEVideoStats> statsTmp;
    std::vector<NEVideoStats> statsTmpLocal;
    for (auto& it : stats) {
        if (it.userUuid == AuthManager::getInstance()->authAccountId().toStdString())
            statsTmpLocal.emplace_back(it);
        else
            statsTmp.emplace_back(it);
    }

    if (!statsTmpLocal.empty()) {
        VideoManager::getInstance()->onLocalUserVideoStats(statsTmpLocal);
    }
    if (!statsTmp.empty()) {
        VideoManager::getInstance()->onRemoteUserVideoStats(statsTmp);
    }
}

void NEInRoomServiceListener::onNetworkQuality(const std::vector<NERoomRtcNetworkQualityInfo>& quality) {
    for (auto& it : quality) {
        MembersManager::getInstance()->onNetworkQuality(it.userUuid, it.upStatus, it.downStatus);
    }
}

void NEInRoomServiceListener::onRtcUserVideoStart(const std::string& userUuid) {
    YXLOG(Info) << "onRtcUserVideoStart, userUuid: " << userUuid << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        auto subscribeHelper = MeetingManager::getInstance()->getSubscribeHelper();
        if (subscribeHelper) {
            subscribeHelper->updateVideoState(userUuid, true);
        }
    });
}

void NEInRoomServiceListener::onRtcUserVideoStop(const std::string& userUuid) {
    YXLOG(Info) << "onRtcUserVideoStop, userUuid: " << userUuid << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        auto subscribeHelper = MeetingManager::getInstance()->getSubscribeHelper();
        if (subscribeHelper) {
            subscribeHelper->updateVideoState(userUuid, false);
        }
    });
}

void NEInRoomServiceListener::onCameraDeviceChanged(const std::string& deviceId, bool bAdd) {
    auto videoCtr = VideoManager::getInstance()->getVideoController();
    if (!bAdd && videoCtr && videoCtr->getCameraCurDeviceId() == deviceId) {
        videoCtr->clearCameraCurDeviceId();
    }
    DeviceManager::getInstance()->onCameraDeviceChanged(deviceId, bAdd ? NEDeviceState::kDeviceAdded : NEDeviceState::kDeviceRemoved);
}

void NEInRoomServiceListener::onPlayoutDeviceChanged(const std::string& deviceId, bool bAdd) {
    DeviceManager::getInstance()->onPlayoutDeviceChanged(deviceId, bAdd ? NEDeviceState::kDeviceAdded : NEDeviceState::kDeviceRemoved);
}

void NEInRoomServiceListener::onRecordDeviceChanged(const std::string& deviceId, bool bAdd) {
    DeviceManager::getInstance()->onRecordDeviceChanged(deviceId, bAdd ? NEDeviceState::kDeviceAdded : NEDeviceState::kDeviceRemoved);
}

void NEInRoomServiceListener::onDefaultPlayoutDeviceChanged(const std::string& deviceId) {
    DeviceManager::getInstance()->onDefualtPlayoutDeviceChanged(deviceId);
}

void NEInRoomServiceListener::onDefaultRecordDeviceChanged(const std::string& deviceId) {
    DeviceManager::getInstance()->onDefualtRecordDeviceChanged(deviceId);
}

void NEInRoomServiceListener::onRoomConnectStateChanged(NEConnectState state) {
    if (state == kNEStateReConnecting) {
        MeetingManager::getInstance()->onReConnecting();
    } else if (state == kNEStateConnected) {
        MeetingManager::getInstance()->onReConnected();
    } else if (state == kNEStateDisConnected) {
        MeetingManager::getInstance()->onReConnectFail();
    }
}

void NEInRoomServiceListener::activeSpeakerVideoUser(const std::vector<NEAudioStats>& stats) {
    auto timestamp = std::chrono::time_point_cast<std::chrono::seconds>(std::chrono::system_clock::now());
    auto difference = timestamp.time_since_epoch().count() - m_nActiveSwitchTimestamp;

    auto config = GlobalManager::getInstance()->getGlobalConfig();
    if (nullptr == config) {
        return;
    }

    auto focusSwitchInterval = config->getFocusSwitchInterval();

    std::map<uint64_t, std::string> remoteUsers;
    for (uint32_t i = 0; i < stats.size(); i++) {
        auto& remoteUser = stats[i];
        if (remoteUser.volume > 10)
            remoteUsers[remoteUser.volume] = remoteUser.userUuid;
    }

    if (remoteUsers.size() == 0) {
        return;
    }

    if (difference < focusSwitchInterval)
        return;

    auto maxVolumeUid = remoteUsers.rbegin();
    if (maxVolumeUid->second == AuthManager::getInstance()->authAccountId().toStdString()) {
        return;
    }

    m_nActiveSwitchTimestamp = timestamp.time_since_epoch().count();
    m_activeSpeaker = maxVolumeUid->second;
    AudioManager::getInstance()->onActiveSpeakerChanged(
        m_activeSpeaker, MembersManager::getInstance()->getNicknameByAccountId(QString::fromStdString(m_activeSpeaker)).toStdString());
}

void NEInRoomServiceListener::onLocalAudioVolumeIndication(int volume) {
    DeviceManager::getInstance()->onLocalVolumeIndication(volume);
}

void NEInRoomServiceListener::onRtcRemoteAudioVolumeIndication(std::list<NEMemberVolumeInfo> volumeList, int totalVolume) {
    for (auto volumeInfo : volumeList) {
        DeviceManager::getInstance()->onRemoteVolumeIndication(volumeInfo.userUuid, volumeInfo.volume);
    }
}

void NEInRoomServiceListener::onRtcDisconnect() {
    Invoker::getInstance()->execute([=]() {
        MeetingManager::getInstance()->leaveMeeting(
            false, [](int code, const std::string& msg) { MeetingManager::getInstance()->onDisconnected(kNERoomEndReasonLeaveBySelf); });
    });
}

void NEInRoomServiceListener::onMemberPropertiesDeleted(const std::string& userUuid, const std::map<std::string, std::string>& propertie) {
    for (auto iter = propertie.begin(); iter != propertie.end(); iter++) {
        if (iter->first == "handsUp") {
            MembersManager::getInstance()->onHandsUpStatusChanged(userUuid, NEMeeting::HAND_STATUS_DOWN);
        } else if (iter->first == "wbDrawable") {
            WhiteboardManager::getInstance()->onRoomUserWhiteboardDrawEnableStatusChanged(userUuid, false);
        }
    }
}

void NEInRoomServiceListener::onRoomPropertiesDeleted(const std::map<std::string, std::string>& propertie) {
    for (auto iter = propertie.begin(); iter != propertie.end(); iter++) {
        if (iter->first == "focus") {
            MeetingManager::getInstance()->getMeetingController()->updateFocusAccountId("");
            VideoManager::getInstance()->onFocusVideoChanged("", false);
            return;
        }
    }
}
