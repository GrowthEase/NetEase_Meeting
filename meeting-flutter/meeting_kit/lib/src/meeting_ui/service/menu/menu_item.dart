// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

typedef NEMenuItemClickHandler = Future<bool> Function(
    BuildContext context, NEMenuClickInfo clickInfo);

/// 菜单可见性策略
enum NEMenuVisibility {
  /// 始终可见
  visibleAlways,

  /// 主持人不可见
  visibleExcludeHost,

  /// 仅主持人可见
  visibleToHostOnly,

  /// SIP/H323不可见
  visibleExcludeRoomSystemDevice,

  /// 仅对会议创建者可见
  visibleToOwnerOnly,

  /// 仅对会议主持人可见，联席主持人不可见
  visibleToHostExcludeCoHost,
}

typedef NEMenuItemTextGetter(BuildContext context);

/// 菜单项某一状态下的描述信息，包括菜单文本和图标。
class NEMenuItemInfo<T> {
  static final undefine = NEMenuItemInfo._nullable();

  static const int maxTextLength = 10;

  final NEMenuItemTextGetter? textGetter;

  final String? text;

  /// Android平台下该字段为图片资源ID；
  /// iOS平台下该字段为资源名称；
  /// 如果为'0'，则说明该菜单未设置ICON
  final String? icon;

  /// flutter平台下，如果传入该字段，则会从flutter平台加载资源
  final String? platformPackage;

  /// 是否是图片链接
  final bool isNetworkImage;

  NEMenuItemInfo._nullable({this.text, this.icon, this.isNetworkImage = false})
      : textGetter = null,
        platformPackage = null;

  NEMenuItemInfo(
      {this.textGetter,
      this.text,
      this.icon,
      this.platformPackage,
      this.customObject,
      this.isNetworkImage = false})
      : assert(textGetter != null || text != null);

  bool get hasIcon => icon != null && icon != '0';

  bool get isValid =>
      textGetter != null ||
      (text != null && text!.length > 0 && text!.length <= maxTextLength);

  bool get hasPlatformPackage =>
      platformPackage != null && platformPackage != '';

  T? customObject;

  @override
  String toString() {
    return 'NEMenuItemInfo{text: $text, icon: $icon}';
  }
}

class _MenuClickType {
  static const int base = 0;

  static const int stateful = 1;

  static const int action = 2;
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

  NEStatefulMenuClickInfo({required int itemId, required this.state})
      : super(itemId);

  @override
  int get type => _MenuClickType.stateful;

  @override
  Map<String, dynamic> toJson() => {...super.toJson(), 'state': state};

  @override
  String toString() {
    return 'NEStatefulMenuClickInfo{state: $state}';
  }
}

/// 成员菜单点击时，传递操作信息
class NEActionMenuClickInfo extends NEMenuClickInfo {
  /// 点击菜单操作对应的成员uuid
  final String userUuid;

  NEActionMenuClickInfo({required int itemId, required this.userUuid})
      : super(itemId);

  @override
  int get type => _MenuClickType.action;

  Map<String, dynamic> toJson() => {
        'type': type,
        'itemId': itemId,
        'userUuid': userUuid,
      };

  @override
  String toString() {
    return 'NEActionMenuClickInfo{userUuid: $userUuid}';
  }
}

/// 会议自定义菜单项
/// 通过 NEMeetingOptions.injectedMoreMenuItems 添加自定义菜单项
/// 菜单项基类。菜单通过ID来唯一标识，在区间[0,100)以及[100000,110000]范围内的菜单为SDK内置菜单, 自定义菜单可以使用其他ID。
/// 目前SDK提供了单状态菜单
/// [NESingleStateMenuItem]与双状态菜单
/// [NECheckableMenuItem]实现可供使用。单状态菜单始终展示相同的标题与图标；多状态的菜单包含与状态数一一对应的标题与图标，在菜单状态变更时会触发UI更新。
/// <p>通过注册 ,回调可监听自定义注入菜单的点击事件(SDK内置菜单不会触发回调)。
abstract class NEMeetingMenuItem {
  static const int firstInjectedItemId = firstInjectableMenuId;

  /// 菜单项ID, [0,100)以及[100000,110000]为预留Id，自定义注入菜单Id请使用其他ID
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

  @protected
  bool get isBuiltInMenuItem =>
      itemId < firstInjectedItemId ||
      (itemId >= NEActionMenuIDs.actionMenuStartId &&
          itemId <= NEActionMenuIDs.actionMenuEndId);

  @override
  String toString() {
    return 'NEMeetingMenuItem{itemId: $itemId, visibility: $visibility}';
  }
}

/// 仅包含单个状态的菜单项，点击时不会进行状态迁移
class NESingleStateMenuItem<T> extends NEMeetingMenuItem {
  final NEMenuItemInfo<T> singleStateItem;

  const NESingleStateMenuItem(
      {required int itemId,
      required NEMenuVisibility visibility,
      required this.singleStateItem})
      : super(itemId: itemId, visibility: visibility);

  @override
  bool get isValid {
    return isBuiltInMenuItem || (super.isValid && singleStateItem.isValid);
  }

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
  final bool checked;

  const NECheckableMenuItem({
    required int itemId,
    required NEMenuVisibility visibility,
    required this.uncheckStateItem,
    required this.checkedStateItem,
    this.checked = false,
  }) : super(itemId: itemId, visibility: visibility);

  @override
  bool get isValid =>
      isBuiltInMenuItem ||
      (super.isValid && checkedStateItem.isValid && uncheckStateItem.isValid);

  @override
  String toString() {
    return 'NECheckableMenuItem{uncheckStateItem: $uncheckStateItem, checkedStateItem: $checkedStateItem, checked: $checked}';
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
