// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

class _NESettingsServiceImpl extends NESettingsService
    with NEAccountServiceListener {
  static final _NESettingsServiceImpl _instance = _NESettingsServiceImpl._();

  factory _NESettingsServiceImpl() => _instance;

  _NESettingsServiceImpl._() {
    SettingsRepository().ensureSettings();
    AccountRepository().addListener(this);
    SettingsRepository().addListener(() {
      notifyListeners();
    });
  }

  @override
  void onAccountInfoUpdated(NEAccountInfo? accountInfo) {
    SettingsRepository().ensureSettings();
  }

  @override
  void enableShowMyMeetingElapseTime(bool show) =>
      SettingsRepository().setMeetingElapsedTimeDisplayType(show
          ? NEMeetingElapsedTimeDisplayType.meetingElapsedTime
          : NEMeetingElapsedTimeDisplayType.none);

  @override
  Future<bool> isShowMyMeetingElapseTimeEnabled() =>
      SettingsRepository().getMeetingElapsedTimeDisplayType().then((value) =>
          value == NEMeetingElapsedTimeDisplayType.meetingElapsedTime);

  @override
  void setMeetingElapsedTimeDisplayType(NEMeetingElapsedTimeDisplayType type) =>
      SettingsRepository().setMeetingElapsedTimeDisplayType(type);

  @override
  Future<NEMeetingElapsedTimeDisplayType> getMeetingElapsedTimeDisplayType() =>
      SettingsRepository().getMeetingElapsedTimeDisplayType();

  @override
  void enableTurnOnMyAudioWhenJoinMeeting(bool enable) =>
      SettingsRepository().enableTurnOnMyAudioWhenJoinMeeting(enable);

  @override
  Future<bool> isTurnOnMyAudioWhenJoinMeetingEnabled() =>
      SettingsRepository().isTurnOnMyAudioWhenJoinMeetingEnabled();

  @override
  void enableTurnOnMyVideoWhenJoinMeeting(bool enable) =>
      SettingsRepository().enableTurnOnMyVideoWhenJoinMeeting(enable);

  @override
  Future<bool> isTurnOnMyVideoWhenJoinMeetingEnabled() =>
      SettingsRepository().isTurnOnMyVideoWhenJoinMeetingEnabled();

  @override
  Future<bool> isAudioAINSEnabled() =>
      SettingsRepository().isAudioAINSEnabled();

  @override
  void enableAudioAINS(bool enable) =>
      SettingsRepository().enableAudioAINS(enable);

  @override
  Future<int> getBeautyFaceValue() => SettingsRepository().getBeautyFaceValue();

  @override
  bool isBeautyFaceSupported() => SettingsRepository().isBeautyFaceSupported();

  @override
  Future<void> setBeautyFaceValue(int value) =>
      SettingsRepository().setBeautyFaceValue(value);

  @override
  bool isMeetingLiveSupported() =>
      SettingsRepository().isMeetingLiveSupported();

  @override
  bool isWaitingRoomSupported() =>
      SettingsRepository().isWaitingRoomSupported();

  @override
  bool isMeetingCloudRecordSupported() =>
      SettingsRepository().isMeetingCloudRecordSupported();

  @override
  bool isMeetingWhiteboardSupported() =>
      SettingsRepository().isMeetingWhiteboardSupported();

  @override
  void enableVirtualBackground(bool enable) =>
      SettingsRepository().enableVirtualBackground(enable);

  @override
  Future<bool> isVirtualBackgroundEnabled() =>
      SettingsRepository().isVirtualBackgroundEnabled();

  @override
  void setBuiltinVirtualBackgroundList(List<String> pathList) =>
      SettingsRepository().setBuiltinVirtualBackgroundList(pathList);

  @override
  Future<List<String>> getBuiltinVirtualBackgroundList() =>
      SettingsRepository().getBuiltinVirtualBackgroundList();

  @override
  void setCurrentVirtualBackground(String? path) =>
      SettingsRepository().setCurrentVirtualBackground(path);

  @override
  Future<String?> getCurrentVirtualBackground() =>
      SettingsRepository().getCurrentVirtualBackground();

  @override
  void setExternalVirtualBackgroundList(List<String> virtualBackgrounds) =>
      SettingsRepository().setExternalVirtualBackgroundList(virtualBackgrounds);

  @override
  Future<List<String>> getExternalVirtualBackgroundList() =>
      SettingsRepository().getExternalVirtualBackgroundList();

  @override
  void enableSpeakerSpotlight(bool enable) =>
      SettingsRepository().enableSpeakerSpotlight(enable);

  @override
  Future<bool> isSpeakerSpotlightEnabled() =>
      SettingsRepository().isSpeakerSpotlightEnabled();

  @override
  Future<bool> isFrontCameraMirrorEnabled() =>
      SettingsRepository().isFrontCameraMirrorEnabled();

  @override
  Future<void> enableFrontCameraMirror(bool enable) =>
      SettingsRepository().enableFrontCameraMirror(enable);

  @override
  Future<bool> isTransparentWhiteboardEnabled() =>
      SettingsRepository().isTransparentWhiteboardEnabled();

  @override
  Future<void> enableTransparentWhiteboard(bool enable) {
    return SettingsRepository().enableTransparentWhiteboard(enable);
  }

  @override
  bool isVirtualBackgroundSupported() =>
      SettingsRepository().isVirtualBackgroundSupported();

  @override
  set value(Map newValue) {
    SettingsRepository().value = newValue;
  }

  @override
  Map get value => SettingsRepository().value;

  @override
  NEInterpretationConfig getInterpretationConfig() =>
      SettingsRepository().getInterpretationConfig();

  @override
  NEScheduledMemberConfig getScheduledMemberConfig() =>
      SettingsRepository().getScheduledMemberConfig();

  @override
  bool isAvatarUpdateSupported() =>
      SettingsRepository().isAvatarUpdateSupported();

  @override
  bool isNicknameUpdateSupported() =>
      SettingsRepository().isNicknameUpdateSupported();

  @override
  bool isCaptionsSupported() => SettingsRepository().isCaptionsSupported();

  @override
  bool isTranscriptionSupported() =>
      SettingsRepository().isTranscriptionSupported();

  bool isGuestJoinSupported() => SettingsRepository().isGuestJoinSupported();

  bool isMeetingChatSupported() =>
      SettingsRepository().isMeetingChatSupported();

  @override
  String getAppNotifySessionId() =>
      SettingsRepository().getAppNotifySessionId();

  @override
  Future<NECloudRecordConfig> getCloudRecordConfig() =>
      SettingsRepository().getCloudRecordConfig();

  @override
  void setCloudRecordConfig(NECloudRecordConfig config) =>
      SettingsRepository().setCloudRecordConfig(config);

  @override
  Future<int> setASRTranslationLanguage(
          NEMeetingASRTranslationLanguage language) =>
      SettingsRepository().setASRTranslationLanguage(language);

  @override
  NEMeetingASRTranslationLanguage getASRTranslationLanguage() =>
      SettingsRepository().getASRTranslationLanguage();

  @override
  Future<int> enableCaptionBilingual(bool enable) =>
      SettingsRepository().enableCaptionBilingual(enable);

  @override
  bool isCaptionBilingualEnabled() =>
      SettingsRepository().isCaptionBilingualEnabled();

  @override
  Future<int> enableTranscriptionBilingual(bool enable) =>
      SettingsRepository().enableTranscriptionBilingual(enable);

  @override
  bool isTranscriptionBilingualEnabled() =>
      SettingsRepository().isTranscriptionBilingualEnabled();

  @override
  void addSettingsChangedListener(NESettingsChangedListener listener) =>
      SettingsRepository().addSettingsChangedListener(listener);

  @override
  void removeSettingsChangedListener(NESettingsChangedListener listener) =>
      SettingsRepository().removeSettingsChangedListener(listener);

  Future<NEChatMessageNotificationType> getChatMessageNotificationType() =>
      SettingsRepository().getChatMessageNotificationType();

  @override
  void setChatMessageNotificationType(NEChatMessageNotificationType type) =>
      SettingsRepository().setChatMessageNotificationType(type);

  Future<bool> isShowNameInVideoEnabled() =>
      SettingsRepository().isShowNameInVideoEnabled();

  @override
  Future<void> enableShowNameInVideo(bool enable) =>
      SettingsRepository().enableShowNameInVideo(enable);

  @override
  Future<bool> isShowNotYetJoinedMembersEnabled() =>
      SettingsRepository().isShowNotYetJoinedMembersEnabled();

  @override
  void enableShowNotYetJoinedMembers(bool enable) =>
      SettingsRepository().enableShowNotYetJoinedMembers(enable);

  @override
  bool isCallOutRoomSystemDeviceSupported() =>
      SettingsRepository().isCallOutRoomSystemDeviceSupported();

  @override
  Future<void> enableHideVideoOffAttendees(bool enable) =>
      SettingsRepository().enableHideVideoOffAttendees(enable);

  @override
  Future<bool> isHideVideoOffAttendeesEnabled() =>
      SettingsRepository().isHideVideoOffAttendeesEnabled();

  @override
  Future<void> enableHideMyVideo(bool enable) =>
      SettingsRepository().enableHideMyVideo(enable);

  @override
  Future<bool> isHideMyVideoEnabled() =>
      SettingsRepository().isHideMyVideoEnabled();

  @override
  void enableLeaveTheMeetingRequiresConfirmation(bool enable) =>
      SettingsRepository().enableLeaveTheMeetingRequiresConfirmation(enable);

  @override
  Future<bool> isLeaveTheMeetingRequiresConfirmationEnabled() =>
      SettingsRepository().isLeaveTheMeetingRequiresConfirmationEnabled();
}
