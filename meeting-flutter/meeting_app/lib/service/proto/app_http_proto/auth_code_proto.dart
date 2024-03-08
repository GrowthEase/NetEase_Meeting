// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import '../app_http_proto.dart';
import 'package:nemeeting/service/config/servers.dart';

class GetMobileCheckCodeProto extends AppHttpProto<void> {
  final String appKey;

  /// 手机号
  final String mobile;

  final type = 1; // 验证码类型，1.自动注册并登录

  GetMobileCheckCodeProto(this.appKey, this.mobile);

  @override
  String get method => 'GET';

  @override
  String path() {
    return '${servers.baseUrl}scene/meeting/$appKey/v1/sms/$mobile/$type';
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
