// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// Rtc工具类
class RtcUtils {
  static final Map<String, NERtcAudioProfile> _audioProfiles = {
    "DEFAULT": NERtcAudioProfile.profileDefault,
    "STANDARD": NERtcAudioProfile.profileStandard,
    "STANDARD_EXTEND": NERtcAudioProfile.profileStandardExtend,
    "MIDDLE_QUALITY": NERtcAudioProfile.profileMiddleQuality,
    "MIDDLE_QUALITY_STEREO": NERtcAudioProfile.profileMiddleQualityStereo,
    "HIGH_QUALITY": NERtcAudioProfile.profileHighQuality,
    "HIGH_QUALITY_STEREO": NERtcAudioProfile.profileHighQualityStereo
  };

  static final Map<String, NERtcAudioScenario> _audioScenarios = {
    "DEFAULT": NERtcAudioScenario.scenarioDefault,
    "SPEECH": NERtcAudioScenario.scenarioSpeech,
    "MUSIC": NERtcAudioScenario.scenarioMusic,
    "CHATROOM": NERtcAudioScenario.scenarioChatroom
  };

  static int getRtcAudioProfile(String? profile) =>
      _audioProfiles[profile]?.index ?? NERtcAudioProfile.profileDefault.index;

  static int getRtcAudioScenario(String? scenario) =>
      _audioScenarios[scenario]?.index ??
      NERtcAudioScenario.scenarioDefault.index;
}
