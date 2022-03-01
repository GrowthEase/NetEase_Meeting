// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:service/model/account_apps.dart';

import '../app_http_proto.dart';

class GetAccountAppsInfoProto extends AppHttpProto<AccountApps> {
  GetAccountAppsInfoProto();

  @override
  String path() {
    return 'ne-meeting-account/getAccountApps';
  }

  @override
  AccountApps result(Map map) {
    return AccountApps.fromJson(map);
  }

  @override
  Map data() {
    return {};
  }
}
