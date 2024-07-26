// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <AVKit/AVKit.h>
#import <Foundation/Foundation.h>
@import NERoomKit;
typedef void (^RenderResult)(NSString *_Nonnull userUuid, uint32_t width, uint32_t height,
                             CMSampleBufferRef _Nullable bufferRef);

NS_ASSUME_NONNULL_BEGIN

@interface NEPIPRenderer : NSObject <NERoomVideoRenderSink>
@property(nonatomic, copy) RenderResult renderResult;

+ (instancetype)renderWithUserUuid:(NSString *)userUuid;
@end

NS_ASSUME_NONNULL_END
