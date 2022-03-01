// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:yunxin_meeting/meeting_sdk.dart';
import 'package:service/auth/auth_manager.dart';

class MeetingUtil{

  static String getNickName(){
    return AuthManager().nickName
        ?? NEMeetingSDK.instance.getAccountService().getAccountInfo()?.accountName ?? '';
  }

  static String getCurrentNickLeading() {
    final nickName = getNickName();
    return nickName.isNotEmpty ? nickName.substring(0, 1) : '';
  }

  static String getAppKey(){
    return AuthManager().appKey ?? '';
  }

  static String getMeetingId(){
    return NEMeetingSDK.instance.getAccountService().getAccountInfo()?.roomId ?? '';
  }

  static String getShortMeetingId(){
    return NEMeetingSDK.instance.getAccountService().getAccountInfo()?.shortRoomId ?? '';
  }

  static bool hasShortMeetingId(){
    return getShortMeetingId() != '';
  }

  static String getMobilePhone(){
    return AuthManager().mobilePhone ?? '';
  }
}