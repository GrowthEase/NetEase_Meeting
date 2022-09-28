// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef FLTImageUtil_h
#define FLTImageUtil_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FLTImageUtil : NSObject

+ (UIImage *)scaledImage:(UIImage *)image
                maxWidth:(NSNumber *)maxWidth
               maxHeight:(NSNumber *)maxHeight;

//// Resize all gif animation frames.
//+ (GIFInfo *)scaledGIFImage:(NSData *)data
//                   maxWidth:(NSNumber *)maxWidth
//                  maxHeight:(NSNumber *)maxHeight;

@end

#endif /* FLTImageUtil_h */
