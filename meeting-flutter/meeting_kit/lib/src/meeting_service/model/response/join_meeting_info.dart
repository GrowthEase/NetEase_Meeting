// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class JoinRoomInfo {
  ///	随机会议码,9位数字；个人会议码，10位数字
  final String meetingId;

  /// 公有云音视频房间名称
  final String avRoomCName;

  ///公有云音视频房间id
  final String avRoomCid;

  ///公有云音视频房间成员uid
  final int avRoomUid;

  ///音视频服务器请求token
  final String avRoomCheckSum;

  ///会议创建时间，unix时间戳（单位：s）
  final int createTime;

  ///会议持续时间
  final int duration;

  /// 是否有全体禁音
  final int audioAllMute;

  /// 聊天室id, 创建参数chatRoom=1时返回, 为空表示改会议没有开启聊天室
  final String? chatRoomId;

  /// 推流地址: 创建参数live=1时返回, 为空表示改会议没有开启直播推流
  final String? pushUrl;

  /// 会议唯一key, 可用于获取直播参数
  //final String? meetingKey;

  /// nertc appKey
  final String nrtcAppKey;

  /// 会议录制开关，true开启，false关闭。
  final bool attendeeRecordOn;

  /// 白板账号
  final String? wbAccid;

  /// 白板token
  final String? wbToken;

  /// 白板key
  final String? wbKey;

  /// 白板auth信息
  final WhiteboardAuthInfo? whiteboardAuthInfo;

  /// 白板版本
  final String? whiteboardVer;

  /// 登陆G2版本 白板使用
  final int? wbUid;

  const JoinRoomInfo(
      {required this.meetingId,
      required this.avRoomCName,
      required this.avRoomCid,
      required this.avRoomUid,
      required this.avRoomCheckSum,
      required this.createTime,
      required this.duration,
      required this.audioAllMute,
      this.chatRoomId,
      this.pushUrl,
      //this.meetingKey,
      required this.nrtcAppKey,
      required this.attendeeRecordOn,
      required this.wbAccid,
      required this.wbToken,
      required this.wbKey,
      this.whiteboardAuthInfo,
      this.whiteboardVer,
      this.wbUid});

  factory JoinRoomInfo.fromMap(Map map) {
    return JoinRoomInfo(
        meetingId: map['meetingId'] as String,
        avRoomCName: map['avRoomCName'] as String,
        avRoomCid: map['avRoomCid'] as String,
        avRoomUid: map['avRoomUid'] as int,
        avRoomCheckSum: map['avRoomCheckSum'] as String,
        createTime: (map['createTime'] ?? 0) as int,
        duration: (map['duration'] ?? 0) as int,
        audioAllMute: (map['audioAllMute'] ?? 0) as int,
        chatRoomId: (map['chatRoomId'] as int?)?.toString(),
        pushUrl: map['pushUrl'] as String?,
        //meetingKey: map['meetingKey'] as String?,
        nrtcAppKey: map['nrtcAppKey'] as String,
        attendeeRecordOn: (map['attendeeRecordOn'] ?? false) as bool,
        wbAccid: (map['wbAccid'] ?? '') as String,
        wbToken: (map['wbToken'] ?? '') as String,
        wbKey: (map['wbKey'] ?? '') as String,
        whiteboardVer: (map['whiteboardVer'] ?? 'G1') as String,
        whiteboardAuthInfo: map['wbAuth'] == null
            ? null
            : (WhiteboardAuthInfo.fromMap((map['wbAuth']) as Map)),
        wbUid: map['wbUid'] as int?);
  }

  Map toMap() => {
        'meetingId': meetingId,
        'avRoomCName': avRoomCName,
        'avRoomCid': avRoomCid,
        'avRoomUid': avRoomUid,
        'avRoomCheckSum': avRoomCheckSum,
        'createTime': createTime,
        'duration': duration,
        'audioAllMute': audioAllMute,
        'chatRoomId': chatRoomId,
        'pushUrl': pushUrl,
        //'meetingKey': meetingKey,
        'nrtcAppKey': nrtcAppKey,
        'attendeeRecordOn': attendeeRecordOn,
        'wbAccid': wbAccid,
        'wbToken': wbToken,
        'wbKey': wbKey,
      };

  @override
  String toString() {
    return 'JoinRoomInfo{meetingId: $meetingId, avRoomCName: $avRoomCName, avRoomCid: $avRoomCid, avRoomUid: $avRoomUid, avRoomCheckSum: $avRoomCheckSum, createTime: $createTime, duration: $duration, audioAllMute: $audioAllMute, chatRoomId: $chatRoomId, pushUrl: $pushUrl, nrtcAppKey: $nrtcAppKey, attendeeRecordOn: $attendeeRecordOn, wbAccid: $wbAccid, wbToken: $wbToken, wbKey: $wbKey}';
  }
}

/// auth信息相关
class WhiteboardAuthInfo {
  int curTime;
  String nonce;
  String checksum;

  WhiteboardAuthInfo({
    required this.checksum,
    required this.curTime,
    required this.nonce,
  });

  factory WhiteboardAuthInfo.fromMap(Map map) {
    return WhiteboardAuthInfo(
        checksum: map['checksum'] as String,
        curTime: map['curTime'] as int,
        nonce: map['nonce'] as String);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['curTime'] = curTime;
    data['nonce'] = nonce;
    data['checksum'] = checksum;
    return data;
  }
}
