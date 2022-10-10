// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <ReplayKit/ReplayKit.h>
@class NEScreenShareBroadcasterOptions;

NS_ASSUME_NONNULL_BEGIN

@interface NEScreenShareSampleHandler : RPBroadcastSampleHandler

/// 初始化方法
- (void)setupWithOptions:(NEScreenShareBroadcasterOptions *)options;

@end

NS_ASSUME_NONNULL_END
