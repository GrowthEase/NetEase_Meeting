// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_ui;

class MeetingInterpretationPage extends StatefulWidget {
  static bool get isShowing => _MeetingInterpretationPageState._instance > 0;

  static Future show(BuildContext context) {
    return showMeetingPopupPageRoute(
      context: context,
      builder: (context) {
        return MeetingInterpretationPage();
      },
      routeSettings: RouteSettings(name: 'MeetingInterpretationPage'),
    );
  }

  const MeetingInterpretationPage({super.key});

  @override
  State<MeetingInterpretationPage> createState() =>
      _MeetingInterpretationPageState();
}

class _MeetingInterpretationPageState
    extends _InterpretationPageBaseState<MeetingInterpretationPage> {
  static int _instance = 0;

  @override
  void initState() {
    super.initState();
    _instance++;
  }

  @override
  void dispose() {
    super.dispose();
    _instance--;
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Scaffold(
      appBar: TitleBar(
        title: TitleBarTitle(meetingUiLocalizations.interpretation),
      ),
      backgroundColor: _UIColors.colorF2F3F5,
      body: SafeArea(
        child: listenLanguageSetting(),
      ),
    );
    return AutoPopScope(
      child: child,
      listenable: ValueNotifier(!interpController.isInterpretationStarted()),
    );
  }

  Widget listenLanguageSetting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text(
            meetingUiLocalizations.interpSelectListenLanguage,
            style: TextStyle(
              color: _UIColors.color_999999,
              fontSize: 14,
            ),
          ),
        ),
        SizedBox(height: 8),
        GotoTile(
          title: getListenLanguageTitle(),
          onTap: selectListenLanguage,
        ),
        if (interpController.isMajorAudioInBackgroundEnabled()) ...[
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              meetingUiLocalizations.interpMajorAudioVolume,
              style: TextStyle(
                color: _UIColors.color_999999,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(height: 8),
          SwitchTile(
            value: interpController.isMajorAudioMute(),
            title: meetingUiLocalizations.participantMute,
            onChange: (value) {
              interpController.muteMajorAudio(value);
            },
          ),
          if (!interpController.isMajorAudioMute()) ...[
            _tileDivider(),
            VolumeBar(
              value: pendingVolume?.toDouble() ??
                  interpController.getMajorAudioVolume().toDouble(),
              onChanged: setOriginAudioVolume,
            ),
          ],
        ],
        if (getRoomContext().isMySelfHostOrCoHost()) ...[
          SizedBox(height: 10),
          GotoTile(
            title: meetingUiLocalizations.interpManagement,
            onTap: () => InMeetingInterpretationManagementPage.show(context),
          ),
        ],
      ],
    );
  }

  String getListenLanguageTitle() {
    var lang = _getLanguageNameByTag(interpController.listenLanguage);
    if (lang != null && interpController.isMajorAudioInBackgroundEnabled()) {
      lang = lang + '+' + meetingUiLocalizations.interpMajorAudio;
    }
    return lang ?? meetingUiLocalizations.interpMajorAudio;
  }

  int? pendingVolume;

  void setOriginAudioVolume(double value) {
    final volume = value.toInt();
    setState(() {
      pendingVolume = volume;
    });
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted && volume == pendingVolume) {
        interpController.adjustMajorAudioVolume(volume);
      }
    });
  }

  void selectListenLanguage() {
    _SelectListenLanguagePage.select(context);
  }
}

/// 会中译员管理、开始同声传译、停止同声传译
class InMeetingInterpretationManagementPage extends StatefulWidget {
  static Future show(BuildContext context) {
    return showMeetingPopupPageRoute(
      context: context,
      builder: (context) {
        return InMeetingInterpretationManagementPage();
      },
      routeSettings: RouteSettings(name: 'InterpretationManagementPage'),
    );
  }

  const InMeetingInterpretationManagementPage({super.key});

  @override
  State<InMeetingInterpretationManagementPage> createState() =>
      _InMeetingInterpretationManagementPageState();
}

class _InMeetingInterpretationManagementPageState
    extends _InterpretationPageBaseState<
        InMeetingInterpretationManagementPage> {
  final interpreters = <InterpreterInfo>[];

  late final InterpreterListController interpreterListController;

  @override
  void onFirstBuild() {
    super.onFirstBuild();
    interpreterListController = InMeetingInterpreterListController(
        getRoomContext(),
        interpController.getInterpreterList().map((e) {
          return InterpreterInfo(
            userId: e.userId,
            firstLang: e.firstLang,
            secondLang: e.secondLang,
            attachment: getRoomContext().getMember(e.userId),
          );
        }));
    if (interpreterListController.capacity == 0) {
      interpreterListController.addInterpreter(InterpreterInfo());
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Scaffold(
      appBar: TitleBar(
        title: TitleBarTitle(meetingUiLocalizations.interpretation),
        leading: TitleBarCloseIcon(
          onPressed: confirmToCancelEdit,
        ),
        trailing: ListenableBuilder(
            listenable: interpreterListController,
            builder: (context, _) {
              final canAdd = context.interpretationConfig.maxInterpreters >
                  interpreterListController.capacity;
              return TextButton(
                onPressed: canAdd
                    ? () {
                        interpreterListController
                            .addInterpreter(InterpreterInfo());
                      }
                    : null,
                child: Text(
                  meetingUiLocalizations.globalAdd,
                  style: TextStyle(
                    color: _UIColors.color_337eff.withOpacity(canAdd ? 1 : 0.5),
                    fontSize: 16,
                  ),
                ),
              );
            }),
      ),
      backgroundColor: _UIColors.colorF2F3F5,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: InterpreterListPage(
                controller: interpreterListController,
              ),
            ),
            bottomActionButtons(),
          ],
        ),
      ),
    );
    return AutoPopIfNotManager(
      child: child,
      roomContext: getRoomContext(),
    );
  }

  Widget bottomActionButtons() {
    final started = interpController.isInterpretationStarted();
    return ListenableBuilder(
        listenable: interpreterListController,
        builder: (context, _) {
          final hasIncomplete =
              interpreterListController.hasIncompleteInterpreters();
          final newInterpreters =
              interpreterListController.getInterpreterList();
          final canStart = !hasIncomplete && newInterpreters.isNotEmpty;
          final canUpdate = !hasIncomplete &&
              newInterpreters.isNotEmpty &&
              !listEquals(
                  newInterpreters, interpController.getInterpreterList());
          return Container(
            color: Colors.white,
            child: Row(
              children: [
                if (!started)
                  Expanded(
                    child: MeetingTextButton.fill(
                      text: meetingUiLocalizations.interpStart,
                      // 译员信息不完整时，禁用开始按钮
                      onPressed: canStart
                          ? () {
                              doAction(() {
                                return interpController.startInterpretation(
                                  interpreters: interpreterListController
                                      .getInterpreterList(),
                                );
                              });
                            }
                          : null,
                    ),
                  ),
                if (started)
                  Expanded(
                    child: MeetingTextButton(
                      text: meetingUiLocalizations.interpStop,
                      textColor: _UIColors.colorF24957,
                      borderColor: _UIColors.colorF24957,
                      backgroundColor: _UIColors.white,
                      onPressed: confirmToStopInterpretation,
                    ),
                  ),
                if (started) SizedBox(width: 15),
                if (started)
                  Expanded(
                    child: MeetingTextButton.fill(
                      text: meetingUiLocalizations.globalUpdate,
                      onPressed:
                          canUpdate ? confirmToUpdateInterpretation : null,
                    ),
                  ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          );
        });
  }

  /// 取消编辑 同声传译 二次弹窗
  void confirmToCancelEdit() async {
    var willCancel = !interpreterListController.hasIncompleteInterpreters() &&
        listEquals(interpreterListController.getInterpreterList(),
            interpController.getInterpreterList());
    if (!willCancel) {
      willCancel = await showConfirmDialog2(
            title: (ctx) =>
                ctx.meetingUiLocalizations.interpConfirmCancelEditMsg,
            cancelLabel: (ctx) => ctx.meetingUiLocalizations.globalCancel,
            okLabel: (ctx) => ctx.meetingUiLocalizations.globalSure,
            routeSettings:
                RouteSettings(name: 'InMeetingConfirmCancelEditInterpretation'),
            contentWrapperBuilder: (child) {
              return AutoPopIfNotManager(
                roomContext: getRoomContext(),
                child: child,
              );
            },
          ) ==
          true;
    }
    if (mounted && willCancel) {
      Navigator.of(context).pop();
    }
  }

  /// 关闭同声传译 二次确认 弹窗
  void confirmToStopInterpretation() async {
    final willClose = await showConfirmDialog2(
          title: (ctx) => ctx.meetingUiLocalizations.interpConfirmStopMsg,
          cancelLabel: (ctx) => ctx.meetingUiLocalizations.globalCancel,
          okLabel: (ctx) => ctx.meetingUiLocalizations.globalClose,
          okLabelColor: _UIColors.colorF24957,
          routeSettings:
              RouteSettings(name: 'InMeetingConfirmCloseInterpretation'),
          contentWrapperBuilder: (child) {
            return AutoPopIfNotManager(
              roomContext: getRoomContext(),
              child: child,
            );
          },
        ) ==
        true;
    if (mounted && willClose) {
      doAction(() => interpController.stopInterpretation());
    }
  }

  /// 更新同声传译 二次确认 弹窗
  void confirmToUpdateInterpretation() async {
    final willUpdate = await showConfirmDialog2(
          title: (ctx) => ctx.meetingUiLocalizations.interpConfirmUpdateMsg,
          cancelLabel: (ctx) => ctx.meetingUiLocalizations.globalCancel,
          okLabel: (ctx) => ctx.meetingUiLocalizations.globalSure,
          routeSettings:
              RouteSettings(name: 'InMeetingConfirmUpdateInterpretation'),
          contentWrapperBuilder: (child) {
            return AutoPopIfNotManager(
              roomContext: getRoomContext(),
              child: child,
            );
          },
        ) ==
        true;
    if (mounted && willUpdate) {
      doAction(() => interpController.updateInterpreterList(
          interpreterListController.getInterpreterList()));
    }
  }

  void doAction<T>(Future<NEResult<T>> Function() action) async {
    doIfNetworkAvailable(() async {
      final result = await toastOnFail(action);
      if (mounted) {
        if (result.isSuccess() && ModalRoute.of(context)!.isCurrent) {
          Navigator.of(context).pop();
        } else if (!result.isSuccess()) {
          showToast(result.msg ?? meetingUiLocalizations.globalOperationFail);
        }
      }
    });
  }
}

/// 成员选择“收听语言”页面
class _SelectListenLanguagePage extends StatefulWidget {
  static Future select(BuildContext context) {
    return showMeetingPopupPageRoute<String>(
      routeSettings: RouteSettings(name: 'SelectListenLanguagePage'),
      context: context,
      builder: (context) {
        return _SelectListenLanguagePage();
      },
    );
  }

  const _SelectListenLanguagePage({super.key});

  @override
  State<_SelectListenLanguagePage> createState() =>
      _SelectListenLanguagePageState();
}

class _SelectListenLanguagePageState
    extends _InterpretationPageBaseState<_SelectListenLanguagePage> {
  @override
  Widget build(BuildContext context) {
    return AutoPopScope(
      listenable: ValueNotifier(!interpController.isInterpretationStarted()),
      child: Scaffold(
        appBar: TitleBar(
          title: TitleBarTitle(meetingUiLocalizations.interpSelectLanguage),
        ),
        backgroundColor: _UIColors.colorF2F3F5,
        body: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: 20),
            ...[
              null,
              ...interpController.getAvailableLanguageList(),
              if (interpController.listenLanguage != null &&
                  !interpController
                      .getAvailableLanguageList()
                      .contains(interpController.listenLanguage))
                interpController.listenLanguage,
            ]
                .map((lang) => GotoTile(
                      title: lang == null
                          ? meetingUiLocalizations.interpMajorAudio
                          : _getLanguageNameByTag(lang) ?? lang,
                      onTap: () => setListenLanguage(lang),
                      trailing: interpController.listenLanguage == lang
                          ? Icon(
                              NEMeetingIconFont.icon_check_line,
                              size: 16.0,
                              color: _UIColors.color_337eff,
                            )
                          : SizedBox.shrink(),
                    ))
                .expand((element) => [element, _tileDivider()])
                .toList()
              ..removeLast(),
            SizedBox(height: 16),
            if (interpController.listenLanguage != null)
              SwitchTile(
                title: meetingUiLocalizations.interpListenMajorAudioMeanwhile,
                value: interpController.isMajorAudioInBackgroundEnabled(),
                onChange: (value) {
                  interpController.enableMajorAudioInBackground(value);
                },
              ),
          ],
        ),
      ),
    );
  }

  void setListenLanguage(String? language) async {
    final controller = interpController;
    if (language != controller.listenLanguage) {
      final result = await controller.setListenLanguage(language);
      if (mounted &&
          !result.isSuccess() &&
          !result.isForbidden() &&
          !result.isCancelled()) {
        final willRejoin = await showRejoinChannelConfirmDialog() == true;
        if (mounted && willRejoin) {
          setListenLanguage(language);
        }
      }
    }
  }
}

/// 根据 语言 获取语言名称
String? _getLanguageNameByTag(
  String? langTag, [
  NEMeetingUIKitLocalizations? localizations,
]) {
  localizations ??= NEMeetingUIKit.instance.getUIKitLocalizations();
  return switch (langTag) {
    NEInterpretationLanguages.chinese => localizations.langChinese,
    NEInterpretationLanguages.english => localizations.langEnglish,
    NEInterpretationLanguages.japanese => localizations.langJapanese,
    NEInterpretationLanguages.korean => localizations.langKorean,
    NEInterpretationLanguages.french => localizations.langFrench,
    NEInterpretationLanguages.german => localizations.langGerman,
    NEInterpretationLanguages.spanish => localizations.langSpanish,
    NEInterpretationLanguages.russian => localizations.langRussian,
    NEInterpretationLanguages.portuguese => localizations.langPortuguese,
    NEInterpretationLanguages.italian => localizations.langItalian,
    NEInterpretationLanguages.turkish => localizations.langTurkish,
    NEInterpretationLanguages.vietnamese => localizations.langVietnamese,
    NEInterpretationLanguages.thai => localizations.langThai,
    NEInterpretationLanguages.indonesian => localizations.langIndonesian,
    NEInterpretationLanguages.malay => localizations.langMalay,
    NEInterpretationLanguages.arabic => localizations.langArabic,
    NEInterpretationLanguages.hindi => localizations.langHindi,
    _ => langTag
  };
}

/// 译员切换传译语言面板
class InterpreterSwitchLangPanel extends StatefulWidget {
  const InterpreterSwitchLangPanel({super.key});

  @override
  State<InterpreterSwitchLangPanel> createState() =>
      _InterpreterSwitchLangPanelState();
}

class _InterpreterSwitchLangPanelState
    extends _InterpretationPageBaseState<InterpreterSwitchLangPanel> {
  @override
  Widget build(BuildContext context) {
    final mySelfInterpreter = interpController.getMySelfInterpreter();
    if (mySelfInterpreter == null ||
        !interpController.isInterpretationStarted()) {
      return SizedBox.shrink();
    }
    final speakLang = interpController.speakLanguage ?? '';
    return SizedBox(
      height: 36,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: _UIColors.color282832,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            speakLanguageButton(mySelfInterpreter.firstLang, speakLang),
            Container(
              width: 1,
              height: 16,
              color: Colors.white.withOpacity(0.2),
            ),
            speakLanguageButton(mySelfInterpreter.secondLang, speakLang),
            Container(
              width: 1,
              height: 16,
              color: Colors.white.withOpacity(0.2),
            ),
            speakLanguageButton('', speakLang),
          ],
        ),
      ),
    );
  }

  Widget speakLanguageButton(String? languageTag, String speakLang) {
    if (languageTag == null) return SizedBox.shrink();
    final majorAudio = languageTag == '';
    final selected = languageTag == speakLang;
    return TextButton(
      onPressed: () => switchSpeakLanguage(majorAudio ? null : languageTag),
      child: Text(
        majorAudio
            ? meetingUiLocalizations.interpMajorChannel
            : _getLanguageNameByTag(languageTag)!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: ButtonStyle(
        fixedSize: MaterialStateProperty.all(Size.fromWidth(80)),
        textStyle: MaterialStateProperty.all(
          TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        backgroundColor: MaterialStateProperty.all(
          selected ? _UIColors.white : Colors.transparent,
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        foregroundColor: MaterialStateProperty.all(
            selected ? _UIColors.blue_337eff : _UIColors.white),
      ),
    );
  }

  void switchSpeakLanguage(String? language) async {
    final result = await interpController.setSpeakLanguage(language);
    if (mounted &&
        !result.isSuccess() &&
        !result.isForbidden() &&
        !result.isCancelled()) {
      final willRejoin = await showRejoinChannelConfirmDialog() == true;
      if (mounted && willRejoin) {
        switchSpeakLanguage(language);
      }
    }
  }
}

/// 音量条
class VolumeBar extends StatelessWidget {
  final double min, max;
  final double value;
  final ValueChanged<double>? onChanged;

  const VolumeBar({
    super.key,
    this.min = 0,
    this.max = 100,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 56,
      padding: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        children: [
          Icon(
            NEMeetingIconFont.icon_volume_down,
            size: 16,
            color: _UIColors.colorE9E9EA,
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                trackShape: RoundSliderTrackShape(radius: 2),
                thumbShape: RoundBorderSliderThumbShape(
                  enabledThumbRadius: 8,
                  border: BorderSide(
                    color: _UIColors.blue_337eff,
                    width: 2,
                  ),
                ),
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  onChanged: onChanged,
                  activeColor: _UIColors.blue_337eff,
                  thumbColor: _UIColors.white,
                  inactiveColor: _UIColors.colorE9E9EA,
                ),
              ),
            ),
          ),
          Icon(
            NEMeetingIconFont.icon_volume_up,
            size: 16,
            color: _UIColors.colorE9E9EA,
          ),
        ],
      ),
    );
  }
}

Widget _tileDivider() {
  return Container(
    padding: const EdgeInsets.only(left: 20.0),
    color: Colors.white,
    child: Container(
      height: 1,
      color: _UIColors.colorE8E9EB,
    ),
  );
}

abstract class _InterpretationPageBaseState<T extends StatefulWidget>
    extends State<T>
    with MeetingKitLocalizationsMixin, MeetingStateScope, FirstBuildScope {
  late final interpController = meetingUIState.interpretationController;

  void onFirstBuild() {
    interpController.addListener(updateUI);
  }

  @override
  void dispose() {
    interpController.removeListener(updateUI);
    super.dispose();
  }

  void updateUI() {
    if (!mounted) return;
    setState(() {});
  }

  /// 重新加入频道确认弹窗
  Future<bool?> showRejoinChannelConfirmDialog() {
    return showConfirmDialog2(
      title: (ctx) => ctx.meetingUiLocalizations.interpJoinChannelErrorMsg,
      cancelLabel: (ctx) => ctx.meetingUiLocalizations.globalCancel,
      okLabel: (ctx) => ctx.meetingUiLocalizations.interpReJoinChannel,
      routeSettings:
          RouteSettings(name: 'InterpreterRejoinChannelConfirmDialog'),
      contentWrapperBuilder: (child) {
        return ListenableBuilder(
          listenable: interpController,
          builder: (context, child) {
            return AutoPopScope(
              listenable:
                  ValueNotifier(!interpController.isInterpretationStarted()),
              child: child!,
            );
          },
          child: child,
        );
      },
    );
  }
}

typedef OnSelectUser = void Function(BuildContext, InterpreterInfo);
typedef OnGetComment = String? Function(BuildContext, InterpreterInfo);

/// 译员信息卡片
class MeetingInterpreterCard extends StatelessWidget {
  final VoidCallback? onSelectFirstLang;
  final VoidCallback? onSelectSecondLang;
  final VoidCallback? onSwitchLang;
  final OnSelectUser? onSelectUser;
  final InterpreterInfo interpreter;
  final OnGetComment? onGetComment;

  const MeetingInterpreterCard({
    super.key,
    required this.interpreter,
    this.onSelectUser,
    this.onSelectFirstLang,
    this.onSelectSecondLang,
    this.onSwitchLang,
    this.onGetComment,
  });

  @override
  Widget build(BuildContext context) {
    return NEMeetingUIKitLocalizationsScope(
        builder: (context, localizations, _) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: _UIColors.white,
        ),
        child: ListenableBuilder(
          listenable: interpreter,
          builder: (context, _) {
            var InterpreterInfo(
              :name,
              :avatar,
              :firstLang,
              :secondLang,
            ) = interpreter;
            final comment = onGetComment?.call(context, interpreter);
            return Column(
              children: [
                GestureDetector(
                  onTap: () => onSelectUser?.call(context, interpreter),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _UIColors.colorF2F3F5,
                    ),
                    child: Row(
                      children: [
                        if (name != null)
                          NEMeetingAvatar.small(
                            name: name,
                            url: avatar,
                          ),
                        if (name != null) SizedBox(width: 8),
                        Text(
                          name ?? localizations.interpInterpreter,
                          style: TextStyle(
                            color: name == null
                                ? _UIColors.greyCCCCCC
                                : _UIColors.color_333333,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (comment != null)
                          Text(
                            '($comment)',
                            style: TextStyle(
                              color: _UIColors.color_999999,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildLang(
                        _getLanguageNameByTag(firstLang) ??
                            localizations.globalLang,
                        onSelectFirstLang,
                        firstLang == null,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: GestureDetector(
                        onTap: () {
                          if (firstLang != null || secondLang != null)
                            onSwitchLang?.call();
                        },
                        child: Icon(
                          NEMeetingIconFont.icon_switch,
                          size: 16,
                          color: _UIColors.color_999999,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildLang(
                        _getLanguageNameByTag(secondLang) ??
                            localizations.globalLang,
                        onSelectSecondLang,
                        secondLang == null,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    });
  }

  Widget _buildLang(String lang, VoidCallback? onTap, bool empty) {
    return GotoTile(
      decoration: BoxDecoration(
        color: _UIColors.colorF2F3F5,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      height: 40,
      title: lang,
      titleTextStyle: TextStyle(
        color: empty ? _UIColors.greyCCCCCC : _UIColors.color_333333,
        fontSize: 14,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
      trailing: Icon(
        NEMeetingIconFont.icon_arrow_down,
        size: 14,
        color: _UIColors.greyCCCCCC,
      ),
      maxLines: 1,
    );
  }
}

/// 选择语言页面，区别于选择收听语言。该页面会展示支持的语言，并可允许添加自定义语言。
class SelectLanguagePage extends StatefulWidget {
  static Future<String?> select(
    BuildContext context, {
    String? disableLang,
    String? selectedLang,
    List<String> extraLangs = const [],
  }) {
    return showMeetingPopupPageRoute(
      context: context,
      routeSettings: RouteSettings(name: 'SelectLanguagePage'),
      builder: (context) {
        return SelectLanguagePage(
          disableLang: disableLang,
          selectedLang: selectedLang,
          extraLangs: extraLangs,
        );
      },
    );
  }

  final String? disableLang;
  final String? selectedLang;

  /// 额外的语言列表
  final List<String> extraLangs;

  const SelectLanguagePage({
    super.key,
    this.disableLang,
    this.selectedLang,
    this.extraLangs = const [],
  });

  @override
  State<SelectLanguagePage> createState() => _SelectLanguagePageState();
}

class _SelectLanguagePageState extends State<SelectLanguagePage>
    with MeetingKitLocalizationsMixin {
  final langs = <String>[];
  final langsSet = <String>{};
  late final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    NEInterpretationLanguages.all.forEach(addCustomLang);
    widget.extraLangs.forEach(addCustomLang);
    InterpretationCustomLangCache.getLanguages().forEach(addCustomLang);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  bool addCustomLang(String lang) {
    if (langsSet.add(lang)) {
      langs.add(lang);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NEMeetingKitFeatureConfig(
      // 使用最近的 sdk config，如果在会议中，可以查询到会议中使用的实例
      config: context.sdkConfig,
      child: NEMeetingUIKitLocalizationsScope(
          builder: (context, localizations, _) {
        bool canAddCustomLang = context.interpretationConfig.enableCustomLang;
        final maxCustomLangNameLen =
            context.interpretationConfig.maxCustomLangNameLen;
        return Scaffold(
          appBar: TitleBar(
            showBottomDivider: true,
            title: TitleBarTitle(
              localizations.interpSelectLanguage,
            ),
            leading: canAddCustomLang ? TitleBarCloseIcon() : null,
            trailing: canAddCustomLang
                ? TextButton(
                    onPressed: () =>
                        showAddCustomLangDialog(maxCustomLangNameLen),
                    child: Text(
                      localizations.globalAdd,
                      style: TextStyle(
                        color: _UIColors.color_337eff,
                        fontSize: 16,
                      ),
                    ),
                  )
                : TitleBarCloseIcon(),
          ),
          backgroundColor: _UIColors.colorF2F3F5,
          body: ListView(
            controller: scrollController,
            children: [
              SizedBox(height: 20),
              ...langs
                  .map((lang) => GotoTile(
                        title:
                            _getLanguageNameByTag(lang, localizations) ?? lang,
                        titleTextStyle: TextStyle(
                          color: lang == widget.disableLang
                              ? _UIColors.color_999999
                              : _UIColors.color_222222,
                          fontSize: 16,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                        onTap: lang == widget.disableLang
                            ? null
                            : () {
                                Navigator.of(context).pop(lang);
                              },
                        trailing: widget.selectedLang == lang
                            ? Icon(
                                NEMeetingIconFont.icon_check_line,
                                size: 16.0,
                                color: _UIColors.color_337eff,
                              )
                            : SizedBox.shrink(),
                      ))
                  .expand((element) => [element, _tileDivider()])
                  .toList()
                ..removeLast(),
              SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  void showAddCustomLangDialog(int maxLen) {
    final controller = TextEditingController();
    bool isInputValid() =>
        controller.text.isNotBlank && controller.text.isNotEmpty;
    showCupertinoDialog<String>(
      routeSettings: RouteSettings(name: 'showAddCustomLangDialog'),
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (_, setState) => NEMeetingUIKitLocalizationsScope(
              builder: (BuildContext context, localizations, _) {
            return CupertinoAlertDialog(
              title: Text(localizations.interpAddLanguage),
              content: Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CupertinoTextField(
                        autofocus: true,
                        controller: controller,
                        maxLines: 1,
                        placeholder: localizations.interpInputLanguage,
                        placeholderStyle: const TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.placeholderText,
                        ),
                        onChanged: (_) => setState(() {}),
                        keyboardType: TextInputType.text,
                        clearButtonMode: OverlayVisibilityMode.editing,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(maxLen),
                        ],
                      ),
                    ],
                  )),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(localizations.globalCancel),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                  child: Text(localizations.globalAdd),
                  onPressed: isInputValid()
                      ? () => returnLangIfValid(context, controller.text.trim())
                      : null,
                ),
              ],
            );
          }),
        );
      },
    ).then((result) {
      if (mounted && result != null) {
        final customLang = result.trim();
        if (addCustomLang(customLang)) {
          InterpretationCustomLangCache.addLanguage(customLang);
          scrollController.position
              .jumpTo(scrollController.position.maxScrollExtent);
          setState(() {});
        }
      }
    });
  }

  void returnLangIfValid(BuildContext context, String lang) {
    if (isLanguageAlreadyExists(lang)) {
      showToast(NEMeetingUIKit.instance
          .getUIKitLocalizations()
          .interpLanguageAlreadyExists);
      return;
    }
    Navigator.of(context).pop(lang);
  }

  bool isLanguageAlreadyExists(String lang) {
    return langs.any((element) {
      return element == lang || lang == _getLanguageNameByTag(element);
    });
  }
}

/// 自定义语言内存缓存
class InterpretationCustomLangCache {
  InterpretationCustomLangCache._();

  static final _langs = LinkedHashSet<String>();

  static void addLanguage(String lang) {
    _langs.add(lang);
  }

  static void clearLanguages(String lang) {
    _langs.clear();
  }

  static List<String> getLanguages() {
    return _langs.toList();
  }
}

class InterpreterInfo extends ChangeNotifier {
  String? _userId;
  String? _firstLang;
  String? _secondLang;
  dynamic _attachment;

  InterpreterInfo({
    String? userId,
    String? firstLang,
    String? secondLang,
    dynamic attachment,
  })  : _userId = userId,
        _firstLang = firstLang,
        _secondLang = secondLang,
        _attachment = attachment;

  String? get userId => _userId;

  String? get firstLang => _firstLang;

  String? get secondLang => _secondLang;

  dynamic get attachment => _attachment;

  String? get name {
    switch (_attachment) {
      case NEContact(:String? name) ||
            NERoomMember(:String? name) ||
            NEBaseRoomMember(:String? name):
        return name;
      default:
        return null;
    }
  }

  String? get avatar {
    switch (_attachment) {
      case NEContact(:var avatar) ||
            NERoomMember(:var avatar) ||
            NEBaseRoomMember(:var avatar):
        return avatar;
      default:
        return null;
    }
  }

  void setFirstLang(String? firstLang) {
    if (_firstLang != firstLang) {
      _firstLang = firstLang;
      notifyListeners();
    }
  }

  void setSecondLang(String? secondLang) {
    if (_secondLang != secondLang) {
      _secondLang = secondLang;
      notifyListeners();
    }
  }

  void switchLang() {
    if (_firstLang != null || _secondLang != null) {
      final lang = _firstLang;
      _firstLang = secondLang;
      _secondLang = lang;
      notifyListeners();
    }
  }

  void setUser(String userId, Object attachment) {
    if (_userId != userId || _attachment != attachment) {
      _userId = userId;
      _attachment = attachment;
      notifyListeners();
    }
  }

  void setAttachment(dynamic attachment) {
    if (_attachment != attachment) {
      _attachment = attachment;
      notifyListeners();
    }
  }

  bool isIncomplete() {
    return (userId != null || firstLang != null || secondLang != null) &&
        (userId == null || firstLang == null || secondLang == null);
  }

  bool isValid() {
    return userId != null && firstLang != null && secondLang != null;
  }
}

/// 用于控制同声传译译员添加、删除、更新操作
class InterpreterListController extends ChangeNotifier {
  final _interpreters = <InterpreterInfo>[];

  InterpreterListController([Iterable<InterpreterInfo>? interpreterInfos]) {
    if (interpreterInfos != null) {
      interpreterInfos.forEach(addInterpreter);
    }
    _loadUserAttachment();
  }

  InterpreterListController.withInterpreters(
      [Iterable<NEMeetingInterpreter>? interpreters]) {
    if (interpreters != null) {
      interpreters.map((e) {
        return InterpreterInfo(
          userId: e.userId,
          firstLang: e.firstLang,
          secondLang: e.secondLang,
        );
      }).forEach(addInterpreter);
    }
    _loadUserAttachment();
  }

  void _loadUserAttachment() async {
    final usersWithoutAttachment = _interpreters
        .where((e) => e.isValid())
        .where((e) => e.attachment == null)
        .map((e) => e.userId!)
        .toList();
    if (usersWithoutAttachment.isNotEmpty) {
      final result = await NEMeetingKit.instance
          .getContactsService()
          .getContactsInfo(usersWithoutAttachment);
      if (result.isSuccess()) {
        result.data!.foundList.forEach((e1) {
          _interpreters
              .firstWhereOrNull((e2) => e1.userUuid == e2.userId)
              ?.setAttachment(e1);
        });
      }
    }
  }

  int get capacity => _interpreters.length;

  int get size {
    return _interpreters.where((element) => element.isValid()).length;
  }

  bool get isNotEmpty => size > 0;

  List<NEMeetingInterpreter> getInterpreterList() {
    return _interpreters
        .where((element) => element.isValid())
        .map(
            (e) => NEMeetingInterpreter(e.userId!, e.firstLang!, e.secondLang!))
        .toList();
  }

  bool hasInterpreter(String userId) {
    return _interpreters
        .any((element) => element.isValid() && element.userId == userId);
  }

  Set<String> getSelectedUsers() {
    return _interpreters.map((e) => e.userId).whereNotNull().toSet();
  }

  InterpreterInfo getInterpreter(int index) {
    return _interpreters[index];
  }

  void addInterpreter(InterpreterInfo interpreter) {
    _interpreters.add(interpreter);
    interpreter.addListener(notifyListeners);
    notifyListeners();
  }

  void removeInterpreter(InterpreterInfo interpreter) {
    if (_interpreters.remove(interpreter)) {
      interpreter.removeListener(notifyListeners);
      notifyListeners();
    }
  }

  void removeInterpreterByUserId(String userId) {
    final interpreter =
        _interpreters.firstWhereOrNull((e) => e.userId == userId);
    if (interpreter != null) {
      removeInterpreter(interpreter);
    }
  }

  String? getUserComment(BuildContext context, InterpreterInfo interpreter) {
    return null;
  }

  Future<InterpreterInfo?> selectUser(
      BuildContext context, InterpreterInfo interpreter) {
    return _SelectInterpreterFromContactList.select(
      context,
      interpreter.attachment as NEContact?,
      getSelectedUsers(),
    ).then((contact) {
      if (contact != null) {
        interpreter.setUser(contact.userUuid, contact);
      }
      return null;
    });
  }

  bool hasIncompleteInterpreters() {
    return _interpreters.any((element) => element.isIncomplete());
  }

  void discardIncompleteInterpreters() {
    final cap = _interpreters.length;
    _interpreters.removeWhere((element) => element.isIncomplete());
    if (_interpreters.length != cap) {
      notifyListeners();
    }
  }
}

/// 会中译员列表管理
class InMeetingInterpreterListController extends InterpreterListController {
  final NERoomContext roomContext;

  InMeetingInterpreterListController(this.roomContext,
      [super.interpreterInfos]);

  @override
  String? getUserComment(BuildContext context, InterpreterInfo interpreter) {
    if (interpreter.userId != null) {
      final member = roomContext.getMember(interpreter.userId);
      if (member == null || !member.isInRtcChannel) {
        return NEMeetingUIKitLocalizations.of(context)!.participantNotJoined;
      }
    }
    return null;
  }

  @override
  Future<InterpreterInfo?> selectUser(
      BuildContext context, InterpreterInfo interpreter) {
    return _SelectInterpreterFromInMeetingPage.select(
            context, interpreter.userId, getSelectedUsers())
        .then((member) {
      if (member != null) {
        interpreter.setUser(member.uuid, member);
      }
      return null;
    });
  }
}

/// 即将删除译员回调，返回 false 不删除
typedef Future<bool> OnWillRemoveInterpreter(InterpreterInfo interpreter);

/// 译员列表
class InterpreterListPage extends StatefulWidget {
  final InterpreterListController controller;
  final bool editable;
  final OnWillRemoveInterpreter? onWillRemoveInterpreter;

  const InterpreterListPage({
    super.key,
    required this.controller,
    this.editable = true,
    this.onWillRemoveInterpreter,
  });

  @override
  State<InterpreterListPage> createState() => _InterpreterListPageState();
}

class _InterpreterListPageState extends State<InterpreterListPage> {
  late InterpreterListController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    controller.addListener(updateUI);
  }

  @override
  void didUpdateWidget(covariant InterpreterListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(updateUI);
      controller = widget.controller;
      controller.addListener(updateUI);
    }
  }

  @override
  void dispose() {
    controller.removeListener(updateUI);
    super.dispose();
  }

  void updateUI() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: controller.capacity,
      itemBuilder: (context, index) {
        final interpreter = controller.getInterpreter(index);
        Widget child = buildInterpreterItem(interpreter);
        if (!widget.editable) {
          return child;
        }
        return Slidable(
          key: ValueKey(interpreter),
          endActionPane: ActionPane(
            extentRatio: 76.0 / 375,
            motion: BehindMotion(),
            children: [
              CustomSlidableAction(
                onPressed: (context) async {
                  final willRemove =
                      await widget.onWillRemoveInterpreter?.call(interpreter) !=
                          false;
                  if (!mounted) return;
                  if (willRemove) {
                    controller.removeInterpreter(interpreter);
                  } else {
                    Slidable.of(context)?.close();
                  }
                },
                backgroundColor: Colors.transparent,
                autoClose: false,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: ShapeDecoration(
                    shape: CircleBorder(),
                    color: _UIColors.colorFE3B30,
                    // borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(
                    NEMeetingIconFont.icon_delete,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          child: child,
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(height: 10);
      },
    );
  }

  Widget buildInterpreterItem(InterpreterInfo interpreter) {
    final editable = widget.editable;
    return MeetingInterpreterCard(
      interpreter: interpreter,
      onSwitchLang: editable ? () => interpreter.switchLang() : null,
      onSelectFirstLang: editable ? () => selectLang(interpreter, true) : null,
      onSelectSecondLang:
          editable ? () => selectLang(interpreter, false) : null,
      onSelectUser: editable ? controller.selectUser : null,
      onGetComment: controller.getUserComment,
    );
  }

  void selectLang(InterpreterInfo interpreter, bool firstLang) {
    SelectLanguagePage.select(
      context,
      disableLang: firstLang ? interpreter.secondLang : interpreter.firstLang,
      selectedLang: firstLang ? interpreter.firstLang : interpreter.secondLang,
      extraLangs: controller
          .getInterpreterList()
          .map((e) => [e.firstLang, e.secondLang])
          .flattened
          .toList(),
    ).then((lang) {
      if (mounted && lang != null) {
        if (firstLang) {
          interpreter.setFirstLang(lang);
        } else {
          interpreter.setSecondLang(lang);
        }
      }
    });
  }
}

/// 预约会议选择译员页面
class PreMeetingInterpreterListPage extends StatefulWidget {
  static void show(
    BuildContext context,
    InterpreterListController controller, {
    bool editable = true,
    OnWillRemoveInterpreter? onWillRemoveInterpreter,
  }) {
    showMeetingPopupPageRoute(
      context: context,
      routeSettings: RouteSettings(name: 'PreMeetingInterpreterListPage'),
      builder: (context) {
        return PreMeetingInterpreterListPage(
          controller: controller,
          editable: editable,
          onWillRemoveInterpreter: onWillRemoveInterpreter,
        );
      },
    );
  }

  final InterpreterListController controller;
  final bool editable;
  final OnWillRemoveInterpreter? onWillRemoveInterpreter;

  PreMeetingInterpreterListPage({
    super.key,
    required this.controller,
    this.editable = true,
    this.onWillRemoveInterpreter,
  });

  @override
  State<PreMeetingInterpreterListPage> createState() =>
      _PreMeetingInterpreterListPageState();
}

class _PreMeetingInterpreterListPageState
    extends State<PreMeetingInterpreterListPage>
    with MeetingKitLocalizationsMixin {
  @override
  Widget build(BuildContext context) {
    Widget child = Scaffold(
      appBar: TitleBar(
        title: TitleBarTitle(meetingUiLocalizations.interpInterpreter),
        leading: widget.editable
            ? TitleBarCloseIcon(
                onPressed: () async {
                  var willPop = true;
                  if (widget.controller.hasIncompleteInterpreters()) {
                    willPop = await showConfirmDialog2(
                          title: (ctx) => ctx
                              .meetingUiLocalizations.interpInfoIncompleteTitle,
                          message: (ctx) => ctx
                              .meetingUiLocalizations.interpInfoIncompleteMsg,
                          cancelLabel: (ctx) =>
                              ctx.meetingUiLocalizations.globalCancel,
                          okLabel: (ctx) =>
                              ctx.meetingUiLocalizations.globalSure,
                          routeSettings: RouteSettings(
                              name: 'PreMeetingCancelEditInterpreter'),
                        ) ==
                        true;
                  }
                  if (mounted && willPop) {
                    Navigator.of(context).pop();
                  }
                },
              )
            : null,
        trailing: widget.editable
            ? ListenableBuilder(
                listenable: widget.controller,
                builder: (context, _) {
                  final disabled = widget.controller.capacity >=
                      context.interpretationConfig.maxInterpreters;
                  return TextButton(
                    onPressed: disabled
                        ? null
                        : () {
                            widget.controller.addInterpreter(InterpreterInfo());
                          },
                    child: Text(
                      meetingUiLocalizations.globalAdd,
                      style: TextStyle(
                        color: _UIColors.color_337eff
                            .withOpacity(disabled ? 0.5 : 1),
                        fontSize: 16,
                      ),
                    ),
                  );
                })
            : TitleBarCloseIcon(),
      ),
      backgroundColor: _UIColors.colorF2F3F5,
      body: SafeArea(
        child: InterpreterListPage(
          controller: widget.controller,
          editable: widget.editable,
          onWillRemoveInterpreter: widget.onWillRemoveInterpreter,
        ),
      ),
    );
    return NEMeetingKitFeatureConfig(child: child);
  }

  @override
  void dispose() {
    final controller = widget.controller;
    Timer.run(() {
      controller.discardIncompleteInterpreters();
    });
    super.dispose();
  }
}

/// 会前从企业通讯录选择译员
class _SelectInterpreterFromContactList extends StatelessWidget {
  static Future<NEContact?> select(
      BuildContext context, NEContact? current, Set<String> selectedUsers) {
    return showMeetingPopupPageRoute<NEContact>(
      context: context,
      routeSettings: RouteSettings(name: 'SelectInterpreterFromContactList'),
      builder: (context) {
        return _SelectInterpreterFromContactList(
            current: current, selectedUsers: selectedUsers);
      },
    );
  }

  final Set<String> selectedUsers;
  final NEContact? current;

  const _SelectInterpreterFromContactList({
    super.key,
    this.current,
    required this.selectedUsers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar(
        title: TitleBarTitle(NEMeetingUIKit.instance
            .getUIKitLocalizations()
            .interpSelectInterpreter),
        showBottomDivider: true,
      ),
      body: ContactList(
        alreadySelectedUserUuids: current != null ? [current!.userUuid] : [],
        selectedContactsCache: current != null ? [current!] : [],
        singleMode: true,
        showSearchHint: false,
        itemClickCallback: (contact, _, __) {
          if (selectedUsers.contains(contact.userUuid)) {
            ToastUtils.showToast(
                context,
                NEMeetingUIKit.instance
                    .getUIKitLocalizations()
                    .interpInterpreterAlreadyExists);
            return false;
          }
          return true;
        },
      ),
    );
  }
}

/// 会中选择译员页面，包含与会成员、未入会成员（不包含 sip 端）
class _SelectInterpreterFromInMeetingPage extends StatefulWidget {
  static Future<NEBaseRoomMember?> select(
      BuildContext context, String? selected, Set<String> selectedUsers) {
    return showMeetingPopupPageRoute<NEBaseRoomMember>(
      context: context,
      routeSettings: RouteSettings(name: 'SelectInterpreterFromInMeetingPage'),
      builder: (context) {
        return _SelectInterpreterFromInMeetingPage(
            current: selected, selectedUsers: selectedUsers);
      },
    );
  }

  final Set<String> selectedUsers;
  final String? current;

  const _SelectInterpreterFromInMeetingPage({
    super.key,
    this.current,
    required this.selectedUsers,
  });

  @override
  State<_SelectInterpreterFromInMeetingPage> createState() =>
      _SelectInterpreterFromInMeetingPageState();
}

class _SelectInterpreterFromInMeetingPageState
    extends State<_SelectInterpreterFromInMeetingPage>
    with MeetingKitLocalizationsMixin, MeetingStateScope {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MeetingMemberPageView(
        title: (_) => meetingUiLocalizations.interpSelectInterpreter,
        roomContext: getRoomContext(),
        showUserEnterHint: false,
        pageFilter: (page) {
          return page.type == _MembersPageType.inMeeting ||
              page.type == _MembersPageType.notYetJoined &&
                  getFilterMemberList(page).length > 0;
        },
        pageBuilder: (page, searchKey) => _buildMemberListPage(page, searchKey),
        memberSize: calculateMemberSize,
      ),
    );
  }

  /// 计算成员列表的大小
  int calculateMemberSize(_PageData pageData, _) =>
      getFilterMemberList(pageData).length;

  List<NEBaseRoomMember> getFilterMemberList(_PageData pageData) {
    /// 移除自己和SIP成员
    return pageData.filteredUserList
        .whereType<NEBaseRoomMember>()
        .whereNot((element) =>
            element is NERoomMember && element.clientType == NEClientType.sip)
        .toList();
  }

  Widget _buildMemberListPage(_PageData pageData, String? searchKey) {
    final memberList = getFilterMemberList(pageData);
    return memberList.isEmpty
        ? Container(
            alignment: Alignment.center,
            child: Text(
              meetingUiLocalizations.participantNotFound,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: _UIColors.color3D3D3D,
                decoration: TextDecoration.none,
              ),
            ),
          )
        : buildMembers(memberList);
  }

  Widget buildMembers(List<NEBaseRoomMember> userList) {
    final len = userList.length;

    return ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        primary: false,
        cacheExtent: 48,
        itemCount: len + 1,
        itemBuilder: (context, index) {
          if (index == len) {
            return SizedBox(height: 1);
          }
          return buildMemberItem(userList[index]);
        },
        separatorBuilder: (context, index) {
          return buildDivider();
        });
  }

  Widget buildMemberItem(NEBaseRoomMember user) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (user.uuid != widget.current) {
          if (widget.selectedUsers.contains(user.uuid)) {
            showToast(meetingUiLocalizations.interpInterpreterAlreadyExists);
            return;
          }
          Navigator.of(context).pop(user);
        }
      },
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            NEMeetingAvatar.medium(
              name: user.name,
              url: user.avatar,
            ),
            SizedBox(width: 6),
            Expanded(
              child: _memberItemNick(user),
            ),
            if (widget.current == user.uuid)
              Icon(
                NEMeetingIconFont.icon_check_line,
                size: 16,
                color: _UIColors.color_337eff,
              ),
          ],
        ),
      ),
    );
  }

  Widget _memberItemNick(NEBaseRoomMember user) {
    var subtitle = <String>[];
    if (user is NERoomMember) {
      switch (user.role.name) {
        case MeetingRoles.kHost:
          subtitle.add(meetingUiLocalizations.participantHost);
          break;
        case MeetingRoles.kCohost:
          subtitle.add(meetingUiLocalizations.participantCoHost);
          break;
      }
    }
    if (getRoomContext().isMySelf(user.uuid)) {
      subtitle.add(meetingUiLocalizations.participantMe);
    }
    final subTitleTextStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.normal,
      color: _UIColors.color_999999,
      decoration: TextDecoration.none,
    );
    if (subtitle.isNotEmpty) {
      return Column(
        children: [
          Text(
            user.name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.normal,
              color: _UIColors.color_333333,
              decoration: TextDecoration.none,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '(${subtitle.join(',')})',
            style: subTitleTextStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
      );
    } else {
      return Text(
        user.name,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: _UIColors.color_333333,
            decoration: TextDecoration.none),
      );
    }
  }

  ///构建分割线
  Widget buildDivider({bool isShow = true}) {
    return Visibility(
      visible: isShow,
      child: Container(height: 1, color: _UIColors.globalBg),
    );
  }
}

/// 成为译员弹窗
class BeingAssignInterpreterTip extends StatelessWidget {
  final NEMeetingInterpreter? interpreter;

  BeingAssignInterpreterTip({super.key, required this.interpreter});

  @override
  Widget build(BuildContext context) {
    return NEMeetingUIKitLocalizationsScope(
        builder: (context, localizations, _) {
      return Dialog(
        backgroundColor: _UIColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 270,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  localizations.interpAssignInterpreter,
                  style: TextStyle(
                    color: _UIColors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              Text(
                localizations.interpAssignLanguage,
                style: TextStyle(
                  color: _UIColors.color_333333,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(child: buildLang(interpreter?.firstLang)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Icon(
                        NEMeetingIconFont.icon_switch,
                        size: 12,
                        color: _UIColors.greyCCCCCC,
                      ),
                    ),
                    Expanded(child: buildLang(interpreter?.secondLang)),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  localizations.interpAssignInterpreterTip,
                  style: TextStyle(
                    color: _UIColors.color_666666,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Divider(
                height: 1,
                color: _UIColors.greyCCCCCC,
              ),
              CupertinoDialogAction(
                child: Text(
                  localizations.globalSure,
                  style: TextStyle(
                    color: _UIColors.color_337eff,
                    fontSize: 17,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget buildLang(String? lang) {
    return Container(
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _UIColors.colorF2F3F5,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getLanguageNameByTag(lang) ?? '',
        style: TextStyle(
          color: _UIColors.color_333333,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// 会中同声传译事件处理
mixin InMeetingInterpretationManager<T extends StatefulWidget>
    on MeetingKitLocalizationsMixin<T>, NEInterpretationEventListener {
  NEInterpretationController? _interpretationController;
  NEInterpretationController get interpretationController {
    if (_interpretationController == null) {
      _interpretationController =
          Provider.of<MeetingUIState>(context, listen: false)
              .interpretationController;
      _interpretationController!.addEventListener(this);
    }
    return _interpretationController!;
  }

  /// 最小化时不展示相关弹窗
  bool get _shouldNotShowDialog {
    return !mounted ||
        Provider.of<MeetingUIState>(context, listen: false).isMinimized;
  }

  @override
  void dispose() {
    _interpretationController?.removeEventListener(this);
    super.dispose();
  }

  void onInterpreterLeaveMeeting(List<NEMeetingInterpreter> interpreters) {
    _interpreterInMeetingStatusChanged();
  }

  void onInterpreterJoinMeeting(List<NEMeetingInterpreter> interpreters) {
    _interpreterInMeetingStatusChanged();
  }

  bool _interpreterInMeetingStatusChangedDialogShowing = false;

  /// 提示译员参会状态变更
  void _interpreterInMeetingStatusChanged() async {
    if (_interpreterInMeetingStatusChangedDialogShowing || _shouldNotShowDialog)
      return;
    _interpreterInMeetingStatusChangedDialogShowing = true;
    final result =
        await MeetingNotificationManager.showNotificationBar(NotificationBar(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 94 + MediaQuery.of(context).padding.bottom,
      ),
      icon: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _UIColors.color_337eff,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          NEMeetingIconFont.icon_interpretation,
          color: _UIColors.white,
          size: 16,
        ),
      ),
      title: Builder(builder: (context) {
        return Text(context.meetingUiLocalizations.interpretation);
      }),
      content: Builder(builder: (context) {
        return Text(context
            .meetingUiLocalizations.interpInterpreterInMeetingStatusChanged);
      }),
      actions: [
        NotificationBarTextAction(
          text: Builder(builder: (context) {
            return Text(
              context.meetingUiLocalizations.interpSettings,
            );
          }),
        ),
      ],
    ))?.closed;
    _interpreterInMeetingStatusChangedDialogShowing = false;
    if (mounted && result?.isAction == true) {
      InMeetingInterpretationManagementPage.show(context);
    }
  }

  bool _interpreterOfflineDialogShowing = false;
  void onMyListenInterpreterOffline(String language) async {
    if (_interpreterOfflineDialogShowing || _shouldNotShowDialog) return;
    _interpreterOfflineDialogShowing = true;
    final willSwitchLanguage = await DialogUtils.showCommonDialog(
          context,
          meetingUiLocalizations.interpInterpreterOffline,
          null,
          () => Navigator.of(context).pop(),
          () => Navigator.of(context).pop(true),
          cancelText: meetingUiLocalizations.interpDontSwitch,
          acceptText: meetingUiLocalizations.interpSwitchToMajorAudio,
          contentWrapperBuilder: _autoPopIfInterpretationStopped,
        ) ==
        true;
    _interpreterOfflineDialogShowing = false;
    if (mounted &&
        willSwitchLanguage &&
        interpretationController.listenLanguage == language) {
      interpretationController.setListenLanguage(null);
    }
  }

  void onMyListenLanguageRemoved(String language, bool bySelf) async {
    if (!bySelf) {
      _showMyListenLanguageUnavailableDialog(meetingUiLocalizations
          .interpLanguageRemoved(_getLanguageNameByTag(language)!));
    }
  }

  bool _languageUnavailableDialogShowing = false;
  void _showMyListenLanguageUnavailableDialog(String title) async {
    if (_languageUnavailableDialogShowing || _shouldNotShowDialog) return;
    _languageUnavailableDialogShowing = true;
    final willGotoInterpretationPage = await DialogUtils.showCommonDialog(
          context,
          title,
          null,
          () => Navigator.of(context).pop(),
          () => Navigator.of(context).pop(true),
          cancelText: meetingUiLocalizations.globalGotIt,
          acceptText: meetingUiLocalizations.globalView,
          contentWrapperBuilder: _autoPopIfInterpretationStopped,
        ) ==
        true;
    _languageUnavailableDialogShowing = false;
    if (mounted &&
        willGotoInterpretationPage &&
        !MeetingInterpretationPage.isShowing) {
      MeetingInterpretationPage.show(context);
    }
  }

  void onInterpretationStartStateChanged(bool started, bool bySelf) {
    if (!bySelf) {
      /// 如果是译员，会弹窗提示成为译员，这里不用再进行 toast 提示
      if (started) {
        Timer.run(() {
          if (!interpretationController.isMySelfInterpreter()) {
            showToast(meetingUiLocalizations.interpStartNotification);
          } else {
            checkAndShowBeingInterpreter();
          }
        });
      } else if (!started) {
        showToast(meetingUiLocalizations.interpStopNotification);
      }
    }
  }

  void onMyListeningLanguageDisconnect(String lang, int reason) {
    showToast(meetingUiLocalizations.interpListeningChannelDisconnect);
  }

  void onMySpeakingLanguageDisconnect(String lang, int reason) {
    showToast(meetingUiLocalizations.interpSpeakingChannelDisconnect);
  }

  void onMyInterpreterChanged(
      NEMeetingInterpreter? myInterpreter, bool bySelf) {
    if (!bySelf) {
      if (myInterpreter == null) {
        if (_shouldNotShowDialog) return;
        DialogUtils.showOneButtonCommonDialog(
          context,
          meetingUiLocalizations.interpUnassignInterpreter,
          null,
          null,
          contentWrapperBuilder: _autoPopIfInterpretationStopped,
          acceptText: meetingUiLocalizations.globalSure,
        );
      } else {
        checkAndShowBeingInterpreter();
      }
    }
  }

  bool _isBeingInterpreterDialogShowing = false;

  /// 检查并展示"您已成为本场会议的同传译员"弹窗
  void checkAndShowBeingInterpreter() async {
    if (mounted &&
        interpretationController.isMySelfInterpreter() &&
        interpretationController.isInterpretationStarted()) {
      if (_isBeingInterpreterDialogShowing || _shouldNotShowDialog) return;
      _isBeingInterpreterDialogShowing = true;
      await showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: false,
        routeSettings: RouteSettings(name: 'InMeetingBeingInterpreter'),
        builder: (_) {
          return ListenableBuilder(
              listenable: interpretationController,
              builder: (context, _) {
                return AutoPopScope(
                  listenable: ValueNotifier(
                      !interpretationController.isInterpretationStarted() ||
                          !interpretationController.isMySelfInterpreter()),
                  child: BeingAssignInterpreterTip(
                    interpreter:
                        interpretationController.getMySelfInterpreter(),
                  ),
                );
              });
        },
      );
      _isBeingInterpreterDialogShowing = false;
    }
  }

  Widget _autoPopIfInterpretationStopped(Widget child) {
    return ListenableBuilder(
      listenable: interpretationController,
      builder: (context, child) {
        return AutoPopScope(
          listenable: ValueNotifier(
              !interpretationController.isInterpretationStarted()),
          child: child,
        );
      },
      child: child,
    );
  }
}
