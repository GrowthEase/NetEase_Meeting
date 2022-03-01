// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:base/util/textutil.dart';

class HttpCode {
  static const int cancel = -4;
  static const int meetingSDKLoginError = -3;
  static const int imLoginError = -2;
  static const int netWorkError = -1;
  static const int success = 200;
  static const int paramsError = 300;
  static const int paramsNull = 301;
  static const int serverInnerError = 302;
  static const int feedbackOk = 401;
  static const int notFound = 404;
  static const int netTimeout = 408;
  static const int netError = 415;
  static const int serverError = 501;
  static const int allocationAccountFail = 1000;
  static const int fetchAccountFail = 1001;
  static const int controlNotAllocationAccount = 1002;
  static const int phoneAlreadyRegister = 1003;
  static const int phoneNotRegister = 1004;
  static const int tokenError = 1005;
  static const int verifyError = 1006;
  static const int loginPasswordError = 1007;
  static const int passwordError = 1008;
  static const int tvAccountNotExist = 1009;
  static const int illegalPhone = 1010;
  static const int smsCodeOverLimit = 1011;
  static const int verifyInvalid = 1012;
  static const int accountNotExist = 1014;
  static const int meetingNotExist = 2000;
  static const int meetingMemberOverLimit = 2001;
  static const int alreadyInMeeting = 2002;
  static const int nickError = 2003;
  static const int memberVideoError = 2004;
  static const int memberAudioError = 2005;
  static const int roomCidIsEmpty = 2006;
  static const int memberNotHasMeetingId = 2007;
  static const int notJoinMeetingCannotKick = 2008;
  static const int screenShareOverLimit = 2009;
  static const int notHostPermission = 2100;
  static const int memberNotInMeeting = 2101;
  static const int controlCodeError = 2102;

  static String getMsg(String? msg, [String? defaultMsg]) {
    if (TextUtil.isEmpty(msg)) {
      return TextUtil.isEmpty(defaultMsg) ? '网络连接失败，请检查你的网络连接！' : defaultMsg!;
    }
    return msg!;
  }
}
