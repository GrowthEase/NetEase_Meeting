// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// 会议历史记录对象
class NEHistoryMeetingItem {
  /// 会议唯一ID
  final int meetingUniqueId;

  /// 会议ID
  final String meetingId;

  /// 会议短号
  final String? shortMeetingId;

  /// 会议主题
  final String subject;

  /// 会议密码
  final String? password;

  /// 会议昵称
  String nickname;

  /// sipId
  String? sipId;

  NEHistoryMeetingItem({
    required this.meetingUniqueId,
    required this.meetingId,
    this.shortMeetingId,
    required this.subject,
    this.password,
    this.sipId,
    required this.nickname,
  });

  static NEHistoryMeetingItem? fromJson(Map<dynamic, dynamic>? json) {
    if (json == null) return null;
    try {
      return NEHistoryMeetingItem(
          meetingUniqueId: json['meetingUniqueId'] as int,
          meetingId: json['meetingId'] as String,
          shortMeetingId: json['shortMeetingId'] as String?,
          password: json['password'] as String?,
          subject: json['subject'] as String,
          nickname: json['nickname'] as String,
          sipId: json['sipId'] as String?,
      );
    }catch(e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'meetingUniqueId': meetingUniqueId,
        'meetingId': meetingId,
        'shortMeetingId': shortMeetingId,
        'password': password,
        'subject': subject,
        'nickname': nickname,
        'sipId': sipId,
      };
}
