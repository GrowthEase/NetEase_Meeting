// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

///登录 web 直播页的鉴权级别，0：不需要鉴权，1：需要登录，2：需要登录并且账号要与直播应用绑定。不填的话表示不需要鉴权
enum NELiveAuthLevel {
  /// 不需要鉴权
  normal,

  /// 需要登录
  token,

  /// 需要登录并且账号要与直播应用绑定
  appToken,
}

const normal = 0;
const token = 1;
const appToken = 2;

extension LiveAuthLevelExtension on NELiveAuthLevel {
  int get value {
    switch (this) {
      case NELiveAuthLevel.normal:
        return normal;
      case NELiveAuthLevel.token:
        return token;
      case NELiveAuthLevel.appToken:
        return appToken;
      default:
        return normal;
    }
  }

  static NELiveAuthLevel get(int mode) {
    switch (mode) {
      case normal:
        return NELiveAuthLevel.normal;
      case token:
        return NELiveAuthLevel.token;
      case appToken:
        return NELiveAuthLevel.appToken;
      default:
        return NELiveAuthLevel.normal;
    }
  }
}
