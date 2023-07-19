// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

//
// Author: Wang Rongtao <rtwang@corp.netease.com>
// Date: 2011/6/24
//
// A implemetation of a cross flatform waitable event based message loop

#ifndef BASE_FRAMEWORK_DEFAULT_MESSAGE_PUMP_H_
#define BASE_FRAMEWORK_DEFAULT_MESSAGE_PUMP_H_

#include "base/forbid_copy.h"
#include "base/framework/message_pump.h"
#include "base/synchronization/waitable_event.h"
#include "base/time/time.h"

namespace nbase {

class DefaultMessagePump : public MessagePump {
public:
    NBASE_FORBID_COPY(DefaultMessagePump)

    DefaultMessagePump();
    virtual ~DefaultMessagePump() {}

    virtual void Run(Delegate* delegate);
    virtual void Quit();
    virtual void ScheduleWork();
    virtual void ScheduleDelayedWork(const TimeTicks& delay_message_time);

private:
    void Wait();
    void WaitTimeout(const TimeDelta& timeout);
    void Wakeup();

    WaitableEvent event_;
    bool should_quit_;
    TimeTicks delayed_work_time_;
};

}  // namespace nbase

#endif  // BASE_FRAMEWORK_DEFAULT_MESSAGE_PUMP_H_
