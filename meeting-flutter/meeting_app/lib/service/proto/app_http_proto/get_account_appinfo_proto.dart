// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/model/account_app_info.dart';

import '../app_http_proto.dart';

class GetAccountAppInfoProto extends AppHttpProto<AccountAppInfo> {
  GetAccountAppInfoProto();

  @override
  String path() {
    return 'scene/meeting/${AuthManager().appKey}/v1/app/info';
  }

  @override
  String get method => 'GET';

  @override
  AccountAppInfo result(Map map) {
    return AccountAppInfo.fromJson(map);
  }

  @override
  Map data() {
    return {};
  }
}
