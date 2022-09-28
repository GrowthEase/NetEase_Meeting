// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_meeting_core/meeting_kit.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';

class MeetingUtil {
  static String getNickName() {
    return AuthManager().nickName ??
        NEMeetingKit.instance.getAccountService().getAccountInfo()?.nickname ??
        '';
  }

  static String getCurrentNickLeading() {
    final nickName = getNickName();
    return nickName.isNotEmpty ? nickName.substring(0, 1) : '';
  }

  static String getAppKey() {
    return AuthManager().appKey ?? '';
  }

  static String getMeetingId() {
    return NEMeetingKit.instance
            .getAccountService()
            .getAccountInfo()
            ?.privateMeetingNum ??
        '';
  }

  static String getShortMeetingId() {
    return NEMeetingKit.instance
            .getAccountService()
            .getAccountInfo()
            ?.privateShortMeetingNum ??
        '';
  }

  static bool hasShortMeetingId() {
    return getShortMeetingId() != '';
  }

  static String getMobilePhone() {
    return AuthManager().mobilePhone ?? '';
  }

  static bool getAutoRegistered() {
    return AuthManager().autoRegistered ?? false;
  }
}
