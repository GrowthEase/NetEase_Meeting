// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
import 'menu_item.dart';

class _MenuItemTypes {
  static const int singleStateMenuItem = 0;

  static const int checkableMenuItem = 1;
}

List<NEMeetingMenuItem>? buildMenuItemList(List? json) {
  return json?.whereType<Map<String,dynamic>>().map((element) {
    NEMeetingMenuItem? item;
    final type = element['type'];
    if (type == _MenuItemTypes.singleStateMenuItem) {
      item = _buildSingleStateMenuItem(element);
    } else if (type == _MenuItemTypes.checkableMenuItem) {
      item = _buildCheckableMenuItem(element);
    }
    if (item?.isValid ?? false) {
      return item;
    }
    return null;
  }).whereType<NEMeetingMenuItem>().toList(growable: false);
}

NEMeetingMenuItem? _buildSingleStateMenuItem(Map json) {
  try {
    final info = json['info'] as Map;
    return NESingleStateMenuItem(
      itemId: json['itemId'] as int,
      visibility: NEMenuVisibility.values[json['visibility'] as int],
      singleStateItem: NEMenuItemInfo(
        info['text'] as String,
        icon: info['icon']?.toString(),
      ),
    );
  } catch (e) {
    //noop
  }
  return null;
}

NEMeetingMenuItem? _buildCheckableMenuItem(Map json) {
  try {
    final uncheckInfo = json['uncheckInfo'] as Map;
    final checkInfo = json['checkInfo'] as Map;
    return NECheckableMenuItem(
      itemId: json['itemId'] as int,
      visibility: NEMenuVisibility.values[json['visibility'] as int],
      uncheckStateItem: NEMenuItemInfo(
        uncheckInfo['text'] as String,
        icon: uncheckInfo['icon']?.toString(),
      ),
      checkedStateItem: NEMenuItemInfo(
        checkInfo['text'] as String,
        icon: checkInfo['icon']?.toString(),
      ),
    );
  } catch (e) {
    //noop
  }
  return null;
}

