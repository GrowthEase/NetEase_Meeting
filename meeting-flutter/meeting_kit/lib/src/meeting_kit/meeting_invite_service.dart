// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

/// 提供会议相关的服务接口，诸如创建会议、加入会议、添加会议状态监听等。可通过 [NEMeetingKit.MeetingInviteService] 获取对应的服务实例
abstract class NEMeetingInviteService {
  ///
  /// 拒绝一个邀请，只有完成SDK的登录鉴权操作才允许该操作。 挂断正在进行的呼叫，无论是正在响铃还是等待响铃都可以使用
  /// [meetingId] 会议ID
  ///
  Future<NEResult<VoidResult>> rejectInvite(int meetingId);

  /// 通过邀请 加入一个当前正在进行中的会议，只有完成SDK的登录鉴权操作才允许加入会议。
  /// 加入会议成功后，SDK会拉起会议页面，调用方不用做其他操作
  ///
  /// * [param] 会议参数对象，不能为空
  /// * [opts]  会议选项对象，可空；当未指定时，会使用默认的选项
  ///
  Future<NEResult<void>> acceptInvite(
    BuildContext context,
    NEJoinMeetingParams param,
    NEMeetingOptions opts, {
    PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
    int? startTime,
    Widget? backgroundWidget,
  });

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

  ///
  /// 呼叫指定会议室设备
  /// [device] device 设备
  ///
  Future<NEResult<NERoomSIPCallInfo?>> callOutRoomSystem(
      NERoomSystemDevice device);
}
