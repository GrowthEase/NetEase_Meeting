// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class HostRejectAudioHandsUpData extends BaseData{
  ///被操作对象user id
  String operaUser;

  HostRejectAudioHandsUpData(this.operaUser) : super(TCProtocol.hostRejectAudioHandsUp, 0);

  @override
  Map toData() {
    return {
      'operAccountId': operaUser,
    };
  }

}