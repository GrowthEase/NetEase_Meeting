// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 通讯录搜索
class _SearchContactsApi extends HttpApi<List<NEContact>> {
  /// 名字，支持模糊匹配
  String? name;

  /// 手机号，精确匹配
  String? phoneNumber;

  /// 每页大小，不传取默认20
  int? pageSize;

  /// 页码，不传取默认1
  int? pageNum;

  _SearchContactsApi(this.name, this.phoneNumber, this.pageSize, this.pageNum);

  @override
  String path() {
    var url = 'scene/meeting/${ServiceRepository().appKey}/v1/account-search?';
    if (name != null) {
      url += 'name=$name&';
    }
    if (phoneNumber != null) {
      url += 'phoneNumber=$phoneNumber&';
    }
    if (pageSize != null) {
      url += 'pageSize=$pageSize&';
    }
    if (pageNum != null) {
      url += 'pageNum=$pageNum&';
    }
    url = url.removeSuffix('&');
    return url;
  }

  @override
  String get method => 'GET';

  @override
  List<NEContact> parseResult(dynamic data) {
    List list = data as List;
    if (list.isNotEmpty) {
      return list.map((e) {
        assert(e is Map);
        final item = e as Map<String, dynamic>;
        return NEContact.fromJson(item);
      }).toList();
    }
    return [];
  }

  @override
  Map data() => {};
}
