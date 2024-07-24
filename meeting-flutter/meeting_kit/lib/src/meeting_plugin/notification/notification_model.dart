// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_plugin;

class NEForegroundServiceConfig {
  ///
  ///前台服务通知标题
  ///
  final String contentTitle;

  ///
  ///前台服务通知內容
  ///
  final String contentText;

  ///
  ///前台服务通知图标，如果不设置默认显示应用图标
  ///
  final int smallIcon;

  ///
  ///通知点击落页， 不配置默认应用首页
  ///
  final String? launchClassName;

  ///
  ///前台服务通知提示
  ///
  final String ticker;

  ///
  ///前台服务通知通道id
  ///
  final String channelId;

  ///
  ///台服务通知通道名称
  ///
  final String channelName;

  ///
  ///前台服务通知通道描述
  ///
  final String channelDesc;

  NEForegroundServiceConfig({
    required this.contentTitle,
    required this.contentText,
    required this.ticker,
    required this.channelId,
    required this.channelName,
    required this.channelDesc,
    this.smallIcon = 0,
    this.launchClassName,
  });

  _toMap() => {
        'contentTitle': contentTitle,
        'contentText': contentText,
        'smallIcon': smallIcon,
        'launchClassName': launchClassName,
        'ticker': ticker,
        'channelId': channelId,
        'channelName': channelName,
        'channelDesc': channelDesc,
      };

  static NEForegroundServiceConfig? fromMap(Map? map) {
    if (map == null) {
      return null;
    }
    return NEForegroundServiceConfig(
      contentTitle: map['contentTitle'] as String,
      contentText: map['contentText'] as String,
      ticker: map['ticker'] as String,
      channelId: map['channelId'] as String,
      channelName: map['channelName'] as String,
      channelDesc: map['channelDesc'] as String,
      smallIcon: map['smallIcon'] as int? ?? 0,
      launchClassName: map['launchClassName'] as String?,
    );
  }
}
