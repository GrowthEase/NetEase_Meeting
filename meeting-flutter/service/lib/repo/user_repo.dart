// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:base/util/global_preferences.dart';
import 'package:service/model/security_notice_info.dart';
import 'package:service/repo/i_repo.dart';
import 'package:service/response/result.dart';

/// 用户信息
class UserRepo extends IRepo {
  UserRepo._internal();

  static final UserRepo _singleton = UserRepo._internal();

  factory UserRepo() => _singleton;

  /// 昵称修改
  Future<Result<void>> updateNickname(String nickName) {
    return appService.updateNickname(nickName);
  }

  /// 安全提示接口
  Future<Result<SecurityNoticeInfo>> getSecurityNoticeConfigs(String time) {
    return appService.getSecurityNoticeConfigs(time);
  }
}
