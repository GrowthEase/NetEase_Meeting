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
  /// 拒绝邀请
  /// [meetingId] 会议ID
  ///
  Future<NEResult<VoidResult>> rejectInvite(String meetingId);

  /**
   * @brief 添加消息监听
   * @param listener 消息监听对象 {@link NEMeetingInviteListener}
   */
  void addEventListener(NEMeetingInviteListener listener);

  /**
   * @brief 移除消息监听
   * @param listener 消息监听对象 {@link NEMeetingInviteListener}
   */
  void removeEventListener(NEMeetingInviteListener listener);
}

/// 会议邀请状态变更回调
/// [status] 邀请状态
/// [meetingId] 会议ID
/// [inviteInfo] 邀请信息
///
abstract class NEMeetingInviteListener {
  // 房间呼出状态改变的回调事件。
  void onMeetingInviteStatusChanged(NEMeetingInviteStatus status,
      String? meetingId, NEMeetingInviteInfo inviteInfo);
}

/// 房间邀请信息
class NEMeetingInviteInfo {
  /// 邀请者名称
  String? inviterName;

  /// 会议号
  String? meetingNum;

  /// 邀请者头像
  String? inviterIcon;

  /// 邀请者主题
  String? subject;

  /// 是否是预约会议指定成员
  bool? outOfMeeting;

  /// fromMap 解析
  NEMeetingInviteInfo.fromMap(Map? map) {
    meetingNum = map?['meetingNum'] ?? '';
    inviterName = map?['inviterName'] ?? '';
    inviterIcon = map?['inviterIcon'] ?? '';
    subject = map?['subject'] ?? '';
    outOfMeeting = map?['outOfMeeting'] ?? false;
  }

  toMap() {
    return {
      'meetingNum': meetingNum,
      'inviterName': inviterName,
      'inviterIcon': inviterIcon,
      'subject': subject,
      'outOfMeeting': outOfMeeting
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
}
