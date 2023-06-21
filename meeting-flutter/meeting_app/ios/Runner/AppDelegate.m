// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "AppDelegate.h"
#import <CoreFoundation/CFNotificationCenter.h>
#import <Flutter/Flutter.h>
#import <ReplayKit/ReplayKit.h>
#include "GeneratedPluginRegistrant.h"
#import "NTESLinkStreamHandler.h"

const char *breaken_pathes[] = {"/Applications/Cydia.app",
                                "/Library/MobileSubstrate/MobileSubstrate.dylib", "/bin/bash",
                                "/usr/sbin/sshd", "/etc/apt"};
#define ARRAY_SIZE(a) sizeof(a) / sizeof(a[0])

static NSString *const methodChannelName = @"meeting.meeting.netease.im/cnannel";

static NSString *const eventChannelName = @"meeting.meeting.netease.im/events";

static NSString *const prefixName = @"meeting://";

static NSString *const broadcastExtensionAppGroup = @"group.com.netease.yunxin.meeting";

@interface AppDelegate ()

@property(nonatomic, strong) FlutterMethodChannel *methodChannel;

@property(nonatomic, strong) FlutterEventChannel *eventChannel;

@property(nonatomic, strong) NTESLinkStreamHandler *streamHandler;

@property(nonatomic, strong) UILabel *view;

@property(nonatomic, strong) NSString *url;

@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.url = [launchOptions[UIApplicationLaunchOptionsURLKey] absoluteString] ?: @"";
  UIViewController *vc = self.window.rootViewController;
  self.methodChannel = [FlutterMethodChannel methodChannelWithName:methodChannelName
                                                   binaryMessenger:vc];

  __weak typeof(self) wSelf = self;
  [self.methodChannel
      setMethodCallHandler:^(FlutterMethodCall *_Nonnull call, FlutterResult result) {
        if ([call.method isEqualToString:@"initialLink"]) {
          result(wSelf.url);
          wSelf.url = @"";
        } else {
          result(FlutterMethodNotImplemented);
        }
      }];

  [self.eventChannel setStreamHandler:self.streamHandler];

  [GeneratedPluginRegistrant registerWithRegistry:self];

  BOOL success = [super application:application didFinishLaunchingWithOptions:launchOptions];
  return success;
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
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

- (void)applicationWillTerminate:(UIApplication *)application {
  NSString *stopNotificationName =
      @"com.netease.rtc.kit.screenshare.notification.host_request_stop";
  CFStringRef notificationName = (CFStringRef)CFBridgingRetain(stopNotificationName);
  CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                       notificationName, nil, nil, true);
}

/// 退出应用
- (void)exitApplication {
  // 运行一个不存在的方法,退出界面更加圆滑
  [self performSelector:@selector(exitApp)];
  abort();
}

/// 越狱检测
- (BOOL)prisonBreakenDetection {
  if ([self isSimulator]) return NO;
  for (int i = 0; i < ARRAY_SIZE(breaken_pathes); i++) {
    if ([[NSFileManager defaultManager]
            fileExistsAtPath:[NSString stringWithUTF8String:breaken_pathes[i]]]) {
      return YES;
    }
  }
  return NO;
}
// 是否模拟器
- (BOOL)isSimulator {
#if TARGET_OS_SIMULATOR
  return YES;
#else
  return NO;
#endif
}
/// 判断Mach-O文件否被篡改
- (BOOL)checkMach_O {
  NSBundle *bundle = [NSBundle mainBundle];
  NSDictionary *info = [bundle infoDictionary];
  if ([info objectForKey:@"SignerIdentity"] != nil) {
    // 存在这个key，则说明被二次打包了
    return YES;
  }
  return NO;
}

@end
