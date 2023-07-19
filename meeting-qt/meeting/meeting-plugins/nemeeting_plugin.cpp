// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nemeeting_plugin.h"
#include <qqml.h>
#include "components/auth/nem_account.h"
#include "components/auth/nem_authenticate.h"
#include "components/devices/nem_devices.h"
#include "components/meeting/nem_session.h"
#include "models/nem_devices_model.h"
#include "models/nem_members_model.h"
#include "models/nem_schedule_model.h"
#include "nem_engine.h"
#include "providers/nem_frame_provider.h"

void NEMeetingPlugin::registerTypes(const char* uri) {
    // @uri NEMeeting
    qmlRegisterType<NEMEngine>(uri, 1, 0, "NEMEngine");
    qmlRegisterType<NEMAuthenticate>(uri, 1, 0, "NEMAuthenticate");
    qmlRegisterType<NEMAccount>(uri, 1, 0, "NEMAccount");

    // Devices
    qmlRegisterType<NEMDevices>(uri, 1, 0, "NEMDevices");
    qmlRegisterType<NEMDevicesModel>(uri, 1, 0, "NEMDeviceModel");

    // Schedules
    qmlRegisterType<NEMSchedule>(uri, 1, 0, "NEMSchedule");
    qmlRegisterType<NEMScheduleModel>(uri, 1, 0, "NEMScheduleModel");

    // Meeting
    qmlRegisterType<NEMSession>(uri, 1, 0, "NEMSession");
    qmlRegisterType<NEMMine>(uri, 1, 0, "NEMMine");
    qmlRegisterType<NEMAudioController>(uri, 1, 0, "NEMAudioController");
    qmlRegisterType<NEMVideoController>(uri, 1, 0, "NEMVideoController");
    qmlRegisterType<NEMShareController>(uri, 1, 0, "NEMShareController");
    qmlRegisterType<NEMMembersController>(uri, 1, 0, "NEMMembersController");
    qmlRegisterType<NEMMembersModel>(uri, 1, 0, "NEMMembersModel");

    // Providers
    qmlRegisterType<NEMFrameProvider>(uri, 1, 0, "NEMFrameProvider");
}
