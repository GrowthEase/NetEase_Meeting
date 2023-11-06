// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
//
//  AuthChecker.m
//  nertc_sdk
//
//  Created by dudu on 2020/9/4.
//

#include "auth_checker.h"
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVMediaFormat.h>
#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#include <QDebug>

bool checkAuthRecordScreen() {
    if (@available(macOS 10.14, *)) {
        CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
        NSUInteger numberOfWindows = CFArrayGetCount(windowList);
        NSUInteger numberOfWindowsWithName = 0;
        for (unsigned long idx = 0; idx < numberOfWindows; idx++) {
            NSDictionary* windowInfo = (NSDictionary*)CFArrayGetValueAtIndex(windowList, idx);
            NSString* windowName = windowInfo[(id)kCGWindowName];
            NSNumber* sharingType = windowInfo[(id)kCGWindowSharingState];
            if (windowName || kCGWindowSharingNone != sharingType.intValue) {
                numberOfWindowsWithName++;
            } else {
                break;  // breaking early, numberOfWindowsWithName not increased
            }
        }
        CFRelease(windowList);
        return numberOfWindows == numberOfWindowsWithName;
    }
    return true;
}

void showScreenRecordingPrompt() {
    /* macos 10.14 and lower do not require screen recording permission to get window titles */
    if (@available(macos 10.14, *)) {
        /*
         To minimize the intrusion just make a 1px image of the upper left corner
         This way there is no real possibilty to access any private data
         */
        CGImageRef screenshot =
            CGWindowListCreateImage(CGRectMake(0, 0, 1, 1), kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
        CFRelease(screenshot);
    }
}

void openRecordSettings() {
    if (@available(macOS 10.14, *)) {
        NSURL* URL = [NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"];
        [[NSWorkspace sharedWorkspace] openURL:URL];
    }
}

void openCameraSettings() {
    if (@available(macOS 10.14, *)) {
        NSURL* URL = [NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_Camera"];
        [[NSWorkspace sharedWorkspace] openURL:URL];
    }
}

void openMicrophoneSettings() {
    if (@available(macOS 10.14, *)) {
        NSURL* URL = [NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone"];
        [[NSWorkspace sharedWorkspace] openURL:URL];
    }
}

bool checkAuthCamera() {
    bool result = true;
    if (@available(macOS 10.14, *)) {
        AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        qInfo() << " checkAuthCamera authorizationStatus: " << authorizationStatus;
        if (authorizationStatus == AVAuthorizationStatusAuthorized) {
            result = true;
        } else if (authorizationStatus == AVAuthorizationStatusRestricted) {
            result = false;
        } else if (authorizationStatus == AVAuthorizationStatusDenied) {
            result = false;
        } else if (authorizationStatus == AVAuthorizationStatusNotDetermined) {
            result = true;
        }
    }

    qInfo() << " checkAuthCamera authorizationStatus: ";
    return result;
}

bool checkAuthMicrophone() {
    bool result = true;
    if (@available(macOS 10.14, *)) {
        AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        qInfo() << " checkAuthMicrophone authorizationStatus: " << authorizationStatus;
        if (authorizationStatus == AVAuthorizationStatusAuthorized) {
            result = true;
        } else if (authorizationStatus == AVAuthorizationStatusRestricted) {
            result = false;
        } else if (authorizationStatus == AVAuthorizationStatusDenied) {
            result = false;
        } else if (authorizationStatus == AVAuthorizationStatusNotDetermined) {
            result = true;
        }
    }

    qInfo() << " checkAuthMicrophone authorizationStatus: ";

    return result;
}
