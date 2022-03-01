// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class ModifyNickData extends BaseData{
  String userId;
  String nick;

  ModifyNickData(this.userId, this.nick) : super(TCProtocol.modifyNick, 0);

  @override
  Map toData() {
    return {
      'accountId': userId,
      'nickName': nick,
    };
  }

}