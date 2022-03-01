/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NERTCSTATSEVENTLISTENER_H
#define NERTCSTATSEVENTLISTENER_H

#include <QObject>
#include "in_room_stats_listener.h"

using namespace neroom;

class NERtcStatsEventListener : public INERtcStatsEventListener {
public:
    NERtcStatsEventListener();
    ~NERtcStatsEventListener();

    virtual void onLocalAudioStats(const AudioStats& stats) override;
    virtual void onRemoteAudioStats(const std::vector<AudioStats>& videoStats) override;
    virtual void onLocalVideoStats(const std::vector<VideoStats>& videoStats) override;
    virtual void onRemoteVideoStats(const std::vector<VideoStats>& videoStats) override;
    virtual void onNetworkQuality(const std::string& userId, NENetWorkQuality up, NENetWorkQuality down) override;
};

#endif  // NERTCSTATSEVENTLISTENER_H
