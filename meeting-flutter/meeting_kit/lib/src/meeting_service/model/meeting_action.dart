// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

abstract class MeetingAction {
  final int type;
  String? roomCid;

  MeetingAction(this.type);

  @mustCallSuper
  void fromJson(Map map) {
    roomCid = (map['room_cid'] ?? map['avRoomCid']) as String?;
  }
}

abstract class MeetingSubTypeAction extends MeetingAction {
  final int subType;

  MeetingSubTypeAction(int type, this.subType) : super(type);
}

class TCAction extends MeetingAction {
  late final String toAccountId;
  late final String fromAccountId;
  late final Map data;

  TCAction() : super(ActionType.tc);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    toAccountId = map['toAccountId'] as String;
    fromAccountId = map['fromAccountId'] as String;
    data = map['data'] as Map;
  }
}

/// 音频子类型@see [AudioSubType]
class AudioAction extends MeetingSubTypeAction {
  ///  user id 来自于谁的操作 ，自己操作自己填自己帐号，主持人操作填主持人帐号 (摇控器填写TV 的)
  late final String fromUser;

  /// 禁音/取消禁音
  late final int muteAudio;

  /// 被操作对象user id ，为空(没有或者"")的话，指全体禁音/解除， 读取subType来处理
  late final String? operateUser;

  AudioAction(int? subType)
      : super(ActionType.controlAudio, subType ?? AudioSubType.unknown);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    fromUser = map['from_user'] as String;
    muteAudio = map['mute_audio'] as int;
    operateUser = map['oper_user'] as String?;
  }
}

/// 举手子类型@see [HandsUpSubType]
class HandsUpAction extends MeetingSubTypeAction {
  ///  user id 来自于谁的操作 ，自己操作自己填自己帐号
  late final String fromUser;

  /// 举手
  late final HandsUp handsUp;

  /// 被操作对象user id
  late final String operateUser;

  HandsUpAction(int subType) : super(ActionType.handsUp, subType);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    fromUser = map['from_user'] as String;
    handsUp = HandsUp.fromMap(map['hands_up'] as Map) as HandsUp;
    operateUser = map['oper_user'] as String;
  }
}

class VideoAction extends MeetingSubTypeAction {
  ///  user id 来自于谁的操作 ，自己操作自己填自己帐号，主持人操作填主持人帐号 (摇控器填写TV 的)
  late final String fromUser;

  /// 关闭/开启视频
  late final int muteVideo;

  /// 被操作对象user id
  late final String operateUser;

  VideoAction(int? subType)
      : super(ActionType.controlVideo, subType ?? VideoSubType.unknown);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    fromUser = map['from_user'] as String;
    muteVideo = map['mute_video'] as int;
    operateUser = map['oper_user'] as String;
  }
}

class FocusAction extends MeetingAction {
  /// 设置/取消焦点
  late final bool isFocus;

  /// 被操作对象user id
  late final String operateUser;

  FocusAction() : super(ActionType.controlFocus);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    isFocus = (map['is_focus'] ?? false) as bool;
    operateUser = map['oper_user'] as String;
  }
}

class HostAction extends MeetingAction {
  /// 被操作对象user id
  late final String operateUser;

  HostAction() : super(ActionType.controlHost);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    operateUser = map['oper_user'] as String;
  }
}

class NickAction extends MeetingAction {
  /// 更新昵称user id
  late final String userId;

  /// 昵称更新后的值
  late final String nick;

  NickAction() : super(ActionType.updateNick);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    userId = map['user_id'] as String;
    nick = map['nick'] as String;
  }
}

class ScreenShareAction extends MeetingAction {
  static const int notShare = 0;

  static const int share = 1;

  /// 更新昵称user id
  late final String userId;

  /// 0:非共享状态,1:共享状态
  late final int screenSharing;
  late final int userAvRoomUid;
  late final int operUserAvRoomUid;

  ScreenShareAction() : super(ActionType.screenShare);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    userId = map['user_id'] as String;
    screenSharing = map['screen_sharing'] as int;
    userAvRoomUid = map['user_av_room_uid'] as int;
    operUserAvRoomUid = map['oper_user_av_room_uid'] as int;
  }

  @override
  String toString() {
    return 'ScreenShareAction{userId: $userId, '
        'screenSharing: $screenSharing, user_av_room_uid: $userAvRoomUid, '
        'oper_user_av_room_uid: $operUserAvRoomUid}';
  }
}

/// 60.开启白板，61.关闭白板，
class WhiteBoardShareAction extends MeetingAction {
  ///白板共享人roomUid
  late final int sharerAvRoomUid;

  /// 操作人roomUid
  late final int operatorAvRoomUid;

  /// 白板拥有者imAccid
  late final String sharerImAccid;

  WhiteBoardShareAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    sharerAvRoomUid = map['sharerAvRoomUid'] as int;
    operatorAvRoomUid = map['operatorAvRoomUid'] as int;
    sharerImAccid = map['sharerImAccid'] as String;
  }

  @override
  String toString() {
    return 'WhiteBoardShareAction{sharerAvRoomUid: $sharerAvRoomUid, operatorAvRoomUid: $operatorAvRoomUid, sharerImAccid: $sharerImAccid}';
  }
}

class Audio2VideoAction extends MeetingAction {
  Audio2VideoAction(int type) : super(type);
}

class Video2AudioAction extends MeetingAction {
  Video2AudioAction(int type) : super(type);
}

class WhiteboardInteractionAction extends MeetingAction {
  static const int undoMemberWhiteboardInteraction = 0;

  static const int awardedMemberWhiteboardInteraction = 1;

  ///白板共享人roomUid
  late final int sharerAvRoomUid;

  /// 白板被共享人roomUid
  late final int sharedAvRoomUid;

  /// 操作人roomUid
  late final int operatorAvRoomUid;

  /// 白板拥有者imAccid
  late final String sharerImAccid;

  /// 白板互动权限状态，0关闭，1开启
  late final int whiteBoardInteract;

  WhiteboardInteractionAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    sharerAvRoomUid = map['sharerAvRoomUid'] as int;
    sharedAvRoomUid = map['sharedAvRoomUid'] as int;
    operatorAvRoomUid = map['operatorAvRoomUid'] as int;
    sharerImAccid = map['sharerImAccid'] as String;
    if (type == ActionType.awardedMemberWhiteboardInteraction) {
      whiteBoardInteract = awardedMemberWhiteboardInteraction;
    } else if (type == ActionType.undoMemberWhiteboardInteraction) {
      whiteBoardInteract = undoMemberWhiteboardInteraction;
    }
  }

  @override
  String toString() {
    return 'WhiteboardInteractionAction{sharerAvRoomUid: $sharerAvRoomUid, '
        'sharedAvRoomUid: $sharedAvRoomUid, operatorAvRoomUid: $operatorAvRoomUid, '
        'sharerImAccid: $sharerImAccid, whiteBoardInteract: $whiteBoardInteract}';
  }
}

class MemberChangeAction extends MeetingAction {
  /// 用户信息变更
  late final String userId;

  MemberChangeAction() : super(ActionType.memberChange);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    userId = map['user_id'] as String;
  }
}

class MeetingLockAction extends MeetingAction {
  /// int,1:允许所有人加入,2:不允许任何加入
  late final int joinControlType;

  MeetingLockAction() : super(ActionType.meetingLock);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    joinControlType = map['join_control_type'] as int;
  }
}

/// 预约房间状态变更通知
class ScheduledRoomStatusChangeAction extends MeetingAction {
  late final List<NEMeetingItem> list;

  ScheduledRoomStatusChangeAction() : super(ActionType.meetingInfoChange);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    var links = (map['meetingList'] ?? []) as List;
    list = links
        .map<NEMeetingItem>((e) => NEMeetingItem.fromJson(e as Map))
        .toList();
  }
}

class AuthInfoExpiredAction extends MeetingAction {
  AuthInfoExpiredAction() : super(ActionType.authInfoExpired);

  late final String uid;
  late final String deviceId;

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    uid = map['user_id'] as String;
    deviceId = map['device_id'] as String;
  }
}

class MeetingLiveAction extends MeetingAction {
  /// 会议直播状态
  late final NERoomItemLiveState state;

  /// 会议直播标题
  late final String title;

  /// 直播聊天室是否可用
  late final bool liveChatRoomEnable;

  /// 直播任务id
  late final String taskId;

  /// 直播成员id
  late final List<int> liveAVRoomUids;

  /// 直播布局
  late final int liveLayout;

  /// 直播密码
  late final String? password;

  ///登录 web 直播页的鉴权级别，0：不需要鉴权，1：需要登录，2：需要登录并且账号要与直播应用绑定。不填的话表示不需要鉴权
  late final int liveWebAccessControlLevel;

  MeetingLiveAction() : super(ActionType.live);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    var _state = (map['state'] ?? 0) as int;
    state = _state >= 0 && _state < NERoomItemLiveState.values.length
        ? NERoomItemLiveState.values[_state]
        : NERoomItemLiveState.invalid;
    title = map['title'] as String;
    liveChatRoomEnable = (map['live_chat_room_enable'] ?? false) as bool;
    taskId = map['task_id'] as String;
    liveAVRoomUids = (map['live_av_room_uids'] as List).cast<int>();
    liveLayout = (map['live_layout'] ?? LiveLayoutType.gallery) as int;
    password = map['password'] as String?;
    liveWebAccessControlLevel = map['live_web_access_control_level'] as int;
  }
}

/// 邀请通知
class RoomInvitationAction extends MeetingAction {
  late final NERoomInvitation invitation;

  /// 邀请人uid, 房间uid
  late final int inviterRtcId;

  /// 预留，邀请通话类型，0:p2p，1:多人会议，2:加入第三方sip
  late final int inviteType;

  RoomInvitationAction() : super(ActionType.invitation);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    inviterRtcId = map.remove('inviterUid') as int;
    inviteType = map.remove('inviteType') as int;
    invitation = NERoomInvitation(
      sipNum: map.remove('sipNum') as String,
      sipHost: map.remove('sipHost') as String,
    );
  }
}
