// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class NERemoteHistoryMeeting {
  /// 参会记录id，查询时可做分页用
  final int? anchorId;

  /// 会议唯一 Id
  final int meetingId;

  /// 会议号
  final String meetingNum;

  /// 会议标题
  final String subject;

  /// 会议类型
  final NEMeetingType type;

  /// 参会时间 毫秒
  final int roomEntryTime;

  /// 会议开始时间，毫秒
  final int roomStartTime;

  /// 会议结束时间，毫秒
  final int roomEndTime;

  /// 创建人头像
  final String? ownerAvatar;

  /// 创建人userUuid
  final String ownerUserUuid;

  /// 创建人昵称
  final String ownerNickname;

  /// 时区Id
  final String? timezoneId;

  /// 收藏id，如果未收藏则为null
  int? _favoriteId;

  int? get favoriteId => _favoriteId;

  set favoriteId(int? value) {
    _favoriteId = value;
  }

  /// 是否已收藏
  bool get isFavorite => favoriteId != null;

  NERemoteHistoryMeeting({
    this.anchorId,
    this.meetingId = 0,
    this.meetingNum = '',
    this.subject = '',
    this.type = NEMeetingType.kRandom,
    this.roomEntryTime = 0,
    this.roomStartTime = 0,
    this.roomEndTime = 0,
    this.ownerAvatar,
    this.ownerUserUuid = '',
    this.ownerNickname = '',
    int? favoriteId,
    this.timezoneId,
  }) : _favoriteId = favoriteId;

  NERemoteHistoryMeeting copyWith({
    int? anchorId,
    int? meetingId,
    String? meetingNum,
    String? subject,
    NEMeetingType? type,
    int? roomEntryTime,
    int? roomStartTime,
    int? roomEndTime,
    String? ownerAvatar,
    String? ownerUserUuid,
    String? ownerNickname,
    int? favoriteId,
    String? timezoneId,
  }) {
    return NERemoteHistoryMeeting(
      anchorId: anchorId ?? this.anchorId,
      meetingId: meetingId ?? this.meetingId,
      meetingNum: meetingNum ?? this.meetingNum,
      subject: subject ?? this.subject,
      type: type ?? this.type,
      roomEntryTime: roomEntryTime ?? this.roomEntryTime,
      roomStartTime: roomStartTime ?? this.roomStartTime,
      roomEndTime: roomEndTime ?? this.roomEndTime,
      ownerAvatar: ownerAvatar ?? this.ownerAvatar,
      ownerUserUuid: ownerUserUuid ?? this.ownerUserUuid,
      ownerNickname: ownerNickname ?? this.ownerNickname,
      favoriteId: favoriteId ?? this.favoriteId,
      timezoneId: timezoneId ?? this.timezoneId,
    );
  }

  /// 解析服务器数据
  NERemoteHistoryMeeting.fromJson(Map json)
      : anchorId = json["attendeeId"] as int?,
        meetingId = json["roomArchiveId"] as int,
        meetingNum = json["meetingNum"] as String,
        subject = json["subject"] as String,
        type = MeetingTypeExtension.fromType(json["type"] as int),
        roomEntryTime = json["roomEntryTime"] as int,
        roomStartTime = json["roomStartTime"] as int,
        roomEndTime = json["roomEndTime"] as int,
        ownerAvatar = json["ownerAvatar"] as String?,
        ownerUserUuid = json["ownerUserUuid"] as String,
        ownerNickname = json["ownerNickname"] as String,
        _favoriteId = json["favoriteId"] as int?,
        timezoneId = json["timezoneId"] as String?;

  /// 给native组件
  Map<String, dynamic> toJson() => {
        "anchorId": anchorId,
        "meetingId": meetingId,
        "meetingNum": meetingNum,
        "subject": subject,
        "type": type.type,
        "roomEntryTime": roomEntryTime,
        "roomStartTime": roomStartTime,
        "roomEndTime": roomEndTime,
        "ownerAvatar": ownerAvatar,
        "ownerUserUuid": ownerUserUuid,
        "ownerNickname": ownerNickname,
        "favoriteId": _favoriteId,
        "timezoneId": timezoneId
      };
}
