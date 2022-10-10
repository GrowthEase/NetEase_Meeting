// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEScreenShareBroadcasterOptions : NSObject

/// Apple appGroup
@property(nonatomic, copy) NSString *appGroup;

/// 目标视频帧分辨率。
/// @discussion 如果宽和高只设定了一个，则另一个按照比例自动缩放。如果宽高都不设定，则按照原始尺寸。
@property(nonatomic, assign) CGSize targetFrameSize;

/// fps。 5-10
@property(nonatomic, assign) NSUInteger frameRate;

/// 端口号(确保宿主和扩展进程依赖库中使用相同的端口号)
@property(nonatomic, assign) int serverPort;

@end

NS_ASSUME_NONNULL_END
