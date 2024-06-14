// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class _GetMobileCheckCodeApi extends HttpApi<void> {
  static const int _typeForLogin = 1;

  /// 手机号
  final String mobile;

  final int type; // 验证码类型，1.自动注册并登录

  _GetMobileCheckCodeApi(this.mobile, this.type);

  _GetMobileCheckCodeApi.forLogin(this.mobile) : type = _typeForLogin;

  @override
  String get method => 'GET';

  @override
  String path() {
    return 'scene/meeting/${ServiceRepository().appKey}/v1/sms/$mobile/$type';
  }

  @override
  void result(Map map) {
    return null;
  }

  @override
  Map data() {
    return const {};
  }

  @override
  bool checkLoginState() {
    return false;
  }
}
