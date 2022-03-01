// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:service/model/login_info.dart';

import '../app_http_proto.dart';

class SwitchAppProto extends AppHttpProto<LoginInfo> {
  SwitchAppProto();

  @override
  String path() {
    return 'ne-meeting-account/switchApp';
  }

  @override
  LoginInfo result(Map map) {
    return LoginInfo.fromJson(map);
  }

  @override
  Map data() {
    return {};
  }
}
