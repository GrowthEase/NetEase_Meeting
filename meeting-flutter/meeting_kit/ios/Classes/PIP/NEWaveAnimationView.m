// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEWaveAnimationView.h"

@interface NEWaveAnimationView ()

@property(nonatomic, weak) CALayer *animationLayer;
@property(nonatomic, assign) BOOL isAnimating;

@end

@implementation NEWaveAnimationView

- (void)layoutSubviews {
  [super layoutSubviews];
  /// 如果在NEWaveAnimationView没有展示的地方启动动画会导致动画不启动，所以在这里刷新一下
  if (_isAnimating) {
    [self startAnimation];
  }
}

- (void)startAnimation {
  if (_isAnimating) {
    [self stopAnimation];
  }
  CALayer *animationLayer = [CALayer layer];
  NSMutableArray<CALayer *> *pulsingLayers = [self setupAnimationLayers:self.frame];
  [pulsingLayers
      enumerateObjectsUsingBlock:^(CALayer *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [animationLayer addSublayer:obj];
      }];
  [self.layer addSublayer:animationLayer];
  _animationLayer = animationLayer;
  _isAnimating = YES;
}

- (void)stopAnimation {
  if (!_isAnimating) {
    return;
  }
  [_animationLayer.sublayers enumerateObjectsUsingBlock:^(__kindof CALayer *_Nonnull obj,
                                                          NSUInteger idx, BOOL *_Nonnull stop) {
    [obj removeAllAnimations];
  }];
  [_animationLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
  [_animationLayer removeFromSuperlayer];
  _animationLayer = nil;
  _isAnimating = NO;
}

- (NSMutableArray<CALayer *> *)setupAnimationLayers:(CGRect)rect {
  NSMutableArray<CALayer *> *ret = [NSMutableArray array];
  NSInteger pulsingCount = 5;
  double animationDuration = 3;
  for (int i = 0; i < pulsingCount; i++) {
    CALayer *pulsingLayer = [CALayer layer];
    pulsingLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    pulsingLayer.borderColor = [UIColor whiteColor].CGColor;
    pulsingLayer.borderWidth = 1;
    pulsingLayer.cornerRadius = rect.size.height / 2;

    CAMediaTimingFunction *defaultCurve =
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.fillMode = kCAFillModeBackwards;
    animationGroup.beginTime =
        CACurrentMediaTime() + (double)i * animationDuration / (double)pulsingCount;
    animationGroup.duration = animationDuration;
    animationGroup.repeatCount = HUGE;
    animationGroup.timingFunction = defaultCurve;

    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @1.0;
    scaleAnimation.toValue = @1.5;

    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.values = @[ @1, @0.9, @0.8, @0.7, @0.6, @0.5, @0.4, @0.3, @0.2, @0.1, @0 ];
    opacityAnimation.keyTimes = @[ @0, @0.1, @0.2, @0.3, @0.4, @0.5, @0.6, @0.7, @0.8, @0.9, @1 ];

    animationGroup.animations = @[ scaleAnimation, opacityAnimation ];
    [pulsingLayer addAnimation:animationGroup forKey:@"plulsing"];
    [ret addObject:pulsingLayer];
  }
  return ret;
}

@end
