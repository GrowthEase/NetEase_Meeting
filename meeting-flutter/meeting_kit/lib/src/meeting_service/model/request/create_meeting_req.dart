// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class _CreateMeetingRequest {
  /// 会议主题
  final String? subject;

  /// 开始时间
  // final int? startTime;

  /// 结束时间
  // final int? endTime;

  /// 会议密码
  final String? password;

  /// 属性
  final Map? roomProperties;

  /// 设置成员角色
  final Map? roleBinds;

  /// 模版
  final int roomConfigId;

  /// 功能配置
  final NEMeetingFeatureConfig featureConfig;

  final bool enableWaitingRoom;

  // /// 画面状态 1：打开，2：关闭
  // final int video;
  //
  // /// 声音状态，1：打开，2：关闭
  // final int audio;
  //
  // /// 聊天室功能开关
  // final bool enableChatroom;
  //
  // /// 是否开启录制
  // final bool cloudRecordOn;
  //
  // ///会议中的成员标签，自定义，最大长度1024个字符
  // final String? tag;
  //
  // /// 透传字段，最大长度 2K
  // final String? extraData;
  //
  // ///场景信息
  // final Map? scene;
  //
  // final List<NERoomControl>? controls;
  //
  // /// 白板版本,默认G2
  // final String? whiteboardVer;

  const _CreateMeetingRequest({
    this.subject,
    // this.startTime,
    // this.endTime,
    this.password,
    this.enableWaitingRoom = false,
    this.roomProperties,
    this.roleBinds,
    required this.roomConfigId,
    required this.featureConfig,
  });

  Map get data => {
        'subject': subject,
        // if (startTime != null) 'startTime': startTime,
        // if (endTime != null) 'endTime': endTime,
        if (password != null) 'password': password,
        if (roomProperties?.isNotEmpty ?? false)
          'roomProperties': roomProperties,
        if (roleBinds?.isNotEmpty ?? false) 'roleBinds': roleBinds,
        'roomConfigId': roomConfigId,
        'roomConfig': {
          'resource': {
            'rtc': featureConfig.enableRtc,
            'chatroom': featureConfig.enableChatroom,
            'live': featureConfig.enableLive,
            'record': featureConfig.enableRecord,
            'whiteboard': featureConfig.enableWhiteboard,
            'sip': featureConfig.enableSip,
          }
        },
        'openWaitingRoom': enableWaitingRoom,
      };
}
