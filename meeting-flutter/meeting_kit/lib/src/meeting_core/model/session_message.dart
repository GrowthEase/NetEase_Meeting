// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class NEMeetingSessionMessage {
  late final String? sessionId;
  late final NEMeetingSessionTypeEnum? sessionType;
  late final String? messageId;
  late final String? data;

  /// 时间戳，单位为ms
  late final int time;

  NEMeetingSessionMessage({
    this.sessionId,
    this.sessionType,
    this.messageId,
    this.data,
    int? time,
  }) : time = time ?? 0;

  NEMeetingSessionMessage.fromMap(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
    sessionType = NEMeetingSessionTypeEnumExtension.toType(json['sessionType']);
    messageId = json['messageId'];
    time = json['time'] ?? 0;
    // data = json['data'] != null ? NotifyCardData.fromMap(json['data']) : null;
    data = json['data'];
  }

  toMap() {
    final Map<String, dynamic> dataMap = Map<String, dynamic>();
    dataMap['sessionId'] = sessionId;
    dataMap['sessionType'] = sessionType?.value;
    dataMap['messageId'] = messageId;
    dataMap['time'] = time;
    if (data != null) {
      dataMap['data'] = data;
    }
    return dataMap;
  }
}

/// 查询自定义消息历史的参数
class NEMeetingGetMessageHistoryParams {
  /// 获取聊天对象的Id（好友帐号，群ID等） 会话Id
  final String sessionId;

  /// 查询开启时间点
  int? fromTime;

  /// 查询截止时间点
  int? toTime;

  /// 条数限制
  /// 限制0~100，否则414。其中0会被转化为100
  int? limit;

  /// 查询方向,默认从大到小排序
  NEMeetingMessageSearchOrder? order = NEMeetingMessageSearchOrder.kDesc;

  NEMeetingGetMessageHistoryParams(
      {required this.sessionId,
      this.fromTime,
      this.toTime,
      this.limit,
      this.order});

  NEMeetingGetMessageHistoryParams.fromMap(Map<String, dynamic> json)
      : sessionId = json['sessionId'] ?? '',
        fromTime = json['fromTime'] ?? 0,
        toTime = json['toTime'] ?? 0,
        limit = json['limit'] ?? 0,
        order = NEMeetingMessageSearchOrderExtension.toType(
            json['order'] ?? NEMeetingMessageSearchOrder.kDesc.index);
}

extension NEMeetingMessageSearchOrderExtension on NEMeetingMessageSearchOrder {
  static NEMeetingMessageSearchOrder toType(int? type) =>
      (NEMeetingMessageSearchOrder.values.firstWhere(
        (element) => element.index == type,
        orElse: () => NEMeetingMessageSearchOrder.kDesc,
      ));
}

/// 会话消息类型
///
enum NEMeetingSessionTypeEnum {
  /// 未知
  None(-1),

  /// 个人会话
  P2P(0);

  final int value;
  const NEMeetingSessionTypeEnum(this.value);
}

/// 消息查询方向
///
enum NEMeetingMessageSearchOrder {
  /// 从小到大,降序
  kDesc,

  /// 从大到小,升序
  kAsc,
}

/// 会议消息类型
extension NEMeetingSessionTypeEnumExtension on NEMeetingSessionTypeEnum {
  static NEMeetingSessionTypeEnum toType(int? type) =>
      (NEMeetingSessionTypeEnum.values.firstWhere(
        (element) => element.value == type,
        orElse: () => NEMeetingSessionTypeEnum.None,
      ));
}

/// 最近联系人消息变更
class NEMeetingRecentSession {
  ///  获取聊天对象的Id（好友帐号，群ID等）
  /// [sessionId] 会话Id
  ///
  final String? sessionId;

  /// 获取与该联系人的最后一条消息的发送方的帐号
  /// [fromAccount] 发送者帐号
  final String? fromAccount;

  /// 获取与该联系人的最后一条消息的发送方的昵称
  /// [fromNick]发送者昵称
  ///
  final String? fromNick;

  /// 会话类型
  ///
  final NEMeetingSessionTypeEnum? sessionType;

  /// 最近一条消息的UUID
  final String? recentMessageId;

  /// 该联系人的未读消息条数
  /// 未读数
  final int unreadCount;

  /// 最近一条消息的缩略内容
  final String? content;

  /// 最近一条消息的时间，单位为ms
  ///
  final int time;

  NEMeetingRecentSession(
      this.sessionId,
      this.fromAccount,
      this.fromNick,
      this.sessionType,
      this.recentMessageId,
      this.unreadCount,
      this.content,
      this.time);

  toMap() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['sessionId'] = sessionId;
    data['fromAccount'] = fromAccount;
    data['fromNick'] = fromNick;
    data['sessionType'] = sessionType?.value;
    data['recentMessageId'] = recentMessageId;
    data['unreadCount'] = unreadCount;
    data['content'] = content;
    data['time'] = time;
    return data;
  }
}
