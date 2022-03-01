/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "meeting_stats_listener.h"
#include "manager/meeting/audio_manager.h"
#include "manager/meeting/members_manager.h"
#include "manager/meeting/video_manager.h"

NERtcStatsEventListener::NERtcStatsEventListener() {}

NERtcStatsEventListener::~NERtcStatsEventListener() {}

void NERtcStatsEventListener::onLocalAudioStats(const AudioStats& stats) {
    // undone
}

void NERtcStatsEventListener::onRemoteAudioStats(const std::vector<AudioStats>& videoStats) {
    AudioManager::getInstance()->onRemoteUserAudioStats(videoStats);
}
void NERtcStatsEventListener::onLocalVideoStats(const std::vector<VideoStats>& videoStats) {
    VideoManager::getInstance()->onLocalUserVideoStats(videoStats);
}
void NERtcStatsEventListener::onRemoteVideoStats(const std::vector<VideoStats>& videoStats) {
    VideoManager::getInstance()->onRemoteUserVideoStats(videoStats);
}
void NERtcStatsEventListener::onNetworkQuality(const std::string& userId, NENetWorkQuality up, NENetWorkQuality down) {
    MembersManager::getInstance()->onNetworkQuality(userId, up, down);
}
