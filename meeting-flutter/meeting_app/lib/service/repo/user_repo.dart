// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_common/netease_common.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

import '../repo/i_repo.dart';
import '../response/result.dart';

/// 用户信息
class UserRepo extends IRepo {
  UserRepo._internal();

  static final UserRepo _singleton = UserRepo._internal();

  factory UserRepo() => _singleton;

  /// 昵称修改
  Future<VoidResult> updateNickname(String nickname) {
    return NEMeetingKit.instance.getAccountService().updateNickname(nickname);
  }

  /// 更新头像
  Future<VoidResult> updateAvatar(String imagePath) {
    return NEMeetingKit.instance.getAccountService().updateAvatar(imagePath);
  }

  /// 安全提示接口
  Future<NEResult<NEMeetingAppNoticeTips>> getSecurityNoticeConfigs() {
    return NEMeetingKit.instance.getAppNoticeTips();
  }
}
