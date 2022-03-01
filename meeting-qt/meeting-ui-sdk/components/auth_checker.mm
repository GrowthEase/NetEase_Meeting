/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

//
//  AuthChecker.m
//  nertc_sdk
//
//  Created by dudu on 2020/9/4.
//

#include "auth_checker.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AppKit/AppKit.h>

bool checkAuthRecordScreen()
{
    if (@available(macOS 10.15, *)) {
        CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
        NSUInteger numberOfWindows = CFArrayGetCount(windowList);
        NSUInteger numberOfWindowsWithName = 0;
        for (unsigned long idx = 0; idx < numberOfWindows; idx++) {
            NSDictionary* windowInfo = (NSDictionary *)CFArrayGetValueAtIndex(windowList, idx);
            NSString* windowName = windowInfo[(id)kCGWindowName];
            NSNumber* sharingType = windowInfo[(id)kCGWindowSharingState];
            if (windowName || kCGWindowSharingNone != sharingType.intValue) {
                numberOfWindowsWithName++;
            } else {
                //no kCGWindowName detected -> not enabled
                break; //breaking early, numberOfWindowsWithName not increased
            }
        }
        CFRelease(windowList);
        return numberOfWindows == numberOfWindowsWithName;
    }
    return true;
}

void showScreenRecordingPrompt()
{
    /* macos 10.14 and lower do not require screen recording permission to get window titles */
    if(@available(macos 10.15, *)) {
        /*
         To minimize the intrusion just make a 1px image of the upper left corner
         This way there is no real possibilty to access any private data
         */
        CGImageRef screenshot = CGWindowListCreateImage(
                    CGRectMake(0, 0, 1, 1),
                    kCGWindowListOptionOnScreenOnly,
                    kCGNullWindowID,
                    kCGWindowImageDefault);
        CFRelease(screenshot);
    }
}

void openSettings()
{
    if (@available(macOS 10.15, *)) {
        NSURL *URL = [NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"];
        [[NSWorkspace sharedWorkspace] openURL:URL];
    }
}
