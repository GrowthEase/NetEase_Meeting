// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:service/model/account_app_info.dart';
import 'package:service/model/account_apps.dart';
import 'package:service/model/login_info.dart';
import 'package:service/repo/i_repo.dart';
import 'package:service/response/result.dart';

/// 获取公司信息
class AccountInfoRepo extends IRepo {
  AccountInfoRepo._internal();

  static final AccountInfoRepo _singleton = AccountInfoRepo._internal();

  factory AccountInfoRepo() => _singleton;

  /// 获取当前绑定用户公司信息
  Future<Result<AccountAppInfo>> getAccountAppInfo() {
    return appService.getAccountAppInfo();
  }

  ///获取当前用户所属的公司列表
  Future<Result<AccountApps>> getAccountApps() {
    return appService.getAccountApps();
  }

  ///切换公司
  Future<Result<LoginInfo>> switchApp(){
    return appService.switchApp();
  }

}
