// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef NEMeetingScreenShareController_H
#define NEMeetingScreenShareController_H

#include "controller/rtc_ctrl_interface.h"

using namespace neroom;

class NEMeetingScreenShareController {
    using NEShareCallback = std::function<void(int, const std::string&)>;

public:
    NEMeetingScreenShareController();
    ~NEMeetingScreenShareController();

    bool startAppShare(void* hwnd, bool preferMotion = false, const NEShareCallback& callback = NEShareCallback());
    bool startScreenShare(const uint32_t& monitor_id,
                          const std::list<void*>& excludedWindowList = std::list<void*>(),
                          bool preferMotion = false,
                          const NEShareCallback& callback = NEShareCallback());
    bool startRectShare(const NERectangle& sourceRectangle,
                        const NERectangle& regionRectangle,
                        const std::list<void*>& excludedWindowList = std::list<void*>(),
                        bool preferMotion = false,
                        const NEShareCallback& callback = NEShareCallback());

    bool stopScreenShare(const NEShareCallback& callback = NEShareCallback());
    bool stopParticipantScreenShare(const std::string& accountId, const NEShareCallback& callback = NEShareCallback());
    bool pauseShare();
    bool resumeShare();
    bool switchAppShare(void* hwnd, bool preferMotion = false);
    bool switchMonitorShare(const uint32_t& monitor_id, const std::list<void*>& excludedWindowList, bool preferMotion = false);
    bool startSystemAudioLoopbackCapture();
    bool stopSystemAudioLoopbackCapture();
    bool systemAudioLoopbackCapture(bool& enable) const;
    std::string getScreenSharingUserId();

private:
    bool m_systemAudioLoopbackCapture = false;
};

#endif  // NEMeetingScreenShareController_H
