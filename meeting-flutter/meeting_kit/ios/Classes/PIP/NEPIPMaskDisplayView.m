// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEPIPMaskDisplayView.h"

@interface NEPIPMaskDisplayView ()

@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *tipsLabel;

@end

@implementation NEPIPMaskDisplayView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupSubviews];
  }
  return self;
}

- (void)setContent:(NSString *)content {
  _content = content;
  self.tipsLabel.text = content;
}

- (void)setName:(NSString *)name {
  _name = name;
  self.nameLabel.text = name;
}

- (void)setupSubviews {
  [self addSubview:self.nameLabel];
  [NSLayoutConstraint activateConstraints:@[
    [self.nameLabel.heightAnchor constraintEqualToConstant:16],
    [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
    [self.nameLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor],
    [self.nameLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
  ]];

  [self addSubview:self.tipsLabel];
  [NSLayoutConstraint activateConstraints:@[
    [self.tipsLabel.topAnchor constraintEqualToAnchor:self.topAnchor],
    [self.tipsLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
    [self.tipsLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
    [self.tipsLabel.bottomAnchor constraintEqualToAnchor:self.nameLabel.topAnchor]
  ]];
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

- (UILabel *)tipsLabel {
  if (!_tipsLabel) {
    _tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _tipsLabel.numberOfLines = 0;
    _tipsLabel.backgroundColor = UIColor.blackColor;
    _tipsLabel.textColor = UIColor.whiteColor;
    _tipsLabel.textAlignment = NSTextAlignmentCenter;
    _tipsLabel.font = [UIFont systemFontOfSize:11];
    _tipsLabel.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return _tipsLabel;
}

@end
