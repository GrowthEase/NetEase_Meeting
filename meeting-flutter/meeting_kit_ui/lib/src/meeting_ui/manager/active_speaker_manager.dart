// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// “正在讲话”成员状态变更回调
typedef OnActiveSpeakerActiveChanged = void Function(String user, bool active);

/// “正在讲话”成员列表变更回调
typedef OnActiveSpeakerListChanged = void Function(List<String> activeSpeakers);

final class ActiveSpeakerConfig {
  /// 成员有效音量阈值。远端成员每次回调的音量大小超过该阈值才算有效。默认为 10
  final int validVolumeThreshold;

  /// 最大“正在讲话”成员数。默认为 3
  final int maxActiveSpeakerCount;

  /// 成为“正在讲话”成员的音量阈值。默认为 30
  final int activeSpeakerVolumeThreshold;

  /// 音量事件回调间隔。默认为 200ms
  final int volumeIndicationInterval;

  /// 音量窗口大小。默认为 15
  final int volumeIndicationWindowSize;

  /// 是否开启视频提前订阅。默认为 true
  final bool enableVideoPreSubscribe;

  factory ActiveSpeakerConfig.fromJson(Map? json) {
    return json == null
        ? const ActiveSpeakerConfig()
        : ActiveSpeakerConfig(
            validVolumeThreshold: json['validVolumeThreshold'] as int?,
            maxActiveSpeakerCount: json['maxActiveSpeakerCount'] as int?,
            activeSpeakerVolumeThreshold:
                json['activeSpeakerVolumeThreshold'] as int?,
            volumeIndicationInterval: json['volumeIndicationInterval'] as int?,
            volumeIndicationWindowSize:
                json['volumeIndicationWindowSize'] as int?,
            enableVideoPreSubscribe: json['enableVideoPreSubscribe'] as bool?,
          );
  }

  const ActiveSpeakerConfig({
    int? validVolumeThreshold,
    int? maxActiveSpeakerCount,
    int? activeSpeakerVolumeThreshold,
    int? volumeIndicationInterval,
    int? volumeIndicationWindowSize,
    bool? enableVideoPreSubscribe,
  })  : this.maxActiveSpeakerCount = maxActiveSpeakerCount ?? 3,
        this.activeSpeakerVolumeThreshold = activeSpeakerVolumeThreshold ?? 30,
        this.volumeIndicationInterval = volumeIndicationInterval ?? 200,
        this.validVolumeThreshold = validVolumeThreshold ?? 10,
        this.volumeIndicationWindowSize = volumeIndicationWindowSize ?? 15,
        this.enableVideoPreSubscribe = enableVideoPreSubscribe ?? true;
}

///
/// [Design doc](https://docs.popo.netease.com/team/pc/nim/pageDetail/9eb9f72b597848e5ba852f70921bcb3f?popo_locale=zh&xyz=1706581344558#edit)
///
final class ActiveSpeakerManager with _AloggerMixin {
  static bool kDebugLog = false;

  final ActiveSpeakerConfig config;
  final NERoomContext roomContext;
  final OnActiveSpeakerActiveChanged? onActiveSpeakerActiveChanged;
  final OnActiveSpeakerListChanged? onActiveSpeakerListChanged;
  late final roomEventCallback = NERoomEventCallback(
    rtcRemoteAudioVolumeIndication: _onRemoteAudioVolumeIndication,
    memberLeaveRoom: _onMemberLeave,
    memberLeaveRtcChannel: _onMemberLeave,
  );

  final _activeSpeakers = <String>[];
  final _volumeIndications = Queue<List<NEMemberVolumeInfo>>();

  ActiveSpeakerManager({
    required this.roomContext,
    this.config = const ActiveSpeakerConfig(),
    this.onActiveSpeakerActiveChanged,
    this.onActiveSpeakerListChanged,
  }) {
    roomContext.rtcController.enableAudioVolumeIndication(
        true, config.volumeIndicationInterval, true);
    roomContext.addEventCallback(roomEventCallback);
  }

  void dispose() {
    _activeSpeakers.clear();
    _volumeIndications.clear();
    roomContext.removeEventCallback(roomEventCallback);
  }

  /// 获取当前“正在讲话”列表
  List<String> get activeSpeakers => List.of(_activeSpeakers);

  /// 收到远端用户音量事件，更新音量窗口列表，并更新“正在讲话”成员列表
  void _onRemoteAudioVolumeIndication(
      List<NEMemberVolumeInfo> value, int total) {
    if (kDebugLog)
      debugPrint(
          '${DateTime.now()} add volume: ${value.map((e) => e.toJson())}');
    // final validVolumes = List.of(value);
    // validVolumes
    //     .removeWhere((element) => element.volume < config.validVolumeThreshold);
    _volumeIndications.addLast(List.of(value));
    if (_volumeIndications.length > config.volumeIndicationWindowSize) {
      _volumeIndications.removeFirst();
    }
    _updateActiveSpeaker();
  }

  /// 成员离开，如果当前成员属于“正在讲话”列表中的成员，则更新“正在讲话”列表
  void _onMemberLeave(List<NERoomMember> members) {
    _volumeIndications.forEach((element) {
      element.removeWhere((e) => members.any((m) => m.uuid == e.userUuid));
    });
    if (members.any((member) => _activeSpeakers.contains(member.uuid))) {
      _updateActiveSpeaker();
    }
  }

  /// 更新“正在讲话”列表
  /// 1. 计算窗口内每个成员的平均音量；并按照音量从大到小排序
  /// 2. 过滤列表中音量小于阈值、音频关闭的成员
  /// 3. 取前3个成员作为“正在讲话”列表
  /// 4. 与当前“正在讲话”列表比较，找出新增和移除的成员，并对外通知
  void _updateActiveSpeaker() {
    final userVolumeInfos = <String, _UserVolume>{};

    /// 计算窗口内每个成员的总音量
    _volumeIndications.forEach((element) {
      element.forEach((e) {
        userVolumeInfos.update(e.userUuid, (value) {
          value.addVolume(e.volume);
          return value;
        }, ifAbsent: () => _UserVolume(e.volume));
      });
    });

    // /// 计算窗口内的音频采样数（规避采样少音量大的场景：只有一次采样，但声音很大）；
    // /// 1. 取所有用户里音频采样数最大的用户的采样数；
    // /// 2. 音频采样数的最小值为：5（对应 200 * 5 = 1000ms）
    // final samples = max(
    //     userVolumeInfos.values
    //             .maxByOrNull<num>((value) => value.samples)
    //             ?.samples ??
    //         0,
    //     5);
    final samples = config.volumeIndicationWindowSize;
    if (kDebugLog) debugPrint('userVolumeInfos: $userVolumeInfos $samples');

    /// 计算平均音量，并从大到小进行排序
    final sortedUserList = userVolumeInfos.entries.map((e) {
      return (user: e.key, volume: e.value.calculateAvgVolume(samples));
    }).toList()
      ..sort((a, b) => b.volume.compareTo(a.volume));
    if (kDebugLog) debugPrint('sortedUserList: $sortedUserList');

    /// 计算新的“正在讲话”列表
    final newActiveSpeakers = sortedUserList
        .where((e) {
          final member = roomContext.getMember(e.user);
          return member != null && member.isAudioOn && e.volume > 0;
          // e.volume >= config.activeSpeakerVolumeThreshold;
        })
        .map((e) => e.user)
        .take(config.maxActiveSpeakerCount)
        .toList();

    /// 对比新旧“正在讲话”列表，找出新增和移除的成员，并对外通知
    final newActiveSpeakersSet = newActiveSpeakers.toSet();
    final oldActiveSpeakersSet = _activeSpeakers.toSet();
    // new added active speakers
    newActiveSpeakersSet.difference(oldActiveSpeakersSet).forEach((user) {
      onActiveSpeakerActiveChanged?.call(user, true);
    });
    // removed active speakers
    oldActiveSpeakersSet.difference(newActiveSpeakersSet).forEach((user) {
      onActiveSpeakerActiveChanged?.call(user, false);
    });

    /// 顺序变化或者成员变化都需要通知
    if (!listEquals(newActiveSpeakers, _activeSpeakers)) {
      commonLogger
          .i('Active speakers changed: $_activeSpeakers -> $newActiveSpeakers');
      _activeSpeakers.clear();
      _activeSpeakers.addAll(newActiveSpeakers);
      onActiveSpeakerListChanged?.call(activeSpeakers);
    }
  }
}

final class _UserVolume {
  int totalVolume;
  int samples = 1;

  _UserVolume(this.totalVolume);

  void addVolume(int volume) {
    this.totalVolume += volume;
    samples++;
  }

  /// 返回平均音量，音量的采样次数最小为 5 次
  double calculateAvgVolume(int samples) => totalVolume / samples;

  @override
  String toString() {
    return '_UserVolume{volume: $totalVolume, samples: $samples}';
  }
}
