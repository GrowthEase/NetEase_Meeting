// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:service/model/account_app_info.dart';

import '../app_http_proto.dart';

class GetAccountAppInfoProto extends AppHttpProto<AccountAppInfo> {

  GetAccountAppInfoProto();

  @override
  String path() {
    return 'ne-meeting-account/getAccountAppInfo';
  }

  @override
  AccountAppInfo result(Map map) {
    return AccountAppInfo.fromJson(map);
  }

  @override
  Map data() {
    return {};
  }

}
