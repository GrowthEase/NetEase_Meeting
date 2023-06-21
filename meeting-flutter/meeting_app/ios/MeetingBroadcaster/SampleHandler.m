// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "SampleHandler.h"
#import <NERtcReplayKit/NERtcReplayKit.h>

static NSString *kAppGroup = @"group.com.netease.yunxin.meeting";

@interface SampleHandler () <NEScreenShareSampleHandlerDelegate>

@end

@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *, NSObject *> *)setupInfo {
  NEScreenShareBroadcasterOptions *options = [[NEScreenShareBroadcasterOptions alloc] init];
  options.appGroup = kAppGroup;
  // 设置采集帧率30帧
  options.frameRate = 30;
  // 设置需要采集系统音频数据
  options.needAudioSampleBuffer = YES;
  // 设置需要采集系统音频数据
  //    options.needMicAudioSampleBuffer = YES;
  [[NEScreenShareSampleHandler sharedInstance] broadcastStartedWithSetupInfo:options];
  NEScreenShareSampleHandler.sharedInstance.delegate = self;
}

- (void)broadcastPaused {
  // User has requested to pause the broadcast. Samples will stop being delivered.
  [[NEScreenShareSampleHandler sharedInstance] broadcastPaused];
}

- (void)broadcastResumed {
  // User has requested to resume the broadcast. Samples delivery will resume.
  [[NEScreenShareSampleHandler sharedInstance] broadcastResumed];
}

- (void)broadcastFinished {
  // User has requested to finish the broadcast.
  [[NEScreenShareSampleHandler sharedInstance] broadcastFinished];
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer
                   withType:(RPSampleBufferType)sampleBufferType {
  [[NEScreenShareSampleHandler sharedInstance] processSampleBuffer:sampleBuffer
                                                          withType:sampleBufferType];
}

- (void)onRequestToFinishBroadcastWithError:(NSError *)error {
  [self finishBroadcastWithError:error];
}

@end
