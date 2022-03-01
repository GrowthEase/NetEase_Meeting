// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class SyncControlAccountData extends BaseData {
  String account;
  String code;
  String deviceId;
  String nick;
  String controllerProtocolVersion;

  SyncControlAccountData(this.account, this.code, this.deviceId, this.nick, this.controllerProtocolVersion)
      : super(TCProtocol.bind2TV, 0);

  @override
  Map toData() => {
        'accountId': account,
        'code': code,
        'deviceId': deviceId,
        'nickName': nick,
        'controllerProtocolVersion': controllerProtocolVersion
      };
}
