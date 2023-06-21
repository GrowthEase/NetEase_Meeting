// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_kit;

/// 房间音频选项
class NERoomAudioProfile {
  /// 高清语音场景
  static final speech = NERoomAudioProfile(
    profile: NERtcAudioProfile.profileDefault.index,
    scenario: NERtcAudioScenario.scenarioSpeech.index,
  );

  /// 音乐模式场景
  static final music = NERoomAudioProfile(
    profile: NERtcAudioProfile.profileHighQuality.index,
    scenario: NERtcAudioScenario.scenarioMusic.index,
    enableAINS: false,
  );

  /// index of [NERtcAudioProfile] or -1 for unspecified
  final int profile;

  /// index of [NERtcAudioScenario] or -1 for unspecified
  final int scenario;

  final bool enableAINS;

  const NERoomAudioProfile({
    required this.profile,
    required this.scenario,
    this.enableAINS = true,
  });

  factory NERoomAudioProfile.fromJson(Map<String, dynamic> json) {
    return NERoomAudioProfile(
      profile: json['profile'] as int,
      scenario: json['scenario'] as int,
      enableAINS: json['enableAINS'] as bool,
    );
  }

  @override
  String toString() {
    return 'NERoomAudioProfile{'
        'profile: $profile, '
        'scenario: $scenario, '
        'enableAINS: $enableAINS'
        '}';
  }
}
