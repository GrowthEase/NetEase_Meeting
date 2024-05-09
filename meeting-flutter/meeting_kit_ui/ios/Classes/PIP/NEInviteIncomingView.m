// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEInviteIncomingView.h"
#import "NEWaveAnimationView.h"
#if __has_include(<netease_meeting_ui/netease_meeting_ui-Swift.h>)
#import <netease_meeting_ui/netease_meeting_ui-Swift.h>
#else
#import "netease_meeting_ui-Swift.h"
#endif

@interface NEInviteIncomingView ()

@property(nonatomic, strong) NEWaveAnimationView *animationView;
@property(nonatomic, strong) NEMeetingAvatar *avatar;

@end

@implementation NEInviteIncomingView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupSubviews];
  }
  return self;
}

- (void)setupSubviews {
  [self addSubview:self.avatar];
  [self addSubview:self.animationView];
}

- (void)layoutSubviews {
  [super layoutSubviews];

  CGFloat width = MIN(self.frame.size.width, self.frame.size.height);
  self.avatar.frame = CGRectMake(0, 0, width / 2, width / 2);
  self.avatar.layer.cornerRadius = width / 4;
  self.animationView.frame = CGRectMake(0, 0, width / 2, width / 2);

  self.avatar.center = self.center;
  self.animationView.center = self.center;
}

- (void)setUrl:(NSString *)url {
  _url = url;
  self.avatar.url = url;
}

- (void)setName:(NSString *)name {
  _name = name;
  self.avatar.name = name;
}

- (void)startAnimation {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.animationView startAnimation];
  });
}

- (void)stopAnimation {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.animationView stopAnimation];
  });
}

- (NEMeetingAvatar *)avatar {
  if (!_avatar) {
    _avatar = [[NEMeetingAvatar alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _avatar.layer.cornerRadius = 50;
    _avatar.clipsToBounds = true;
  }
  return _avatar;
}

- (NEWaveAnimationView *)animationView {
  if (!_animationView) {
    _animationView = [[NEWaveAnimationView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
  }
  return _animationView;
}

@end
