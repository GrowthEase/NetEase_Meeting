/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "screensaver.h"
#include <IOKit/pwr_mgt/IOPMLib.h>

IOPMAssertionID assertionID = 0;
ScreenSaver::ScreenSaver(QObject *parent) : QObject(parent)
{
}

ScreenSaver::~ScreenSaver()
{
    if (0 != assertionID)
    {
        IOPMAssertionRelease(assertionID);
        assertionID = 0;
    }
}

bool ScreenSaver::screenSaverEnabled() const
{
    return 0 != assertionID;
}

void ScreenSaver::setScreenSaverEnabled(bool enabled)
{
    YXLOG(Info) << "setScreenSaverEnabled: " << enabled << YXLOGEnd;
    if (enabled && 0 == assertionID)
    {
        CFStringRef reasonForActivity = CFSTR("ScreenSaver Act");
        IOReturn success = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep, kIOPMAssertionLevelOn, reasonForActivity, &assertionID);
        if (kIOReturnSuccess != success)
        {
            assertionID = 0;
        }
    }
    else if (!enabled && 0 != assertionID)
    {
        IOPMAssertionRelease(assertionID);
        assertionID = 0;
    }
}

void ScreenSaver::activityTimeout()
{
}
