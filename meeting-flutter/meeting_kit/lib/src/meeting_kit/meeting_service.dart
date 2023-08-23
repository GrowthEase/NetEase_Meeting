// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

/// 提供创建会议必要的基本参数，如会议ID、房间昵称等
class NEStartMeetingParams {
  ///
  /// 会议主题
  ///
  final String? subject;

  /// 指定要创建会议号
  /// * 可指定为个人会议ID或个人会议短号；
  /// * 当不指定时，由服务端随机分配一个会议ID；
  final String? meetingNum;

  /// 房间中的用户昵称，不能为空
  final String displayName;

  /// 房间密码;
  /// 创建房间时，如果密码不为空，会创建带指定密码的房间
  /// 加入带密码的房间时，需要指定密码
  final String? password;

  /// 会议中的用户成员标签，自定义，最大长度50
  final String? tag;

  final String? avatar;

  /// 透传字段
  final String? extraData;

  /// 音视频控制
  final List<NERoomControl>? controls;

  /// 设置会议成员角色
  final Map<String, NEMeetingRoleType>? roleBinds;

  /// 媒体流加密类型
  final NEEncryptionConfig? encryptionConfig;

  IntervalEvent? trackingEvent;

  NEStartMeetingParams({
    this.subject,
    this.meetingNum,
    required this.displayName,
    this.password,
    this.tag,
    this.avatar,
    this.extraData,
    this.controls,
    this.roleBinds,
    this.encryptionConfig,
  });

  @override
  String toString() {
    return 'NEStartMeetingParams{meetingNum: $meetingNum, displayName: $displayName, tag: $tag}';
  }
}

class NEStartMeetingOptions {
  ///
  /// 是否开启聊天室
  ///
  final bool noChat;

  ///
  /// 是否开启 云端录制
  ///
  final bool noCloudRecord;

  ///
  /// 是否开启 SIP 功能
  ///
  final bool noSip;

  ///
  /// 配置在加入Rtc频道成功后是否打开本地音频设备，默认打开。
  /// 该选项若配置为打开，则SDK会提前初始化音频设备，但不会对外发送本地音频流。
  ///
  final bool enableMyAudioDeviceOnJoinRtc;

  NEStartMeetingOptions({
    this.noChat = false,
    this.noCloudRecord = true,
    this.noSip = false,
    this.enableMyAudioDeviceOnJoinRtc = true,
  });
}

/// 提供加入会议时必要的额外参数，如会议ID、用户会议昵称,tag等
class NEJoinMeetingParams {
  /// 会议号
  final String meetingNum;

  /// 会议昵称
  final String displayName;

  /// 房间密码;
  /// 创建房间时，如果密码不为空，会创建带指定密码的房间
  /// 加入带密码的房间时，需要指定密码
  final String? password;

  /// 会议中的用户成员标签，自定义，最大长度50
  final String? tag;

  final String? avatar;

  /// 媒体流加密类型
  final NEEncryptionConfig? encryptionConfig;

  IntervalEvent? trackingEvent;

  NEJoinMeetingParams({
    required this.meetingNum,
    required this.displayName,
    this.password,
    this.tag,
    this.avatar,
    this.encryptionConfig,
  });

  NEJoinMeetingParams copy({String? password}) {
    return NEJoinMeetingParams(
      meetingNum: meetingNum,
      displayName: displayName,
      password: password ?? this.password,
      tag: tag,
      avatar: avatar,
      encryptionConfig: encryptionConfig,
    );
  }
}

class NEJoinMeetingOptions {
  ///
  /// 配置在加入Rtc频道成功后是否打开本地音频设备，默认打开。
  /// 该选项若配置为打开，则SDK会提前初始化音频设备，但不会对外发送本地音频流。
  ///
  final bool enableMyAudioDeviceOnJoinRtc;

  NEJoinMeetingOptions({
    this.enableMyAudioDeviceOnJoinRtc = true,
  });
}

/// 提供会议相关的服务接口，诸如创建会议、加入会议、添加会议状态监听等。可通过 [NEMeetingKit.getMeetingService] 获取对应的服务实例
abstract class NEMeetingService {
  /// 创建一个新的会议，只有完成SDK的登录鉴权操作才允许创建会议。创建会议成功后，SDK会拉起会议页面，调用方不用做其他操作
  ///
  /// * [param] 会议参数对象，不能为空
  /// * [opts]  会议选项对象，可空；当未指定时，会使用默认的选项
  ///
  /// 该回调会返回一个[NERoomContext]房间上下文实例，该实例支持会议相关扩展 [NEMeetingContext]
  Future<NEResult<NERoomContext>> startMeeting(
    NEStartMeetingParams param,
    NEStartMeetingOptions opts,
  );

  /// 加入一个当前正在进行中的会议，已登录或未登录均可加入会议。
  /// 加入会议成功后，SDK会拉起会议页面，调用方不用做其他操作
  ///
  /// * [param] 会议参数对象，不能为空
  /// * [opts]  会议选项对象，可空；当未指定时，会使用默认的选项
  ///
  /// 该回调会返回一个[NERoomContext]房间上下文实例，该实例支持会议相关扩展 [NEMeetingContext]
  Future<NEResult<NERoomContext>> joinMeeting(
    NEJoinMeetingParams param,
    NEJoinMeetingOptions opts,
  );

  ///  加入一个当前正在进行中的会议，已登录或未登录均可加入会议。
  ///<p>加入会议成功后，SDK会拉起会议页面，调用方不用做其他操作。
  ///
  /// * [param] 会议参数对象，不能为空
  /// * [opts]  会议选项对象，可空；当未指定时，会使用默认的选项
  Future<NEResult<NERoomContext>> anonymousJoinMeeting(
    NEJoinMeetingParams param,
    NEJoinMeetingOptions opts,
  );
}

/// 会议信息
class NEMeetingInfo {
  /// 会议标识
  final int meetingId;

  /// 会议号
  final String meetingNum;

  /// 当前会议短号ID
  final String? shortMeetingNum;

  /// 当前会议SIP ID
  final String? sipCid;

  /// 会议类型
  final int type;

  /// 会议主题
  final String subject;

  /// 会议密码
  final String? password;

  /// 会议开始时间
  final int startTime;

  /// 会议预约开始时间
  final int scheduleStartTime;

  /// 会议预约结束时间
  final int scheduleEndTime;

  /// 会议当前持续时间
  final int duration;

  /// 当前用户是否为主持人
  final bool isHost;

  /// 当前会议是否被锁定
  final bool isLocked;

  /// 当前主持人id
  final String hostUserId;

  final String? extraData;

  ///
  /// 会议邀请链接
  ///
  final String? inviteUrl;

  ///
  /// 会议邀请码
  ///
  final String? inviteCode;

  final List<NEInMeetingUserInfo> userList;

  NEMeetingInfo({
    required this.meetingId,
    required this.meetingNum,
    this.shortMeetingNum,
    this.sipCid,
    required this.type,
    required this.subject,
    this.password,
    required this.startTime,
    this.scheduleStartTime = 0,
    this.scheduleEndTime = 0,
    this.inviteUrl,
    this.inviteCode,
    required this.duration,
    required this.isHost,
    required this.isLocked,
    required this.hostUserId,
    required this.userList,
    this.extraData,
  });

  Map<String, dynamic> toMap() => {
        'meetingId': meetingId,
        'meetingNum': meetingNum,
        if (shortMeetingNum != null) 'shortMeetingNum': shortMeetingNum,
        if (sipCid != null) 'sipId': sipCid,
        'type': type,
        'isLocked': isLocked,
        'isHost': isHost,
        if (password != null) 'password': password,
        'subject': subject,
        'startTime': startTime,
        'scheduleStartTime': scheduleStartTime,
        'scheduleEndTime': scheduleEndTime,
        'duration': duration,
        'hostUserId': hostUserId,
        if (extraData != null) 'extraData': extraData,
        'userList': userList.map((e) => e.toMap()).toList(growable: false),
      };

  @override
  String toString() {
    return 'NEMeetingInfo{meetingId: $meetingId, meetingNum: $meetingNum, shortMeetingNum: $shortMeetingNum, sipCid: $sipCid, type: $type, subject: $subject, password: $password, startTime: $startTime, scheduleStartTime: $scheduleStartTime, scheduleEndTime: $scheduleEndTime, duration: $duration, isHost: $isHost, isLocked: $isLocked, hostUserId: $hostUserId, userList: $userList}';
  }
}

/// 会议中的成员信息类
class NEInMeetingUserInfo {
  final String userId;

  final String userName;

  ///会议中的成员标签，自定义，最大长度1024个字符
  final String? tag;

  /// 是否为自己
  final bool isSelf;

  final String _role;

  NEInMeetingUserInfo(this.userId, this.userName, this.tag, this._role,
      [this.isSelf = false]);

  Map<String, dynamic> toMap() => <String, dynamic>{
        'userId': userId,
        'userName': userName,
        if (tag != null) 'tag': tag,
        'isSelf': isSelf,
        'roleType': roleType.index,
      };

  NEMeetingRoleType get roleType => MeetingRoles.mapStringRoleToEnum(_role);

  @override
  String toString() {
    return 'NEInMeetingUserInfo{userId: $userId, userName: $userName, tag: $tag, isSelf: $isSelf}';
  }
}

class NEMeetingConstants {
  /// 会议密码最小长度
  static const int meetingPasswordMinLen = 4;

  /// 会议密码最大长度
  static const int meetingPasswordMaxLen = 20;

  /// 入会超时时间，单位 ms
  static const int meetingJoinTimeout = 45 * 1000;
}
