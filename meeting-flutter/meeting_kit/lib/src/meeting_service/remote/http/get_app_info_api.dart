// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class _GetAppInfoApi extends HttpApi<NEMeetingCorpInfo> {
  final String? baseUrl;
  final String? corpCode;
  final String? corpEmail;

  _GetAppInfoApi({
    this.baseUrl,
    this.corpCode,
    this.corpEmail,
  });

  @override
  String get method => 'GET';

  @override
  String path() {
    var base = baseUrl ?? '';
    if (base.isNotEmpty && !base.endsWith('/')) {
      base = '$base/';
    }
    return '${base}scene/meeting/v2/app-info';
  }

  @override
  NEMeetingCorpInfo result(Map map) {
    return NEMeetingCorpInfo.fromJson(map, corpCode: corpCode);
  }

  @override
  Map data() {
    return {
      if (corpCode != null) 'code': corpCode,
      if (corpEmail != null) 'email': corpEmail,
    };
  }
}
