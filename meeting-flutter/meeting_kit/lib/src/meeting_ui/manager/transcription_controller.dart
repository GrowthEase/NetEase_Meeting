// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 字幕、转写控制器
abstract class NEMeetingLiveTranscriptionController {
  /// 无操作权限
  static const codeNoPermission = 1041;

  factory NEMeetingLiveTranscriptionController(NERoomContext roomContext) {
    return _MeetingLiveTranscriptionController._(roomContext);
  }

  NEMeetingLiveTranscriptionController._();

  /// 开启/关闭字幕
  Future<VoidResult> enableCaption(bool enable);

  /// 获取字幕是否开启
  bool isCaptionsEnabled();

  /// 允许/不允许成员使用字幕，仅管理员可操作
  Future<VoidResult> allowParticipantsEnableCaption(bool allow);

  /// 获取是否允许成员使用字幕
  bool isAllowParticipantsEnableCaption();

  /// 本端是否可以开启字幕
  /// 仅当本端为管理员或管理员允许成员使用字幕时，可以开启字幕
  bool canMySelfEnableCaption();

  /// 设置目标翻译语言
  Future<VoidResult> setTranslationLanguage(
      NEMeetingASRTranslationLanguage language);

  /// 返回当前设置的翻译语言
  NEMeetingASRTranslationLanguage getTranslationLanguage();

  /// 开启/关闭转写双语显示
  void enableTranscriptionBilingual(bool enable);

  /// 获取转写双语显示状态
  bool isTranscriptionBilingualEnabled();

  /// 开启/关闭字幕双语显示
  void enableCaptionBilingual(bool enable);

  /// 获取字幕双语显示状态
  bool isCaptionBilingualEnabled();

  /// 添加监听器
  void addListener(NEMeetingLiveTranscriptionControllerListener listener);

  /// 移除监听器
  void removeListener(NEMeetingLiveTranscriptionControllerListener listener);

  /// 查询字幕消息发送者的用户信息
  CaptionMessageUserInfo? getUserInfo(String userUuid);

  /// 转写是否开启，仅管理员有权限开启转写
  bool isTranscriptionEnabled();

  /// 本端是否可以开启/关闭转写，仅管理员有权限
  bool canMySelfEnableTranscription();

  /// 是否有转写历史消息
  bool hasTranscriptionHistoryMessages();

  /// 开启/关闭转写
  Future<VoidResult> enableTranscription(bool enable);

  /// 获取转写消息历史
  List<NERoomCaptionMessage> getTranscriptionMessageList();

  /// 获取是否隐藏头像
  bool get isAvatarHidden;

  /// 销毁控制器
  void dispose();
}

/// 事件监听器
mixin class NEMeetingLiveTranscriptionControllerListener {
  ///
  /// 接收到字幕消息
  /// - [channel] 频道，如果为空，则为主频道
  /// - [captionMessages] 字幕消息列表
  ///
  void onReceiveCaptionMessages(
      String? channel, List<NERoomCaptionMessage> captionMessages) {}

  ///
  /// 头像显示隐藏变化
  /// - [hide] 是否隐藏
  ///
  void onAvatarHiddenChanged(bool hide) {}

  ///
  /// 允许成员使用字幕开关变更通知
  /// - [allow] 是否允许
  ///
  void onAllowParticipantsEnableCaptionChanged(bool allow) {}

  ///
  /// 本地成员字幕被禁用，因为管理员禁止成员使用字幕
  ///
  void onMySelfCaptionForbidden() {}

  ///
  /// 本地成员字幕状态变更，比如手动开启/关闭字幕
  ///
  void onMySelfCaptionEnableChanged(bool enable) {}

  ///
  /// 转写状态变更
  ///
  void onTranscriptionEnableChanged(bool enable) {}

  ///
  /// 转写变更
  ///
  void onTranscriptionMessageUpdated() {}

  ///
  /// 翻译设置变更
  ///
  void onTranslationSettingsChanged() {}
}

class _MeetingLiveTranscriptionController
    extends NEMeetingLiveTranscriptionController with _AloggerMixin {
  /// 成员使用字幕权限key
  static const captionPermissionKey = 'capPerm';
  static const captionPermissionOffValue = '0';
  static const captionPermissionOnValue = '1';

  /// 转写状态的房间属性
  static const transcriptionKey = 'transcript';
  static const transcriptionOnValue = '1';

  final NERoomContext roomContext;

  /// 字幕开关
  bool captionsEnabled = false;
  final listeners =
      ObserverList<NEMeetingLiveTranscriptionControllerListener>();

  /// rtc 字幕开关
  var captionsEngineRunning = false;

  /// 转写消息历史，每个元素为一段时间内的转写消息
  final List<List<NERoomCaptionMessage>> transcriptionMessages = [];

  /// 当前阶段内的 Final 消息
  List<NERoomCaptionMessage> currentFinalTranscriptionMessages = [];

  /// 当前阶段内的非 Final 消息
  Map<String, NERoomCaptionMessage> currentNonFinalTranscriptionMessages = {};

  _MeetingLiveTranscriptionController._(this.roomContext) : super._() {
    roomContext.addEventCallback(eventCallback);
    SettingsRepository().addSettingsChangedListener(updateTranslationSettings);
    handleTranscriptionEnableChanged();
  }

  @override
  void dispose() {
    roomContext.removeEventCallback(eventCallback);
    SettingsRepository()
        .removeSettingsChangedListener(updateTranslationSettings);
    listeners.clear();
  }

  late final eventCallback = NERoomEventCallback(
      roomPropertiesChanged: mayHandleRoomPropertyChanged,
      roomPropertiesDeleted: mayHandleRoomPropertyChanged,
      onReceiveCaptionMessages: handleCaptionMessages,
      onCaptionStateChanged: handleCaptionStateChanged,
      memberLeaveRoom: handleMemberInOutRoom,
      memberJoinRoom: handleMemberInOutRoom,
      memberRoleChanged: (member, oldRole, newRole) {
        if (member.uuid == roomContext.myUuid) checkMySelfCaptionForbidden();
      },
      memberNameChanged: (member, name, _) {
        messageUserInfos[member.uuid]?.nickname = name;
      });

  void checkMySelfCaptionForbidden() {
    /// 管理员禁止成员使用字幕，且当前开启字幕，则关闭字幕，并对外通知
    if (captionsEnabled && !canMySelfEnableCaption()) {
      enableCaption(false);
      notifyListeners((listener) {
        listener.onMySelfCaptionForbidden();
      });
    }
  }

  void mayHandleRoomPropertyChanged(Map<String, String> properties) {
    if (properties[captionPermissionKey] != null) {
      final allow = isAllowParticipantsEnableCaption();
      commonLogger.i('onAllowParticipantsEnableCaptionChanged: $allow');
      checkMySelfCaptionForbidden();
      notifyListeners((listener) {
        listener.onAllowParticipantsEnableCaptionChanged(allow);
      });
    }
    if (properties.containsKey(MeetingSecurityCtrlKey.securityCtrlKey)) {
      notifyListeners((listener) {
        listener.onAvatarHiddenChanged(roomContext.isAvatarHidden);
      });
    }

    /// 转写开关状态变更
    if (properties[transcriptionKey] != null) {
      handleTranscriptionEnableChanged();
      if (!isTranscriptionEnabled()) {
        final segments = [
          ...currentFinalTranscriptionMessages,
          ...currentNonFinalTranscriptionMessages.values,
        ].sortedBy((e) => e.timestamp as num);
        transcriptionMessages.add(segments);
        currentFinalTranscriptionMessages.clear();
        currentNonFinalTranscriptionMessages.clear();

        transcriptionMessages.add([const TranscriptionEndMessage()]);
      }
      notifyListeners((listener) {
        listener.onTranscriptionMessageUpdated();
      });
    }
  }

  void handleCaptionStateChanged(int state, int code, String? msg) {
    commonLogger.i('onCaptionStateChanged: $state, $code, $msg');
    if (state == NERoomCaptionState.STATE_ENABLE_CAPTION_SUCCESS) {
      captionsEngineRunning = true;
      syncTranslationLanguage();
    } else if (state == NERoomCaptionState.STATE_DISABLE_CAPTION_SUCCESS) {
      captionsEngineRunning = false;
    }
  }

  bool maybeChangeCaptionsEnabled(bool enable) {
    if (enable != captionsEnabled) {
      captionsEnabled = enable;
      notifyListeners((listener) {
        listener.onMySelfCaptionEnableChanged(enable);
      });
      return true;
    }
    return false;
  }

  /// 消息用户信息
  final messageUserInfos = <String, CaptionMessageUserInfo>{};

  /// 处理字幕消息
  void handleCaptionMessages(
      String? channel, List<NERoomCaptionMessage> captionMessages) {
    debugPrint(
        'handleCaptionMessages: ${captionMessages.map((e) => '${e.fromUserUuid}-${e.content}-${e.translationContent}-${e.timestamp}').join('\n')}');
    final filterMessages = <NERoomCaptionMessage>[];
    final transcriptionEnabled = isTranscriptionEnabled();
    var transcriptionMessageUpdated = false;
    captionMessages.forEach((message) {
      final member = roomContext.getMember(message.fromUserUuid);
      if (member != null) {
        messageUserInfos[message.fromUserUuid] =
            CaptionMessageUserInfo.fromMember(member);
      }
      if (messageUserInfos.containsKey(message.fromUserUuid)) {
        filterMessages.add(message);
        if (transcriptionEnabled) {
          transcriptionMessageUpdated = true;
          handleNewTranscriptionMessage(message);
        }
      }
    });
    if (filterMessages.isNotEmpty) {
      notifyListeners((listener) {
        listener.onReceiveCaptionMessages(channel, filterMessages);
      });
    }
    if (transcriptionMessageUpdated) {
      notifyListeners((listener) {
        listener.onTranscriptionMessageUpdated();
      });
    }
  }

  @override
  Future<VoidResult> allowParticipantsEnableCaption(bool allow) async {
    commonLogger.i('allowParticipantsEnableCaption: $allow');
    final result = await roomContext.updateRoomProperty(
      captionPermissionKey,
      allow ? captionPermissionOnValue : captionPermissionOffValue,
    );
    commonLogger.i('allowParticipantsEnableCaption: $allow, $result');
    return result;
  }

  @override
  CaptionMessageUserInfo? getUserInfo(String userUuid) {
    final member = roomContext.getMember(userUuid);
    if (member != null) return CaptionMessageUserInfo.fromMember(member);
    return messageUserInfos[userUuid];
  }

  @override
  bool isAllowParticipantsEnableCaption() {
    final value = roomContext.roomProperties[captionPermissionKey];
    return value == null || value == captionPermissionOnValue;
  }

  @override
  bool canMySelfEnableCaption() {
    return roomContext.isMySelfHostOrCoHost() ||
        isAllowParticipantsEnableCaption();
  }

  @override
  Future<VoidResult> enableCaption(bool enable) async {
    commonLogger.i('enableCaption: $enable, $captionsEnabled');
    if (enable != captionsEnabled) {
      if (enable) {
        final hasPermission =
            await InMeetingRepository.hasEnableCaptionsPermission(
                roomContext.meetingNum);
        if (!hasPermission.isSuccess()) return hasPermission;
      }
      var result = Future.value(const NEResult.success());
      if (enable) {
        result = startRtcCaptionsEngine();
      } else if (!isTranscriptionEnabled()) {
        result = stopRtcCaptionsEngine();
      }
      return result.onSuccess(() => maybeChangeCaptionsEnabled(enable));
    }
    return const NEResult.success();
  }

  @override
  bool isCaptionsEnabled() {
    return captionsEnabled;
  }

  @override
  bool isTranscriptionEnabled() {
    return roomContext.roomProperties[transcriptionKey] == transcriptionOnValue;
  }

  @override
  bool canMySelfEnableTranscription() {
    return roomContext.isMySelfHostOrCoHost();
  }

  @override
  bool hasTranscriptionHistoryMessages() {
    return transcriptionMessages.isNotEmpty ||
        currentFinalTranscriptionMessages.isNotEmpty ||
        currentNonFinalTranscriptionMessages.isNotEmpty;
  }

  @override
  Future<VoidResult> enableTranscription(bool enable) async {
    final current = isTranscriptionEnabled();
    commonLogger.i('enableTranscription: $enable, $current');
    if (current == enable) return const NEResult.success();
    if (!canMySelfEnableTranscription()) {
      return const NEResult(
          code: NEMeetingLiveTranscriptionController.codeNoPermission);
    }
    return (enable
            ? roomContext.updateRoomProperty(
                transcriptionKey, transcriptionOnValue)
            : roomContext.deleteRoomProperty(transcriptionKey))
        .then((result) {
      commonLogger.i('enableTranscription result: $enable, $result');
      return result;
    });
  }

  @override
  List<NERoomCaptionMessage> getTranscriptionMessageList() {
    List<List<NERoomCaptionMessage>> history = [
      ...transcriptionMessages,
      if (isTranscriptionEnabled())
        [
          ...currentFinalTranscriptionMessages,
          ...currentNonFinalTranscriptionMessages.values,
        ].sortedBy((e) => e.timestamp as num),
    ];
    return history.flattened.toList(growable: false);
  }

  @override
  bool get isAvatarHidden => roomContext.isAvatarHidden;

  void handleTranscriptionEnableChanged() {
    final enabled = isTranscriptionEnabled();
    commonLogger.i('onTranscriptionEnableChanged: $enabled');
    if (enabled) {
      transcriptionMessages.add([const TranscriptionStartMessage()]);
      startRtcCaptionsEngine();
    } else if (!captionsEnabled) {
      stopRtcCaptionsEngine();
    }
    notifyListeners((listener) {
      listener.onTranscriptionEnableChanged(enabled);
    });
  }

  void handleNewTranscriptionMessage(NERoomCaptionMessage message) {
    /// 保留第一个消息的时间戳，后续的消息内容更新
    var nonFinal = currentNonFinalTranscriptionMessages[message.fromUserUuid];
    if (nonFinal != null) {
      message = message.copyWith(timestamp: nonFinal.timestamp);
    }
    if (message.isFinal) {
      currentNonFinalTranscriptionMessages.remove(message.fromUserUuid);
      currentFinalTranscriptionMessages.add(message);
    } else {
      currentNonFinalTranscriptionMessages[message.fromUserUuid] = message;
    }
  }

  /// 成员离开/加入房间，将非 final 消息转为 final 消息
  void handleMemberInOutRoom(List<NERoomMember> members) {
    var dirty = false;
    members.forEach((member) {
      final message = currentNonFinalTranscriptionMessages.remove(member.uuid);
      if (message != null) {
        dirty = true;
        currentFinalTranscriptionMessages.add(message);
      }
    });
    if (dirty) {
      currentFinalTranscriptionMessages.sort((a, b) {
        return (a.timestamp as num).compareTo(b.timestamp as num);
      });
    }
  }

  Future<VoidResult> startRtcCaptionsEngine() async {
    commonLogger.i('startCaptionsEngine: cur=$captionsEngineRunning');
    if (captionsEngineRunning) return const NEResult.success();
    return roomContext.rtcController.enableCaption(true);
  }

  Future<VoidResult> stopRtcCaptionsEngine() async {
    commonLogger.i('stopCaptionsEngine: cur=$captionsEngineRunning');
    if (!captionsEngineRunning) return const NEResult.success();
    return roomContext.rtcController.enableCaption(false);
  }

  var translationLanguage = SettingsRepository().getASRTranslationLanguage();

  /// 重置翻译语言
  void syncTranslationLanguage() {
    roomContext.rtcController
        .setCaptionTranslationLanguage(translationLanguage.mapToRoomLanguage());
  }

  @override
  Future<VoidResult> setTranslationLanguage(
      NEMeetingASRTranslationLanguage language) async {
    if (language != translationLanguage) {
      SettingsRepository().setASRTranslationLanguage(language);
    }
    return const NEResult.success();
  }

  @override
  NEMeetingASRTranslationLanguage getTranslationLanguage() {
    return translationLanguage;
  }

  bool transcriptionBilingualEnabled =
      SettingsRepository().isTranscriptionBilingualEnabled();
  @override
  void enableTranscriptionBilingual(bool enable) {
    SettingsRepository().enableTranscriptionBilingual(enable);
  }

  @override
  bool isTranscriptionBilingualEnabled() {
    return transcriptionBilingualEnabled;
  }

  bool captionBilingualEnabled =
      SettingsRepository().isCaptionBilingualEnabled();
  @override
  void enableCaptionBilingual(bool enable) {
    SettingsRepository().enableCaptionBilingual(enable);
  }

  @override
  bool isCaptionBilingualEnabled() {
    return captionBilingualEnabled;
  }

  void updateTranslationSettings() {
    final transcriptionBilingual =
        SettingsRepository().isTranscriptionBilingualEnabled();
    final captionBilingual = SettingsRepository().isCaptionBilingualEnabled();
    final translationLanguage =
        SettingsRepository().getASRTranslationLanguage();
    var changed = false;
    if (this.translationLanguage != translationLanguage) {
      changed = true;
      this.translationLanguage = translationLanguage;
      syncTranslationLanguage();
    }
    if (this.transcriptionBilingualEnabled != transcriptionBilingual) {
      this.transcriptionBilingualEnabled = transcriptionBilingual;
      changed = true;
    }
    if (this.captionBilingualEnabled != captionBilingual) {
      this.captionBilingualEnabled = captionBilingual;
      changed = true;
    }

    commonLogger.i('onTranslationSettingsChanged');
    if (changed)
      notifyListeners((listener) => listener.onTranslationSettingsChanged());
  }

  @override
  void addListener(NEMeetingLiveTranscriptionControllerListener listener) {
    listeners.add(listener);
  }

  @override
  void removeListener(NEMeetingLiveTranscriptionControllerListener listener) {
    listeners.remove(listener);
  }

  void notifyListeners(
      void Function(NEMeetingLiveTranscriptionControllerListener listener)
          notify) {
    final copy = listeners.toList();
    for (var listener in copy) {
      if (listeners.contains(listener)) {
        notify(listener);
      }
    }
  }
}

/// 消息用户信息
class CaptionMessageUserInfo {
  final String userId;
  String nickname;
  String? avatar;

  CaptionMessageUserInfo.fromMember(NERoomMember member)
      : this(member.uuid, member.name, member.avatar);

  CaptionMessageUserInfo(this.userId, this.nickname, this.avatar);
}

/// 转写开始消息
final class TranscriptionStartMessage extends NERoomCaptionMessage {
  const TranscriptionStartMessage()
      : super(
          fromUserUuid: '',
          content: '',
          timestamp: 0,
          isFinal: false,
        );
}

/// 转写结束消息
final class TranscriptionEndMessage extends NERoomCaptionMessage {
  const TranscriptionEndMessage()
      : super(
          fromUserUuid: '',
          content: '',
          timestamp: 0,
          isFinal: true,
        );
}
