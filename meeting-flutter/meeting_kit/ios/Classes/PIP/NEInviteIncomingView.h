// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEInviteIncomingView : UIView

@property(nonatomic, copy) NSString *url;
@property(nonatomic, copy) NSString *name;

- (void)startAnimation;

- (void)stopAnimation;

@end

NS_ASSUME_NONNULL_END
