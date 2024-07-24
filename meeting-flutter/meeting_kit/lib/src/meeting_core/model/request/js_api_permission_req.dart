// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class JSApiPermissionRequest {
  final NEInjectedAuthorization? authorization;

  /// 应用标识
  final String pluginId;

  /// 应用用户标识
  final String? openId;

  /// 随机串
  final String nonce;

  /// 毫秒时间戳
  final int curTime;

  /// 签名
  final String checksum;

  /// 被授权页面
  final String url;

  const JSApiPermissionRequest({
    required this.authorization,
    required this.pluginId,
    required this.openId,
    required this.nonce,
    required this.curTime,
    required this.checksum,
    required this.url,
  });

  Map get data => {
        if (authorization != null) ...authorization!.toHeaders(),
        'pluginId': pluginId,
        'openId': openId,
        'nonce': nonce,
        'curTime': curTime,
        'checksum': checksum,
        'url': url,
      };

  Map<String, dynamic> header() => {
        if (authorization != null) ...authorization!.toHeaders(),
      };
}
