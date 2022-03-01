// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

typedef MenuItemClickCallback = void Function(NEMenuClickInfo clickInfo);

typedef MenuItemTipBuilder = Widget Function(BuildContext context, Widget anchor);

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
}

class InternalMenuItems {
  /// 动态菜单按钮
  /// 需要在"更多"菜单中优先展示
  static const List<NEMeetingMenuItem> dynamicFeatureMenuItemList = [
    beauty,
    live,
  ];

  /// 更多菜单
  static const more = NESingleStateMenuItem(
    itemId: InternalMenuIDs.more,
    visibility: NEMenuVisibility.visibleAlways,
    singleStateItem: NEMenuItemInfo(Strings.more),
  );

  /// 美颜菜单
  static const beauty = NESingleStateMenuItem(
    itemId: InternalMenuIDs.beauty,
    visibility: NEMenuVisibility.visibleAlways,
    singleStateItem: NEMenuItemInfo(Strings.beauty),
  );

  /// 直播菜单
  static const live = NESingleStateMenuItem(
    itemId: InternalMenuIDs.live,
    visibility: NEMenuVisibility.visibleToHostOnly,
    singleStateItem: NEMenuItemInfo(Strings.live),
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
      final ver = ++_transitionVersion;
      transitionController.then((bool didTransition) {
        if (didTransition && ver == _transitionVersion) {
          moveState();
        }
      });
    }
  }

  void moveState();
}

class CyclicStateListController extends MenuStateController<NEMenuItemState> {
  final List<NEMenuItemState> stateList;

  late int _currentIndex;

  CyclicStateListController({required this.stateList, required NEMenuItemState initialState, ValueListenable? listenTo})
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
    _currentIndex = (_currentIndex + 1) % stateList.length;
    value = stateList[_currentIndex];
  }
}

final int _uncheckState = NEMenuItemStates.getState([NEMenuItemState.uncheck]);
final int _checkState = NEMenuItemStates.getState([NEMenuItemState.checked]);
final int _noneState = NEMenuItemStates.getState([NEMenuItemState.none]);

final _builtinMenuItemIcons = <int, Map<int, Icon>>{
  NEMenuIDs.microphone: {
    _uncheckState: const Icon(NEMeetingIconFont.icon_yx_tv_voice_onx, color: UIColors.colorECEDEF),
    _checkState: const Icon(NEMeetingIconFont.icon_yx_tv_voice_offx, color: UIColors.colorFE3B30),
  },
  NEMenuIDs.camera: {
    _uncheckState: const Icon(NEMeetingIconFont.icon_yx_tv_video_onx, color: UIColors.colorECEDEF),
    _checkState: const Icon(NEMeetingIconFont.icon_yx_tv_video_offx, color: UIColors.colorFE3B30),
  },
  NEMenuIDs.screenShare: {
    _uncheckState: const Icon(NEMeetingIconFont.icon_yx_tv_sharescreen, color: UIColors.colorECEDEF),
    _checkState: const Icon(NEMeetingIconFont.icon_yx_tv_sharescreen, color: UIColors.blue_337eff),
  },
  NEMenuIDs.participants: {
    _noneState: const Icon(NEMeetingIconFont.icon_yx_tv_attendeex, color: UIColors.colorECEDEF),
  },
  NEMenuIDs.managerParticipants: {
    _noneState: const Icon(NEMeetingIconFont.icon_yx_tv_attendeex, color: UIColors.colorECEDEF),
  },
  NEMenuIDs.chatroom: {
    _noneState: const Icon(NEMeetingIconFont.icon_chat, color: UIColors.colorECEDEF),
  },
  NEMenuIDs.invitation: {
    _noneState: const Icon(NEMeetingIconFont.icon_yx_tv_invitex, color: UIColors.colorECEDEF),
  },
  InternalMenuIDs.more: {
    _noneState: const Icon(Icons.more_horiz, color: UIColors.colorECEDEF),
  },
  InternalMenuIDs.beauty: {
    _noneState: const Icon(NEMeetingIconFont.icon_beauty1x, color: UIColors.colorECEDEF),
  },
  InternalMenuIDs.live: {
    _noneState: const Icon(NEMeetingIconFont.icon_live, color: UIColors.colorECEDEF),
  },
  NEMenuIDs.whiteBoard: {
    _uncheckState: const Icon(NEMeetingIconFont.icon_whiteboard, color: UIColors.colorECEDEF),
    _checkState: const Icon(NEMeetingIconFont.icon_whiteboard, color: UIColors.blue_337eff),
  },
};

Icon? _useBuiltinIconById(int id, int state) {
  final icons = _builtinMenuItemIcons[id];
  if (icons is Map) {
    return icons![state];
  }
  return null;
}

class SingleStateMenuItem extends StatelessWidget {
  final NESingleStateMenuItem menuItem;
  final MenuItemClickCallback callback;
  final MenuItemTipBuilder? tipBuilder;

  SingleStateMenuItem({
    Key? key,
    required this.menuItem,
    this.tipBuilder,
    required this.callback,
  }) : super(key: key ?? ValueKey(menuItem.itemId));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => callback.call(NEMenuClickInfo(menuItem.itemId)),
      child: MenuItemInfo(
        itemId: menuItem.itemId,
        itemInfo: menuItem.singleStateItem,
        itemState: _noneState,
        tipBuilder: tipBuilder,
      ),
    );
  }
}

class CheckableMenuItem extends StatelessWidget {
  final NECheckableMenuItem menuItem;
  final MenuItemClickCallback? callback;
  final CyclicStateListController controller;
  final MenuItemTipBuilder? tipBuilder;

  CheckableMenuItem({Key? key, required this.menuItem, required this.controller, this.callback, this.tipBuilder})
      : super(key: key ?? ValueKey(menuItem.itemId));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => callback?.call(
          NEStatefulMenuClickInfo(itemId: menuItem.itemId, state: NEMenuItemStates.getState([controller.value]))),
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (BuildContext context, NEMenuItemState state, Widget? child) {
          final _state = NEMenuItemStates.getState([state]);
          final checked = NEMenuItemStates.isChecked(_state);
          return MenuItemInfo(
            itemId: menuItem.itemId,
            itemInfo: checked ? menuItem.checkedStateItem : menuItem.uncheckStateItem,
            itemState: _state,
            tipBuilder: tipBuilder,
          );
        },
      ),
    );
  }
}

class MenuItemInfo extends StatelessWidget {
  final int itemId;
  final NEMenuItemInfo itemInfo;
  final int itemState;
  final MenuItemTipBuilder? tipBuilder;

  MenuItemInfo({required this.itemId, required this.itemInfo, required this.itemState, this.tipBuilder});

  @override
  Widget build(BuildContext context) {
    final Widget icon = Container(
      width: 24,
      height: 24,
      child: !itemInfo.hasIcon
          ? _useBuiltinIconById(itemId, itemState)
          : Image(
              image: getImage(itemInfo),
            ),
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        tipBuilder?.call(context, icon) ?? icon,
        SizedBox(height: 2),
        Text(
          itemInfo.text.trim(),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.fade,
          style: TextStyle(
            color: UIColors.colorECEDEF,
            fontSize: 10,
            decoration: TextDecoration.none,
            fontWeight: FontWeight.w400,
          ),
        )
      ],
    );
  }

  ImageProvider getImage(NEMenuItemInfo itemInfo) {
    if (itemInfo.hasPlatformPackage) {
      return AssetImage(itemInfo.icon!, package: itemInfo.platformPackage);
    }
    return PlatformImage(key: itemInfo.icon ?? '');
  }
}
