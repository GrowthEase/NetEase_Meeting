// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef VIDEO_CONTROLLER_H
#define VIDEO_CONTROLLER_H

#include "controller/pre_rtc_ctrl_interface.h"

namespace neroom {
class INEPreviewRoomContext;
}

class NEMeetingVideoController {
public:
    NEMeetingVideoController();
    ~NEMeetingVideoController();

    std::string getPinnedUserId();
    bool pinVideo(const std::string& userId, bool on, const neroom::NECallback<>& callback = neroom::NECallback<>());
    bool askParticipantStartVideo(const std::string& userId, const neroom::NECallback<>& callback = neroom::NECallback<>());
    bool stopParticipantVideo(const std::string& userId, const neroom::NECallback<>& callback = neroom::NECallback<>());
    bool setupPreviewCanvas(void* usedata, void* window, bool highVideoQuality = false);
    bool muteMyVideo(bool disable, const neroom::NECallback<>& callback = neroom::NECallback<>());
    bool startVideoPreview();
    bool stopVideoPreview();
    bool setInternalRender(bool internalRender);
    bool subscribeRemoteVideoStream(const std::string& userId, bool bHighStream);
    bool unsubscribeRemoteVideoStream(const std::string& userId);
    bool subscribeRemoteVideoSubStream(const std::string& userId);
    bool unsubscribeRemoteVideoSubStream(const std::string& userId);
    bool setupVideoCanvas(const std::string& userId, void* userData, void* window);
    bool setupSubVideoCanvas(const std::string& userId, void* userData, void* window);
    bool enumCameraDevices(std::vector<neroom::NEDeviceBaseInfo>& deviceList);
    bool getSelectedCameraDevice(std::string& deviceId);
    bool selectCameraDevice(const std::string& deviceId);
    // bool setVideoProfileType(NEVideoProfileType videoProfileType);
    int enumCaptureDevices();
    bool muteAllParticipantsVideo(bool allowUnmuteSelf, const neroom::NECallback<>& callback = neroom::NECallback<>());
    bool unmuteAllParticipantsVideo(const neroom::NECallback<>& callback = neroom::NECallback<>());

    void clearCameraCurDeviceId() { m_deviceId.clear(); }
    std::string getCameraCurDeviceId() const { return m_deviceId; }

private:
    std::string m_deviceId;
};

#endif  // VIDEO_CONTROLLER_H
