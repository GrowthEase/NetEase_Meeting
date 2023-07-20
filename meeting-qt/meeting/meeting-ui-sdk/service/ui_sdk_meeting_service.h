// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEETING_UI_SDK_SERVICE_MEETING_SERVICE_H_
#define MEETING_UI_SDK_SERVICE_MEETING_SERVICE_H_

USING_NS_NNEM_SDK_INTERFACE

class NEM_SDK_INTERFACE_EXPORT NEMeetingServiceIMP : public NEMeetingService {
    friend NEMeetingSDK* NEMeetingSDK::getInstance();

public:
    NEMeetingServiceIMP();
    virtual ~NEMeetingServiceIMP();

public:
    virtual void startMeeting(const NEStartMeetingParams& param, const NEStartMeetingOptions& opts, const NEStartMeetingCallback& cb) override;
    virtual void joinMeeting(const NEJoinMeetingParams& param, const NEJoinMeetingOptions& opts, const NEJoinMeetingCallback& cb) override;

private:
    void doJoinMeeting(const NEJoinMeetingParams& param, const NEJoinMeetingOptions& opts, const NEJoinMeetingCallback& cb);
    void doAnonJoinMeeting(const NEJoinMeetingParams& param, const NEJoinMeetingOptions& opts, const NEJoinMeetingCallback& cb);
};

#endif  // MEETING_UI_SDK_SERVICE_MEETING_SERVICE_H_
