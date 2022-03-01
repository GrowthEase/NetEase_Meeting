// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

typedef MenuItemClickCallback = void Function(NEMenuClickInfo clickInfo);

typedef MenuItemTipBuilder = Widget Function(
    BuildContext context, Widget? child);

class ValueNotifierAdapter<T, R> extends ValueNotifier<R> {
  final ValueListenable<T> source;
  final R Function(T) mapper;

  ValueNotifierAdapter({required this.source, required this.mapper})
      : super(mapper(source.value)) {
    source.addListener(_updateValue);
  }

  void refresh() => _updateValue();

  void _updateValue() => value = mapper(source.value);

  @override
  void dispose() {
    source.removeListener(_updateValue);
    super.dispose();
  }
}

class ControlInternalMenuItems {
  /// 动态菜单按钮
  /// 需要在"更多"菜单中优先展示
  static const List<NEMeetingMenuItem> dynamicFeatureMenuItemList = [
  ];

  /// 更多菜单
  static const more = NESingleStateMenuItem(
    itemId: _InternalMenuIDs.more,
    visibility: NEMenuVisibility.visibleAlways,
    singleStateItem: NEMenuItemInfo(_Strings.more),
  );


}

/// 内部使用，50-99
class _InternalMenuIDs {
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

final int _uncheckState = NEMenuItemStates.getState([NEMenuItemState.uncheck]);
final int _checkState = NEMenuItemStates.getState([NEMenuItemState.checked]);
final int _noneState = NEMenuItemStates.getState([NEMenuItemState.none]);

final _builtinMenuItemIcons = <int, Map<int, Icon>>{
  NEMenuIDs.microphone: {
    _uncheckState: const Icon(NEMeetingIconFont.icon_yx_tv_voice_onx,
      color: UIColors.color_49494D, size: 30,),
    _checkState: const Icon(NEMeetingIconFont.icon_yx_tv_voice_offx,
      color: UIColors.white, size: 30,),
  },
  NEMenuIDs.camera: {
    _uncheckState: const Icon(NEMeetingIconFont.icon_yx_tv_video_onx,
      color: UIColors.color_49494D, size: 30,),
    _checkState: const Icon(NEMeetingIconFont.icon_yx_tv_video_offx,
      color: UIColors.white, size: 30,),
  },
  NEMenuIDs.switchShowType: {
    _uncheckState: const Icon(NEMeetingIconFont.icon_yx_tv_layout_bx,
      color: UIColors.color_49494D, size: 30,),
    _checkState: const Icon(NEMeetingIconFont.icon_yx_tv_layout_ax,
      color: UIColors.color_49494D, size: 30,),
  },
  NEMenuIDs.participants: {
    _noneState: const Icon(NEMeetingIconFont.icon_yx_tv_attendeex,
      color: UIColors.color_49494D, size: 30,),
  },
  NEMenuIDs.managerParticipants: {
    _noneState: const Icon(NEMeetingIconFont.icon_yx_tv_attendeex,
      color: UIColors.color_49494D, size: 30,),
  },
  NEMenuIDs.invitation: {
    _noneState: const Icon(NEMeetingIconFont.icon_yx_tv_invitex,
      color: UIColors.color_49494D, size: 30,),
  },
  _InternalMenuIDs.more: {
    _noneState: const Icon(Icons.more_horiz,
      color: UIColors.color_49494D, size: 30,),
  },
};

Icon? _useBuiltinIconById(int? id, int? state) {
  final icons = _builtinMenuItemIcons[id!];
  if (icons is Map) {
    return icons![state!];
  }
  return null;
}

class SingleStateMenuItem extends StatelessWidget {
  final NESingleStateMenuItem menuItem;
  final MenuItemClickCallback? callback;
  final MenuItemTipBuilder? tipBuilder;

  SingleStateMenuItem({
    Key? key,
    required this.menuItem,
    this.tipBuilder,
    this.callback,
  })
      : super(key: key ?? ValueKey(menuItem.itemId));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => callback?.call(NEMenuClickInfo(menuItem.itemId)),
      child: ControlMenuItemInfo(
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
  final ControllerCyclicStateListController controller;
  final MenuItemTipBuilder? tipBuilder;

  CheckableMenuItem({Key? key, required this.menuItem, required this.controller, this.callback, this.tipBuilder})
      : super(key: key ?? ValueKey(menuItem.itemId));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () =>
          callback?.call(NEStatefulMenuClickInfo(
              itemId: menuItem.itemId,
              state: NEMenuItemStates.getState([controller.value]))),
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (BuildContext context, NEMenuItemState state, Widget? child) {
          final _state = NEMenuItemStates.getState([state]);
          final checked = NEMenuItemStates.isChecked(_state);
          return ControlMenuItemInfo(
            itemId: menuItem.itemId,
            itemInfo:
            checked ? menuItem.checkedStateItem : menuItem.uncheckStateItem,
            itemState: _state,
            tipBuilder: tipBuilder,
          );
        },
      ),
    );
  }
}

class ControlMenuItemInfo extends StatelessWidget {
  final int? itemId;
  final NEMenuItemInfo? itemInfo;
  final int? itemState;
  final MenuItemTipBuilder? tipBuilder;

  ControlMenuItemInfo({this.itemId, this.itemInfo, this.itemState, this.tipBuilder});

  @override
  Widget build(BuildContext context) {
    final Widget icon = Container(
      child: controlButton(),

    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        tipBuilder?.call(context, icon) ?? icon,
        SizedBox(height: 2),
        Text(
          itemInfo!.text.trim(),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.fade,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: UIColors.primaryText,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        )
      ],
    );
  }

  Widget controlButton() {
    var isSelected = itemState == _checkState ? true : false;
    return RawMaterialButton(
      elevation: 0,
      fillColor: isSelected ? itemId == NEMenuIDs.switchShowType ? UIColors.white : UIColors.color_49494D : UIColors
          .white,
      constraints: BoxConstraints(minWidth: 72.0, minHeight: 72.0),
      child: !itemInfo!.hasIcon
          ? _useBuiltinIconById(itemId, itemState)
          : Image(
        image: PlatformImage(key: itemInfo!.icon!),
      ),
      shape: CircleBorder(
          side: BorderSide(
              color: isSelected
                  ? itemId == NEMenuIDs.switchShowType
                      ? UIColors.colorC8C8CC
                      : UIColors.color_49494D
                  : UIColors.colorC8C8CC,
              width: 1)),
      onPressed: null,
    );
  }

}

class ControlMoreSingleStateMenuItem extends StatelessWidget {
  final NESingleStateMenuItem menuItem;
  final MenuItemClickCallback? callback;
  final MenuItemTipBuilder? tipBuilder;

  ControlMoreSingleStateMenuItem({
    Key? key,
    required this.menuItem,
    this.tipBuilder,
    this.callback,
  })
      : super(key: key ?? ValueKey(menuItem.itemId));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => callback?.call(NEMenuClickInfo(menuItem.itemId)),
      child: ControlMoreMenuItemInfo(
        itemId: menuItem.itemId,
        itemInfo: menuItem.singleStateItem,
        itemState: _noneState,
        tipBuilder: tipBuilder,
      ),
    );
  }
}

class ControlMoreCheckableMenuItem extends StatelessWidget {
  final NECheckableMenuItem menuItem;
  final MenuItemClickCallback? callback;
  final ControllerCyclicStateListController controller;
  final MenuItemTipBuilder? tipBuilder;

  ControlMoreCheckableMenuItem(
      {Key? key, required this.menuItem, required this.controller, this.callback, this.tipBuilder})
      : super(key: key ?? ValueKey(menuItem.itemId));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () =>
          callback?.call(NEStatefulMenuClickInfo(
              itemId: menuItem.itemId,
              state: NEMenuItemStates.getState([controller.value]))),
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (BuildContext context, NEMenuItemState state, Widget? child) {
          final _state = NEMenuItemStates.getState([state]);
          final checked = NEMenuItemStates.isChecked(_state);
          return ControlMoreMenuItemInfo(
            itemId: menuItem.itemId,
            itemInfo:
            checked ? menuItem.checkedStateItem : menuItem.uncheckStateItem,
            itemState: _state,
            tipBuilder: tipBuilder,
          );
        },
      ),
    );
  }
}

class ControlMoreMenuItemInfo extends StatelessWidget {
  final int? itemId;
  final NEMenuItemInfo? itemInfo;
  final int? itemState;
  final MenuItemTipBuilder? tipBuilder;

  ControlMoreMenuItemInfo({this.itemId, this.itemInfo, this.itemState, this.tipBuilder});

  @override
  Widget build(BuildContext context) {
    final icon =
    !itemInfo!.hasIcon
        ? _useBuiltinIconById(itemId, itemState) : Image(image: PlatformImage(key: itemInfo!.icon!),);
    return Row(
      children: <Widget>[
        tipBuilder?.call(context, icon) ?? icon!,
        SizedBox(height: 2),
        Container(
          margin: EdgeInsets.only(left: 13),
          width: 300,
          child: Text(
            itemInfo!.text.trim(),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
            textAlign: TextAlign.left,

            style: TextStyle(
              decoration: TextDecoration.none,
              color: UIColors.primaryText,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),),
        ),
      ],
    );
  }
}
