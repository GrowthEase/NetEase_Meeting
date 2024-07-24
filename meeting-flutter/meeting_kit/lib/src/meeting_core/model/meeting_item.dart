// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

///  预定房间item
abstract class NEMeetingItem {
  factory NEMeetingItem.createScheduleMeetingItem() => _MeetingItemImpl();

  factory NEMeetingItem() => _MeetingItemImpl();

  NEMeetingItem._();

  /// 会议唯一标识
  int? get meetingId;

  /// 会议号
  String? get meetingNum;

  /// 设置会议主题
  set subject(String? subject);

  /// 获取会议主题
  String? get subject;

  /// 设置会议开始时间，单位毫秒。在编辑预约会议时，如果设置为0，则不调整会议开始时间
  set startTime(int start);

  /// 获取会议开始时间戳（标准UNIX时间戳格式，单位为ms）
  int get startTime;

  /// 设置会议结束时间，单位毫秒。在编辑预约会议时，如果设置为0，则不调整会议结束时间
  set endTime(int end);

  /// 获取会议结束时间戳（标准UNIX时间戳格式，单位为ms）
  int get endTime;

  /// 开启sip功能, 默认为 true
  set noSip(bool? enable);

  /// 获取会议是否支持sip，默认为 true
  bool get noSip;

  /// 开启/关闭等候室
  void setWaitingRoomEnabled(bool enabled);

  /// 等候室是否开启
  bool get waitingRoomEnabled;

  /// 查询是否允许成员在主持人入会前加入，默认为 true
  bool get enableJoinBeforeHost;

  /// 设置是否允许成员在主持人入会前加入
  void setEnableJoinBeforeHost(bool enable);

  /// 查询是否允许访客入会
  bool get enableGuestJoin;

  /// 设置是否允许访客入会
  void setEnableGuestJoin(bool enable);

  /// 设置会议密码， 为空表示不设置密码
  set password(String? password);

  /// 获取会议密码
  String? get password;

  /// 预定会议参数设置
  set settings(NEMeetingItemSetting setting);

  /// 获取会议参数设置
  NEMeetingItemSetting get settings;

  /// 设置会议状态
  set status(NEMeetingItemStatus status);

  /// 会议状态
  NEMeetingItemStatus get status;

  /// 会议类型
  NEMeetingType? get meetingType;

  /// 会议邀请链接
  String? get inviteUrl;

  /// 房间号
  String? get roomUuid;

  /// 创建人id
  String? ownerUserUuid;

  /// 创建人昵称
  String? ownerNickname;

  /// 会议短号
  String? shortMeetingNum;

  /// 获取会议直播信息设置
  NEMeetingItemLive? get live;

  /// 会议直播信息设置
  set live(NEMeetingItemLive? live);

  /// 扩展字段
  String? get extraData;

  /// 设置扩展字段
  set extraData(String? extraData);

  /// 设置角色
  set roleBinds(Map<String, NEMeetingRoleType>? roleBinds);

  /// 获取角色
  Map<String, NEMeetingRoleType>? get roleBinds;

  /// 获取周期性会议规则
  NEMeetingRecurringRule get recurringRule;

  /// 设置周期性会议规则
  set recurringRule(NEMeetingRecurringRule recurringRule);

  /// 预约指定成员列表,后台配置开启预定成员功能时有效
  List<NEScheduledMember>? get scheduledMemberList;

  /// 获取预约指定成员列表
  set scheduledMemberList(List<NEScheduledMember>? list);

  /// 获取时区ID
  String? get timezoneId;

  /// 设置时区ID
  set timezoneId(String? timezoneId);

  /// 获取同声传译设置。为空或译员列表为空表示关闭同声传译
  NEMeetingInterpretationSettings? get interpretationSettings;

  /// 设置同声传译设置。如果设置为null或译员列表为空，则表示关闭同声传译
  set interpretationSettings(NEMeetingInterpretationSettings? value);

  /// 获取云录制配置
  NECloudRecordConfig? get cloudRecordConfig;

  /// 设置云录制配置
  set cloudRecordConfig(NECloudRecordConfig? value);

  /// 获取sip号
  String? get sipCid;

  /// 设置sip号
  set sipCid(String? sipCid);

  Map toJson();

  Map request();

  /// 深拷贝
  NEMeetingItem copy();

  static NEMeetingItem fromJson(Map<dynamic, dynamic> map) {
    return _MeetingItemImpl._fromJson(map);
  }

  static NEMeetingItem fromNativeJson(Map<dynamic, dynamic> map) {
    return _MeetingItemImpl._fromNativeJson(map);
  }
}

/// 用于预约会议时设置预选成员
class NEScheduledMember {
  /// 用户id
  String userUuid;

  /// 用户角色
  String role;

  NEScheduledMember({required this.userUuid, required this.role});

  Map<String, dynamic> toJson() {
    return {
      'userUuid': userUuid,
      'role': role,
    };
  }

  factory NEScheduledMember.fromJson(Map<dynamic, dynamic> map) {
    return NEScheduledMember(
      userUuid: map['userUuid'],
      role: map['role'],
    );
  }

  /// copy函数
  NEScheduledMember copy() {
    return NEScheduledMember(
      userUuid: userUuid,
      role: role,
    );
  }
}

extension NEScheduledMemberExt on NEScheduledMember {
  /// 选择成员排序
  static int compareMember(NEScheduledMember lhs, NEScheduledMember rhs,
      String? myUserUuid, String? ownerUuid) {
    if (myUserUuid == lhs.userUuid) {
      return -1;
    }
    if (myUserUuid == rhs.userUuid) {
      return 1;
    }
    if (ownerUuid == lhs.userUuid) {
      return -1;
    }
    if (ownerUuid == rhs.userUuid) {
      return 1;
    }
    if (lhs.role == MeetingRoles.kHost) {
      return -1;
    }
    if (rhs.role == MeetingRoles.kHost) {
      return 1;
    }
    if (lhs.role == MeetingRoles.kCohost) {
      return -1;
    }
    if (rhs.role == MeetingRoles.kCohost) {
      return 1;
    }
    return -1;
  }
}
