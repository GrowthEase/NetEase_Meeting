// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
import 'menu_item.dart';
import 'menu_items.dart';

class NEControlMenuIDs extends NEMenuIDs {

  /// 以下菜单不能包含在Toolbar菜单中
  static const Set<int> toolbarExcludes = {

  };

  /// 以下菜单不能包含在更多菜单中
  static const Set<int> moreExcludes = {
    NEMenuIDs.microphone, NEMenuIDs.camera, NEMenuIDs.managerParticipants, NEMenuIDs.participants,
  };

  static const Set<int> all = {
    NEMenuIDs.microphone, NEMenuIDs.camera, NEMenuIDs.participants, NEMenuIDs.managerParticipants,
    NEMenuIDs.invitation, NEMenuIDs.switchShowType,
  };
}


class NEControlMenuItems extends NEMenuItems {
  static List<NEMeetingMenuItem> get defaultToolbarMenuItems =>
      [
        NEMenuItems.microphone,
        NEMenuItems.camera,
        NEMenuItems.participants,
        NEMenuItems.managerParticipants,
        switchShowType,
      ];

  static List<NEMeetingMenuItem> get defaultMoreMenuItems =>
      [
        NEMenuItems.invitation,
      ];

  static const NEMeetingMenuItem switchShowType = NECheckableMenuItem(
      itemId: NEMenuIDs.switchShowType,
      visibility: NEMenuVisibility.visibleAlways,
      uncheckStateItem: NEMenuItemInfo("视图布局"),
      checkedStateItem: NEMenuItemInfo("视图布局"));
}


