// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class _ResetPasswordApi extends HttpApi<NELoginInfo> {
  final String oldPassword;
  final String newPassword;
  final String userUuid;

  _ResetPasswordApi({
    required this.userUuid,
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  String get method => 'POST';

  @override
  String path() => 'scene/meeting/v2/password';

  @override
  NELoginInfo result(Map map) =>
      NELoginInfo.fromJson(appKey: ServiceRepository().appKey, map);

  @override
  Map<String, dynamic>? header() {
    return {
      'appKey': ServiceRepository().appKey,
    };
  }

  @override
  Map data() {
    return {
      'userUuid': userUuid,
      'password': hash(oldPassword),
      'newPassword': hash(newPassword),
    };
  }

  String hash(String password) {
    return '$password@yiyong.im'.md5;
  }
}
