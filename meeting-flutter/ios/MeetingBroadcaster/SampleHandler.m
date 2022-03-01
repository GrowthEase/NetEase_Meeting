// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.


#import "SampleHandler.h"

static NSString *kAppGroup = @"group.com.netease.yunxin.meeting";

@interface SampleHandler () <NEScreenShareBroadcasterDelegate>

@property (nonatomic, strong) NEScreenShareBroadcaster *broadcaster;

@end

@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    NEScreenShareBroadcasterOptions *options = [[NEScreenShareBroadcasterOptions alloc] init];
    options.appGroup = kAppGroup;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat screenWidth = screenRect.size.width * scale;
    CGFloat screenHeight = screenRect.size.height * scale;
    if (720 / screenWidth > 1280 / screenHeight) {
        options.targetFrameSize = CGSizeMake(0, 1280); // 根据高度缩放
    } else {
        options.targetFrameSize = CGSizeMake(720, 0); // 根据宽度来缩放
    }
    options.delegate = self;
    self.broadcaster = [[NEScreenShareBroadcaster alloc] initWithOptions:options];
}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
    [self.broadcaster broadcastPaused];
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
    [self.broadcaster broadcastResumed];
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
    [self.broadcaster broadcastFinished];
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            // Handle video sample buffer
            [self.broadcaster sendVideoSampleBuffer:sampleBuffer];
            break;
        case RPSampleBufferTypeAudioApp:
            // Handle audio sample buffer for app audio
            break;
        case RPSampleBufferTypeAudioMic:
            // Handle audio sample buffer for mic audio
            break;
            
        default:
            break;
    }
}

#pragma mark - NEScreenShareBroadcasterDelegate
- (void)onHostRequestFinishBroadcast {
    NSError *error = [NSError errorWithDomain:NSStringFromClass(self.class)
                                         code:0
                                     userInfo:@{
                                         NSLocalizedFailureReasonErrorKey:NSLocalizedString(@"屏幕共享已结束。", nil)
                                     }];
    [self finishBroadcastWithError:error];
}

@end
