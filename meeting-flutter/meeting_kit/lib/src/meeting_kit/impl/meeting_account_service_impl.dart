// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

class _NEMeetingAccountServiceImpl extends NEMeetingAccountService {
  static final _NEMeetingAccountServiceImpl _instance =
      _NEMeetingAccountServiceImpl._();

  factory _NEMeetingAccountServiceImpl() => _instance;

  _NEMeetingAccountServiceImpl._() {
    HttpHeaderRegistry().addContributor(() {
      return getAccountInfo().guard((value) => {
                'user': value.userUuid,
                'token': value.userToken,
              }) ??
          const {};
    });
    NERoomKit.instance.messageChannelService.addMessageChannelCallback(
        NEMessageChannelCallback(onReceiveCustomMessage: (message) {
      /// 账号信息变更通知
      if (message.commandId == 211 && message.roomUuid == null) {
        try {
          final data = jsonDecode(message.data);
          final accountInfo = NEAccountInfo.fromMap(
            data['meetingAccountInfo'] as Map,
            userUuid: _accountInfo?.userUuid,
            userToken: _accountInfo?.userToken,
          );
          _setAccountInfo(accountInfo);
        } catch (e) {}
      }
    }));
  }

  NEAccountInfo? _accountInfo;
  bool _anonymous = false;

  @override
  NEAccountInfo? getAccountInfo() {
    return _accountInfo;
  }

  @override
  _setAccountInfo(NEAccountInfo? accountInfo, [bool anonymous = false]) {
    this._accountInfo = accountInfo;
    this._anonymous = accountInfo == null ? false : anonymous;
    notifyListeners();
  }

  @override
  bool get isAnonymous => _anonymous;
}
