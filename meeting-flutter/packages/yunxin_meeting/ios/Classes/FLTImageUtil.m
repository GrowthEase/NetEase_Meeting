//
//  FLTImageUtil.m
//  ne_meeting_plugin
//
//  Created by hzlichengda on 2020/12/1.
//

#import "FLTImageUtil.h"

@implementation FLTImageUtil : NSObject

+ (UIImage *)scaledImage:(UIImage *)image
                maxWidth:(NSNumber *)maxWidth
               maxHeight:(NSNumber *)maxHeight {
    double originalWidth = image.size.width;
    double originalHeight = image.size.height;
    
    bool hasMaxWidth = maxWidth != (id)[NSNull null];
    bool hasMaxHeight = maxHeight != (id)[NSNull null];
    
    double width = hasMaxWidth ? MIN([maxWidth doubleValue], originalWidth) : originalWidth;
    double height = hasMaxHeight ? MIN([maxHeight doubleValue], originalHeight) : originalHeight;
    
    bool shouldDownscaleWidth = hasMaxWidth && [maxWidth doubleValue] < originalWidth;
    bool shouldDownscaleHeight = hasMaxHeight && [maxHeight doubleValue] < originalHeight;
    bool shouldDownscale = shouldDownscaleWidth || shouldDownscaleHeight;
    
    if (!shouldDownscale) {
        return image;
    }
    
    NSLog(@"[iOS] should scale image");
    
    //  if (shouldDownscale) {
    double downscaledWidth = floor((height / originalHeight) * originalWidth);
    double downscaledHeight = floor((width / originalWidth) * originalHeight);
    
    if (width < height) {
        if (!hasMaxWidth) {
            width = downscaledWidth;
        } else {
            height = downscaledHeight;
        }
    } else if (height < width) {
        if (!hasMaxHeight) {
            height = downscaledHeight;
        } else {
            width = downscaledWidth;
        }
    } else {
        if (originalWidth < originalHeight) {
            width = downscaledWidth;
        } else if (originalHeight < originalWidth) {
            height = downscaledHeight;
        }
    }
    //  }
    
    // Scaling the image always rotate itself based on the current imageOrientation of the original
    // Image. Set to orientationUp for the orignal image before scaling, so the scaled image doesn't
    // mess up with the pixels.
    UIImage *imageToScale = [UIImage imageWithCGImage:image.CGImage
                                                scale:1
                                          orientation:UIImageOrientationUp];
    
    // The image orientation is manually set to UIImageOrientationUp which swapped the aspect ratio in
    // some scenarios. For example, when the original image has orientation left, the horizontal
    // pixels should be scaled to `width` and the vertical pixels should be scaled to `height`. After
    // setting the orientation to up, we end up scaling the horizontal pixels to `height` and vertical
    // to `width`. Below swap will solve this issue.
    if ([image imageOrientation] == UIImageOrientationLeft ||
        [image imageOrientation] == UIImageOrientationRight ||
        [image imageOrientation] == UIImageOrientationLeftMirrored ||
        [image imageOrientation] == UIImageOrientationRightMirrored) {
        double temp = width;
        width = height;
        height = temp;
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 1.0);
    [imageToScale drawInRect:CGRectMake(0, 0, width, height)];
    
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
