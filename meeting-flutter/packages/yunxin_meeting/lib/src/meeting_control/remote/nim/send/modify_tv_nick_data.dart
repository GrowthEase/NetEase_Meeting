// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class ModifyTVNickData extends BaseData{
  String nick;

  ModifyTVNickData(this.nick) : super(TCProtocol.modifyTVNick, 0);

  @override
  Map toData() {
    return {
      'nickName': nick,
    };
  }

}