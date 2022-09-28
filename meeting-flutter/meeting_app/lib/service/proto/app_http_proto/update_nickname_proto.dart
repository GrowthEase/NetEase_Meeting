// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/service/auth/auth_manager.dart';

import '../app_http_proto.dart';

class UpdateNicknameProto extends AppHttpProto<void> {
  /// 昵称
  final String nickname;
  UpdateNicknameProto(this.nickname);

  @override
  String path() {
    return 'scene/meeting/${AuthManager().appKey}/v1/account/nickname';
  }

  @override
  void result(Map map) {
    return null;
  }

  @override
  Map data() {
    return {
      'nickname': nickname,
    };
  }
}
