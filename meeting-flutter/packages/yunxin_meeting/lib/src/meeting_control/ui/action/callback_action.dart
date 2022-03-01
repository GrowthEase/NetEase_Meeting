// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class CallbackAction {

  ///移除成员
  static const int removeMember = 0;
  ///主持人禁止成员画面
  static const int hostMuteVideo = 10;
  ///主持人禁止成员声音
  static const int hostMuteAudio = 11;
  ///主持人全体禁音
  static const int hostMuteAllAudio = 12;
  ///主持人解禁成员画面
  static const int hostUnMuteVideo = 15;

  ///主持人解禁成员声音
  static const int hostUnMuteAudio = 16;
  ///主持人全体解禁
  static const int hostUnMuteAllAudio = 17;

  ///主持人指定焦点视频
  static const int setFocusVideo = 30;
  ///主持人取消焦点视频
  static const int cancelFocusVideo = 31;
  ///移交主持人
  static const int changeHost = 22;
  


}
