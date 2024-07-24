// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "MeetingPlugin.h"
#import <AVFoundation/AVFoundation.h>
#import "FLTImageUtil.h"
#import "MeetingUILog.h"
#import "NEPIPServer.h"
#if __has_include(<netease_meeting_kit/netease_meeting_kit-Swift.h>)
#import <netease_meeting_kit/netease_meeting_kit-Swift.h>
#else
#import "netease_meeting_kit-Swift.h"
#endif

@interface MeetingPlugin ()
@property(nonatomic, strong) TelephoneServer *phoneServer;
@property(nonatomic, strong) LifecycleServer *lifecycleServer;
@property(nonatomic, strong) NEPIPServer *pipServer;
@property(nonatomic, strong) NEMeetingAudioManager *audioManager;
@property(nonatomic, strong) NEVolumeListener *volumeListener;
@end

@implementation MeetingPlugin
- (TelephoneServer *)phoneServer {
  if (!_phoneServer) {
    _phoneServer = [TelephoneServer new];
  }
  return _phoneServer;
}
- (LifecycleServer *)lifecycleServer {
  if (!_lifecycleServer) {
    _lifecycleServer = [LifecycleServer new];
  }
  return _lifecycleServer;
}
- (NEPIPServer *)pipServer {
  if (!_pipServer) {
    _pipServer = [NEPIPServer new];
  }
  return _pipServer;
}
- (NEMeetingAudioManager *)audioManager {
  if (!_audioManager) {
    _audioManager = [NEMeetingAudioManager new];
  }
  return _audioManager;
}
- (NEVolumeListener *)volumeListener {
  if (!_volumeListener) {
    _volumeListener = [NEVolumeListener new];
  }
  return _volumeListener;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"meeting_plugin"
                                  binaryMessenger:[registrar messenger]];

  MeetingPlugin *instance = [[MeetingPlugin alloc] initWithMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:channel];
}
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger {
  self = [super init];
  if (self) {
    FlutterEventChannel *channel =
        [FlutterEventChannel eventChannelWithName:@"meeting_plugin.phone_state_service.states"
                                  binaryMessenger:messenger];
    [channel setStreamHandler:self.phoneServer];

    FlutterEventChannel *lifecycleChannel =
        [FlutterEventChannel eventChannelWithName:@"meeting_plugin.app_lifecycle_service.states"
                                  binaryMessenger:messenger];
    [lifecycleChannel setStreamHandler:self.lifecycleServer];

    FlutterEventChannel *volumeChannel =
        [FlutterEventChannel eventChannelWithName:@"meeting_plugin.volume_listener_event.states"
                                  binaryMessenger:messenger];
    [volumeChannel setStreamHandler:self.volumeListener];
  }
  return self;
}
- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  // 获取模块id
  id modelName = nil;
  NSDictionary *arguments = call.arguments;
  modelName = arguments[@"module"];
  // 模块校验
  if (!modelName || ![modelName isKindOfClass:[NSString class]]) {
    result(@(-1001));
    return;
  }
  // 转发
  if ([modelName isEqualToString:@"NEAssetService"] &&
      [call.method isEqualToString:@"loadAssetAsString"]) {
    NSString *fileName = [arguments objectForKey:@"fileName"];
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@""];
    BOOL isDir = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] || isDir) {
      result(nil);
      return;
    }
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    result(content);
  } else if ([modelName isEqualToString:@"ImageLoader"] &&
             [call.method isEqualToString:@"loadImage"]) {
    NSString *name = [arguments objectForKey:@"key"];
    UIImage *image = [UIImage imageNamed:name];
    if (!image) {
      result(nil);
      return;
    }
#ifdef DEBUG
    NSLog(@"[iOS] loadImage:%@x%@@%@", @(image.size.width), @(image.size.height), @(image.scale));
#endif
    // image = [FLTImageUtil scaledImage:image maxWidth:maxWidth maxHeight:maxHeight];
    NSData *data = UIImagePNGRepresentation(image);
    if (data) {
#ifdef DEBUG
      NSLog(@"[iOS] loadImage: len=%@", @(data.length));
#endif
      result(@{
        @"scale" : @(image.scale),
        @"data" : [FlutterStandardTypedData typedDataWithBytes:data],
      });
    } else {
      result(nil);
    }
    return;
  } else if ([modelName isEqualToString:@"NEImageGallerySaver"]) {
    ImageGallerySaver *saver = [[ImageGallerySaver alloc] init];
    [saver handle:call result:result];
  } else if ([modelName isEqualToString:@"NEPadCheckDetector"]) {
    CheckIpadServer *iPadSaver = [CheckIpadServer new];
    [iPadSaver handle:call result:result];
  } else if ([modelName isEqualToString:@"NEFloatingService"]) {
    if (@available(iOS 15.0, *)) {
      [self.pipServer pipAction:call result:result];
    } else {
      result(nil);
    }
  } else if ([modelName isEqualToString:@"NEAudioService"]) {
    if ([call.method isEqualToString:@"enumAudioDevices"]) {
      NSArray *array = [self.audioManager enumAudioDevices];
      NSMutableArray *ret = [NSMutableArray arrayWithCapacity:array.count];
      for (AVAudioSessionPortDescription *d in array) {
        [ret addObject:[NSNumber numberWithInt:[self getOutputRoutingTypeFromPort:d.portType]]];
      }
      result(ret);
    } else if ([call.method isEqualToString:@"getSelectedAudioDevice"]) {
      int device =
          [self getOutputRoutingTypeFromPort:[self.audioManager getSelectedAudioDevice].portType];
      result([NSNumber numberWithInt:device]);
    } else if ([call.method isEqualToString:@"showAudioDevicePicker"]) {
      [self.audioManager showAudioDevicePicker];
      result(nil);
    }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSDictionary *)dictionaryFromFile:(NSString *)fileName {
  NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"conf"];
  BOOL isDir = NO;
  if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] || isDir) {
    return nil;
  }
  NSData *data = [NSData dataWithContentsOfFile:path];
  NSError *error = nil;
  id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

  if (!obj || error || ![obj isKindOfClass:[NSDictionary class]]) {
    return nil;
  }
  return obj;
}

- (int)getOutputRoutingTypeFromPort:(AVAudioSessionPort)port {
  //  /// 扬声器
  //  kSpeakerPhone = 0,
  //  /// 有线耳机
  //  kWiredHeadset = 1,
  //  /// 听筒
  //  kEarpiece = 2,
  //  /// 蓝牙耳机
  //  kBluetoothHeadset = 3,
  int routing = 0;
  if (!port) {
    return routing;
  }

  if ([port isEqualToString:AVAudioSessionPortBuiltInSpeaker]) {
    routing = 0;
  } else if ([port isEqualToString:AVAudioSessionPortBuiltInReceiver]) {
    routing = 2;
  } else if ([port isEqualToString:AVAudioSessionPortHeadphones]) {
    routing = 1;
  } else if ([port isEqualToString:AVAudioSessionPortBluetoothA2DP] ||
             [port isEqualToString:AVAudioSessionPortBluetoothLE] ||
             [port isEqualToString:AVAudioSessionPortBluetoothHFP]) {
    routing = 3;
  }
  // 不需要对外暴露
  //  else if ([port isEqualToString:AVAudioSessionPortUSBAudio]) {
  //    routing = kRtcAudioOutputRoutingUSBAudio;
  //  }else if ([port isEqualToString:AVAudioSessionPortAirPlay]) {
  //    routing = kRtcAudioOutputRoutingAirPlay;
  //  }

  return routing;
}

@end
