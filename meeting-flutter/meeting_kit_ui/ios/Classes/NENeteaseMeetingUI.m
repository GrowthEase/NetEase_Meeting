// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NENeteaseMeetingUI.h"

@implementation NENeteaseMeetingUI
+ (UIImage *)ne_imageName:(NSString *)imageName {
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  return [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
}
@end
