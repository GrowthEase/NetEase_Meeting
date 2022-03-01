// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

///更改展示模式：1、演讲者模式 2、画廊模式

class ControlMoreMenuPage extends StatefulWidget {
  final ControlMoreMenuArguments arguments;

  ControlMoreMenuPage(this.arguments);

  @override
  State<StatefulWidget> createState() {
    return _ControlMoreMenuPageState(arguments);
  }
}

class _ControlMoreMenuPageState extends BaseState<ControlMoreMenuPage> {
  _ControlMoreMenuPageState(this.arguments);

  final ControlMoreMenuArguments arguments;
  late Radius _radius;
  late List<NEMeetingMenuItem> _filterInjectMenuItems;

  @override
  void initState() {
    super.initState();
    _radius = Radius.circular(8);
    _filterInjectMenuItems = filterInjectMenuItems(arguments.controlMeetingArguments!.injectedMoreMenuItems);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Container(
            height: 404,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.only(topLeft: _radius, topRight: _radius)),
            child: SafeArea(
              top: false,
              child: Column(
                children: <Widget>[
                  _title(),
                  Expanded(
                    child: buildMenuArea(),
                  ),
                ],
              ),
            ),
          ),
        ]);
  }

  Widget _title() {
    return Container(
      height: 48,
      decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
              side: BorderSide(
                color: UIColors.globalBg,
              ),
              borderRadius:
              BorderRadius.only(topLeft: _radius, topRight: _radius))),
      child: Stack(
        children: <Widget>[
          Center(
            child: Text(
              _Strings.more,
              style: TextStyle(
                  color: UIColors.black_333333,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  decoration: TextDecoration.none),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: RawMaterialButton(
              constraints:
              const BoxConstraints(minWidth: 40.0, minHeight: 48.0),
              child: Icon(
                NEMeetingIconFont.icon_yx_tv_duankaix,
                color: UIColors.color_666666,
                size: 15,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          )
        ],
      ),
    );
  }

  Widget buildMenuArea() {
    return ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        primary: false,
        cacheExtent: 48,
        itemCount: _filterInjectMenuItems.length + 1,
        itemBuilder: (context, index) {
          if (index == _filterInjectMenuItems.length) {
            return SizedBox(height: 1);
          }
          return buildMenuItem(index);
        },
        separatorBuilder: (context, index) {
          return Divider(height: 1, color: UIColors.globalBg);
        });
  }

  Widget buildMenuItem(int index) {
    var item = _filterInjectMenuItems[index];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            menuItem2Widget(item),
          ],
        ),
      ),
    );
  }

  Widget menuItem2Widget(NEMeetingMenuItem item) {
    final tipBuilder = getMenuItemTipBuilder(item.itemId);
    if (item is NESingleStateMenuItem) {
      return ControlMoreSingleStateMenuItem(
        menuItem: item,
        callback: handleMenuItemClick,
        tipBuilder: tipBuilder,
      );
    } else if (item is NECheckableMenuItem) {
      final controller = arguments.menuId2Controller!.putIfAbsent(item.itemId, () =>
          getMenuItemStateController(item
              .itemId));
      return ControlMoreCheckableMenuItem(
        menuItem: item,
        controller: controller,
        callback: handleMenuItemClick,
        tipBuilder: tipBuilder,
      );
    }
    return ErrorWidget('unkonwn menu item type');
  }

  MenuItemTipBuilder? getMenuItemTipBuilder(int menuId) {
    switch (menuId) {
    }
    return null;
  }

  ControllerCyclicStateListController getMenuItemStateController(int menuId) {
    var initialState = NEMenuItemState.uncheck;
    ValueListenable? listenTo;
    switch (menuId) {
      case NEMenuIDs.microphone:
        listenTo = arguments.controlMeetingArguments!.audioMuteListenable;
        initialState = arguments.controlMeetingArguments!.audioMute
            ? NEMenuItemState.checked
            : NEMenuItemState.uncheck;
        break;
      case NEMenuIDs.camera:
        listenTo = arguments.controlMeetingArguments!.videoMuteListenable;
        initialState = arguments.controlMeetingArguments!.videoMute
            ? NEMenuItemState.checked
            : NEMenuItemState.uncheck;
        break;
      case NEMenuIDs.switchShowType:
        listenTo = arguments.controlMeetingArguments!._showTypeListenable;
        initialState = (arguments.controlMeetingArguments!.showType == showTypePresenter)
            ? NEMenuItemState.checked
            : NEMenuItemState.uncheck;
    }
    return ControllerCyclicStateListController(
      stateList: [NEMenuItemState.uncheck, NEMenuItemState.checked],
      initialState: initialState,
      listenTo: listenTo,
    );
  }

  void handleMenuItemClick(NEMenuClickInfo clickInfo) {
    UINavUtils.pop(context);
    arguments.moreMenuActionCallback!.call(clickInfo);
  }

  List<NEMeetingMenuItem> filterInjectMenuItems(List<NEMeetingMenuItem> injectMenuItems) {
    return injectMenuItems
        .where(shouldShowMenu)
        .toList(growable: false);
  }

  bool shouldShowMenu(NEMeetingMenuItem item) {
    if (!item.isValid) return false;
    switch (item.visibility) {
      case NEMenuVisibility.visibleToHostOnly:
        return isHost();
      case NEMenuVisibility.visibleExcludeHost:
        return !isHost();
      case NEMenuVisibility.visibleAlways:
        return true;
    }
  }

  bool isHost() {
    return TextUtils.nonEmptyEquals(ControlProfile.pairedAccountId, arguments.hostAccountId);
  }

}
