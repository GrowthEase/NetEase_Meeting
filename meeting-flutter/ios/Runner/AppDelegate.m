// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "NTESLinkStreamHandler.h"
#import <Flutter/Flutter.h>

static NSString * const methodChannelName = @"meeting.meeting.netease.im/cnannel";

static NSString * const eventChannelName = @"meeting.meeting.netease.im/events";

static NSString * const prefixName = @"meeting://";

static NSString * const broadcastExtensionAppGroup = @"group.com.netease.yunxin.meeting";

@interface AppDelegate ()

@property (nonatomic,strong) FlutterMethodChannel * methodChannel;

@property (nonatomic,strong) FlutterEventChannel * eventChannel;

@property (nonatomic,strong) NTESLinkStreamHandler * streamHandler;

@property (nonatomic,strong) UILabel * view;

@property (nonatomic,strong) NSString * url;

@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.url = [launchOptions[UIApplicationLaunchOptionsURLKey] absoluteString] ? : @"";
    UIViewController *vc = self.window.rootViewController;
    self.methodChannel = [FlutterMethodChannel methodChannelWithName:methodChannelName binaryMessenger:vc];
    
    __weak typeof(self) wSelf = self;
    [self.methodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  result) {
        if ([call.method isEqualToString:@"initialLink"]) {
            result(wSelf.url);
            wSelf.url = @"";
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
    [self.eventChannel setStreamHandler:self.streamHandler];

    [GeneratedPluginRegistrant registerWithRegistry:self];
    BOOL success =  [super application:application
         didFinishLaunchingWithOptions:launchOptions];
    return success;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    if ([url.absoluteString containsString:prefixName]) {
        [self.eventChannel setStreamHandler:self.streamHandler];
        return [self.streamHandler handleLink:url.absoluteString];
    }
    return NO;
}

- (NTESLinkStreamHandler *)streamHandler {
    if (!_streamHandler) {
        _streamHandler = [[NTESLinkStreamHandler alloc] init];
    }
    return _streamHandler;
}


- (FlutterEventChannel *)eventChannel {
    if (!_eventChannel) {
        UIViewController *vc = self.window.rootViewController;
        _eventChannel = [FlutterEventChannel eventChannelWithName:eventChannelName binaryMessenger:vc];
    }
    return _eventChannel;
}


@end
