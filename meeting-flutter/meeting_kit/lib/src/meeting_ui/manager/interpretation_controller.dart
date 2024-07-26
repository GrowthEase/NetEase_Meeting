// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

///
/// 会中同声传译控制器
///
abstract class NEInterpretationController extends ChangeNotifier {
  factory NEInterpretationController(
      NERoomContext roomContext, NEInterpretationConfig config) {
    return _InterpretationController._(roomContext, config);
  }

  /// 操作被禁止
  static const int codeForbidden = -2;

  NEInterpretationController._();

  /// 同声传译是否已经开始
  bool isInterpretationStarted();

  /// 同声传译开启/关闭事件流
  Stream<bool> get interpretationStartedChanged;

  /// 开启同声传译
  Future<VoidResult> startInterpretation(
      {List<NEMeetingInterpreter>? interpreters});

  /// 停止同声传译
  Future<VoidResult> stopInterpretation();

  /// 更新译员列表
  Future<VoidResult> updateInterpreterList(
      List<NEMeetingInterpreter> interpreters);

  /// 获取译员列表
  List<NEMeetingInterpreter> getInterpreterList();

  /// 获取当前会议目前可用的语言列表
  List<String> getAvailableLanguageList();

  /// 原声是否静音
  bool isMajorAudioMute();

  /// 获取原声频道播放音量
  int getMajorAudioVolume();

  /// 设置开启/关闭同时收听原声
  void enableMajorAudioInBackground(bool enable);

  /// 是否同时收听原声
  bool isMajorAudioInBackgroundEnabled();

  /// 设置原声静音
  Future<VoidResult> muteMajorAudio(bool mute);

  /// 设置原声音量
  Future<VoidResult> adjustMajorAudioVolume(int volume);

  /// 当前是否在原声频道发言
  bool isSpeakingInMajorChannel();

  /// 设置传译语言
  Future<VoidResult> setSpeakLanguage(String? languageTag,
      {bool force = false});

  /// 返回当前传译语言，如果未设置则返回 null，说明此时在主房间说话
  String? get speakLanguage;

  /// 当前是否在频道中讲话
  bool isMySpeakLanguageChannel(String? channel);

  /// 设置收听语言
  Future<VoidResult> setListenLanguage(String? languageTag,
      {bool force = false});

  /// 返回当前收听语言，如果未设置则返回 null，说明此时在收听主房间
  String? get listenLanguage;

  /// 加入语言频道
  Future<VoidResult> joinLanguageChannel(String languageTag);

  /// 离开语言频道
  Future<VoidResult> leaveLanguageChannel(String languageTag);

  /// 本端是否为译员
  bool isMySelfInterpreter();

  /// 本端译员信息
  NEMeetingInterpreter? getMySelfInterpreter();

  /// 成员是否为译员
  bool isUserInterpreter(String userId);

  /// 添加监听器
  void addEventListener(NEInterpretationEventListener listener);

  /// 移除监听器
  void removeEventListener(NEInterpretationEventListener listener);

  /// 释放资源
  void dispose();
}

/// 同声传译事件监听器
mixin class NEInterpretationEventListener {
  /// 房间内可用语言列表更新通知
  void onAvailableLanguageListUpdated(List<String> languageList) {}

  /// 同声传译开启状态变更通知
  void onInterpretationStartStateChanged(bool started, bool bySelf) {}

  /// 同声传译译员列表变更通知
  void onInterpreterListChanged(List<NEMeetingInterpreter> interpreters) {}

  /// 本端同声传译译员角色变更通知
  void onMyInterpreterChanged(
      NEMeetingInterpreter? myInterpreter, bool bySelf) {}

  /// 本端传译语言变更通知
  void onMySpeakLanguageChanged(String? language) {}

  /// 本端收听语言变更通知
  void onMyListenLanguageChanged(String? language) {}

  /// 本端收听的语言频道被删除
  void onMyListenLanguageRemoved(String language, bool bySelf) {}

  /// 当前收听的频道译员离线
  void onMyListenInterpreterOffline(String language) {}

  /// 译员离会通知
  void onInterpreterLeaveMeeting(List<NEMeetingInterpreter> interpreters) {}

  /// 译员入会通知
  void onInterpreterJoinMeeting(List<NEMeetingInterpreter> interpreters) {}

  /// 收听频道断开
  void onMyListeningLanguageDisconnect(String lang, int reason) {}

  /// 传译频道断开
  void onMySpeakingLanguageDisconnect(String lang, int reason) {}
}

class _InterpretationController extends NEInterpretationController
    with _AloggerMixin {
  static const majorChannelNoSoundTimeout = 6000;
  static const majorChannelVolumeRecoverDuration = 2000;
  static const majorChannelVolumeRecoverStep = 20;
  static const maxVolume = 100;

  static const String interpPropKey = 'interpretation';
  static const String startedKey = 'started';
  static const String channelsKey = 'channelNames';

  _InterpretationController._(this.roomContext, this.config)
      : meetingId = roomContext.meetingInfo.meetingId.toString(),
        super._() {
    roomContext.addEventCallback(eventCallback);
    updateState();
  }

  final NERoomContext roomContext;
  final NEInterpretationConfig config;
  final String meetingId;
  late final eventCallback = NERoomEventCallback(
    roomPropertiesChanged: mayHandleInterpretationChanged,
    roomPropertiesDeleted: mayHandleInterpretationChanged,
    memberAudioMuteChanged: (member, mute, _) {
      /// 本端作为译员，音频状态发生变更，需要更新 pub 状态
      if (_speakLanguage != null && member.uuid == roomContext.myUuid) {
        commonLogger
            .i('update speak language mute state: $_speakLanguage $mute');
        final channel = langRtcChannels[_speakLanguage]!;
        enableChannelAudioPublish(channel, !mute);
      }
    },
    memberLeaveRoom: (members) {
      if (!this.interpStarted) return;

      final leavings = members.map((e) => e.uuid).toSet();
      final leavingList = interpSettings
              ?.getInterpreterList()
              .where((interpreter) => leavings.contains(interpreter.userId))
              .toList() ??
          [];

      /// 译员离开房间，需要检查语言是否仍然可以收听
      if (leavingList.isNotEmpty) {
        final listenLang = _listenLanguage;
        if (listenLang != null &&
            !getAvailableLanguageList().contains(listenLang) &&
            leavingList.any((interpreter) =>
                interpreter.firstLang == listenLang ||
                interpreter.secondLang == listenLang)) {
          commonLogger
              .i('my listen interpreter with language($listenLang) is offline');
          notifyEventListeners(
              (listener) => listener.onMyListenInterpreterOffline(listenLang));
        }
        if (roomContext.isMySelfHostOrCoHost()) {
          notifyEventListeners(
              (listener) => listener.onInterpreterLeaveMeeting(leavingList));
        }
        notifyListeners();
      }
    },
    memberJoinRoom: (members) {
      if (!this.interpStarted) return;
      final joinings = members.map((e) => e.uuid).toSet();

      /// 译员加入房间，通知可用语言变化
      final joiningList = interpSettings
              ?.getInterpreterList()
              .where((interpreter) => joinings.contains(interpreter.userId))
              .toList() ??
          [];
      if (joiningList.isNotEmpty && roomContext.isMySelfHostOrCoHost()) {
        commonLogger.i('interpreters join meeting');
        notifyEventListeners(
            (listener) => listener.onInterpreterJoinMeeting(joiningList));
        notifyListeners();
      }
    },
    rtcRemoteAudioVolumeIndication: handleRtcRemoteAudioVolumeIndication,
    rtcChannelDisconnect: (channel, reason) {
      if (!this.interpStarted || channel == null) return;
      commonLogger.i('channel($channel) disconnect: $reason');
      for (var lang in joinedLangs.toList()) {
        if (langRtcChannels[lang] == channel) {
          final leaving = leaveLanguageChannel(lang);

          /// 收听语言频道断开
          if (_listenLanguage == lang) {
            cancelNoSoundCheckTimer();
            notifyEventListeners((listener) =>
                listener.onMyListeningLanguageDisconnect(lang, reason));
            commonLogger.i('start reconnect listen language channel: $lang');
            leaving
                .then((_) => setListenLanguage(lang, force: true))
                .then((result) {
              commonLogger
                  .i('reconnect listen language channel result: $result');

              /// 重连失败，切换到主频道
              if (!result.isSuccess() && _listenLanguage == lang) {
                setListenLanguage(null);
              }
            });
          } else if (_speakLanguage == lang) {
            /// 传译语言频道断开
            notifyEventListeners((listener) =>
                listener.onMySpeakingLanguageDisconnect(lang, reason));
            commonLogger.i('start reconnect speak language channel: $lang');
            leaving
                .then((_) => setSpeakLanguage(lang, force: true))
                .then((result) {
              commonLogger
                  .i('reconnect speak language channel result: $result');

              /// 重连失败，切换到主频道
              if (!result.isSuccess() && _speakLanguage == lang) {
                setSpeakLanguage(null);
              }
            });
          }
        }
      }
    },
  );

  bool interpStarted = false;
  NEMeetingInterpretationSettings? interpSettings;
  NEMeetingInterpreter? myInterpreter;
  final langRtcChannels = <String, String>{};
  final joinedLangs = <String>{};

  void mayHandleInterpretationChanged(Map<String, String> properties) {
    if (properties.containsKey(interpPropKey)) {
      updateState();
      notifyListeners();
    }
  }

  void updateState() {
    final value = roomContext.roomProperties[interpPropKey];
    bool started = false;
    var interpSettings = NEMeetingInterpretationSettings();
    if (value != null && value.isNotEmpty) {
      assert(() {
        commonLogger.i('interpretation settings: $value');
        return true;
      }());
      try {
        final data = jsonDecode(value) as Map?;
        interpSettings = NEMeetingInterpretationSettings.fromJson(data);
        (data?[channelsKey] as Map?)?.forEach((key, value) {
          if (key is String && value is String) {
            langRtcChannels[key] = value;
          }
        });
        started = data?[startedKey] == true && !interpSettings.isEmpty;
        this.interpSettings = interpSettings;
      } catch (e) {
        commonLogger.e('parse interpretation settings failed: $e');
      }
    }
    final operateBySelf = _operateByMySelf;
    _operateByMySelf = false;
    if (started != this.interpStarted) {
      commonLogger.i(
          'interpretation started changed: ${this.interpStarted} -> $started');
      this.interpStarted = started;
      notifyEventListeners((listener) =>
          listener.onInterpretationStartStateChanged(started, operateBySelf));
      startedStreamController.add(started);
    }
    final myInterpreter = interpSettings
        .getInterpreterList()
        .firstWhereOrNull((element) => element.userId == roomContext.myUuid);
    if (myInterpreter != this.myInterpreter) {
      commonLogger
          .i('my interpreter changed: ${this.myInterpreter} -> $myInterpreter');
      this.myInterpreter = myInterpreter;
      notifyEventListeners((listener) =>
          listener.onMyInterpreterChanged(myInterpreter, operateBySelf));
    }

    /// 更新收听语言
    String? listenLang = started ? _listenLanguage : null;
    if (listenLang != null) {
      /// 如果收听语言不可用，则重置收听语言为 null
      if (!getAvailableLanguageList().contains(listenLang)) {
        commonLogger.i('default listen language changed: $listenLang');
        if (started && !isLanguageExists(listenLang)) {
          /// 收听语言已经被删除了
          notifyEventListeners((listener) =>
              listener.onMyListenLanguageRemoved(listenLang!, operateBySelf));
          listenLang = null;
        }
      }
    }
    if (_listenLanguage != listenLang) {
      setListenLanguage(listenLang);
    }

    /// 更新传译语言
    String? speakLang =
        started ? (_speakLanguage ?? myInterpreter?.firstLang) : null;
    if (speakLang != null &&
        speakLang != myInterpreter?.firstLang &&
        speakLang != myInterpreter?.secondLang) {
      speakLang = started ? myInterpreter?.firstLang : null;
      commonLogger.i('default speak language changed: $speakLang');
    }
    if (_speakLanguage != speakLang) {
      setSpeakLanguage(speakLang);
    }

    /// 清理不再需要的语言频道
    joinedLangs.toList().forEach((lang) {
      if (!shouldStayInLanguageChannel(lang)) {
        leaveLanguageChannel(lang);
      }
    });

    /// 作为译员需要提前加入语言频道以减小延迟
    if (started && myInterpreter != null) {
      preJoinLanguageChannel(myInterpreter.firstLang);
      preJoinLanguageChannel(myInterpreter.secondLang);
    }
  }

  void preJoinLanguageChannel(String language) {
    joinLanguageChannel(language).then((value) {
      commonLogger.i('pre join language channel: $language, result: $value');
      if (value.isSuccess()) {
        if (shouldStayInLanguageChannel(language)) {
          // 调整频道播放音量：如果不是当前收听的频道，调整播放音量为 0
          if (language != _listenLanguage) {
            langRtcChannels[language].guard((channel) {
              adjustChannelPlaybackVolume(channel, 0);
            });
          }
        } else {
          leaveLanguageChannel(language);
        }
      }
    });
  }

  void enableChannelAudioPublish(String? channel, bool enable) {
    roomContext.rtcController
        .enableMediaPub(
      NERoomRtcMediaPublishType.audio,
      enable,
      channel: channel ?? roomContext.roomUuid,
    )
        .then((value) {
      commonLogger.i(
          'enable audio publish: channel=$channel, enable=$enable, result=$value');
    });
  }

  void enableChannelLocalAudio(String? channel, bool enable) {
    roomContext.rtcController
        .enableLocalAudio(
      channel ?? roomContext.roomUuid,
      enable,
    )
        .then((value) {
      commonLogger.i(
          'enable local audio: channel=$channel, enable=$enable, result=$value');
    });
  }

  @override
  void dispose() {
    roomContext.removeEventCallback(eventCallback);
    startedStreamController.close();
    cancelNoSoundCheckTimer();
    super.dispose();
  }

  bool isLanguageExists(String lang) {
    final interpreters = interpSettings?.getInterpreterList();
    if (interpreters == null || interpreters.isEmpty) {
      return false;
    }
    return interpreters.any((interpreter) =>
        interpreter.firstLang == lang || interpreter.secondLang == lang);
  }

  @override
  List<String> getAvailableLanguageList() {
    final interpreters = interpSettings?.getInterpreterList();
    if (interpreters == null || interpreters.isEmpty) {
      return [];
    }
    final result = LinkedHashSet<String>();
    for (var interpreter in interpreters) {
      /// 译员在会
      if (roomContext.getMember(interpreter.userId)?.isInRtcChannel == true) {
        result
          ..add(interpreter.firstLang)
          ..add(interpreter.secondLang);
      }
    }
    return result.toList();
  }

  @override
  List<NEMeetingInterpreter> getInterpreterList() {
    return interpSettings?.getInterpreterList() ?? [];
  }

  @override
  bool isInterpretationStarted() {
    return interpStarted;
  }

  final startedStreamController = StreamController<bool>.broadcast();
  @override
  Stream<bool> get interpretationStartedChanged =>
      startedStreamController.stream;

  @override
  bool isMySelfInterpreter() {
    return myInterpreter != null;
  }

  NEMeetingInterpreter? getMySelfInterpreter() {
    return myInterpreter;
  }

  @override
  bool isUserInterpreter(String userId) {
    return interpSettings
            ?.getInterpreterList()
            .firstWhereOrNull((interpreter) => interpreter.userId == userId) !=
        null;
  }

  @override
  Future<VoidResult> joinLanguageChannel(String language) async {
    if (joinedLangs.contains(language)) {
      return VoidResult.success();
    }
    final channel = langRtcChannels[language];
    var result = const VoidResult(code: -1, msg: 'language channel not exists');
    if (channel != null) {
      result = await roomContext.rtcController.joinRtcChannel(channel: channel);
    }
    if (result.isSuccess()) {
      joinedLangs.add(language);
    }
    commonLogger.i('join language channel: $language, result: $result');
    return result;
  }

  @override
  Future<VoidResult> leaveLanguageChannel(String language) async {
    if (!joinedLangs.contains(language)) {
      return VoidResult.success();
    }
    final channel = langRtcChannels[language];
    var result = const VoidResult(code: -1, msg: 'language channel not exists');
    if (channel != null) {
      joinedLangs.remove(language);
      result =
          await roomContext.rtcController.leaveRtcChannel(channel: channel);
    }
    commonLogger.i('leave language channel: $language, result: $result');
    return result;
  }

  /// 原声频道是否已经静音
  bool _majorAudioMuted = false;

  /// 原声频道音量
  late int _majorAudioVolume = config.defMajorAudioVolume;

  bool _majorAudioInBackground = false;

  @override
  bool isMajorAudioMute() {
    return _majorAudioMuted;
  }

  @override
  int getMajorAudioVolume() {
    return _majorAudioVolume;
  }

  void enableMajorAudioInBackground(bool enable) {
    if (_majorAudioInBackground != enable) {
      final int volume = enable && !_majorAudioMuted ? _majorAudioVolume : 0;
      adjustChannelPlaybackVolume(roomContext.roomUuid, volume).onSuccess(() {
        _majorAudioInBackground = enable;
        cancelNoSoundCheckTimer();
        notifyListeners();
      });
    }
  }

  bool isMajorAudioInBackgroundEnabled() {
    return _majorAudioInBackground;
  }

  @override
  Future<VoidResult> muteMajorAudio(bool mute) {
    commonLogger.i('mute major audio: $mute');
    return adjustChannelPlaybackVolume(
            roomContext.roomUuid, mute ? 0 : _majorAudioVolume)
        .onSuccess(() {
      if (_majorAudioMuted != mute) {
        _majorAudioMuted = mute;
        notifyListeners();
      }
    });
  }

  Future<VoidResult> adjustMajorAudioVolume(int volume) {
    commonLogger.i('adjust major audio volume: $volume');
    return adjustChannelPlaybackVolume(roomContext.roomUuid, volume)
        .onSuccess(() {
      if (_majorAudioVolume != volume) {
        _majorAudioVolume = volume;
        _pendingResetMajorAudioVolume = null;
        notifyListeners();
      }
    });
  }

  /// 调整对应频道的播放音量
  Future<VoidResult> adjustChannelPlaybackVolume(String? channel, int volume) {
    return roomContext.rtcController
        .adjustPlaybackSignalVolume(volume, channel: channel)
        .then((value) {
      commonLogger
          .i('adjust channel($channel) audio volume: $volume, result: $value');
      return value;
    });
  }

  bool isSpeakingInMajorChannel() {
    return _speakLanguage == null;
  }

  String? _listenLanguage;
  @override
  String? get listenLanguage => _listenLanguage;

  String? _pendingListenLanguage;
  int _setListenLanguageReqId = 0;
  @override
  Future<VoidResult> setListenLanguage(String? language,
      {bool force = false}) async {
    final lastLanguage = _listenLanguage;
    final interpStarted = this.interpStarted;

    /// 1. 同传已经开始，允许设置收听语言；
    /// 2. 同传未开始，只允许恢复切换到原声频道；
    final canChange = (language != null && interpStarted) ||
        (language == null && lastLanguage != null);
    if (!canChange) {
      return VoidResult(
          code: NEInterpretationController.codeForbidden, msg: 'forbidden');
    }
    final reqId = ++_setListenLanguageReqId;
    _pendingListenLanguage = language;
    final changed = language != lastLanguage;
    if (changed || force) {
      commonLogger.i('set listen language: $lastLanguage -> $language');
      // 如果是重新收听原声频道，则恢复原声频道音量为默认值 100
      if (language == null) {
        adjustChannelPlaybackVolume(roomContext.roomUuid, maxVolume);
      } else {
        final langChannel = langRtcChannels[language];
        assert(interpStarted && langChannel != null);
        // 加入对应语言频道
        final result = await joinLanguageChannel(language);
        if (reqId == _setListenLanguageReqId) {
          _pendingListenLanguage = null;
        }
        if (!result.isSuccess()) {
          return result;
        }
        if (reqId != _setListenLanguageReqId) {
          if (!shouldStayInLanguageChannel(language)) {
            leaveLanguageChannel(language);
          }
          return VoidResult(code: NEMeetingErrorCode.cancelled);
        }
        // 调整频道播放音量为默认 100
        adjustChannelPlaybackVolume(langChannel, maxVolume);
      }
      _listenLanguage = language;
      if (_listenLanguage == null) {
        _majorAudioInBackground = false;
      }

      if (changed) {
        final lastLangChannel = langRtcChannels[lastLanguage];
        // 先静音语音频道
        if (lastLangChannel == null) {
          adjustChannelPlaybackVolume(roomContext.roomUuid, 0);
        } else {
          adjustChannelPlaybackVolume(lastLangChannel, 0);
        }
        if (lastLanguage != null && lastLangChannel != null) {
          // 需要退出语言频道
          if (!shouldStayInLanguageChannel(lastLanguage)) {
            leaveLanguageChannel(lastLanguage);
          }
        }
        notifyEventListeners(
            (listener) => listener.onMyListenLanguageChanged(language));
        notifyListeners();
      }

      /// 译员的收听语言和传译语言不能为同一语言，需要自动切换
      if (interpStarted &&
          isMySelfInterpreter() &&
          language != null &&
          language == _speakLanguage) {
        commonLogger.i('auto switch speak language');
        setSpeakLanguage(myInterpreter?.flipLanguage(language));
      }
    }
    _pendingListenLanguage = null;
    cancelNoSoundCheckTimer();
    resetAudioVolumeIndication();
    return VoidResult.success();
  }

  String? _speakLanguage;
  @override
  String? get speakLanguage => _speakLanguage;

  bool isMySpeakLanguageChannel(String? channel) {
    return langRtcChannels[_speakLanguage] == channel;
  }

  String? _pendingSpeakLanguage;
  int _setSpeakLanguageReqId = 0;
  @override
  Future<VoidResult> setSpeakLanguage(String? language,
      {bool force = false}) async {
    final lastSpeakLang = _speakLanguage;
    final interpStarted = this.interpStarted;

    /// 1. 译员允许设置传译语言；
    /// 2. 非译员，但历史传译语言不为空，允许切换回主房间
    final canChanged = (language != null &&
            (myInterpreter?.firstLang == language ||
                myInterpreter?.secondLang == language) &&
            interpStarted) ||
        (language == null && lastSpeakLang != null);
    if (!canChanged) {
      return VoidResult(
          code: NEInterpretationController.codeForbidden, msg: 'forbidden');
    }
    final reqId = ++_setSpeakLanguageReqId;
    _pendingSpeakLanguage = language;
    final changed = language != lastSpeakLang;
    if (changed || force) {
      commonLogger.i('set speak language: $lastSpeakLang -> $language');
      if (language != null) {
        /// 加入新的语言频道
        final result = await joinLanguageChannel(language);
        if (reqId == _setSpeakLanguageReqId) {
          _pendingSpeakLanguage = null;
        }
        if (!result.isSuccess()) {
          return result;
        }
        if (reqId != _setSpeakLanguageReqId) {
          if (!shouldStayInLanguageChannel(language)) {
            leaveLanguageChannel(language);
          }
          return VoidResult(code: NEMeetingErrorCode.cancelled);
        }
      }

      /// 关闭上一个语言频道的音频 pub
      final lastSpeakLangChannel = langRtcChannels[lastSpeakLang];
      enableChannelLocalAudio(lastSpeakLangChannel, false);
      enableChannelAudioPublish(lastSpeakLangChannel, false);

      /// 开启新的语言频道的音频 pub
      final langChannel = langRtcChannels[language];
      if (langChannel != null) {
        // 如果不是在主频道发布流，把主频道的音频关闭
        enableChannelLocalAudio(null, false);
      }

      /// 提前打开音频设备，可以获取音量上报
      enableChannelLocalAudio(langChannel, true);
      enableChannelAudioPublish(langChannel, roomContext.localMember.isAudioOn);
      _speakLanguage = language;
      if (changed) {
        notifyEventListeners(
            (listener) => listener.onMySpeakLanguageChanged(language));
        notifyListeners();
      }

      /// 译员的收听语言和传译语言不能为同一语言，需要自动切换
      if (interpStarted &&
          isMySelfInterpreter() &&
          language != null &&
          language == _listenLanguage) {
        commonLogger.i('auto switch listen language');
        setListenLanguage(myInterpreter?.flipLanguage(language));
      }
    }
    _pendingSpeakLanguage = null;
    resetAudioVolumeIndication();
    return VoidResult.success();
  }

  /// 判断是否需要保留语言频道
  bool shouldStayInLanguageChannel(String language) {
    return interpStarted &&
        (language == _speakLanguage ||
            language == _listenLanguage ||
            language == _pendingListenLanguage ||
            language == _pendingSpeakLanguage ||
            language == myInterpreter?.firstLang ||
            language == myInterpreter?.secondLang);
  }

  bool _operateByMySelf = false;
  @override
  Future<VoidResult> startInterpretation(
      {List<NEMeetingInterpreter>? interpreters}) async {
    _operateByMySelf = true;
    final result = await MeetingInterpretationRepo.start(meetingId,
        settings: interpreters != null
            ? NEMeetingInterpretationSettings(interpreters)
            : null);
    commonLogger.i('start interpretation result: $result');
    return result;
  }

  @override
  Future<VoidResult> stopInterpretation() async {
    _operateByMySelf = true;
    final result = await MeetingInterpretationRepo.stop(meetingId);
    commonLogger.i('stop interpretation result: $result');
    return result;
  }

  @override
  Future<VoidResult> updateInterpreterList(
      List<NEMeetingInterpreter> interpreters) async {
    _operateByMySelf = true;
    final settings = NEMeetingInterpretationSettings(interpreters);
    final result =
        await MeetingInterpretationRepo.updateSettings(meetingId, settings);
    commonLogger.i('update interpreter list result: $result');
    return result;
  }

  final listeners = ObserverList<NEInterpretationEventListener>();
  @override
  void addEventListener(NEInterpretationEventListener listener) {
    listeners.add(listener);
  }

  @override
  void removeEventListener(NEInterpretationEventListener listener) {
    listeners.remove(listener);
  }

  void notifyEventListeners(
      void Function(NEInterpretationEventListener listener) notify) {
    final copy = listeners.toList();
    for (var listener in copy) {
      if (listeners.contains(listener)) {
        notify(listener);
      }
    }
  }

  void resetAudioVolumeIndication() {
    debugPrint('resetAudioVolumeIndication');
    joinedLangs.forEach((lang) {
      final enable = lang == _listenLanguage || lang == _speakLanguage;
      final channel = langRtcChannels[lang];
      if (channel != null) {
        EnableAudioVolumeIndicationController.enableAudioVolumeIndication(
            channel, enable);
      }
    });
  }

  /// 收听频道无声音计时器
  Timer? _noSoundCheckTimer;

  /// 处理远端音量回调
  void handleRtcRemoteAudioVolumeIndication(
    String? channel,
    List<NEMemberVolumeInfo> volumes,
    int totalVolume,
  ) {
    if (channel == null || !isListeningAndMajorAudioInBackground(channel))
      return;
    debugPrint(
        'handleRtcRemoteAudioVolumeIndication: $channel, ${volumes.map((e) => '${e.userUuid}-${e.volume}').join(',')}, $totalVolume');

    /// 6S 内无声音，逐渐恢复原声频道音量
    if (volumes.isEmpty || totalVolume == 0) {
      _noSoundCheckTimer ??=
          Timer(const Duration(milliseconds: majorChannelNoSoundTimeout), () {
        if (isListeningAndMajorAudioInBackground(channel)) {
          recoverMajorAudioVolumeGradually(channel);
        }
      });
    } else {
      /// 有声音，取消无声音检测计时器，并重置原声频道音量
      cancelNoSoundCheckTimer();
      if (_pendingResetMajorAudioVolume != null) {
        adjustMajorAudioVolume(_pendingResetMajorAudioVolume!);
        _pendingResetMajorAudioVolume = null;
      }
    }
  }

  void cancelNoSoundCheckTimer() {
    _noSoundCheckTimer?.cancel();
    _noSoundCheckTimer = null;
    _recoverMajorAudioVolumeSubscription?.cancel();
    _recoverMajorAudioVolumeSubscription = null;
  }

  int? _pendingResetMajorAudioVolume;
  StreamSubscription? _recoverMajorAudioVolumeSubscription;

  /// 2S内逐渐恢复原声频道音量，每隔 100 ms 恢复 5%
  void recoverMajorAudioVolumeGradually(String channel) {
    commonLogger.i('start recover major audio volume gradually: $channel');
    final cur = _majorAudioVolume;
    _pendingResetMajorAudioVolume = cur;
    final step = (maxVolume - cur) / majorChannelVolumeRecoverStep;
    _recoverMajorAudioVolumeSubscription = Stream.periodic(
      const Duration(
          milliseconds: majorChannelVolumeRecoverDuration ~/
              majorChannelVolumeRecoverStep),
      (count) => step * (count + 1) + cur,
    ).take(majorChannelVolumeRecoverStep).listen((volume) {
      if (isListeningAndMajorAudioInBackground(channel)) {
        adjustChannelPlaybackVolume(
            roomContext.roomUuid, min(volume.toInt(), maxVolume));
      }
    });
  }

  bool isListeningAndMajorAudioInBackground(String channel) {
    return interpStarted &&
        channel == langRtcChannels[_listenLanguage] &&
        !_majorAudioMuted &&
        _majorAudioInBackground;
  }
}

extension IsForbiddenExtension on VoidResult {
  bool isForbidden() {
    return code == NEInterpretationController.codeForbidden;
  }

  bool isCancelled() {
    return code == NEMeetingErrorCode.cancelled;
  }
}
