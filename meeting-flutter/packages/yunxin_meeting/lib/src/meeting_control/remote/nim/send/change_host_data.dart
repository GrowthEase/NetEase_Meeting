// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class ChangeHostData extends BaseData{
  ///被操作对象user id
  String operaUser;

  ChangeHostData(this.operaUser) : super(TCProtocol.controlHost, 0);

  @override
  Map toData() {
    return {
      'operAccountId': operaUser,
    };
  }

}