// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEPIPRenderer.h"
#include <NEDyldYuv/Libyuv.h>

@interface NEPIPRenderer ()
@property(nonatomic, copy) NSString *userUuid;
@end

@implementation NEPIPRenderer
+ (instancetype)renderWithUserUuid:(NSString *)userUuid {
  NEPIPRenderer *renderer = [self new];
  renderer.userUuid = userUuid;
  return renderer;
}
- (void)onRenderWithFrame:(NERoomVideoFrame *)frame {
  CVPixelBufferRef pixelBuffer;
  CFDictionaryRef empty =
      CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks,
                         &kCFTypeDictionaryValueCallBacks);
  CFMutableDictionaryRef attrs = CFDictionaryCreateMutable(
      kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
  CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
  CVReturn err = CVPixelBufferCreate(kCFAllocatorDefault, frame.width, frame.height,
                                     kCVPixelFormatType_32BGRA,  // important
                                     attrs, &(pixelBuffer));
  CVPixelBufferLockBaseAddress(pixelBuffer, 0);
  uint8_t *dst = CVPixelBufferGetBaseAddress(pixelBuffer);
  size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
  I420ToARGB((uint8_t *)frame.buffer,
             [frame.strides[0] intValue],  // i420Buffer->StrideY(),
             (uint8_t *)frame.uBuffer, [frame.strides[1] intValue], (uint8_t *)frame.vBuffer,
             [frame.strides[2] intValue], dst, bytesPerRow, frame.width, frame.height);
  CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
  [self renderFrame:pixelBuffer width:frame.width height:frame.height];
  CFRelease(pixelBuffer);
}
- (void)renderFrame:(CVPixelBufferRef)bufferRef width:(uint32_t)width height:(uint32_t)height {
  if (!bufferRef) {
    return;
  }

  CMSampleTimingInfo timing = {kCMTimeInvalid, kCMTimeInvalid, kCMTimeInvalid};

  CMVideoFormatDescriptionRef videoInfo = NULL;
  OSStatus result = CMVideoFormatDescriptionCreateForImageBuffer(NULL, bufferRef, &videoInfo);

  CMSampleBufferRef sampleBuffer = NULL;
  result = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, bufferRef, true, NULL, NULL,
                                              videoInfo, &timing, &sampleBuffer);
  // CFRelease(bufferRef);
  CFRelease(videoInfo);

  CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
  CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
  CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
  //    AVSampleBufferDisplayLayer *layer = (AVSampleBufferDisplayLayer *)self.displayView.layer;
  //    if (layer.status == AVQueuedSampleBufferRenderingStatusFailed) {
  //        [layer flush];
  //    }
  //    [layer enqueueSampleBuffer:sampleBuffer];
  if (self.renderResult) {
    self.renderResult(self.userUuid, width, height, sampleBuffer);
  }
  CFRelease(sampleBuffer);
}
@end
