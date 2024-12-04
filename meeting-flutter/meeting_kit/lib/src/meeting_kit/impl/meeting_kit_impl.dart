// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

class _NEMeetingKitImpl extends NEMeetingKit with _AloggerMixin {
  NEMeetingService meetingService = _NEMeetingServiceImpl();
  NEScreenSharingService screenSharingService = _NEScreenSharingServiceImpl();
  _NEAccountServiceImpl accountService = _NEAccountServiceImpl();
  _NESettingsServiceImpl settingsService = _NESettingsServiceImpl();
  NEPreMeetingService preMeetingService = _NEPreMeetingServiceImpl();
  _NEMeetingInviteServiceImpl inviteService = _NEMeetingInviteServiceImpl();
  NEMeetingMessageChannelService messageChannelService =
      _NEMeetingMessageChannelServiceImpl();
  _NEContactsServiceImpl contactsService = _NEContactsServiceImpl();
  _NEFeedbackServiceImpl feedbackService = _NEFeedbackServiceImpl();
  _NEGuestServiceImpl guestService = _NEGuestServiceImpl();

  _NEMeetingKitImpl() {
    ConnectivityManager();
  }

  bool get isInitialized => CoreRepository().isInitialized;

  @override
  Future<NEResult<NEMeetingCorpInfo?>> initialize(NEMeetingKitConfig config) {
    return CoreRepository().initialize(config);
  }

  @override
  Future<NEResult<void>> switchLanguage(NEMeetingLanguage? language) async {
    return CoreRepository().switchLanguage(language);
  }

  @override
  Future<NEResult<void>> loginWithToken(String accountId, String token) async {
    return accountService.loginByToken(
      accountId,
      token,
    );
  }

  @override
  Future<NEResult<void>> loginWithNEMeeting(
      String username, String password) async {
    return accountService.loginByPassword(username, password);
  }

  @override
  Future<NEResult<void>> tryAutoLogin() async {
    apiLogger.i('tryAutoLogin');
    return accountService.tryAutoLogin();
  }

  @override
  NEMeetingService getMeetingService() => meetingService;

  @override
  NEMeetingInviteService getMeetingInviteService() => inviteService;

  @override
  NEMeetingMessageChannelService getMeetingMessageChannelService() =>
      messageChannelService;

  @override
  NEScreenSharingService getScreenSharingService() => screenSharingService;

  @override
  NEAccountService getAccountService() => accountService;

  @override
  NESettingsService getSettingsService() => settingsService;

  @override
  NEPreMeetingService getPreMeetingService() => preMeetingService;

  @override
  NEContactsService getContactsService() => contactsService;

  @override
  NEFeedbackService getFeedbackService() => feedbackService;

  @override
  NEGuestService getGuestService() => guestService;

  @override
  Future<NEResult<void>> logout() async {
    apiLogger.i('logout');
    return accountService.logout();
  }

  @override
  void addAuthListener(NEAuthListener listener) {
    apiLogger.i('addAuthListener $listener');
    accountService.addListener(listener);
  }

  @override
  void removeAuthListener(NEAuthListener listener) {
    apiLogger.i('removeAuthListener $listener');
    accountService.addListener(listener);
  }

  @override
  Future<NEResult<String?>> updateApnsToken(String data, String? key) {
    return NERoomKit.instance.updateApnsToken(data, key);
  }

  @override
  Future<String> get deviceId => NERoomKit.instance.deviceId;

  @override
  Future<NEResult<NEMeetingAppNoticeTips>> getAppNoticeTips() {
    return MeetingRepository()
        .getSecurityNotice(DateTime.now().millisecondsSinceEpoch.toString());
  }

  @override
  Future<String?> getSDKLogPath() {
    return NERoomKit.instance.logPath;
  }
}
