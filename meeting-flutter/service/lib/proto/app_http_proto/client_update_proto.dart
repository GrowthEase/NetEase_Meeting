// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:base/manager/device_manager.dart';
import 'package:service/config/servers.dart';
import 'package:service/model/client_upgrade_info.dart';

import '../app_http_proto.dart';

class ClientUpdateProto extends AppHttpProto<UpgradeInfo> {
  // 账号ID，灰度升级使用
  final String? accountId;
  ///客户端versionCode
  final int versionCode;
  ///客户端versionName
  final String versionName;
  ///业务code：目前支持1-2，2为企业邮会议app
  final int clientAppCode;

  ClientUpdateProto(this.accountId, this.versionName, this.versionCode, this.clientAppCode);

  @override
  Map<String, dynamic> header() {
    return {'clientType': DeviceManager().clientType, 'sdkVersion': versionName};
  }

  @override
  Map data() {
    return {
      if(accountId != null) 'accountId': accountId,
      'versionCode': versionCode,
      'clientAppCode': clientAppCode,
    };
  }

  @override
  String path() {
    return '${servers.oldBaseUrl}client/latestVersion';
  }

  @override
  UpgradeInfo result(Map map) {
    return UpgradeInfo.fromJson(map);
  }
}
