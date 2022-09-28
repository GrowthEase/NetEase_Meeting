// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/service/config/app_config.dart';
import 'package:nemeeting/service/config/scene_type.dart';

import '../app_http_proto.dart';
import 'package:nemeeting/service/config/servers.dart';

class AuthCodeProto extends AppHttpProto<void> {
  /// 手机号
  final String mobile;

  /// 场景
  final SceneType scene;

  final type = 1; // 验证码类型，1.自动注册并登录

  AuthCodeProto(this.mobile, this.scene);

  @override
  String get method => 'GET';

  @override
  String path() {
    return '${servers.baseUrl}scene/meeting/${AppConfig().appKey}/v1/sms/$mobile/$type';
  }

  @override
  void result(Map map) {
    return null;
  }

  @override
  Map data() {
    // return {'mobile': mobile, 'scene': scene.index};
    return const {};
  }

  @override
  bool checkLoginState() {
    return false;
  }
}
