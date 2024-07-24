// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NESampleBufferDisplayView.h"
#import <AVKit/AVKit.h>
#import "NENeteaseMeetingUI.h"
#if __has_include(<netease_meeting_kit/netease_meeting_kit-Swift.h>)
#import <netease_meeting_kit/netease_meeting_kit-Swift.h>
#else
#import "netease_meeting_kit-Swift.h"
#endif

@interface NESampleBufferDisplayView ()
@property(nonatomic, strong) UIView *titleBgView;
@property(nonatomic, strong) UIView *infoBgView;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UIImageView *audioImage;
@property(nonatomic, strong) UIView *phoneBgView;
@property(nonatomic, strong) UIImageView *phoneImage;
@property(nonatomic, strong) UILabel *phoneLabel;
@property(nonatomic, strong) NEMeetingAvatar *avatar;
@end

@implementation NESampleBufferDisplayView
- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupSubviews];
  }
  return self;
}

+ (Class)layerClass {
  return AVSampleBufferDisplayLayer.class;
}

- (void)setupSubviews {
  [self addSubview:self.titleBgView];
  [NSLayoutConstraint activateConstraints:@[
    [self.titleBgView.topAnchor constraintEqualToAnchor:self.topAnchor],
    [self.titleBgView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
    [self.titleBgView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
    [self.titleBgView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
  ]];
  [self.titleBgView addSubview:self.avatar];

  [self addSubview:self.phoneBgView];
  [NSLayoutConstraint activateConstraints:@[
    [self.phoneBgView.topAnchor constraintEqualToAnchor:self.topAnchor],
    [self.phoneBgView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
    [self.phoneBgView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
    [self.phoneBgView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
  ]];
  [self.phoneBgView addSubview:self.phoneImage];
  [NSLayoutConstraint activateConstraints:@[
    [self.phoneImage.widthAnchor constraintEqualToConstant:30],
    [self.phoneImage.heightAnchor constraintEqualToConstant:30],
    [self.phoneImage.centerXAnchor constraintEqualToAnchor:self.phoneBgView.centerXAnchor],
    [self.phoneImage.centerYAnchor constraintEqualToAnchor:self.phoneBgView.centerYAnchor
                                                  constant:-20],
  ]];
  [self.phoneBgView addSubview:self.phoneLabel];
  [NSLayoutConstraint activateConstraints:@[
    [self.phoneLabel.heightAnchor constraintEqualToConstant:30],
    [self.phoneLabel.leadingAnchor constraintEqualToAnchor:self.phoneBgView.leadingAnchor],
    [self.phoneLabel.trailingAnchor constraintEqualToAnchor:self.phoneBgView.trailingAnchor],
    [self.phoneLabel.centerYAnchor constraintEqualToAnchor:self.phoneBgView.centerYAnchor
                                                  constant:20],
  ]];

  [self addSubview:self.infoBgView];
  [NSLayoutConstraint activateConstraints:@[
    [self.infoBgView.heightAnchor constraintEqualToConstant:20],
    [self.infoBgView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:8.0],
    [self.infoBgView.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor
                                                             constant:-8.0],
    [self.infoBgView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-8.0]
  ]];

  [self.infoBgView addSubview:self.audioImage];
  [NSLayoutConstraint activateConstraints:@[
    [self.audioImage.widthAnchor constraintEqualToConstant:16],
    [self.audioImage.heightAnchor constraintEqualToConstant:16],
    [self.audioImage.leadingAnchor constraintEqualToAnchor:self.infoBgView.leadingAnchor
                                                  constant:2.0],
    [self.audioImage.bottomAnchor constraintEqualToAnchor:self.infoBgView.bottomAnchor
                                                 constant:-2.0]
  ]];
  [self.infoBgView addSubview:self.nameLabel];
  [NSLayoutConstraint activateConstraints:@[
    [self.nameLabel.heightAnchor constraintEqualToConstant:16],
    [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.audioImage.trailingAnchor
                                                 constant:4.0],
    [self.nameLabel.trailingAnchor constraintEqualToAnchor:self.infoBgView.trailingAnchor
                                                  constant:-6.0],
    [self.nameLabel.bottomAnchor constraintEqualToAnchor:self.infoBgView.bottomAnchor constant:-2.0]
  ]];
}
- (void)updateStateWithMember:(NERoomMember *)member isSelf:(BOOL)isSelf {
  self.nameLabel.text = member.name;
  self.audioImage.image =
      [NENeteaseMeetingUI ne_imageName:member.isAudioOn ? @"audio_on" : @"audio_off"];
  self.avatar.name = member.name;
  self.avatar.url = member.avatar;
  if (isSelf) {
    self.titleBgView.hidden = NO;
    self.avatar.hidden = member.isVideoOn;
  } else {
    self.avatar.hidden = NO;
    self.titleBgView.hidden = member.isVideoOn;
  }
}
- (void)showPhone:(BOOL)flag {
  self.phoneBgView.hidden = !flag;
  self.phoneImage.hidden = !flag;
  self.phoneLabel.hidden = !flag;
}
- (void)showInfo:(BOOL)flag {
  self.infoBgView.hidden = !flag;
}
- (void)layoutSubviews {
  [super layoutSubviews];
  CGFloat width = MIN(self.frame.size.width, self.frame.size.height);
  self.avatar.frame = CGRectMake(0, 0, width / 2, width / 2);
  self.avatar.layer.cornerRadius = width / 4;
  self.avatar.center = self.center;
}
#pragma mark------------------------ Getter ------------------------
- (UIView *)titleBgView {
  if (!_titleBgView) {
    _titleBgView = [[UIView alloc] initWithFrame:CGRectZero];
    _titleBgView.backgroundColor = [UIColor colorWithRed:64.0 / 255
                                                   green:64.0 / 255
                                                    blue:64.0 / 255
                                                   alpha:1];
    _titleBgView.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return _titleBgView;
}
- (UIView *)phoneBgView {
  if (!_phoneBgView) {
    _phoneBgView = [[UIView alloc] initWithFrame:CGRectZero];
    _phoneBgView.backgroundColor = UIColor.blackColor;
    _phoneBgView.translatesAutoresizingMaskIntoConstraints = NO;
    _phoneBgView.hidden = YES;
  }
  return _phoneBgView;
}
- (UIImageView *)phoneImage {
  if (!_phoneImage) {
    _phoneImage =
        [[UIImageView alloc] initWithImage:[NENeteaseMeetingUI ne_imageName:@"phone_InCall"]];
    _phoneImage.hidden = YES;
    _phoneImage.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return _phoneImage;
}
- (UILabel *)phoneLabel {
  if (!_phoneLabel) {
    _phoneLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _phoneLabel.text = @"正在接听系统电话";
    _phoneLabel.hidden = YES;
    _phoneLabel.textColor = UIColor.whiteColor;
    _phoneLabel.textAlignment = NSTextAlignmentCenter;
    _phoneLabel.font = [UIFont systemFontOfSize:12];
    _phoneLabel.backgroundColor = UIColor.blackColor;
    _phoneLabel.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return _phoneLabel;
}
- (UIView *)infoBgView {
  if (!_infoBgView) {
    _infoBgView = [[UIView alloc] initWithFrame:CGRectZero];
    _infoBgView.backgroundColor = UIColor.blackColor;
    _infoBgView.translatesAutoresizingMaskIntoConstraints = NO;
    _infoBgView.layer.masksToBounds = YES;
    _infoBgView.layer.cornerRadius = 4.0;
  }
  return _infoBgView;
}

- (UILabel *)nameLabel {
  if (!_nameLabel) {
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _nameLabel.backgroundColor = UIColor.blackColor;
    _nameLabel.textColor = UIColor.whiteColor;
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    _nameLabel.font = [UIFont systemFontOfSize:12];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return _nameLabel;
}
- (UIImageView *)audioImage {
  if (!_audioImage) {
    _audioImage =
        [[UIImageView alloc] initWithImage:[NENeteaseMeetingUI ne_imageName:@"audio_off"]];
    _audioImage.backgroundColor = UIColor.blackColor;
    _audioImage.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return _audioImage;
}
- (NEMeetingAvatar *)avatar {
  if (!_avatar) {
    _avatar = [[NEMeetingAvatar alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _avatar.layer.cornerRadius = 50;
    _avatar.clipsToBounds = true;
  }
  return _avatar;
}
@end
