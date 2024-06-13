// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

/// 提供会议相关的服务接口，诸如创建会议、加入会议、添加会议状态监听等。可通过 [NEMeetingKit.MeetingInviteService] 获取对应的服务实例
abstract class NEMeetingInviteService {
  /// 通过邀请 加入一个当前正在进行中的会议，只有完成SDK的登录鉴权操作才允许加入会议。
  /// 加入会议成功后，SDK会拉起会议页面，调用方不用做其他操作
  ///
  /// * [param] 会议参数对象，不能为空
  /// * [opts]  会议选项对象，可空；当未指定时，会使用默认的选项
  ///
  /// 该回调会返回一个[NERoomContext]房间上下文实例，该实例支持会议相关扩展 [NEMeetingContext]
  Future<NEResult<NERoomContext>> acceptInvite(
      NEJoinMeetingParams param, NEJoinMeetingOptions opts);

  ///
  /// 拒绝一个邀请，只有完成SDK的登录鉴权操作才允许该操作。 挂断正在进行的呼叫，无论是正在响铃还是等待响铃都可以使用
  /// [meetingId] 会议ID
  ///
  Future<NEResult<VoidResult>> rejectInvite(int meetingId);

  ///
  /// 添加邀请状态监听实例，用于接收邀请状态变更通知
  ///  [listener] 要添加的监听实例
  ///
  void addMeetingInviteStatusListener(NEMeetingInviteStatusListener listener);

  ///
  /// 移除对应的邀请状态监听实例
  /// [listener] 要移除的监听实例
  ///
  void removeMeetingInviteStatusListener(
      NEMeetingInviteStatusListener listener);
}

///
/// 会议邀请状态监听器，用于监听邀请状态变更事件
///
mixin class NEMeetingInviteStatusListener {
  ///
  /// 会议邀请状态变更通知
  /// [status] 邀请状态
  /// [meetingId] 会议ID
  /// [inviteInfo] 邀请对象信息
  ///
  void onMeetingInviteStatusChanged(NEMeetingInviteStatus status,
      String? meetingId, NEMeetingInviteInfo inviteInfo) {}
}

/// 房间邀请信息
class NEMeetingInviteInfo {
  /// 会议号
  String? meetingNum;

  /// 邀请者名称
  String? inviterName;

  /// 邀请者头像
  String? inviterAvatar;

  /// 会议主题
  String? subject;

  /// 会前邀请，当在预约会议被添加时触发，则为true；会中主动邀请，则为false
  bool? preMeetingInvitation;

  /// fromMap 解析
  NEMeetingInviteInfo.fromMap(Map? map) {
    meetingNum = map?['meetingNum'] ?? '';
    inviterName = map?['inviterName'] ?? '';
    inviterAvatar = map?['inviterIcon'] ?? '';
    subject = map?['subject'] ?? '';
    preMeetingInvitation = map?['outOfMeeting'] ?? false;
  }

  toMap() {
    return {
      'meetingNum': meetingNum,
      'inviterName': inviterName,
      'inviterIcon': inviterAvatar,
      'subject': subject,
      'outOfMeeting': preMeetingInvitation
    };
  }
}

///
/// 成员被邀请的状态
///
enum NEMeetingInviteStatus {
  ///
  /// 未知
  ///
  unknown,

  ///
  /// 等待呼叫
  ///
  waitingCall,

  ///
  /// 呼叫中
  ///
  calling,

  ///
  /// 已拒接
  ///
  rejected,

  ///
  /// 未接听
  ///
  noAnswer,

  ///
  /// 呼叫异常
  ///
  error,

  ///
  /// 已移除
  ///
  removed,

  ///
  /// 已取消
  ///
  canceled,

  ///
  /// 待入会
  ///
  waitingJoined,
}
