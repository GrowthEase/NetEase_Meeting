// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class HostVideoControlData extends BaseData{

  ///来自于谁的操作 ，自己操作自己填自己帐号，主持人操作填主持人帐号 (摇控器填写TV 的)
  String? fromUser;
  ///1：有，2：无（自己关闭），3：无（主持人禁），4：无（主持人打开，等待成员确认）
  int muteVideo;
  ///被操作对象user id
  String operaUser;

  HostVideoControlData(this.fromUser, this.muteVideo, this.operaUser) : super(TCProtocol.hostVideo, 0);

  @override
  Map toData() {
    return {
      'fromAccountId': fromUser,
      'video': muteVideo,
      'operAccountId': operaUser,
    };
  }

}