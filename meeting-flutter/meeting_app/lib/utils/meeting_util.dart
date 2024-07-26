// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:netease_meeting_kit/meeting_kit.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';

class MeetingUtil {
  static String getNickName() {
    return AuthManager().nickName ?? '';
  }

  static String getMeetingNum() {
    return NEMeetingKit.instance
            .getAccountService()
            .getAccountInfo()
            ?.privateMeetingNum ??
        '';
  }

  static String getShortMeetingNum() {
    return NEMeetingKit.instance
            .getAccountService()
            .getAccountInfo()
            ?.privateShortMeetingNum ??
        '';
  }

  static bool hasShortMeetingNum() {
    return getShortMeetingNum() != '';
  }

  static String getMobilePhone() {
    return AuthManager().phoneNumber ?? '';
  }

  /// 未读消息数
  static ValueNotifier<int> _unreadNotifyMessageListenable = ValueNotifier(0);

  /// 设置未读消息数
  static setUnreadNotifyMessageListenable(value) {
    _unreadNotifyMessageListenable.value = value;
  }

  /// 获取未读消息数
  static ValueListenable<int> getUnreadNotifyMessageListenable() {
    return _unreadNotifyMessageListenable;
  }
}
