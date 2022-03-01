// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_plugin;

class NEForegroundServiceConfig {
  static final String defaultContentTitle = _Strings.defaultContentTitle;

  static final String defaultContentText = _Strings.defaultContentText;

  static final String defaultContentTicker = _Strings.defaultContentTicker;

  static final String defaultChannelId = _Strings.defaultChannelId;

  static final String defaultChannelName = _Strings.defaultChannelName;

  static final String defaultChannelDesc = _Strings.defaultChannelDesc;

  ///
  ///前台服务通知标题
  ///
  String contentTitle = defaultContentTitle;

  ///
  ///前台服务通知內容
  ///
  String contentText = defaultContentText;

  ///
  ///前台服务通知图标，如果不设置默认显示应用图标
  ///
  int smallIcon = 0;

  ///通知点击落页， 不配置默认应用首页
  String? launchClassName;

  ///前台服务通知提示
  String ticker = defaultContentTicker;

  ///
  ///前台服务通知通道id
  ///
  String channelId = defaultChannelId;

  ///
  ///台服务通知通道名称
  ///
  String channelName = defaultChannelName;

  ///
  ///前台服务通知通道描述
  ///
  String channelDesc = defaultChannelDesc;

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
    final config = new NEForegroundServiceConfig();
    config.contentTitle = map['contentTitle']?.toString() ?? defaultContentTitle;
    config.contentText = map['contentText']?.toString() ?? defaultContentText;
    config.smallIcon = map['smallIcon'] as int? ?? 0;
    config.launchClassName = map['launchClassName']?.toString();
    config.ticker = map['ticker']?.toString() ?? defaultContentTicker;
    config.channelId = map['channelId']?.toString() ?? defaultChannelId;
    config.channelName = map['channelName']?.toString() ?? defaultChannelName;
    config.channelDesc = map['channelDesc']?.toString() ?? defaultChannelDesc;
    return config;
  }
}
