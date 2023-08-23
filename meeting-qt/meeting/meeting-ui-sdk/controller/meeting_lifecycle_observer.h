#ifndef _MANAGER_MEETING_LIFECYCLE_OBSERVER_H_
#define _MANAGER_MEETING_LIFECYCLE_OBSERVER_H_

#include "meeting_controller_define.h"

class IMeetingLifecycleObserver {
public:
    virtual ~IMeetingLifecycleObserver() = default;
    virtual void onBeforeCreateMeeting() = 0;
    virtual void onAfterCreateMeeting(int code, const NERoomInfo& info) = 0;
    virtual void onBeforeJoinMeeting(const NERoomInfo& info) = 0;
    virtual void onAfterJoinMeeting(int code, const NERoomInfo& info) = 0;
    virtual void onBeforeJoinRTCChannel(const NERoomInfo& info) = 0;
    virtual void onAfterJoinRTCChannel(int code, const NERoomInfo& info) = 0;
    virtual void onBeforeLeaveMeeting(const NERoomInfo& info) = 0;
    virtual void onAfterLeaveMeeting(int code, const NERoomInfo& info) = 0;
    virtual void onBeforeEndMeeting(const NERoomInfo& info) = 0;
    virtual void onAfterEndMeeting(int code, const NERoomInfo& info) = 0;
};

#endif  // _MANAGER_MEETING_LIFECYCLE_OBSERVER_H_
