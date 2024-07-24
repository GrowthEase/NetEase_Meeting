// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class _LoginBySmsApi extends HttpApi<NEAccountInfo> {
  final String mobile;

  final String verifyCode;

  _LoginBySmsApi(this.mobile, this.verifyCode);

  @override
  String path() {
    return 'scene/meeting/${ServiceRepository().appKey}/v1/mobile/$mobile/login';
  }

  @override
  Map data() => {
        'verifyCode': verifyCode,
      };

  @override
  NEAccountInfo result(Map map) {
    return NEAccountInfo.fromMap(map);
  }
}
