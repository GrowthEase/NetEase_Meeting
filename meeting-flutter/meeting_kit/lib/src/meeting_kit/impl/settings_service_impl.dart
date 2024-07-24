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
      SettingsRepository().enableShowMyMeetingElapseTime(show);

  @override
  Future<bool> isShowMyMeetingElapseTimeEnabled() =>
      SettingsRepository().isShowMyMeetingElapseTimeEnabled();

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

  @override
  String getAppNotifySessionId() =>
      SettingsRepository().getAppNotifySessionId();

  @override
  Future<NECloudRecordConfig> getCloudRecordConfig() =>
      SettingsRepository().getCloudRecordConfig();

  @override
  void setCloudRecordConfig(NECloudRecordConfig config) =>
      SettingsRepository().setCloudRecordConfig(config);
}
