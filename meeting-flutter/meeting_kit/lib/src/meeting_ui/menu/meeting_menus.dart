// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

typedef MenuItemClickCallback = void Function(NEMenuClickInfo clickInfo);

typedef MenuItemTipBuilder = Widget Function(
    BuildContext context, Widget anchor);

typedef MenuItemIconBuilder = Widget Function(
    BuildContext context, NEMenuItemState state);

/// 内部使用，50-99
class InternalMenuIDs {
  /// 更多菜单
  static const int more = 50;

  static const int cancel = 51;

  static const int leaveMeeting = 52;

  static const int closeMeeting = 53;

  /// 美颜菜单
  static const int beauty = 54;

  /// 直播菜单
  static const int live = 55;

  /// 切换视图菜单
  static const int switchShowType = 56;

  /// sip
  static const int sip = 57;

  /// 虚拟背景
  static const int virtualBackground = 58;

  /// 同声传译
  static const int interpretation = 59;

  /// 字幕菜单
  static const int captions = 60;

  /// 转写菜单
  static const int transcription = 61;
}

class InternalMenuItems {
  /// 动态菜单按钮
  /// 需要在"更多"菜单中优先展示
  static final List<NEMeetingMenuItem> dynamicFeatureMenuItemList = [
    beauty,
    live,
    virtualBackground,
    transcription,
    captions,
    interpretation,
  ];

  /// 更多菜单
  static final more = NESingleStateMenuItem(
    itemId: InternalMenuIDs.more,
    visibility: NEMenuVisibility.visibleAlways,
    singleStateItem: NEMenuItemInfo.undefine,
  );

  /// 美颜菜单
  static final beauty = NESingleStateMenuItem(
    itemId: InternalMenuIDs.beauty,
    visibility: NEMenuVisibility.visibleAlways,
    singleStateItem: NEMenuItemInfo.undefine,
  );

  /// 直播菜单
  static final live = NESingleStateMenuItem(
    itemId: InternalMenuIDs.live,
    visibility: NEMenuVisibility.visibleToHostOnly,
    singleStateItem: NEMenuItemInfo.undefine,
  );

  static final sip = NESingleStateMenuItem(
    itemId: InternalMenuIDs.sip,
    visibility: NEMenuVisibility.visibleAlways,
    singleStateItem: NEMenuItemInfo(text: 'SIP'),
  );

  static final virtualBackground = NESingleStateMenuItem(
    itemId: InternalMenuIDs.virtualBackground,
    visibility: NEMenuVisibility.visibleAlways,
    singleStateItem: NEMenuItemInfo.undefine,
  );

  static final captions = NECheckableMenuItem(
    itemId: InternalMenuIDs.captions,
    visibility: NEMenuVisibility.visibleAlways,
    uncheckStateItem: NEMenuItemInfo.undefine,
    checkedStateItem: NEMenuItemInfo.undefine,
  );

  static final transcription = NESingleStateMenuItem(
    itemId: InternalMenuIDs.transcription,
    visibility: NEMenuVisibility.visibleAlways,
    singleStateItem: NEMenuItemInfo.undefine,
  );

  static final interpretation = NESingleStateMenuItem(
    itemId: InternalMenuIDs.interpretation,
    visibility: NEMenuVisibility.visibleAlways,
    singleStateItem: NEMenuItemInfo.undefine,
  );
}

abstract class MenuStateController<T> extends ValueNotifier<T> {
  final ValueListenable? listenTo;

  int _transitionVersion = 0;

  MenuStateController({
    required T initialState,
    this.listenTo,
  }) : super(initialState) {
    listenTo?.addListener(moveState);
  }

  void didStateTransition(Future<bool>? transitionController) {
    if (transitionController != null) {
      final ver = generateTransitionVersion();
      transitionController.then((bool didTransition) {
        if (didTransition && ver == _transitionVersion) {
          moveState();
        }
      });
    }
  }

  int generateTransitionVersion() {
    return ++_transitionVersion;
  }

  void moveState();

  void moveStateTo(T state);
}

class CyclicStateListController extends MenuStateController<NEMenuItemState> {
  final List<NEMenuItemState> stateList;

  late int _currentIndex;

  CyclicStateListController(
      {required this.stateList,
      required NEMenuItemState initialState,
      ValueListenable? listenTo})
      : assert(stateList.isNotEmpty),
        assert(Set.from(stateList).length == stateList.length),
        assert(stateList.contains(initialState)),
        super(
          initialState: initialState,
          listenTo: listenTo,
        ) {
    _currentIndex = stateList.indexOf(initialState);
    value = initialState;
  }

  @override
  void moveState() {
    generateTransitionVersion();
    _currentIndex = (_currentIndex + 1) % stateList.length;
    value = stateList[_currentIndex];
  }

  @override
  void moveStateTo(NEMenuItemState state) {
    final index = stateList.indexOf(state);
    if (index >= 0) {
      generateTransitionVersion();
      _currentIndex = index;
      value = state;
    }
  }
}

final int _uncheckState = NEMenuItemStates.getState([NEMenuItemState.uncheck]);
final int _checkState = NEMenuItemStates.getState([NEMenuItemState.checked]);
final int _noneState = NEMenuItemStates.getState([NEMenuItemState.none]);

final _builtinMenuItemIcons = <int, Map<int, (IconData, Color)>>{
  NEMenuIDs.microphone: {
    _uncheckState: (
      NEMeetingIconFont.icon_yx_tv_voice_onx,
      _UIColors.colorECEDEF
    ),
    _checkState: (
      NEMeetingIconFont.icon_yx_tv_voice_offx,
      _UIColors.colorFE3B30
    ),
  },
  NEMenuIDs.camera: {
    _uncheckState: (
      NEMeetingIconFont.icon_yx_tv_video_onx,
      _UIColors.colorECEDEF
    ),
    _checkState: (
      NEMeetingIconFont.icon_yx_tv_video_offx,
      _UIColors.colorFE3B30
    ),
  },
  NEMenuIDs.screenShare: {
    _uncheckState: (
      NEMeetingIconFont.icon_yx_tv_sharescreen,
      _UIColors.colorECEDEF
    ),
    _checkState: (
      NEMeetingIconFont.icon_yx_tv_sharescreen,
      _UIColors.blue_337eff
    ),
  },
  NEMenuIDs.participants: {
    _noneState: (NEMeetingIconFont.icon_yx_tv_attendeex, _UIColors.colorECEDEF),
  },
  NEMenuIDs.managerParticipants: {
    _noneState: (NEMeetingIconFont.icon_yx_tv_attendeex, _UIColors.colorECEDEF),
  },
  NEMenuIDs.chatroom: {
    _noneState: (NEMeetingIconFont.icon_chat, _UIColors.colorECEDEF),
  },
  NEMenuIDs.invitation: {
    _noneState: (NEMeetingIconFont.icon_yx_tv_invitex, _UIColors.colorECEDEF),
  },
  InternalMenuIDs.more: {
    _noneState: (Icons.more_horiz, _UIColors.colorECEDEF),
  },
  InternalMenuIDs.beauty: {
    _noneState: (NEMeetingIconFont.icon_beauty1x, _UIColors.colorECEDEF),
  },
  InternalMenuIDs.live: {
    _noneState: (NEMeetingIconFont.icon_live, _UIColors.colorECEDEF),
  },
  NEMenuIDs.whiteBoard: {
    _uncheckState: (NEMeetingIconFont.icon_whiteboard, _UIColors.colorECEDEF),
    _checkState: (NEMeetingIconFont.icon_whiteboard, _UIColors.blue_337eff),
  },
  InternalMenuIDs.sip: {
    _noneState: (NEMeetingIconFont.icon_sip, _UIColors.colorECEDEF),
  },
  InternalMenuIDs.virtualBackground: {
    _noneState: (
      NEMeetingIconFont.icon_virtual_background,
      _UIColors.colorECEDEF
    ),
  },
  InternalMenuIDs.captions: {
    _uncheckState: (NEMeetingIconFont.icon_captions, _UIColors.colorECEDEF),
    _checkState: (NEMeetingIconFont.icon_captions, _UIColors.colorECEDEF),
  },
  InternalMenuIDs.transcription: {
    _noneState: (NEMeetingIconFont.icon_transcription, _UIColors.colorECEDEF),
  },
  InternalMenuIDs.interpretation: {
    _noneState: (NEMeetingIconFont.icon_interpretation, _UIColors.colorECEDEF),
  },
  NEMenuIDs.cloudRecord: {
    _uncheckState: (
      NEMeetingIconFont.icon_cloud_record_start,
      _UIColors.colorECEDEF
    ),
    _checkState: (
      NEMeetingIconFont.icon_cloud_record_stop,
      _UIColors.colorFE3B30
    ),
  },
  NEMenuIDs.security: {
    _noneState: (NEMeetingIconFont.icon_security, _UIColors.colorECEDEF),
  },
  NEMenuIDs.sipCall: {
    _noneState: (NEMeetingIconFont.icon_call_out, _UIColors.colorECEDEF),
  },
  NEMenuIDs.settings: {
    _noneState: (NEMeetingIconFont.icon_setting, _UIColors.colorECEDEF),
  },
  NEMenuIDs.notifyCenter: {
    _noneState: (NEMeetingIconFont.icon_notify, _UIColors.colorECEDEF),
  },
  NEMenuIDs.disconnectAudio: {
    _uncheckState: (NEMeetingIconFont.icon_disconnect, _UIColors.colorECEDEF),
    _checkState: (NEMeetingIconFont.icon_reconnect, _UIColors.colorFE3B30),
  },
  NEMenuIDs.feedback: {
    _noneState: (NEMeetingIconFont.icon_feedback, _UIColors.colorECEDEF),
  },
};

Icon? _useBuiltinIconById(int id, int state, double size) {
  final iconData = _builtinMenuItemIcons[id];
  if (iconData is Map) {
    final data = iconData![state];
    if (data != null) {
      return Icon(data.$1, size: size, color: data.$2);
    }
  }
  return null;
}

class SingleStateMenuItem extends StatelessWidget {
  final NESingleStateMenuItem menuItem;
  final MenuItemClickCallback callback;
  final MenuItemTipBuilder? tipBuilder;
  final MenuItemIconBuilder? iconBuilder;
  final bool isMoreMenuItem;
  final double? iconSize;

  SingleStateMenuItem({
    Key? key,
    required this.menuItem,
    this.tipBuilder,
    required this.callback,
    this.iconBuilder,
    required this.isMoreMenuItem,
    this.iconSize,
  }) : super(key: key ?? ValueKey(menuItem.itemId));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => callback.call(NEMenuClickInfo(menuItem.itemId)),
      child: MenuItemInfo(
        itemId: menuItem.itemId,
        itemInfo: menuItem.singleStateItem,
        itemState: NEMenuItemState.none,
        tipBuilder: tipBuilder,
        iconBuilder: iconBuilder,
        isMoreMenuItem: isMoreMenuItem,
        iconSize: iconSize,
      ),
    );
  }
}

class CheckableMenuItem extends StatelessWidget {
  final NECheckableMenuItem menuItem;
  final MenuItemClickCallback? callback;
  final CyclicStateListController controller;
  final MenuItemTipBuilder? tipBuilder;
  final MenuItemIconBuilder? iconBuilder;
  final bool isMoreMenuItem;
  final double? iconSize;

  CheckableMenuItem({
    Key? key,
    required this.menuItem,
    required this.controller,
    this.callback,
    this.tipBuilder,
    this.iconBuilder,
    required this.isMoreMenuItem,
    this.iconSize,
  }) : super(key: key ?? ValueKey(menuItem.itemId));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => callback?.call(NEStatefulMenuClickInfo(
          itemId: menuItem.itemId,
          state: NEMenuItemStates.getState([controller.value]))),
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (BuildContext context, NEMenuItemState state, Widget? child) {
          final _state = NEMenuItemStates.getState([state]);
          final checked = NEMenuItemStates.isChecked(_state);
          return MenuItemInfo(
            itemId: menuItem.itemId,
            itemInfo:
                checked ? menuItem.checkedStateItem : menuItem.uncheckStateItem,
            itemState: state,
            tipBuilder: tipBuilder,
            iconBuilder: iconBuilder,
            isMoreMenuItem: isMoreMenuItem,
            iconSize: iconSize,
          );
        },
      ),
    );
  }
}

class MenuItemInfo extends StatelessWidget {
  final int itemId;
  final NEMenuItemInfo itemInfo;
  final NEMenuItemState itemState;
  final MenuItemTipBuilder? tipBuilder;
  final MenuItemIconBuilder? iconBuilder;
  final bool isMoreMenuItem;
  final double? iconSize;

  MenuItemInfo({
    required this.itemId,
    required this.itemInfo,
    required this.itemState,
    required this.isMoreMenuItem,
    this.tipBuilder,
    this.iconBuilder,
    this.iconSize,
  });

  final double _defaultIconSize = 28.0;
  double get size => iconSize ?? _defaultIconSize;

  @override
  Widget build(BuildContext context) {
    Widget? icon;
    if (iconBuilder != null) {
      icon = iconBuilder!.call(context, itemState);
    } else {
      icon = !itemInfo.hasIcon
          ? _useBuiltinIconById(
              itemId, NEMenuItemStates.getState([itemState]), size)
          : Image(
              image: getImage(itemInfo),
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.warning,
                  color: Colors.redAccent,
                );
              },
            );
    }
    icon = Container(
      width: size,
      height: size,
      child: icon,
    );
    final menuWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        tipBuilder?.call(context, icon) ?? icon,
        SizedBox(height: 2),
        Padding(
          padding: EdgeInsets.only(left: 4, right: 4),
          child: Text(
            _getMenuTitle(context, itemInfo, itemState),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
            style: TextStyle(
              color: _UIColors.white,
              fontSize: 12,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w400,
            ),
          ),
        )
      ],
    );
    return isMoreMenuItem
        ? Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: menuWidget,
          )
        : menuWidget;
  }

  ImageProvider getImage(NEMenuItemInfo itemInfo) {
    if (itemInfo.isNetworkImage) {
      return NetworkImage(itemInfo.icon!);
    }
    if (itemInfo.hasPlatformPackage) {
      ///当是 '/'表示flutter是根目录，无需添加packages
      return AssetImage(itemInfo.icon!,
          package: itemInfo.platformPackage == '/'
              ? null
              : itemInfo.platformPackage);
    }
    return PlatformImage(key: itemInfo.icon ?? '');
  }

  String _getMenuTitle(BuildContext context, NEMenuItemInfo itemInfo,
      NEMenuItemState itemState) {
    if (!itemInfo.isValid) {
      return _getDefaultMenuTitle(context, itemId, itemState) ?? '';
    }
    return (itemInfo.textGetter?.call(context) ?? itemInfo.text)!.trim();
  }
}

String? _getDefaultMenuTitle(
    BuildContext context, int itemId, NEMenuItemState itemState) {
  final localizations = NEMeetingUIKitLocalizations.of(context);
  final bool checked = itemState == NEMenuItemState.checked;
  switch (itemId) {
    case NEMenuIDs.microphone:
      return checked
          ? localizations!.participantUnmute
          : localizations!.participantMute;
    case NEMenuIDs.camera:
      return checked
          ? localizations!.participantStartVideo
          : localizations!.participantStopVideo;
    case NEMenuIDs.screenShare:
      return checked
          ? localizations!.screenShareStop
          : localizations!.screenShare;
    case NEMenuIDs.participants:
      return localizations!.participants;
    case NEMenuIDs.managerParticipants:
      return localizations!.participantsManager;
    case NEMenuIDs.invitation:
      return localizations!.meetingInvite;
    case NEMenuIDs.chatroom:
      return localizations!.chat;
    case NEMenuIDs.whiteBoard:
      return checked
          ? localizations!.whiteBoardClose
          : localizations!.whiteboardShare;
    case NEMenuIDs.cloudRecord:
      return checked
          ? localizations!.cloudRecordingStop
          : localizations!.cloudRecordingStart;
    case NEMenuIDs.security:
      return localizations!.meetingSecurity;
    case NEMenuIDs.sipCall:
      return localizations!.sipCall;
    case NEMenuIDs.settings:
      return localizations!.settings;
    case NEMenuIDs.notifyCenter:
      return localizations!.globalNotify;
    case InternalMenuIDs.more:
      return localizations!.meetingMore;
    case InternalMenuIDs.beauty:
      return localizations!.meetingBeauty;
    case InternalMenuIDs.live:
      return localizations!.live;
    case InternalMenuIDs.virtualBackground:
      return localizations!.virtualBackground;
    case InternalMenuIDs.interpretation:
      return localizations!.interpretation;
    case InternalMenuIDs.captions:
      return checked
          ? localizations!.transcriptionDisableCaption
          : localizations!.transcriptionEnableCaption;
    case InternalMenuIDs.transcription:
      return localizations!.transcription;
    case NEMenuIDs.disconnectAudio:
      return checked
          ? localizations!.meetingReconnectAudio
          : localizations!.meetingDisconnectAudio;
    case NEMenuIDs.feedback:
      return localizations!.feedbackInRoom;
  }
  return null;
}
