// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

/// 提供会议相关的服务接口，诸如创建会议、加入会议、添加会议状态监听等。可通过 [NEMeetingKit.getMeetingService] 获取对应的服务实例
abstract class NEMeetingService {
  /// 开始一个新的会议，只有完成SDK的登录鉴权操作才允许创建会议。
  /// 开始会议成功后，SDK会拉起会议页面，调用方不用做其他操作
  ///
  /// [param] 会议参数对象，不能为空
  /// [opts]  会议选项对象，可空；当未指定时，会使用默认的选项
  ///
  Future<NEResult<void>> startMeeting(
    BuildContext context,
    NEStartMeetingParams param,
    NEMeetingOptions opts, {
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
    Widget? backgroundWidget,
  });

  /// 加入一个当前正在进行中的会议，只有完成SDK的登录鉴权操作才允许加入会议。
  /// 加入会议成功后，SDK会拉起会议页面，调用方不用做其他操作
  ///
  /// [param] 会议参数对象，不能为空
  /// [opts]  会议选项对象，可空；当未指定时，会使用默认的选项
  ///
  Future<NEResult<void>> joinMeeting(
    BuildContext context,
    NEJoinMeetingParams param,
    NEMeetingOptions opts, {
    PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
    Widget? backgroundWidget,
  });

  ///  匿名入一个当前正在进行中的会议，未登录状态可通过该接口加入会议。
  ///  <p>加入会议成功后，SDK会拉起会议页面，调用方不用做其他操作。
  ///
  /// [param] 会议参数对象，不能为空
  /// [opts]  会议选项对象，可空；当未指定时，会使用默认的选项
  Future<NEResult<void>> anonymousJoinMeeting(
    BuildContext context,
    NEJoinMeetingParams param,
    NEMeetingOptions opts, {
    PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
  });

  ///
  /// 将当前正在进行中的会议页面关闭。不会退出或结束会议，会议继续在后台运行。 如果当前无进行中的会议，则调用无效。
  ///
  Future<NEResult<void>> minimizeCurrentMeeting();

  ///
  /// 从画中画模式恢复会议。如果当前无进行中的会议，则调用无效。
  ///
  Future<NEResult<void>> fullscreenCurrentMeeting();

  ///
  ///  离开当前进行中的会议，并通过参数控制是否同时结束当前会议；
  /// 只有主持人才能结束会议，其他用户设置结束会议无效；
  /// 如果退出当前会议后，会议中再无其他成员，则该会议也会结束；
  /// [closeIfHost] true：结束会议；false：不结束会议；
  ///
  Future<NEResult<void>> leaveCurrentMeeting(bool closeIfHost);

  ///
  /// 设置菜单项点击事件回调
  ///
  void setOnInjectedMenuItemClickListener(
      NEMeetingOnInjectedMenuItemClickListener listener);

  ///
  /// 更新当前存在的自定义菜单项的状态 注意：该接口更新菜单项的文本(最长为10，超过不生效)
  /// [item] 当前已存在的菜单项
  ///
  Future<NEResult<void>> updateInjectedMenuItem(NEMeetingMenuItem? item);

  ///
  /// 获取当前会议状态，参考[NEMeetingStatus]
  ///
  int getMeetingStatus();

  ///
  /// 获取当前会议详情。如果当前无正在进行中的会议，则回调数据对象为空
  ///
  NEMeetingInfo? getCurrentMeetingInfo();

  ///
  /// 添加会议状态监听实例，用于接收会议状态变更通知
  ///
  /// [listener] 要添加的监听实例
  ///
  void addMeetingStatusListener(NEMeetingStatusListener listener);

  ///
  /// 移除对应的会议状态的监听实例
  ///
  /// [listener] 要移除的监听实例
  ///
  void removeMeetingStatusListener(NEMeetingStatusListener listener);
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

  /// 当前是否处于等候室
  final bool isInWaitingRoom;

  /// 当前主持人id
  final String hostUserId;

  /// 额外数据
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

  ///
  /// 会议时区
  ///
  final String? timezoneId;

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
    this.isInWaitingRoom = false,
    required this.hostUserId,
    required this.userList,
    this.extraData,
    this.timezoneId,
  });

  Map<String, dynamic> toMap() => {
        'meetingId': meetingId,
        'meetingNum': meetingNum,
        if (shortMeetingNum != null) 'shortMeetingNum': shortMeetingNum,
        if (sipCid != null) 'sipId': sipCid,
        'type': type,
        'isLocked': isLocked,
        'isHost': isHost,
        'isInWaitingRoom': isInWaitingRoom,
        if (password != null) 'password': password,
        'subject': subject,
        'startTime': startTime,
        'scheduleStartTime': scheduleStartTime,
        'scheduleEndTime': scheduleEndTime,
        'duration': duration,
        'hostUserId': hostUserId,
        if (extraData != null) 'extraData': extraData,
        'userList': userList.map((e) => e.toMap()).toList(growable: false),
        'timezoneId': timezoneId,
      };

  @override
  String toString() {
    return 'NEMeetingInfo{meetingId: $meetingId, meetingNum: $meetingNum, shortMeetingNum: $shortMeetingNum, sipCid: $sipCid, type: $type, subject: $subject, password: $password, startTime: $startTime, scheduleStartTime: $scheduleStartTime, scheduleEndTime: $scheduleEndTime, duration: $duration, isHost: $isHost, isLocked: $isLocked, hostUserId: $hostUserId, userList: $userList, timezoneId: $timezoneId}';
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
