// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

@import NERoomKit;
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NESampleBufferDisplayView : UIView
- (void)updateStateWithMember:(NERoomMember *)member isSelf:(BOOL)isSelf;
- (void)showPhone:(BOOL)flag;
- (void)showInfo:(BOOL)flag;
- (void)updateAvatarHidden:(BOOL)hide;
@end

NS_ASSUME_NONNULL_END
