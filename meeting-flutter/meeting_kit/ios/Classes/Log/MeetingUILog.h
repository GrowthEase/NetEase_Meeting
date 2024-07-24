// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MeetingUILog : NSObject
/// info类型 log
+ (void)infoLog:(NSString *)className desc:(NSString *)desc;
@end

NS_ASSUME_NONNULL_END
