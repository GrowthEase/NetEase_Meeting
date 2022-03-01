// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:base/util/textutil.dart';

class UpgradeInfo {
  ///网易会议客户端最新版本码
  late final int latestVersionCode;

  ///跳转外部下载地址, 此地址不能作为应用内更新下载使用
  late final String url;

  ///更新内容详细描述
  late final String description;

  ///更新内容提示
  late final String title;

  ///本次更新是否提示用户，0：不提示，1：提示
  late final int notify;

  ///强制更新的版本码，小于等于此版本号应用需要强制更新
  late final int forceVersionCode;

  /// 下载文件md5
  late final String md5;

  /// 下载文件地址
  late final String downloadUrl;

  static UpgradeInfo fromJson(Map map) {
    var info = UpgradeInfo();
    info.latestVersionCode = map['latestVersionCode'] as int;
    info.url = map['url'] as String;
    info.description = TextUtil.decodeBase64((map['description'] ?? '') as String);
    info.title = TextUtil.decodeBase64((map['title'] ?? '') as String);
    info.notify = map['notify'] as int;
    info.forceVersionCode = map['forceVersionCode'] as int;
    info.md5 = (map['checkCode'] ?? '')as String;
    info.downloadUrl = map['downloadUrl'] as String;
    return info;
  }

Map toJson() => {
        'latestVersionCode': latestVersionCode,
        'url': url,
        'description': TextUtil.encodeBase64(description),
        'title': TextUtil.encodeBase64(title),
        'notify': notify,
        'forceVersionCode': forceVersionCode,
        'checkCode': md5,
        'downloadUrl': downloadUrl,
      };
}
