// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

///  预定房间item
abstract class NEMeetingItem {
  factory NEMeetingItem.createScheduleRoomItem() => _MeetingItemImpl();

  factory NEMeetingItem() => _MeetingItemImpl();

  NEMeetingItem._();

  ///[NEMeetingType]
  int? get meetingType;

  set meetingType(int? meetingType);

  /// 会议号
  String? get meetingNum;

  /// 会议短号
  String? get shortMeetingNum;

  /// 模版id
  int? get roomConfigId;

  /// 预定成功后会议号
  String? get roomUuid;

  /// h会议id,取消会议，编辑会议使用
  int? get meetingId;

  /// 设置会议主题
  set subject(String? subject);

  /// 获取会议主题
  String? get subject;

  /// 设置会议开始时间， 毫秒
  set startTime(int start);

  /// 获取会议开始时间
  int get startTime;

  /// 设置会议结束时间， 毫秒
  set endTime(int end);

  /// 获取会议结束时间
  int get endTime;

  /// 设置会议密码， 为空表示不设置密码
  set password(String? password);

  /// 获取会议密码
  String? get password;

  /// 预定会议参数设置
  set settings(NEMeetingItemSettings setting);

  /// 获取会议参数设置
  NEMeetingItemSettings get settings;

  /// 会议状态
  NEMeetingState get state;

  /// 扩展字段
  String? get extraData;

  set extraData(String? extraData);

  NEMeetingItemLive? get live;

  set live(NEMeetingItemLive? live);

  set roleBinds(Map<String, NEMeetingRoleType>? roleBinds);

  Map<String, NEMeetingRoleType>? get roleBinds;

  /// 开启sip功能, 默认为关闭[enable]:true
  set noSip(bool? enable);

  /// 获取会议是否支持sip,[noSip]默认为 true
  bool get noSip;

  String? get inviteUrl;

  Map toJson();

  Map request();

  static NEMeetingItem fromJson(Map<dynamic, dynamic> map) {
    return _MeetingItemImpl._fromJson(map);
  }

  static NEMeetingItem fromNativeJson(Map<dynamic, dynamic> map) {
    return _MeetingItemImpl._fromNativeJson(map);
  }
}
