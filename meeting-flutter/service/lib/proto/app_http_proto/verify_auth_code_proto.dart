// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:service/config/scene_type.dart';

import '../app_http_proto.dart';

class VerifyAuthCodeProto extends AppHttpProto<String> {
  ///手机号
  final String mobile;

  ///验证码
  final String verifyCode;

  ///场景值
  final SceneType scene;

  VerifyAuthCodeProto(this.mobile, this.verifyCode, this.scene);

  @override
  String path() {
    return 'ne-meeting-account/checkMobileVerifyCode';
  }

  @override
  String result(Map map) {
    return map['exchangeCode'] as String;
  }

  @override
  Map data() {
    return {'mobile': mobile, 'verifyCode': verifyCode, 'scene': scene.index};
  }

  @override
  bool checkLoginState() {
    return false;
  }
}
