// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import '../model/security_notice_info.dart';
import '../repo/i_repo.dart';
import '../response/result.dart';

/// 用户信息
class UserRepo extends IRepo {
  UserRepo._internal();

  static final UserRepo _singleton = UserRepo._internal();

  factory UserRepo() => _singleton;

  /// 昵称修改
  Future<Result<void>> updateNickname(String nickName) {
    return appService.updateNickname(nickName);
  }

  /// 更新头像
  Future<Result<void>> updateAvatar(String url) {
    return appService.updateAvatar(url);
  }

  /// 安全提示接口
  Future<Result<AppNotifications>> getSecurityNoticeConfigs(
      String appKey, String time) {
    return appService.getSecurityNoticeConfigs(appKey, time);
  }
}
