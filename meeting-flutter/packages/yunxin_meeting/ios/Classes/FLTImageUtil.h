//
//  FLTImageUtil.h
//  Pods
//
//  Created by 李成达 on 2020/12/1.
//

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
