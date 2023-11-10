// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NESampleBufferDisplayView.h"
#import <AVKit/AVKit.h>
#import "NENeteaseMeetingUI.h"

@interface NESampleBufferDisplayView ()
@property(nonatomic, strong) UIView *titleBgView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIView *infoBgView;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UIImageView *audioImage;
@property(nonatomic, strong) UIView *phoneBgView;
@property(nonatomic, strong) UIImageView *phoneImage;
@property(nonatomic, strong) UILabel *phoneLabel;
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
  [self.titleBgView addSubview:self.titleLabel];
  [NSLayoutConstraint activateConstraints:@[
    [self.titleLabel.topAnchor constraintEqualToAnchor:self.titleBgView.topAnchor],
    [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.titleBgView.leadingAnchor],
    [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.titleBgView.trailingAnchor],
    [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.titleBgView.bottomAnchor]
  ]];

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
    [self.infoBgView.heightAnchor constraintEqualToConstant:16],
    [self.infoBgView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
    [self.infoBgView.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor
                                                             constant:0],
    [self.infoBgView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
  ]];

  [self.infoBgView addSubview:self.audioImage];
  [NSLayoutConstraint activateConstraints:@[
    [self.audioImage.widthAnchor constraintEqualToConstant:16],
    [self.audioImage.heightAnchor constraintEqualToConstant:16],
    [self.audioImage.leadingAnchor constraintEqualToAnchor:self.infoBgView.leadingAnchor],
    [self.audioImage.bottomAnchor constraintEqualToAnchor:self.infoBgView.bottomAnchor]
  ]];
  [self.infoBgView addSubview:self.nameLabel];
  [NSLayoutConstraint activateConstraints:@[
    [self.nameLabel.heightAnchor constraintEqualToConstant:16],
    [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.audioImage.trailingAnchor],
    [self.nameLabel.trailingAnchor constraintEqualToAnchor:self.infoBgView.trailingAnchor],
    [self.nameLabel.bottomAnchor constraintEqualToAnchor:self.infoBgView.bottomAnchor]
  ]];
}
- (void)updateStateWithMember:(NERoomMember *)member isSelf:(BOOL)isSelf {
  self.titleLabel.text = member.name;
  self.nameLabel.text = member.name;
  self.audioImage.image =
      [NENeteaseMeetingUI ne_imageName:member.isAudioOn ? @"audio_on" : @"audio_off"];
  if (isSelf) {
    self.titleBgView.hidden = NO;
  } else {
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
#pragma mark------------------------ Getter ------------------------
- (UIView *)titleBgView {
  if (!_titleBgView) {
    _titleBgView = [[UIView alloc] initWithFrame:CGRectZero];
    _titleBgView.backgroundColor = UIColor.blackColor;
    _titleBgView.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return _titleBgView;
}
- (UILabel *)titleLabel {
  if (!_titleLabel) {
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.textColor = UIColor.whiteColor;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:16];
    _titleLabel.backgroundColor = UIColor.clearColor;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return _titleLabel;
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
    _phoneBgView.backgroundColor = UIColor.blackColor;
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
    _nameLabel.font = [UIFont systemFontOfSize:11];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return _nameLabel;
}
- (UIImageView *)audioImage {
  if (!_audioImage) {
    _audioImage =
        [[UIImageView alloc] initWithImage:[NENeteaseMeetingUI ne_imageName:@"audio_off"]];
    _audioImage.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return _audioImage;
}
@end
