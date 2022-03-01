// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class SelfVideoControlData extends BaseData{

  ///1：有，2：无（自己关闭），3：无（主持人禁），4：无（主持人打开，等待成员确认）
  int muteVideo;

  SelfVideoControlData(this.muteVideo) : super(TCProtocol.selfVideo, 0);

  @override
  Map toData() {
    return {
      'video': muteVideo,
    };
  }

}