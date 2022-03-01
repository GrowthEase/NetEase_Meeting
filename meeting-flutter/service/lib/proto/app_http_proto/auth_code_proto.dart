// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:service/config/scene_type.dart';

import '../app_http_proto.dart';

class AuthCodeProto extends AppHttpProto<void> {
  /// 手机号
  final String mobile;

  /// 场景
  final SceneType scene;

  AuthCodeProto(this.mobile, this.scene);

  @override
  String path() {
    return 'ne-meeting-account/sendMobileVerifyCode';
  }

  @override
  void result(Map map) {
    return null;
  }

  @override
  Map data() {
    return {'mobile': mobile, 'scene': scene.index};
  }

  @override
  bool checkLoginState() {
    return false;
  }
}
