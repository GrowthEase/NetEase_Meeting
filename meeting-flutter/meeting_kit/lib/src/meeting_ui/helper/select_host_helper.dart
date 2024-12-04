// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 选择主持人帮助类
class SelectHostHelper {
  SelectHostHelper._internal();

  static SelectHostHelper _singleton = new SelectHostHelper._internal();

  factory SelectHostHelper() => _singleton;

  NERoomContext? _roomContext;

  void init(NERoomContext roomContext) {
    this._roomContext = roomContext;
  }

  /// 获取筛选后的成员列表
  List<NEBaseRoomMember> getFilteredMemberList() {
    final memberList = <NEBaseRoomMember>[];
    if (_roomContext != null) {
      final members = _roomContext!.getAllUsers().toList();

      memberList.addAll(members);

      /// 移除自己和SIP成员
      memberList.removeWhere((element) =>
          _roomContext!.isMySelf(element.uuid) ||
          (element is NERoomMember && element.isRoomSystemDevice));
    }
    return memberList;
  }

  NEBaseRoomMember? getDefaultWantHostMember() {
    return getFilteredMemberList().isNotEmpty
        ? getFilteredMemberList()[0]
        : null;
  }

  void dispose() {
    _roomContext = null;
  }
}
