// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/service/auth/auth_manager.dart';

import '../app_http_proto.dart';

class UpdateAvatarProto extends AppHttpProto<void> {
  /// 头像URL
  final String url;
  UpdateAvatarProto(this.url);

  @override
  String path() {
    return 'scene/meeting/${AuthManager().appKey}/v1/account/avatar';
  }

  @override
  void result(Map map) {
    return null;
  }

  @override
  Map data() {
    return {
      'avatar': url,
    };
  }
}
