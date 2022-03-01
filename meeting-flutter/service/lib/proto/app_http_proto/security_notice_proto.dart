// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:service/model/security_notice_info.dart';

import '../app_http_proto.dart';

class SecurityNoticeProto extends AppHttpProto<SecurityNoticeInfo> {
  /// 时间戳
  late final String time;

  SecurityNoticeProto(this.time);

  @override
  String path() {
    return 'ne-meeting-app/getConfigs';
  }

  @override
  SecurityNoticeInfo result(Map map) {
    return SecurityNoticeInfo.fromJson(map);
  }

  @override
  Map data() {
    return {'time': time};
  }
}
