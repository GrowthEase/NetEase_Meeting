// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 通讯录用户信息获取
class _GetContactsInfoApi extends HttpApi<NEContactsInfoResponse> {
  /// 需要查询的userUuid
  List<String> userUuids;

  _GetContactsInfoApi(this.userUuids);

  @override
  String path() =>
      'scene/meeting/${ServiceRepository().appKey}/v1/account-list';

  @override
  String get method => 'POST';

  @override
  NEContactsInfoResponse parseResult(dynamic data) {
    return NEContactsInfoResponse.fromJson(data);
  }

  @override
  Object? data() => jsonEncode(userUuids);
}
