// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingSettingPage extends StatefulWidget {
  static const String routeName = '/meetingSetting';
  final Function(ValueKey switchKey, bool value)? onSwitchChanged;

  const MeetingSettingPage({Key? key, this.onSwitchChanged}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MeetingSettingState(onSwitchChanged: onSwitchChanged);
  }
}

class MeetingSettingState extends LifecycleBaseState<StatefulWidget>
    with MeetingStateScope, _AloggerMixin {
  final settings = NEMeetingKit.instance.getSettingsService();
  final Function(ValueKey switchKey, bool value)? onSwitchChanged;

  MeetingSettingState({this.onSwitchChanged});

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
    final settingAudioItems = getSettingAudioItems();
    final settingVideoItems = getSettingVideoItems();
    final settingCommonItems = getSettingCommonItems();
    return SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (settingAudioItems.isNotEmpty)
              MeetingSettingGroup(
                title: NEMeetingUIKit.instance
                    .getUIKitLocalizations()
                    .settingAudio,
                iconData: NEMeetingIconFont.icon_audio,
                iconColor: _UIColors.color1BB650,
                children: settingAudioItems,
              ),
            if (settingVideoItems.isNotEmpty)
              MeetingSettingGroup(
                title: NEMeetingUIKit.instance
                    .getUIKitLocalizations()
                    .settingVideo,
                iconData: NEMeetingIconFont.icon_camera,
                iconColor: _UIColors.color1BB650,
                children: getSettingVideoItems(),
              ),
            if (settingCommonItems.isNotEmpty)
              MeetingSettingGroup(
                title: NEMeetingUIKit.instance
                    .getUIKitLocalizations()
                    .settingCommon,
                iconData: NEMeetingIconFont.icon_settings,
                iconColor: _UIColors.color8D90A0,
                children: getSettingCommonItems(),
              ),
            SizedBox(height: 16),
          ]),
    );
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

  /// 通用模块
  List<MeetingSwitchItem> getSettingCommonItems() {
    return [
      buildMeetTimeItem(),
      buildWhiteboardTransparent(),
    ];
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
      key: key,
      title: label,
      valueNotifier: valueNotifier,
      content: content,
      onChanged: (value) {
        onDataChanged(value);
        onSwitchChanged?.call(key, value);
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
}
