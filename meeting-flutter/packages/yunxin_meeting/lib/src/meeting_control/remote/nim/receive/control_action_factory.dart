// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class ControlActionData extends MeetingAction {
  //和遥控器配对的遥控器的deviceId
  late final String controllerDeviceId;

  final int subType;

  ControlActionData(int type, [this.subType = 0]) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    controllerDeviceId = map['controllerDeviceId'] as String;
  }
}

class TCControlChangeAction extends ControlActionData {
  TCControlChangeAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
  }
}

class TCAudioAction extends ControlActionData {
  late String fromUser;
  late int muteAudio;
  late String operateUser;

  TCAudioAction(int type, int subType) : super(type, subType);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    fromUser = map['fromAccountId'] as String;
    muteAudio = map['audio'] as int;
    operateUser = map['operAccountId'] as String;
  }
}

class TCSelfAudioAction extends ControlActionData {
  late int muteAudio;

  TCSelfAudioAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    muteAudio = map['audio'] as int;
  }
}

class TCHostAudioAction extends ControlActionData {
  late String fromUser;
  late int muteAudio;
  late int allowAudioOn;
  late String operateUser;

  TCHostAudioAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    fromUser = map['fromAccountId'] as String;
    muteAudio = map['audio'] as int;
    allowAudioOn = map['allowSelfAudioOn'] as int;
    operateUser = map['operAccountId'] as String;
  }
}

class TCVideoAction extends ControlActionData {
  late String fromUser;
  late int muteVideo;
  late String operateUser;

  TCVideoAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    fromUser = map['fromAccountId'] as String;
    muteVideo = map['video'] as int;
    operateUser = map['operAccountId'] as String;
  }
}

class TCSelfVideoAction extends ControlActionData {
  int? muteVideo;

  TCSelfVideoAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    muteVideo = map['video'] as int?;
  }
}

class TCHostVideoAction extends ControlActionData {
  late String fromUser;
  late int muteVideo;
  late String operateUser;

  TCHostVideoAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    fromUser = map['fromAccountId'] as String;
    muteVideo = map['video'] as int;
    operateUser = map['operAccountId'] as String;
  }
}

class TCChangeHostAction extends ControlActionData {
  late final String operateAccountId;

  TCChangeHostAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    operateAccountId = map['operAccountId'] as String;
  }
}

class TCChangeFocusAction extends ControlActionData {
  late String operateUser;
  late bool isFocus;

  TCChangeFocusAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    operateUser = map['operAccountId'] as String;
    isFocus = map['isFocus'] as bool;
  }
}

class TCScreenShareAction extends ControlActionData {
  static const int notShare = 0;

  static const int share = 1;

  /// 更新昵称user id
  late String userId;

  /// 0:非共享状态,1:共享状态
  late int screenSharing;

  TCScreenShareAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    userId = map['accountId'] as String;
    screenSharing = map['screenSharing'] as int;
  }
}

class TCRemoveAttendeeAction extends ControlActionData {
  late String operateUser;

  TCRemoveAttendeeAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    operateUser = map['operAccountId'] as String;
  }
}

class TCLeaveMeetingAction extends ControlActionData {
  int? reason;

  TCLeaveMeetingAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    reason = map['reason'] as int?;
  }
}

class TCUserJoinedAction extends ControlActionData {
  String? msg;
  late int uid;

  TCUserJoinedAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    msg = map['msg'] as String?;
    uid = map['accountId'] as int;
  }
}

class TCRequestJoinersResultAction extends ControlActionData {
  late List<int> uidList;

  TCRequestJoinersResultAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    uidList = map['avRoomUidList'] as List<int>;
  }
}

class TCRequestMembersResultAction extends ControlActionData {
  late int code;
  late int requestId;
  MeetingInfo? meetingInfo;

  TCRequestMembersResultAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    code = map['code'] as int;
    requestId = map['requestId'] as int;
    meetingInfo = MeetingInfo.fromMap(null, map);
  }
}

class TCCheckUpdateResultAction extends ControlActionData {
  late int requestId;
  late bool hasNewVersion;

  TCCheckUpdateResultAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    requestId = map['requestId'] as int;
    hasNewVersion = map['hasNewVersion'] as bool;
  }
}

class TCFeedbackAction extends ControlActionData {
  late String meetingId;
  late int channelId;
  late String deviceId;
  late String category;
  late String des;

  TCFeedbackAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    meetingId = map['meetingId'] as String;
    channelId = map['channelId'] as int;
    deviceId = map['deviceId'] as String;
    category = map['category'] as String;
    des = map['description'] as String;
  }
}

class TCUserLeaveAction extends ControlActionData {
  String? msg;
  late int uid;

  TCUserLeaveAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    msg = map['msg'] as String?;
    uid = map['accountId'] as int;
  }
}

class TCUnBindResultAction extends ControlActionData {
  late int action;

  TCUnBindResultAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    action = map['action'] as int;
  }
}

class TCControlCreateOrJoinAction extends ControlActionData {
  late int code;
  String? msg;
  late int requestId;
  late String meetingId;
  late int avRoomUid;
  late int audioAllMute;

  TCControlCreateOrJoinAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    code = map['code'] as int;
    msg = map['msg'] as String?;
    requestId = map['requestId'] as int;
    meetingId = (map['meetingId'] ?? '') as String;
    avRoomUid = (map['avRoomUid'] ?? 0) as int;
    audioAllMute = (map['audioAllMute'] ?? audioUnAllMute) as int;
  }
}

class TCControlRequestTVResultAction extends ControlActionData {
  late TVStatus tvStatus;

  TCControlRequestTVResultAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    tvStatus = TVStatus.fromJson(map);
  }
}

class TCBindTVResultAction extends ControlActionData {
  late int code;
  late TVStatus tvStatus;

  TCBindTVResultAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    code = map['code'] as int;
    tvStatus = TVStatus.fromJson(map);
  }
}

class TCMeetingLockAction extends ControlActionData {
  /// int,1:允许所有人加入,2:不允许任何加入
  late int joinControlType;

  TCMeetingLockAction(int action) : super(action);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    joinControlType = map['joinControlType'] as int;
  }
}

class TCMemberChangeAction extends ControlActionData {
  /// 用户信息变更
  late String userId;

  TCMemberChangeAction(int action) : super(action);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    userId = map['accountId'] as String;
  }
}

class TCResultAction extends ControlActionData {
  late int code;
  String? msg;

  TCResultAction(int action) : super(action);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    code = map['code'] as int;
    msg = map['msg'] as String?;
  }
}

class TCJoinChannelResultAction extends ControlActionData {
  late int code;
  String? msg;

  TCJoinChannelResultAction(int action) : super(action);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    code = map['code'] as int;
    msg = map['msg'] as String?;
  }
}

class TCHandsUpAction extends ControlActionData {
  ///  user id 来自于谁的操作 ，自己操作自己填自己帐号
  late String fromUser;

  /// 举手
  HandsUp? handsUp;

  /// 被操作对象user id ，为空(没有或者"")的话，指全体禁音/解除， 读取subType来处理
  String? operateUser;

  TCHandsUpAction(int type, int subType) : super(type, subType);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    fromUser = map['fromAccountId'] as String;
    handsUp = HandsUp.fromMap((map['handsUp'] ?? {}) as Map);
    operateUser = map['operAccountId'] as String?;
  }
}

class TCHandsUpResultAction extends ControlActionData {
  late int code;
  String? msg;

  TCHandsUpResultAction(int type) : super(type);

  @override
  void fromJson(Map map) {
    super.fromJson(map);
    code = map['code'] as int;
    msg = map['msg'] as String?;
  }
}

class ControlActionFactory {
  static const _tag = 'ControlActionFactory';
  static ControlActionData? buildAction(TCAction tcAction) {
    Alog.d(tag: _tag, moduleName: _moduleName, content: 'buildAction $tcAction');
    // if (tcAction == null) {
    //   Alog.d(tag: _tag,moduleName: moduleName,content:'ControlActionFactory buildAction tcAction == null');
    //   return null;
    // }
    return buildTCAction(tcAction);
  }

  static ControlActionData? buildTCAction(TCAction tcAction) {
    ControlActionData? meetingAction;
    final type = (tcAction.data['type'] ?? 0) as int;
    final subType = tcAction.data['subType'] as int?;
    switch (type) {
      case TCProtocol.createMetingResult2Controller:
        meetingAction = TCControlCreateOrJoinAction(type);
        break;
      case TCProtocol.joinMeetingResult2Controller:
        meetingAction = TCControlCreateOrJoinAction(type);
        break;
      case TCProtocol.tvStatusResult2Controller:
        meetingAction = TCControlRequestTVResultAction(type);
        break;
      case TCProtocol.bindResult2Controller:
        meetingAction = TCBindTVResultAction(type);
        break;
      case TCProtocol.memberChange2Controller:
        meetingAction = TCControlChangeAction(type);
        break;
      case TCProtocol.unbind2Controller:
        meetingAction = TCUnBindResultAction(type);
        break;
      case TCProtocol.removeMember:
        meetingAction = TCRemoveAttendeeAction(type);
        break;
      case TCProtocol.leaveMeeting:
        meetingAction = TCLeaveMeetingAction(type);
        break;
      case TCProtocol.memberJoin:
        meetingAction = TCUserJoinedAction(type);
        break;
      case TCProtocol.memberLeave2Controller:
        meetingAction = TCUserLeaveAction(type);
        break;
      case TCProtocol.feedback2Controller:
        meetingAction = TCFeedbackAction(type);
        break;
      case TCProtocol.joinChannelResult2Controller:
        meetingAction = TCJoinChannelResultAction(type);
        break;
      case TCProtocol.fetchJoinersResult2Controller:
        meetingAction = TCRequestJoinersResultAction(type);
        break;
      case TCProtocol.checkUpgradeResult2Controller:
        meetingAction = TCCheckUpdateResultAction(type);
        break;
      case TCProtocol.fetchMemberInfoResult2Controller:
        meetingAction = TCRequestMembersResultAction(type);
        break;
      case TCProtocol.controlAudio:
        meetingAction = TCAudioAction(type, subType!);
        break;
      case TCProtocol.selfAudio:
        meetingAction = TCSelfAudioAction(type);
        break;
      case TCProtocol.hostAudio:
        meetingAction = TCHostAudioAction(type);
        break;
      case TCProtocol.controlVideo:
        meetingAction = TCVideoAction(type);
        break;
      case TCProtocol.selfVideo:
        meetingAction = TCSelfVideoAction(type);
        break;
      case TCProtocol.hostVideo:
        meetingAction = TCHostVideoAction(type);
        break;
      case TCProtocol.controlFocus:
        meetingAction = TCChangeFocusAction(type);
        break;
      case TCProtocol.controlHost:
        meetingAction = TCChangeHostAction(type);
        break;
      case TCProtocol.meetingLock:
        meetingAction = TCMeetingLockAction(type);
        break;
      case TCProtocol.screenShare:
        meetingAction = TCScreenShareAction(type);
        break;
      case TCProtocol.handsUp:
        meetingAction = TCHandsUpAction(type, subType!);
        break;
      case TCProtocol.selfHandsUpResult2Controller:
        meetingAction = TCHandsUpResultAction(type);
        break;

      case TCProtocol.selfUnHandsUpResult2Controller:
      case TCProtocol.finishMeetingResult2TV:
      case TCProtocol.removeMemberResult:
      case TCProtocol.controlFocusResult:
      case TCProtocol.controlHostResult:
      case TCProtocol.meetingLockResult:
      case TCProtocol.selfAudioResult:
      case TCProtocol.hostAudioResult:
      case TCProtocol.selfVideoResult:
      case TCProtocol.hostVideoResult:
      case TCProtocol.hostRejectAudioHandsUpResult:
      case TCProtocol.modifyTVNickResult:
        meetingAction = TCResultAction(type);
        break;
      default:
    }

    if (meetingAction != null) {
      meetingAction.fromJson(tcAction.data['data'] as Map);
    }
    return meetingAction;
  }
}
