// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 会议类型
enum NEMeetingType {
  /// 随机会议
  kRandom,

  /// 个人会议
  kPersonal,

  /// 预约会议
  kReservation,
}

extension MeetingTypeExtension on NEMeetingType {
  int get type {
    switch (this) {
      case NEMeetingType.kRandom:
        return 1;
      case NEMeetingType.kPersonal:
        return 2;
      case NEMeetingType.kReservation:
        return 3;
    }
  }

  static NEMeetingType fromType(int type) {
    switch (type) {
      case 2:
        return NEMeetingType.kPersonal;
      case 3:
        return NEMeetingType.kReservation;
      default:
        return NEMeetingType.kRandom;
    }
  }
}

/// 功能开关
class NEMeetingFeatureConfig {
  ///
  /// 是否开启录制
  ///
  final bool enableRecord;

  ///
  /// 是否开启直播
  ///
  final bool enableLive;

  ///
  /// 是否创建RTC房间
  ///
  final bool enableRtc;

  ///
  /// 是否创建聊天室
  ///
  final bool enableChatroom;

  ///
  /// 是否创建白板
  ///
  final bool enableWhiteboard;

  ///
  /// 是否开启Sip
  ///
  final bool enableSip;

  const NEMeetingFeatureConfig({
    this.enableRecord = false,
    this.enableChatroom = false,
    this.enableLive = false,
    this.enableRtc = true,
    this.enableWhiteboard = false,
    this.enableSip = false,
  });
}

/// 会议信息
class MeetingInfo {
  ///
  /// 会议ID
  ///
  late final int meetingId;

  ///
  /// 会议号
  ///
  late final String meetingNum;

  ///
  /// 对应 NERoom 房间ID
  ///
  late final String roomUuid;

  ///
  /// 会议类型
  ///
  late final NEMeetingType type;

  ///
  /// 会议主题
  ///
  late final String subject;

  ///
  /// 开始时间，单位毫秒
  ///
  late final int startTime;

  ///
  /// 结束时间，单位毫秒
  ///
  late final int endTime;

  ///
  /// 会议状态
  ///
  late final NEMeetingState state;

  ///
  /// 会议短号
  ///
  late final String? shortMeetingNum;

  ///
  /// sip号
  ///
  late final String? sipCid;

  /// meeting 配置相关
  late final MeetingSettings? settings;

  MeetingInfo.fromMap(Map map) {
    meetingId = map['meetingId'] as int;
    meetingNum = map['meetingNum'] as String;
    roomUuid = map['roomUuid'] as String;
    type = MeetingTypeExtension.fromType(map['type'] as int);
    subject = map['subject'] as String;
    startTime = map['startTime'] as int? ?? 0;
    endTime = map['endTime'] as int? ?? 0;
    state = _MeetingStateExtension.fromState(map['state'] as int);
    shortMeetingNum = map['shortMeetingNum'] as String?;
    sipCid = map['sipCid'] as String?;
    settings = MeetingSettings.fromMap(map['settings'] as Map?);
  }
}

class MeetingSettings {
  LiveConfig? liveConfig; // 直播配置
  MeetingSettings.fromMap(Map? map) {
    liveConfig = LiveConfig.fromMap(map?['liveConfig'] as Map?);
  }
}

class LiveConfig {
  String? liveAddress; // 直播地址
  LiveConfig.fromMap(Map? map) {
    liveAddress = map?['liveAddress'];
  }
}
