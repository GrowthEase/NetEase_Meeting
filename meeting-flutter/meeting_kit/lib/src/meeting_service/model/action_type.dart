// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class ActionType {
  ///******host control******///
  ///移除成员
  static const int removeMember = 0;

  ///主持人禁止成员画面
  static const int hostMuteVideo = 10;

  ///主持人禁止成员声音
  static const int hostMuteAudio = 11;

  ///主持人全体禁音&允许用户自行解除静音
  static const int hostMuteAllAudio = 12;

  ///主持人锁定会议
  static const int hostLockMeeting = 13;

  /// 设置全体视频关闭&允许用户自行解除视频关闭状态
  static const int hostMuteAllVideoAllowSelfOn = 14;

  /// 主持人全体视频关闭&不允许用户自行解除解除视频关闭状态
  static const int hostMuteAllVideoNotAllowSelfOn = 43;

  /// 解除全体视频关闭
  static const int hostUnmuteAllVideo = 19;

  ///主持人解禁成员画面
  static const int hostUnMuteVideo = 15;

  ///主持人解禁成员声音
  static const int hostUnMuteAudio = 16;

  ///主持人全体解禁
  static const int hostUnMuteAllAudio = 17;

  ///主持人解锁会议
  static const int hostUnLockMeeting = 18;

  /// 主持人关闭音视频
  static const int hostMuteAudioAndVideo = 20;

  /// 主持人打开音视频
  static const int hostUnmuteAudioAndVideo = 21;

  ///移交主持人
  static const int changeHost = 22;

  ///主持人指定焦点视频
  static const int setFocusVideo = 30;

  ///主持人取消焦点视频
  static const int cancelFocusVideo = 31;

  ///主持人全体禁音&不允许用户自行解除静音
  static const int hostMuteAllAudioOff = 40;

  ///主持人操作成员举手通过,成员自行发起解除静音请求，当前未使用：预留
  static const int hostAgreeAudioHandsUp = 41;

  ///静音状态主持人拒绝成员举手
  static const int hostRejectAudioHandsUp = 42;

  ///******self control******///
  ///成员关闭自身画面
  static const int muteSelfVideo = 50;

  ///成员关闭自身声音
  static const int muteSelfAudio = 51;

  ///成员结束屏幕共享
  static const int stopScreenShare = 52;

  ///成员打开自身画面
  static const int unMuteSelfVideo = 55;

  ///成员打开自身声音
  static const int unMuteSelfAudio = 56;

  ///成员开始屏幕共享
  static const int startScreenShare = 57;

  ///全体静音成员举手
  static const int muteAllHandsUp = 58;

  ///全体静音成员放手
  static const int muteAllUnHandsUp = 59;

  ///******server control******///

  ///主持人关闭屏幕共享
  static const int hostStopScreenShare = 53;

  ///成员开启白板
  static const int startWhiteBoardShare = 60;

  ///结束成员白板
  static const int stopWhiteBoardShare = 61;

  ///授予成员白板互动权限
  static const int awardedMemberWhiteboardInteraction = 62;

  ///撤销成员白板互动权限
  static const int undoMemberWhiteboardInteraction = 63;

  ///音频转视频
  static const int audio2Video = 67;

  ///视频转音频
  static const int video2Audio = 68;

  ///声音开关控制
  static const int controlAudio = 100;

  ///视频开关控制
  static const int controlVideo = 101;

  ///更新焦点视频
  static const int controlFocus = 102;

  ///更新主持人
  static const int controlHost = 103;

  ///昵称变更
  static const int updateNick = 104;

  ///屏幕共享
  static const int screenShare = 105;

  ///member change
  static const int memberChange = 106;

  ///会议锁定
  static const int meetingLock = 107;

  ///G2 回调代替
  static const int hostKickMember = 108;

  ///G2 回调代替
  static const int deviceKicked = 109;

  /// 会议状态及信息变更
  static const int meetingInfoChange = 110;

  /// 举手状态，大类(包括各种业务举手)
  static const int handsUp = 111;

  /// 直播
  static const int live = 114;

  /// 房间内邀请状态变更通知
  static const int invitation = 115;

  /// 账号token过期
  static const int authInfoExpired = 1000;

  ///遥控器和TV协议
  static const int tc = 201;
}

/// 音频子类型
class AudioSubType {
  static const int unknown = 0;

  ///全局静音&不允许自行解除
  static const int muteAllOpenOff = 1;

  ///全局静音&允许自行解除
  static const int muteAllOpenOn = 2;

  ///解除全局静音
  static const int unMuteAll = 3;

  ///主持人通过成员举手申请，手放下，客户端音频打开
  static const int muteAudioHandsUpOn = 4;
}

/// 视频子类型
class VideoSubType {
  static const int unknown = 0;

  ///全体关闭视频&不允许自行解除
  static const int muteAllOpenOff = 1;

  ///全体关闭视频&允许自行解除
  static const int muteAllOpenOn = 2;

  ///全体打开视频
  static const int unMuteAll = 3;

  ///主持人通过成员举手申请，手放下，客户端视频打开
  static const int muteVideoHandsUpOn = 4;
}

/// 举手子类型
class HandsUpSubType {
  ///成员举手
  static const int memberHandsUp = 1;

  ///成员举手放下
  static const int memberHandsUpDown = 2;

  ///主持人拒绝成员举手申请,成员手放下
  static const int hostRejectAudioHandsUp = 3;

  ///主持人通过成员举手申请，手放下，成员发送解除音频请求
  static const int hostAgreeAudioHandsUp = 4;
}
