// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'menu_items.dart';

typedef NEMenuItemClickHandler = Future<bool> Function(BuildContext context,NEMenuClickInfo clickInfo);

/// 菜单可见性策略
enum NEMenuVisibility {
  /// 始终可见
  visibleAlways,

  /// 主持人不可见
  visibleExcludeHost,

  /// 仅主持人可见
  visibleToHostOnly,
}

/// 菜单项某一状态下的描述信息，包括菜单文本和图标。
class NEMenuItemInfo {
  static const int maxTextLength = 10;

  final String text;

  /// Android平台下该字段为图片资源ID；
  /// iOS平台下该字段为资源名称；
  /// 如果为'0'，则说明该菜单未设置ICON
  final String? icon;

  /// flutter平台下，如果传入该字段，则会从flutter平台加载资源
  final String? platformPackage;

  const NEMenuItemInfo(this.text, {this.icon,this.platformPackage});

  bool get hasIcon => icon != null && icon != '0';

  bool get isValid => text.length > 0 && text.length <= maxTextLength;

  bool get hasPlatformPackage => platformPackage != null && platformPackage != '';

  @override
  String toString() {
    return 'NEMenuItemInfo{text: $text, icon: $icon}';
  }


}

class _MenuClickType {
  static const int base = 0;

  static const int stateful = 1;
}

/// 单状态的菜单项被点击时的描述信息，只包含菜单ID
class NEMenuClickInfo {
  final int itemId;

  NEMenuClickInfo(this.itemId);

  @protected
  int get type => _MenuClickType.base;

  Map<String, dynamic> toJson() => {
        'type': type,
        'itemId': itemId,
      };

  @override
  String toString() {
    return 'NEMenuClickInfo{itemId: $itemId}';
  }
}

class NEStatefulMenuClickInfo extends NEMenuClickInfo {
  /// 当前菜单项的状态
  final int state;

  NEStatefulMenuClickInfo({required int itemId, required this.state}) : super(itemId);

  @override
  int get type => _MenuClickType.stateful;

  @override
  Map<String, dynamic> toJson() =>
      {...super.toJson(), 'state': state};

  @override
  String toString() {
    return 'NEStatefulMenuClickInfo{state: $state}';
  }
}

/// 会议自定义菜单项
/// 通过 NEMeetingOptions.injectedMoreMenuItems 添加自定义菜单项
abstract class NEMeetingMenuItem {
  static const int firstInjectedItemId = firstInjectableMenuId;

  /// 菜单项ID, 从0-99为预留Id，自定义注入菜单Id请使用100以上
  final int itemId;

  final NEMenuVisibility visibility;

  const NEMeetingMenuItem({required this.itemId, required this.visibility});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NEMeetingMenuItem &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId;

  @override
  int get hashCode => itemId.hashCode;

  bool get isValid => true;

  @override
  String toString() {
    return 'NEMeetingMenuItem{itemId: $itemId, visibility: $visibility}';
  }
}

/// 仅包含单个状态的菜单项，点击时不会进行状态迁移
class NESingleStateMenuItem extends NEMeetingMenuItem {
  final NEMenuItemInfo singleStateItem;

  const NESingleStateMenuItem(
      {required int itemId, required NEMenuVisibility visibility, required this.singleStateItem})
      : super(itemId: itemId, visibility: visibility);

  @override
  bool get isValid =>
      super.isValid && singleStateItem.isValid;

  @override
  String toString() {
    return 'NESingleStateMenuItem{singleStateItem: $singleStateItem}';
  }


}

/// 包含<b>checked</b>和<b>uncheck</b>两个状态的菜单项，初始时菜单项为<b>uncheck</b>状态，
/// 点击后可切换至<b>checked</b>状态，如此反复。通过菜单项点击回调方法返回值控制是否进行状态迁移。
/// 如果方法返回true，则会进行状态转移，否则保持当前状态不变。
class NECheckableMenuItem extends NEMeetingMenuItem {
  final NEMenuItemInfo uncheckStateItem;
  final NEMenuItemInfo checkedStateItem;

  const NECheckableMenuItem(
      {required int itemId,
      required NEMenuVisibility visibility,
      required this.uncheckStateItem,
      required this.checkedStateItem})
      : super(itemId: itemId, visibility: visibility);

  @override
  bool get isValid =>
      super.isValid &&
      checkedStateItem.isValid &&
      uncheckStateItem.isValid;

  @override
  String toString() {
    return 'NECheckableMenuItem{uncheckStateItem: $uncheckStateItem, checkedStateItem: $checkedStateItem}';
  }

}

enum NEMenuItemState {
  none,

  uncheck,

  checked,
}

class NEMenuItemStates {
  static const int _checkStateMask = 0x1;

  static int getState(List<NEMenuItemState> states) {
    return states.fold(0, (previousValue, element) {
      switch (element) {
        case NEMenuItemState.none:
          return previousValue;
        case NEMenuItemState.uncheck:
          return previousValue & (~_checkStateMask);
        case NEMenuItemState.checked:
          return previousValue | _checkStateMask;
      }
    });
  }

  static bool isChecked(int state) {
    return (state & _checkStateMask) == _checkStateMask;
  }
}
