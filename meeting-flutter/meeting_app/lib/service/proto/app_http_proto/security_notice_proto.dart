// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/service/config/servers.dart';
import 'package:nemeeting/service/model/security_notice_info.dart';

import '../app_http_proto.dart';

class SecurityNoticeProto extends AppHttpProto<AppNotifications> {
  final String appKey;

  /// 时间戳
  final String time;

  SecurityNoticeProto(this.appKey, this.time);

  @override
  String get method => 'GET';

  @override
  String path() {
    return '${servers.baseUrl}scene/meeting/$appKey/v1/tips?time=$time';
  }

  @override
  AppNotifications result(Map map) {
    return AppNotifications.fromJson(appKey, map);
  }

  @override
  Map data() => {};
}
