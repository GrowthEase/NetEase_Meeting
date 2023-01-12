// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingConfig {
  // static final int _focusSwitchInterval = 6;

  /// audio low threshold
  static const int volumeLowThreshold = 10;

  /// join time out
  static const int joinTimeOutInterval = 45;

  static const int _defaultGridSide = 2;

  static int get defaultGridSide => _defaultGridSide;

  /// gridSide * gridSide
  /// /*/*/
  /// /*/*/
  // static final int _gridSize = _defaultGridSide * _defaultGridSide;

  /// min show grid size  must bigger than 2, because every page show self
  static const minGridSize = 2;

  /// gallery self render size
  static const int selfRenderSize = 2;

  factory MeetingConfig() =>
      _instance ??= (_instance = MeetingConfig._internal());

  static MeetingConfig? _instance;

  MeetingConfig._internal();

  static SDKConfig? globalConfig;

  int get pageSize {
    var i = SDKConfig.galleryPageSize;

    if (i < minGridSize) {
      i = minGridSize;
    }
    return i;
  }

  ///except me, server push every page size if null show default size,
  int get pageSizeExceptMe {
    return pageSize - 1;
  }

  int get focusSwitchInterval {
    return SDKConfig.focusSwitchInterval;
  }
}

///
/// 聊天室配置
///
class NEMeetingChatroomConfig {
  ///
  /// 是否允许发送/接收文件消息，默认打开。
  ///
  final bool enableFileMessage;

  ///
  /// 是否允许发送/接收图片消息，默认打开。
  ///
  final bool enableImageMessage;

  NEMeetingChatroomConfig({
    this.enableFileMessage = true,
    this.enableImageMessage = true,
  });

  factory NEMeetingChatroomConfig.fromJson(Map? json) {
    return NEMeetingChatroomConfig(
      enableFileMessage: json.getOrDefault('enableFileMessage', true),
      enableImageMessage: json.getOrDefault('enableImageMessage', true),
    );
  }
}
