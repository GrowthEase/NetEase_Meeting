// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingSettingPage extends StatefulWidget {
  static const String routeName = '/meetingSetting';
  final Function(ValueKey switchKey, dynamic value)? onItemValueChanged;
  final ValueListenable<bool> isMySelfManagerListenable;
  final NERoomContext roomContext;

  const MeetingSettingPage(
      {Key? key,
      this.onItemValueChanged,
      required this.roomContext,
      required this.isMySelfManagerListenable})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MeetingSettingState(
        onItemValueChanged: onItemValueChanged,
        roomContext: roomContext,
        isMySelfManagerListenable: isMySelfManagerListenable);
  }
}

class MeetingSettingState extends LifecycleBaseState<StatefulWidget>
    with MeetingStateScope, _AloggerMixin {
  final settings = SettingsRepository();
  final NERoomContext roomContext;
  final Function(ValueKey switchKey, dynamic value)? onItemValueChanged;
  final ValueListenable<bool> isMySelfManagerListenable;

  MeetingSettingState(
      {this.onItemValueChanged,
      required this.roomContext,
      required this.isMySelfManagerListenable});

  final _notificationType = ValueNotifier<NEChatMessageNotificationType>(
      NEChatMessageNotificationType.barrage);

  @override
  void initState() {
    super.initState();
    SettingsRepository().getChatMessageNotificationType().then((value) {
      _notificationType.value = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _UIColors.globalBg,
      appBar: buildAppbar(),
      body: buildBody(),
    );
  }

  PreferredSizeWidget? buildAppbar() {
    return TitleBar(
      title: TitleBarTitle(
          NEMeetingUIKit.instance.getUIKitLocalizations().settings),
    );
  }

  Widget buildBody() {
    final settingMemberJoinItems = getSettingMemberJoinItems();
    final settingAudioItems = getSettingAudioItems();
    final settingVideoItems = getSettingVideoItems();
    final settingChatItems = getSettingChatItems();
    final settingCommonItems = getSettingCommonItems();
    return SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (settingMemberJoinItems.isNotEmpty)
              ValueListenableBuilder(
                valueListenable: isMySelfManagerListenable,
                builder: (context, value, child) {
                  return Visibility(
                      visible: value,
                      child: MeetingCard(
                        title: NEMeetingUIKit.instance
                            .getUIKitLocalizations()
                            .joinMeetingSettings,
                        iconData: NEMeetingIconFont.icon_info,
                        iconColor: _UIColors.blue_337eff,
                        children: settingMemberJoinItems,
                      ));
                },
              ),
            if (settingAudioItems.isNotEmpty)
              MeetingCard(
                title: NEMeetingUIKit.instance
                    .getUIKitLocalizations()
                    .settingAudio,
                iconData: NEMeetingIconFont.icon_audio,
                iconColor: _UIColors.color1BB650,
                children: settingAudioItems,
              ),
            if (settingVideoItems.isNotEmpty)
              MeetingCard(
                title: NEMeetingUIKit.instance
                    .getUIKitLocalizations()
                    .settingVideo,
                iconData: NEMeetingIconFont.icon_camera,
                iconColor: _UIColors.color1BB650,
                children: getSettingVideoItems(),
              ),
            if (settingChatItems.isNotEmpty)
              MeetingCard(
                title: NEMeetingUIKit.instance.getUIKitLocalizations().chat,
                iconData: NEMeetingIconFont.icon_chat,
                iconColor: _UIColors.color_337eff,
                children: getSettingChatItems(),
              ),
            if (settingCommonItems.isNotEmpty)
              MeetingCard(
                title: NEMeetingUIKit.instance
                    .getUIKitLocalizations()
                    .settingCommon,
                iconData: NEMeetingIconFont.icon_settings,
                iconColor: _UIColors.color8D90A0,
                children: getSettingCommonItems(),
              ),
            SizedBox(height: 16 + MediaQuery.of(context).padding.bottom),
          ]),
    );
  }

  /// 入会设置模块
  List<MeetingSwitchItem> getSettingMemberJoinItems() {
    return [
      // 入会自动静音功能这期不上
      // buildMemberJoinWithMute(),
      buildRingWhenMemberJoinOrLeave(),
    ];
  }

  /// 音频模块
  List<MeetingSwitchItem> getSettingAudioItems() {
    return [
      buildAudioAINS(),
      buildSpeakerSpotlight(),
    ];
  }

  /// 视频模块
  List<MeetingSwitchItem> getSettingVideoItems() {
    return [
      buildFrontCameraMirror(),
    ];
  }

  /// 聊天模块
  List<Widget> getSettingChatItems() {
    return [
      if (settings.isMeetingChatSupported()) buildChatMessageNotification(),
    ];
  }

  /// 通用模块
  List<Widget> getSettingCommonItems() {
    return [
      buildMeetTimeItem(),
      buildWhiteboardTransparent(),
      buildNotYetJoinSettings(),
      buildCaptionsSettings(),
      buildShowNameInVideo(),
    ];
  }

  /// 成员入会时自动静音
  MeetingSwitchItem buildMemberJoinWithMute() {
    return buildSwitchItem(
        key: MeetingUIValueKeys.memberJoinWithMute,
        label:
            NEMeetingUIKit.instance.getUIKitLocalizations().memberJoinWithMute,
        asyncData: Future.value(roomContext.isAllAudioMuted),
        onDataChanged: (value) {
          if (value) {
            roomContext.rtcController.muteAllParticipantsAudio(
                roomContext.isUnmuteAudioBySelfEnabled);
          } else {
            roomContext.rtcController.unmuteAllParticipantsAudio();
          }
        });
  }

  /// 成员入会或离会事播放提示音
  MeetingSwitchItem buildRingWhenMemberJoinOrLeave() {
    return buildSwitchItem(
        key: MeetingUIValueKeys.ringWhenMemberJoinOrLeave,
        label: NEMeetingUIKit.instance
            .getUIKitLocalizations()
            .ringWhenMemberJoinOrLeave,
        asyncData: Future.value(roomContext.canPlayRing),
        onDataChanged: (value) {
          roomContext.updatePlaySound(value);
        });
  }

  /// 构建音频智能降噪选项
  MeetingSwitchItem buildAudioAINS() {
    return buildSwitchItem(
      key: MeetingUIValueKeys.audioAINS,
      label: NEMeetingUIKit.instance.getUIKitLocalizations().settingAudioAINS,
      asyncData: settings.isAudioAINSEnabled(),
      onDataChanged: (value) => settings.enableAudioAINS(value),
    );
  }

  /// 构建语音激励选项
  MeetingSwitchItem buildSpeakerSpotlight() {
    return buildSwitchItem(
        key: MeetingUIValueKeys.enableSpeakerSpotlight,
        label: NEMeetingUIKit.instance
            .getUIKitLocalizations()
            .settingSpeakerSpotlight,
        content: NEMeetingUIKit.instance
            .getUIKitLocalizations()
            .settingSpeakerSpotlightTip,
        asyncData: settings.isSpeakerSpotlightEnabled(),
        onDataChanged: (value) {
          settings.enableSpeakerSpotlight(value);
        });
  }

  /// 前置摄像头镜像
  MeetingSwitchItem buildFrontCameraMirror() {
    return buildSwitchItem(
      key: MeetingUIValueKeys.enableFrontCameraMirror,
      label: NEMeetingUIKit.instance
          .getUIKitLocalizations()
          .settingEnableFrontCameraMirror,
      asyncData: settings.isFrontCameraMirrorEnabled(),
      onDataChanged: settings.enableFrontCameraMirror,
    );
  }

  /// 新消息提醒
  Widget buildChatMessageNotification() {
    return ValueListenableBuilder(
        valueListenable: _notificationType,
        builder: (context, value, _) {
          return MeetingArrowItem(
              key: MeetingUIValueKeys.chatMessageNotification,
              title: NEMeetingUIKit.instance
                  .getUIKitLocalizations()
                  .settingChatMessageNotification,
              content: getNotificationTypeText(value),
              onTap: showNotificationTypeDialog);
        });
  }

  NEMeetingUIKitLocalizations get localizations =>
      NEMeetingUIKit.instance.getUIKitLocalizations();

  String getNotificationTypeText(NEChatMessageNotificationType type) {
    switch (type) {
      case NEChatMessageNotificationType.barrage:
        return localizations.settingChatMessageNotificationBarrage;
      case NEChatMessageNotificationType.bubble:
        return localizations.settingChatMessageNotificationBubble;
      case NEChatMessageNotificationType.noRemind:
        return localizations.settingChatMessageNotificationNoReminder;
    }
  }

  void showNotificationTypeDialog() {
    BottomSheetUtils.showMeetingBottomDialog(
        buildContext: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildNotificationCheckItem(
              title: localizations.settingChatMessageNotificationBarrage,
              type: NEChatMessageNotificationType.barrage,
            ),
            buildNotificationCheckItem(
              title: localizations.settingChatMessageNotificationBubble,
              type: NEChatMessageNotificationType.bubble,
            ),
            buildNotificationCheckItem(
              title: localizations.settingChatMessageNotificationNoReminder,
              type: NEChatMessageNotificationType.noRemind,
            ),
          ],
        ));
  }

  Widget buildNotificationCheckItem(
      {required String title, required NEChatMessageNotificationType type}) {
    return MeetingCheckItem(
      title: title,
      isSelected: _notificationType.value == type,
      onTap: () {
        _notificationType.value = type;
        onItemValueChanged?.call(
            MeetingUIValueKeys.chatMessageNotification, type);
        SettingsRepository().setChatMessageNotificationType(type);
        Navigator.of(context).pop();
      },
    );
  }

  /// 通用开关选项
  MeetingSwitchItem buildSwitchItem({
    required ValueKey<String> key,
    required String label,
    required Future<bool> asyncData,
    required ValueChanged<bool> onDataChanged,
    String? content,
  }) {
    final valueNotifier = ValueNotifier<bool>(false);
    asyncData.then((value) {
      valueNotifier.value = value;
    });
    return MeetingSwitchItem(
      switchKey: key,
      title: label,
      valueNotifier: valueNotifier,
      content: content,
      onChanged: (value) {
        onDataChanged(value);
        onItemValueChanged?.call(key, value);
        valueNotifier.value = value;
      },
    );
  }

  /// 白板透明
  MeetingSwitchItem buildWhiteboardTransparent() {
    return buildSwitchItem(
      key: MeetingUIValueKeys.enableTransparentWhiteboard,
      label: NEMeetingUIKit.instance
          .getUIKitLocalizations()
          .settingEnableTransparentWhiteboard,
      asyncData: settings.isTransparentWhiteboardEnabled(),
      onDataChanged: settings.enableTransparentWhiteboard,
    );
  }

  /// 显示会议持续事件
  MeetingSwitchItem buildMeetTimeItem() {
    return buildSwitchItem(
      key: MeetingUIValueKeys.openShowMeetTime,
      label: NEMeetingUIKit.instance
          .getUIKitLocalizations()
          .settingShowMeetDuration,
      asyncData: settings.isShowMyMeetingElapseTimeEnabled(),
      onDataChanged: (value) => settings.enableShowMyMeetingElapseTime(value),
    );
  }

  /// 字幕设置
  Widget buildCaptionsSettings() {
    return NEMeetingKitFeatureConfig(
        config: meetingUIState.sdkConfig,
        builder: (context, _) {
          if (!context.isCaptionsSupported ||
              meetingUIState.meetingArguments.options.noCaptions)
            return SizedBox.shrink();
          return MeetingArrowItem(
            title: NEMeetingUIKit.instance
                .getUIKitLocalizations()
                .transcriptionCaptionSettings,
            onTap: () => MeetingCaptionsSettingsPage.show(context),
          );
        });
  }

  /// 视频画面是否显示名字
  Widget buildShowNameInVideo() {
    return buildSwitchItem(
      key: MeetingUIValueKeys.enableShowNameInVideo,
      label: NEMeetingUIKit.instance.getUIKitLocalizations().settingShowName,
      asyncData: settings.isShowNameInVideoEnabled(),
      onDataChanged: (value) => settings.enableShowNameInVideo(value),
    );
  }

  /// 隐藏未入会成员设置
  Widget buildNotYetJoinSettings() {
    return buildSwitchItem(
      key: MeetingUIValueKeys.showNotYetJoinedMembers,
      label: NEMeetingUIKit.instance
          .getUIKitLocalizations()
          .settingHideNotYetJoinedMembers,
      asyncData:
          settings.isShowNotYetJoinedMembersEnabled().then((value) => !value),
      onDataChanged: (value) => settings.enableShowNotYetJoinedMembers(!value),
    );
  }
}
