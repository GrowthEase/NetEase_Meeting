// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class InMeetingMemberInfo {
  /// 视频会议帐号id
  late final String accountId;

  /// 视频会议帐号昵称
  late String nickName;

  /// 视频状态，1：有，2：无（自己关闭），3：无（主持人禁），4：无（主持人解禁，但自己关闭）
  late int video;

  /// 声音状态，1：有，2：无（自己关闭），3：无（主持人禁），4：无（主持人解禁，但自己关闭）
  late int audio;

  /// 音视频房间成员uid
  late final int avRoomUid;

  /// 用户状态  1：占位， 2：在线
  /// [MemberStatus]
  late final int status;

  /// 幕共享状态 0:非共享中，1：共享中
  late int screenSharing;

  /// 会议成员入会占位毫秒时间戳
  late int placeHolderTime;

  /// 举手信息, 可能有多种状态的举手信息
  late List<HandsUp> handsUp;

  /// 成员客户端类型
  late int clientType;

  /// 成员客户端类型
  ///http://doc.hz.netease.com/pages/viewpage.action?pageId=278096374
  /// 成员标签
  late String? memberTag;

  /// 角色身份，1成员，2主持人，3管理员，4隐藏
  /// [RoleType]
  late int roleType;

  /// 白板互动权限状态，0关闭，1开启[InteractionStatus]
  late int whiteBoardInteract;

  ///会议中的成员标签，自定义，最大长度1024个字符
  late String tag;

  static InMeetingMemberInfo fromMap(Map map) {
    var member = InMeetingMemberInfo();
    member.accountId = map['accountId'] as String;
    member.nickName = map['nickName'] as String;
    member.video = map['video'] as int;
    member.audio = map['audio'] as int;
    member.avRoomUid = map['avRoomUid'] as int;
    member.status = (map['status'] ?? MemberStatus.online) as int; //TV无该字段
    member.screenSharing = (map['screenSharing'] ?? 0) as int;
    member.handsUp = HandsUp.fromArrays(map['handsUps'] as List?) ?? [];
    member.clientType = map['clientType'] as int;
    member.roleType = (map['roleType'] ?? RoleType.normal) as int;
    member.memberTag = map['memberTag'] as String?;
    member.whiteBoardInteract =
        (map['whiteBoardInteract'] ?? InteractionStatus.close) as int;
    member.tag = (map['memberTag'] ?? '') as String;
    return member;
  }

  bool get isOnline => status == MemberStatus.online;

  static List<InMeetingMemberInfo>? fromArrays(List? members) {
    if (members == null || members.isEmpty) {
      return null;
    }
    return members.map((item) {
      return InMeetingMemberInfo.fromMap(item as Map);
    }).toList();
  }

  @override
  String toString() {
    return 'MemberInfo{accountId: $accountId, nickName: $nickName,tag: $tag, video: $video, '
        'audio: $audio, avRoomUid: $avRoomUid, status: $status, '
        'screenSharing: $screenSharing, clientType: $clientType,memberTag:$memberTag}';
  }

  /// 当前静音举手状态
  bool isAudioHandsUp() {
    return handsUp.any((e) => (e.handsUpType == HandsUpType.muteAll &&
        e.status == NEHandsUpStatus.up));
  }

  /// 白板互动权限状态，0关闭，1开启
  bool hasWhiteBoardInteract() {
    return whiteBoardInteract == InteractionStatus.open;
  }

  /// 更新白板互动权限状态，0关闭，1开启
  bool updateWhiteBoardInteract(int value) {
    return whiteBoardInteract == value;
  }

  /// 更新静音举手状态
  void updateMuteAllHandsUp(bool up) {
    handsUp
        .removeWhere((element) => element.handsUpType == HandsUpType.muteAll);
    handsUp.add(
      HandsUp(
        handsUpType: HandsUpType.muteAll,
        status: (up ? NEHandsUpStatus.up : NEHandsUpStatus.down),
        handsUpTime: (up ? DateTime.now().millisecondsSinceEpoch : -1),
      ),
    );
  }

  int getAudioHandsUpTime() {
    if (isAudioHandsUp()) {
      for (final element in handsUp) {
        if (element.handsUpType == HandsUpType.muteAll) {
          return element.handsUpTime;
        }
      }
    }
    return -1;
  }
}

class MemberStatus {
  /// 占位状态
  /// 已经请求会议服务的start、join接口
  /// 但会议服务还没有收到加入音视频房间的抄送
  static final int reserved = 1;

  /// 已经加入到音视频房间
  /// 抄送已经发送到会议应用服务器
  static final int online = 2;
}
