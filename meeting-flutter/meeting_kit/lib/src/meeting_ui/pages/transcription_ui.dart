// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

mixin NEMeetingLiveTranscriptionControllerMixin<T extends StatefulWidget>
    on
        MeetingKitLocalizationsMixin<T>,
        MeetingStateScope<T>,
        NEMeetingLiveTranscriptionControllerListener {
  /// 控制器
  NEMeetingLiveTranscriptionController? _transcriptionController;
  NEMeetingLiveTranscriptionController get transcriptionController {
    if (_transcriptionController == null) {
      _transcriptionController = meetingUIState.transcriptionController;
      _transcriptionController!.addListener(this);
    }
    return _transcriptionController!;
  }

  ValueNotifier<bool>? _captionsEnabledNotifier;
  ValueListenable<bool> get captionsEnabledListenable {
    _captionsEnabledNotifier ??=
        ValueNotifier(transcriptionController.isCaptionsEnabled());
    return _captionsEnabledNotifier!;
  }

  void enableCaption(bool enable) {
    if (enable) {
      doIfNetworkAvailable(() {
        _isLocalAction = true;
        transcriptionController.enableCaption(true).onFailure((code, msg) {
          if (mounted) {
            if (code == NEMeetingLiveTranscriptionController.codeNoPermission) {
              msg = meetingUiLocalizations.transcriptionCanNotEnableCaption;
            }
            showToast(msg ?? meetingUiLocalizations.transcriptionStartFailed);
          }
        });
      });
    } else {
      _isLocalAction = true;
      transcriptionController.enableCaption(false);
    }
  }

  @override
  void onMySelfCaptionForbidden() {
    showToast(meetingUiLocalizations.transcriptionCaptionForbidden);
  }

  @override
  void onMySelfCaptionEnableChanged(bool enable) {
    _captionsEnabledNotifier?.value = enable;

    /// 仅本地操作才提示
    if (_isLocalAction) {
      showToast(enable
          ? meetingUiLocalizations.transcriptionEnableCaptionHint
          : meetingUiLocalizations.transcriptionDisableCaptionHint);
    }
    _isLocalAction = false;
  }

  /// 处理“转写”菜单点击
  void handleTranscriptionMenuClicked() async {
    final enabled = transcriptionController.isTranscriptionEnabled();
    if (enabled || transcriptionController.hasTranscriptionHistoryMessages()) {
      MeetingTranscriptionPage.show(context, enableTranscription);
      return;
    }
    if (transcriptionController.canMySelfEnableTranscription()) {
      final result = await showConfirmDialog2(
        routeSettings: RouteSettings(name: 'MeetingTranscriptionStartConfirm'),
        title: (_) => meetingUiLocalizations.transcriptionStartConfirmMsg,
        cancelLabel: (_) => meetingUiLocalizations.globalCancel,
        okLabel: (_) => meetingUiLocalizations.globalStart,
        contentWrapperBuilder: (child) {
          return AutoPopIfNotManager(
            roomContext: meetingUIState.roomContext,
            child: child,
          );
        },
      );
      if (mounted && result == true) {
        enableTranscription(true).then((value) {
          if (mounted && value != null) {
            MeetingTranscriptionPage.show(context, enableTranscription);
          }
        });
      }
    } else {
      showToast(meetingUiLocalizations.transcriptionNotStarted);
    }
  }

  ValueNotifier<bool>? _transcriptionEnabledNotifier;
  ValueListenable<bool> get transcriptionEnabledListenable {
    _transcriptionEnabledNotifier ??=
        ValueNotifier(transcriptionController.isTranscriptionEnabled());
    return _transcriptionEnabledNotifier!;
  }

  /// 是否为本地操作
  var _isLocalAction = false;
  Future<VoidResult?> enableTranscription(bool enable) {
    return doIfNetworkAvailable(() {
      _isLocalAction = true;
      return transcriptionController
          .enableTranscription(enable)
          .onFailure((code, msg) {
        if (mounted) {
          showToast(msg ?? meetingUiLocalizations.globalOperationFail);
        }
      });
    });
  }

  @override
  void onTranscriptionEnableChanged(bool enable) {
    _transcriptionEnabledNotifier?.value = enable;

    /// 非本端操作才提示
    if (!_isLocalAction) {
      showToast(enable
          ? meetingUiLocalizations.transcriptionStartedNotificationMsg
          : meetingUiLocalizations.transcriptionStoppedTip);
    }
    _isLocalAction = false;
  }
}

/// 字幕条
class MeetingCaptionsBar extends StatefulWidget {
  final NEMeetingLiveTranscriptionController controller;
  final EdgeInsetsGeometry? padding;

  const MeetingCaptionsBar({
    super.key,
    required this.controller,
    this.padding,
  });

  @override
  State<MeetingCaptionsBar> createState() => _MeetingCaptionsBarState();
}

class _MeetingCaptionsBarState extends State<MeetingCaptionsBar>
    with
        MeetingStateScope,
        SingleTickerProviderStateMixin,
        MeetingKitLocalizationsMixin,
        NEMeetingLiveTranscriptionControllerListener {
  static const maxActiveSpeaker = 3;
  static const captionsMessageTimeoutInSeconds = 5;
  static const maxLinesOfAll = 4;
  static const maxLinesOfEach = 2;
  static const nicknameWidth = 28.0;
  static const lineHeight = 22.0;
  static const captionTextFontSize = 14.0;
  // static const contentWidth = 265.0;

  late final controller = widget.controller;
  var enabled = false;
  var loading = false;
  String? notificationMessage;
  bool showNotification = false;
  AnimationController? animationController;
  static final loadingHintOffsetTween =
      Tween<Offset>(begin: Offset.zero, end: Offset(0.0, -1.0));
  static final settingsHintOffsetTween =
      Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset.zero);

  bool get hasContent =>
      enabled && (loading || activeSpeakers.isNotEmpty || showNotification);

  @override
  void initState() {
    super.initState();
    controller.addListener(this);
    enabled = controller.isCaptionsEnabled();
    updateCaptionSettings();
  }

  @override
  void dispose() {
    animationController?.dispose();
    textPainter?.dispose();
    hideCaptionsTimer?.cancel();
    controller.removeListener(this);
    super.dispose();
  }

  @override
  void onMySelfCaptionEnableChanged(bool enable) {
    setState(() {
      enabled = enable;
      notificationMessage = null;
      hideCaptionsTimer?.cancel();
      resetCaptionsMessage();
      if (enable) {
        startLoading();
      }
    });
  }

  @override
  void onTranslationSettingsChanged() {
    updateCaptionSettings();
  }

  /// 显示源语言
  bool showOriginalText = true;

  /// 显示翻译语言
  bool showTranslatedText = false;

  /// 是否仅展示一种语言，原始语言或翻译语言
  bool showSingleLanguage = true;
  void updateCaptionSettings() {
    final transLang = controller.getTranslationLanguage();
    final bilingual = controller.isCaptionBilingualEnabled();

    /// 不翻译/显示双语，则展示原语言
    final shouldShowOriginalText =
        transLang == NEMeetingASRTranslationLanguage.none || bilingual;
    final shouldShowTranslatedText =
        transLang != NEMeetingASRTranslationLanguage.none;
    if (shouldShowOriginalText != showOriginalText ||
        shouldShowTranslatedText != showTranslatedText) {
      setState(() {
        showOriginalText = shouldShowOriginalText;
        showTranslatedText = shouldShowTranslatedText;
        showSingleLanguage = (showOriginalText != showTranslatedText) &&
            (showOriginalText || showTranslatedText);
      });
    }
  }

  final userMessageInfos = <String, _UserCaptionsMessageInfo>{};
  final activeSpeakers = <String>[];

  void resetCaptionsMessage() {
    activeSpeakers.clear();
    userMessageInfos.clear();
    showNotification = false;
  }

  late NEInterpretationController interpretationController =
      meetingUIState.interpretationController;

  @override
  void onReceiveCaptionMessages(
      String? channel, List<NERoomCaptionMessage> captionMessages) {
    if (!enabled) return;

    /// 同传没有收听原声，不展示字幕
    if (meetingUIState.interpretationController.listenLanguage != null &&
        !meetingUIState.interpretationController
            .isMajorAudioInBackgroundEnabled()) {
      if (notificationMessage == null) {
        notificationMessage =
            meetingUiLocalizations.transcriptionCaptionNotAvailableInSubChannel;
        showNotification = true;
        setState(() {});
      }
      return;
    }
    notificationMessage = null;
    showNotification = false;
    for (final msg in captionMessages) {
      final user = msg.fromUserUuid;
      userMessageInfos
          .putIfAbsent(user, () => _UserCaptionsMessageInfo())
          .addMessage(msg);
    }
    final orderedMessages = userMessageInfos.values
        .map((e) => e.latestMessage)
        .toList()
      ..sortBy((e) => e.timestamp as num);
    final latestTimestamp = orderedMessages.last.timestamp;
    final newActiveSpeakers = orderedMessages.reversed
        .where((e) =>
            latestTimestamp - e.timestamp <
            captionsMessageTimeoutInSeconds * 1000)
        .map((e) => e.fromUserUuid)
        .take(maxActiveSpeaker)
        .toList();
    debugPrint('activeSpeaker changed: $activeSpeakers -> $newActiveSpeakers');
    activeSpeakers
        .where((user) => !newActiveSpeakers.contains(user))
        .forEach((user) {
      /// 重置不再是演讲者的成员消息
      userMessageInfos[user]?.resetShowingMessageText();
    });
    activeSpeakers.clear();
    activeSpeakers.addAll(newActiveSpeakers);
    setState(() {});
    scheduleHideCaptionsTimer();
  }

  ValueNotifier<bool> hideAvatar = ValueNotifier(false);
  @override
  void onAvatarHiddenChanged(bool hide) {
    hideAvatar.value = hide;
  }

  Timer? hideCaptionsTimer;
  void scheduleHideCaptionsTimer() {
    hideCaptionsTimer?.cancel();
    hideCaptionsTimer =
        Timer(const Duration(seconds: captionsMessageTimeoutInSeconds), () {
      if (mounted) {
        setState(() {
          resetCaptionsMessage();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!hasContent) {
      return const SizedBox.shrink();
    }
    Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicWidth(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            height: 22,
            decoration: ShapeDecoration(
              shape: StadiumBorder(),
              color: _UIColors.black80,
            ),
            alignment: Alignment.center,
            child: Text(
              meetingUiLocalizations.transcriptionDisclaimer,
              style: TextStyle(
                fontSize: 10,
                color: _UIColors.color_99FFFFFF,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
        SizedBox(height: 6.h),
        SizedBox(
          width: 351.w,
          child: Container(
            decoration: ShapeDecoration(
              color: _UIColors.black80,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: loading
                ? buildLoading()
                : (notificationMessage != null && showNotification
                    ? buildNotification()
                    : buildCaptions()),
          ),
        )
      ],
    );
    if (widget.padding != null) {
      body = Padding(
        padding: widget.padding!,
        child: body,
      );
    }
    return GestureDetector(
      child: body,
      onTap: () => MeetingCaptionsSettingsPage.show(context),
    );
  }

  void startLoading() async {
    if (animationController == null) {
      final controller = AnimationController(
          duration: const Duration(milliseconds: 300), vsync: this);
      controller.addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          if (!mounted) return;
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) return;
          setState(() {
            loading = false;
          });
        }
      });
      animationController = controller;
    }
    loading = true;
    animationController!.value = 0;
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted || !loading) return;
    animationController!.forward();
  }

  Widget buildLoading() {
    return SizedBox(
      height: 38,
      child: Stack(
        fit: StackFit.expand,
        children: [
          SlideTransition(
            position: loadingHintOffsetTween.animate(animationController!),
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 8),
                  SizedBox.square(
                    dimension: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                      valueColor: AlwaysStoppedAnimation(_UIColors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      meetingUiLocalizations.transcriptionCaptionLoading,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 14,
                        color: _UIColors.white,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
          SlideTransition(
            position: settingsHintOffsetTween.animate(animationController!),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  meetingUiLocalizations.transcriptionCaptionSettingsHint,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 14,
                    color: _UIColors.white,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNotification() {
    scheduleHideCaptionsTimer();
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        notificationMessage!,
        style: TextStyle(
          fontSize: 14,
          color: _UIColors.white,
          decoration: TextDecoration.none,
          fontWeight: FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildCaptions() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (userMessageInfos.isEmpty) return SizedBox.shrink();
          List<Widget> widgets;
          if (showSingleLanguage) {
            widgets = buildSingleLanguageCaption(constraints);
          } else {
            widgets = buildTwoLanguageCaption(constraints);
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          );
        },
      ),
    );
  }

  /// 单语字幕: 原语言或翻译语言
  List<Widget> buildSingleLanguageCaption(BoxConstraints constraints) {
    assert(showSingleLanguage);

    /// 如果只有一个人的字幕，最多展示 4 行；多人情况下，最多每人展示 2 行字幕
    final activeSpeakerLen = activeSpeakers.length;
    var remainLines = maxLinesOfAll;
    final widgets = <Widget>[];
    var index = 0;
    final isTranslated = showTranslatedText;
    for (var user in activeSpeakers) {
      assert(userMessageInfos.containsKey(user));
      final messageInfo = userMessageInfos[user]!;

      /// 强制把第二个人的行数留给第三个人至少一行
      int reservation = 0;
      if (activeSpeakerLen == 3 && index == 1 && remainLines <= 2) {
        reservation = 1;
      }
      final measureInfo = measureText(
          messageInfo.getNextMessageText(isTranslated),
          min(maxLinesOfEach - reservation, remainLines),
          constraints);
      if (messageInfo.latestMessage.isFinal) {
        messageInfo.setShowingMessageText(measureInfo.text, isTranslated);
      }
      widgets.add(buildCaptionMessageRow(
        controller.getUserInfo(user)!,
        measureInfo.lines,
        measureInfo.text,
        contentTextStyle:
            isTranslated ? translationTextStyle : captionTextStyle,
      ));
      remainLines -= measureInfo.lines;
      if (remainLines <= 0) {
        break;
      }
      ++index;
    }
    return widgets.reversed.toList();
  }

  /// 双语字幕
  List<Widget> buildTwoLanguageCaption(BoxConstraints constraints) {
    assert(showOriginalText && showOriginalText);

    /// 每种语言的最大行数
    var maxLineOfLang = activeSpeakers.length >= 2 ? 1 : 2;

    var remainLines = maxLinesOfAll;
    final widgets = <Widget>[];
    outer:
    for (var user in activeSpeakers) {
      assert(userMessageInfos.containsKey(user));
      final messageInfo = userMessageInfos[user]!;

      for (var isTranslated in const [true, false]) {
        final text = messageInfo.getNextMessageText(isTranslated);
        if (text.isEmpty) continue;
        final measureInfo = measureText(
            messageInfo.getNextMessageText(isTranslated),
            min(maxLineOfLang, remainLines),
            constraints);
        if (messageInfo.latestMessage.isFinal) {
          messageInfo.setShowingMessageText(measureInfo.text, isTranslated);
        }
        widgets.add(buildCaptionMessageRow(
          controller.getUserInfo(user)!,
          measureInfo.lines,
          measureInfo.text,
          contentTextStyle:
              isTranslated ? translationTextStyle : captionTextStyle,
        ));
        remainLines -= measureInfo.lines;
        if (remainLines <= 0) {
          break outer;
        }
      }
    }
    return widgets.reversed.toList();
  }

  Widget buildCaptionMessageRow(
    CaptionMessageUserInfo userInfo,
    int maxLines,
    String text, {
    TextStyle contentTextStyle = captionTextStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          width: nicknameWidth,
          height: lineHeight,
          padding: EdgeInsets.all(2.0),
          child: ValueListenableBuilder(
            valueListenable: hideAvatar,
            builder: (context, hideAvatar, child) {
              return NEMeetingAvatar(
                size: 18,
                textStyle: AvatarTextStyle(
                  fontSizeOneChinese: 10,
                  fontSizeTwoChinese: 8,
                  fontSizeLetter: 10,
                ),
                name: userInfo.nickname,
                url: userInfo.avatar,
                hideImageAvatar: hideAvatar,
              );
            },
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: contentTextStyle.copyWith(inherit: false),
              maxLines: maxLines,
              strutStyle: StrutStyle(
                forceStrutHeight: true,
                height: 18 / 14,
              ),
              // textAlign: TextAlign.center,
              // overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  /// 原始内容样式
  static const captionTextStyle = TextStyle(
    fontSize: captionTextFontSize,
    color: _UIColors.white,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.w500,
  );

  /// 翻译内容样式
  static const translationTextStyle = TextStyle(
    fontSize: captionTextFontSize,
    color: _UIColors.colorF7C266,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.w500,
  );

  TextPainter? textPainter;
  _MeasureInfo measureText(
      String text, int requestMaxLines, BoxConstraints constraints) {
    if (text.isEmpty) return _MeasureInfo(1, '');
    Stopwatch? stopwatch;
    assert(() {
      stopwatch = Stopwatch()..start();
      return true;
    }());
    final width = constraints.maxWidth - nicknameWidth;
    textPainter ??= TextPainter(
      textDirection: TextDirection.ltr,
    );
    final painter = textPainter!;
    painter.maxLines = 10;
    painter.text = TextSpan(
      text: text,
      style: captionTextStyle,
    );
    painter.layout(maxWidth: width);
    final lineMetrics = painter.computeLineMetrics();
    final actualLines = lineMetrics.length;

    /// 没有超过最大行数
    if (actualLines <= requestMaxLines) {
      assert(() {
        print(
            'measureText consume1: ${text} ${requestMaxLines} ${actualLines} ${stopwatch!.elapsedMilliseconds}');
        return true;
      }());
      return _MeasureInfo(lineMetrics.length, text);
    } else {
      /// 超过最大行数
      int startIndex = 0;
      for (int i = 0; i < actualLines - requestMaxLines; ++i) {
        final textRange =
            painter.getLineBoundary(TextPosition(offset: startIndex));
        startIndex = textRange.end;
      }
      debugPrint('measureText startIndex: $text $startIndex');
      assert(() {
        print(
            'measureText consume2: ${requestMaxLines} ${actualLines}  ${stopwatch!.elapsedMilliseconds}');
        return true;
      }());
      return _MeasureInfo(requestMaxLines, text.substring(startIndex));
    }
  }
}

class _UserCaptionsMessageInfo {
  /// 即将要展示的字幕文本
  /// 包含所有的 final 消息
  String _text = '';

  /// 翻译的文本
  String _translationText = '';

  /// 最近一条收到的消息，用于排序
  /// 如果该消息为非 final 消息，则展示字幕时 需要拼接 text + latestMessage.content
  NERoomCaptionMessage? _latestMessage;
  NERoomCaptionMessage get latestMessage => _latestMessage!;

  _UserCaptionsMessageInfo();

  void addMessage(NERoomCaptionMessage message) {
    final last = _latestMessage;
    if (last != null && !last.isFinal) {
      /// 非 final 消息保持时间戳不变
      message = message.copyWith(
        timestamp: last.timestamp,
      );
    }

    _latestMessage = message;
    if (message.isFinal) {
      _text += message.content;
      _translationText += (message.translationContent ?? '');
    }
  }

  String getNextMessageText([bool isTranslated = false]) {
    final isFinal = latestMessage.isFinal == true;
    if (isTranslated) {
      return isFinal
          ? _translationText
          : _translationText + latestMessage.nonNullTranslationContent;
    } else {
      return isFinal ? _text : _text + latestMessage.content;
    }
  }

  void setShowingMessageText(String text, [bool isTranslated = false]) {
    if (isTranslated) {
      _translationText = text;
    } else {
      _text = text;
    }
  }

  void resetShowingMessageText() {
    var isFinal = latestMessage.isFinal == true;
    _text = isFinal ? latestMessage.content : '';
    _translationText = isFinal ? latestMessage.nonNullTranslationContent : '';
  }
}

extension _NonNullTranslationContent on NERoomCaptionMessage {
  String get nonNullTranslationContent {
    return this.translationContent ?? '';
  }
}

/// 测量信息
class _MeasureInfo {
  final int lines;
  final String text;

  _MeasureInfo(
    this.lines,
    this.text,
  );
}

/// 字幕设置页面
class MeetingCaptionsSettingsPage extends StatefulWidget {
  static Future show(BuildContext context) {
    return showMeetingPopupPageRoute(
      context: context,
      builder: (context) => MeetingCaptionsSettingsPage(),
    );
  }

  const MeetingCaptionsSettingsPage({super.key});

  @override
  State<MeetingCaptionsSettingsPage> createState() =>
      _MeetingCaptionsSettingsPageState();
}

class _MeetingCaptionsSettingsPageState
    extends State<MeetingCaptionsSettingsPage>
    with
        MeetingKitLocalizationsMixin,
        MeetingStateScope,
        NEMeetingLiveTranscriptionControllerListener,
        FirstBuildScope {
  late NEMeetingLiveTranscriptionController controller;
  final allowEnableCaptionsNotifier = ValueNotifier(false);

  @override
  void onAllowParticipantsEnableCaptionChanged(bool allow) {
    allowEnableCaptionsNotifier.value =
        controller.isAllowParticipantsEnableCaption();
  }

  @override
  void onTranslationSettingsChanged() {
    setState(() {});
  }

  @override
  void onFirstBuild() {
    controller = meetingUIState.transcriptionController;
    controller.addListener(this);
    allowEnableCaptionsNotifier.value =
        controller.isAllowParticipantsEnableCaption();
  }

  @override
  void dispose() {
    controller.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _UIColors.globalBg,
      appBar: TitleBar(
        title: TitleBarTitle(
          meetingUiLocalizations.transcriptionCaptionSettings,
        ),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return ListView(
      children: [
        MeetingCard(
          title: meetingUiLocalizations.transcriptionTranslationSettings,
          iconData: NEMeetingIconFont.icon_settings,
          iconColor: _UIColors.color8D90A0,
          children: [
            MeetingArrowItem(
              title: meetingUiLocalizations.transcriptionTargetLang,
              content: switch (controller.getTranslationLanguage()) {
                NEMeetingASRTranslationLanguage.chinese =>
                  meetingUiLocalizations.langChinese,
                NEMeetingASRTranslationLanguage.english =>
                  meetingUiLocalizations.langEnglish,
                NEMeetingASRTranslationLanguage.japanese =>
                  meetingUiLocalizations.langJapanese,
                _ => meetingUiLocalizations.transcriptionNotTranslated,
              },
              onTap: showTranslationLanguagePopup,
            ),
            MeetingSwitchItem(
              title: meetingUiLocalizations.transcriptionShowBilingual,
              valueNotifier:
                  ValueNotifier(controller.isCaptionBilingualEnabled()),
              onChanged: enableCaptionBilingualDisplay,
            ),
          ],
        ),
        MemberRoleChangedBuilder.ifManager(
            roomContext: meetingUIState.roomContext,
            builder: (context, _) {
              return MeetingCard(
                title: meetingUiLocalizations.meetingAllowMembersTo,
                iconData: NEMeetingIconFont.icon_members,
                iconColor: _UIColors.color_337eff,
                children: [
                  MeetingSwitchItem(
                    switchKey:
                        MeetingUIValueKeys.allowParticipantsEnableCaptions,
                    title:
                        meetingUiLocalizations.transcriptionAllowEnableCaption,
                    valueNotifier: allowEnableCaptionsNotifier,
                    onChanged: allowParticipantsEnableCaption,
                  ),
                ],
              );
            }),
      ],
    );
  }

  void allowParticipantsEnableCaption(bool allow) {
    doIfNetworkAvailable(() {
      controller.allowParticipantsEnableCaption(allow).onFailure((code, msg) {
        if (mounted) {
          showToast(msg ?? meetingUiLocalizations.globalOperationFail);
        }
      });
    });
  }

  void showTranslationLanguagePopup() async {
    final language = await SelectCaptionTranslationLanguagePopup.show(
        context, controller.getTranslationLanguage());
    if (!mounted || language == null) return;
    controller.setTranslationLanguage(language);
  }

  void enableCaptionBilingualDisplay(bool enable) {
    controller.enableCaptionBilingual(enable);
  }
}

/// 转写设置
class MeetingTranscriptionSettingsPage extends StatefulWidget {
  static Future show(BuildContext context) {
    return showMeetingPopupPageRoute(
      context: context,
      builder: (context) => MeetingTranscriptionSettingsPage(),
    );
  }

  const MeetingTranscriptionSettingsPage({super.key});

  @override
  State<MeetingTranscriptionSettingsPage> createState() =>
      _MeetingTranscriptionSettingsPageState();
}

class _MeetingTranscriptionSettingsPageState
    extends State<MeetingTranscriptionSettingsPage>
    with
        MeetingKitLocalizationsMixin,
        MeetingStateScope,
        NEMeetingLiveTranscriptionControllerListener,
        FirstBuildScope {
  late NEMeetingLiveTranscriptionController controller;

  @override
  void onFirstBuild() {
    controller = meetingUIState.transcriptionController;
    controller.addListener(this);
  }

  @override
  void dispose() {
    controller.removeListener(this);
    super.dispose();
  }

  @override
  void onTranslationSettingsChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _UIColors.globalBg,
      appBar: TitleBar(
        title: TitleBarTitle(
          meetingUiLocalizations.transcriptionSettings,
        ),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return ListView(
      children: [
        MeetingCard(
          title: meetingUiLocalizations.transcriptionTranslationSettings,
          iconData: NEMeetingIconFont.icon_settings,
          iconColor: _UIColors.color8D90A0,
          children: [
            MeetingArrowItem(
              title: meetingUiLocalizations.transcriptionTargetLang,
              content: switch (controller.getTranslationLanguage()) {
                NEMeetingASRTranslationLanguage.chinese =>
                  meetingUiLocalizations.langChinese,
                NEMeetingASRTranslationLanguage.english =>
                  meetingUiLocalizations.langEnglish,
                NEMeetingASRTranslationLanguage.japanese =>
                  meetingUiLocalizations.langJapanese,
                _ => meetingUiLocalizations.transcriptionNotTranslated,
              },
              onTap: showTranslationLanguagePopup,
            ),
            MeetingSwitchItem(
              title: meetingUiLocalizations.transcriptionShowBilingual,
              valueNotifier:
                  ValueNotifier(controller.isTranscriptionBilingualEnabled()),
              onChanged: enableTranscriptionBilingualDisplay,
            ),
          ],
        ),
      ],
    );
  }

  void showTranslationLanguagePopup() async {
    final language = await SelectCaptionTranslationLanguagePopup.show(
        context, controller.getTranslationLanguage());
    if (!mounted || language == null) return;
    controller.setTranslationLanguage(language);
  }

  void enableTranscriptionBilingualDisplay(bool enable) {
    controller.enableTranscriptionBilingual(enable);
  }
}

class SelectCaptionTranslationLanguagePopup extends StatelessWidget {
  static Future<NEMeetingASRTranslationLanguage?> show(
    BuildContext context,
    NEMeetingASRTranslationLanguage? selected,
  ) async {
    final width = MediaQuery.sizeOf(context).shortestSide;
    return BottomSheetUtils.showMeetingBottomDialog<
        NEMeetingASRTranslationLanguage>(
      buildContext: context,
      constraints: BoxConstraints(minWidth: width, maxWidth: width),
      routeSettings: RouteSettings(name: 'SelectCaptionTranslationLanguage'),
      actionText: NEMeetingUIKitLocalizations.of(context)!.globalCancel,
      child: SelectCaptionTranslationLanguagePopup(selected: selected),
    ).result;
  }

  final NEMeetingASRTranslationLanguage? selected;

  const SelectCaptionTranslationLanguagePopup({super.key, this.selected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: NEMeetingASRTranslationLanguage.values.map((e) {
          return _buildItem(e);
        }).toList(),
      ),
    );
  }

  Widget _buildItem(NEMeetingASRTranslationLanguage language) {
    final isSelected = language == selected;
    final color = isSelected ? _UIColors.color_337eff : _UIColors.color_333333;
    return Builder(builder: (context) {
      final localizations = context.meetingUiLocalizations;
      return GestureDetector(
        onTap: () async {
          Navigator.pop(context, isSelected ? null : language);
        },
        child: Container(
          height: 48,
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  switch (language) {
                    NEMeetingASRTranslationLanguage.chinese =>
                      localizations.langChinese,
                    NEMeetingASRTranslationLanguage.english =>
                      localizations.langEnglish,
                    NEMeetingASRTranslationLanguage.japanese =>
                      localizations.langJapanese,
                    _ => localizations.transcriptionNotTranslated,
                  },
                  style: TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w500,
                    color: _UIColors.color1E1F27,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  NEMeetingIconFont.icon_check_line,
                  size: 16,
                  color: color,
                ),
            ],
          ),
        ),
      );
    });
  }
}

/// 会议转写页面
class MeetingTranscriptionPage extends StatefulWidget {
  static Future show(
      BuildContext context, ValueChanged<bool> enableTranscriptionCallback) {
    return showMeetingPopupPageRoute(
      context: context,
      builder: (context) => MeetingWatermark(
        child: MeetingTranscriptionPage(
            enableTranscriptionCallback: enableTranscriptionCallback),
      ),
    );
  }

  final ValueChanged<bool> enableTranscriptionCallback;
  const MeetingTranscriptionPage({
    super.key,
    required this.enableTranscriptionCallback,
  });

  @override
  State<MeetingTranscriptionPage> createState() =>
      _MeetingTranscriptionPageState();
}

class _MeetingTranscriptionPageState extends State<MeetingTranscriptionPage>
    with
        MeetingKitLocalizationsMixin,
        MeetingStateScope,
        NEMeetingLiveTranscriptionControllerListener,
        FirstBuildScope {
  late final controller = meetingUIState.transcriptionController;
  final transcriptionEnabledNotifier = ValueNotifier(false);
  final itemPositionsListener = ItemPositionsListener.create();
  final itemScrollController = ItemScrollController();
  var autoScrollToBottom = true;
  var autoScrollToBottomScheduled = false;
  ({bool isOldList, int index, bool isTranslated})? selectedIndexInfo;
  var selectedVer = 0;
  final scrollController = ScrollController();
  final centerKey = UniqueKey();
  List<NERoomCaptionMessage> oldMessageList = [];
  List<NERoomCaptionMessage> newMessageList = [];
  double extentAfter = 0.0;
  final fakeMessageListScrollController = ScrollController();
  final ensureLayoutParamsCompleter = Completer<bool>();

  /// 显示源语言
  bool showOriginalText = true;

  /// 显示翻译语言
  bool showTranslatedText = false;

  @override
  void onFirstBuild() {
    controller.addListener(this);
    updateTranscriptionSettings();
    transcriptionEnabledNotifier.value = controller.isTranscriptionEnabled();
    hideAvatar.value = controller.isAvatarHidden;
    oldMessageList.addAll(controller.getTranscriptionMessageList().reversed);
    ensureLayoutParams();
  }

  @override
  void dispose() {
    controller.removeListener(this);
    scrollController.dispose();
    fakeMessageListScrollController.dispose();
    super.dispose();
  }

  @override
  void onTranslationSettingsChanged() {
    updateTranscriptionSettings();
  }

  void updateTranscriptionSettings() {
    final transLang = controller.getTranslationLanguage();
    final bilingual = controller.isTranscriptionBilingualEnabled();

    /// 不翻译/显示双语，则展示原语言
    final shouldShowOriginalText =
        transLang == NEMeetingASRTranslationLanguage.none || bilingual;

    /// 翻译打开/显示双语，则展示翻译语言
    final shouldShowTranslatedText =
        transLang != NEMeetingASRTranslationLanguage.none || bilingual;
    if (shouldShowOriginalText != showOriginalText ||
        shouldShowTranslatedText != showTranslatedText) {
      setState(() {
        selectedIndexInfo = null;
        showOriginalText = shouldShowOriginalText;
        showTranslatedText = shouldShowTranslatedText;
      });
    }
  }

  @override
  void onTranscriptionEnableChanged(bool enable) {
    transcriptionEnabledNotifier.value = enable;
  }

  @override
  void onTranscriptionMessageUpdated() {
    final willAutoScrollToBottom = extentAfter <= 5;
    setState(() {
      final messages = controller.getTranscriptionMessageList();
      final oldLen = oldMessageList.length;
      oldMessageList.clear();
      oldMessageList.addAll(messages.sublist(0, oldLen).reversed);
      newMessageList.clear();
      newMessageList.addAll(messages.sublist(oldLen));

      /// 自动滚动到底部，重置当前选中的 item，且收起菜单
      if (willAutoScrollToBottom && selectedIndexInfo?.isOldList == false) {
        selectedIndexInfo = null;
        selectedVer++;
      }
    });
    if (willAutoScrollToBottom) {
      postOnFrame(() {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _UIColors.white,
      appBar: TitleBar(
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => MeetingTranscriptionSettingsPage.show(context),
          child: Container(
            width: 48,
            height: 48,
            child: Icon(
              NEMeetingIconFont.icon_settings_stroke,
              size: 24,
              color: _UIColors.color656A72,
            ),
          ),
        ),
        title: TitleBarTitle(
          meetingUiLocalizations.transcription,
        ),
        showBottomDivider: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.topCenter,
                child: buildMessageList(),
              ),
            ),
            if (oldMessageList.isNotEmpty || newMessageList.isNotEmpty)
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 4.h, bottom: 8.h),
                  height: 22,
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    color: _UIColors.colorF0F1F5,
                  ),
                  child: Text(
                    meetingUiLocalizations.transcriptionDisclaimer,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12.spMin,
                      color: _UIColors.color8D90A0,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ValueListenableBuilder(
                valueListenable: transcriptionEnabledNotifier,
                builder: (context, _, __) {
                  return buildActionButton();
                }),
          ],
        ),
      ),
    );
  }

  /// 使用当前的数据进行计算
  void ensureLayoutParams() {
    /// 已经计算过一次，不用再重新计算
    const _oldMessageListEverFullKey =
        'transcription_old_message_list_ever_full';
    if (meetingUIState.getAttachment(_oldMessageListEverFullKey) != null) {
      ensureLayoutParamsCompleter.complete(true);
      return;
    }
    var index = 1;
    Future.doWhile(() {
      if (!mounted) return false;
      final scrollController = fakeMessageListScrollController;
      if (scrollController.hasClients) {
        final position = scrollController.position;
        if (position.hasContentDimensions && position.hasViewportDimension) {
          debugPrint('ensureLayoutParams: '
              'index=$index, '
              'viewport=${position.viewportDimension}, '
              'max=${position.maxScrollExtent}, '
              'after=${position.extentAfter}');
          final oldMessageListFull = position.extentAfter > 0;
          if (!oldMessageListFull) {
            /// 历史消息未占满全屏
            oldMessageList.clear();
            newMessageList.clear();
            newMessageList.addAll(controller.getTranscriptionMessageList());
          } else {
            meetingUIState.addAttachment(_oldMessageListEverFullKey, '');
          }
          ensureLayoutParamsCompleter.complete(oldMessageListFull);
          return false;
        }
      }

      index++;
      return Future.delayed(const Duration(milliseconds: 10), () => true);
    });
  }

  Widget buildMessageList() {
    assert(() {
      print('buildMessageList: ${oldMessageList.length}');
      return true;
    }());
    return FutureBuilder(
      future: ensureLayoutParamsCompleter.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return buildRealMessageList(snapshot.requireData);
        }
        return buildFakeMessageList();
      },
    );
  }

  Widget buildFakeMessageList() {
    return ListView.separated(
      controller: fakeMessageListScrollController,
      padding: EdgeInsets.only(top: 16.h),
      itemCount: min(oldMessageList.length, 30),
      itemBuilder: (context, index) {
        return Visibility.maintain(
          visible: false,
          child: buildItem(true, index, oldMessageList),
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(height: 12.h);
      },
    );
  }

  Widget buildRealMessageList(bool oldMessageListFull) {
    Widget child = CustomScrollView(
      controller: scrollController,
      center: centerKey,
      anchor: oldMessageListFull ? 1.0 : 0.0,
      slivers: [
        if (oldMessageList.isNotEmpty)
          SliverToBoxAdapter(
            child: SizedBox(height: 4.h),
          ),

        /// 旧消息需要逆序后往前布局
        if (oldMessageList.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: buildItem(true, index, oldMessageList),
                );
              },
              childCount: oldMessageList.length,
            ),
          ),
        SliverPadding(
          padding: EdgeInsets.zero,
          key: centerKey,
        ),

        SliverToBoxAdapter(
          child: SizedBox(height: oldMessageList.isEmpty ? 16.h : 12.h),
        ),

        /// 新消息正序布局
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: buildItem(false, index, newMessageList),
              );
            },
            childCount: newMessageList.length,
          ),
        ),
      ],
    );
    return NotificationListener(
      onNotification: (notification) {
        if (notification is OverscrollIndicatorNotification) {
          notification.disallowIndicator();
          return true;
        }

        if (notification is ScrollNotification) {
          if (notification.metrics is PageMetrics) {
            return false;
          }
          if (notification.metrics is FixedScrollMetrics) {
            if (notification.metrics.axisDirection == AxisDirection.left ||
                notification.metrics.axisDirection == AxisDirection.right) {
              return false;
            }
          }

          extentAfter = notification.metrics.extentAfter;
        }
        return false;
      },
      child: Padding(
        padding: EdgeInsets.only(left: 20.w, right: 20.w),
        child: child,
      ),
    );
  }

  Widget buildItem(isOldList, int index, List<NERoomCaptionMessage> messages) {
    if (index < 0) return SizedBox.shrink();
    final message = messages.elementAtOrNull(index);
    if (message == null) return SizedBox.shrink();
    if (message is TranscriptionStartMessage ||
        message is TranscriptionEndMessage) {
      return buildStartEndMessage(message);
    }
    return buildMessageItem(isOldList, index, message);
  }

  ValueNotifier<bool> hideAvatar = ValueNotifier(false);
  @override
  void onAvatarHiddenChanged(bool hide) {
    hideAvatar.value = hide;
  }

  Widget buildMessageItem(
      bool isOldList, int index, NERoomCaptionMessage message) {
    final userInfo = controller.getUserInfo(message.fromUserUuid)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ValueListenableBuilder(
              valueListenable: hideAvatar,
              builder: (context, hideAvatar, child) {
                return NEMeetingAvatar.small(
                  name: userInfo.nickname,
                  url: userInfo.avatar,
                  hideImageAvatar: hideAvatar,
                );
              },
            ),
            SizedBox(width: 8.w),
            Text(
              userInfo.nickname,
              style: TextStyle(
                fontSize: 14.spMin,
                color: _UIColors.color1E1F27,
                fontWeight: FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              strutStyle: StrutStyle(
                forceStrutHeight: true,
                height: 1,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              message.timestamp.formatToTimeString('HH:mm:ss'),
              style: TextStyle(
                fontSize: 14.spMin,
                color: _UIColors.color8D90A0,
                fontWeight: FontWeight.normal,
              ),
              strutStyle: StrutStyle(
                forceStrutHeight: true,
                height: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 24),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showOriginalText || message.translationContent.isEmpty)
                    buildMessageContent(isOldList, message, index, false),
                  if (showTranslatedText)
                    buildMessageContent(isOldList, message, index, true),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildMessageContent(
    bool isOldList,
    NERoomCaptionMessage message,
    int index,
    bool isTranslated,
  ) {
    final content = isTranslated ? message.translationContent : message.content;

    /// 内容不存在
    if (content == null || content.isEmpty) return SizedBox.shrink();
    final selected = selectedIndexInfo?.isOldList == isOldList &&
        selectedIndexInfo?.index == index &&
        selectedIndexInfo?.isTranslated == isTranslated;
    return Container(
      padding: EdgeInsets.only(top: 4.0, right: 4.0, bottom: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        color: selected ? _UIColors.color_ADCBFF : Colors.transparent,
      ),
      child: ChatMenuWidget(
        key: ValueKey((message.timestamp, index, isTranslated, selectedVer)),
        showOnTap: true,
        showOnLongPress: false,
        onValueChanged: (value) {
          Clipboard.setData(ClipboardData(text: content));
        },
        actions: [
          meetingUiLocalizations.globalCopy,
        ],
        willShow: () {
          setState(() {
            selectedIndexInfo = (
              isOldList: isOldList,
              index: index,
              isTranslated: isTranslated
            );
          });
        },
        child: Text(
          content,
          style: TextStyle(
            fontSize: 16.spMin,
            color: _UIColors.color1E1F27,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget buildStartEndMessage(NERoomCaptionMessage message) {
    assert(message is TranscriptionStartMessage ||
        message is TranscriptionEndMessage);
    final isStart = message is TranscriptionStartMessage;
    return Center(
      child: Text(
        isStart
            ? meetingUiLocalizations.transcriptionStartedTip
            : meetingUiLocalizations.transcriptionStoppedTip,
        style: TextStyle(
          fontSize: 12.spMin,
          color: _UIColors.color8D90A0,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget buildActionButton() {
    return MemberRoleChangedBuilder.ifManager(
      roomContext: meetingUIState.roomContext,
      builder: (context, _) {
        Widget action;
        if (controller.isTranscriptionEnabled()) {
          action = MeetingTextButton(
            text: meetingUiLocalizations.transcriptionStop,
            textColor: _UIColors.color1E1F27,
            borderColor: _UIColors.colorCDCFD7,
            backgroundColor: _UIColors.white,
            onPressed: () => enableTranscription(false),
          );
        } else {
          action = MeetingTextButton.fill(
            text: meetingUiLocalizations.transcriptionStart,
            onPressed: () => enableTranscription(true),
          );
        }
        return Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: _UIColors.colorE6E7EB,
                      width: 1,
                    ),
                  ),
                ),
                child: action,
              ),
            ),
          ],
        );
      },
    );
  }

  void enableTranscription(bool enable) {
    widget.enableTranscriptionCallback(enable);
  }
}

class NoOverscrollIndicatorBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
