// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class TVStatus{
  late final int code;
  late final int avRoomUid;
  late final String nick;
  late String tvNick; //修改昵称会重新赋值，不能定义为final
  late final int muteVideo;
  late final int muteAudio;
  late final int isFocus;
  late final String? masterUserId;
  ///0: 初始状态 ， 1 ： 正在创建会议  、 2：正在加入会议 ，  3： 正在会议中
  late final int status;
  late final String? meetingId;
  String? msg;
  late final String userId;
  late final String? meetingToken;
  late final String deviceId;
  late int showType;

  static TVStatus fromJson(Map map) {
    var tvStatus = TVStatus();
    tvStatus.code = (map['code'] ?? 0) as int;
    tvStatus.avRoomUid = (map['avRoomUid'] ?? 0) as int;
    tvStatus.nick = (map['nickName'] ?? '') as String;
    tvStatus.tvNick = (map['tvNickName'] ?? '') as String;
    tvStatus.muteVideo = map['video'] as int;
    tvStatus.muteAudio = map['audio'] as int ;
    tvStatus.isFocus = map['isFocus'] as int;
    tvStatus.masterUserId = map['hostAccountId'] as String?;
    tvStatus.status = map['status'] as int;
    tvStatus.meetingId = map['meetingId'] as String?;
    tvStatus.msg = map['msg'] as String?;
    tvStatus.userId = map['accountId'] as String;
    tvStatus.meetingToken = map['meetingToken'] as String?;
    tvStatus.deviceId = map['deviceId'] as String;
    tvStatus.showType = (map['showType'] ?? showTypePresenter) as int;
    return tvStatus;
  }

  @override
  String toString() {
    return 'TVStatus{code: $code, avRoomUid: $avRoomUid, nick: $nick, muteVideo: $muteVideo, muteAudio: $muteAudio, '
        'isFocus: $isFocus, masterUserId: $masterUserId, status: $status, meetingId: $meetingId, msg: $msg, userId: $userId, '
        'meetingToken: $meetingToken, deviceId: $deviceId, showType: $showType}';
  }
}

class StatusType {
  static const int init = 0;
  static const int creating = 1;
  static const int joining = 2;
  static const int meeting = 3;
}
