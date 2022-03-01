// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class TCProtocol{

  /// 遥控器协议版本号
  static String controllerProtocolVersion = '1.1';

  /// 遥控器绑定TV
  static const int bind2TV = 1;

  /// TV同步绑定结果给遥控器
  static const int bindResult2Controller = 13;

  /// 遥控器创建会议
  static const int createMeeting2TV = 2;

  /// TV创建会议结果
  static const int createMetingResult2Controller = 3;

  /// 遥控器加入会议
  static const int joinMeeting2TV = 4;

  /// TV加入会议结果
  static const int joinMeetingResult2Controller = 5;

  /// 遥控器取消 创建/加入 会议
  static const int cancel2TV = 6;

  /// 遥控器请求TV状态
  static const int requestTVStatus2TV = 7;

  /// TV同步状态给遥控器
  static const int tvStatusResult2Controller = 8;

  /// TV让遥控器更新下成员列表
  static const int memberChange2Controller = 9;

  /// TV 收到未绑定遥控器的消息，给予反馈
  static const int notBinded2Controller = 10;

  /// 遥控器断开连接
  static const int unBind2TV = 11;

  /// 离开会议
  static const int leaveMeeting = 12;


  /// 遥控器主持人结束会议
  static const int finishMeeting2TV = 14;

  /// 遥控器主持人结束会议结果
  static const int finishMeetingResult2TV = 55;

  /// 主持人移除成员
  static const int removeMember = 15;

  /// 主持人移除成员结果
  static const int removeMemberResult = 56;

  /// 意见反馈
  static const int feedback2TV = 16;

  /// TV通知遥控器解除绑定
  static const int unbind2Controller = 17;

  /// 有用户加入会议
  static const int memberJoin = 18;

  /// 有用户离开会议
  static const int memberLeave2Controller = 19;

  /// 问题反馈，tv通知遥控器上传日志
  static const int feedback2Controller = 20;

  /// 遥控器向tv请求成员列表
  static const int fetchJoiners2TV = 21;

  /// tv向遥控器返回成员列表
  static const int fetchJoinersResult2Controller = 22;

  ///tv向遥控器返回加入频道的结果，用来做过度页面消失
  static const int joinChannelResult2Controller = 23;

  /// 切换视图
  static const int changeShowType2TV = 30;

  /// 翻页
  static const int turnPage2TV = 31;

  /// 遥控器通知TV检查更新
  static const int checkUpgrade2TV = 32;

  /// TV返回给遥控器检查更新结果
  static const int checkUpgradeResult2Controller = 33;

  /// 遥控器通知TV更新
  static const int upgrade2TV = 34;

  /// 遥控器请求成员信息(可能包括已经离开会议的人)
  static const int fetchMemberInfo2TV = 35;

  /// TV返回给遥控器成员信息(可能包括已经离开会议的人)
  static const int fetchMemberInfoResult2Controller = 36;

  /// 音频开关控制
  static const int controlAudio = 37;

  /// 视频开关控制
  static const int controlVideo = 38;

  /// 更新焦点视频
  static const int controlFocus = 39;

  /// 更新焦点视频结果
  static const int controlFocusResult = 57;

  /// 更换主持人
  static const int controlHost = 40;

  /// 更换主持人结果
  static const int controlHostResult = 58;

  /// 更换昵称
  static const int modifyNick = 41;

  /// 主持人更改会议锁定状态
  static const int meetingLock = 42;

  /// 主持人更改会议锁定状态结果
  static const int meetingLockResult = 59;

  /// 屏幕共享
  static const int screenShare = 43;

  /// 自己的音频
  static const int selfAudio = 44;

  /// 自己的音频结果
  static const int selfAudioResult = 60;

  /// 主持人的控制的音频
  static const int hostAudio = 45;

  /// 主持人的控制的音频结果
  static const int hostAudioResult = 61;

  /// 自己的视频
  static const int selfVideo = 46;

  /// 自己的视频结果
  static const int selfVideoResult = 62;

  /// 主持人控制的视频
  static const int hostVideo = 47;

  /// 主持人控制的视频结果
  static const int hostVideoResult = 63;

  /// 自己的举手动作
  static const int selfHandsUp = 48;

  /// TV同步自己举手结果给遥控器
  static const int selfHandsUpResult2Controller = 53;

  /// 自己的放手动作
  static const int selfUnHandsUp = 49;

  /// TV同步自己放手结果给遥控器
  static const int selfUnHandsUpResult2Controller = 54;

  /// 其他人举手
  static const int handsUp = 50;

  /// 主持人拒绝举手
  static const int hostRejectAudioHandsUp = 51;

  /// 主持人拒绝举手结果
  static const int hostRejectAudioHandsUpResult = 52;

  /// 修改TV昵称
  static const int modifyTVNick = 64;

  /// 修改TV昵称结果
  static const int modifyTVNickResult = 65;
}