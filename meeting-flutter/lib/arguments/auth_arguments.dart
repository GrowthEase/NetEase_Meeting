// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:service/config/scene_type.dart';

///修改密码的类型：1、忘记密码 2、设置页面修改密码
enum ResetPwdSceneType { forgetPwd, settingModify }

class AuthArguments {
  String? mobile;
  String? verifyCode;         //短信校验码
  String? verifyExchangeCode;  //验证成功后的内部请求码，用于后续请求，如注册、重置密码等
  SceneType? sceneType;
  ResetPwdSceneType? fromWhere;

  @override
  String toString() {
    return 'mobile = $mobile, verifyCode = $verifyCode, verifyExchangeCode=$verifyExchangeCode, sceneType = $sceneType, '
        'fromWhere = '
        '$fromWhere';
  }
}
