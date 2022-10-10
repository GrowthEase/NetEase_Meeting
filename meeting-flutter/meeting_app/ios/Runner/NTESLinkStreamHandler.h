// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface NTESLinkStreamHandler : NSObject <FlutterStreamHandler>

- (BOOL)handleLink:(NSString *)link;

@end

NS_ASSUME_NONNULL_END
