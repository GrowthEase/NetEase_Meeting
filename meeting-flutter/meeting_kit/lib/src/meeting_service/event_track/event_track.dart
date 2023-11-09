// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class TrackEventName {
  /// added 0.5.0
  ///sdk启动
  static const String sdkInit = 'sdk_init';

  ///登陆sdk
  static const String loginSdk = 'login_sdk';

  ///登陆sdk成功
  static const String loginSdkSuccess = 'login_sdk_success';

  ///登陆sdk失败
  static const String loginSdkFailed = 'login_sdk_failed';

  ///登陆meeting server
  static const String loginMeetingServer = 'login_meeting_server';

  ///登陆meeting server成功
  static const String loginMeetingServerSuccess =
      'login_meeting_server_success';

  ///登陆meeting server失败
  static const String loginMeetingServerFailed = 'login_meeting_server_failed';

  ///登陆im
  static const String loginIm = 'login_im';

  ///登陆im成功
  static const String loginImSuccess = 'login_im_success';

  ///登陆im失败
  static const String loginImFailed = 'login_im_failed';

  ///登出sdk
  static const String loginOutSdk = 'login_out_sdk';

  ///创建会议
  static const String roomCreate = 'meeting_create';

  ///创建会议成功
  static const String roomCreateSuccess = 'meeting_create_success';

  ///创建会议失败
  static const String roomCreateFailed = 'meeting_create_failed';

  ///加入会议
  static const String roomJoin = 'meeting_join';

  ///加入会议成功
  static const String meetingJoinSuccess = 'meeting_join_success';

  ///加入会议失败
  static const String meetingJoinFailed = 'meeting_join_failed';

  ///打开会议页面
  static const String pageMeeting = 'page_meeting';

  ///join Channel
  static const String joinChannel = 'join_channel';

  ///join Channel 成功
  static const String joinChannelSuccess = 'join_channel_success';

  ///join Channel 失败
  static const String joinChannelFailed = 'join_channel_failed';

  ///结束会议回调
  static const String meetingFinish = 'meeting_finish';

  ///操作音频按钮
  static const String switchAudio = 'switch_audio';

  ///操作音频按钮
  static const String handsUp = 'hands_up';

  ///操作视频按钮
  static const String switchCamera = 'switch_camera';

  ///屏幕共享
  static const String screenShare = 'screen_share';

  ///成员打开屏幕共享
  static const String memberScreenShareStart = 'member_screen_share_start';

  ///成员关闭屏幕共享
  static const String memberScreenShareStop = 'member_screen_share_stop';

  ///成员打开白板共享
  static const String memberWhiteBoardShareStart =
      'member_whiteBoard_share_start';

  ///成员关闭白板共享
  static const String memberWhiteBoardShareStop =
      'member_whiteboard_share_stop';

  ///成员白板授权
  static const String awardedMemberWhiteboardInteraction =
      'awarded_member_whiteboard_interaction';

  ///成员白板撤回授权
  static const String undoMemberWhiteboardInteraction =
      'undo_member_whiteboard_interaction';

  ///管理参会者按钮
  static const String manageMember = 'manage_member';

  ///邀请
  static const String invite = 'invite';

  ///美颜
  static const String beauty = 'beauty';

  ///美颜
  static const String whiteBoard = 'whiteBoard';

  ///主持人全体静音
  static const String muteAllAudio = 'mute_all_audio';

  ///	主持人解除全体静音
  static const String unMuteAllAudio = 'unmute_all_audio';

  ///主持人全体静音
  static const String muteAllVideo = 'mute_all_video';

  ///	主持人解除全体静音
  static const String unMuteAllVideo = 'unmute_all_video';

  ///主持人开启、停止成员音频
  static const String switchAudioMember = 'switch_audio_member';

  ///主持人开启、停止成员视频
  static const String switchCameraMember = 'switch_camera_member';

  static const String muteAudioAndVideo = 'mute_audio_video';

  ///主持人设置焦点视频成员
  static const String focusMember = 'focus_member';

  ///主持人移除某个人
  static const String removeMember = 'remove_member';

  ///主持人移交主持人
  static const String changeHost = 'change_host';

  ///自己离开会议
  static const String selfLeaveMeeting = 'self_leave_meeting';

  ///自己结束会议
  static const String selfFinishMeeting = 'self_finish_meeting';

  ///其他用户加入会议
  static const String memberJoinMeeting = 'member_join_meeting';

  ///其他用户打开摄像头
  static const String memberVideoStart = 'member_video_start';

  ///其他用户关闭摄像头
  static const String memberVideoStop = 'member_video_stop';

  ///其他用户接受首帧视频
  static const String firstVideoDataReceived = 'first_video_data_received';

  ///其他用户更改分辨率
  static const String memberChangeProfile = 'member_change_profile';

  ///其他用户离开会议
  static const String memberLeaveMeeting = 'member_leave_meeting';

  ///订阅成员视频流
  static const String subMemberVideo = 'sub_member_video';

  ///反订阅成员视频流
  static const String unSubMemberVideo = 'un_sub_member_video';

  ///订阅成员视频辅流
  static const String subMemberSubStreamVideo = 'sub_member_substream_video';

  ///反订阅成员视频辅流
  static const String unSubMemberSubStreamVideo =
      'un_sub_member_substream_video';

  /// 查看会议信息
  static const String meetingInfoClick = 'meeting_info_click';

  ///主持人拒绝成员打开音频手放下
  static const String handsUpDown = 'hands_up_down';
}

class _TrackModuleName {
  static const String meeting = 'meeting';
}

abstract class EventTrackMixin {
  void trackPeriodicEvent(String name,
      {String module = _TrackModuleName.meeting,
      String? category,
      Map? extra}) {}

  void trackImmediateEvent(String name,
      {String module = _TrackModuleName.meeting,
      String? category,
      Map? extra}) {}
}
