// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "SampleHandler.h"

static NSString *kAppGroup = @"group.com.netease.yunxin.meeting";

@implementation SampleHandler

- (void)setupWithOptions:(NEScreenShareBroadcasterOptions *)options {
  options.appGroup = kAppGroup;
  options.targetFrameSize = CGSizeMake(0, 0);  // 原始尺寸
}

#pragma mark - NEScreenShareBroadcasterDelegate
- (void)onHostRequestFinishBroadcast {
  NSError *error = [NSError
      errorWithDomain:NSStringFromClass(self.class)
                 code:0
             userInfo:@{
               NSLocalizedFailureReasonErrorKey : NSLocalizedString(@"屏幕共享已结束。", nil)
             }];
  [self finishBroadcastWithError:error];
}

@end
