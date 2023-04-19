// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
class HistoryMeeting {
  /// 参会记录id
  final int attendeeId;

  /// 房间归档id/唯一id
  final int roomArchiveId;

  /// 会议号
  final String meetingNum;

  /// 会议标题
  final String subject;

  /// 会议类型
  final int type;

  /// 参会时间 毫秒
  final int roomEntryTime;

  /// 会议开始时间，毫秒
  final int roomStartTime;

  /// 创建人userUuid
  final String ownerUserUuid;

  /// 创建人昵称
  final String ownerNickname;

  /// 是否收藏
  bool? isFavorite;

  /// 收藏id
  int? favoriteId;

  HistoryMeeting(
      this.attendeeId,
      this.roomArchiveId,
      this.meetingNum,
      this.subject,
      this.type,
      this.roomEntryTime,
      this.roomStartTime,
      this.ownerUserUuid,
      this.ownerNickname,
      this.isFavorite,
      this.favoriteId);
  HistoryMeeting.group(int entryTime)
      : this(0, 0, "", "", 0, entryTime, 0, "", "", null, null);
  // HistoryMeeting(
  //   this.attendeeId,
  //   this.roomArchiveId,
  //   this.meetingNum,
  //   this.subject,
  //   this.type,
  //   this.roomEntryTime,
  //   this.roomStartTime,
  //   this.ownerUserUuid,
  //   this.ownerNickname,
  //   this.isFavorite,
  //   this.favoriteId
  // )

  HistoryMeeting.fromJson(Map json)
      : attendeeId = json["attendeeId"] as int,
        roomArchiveId = json["roomArchiveId"] as int,
        meetingNum = json["meetingNum"] as String,
        subject = json["subject"] as String,
        type = json["type"] as int,
        roomEntryTime = json["roomEntryTime"] as int,
        roomStartTime = json["roomStartTime"] as int,
        ownerUserUuid = json["ownerUserUuid"] as String,
        ownerNickname = json["ownerNickname"] as String,
        isFavorite = json["isFavorite"] as bool?,
        favoriteId = json["favoriteId"] as int?;

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['attendeeId'] = attendeeId;
    map["roomArchiveId"] = roomArchiveId;
    map["meetingNum"] = meetingNum;
    map["subject"] = subject;
    map["type"] = type;
    map["roomEntryTime"] = roomEntryTime;
    map["roomStartTime"] = roomStartTime;
    map["ownerUserUuid"] = ownerUserUuid;
    map["ownerNickname"] = ownerNickname;
    map["isFavorite"] = isFavorite;
    map["favoriteId"] = favoriteId;
    return map;
  }
}

class FavoriteMeeting {
  int favoriteId;
  int roomArchiveId;
  String meetingNum;
  String subject;
  int type;
  int roomEntryTime;
  int roomStartTime;
  String ownerUserUuid;
  String ownerNickname;
  FavoriteMeeting(
      this.favoriteId,
      this.roomArchiveId,
      this.meetingNum,
      this.subject,
      this.type,
      this.roomEntryTime,
      this.roomStartTime,
      this.ownerUserUuid,
      this.ownerNickname);
  FavoriteMeeting.group(int entryTime)
      : this(0, 0, "", "", 0, entryTime, 0, "", "");

  FavoriteMeeting.fromJson(Map json)
      : favoriteId = json["favoriteId"] as int,
        roomArchiveId = json["roomArchiveId"] as int,
        meetingNum = json["meetingNum"] as String,
        subject = json["subject"] as String,
        type = json["type"] as int,
        roomEntryTime = json["roomEntryTime"] as int,
        roomStartTime = json["roomStartTime"] as int,
        ownerUserUuid = json["ownerUserUuid"] as String,
        ownerNickname = json["ownerNickname"] as String;
}
