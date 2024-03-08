// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import '../app_http_proto.dart';

class ReportYiDunTokenProto extends AppHttpProto<void> {
  final String appKey;
  final String user;
  final String token;

  ReportYiDunTokenProto(this.appKey, this.user, this.token);

  @override
  String path() {
    return 'antispam/apps/$appKey/users/$user/yiduntoken';
  }

  @override
  String get method => 'POST';

  @override
  void result(Map map) {
    return null;
  }

  @override
  Map data() => {
        'yidunToken': token,
      };
}
