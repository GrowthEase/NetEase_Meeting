// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "MeetingUILog.h"
#import <YXAlog_iOS/YXAlog.h>

@implementation MeetingUILog
/// info类型 log
+ (void)infoLog:(NSString *)className desc:(NSString *)desc {
  [YXAlog.shared logWithLevel:YXAlogLevelInfo
                   moduleName:@"XKit"
                          tag:className
                         type:YXAlogTypeNormal
                         line:0
                         desc:desc];
}
@end
