// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// SDK内置成员操作菜单项ID，需要与平台定义的ID值保持一致，使用以下ID的菜单可添加至成员列表操作菜单列表中的任意位置。
/// Note: 如果修改ID值，请同步修改平台上的定义
class NEActionMenuIDs {
  /// SDK内置成员列表菜单操作项起始ID。
  /// SDK内置的菜单点击时不会触发回调，只有自定义菜单才会回调。
  static const int actionMenuStartId = 100000;

  /// SDK内置成员列表菜单操作项结束ID。
  /// SDK内置的菜单点击时不会触发回调，只有自定义菜单才会回调。
  static const int actionMenuEndId = 110000;

  static const Set<int> all = {
    audio,
    video,
    focusVideo,
    lockVideo,
    changeHost,
    reclaimHost,
    removeMember,
    rejectHandsUp,
    whiteboardInteraction,
    screenShare,
    whiteBoardShare,
    updateNick,
    audioAndVideo,
    coHost,
    putInWaitingRoom,
    chatPrivate,
  };

  /// 内置"音频"菜单操作ID
  static const int audio = 100000;

  /// 内置"视频"菜单操作ID，
  static const int video = 100001;

  /// 内置"焦点视频"菜单操作ID，
  static const int focusVideo = 100002;

  /// 内置"锁定视频"菜单操作ID，
  static const int lockVideo = 100003;

  /// 内置"移交主持人"菜单操作ID，
  static const int changeHost = 100004;

  /// 内置"收回主持人"菜单操作ID，
  static const int reclaimHost = 100005;

  /// 内置"移除成员"菜单操作ID，
  static const int removeMember = 100006;

  /// 内置"手放下"菜单操作ID，
  static const int rejectHandsUp = 100007;

  /// 内置"白板互动"菜单操作ID，
  static const int whiteboardInteraction = 100008;

  /// 内置"屏幕共享"菜单操作ID，
  static const int screenShare = 100009;

  /// 内置"白板共享"菜单操作ID，
  static const int whiteBoardShare = 100010;

  /// 内置"改名"菜单操作ID，
  static const int updateNick = 100011;

  /// 内置"音视频"菜单操作ID，
  static const int audioAndVideo = 100012;

  /// 内置"联席主持人"菜单操作ID，
  static const int coHost = 100013;

  /// 内置"移至等候室"菜单操作ID，
  static const int putInWaitingRoom = 100014;

  /// 内置"私聊"菜单操作ID，
  static const int chatPrivate = 100015;
}

/// 内置成员列表菜单操作项
class NEMenuActionItems {
  static List<NEMeetingMenuItem> get defaultActionMenuItems => [
        updateNick,
        rejectHandsUp,
        audio,
        video,
        audioAndVideo,
        chatPrivate,
        focusVideo,
        lockVideo,
        coHost,
        changeHost,
        reclaimHost,
        screenShare,
        whiteBoardShare,
        whiteboardInteraction,
        putInWaitingRoom,
        removeMember,
      ];

  /// 主持人静音、主持人解除静音
  static final NEMeetingMenuItem audio = NECheckableMenuItem(
    itemId: NEActionMenuIDs.audio,
    visibility: NEMenuVisibility.visibleToHostOnly,
    uncheckStateItem: NEMenuItemInfo.undefine,
    checkedStateItem: NEMenuItemInfo.undefine,
  );

  /// 主持人关闭视频、主持人打开视频
  static final NEMeetingMenuItem video = NECheckableMenuItem(
    itemId: NEActionMenuIDs.video,
    visibility: NEMenuVisibility.visibleToHostOnly,
    uncheckStateItem: NEMenuItemInfo.undefine,
    checkedStateItem: NEMenuItemInfo.undefine,
  );

  /// 设为焦点视频、取消焦点视频
  static final NEMeetingMenuItem focusVideo = NECheckableMenuItem(
    itemId: NEActionMenuIDs.focusVideo,
    visibility: NEMenuVisibility.visibleToHostOnly,
    uncheckStateItem: NEMenuItemInfo.undefine,
    checkedStateItem: NEMenuItemInfo.undefine,
  );

  /// 锁定视频、取消锁定视频
  static final NEMeetingMenuItem lockVideo = NECheckableMenuItem(
    itemId: NEActionMenuIDs.lockVideo,
    visibility: NEMenuVisibility.visibleAlways,
    uncheckStateItem: NEMenuItemInfo.undefine,
    checkedStateItem: NEMenuItemInfo.undefine,
  );

  /// 移交主持人，仅主持人展示、联席主持人不展示
  static final NEMeetingMenuItem changeHost = NESingleStateMenuItem(
    itemId: NEActionMenuIDs.changeHost,
    visibility: NEMenuVisibility.visibleToHostExcludeCoHost,
    singleStateItem: NEMenuItemInfo.undefine,
  );

  /// 收回主持人，仅会议创建者展示
  static final NEMeetingMenuItem reclaimHost = NESingleStateMenuItem(
    itemId: NEActionMenuIDs.reclaimHost,
    visibility: NEMenuVisibility.visibleToOwnerOnly,
    singleStateItem: NEMenuItemInfo.undefine,
  );

  /// 移除成员
  static final NEMeetingMenuItem removeMember = NESingleStateMenuItem(
    itemId: NEActionMenuIDs.removeMember,
    visibility: NEMenuVisibility.visibleToHostOnly,
    singleStateItem: NEMenuItemInfo.undefine,
  );

  /// 手放下
  static final NEMeetingMenuItem rejectHandsUp = NESingleStateMenuItem(
    itemId: NEActionMenuIDs.rejectHandsUp,
    visibility: NEMenuVisibility.visibleToHostOnly,
    singleStateItem: NEMenuItemInfo.undefine,
  );

  /// 授权白板互动、撤回白板互动
  static final NEMeetingMenuItem whiteboardInteraction = NECheckableMenuItem(
    itemId: NEActionMenuIDs.whiteboardInteraction,
    visibility: NEMenuVisibility.visibleExcludeRoomSystemDevice,
    uncheckStateItem: NEMenuItemInfo.undefine,
    checkedStateItem: NEMenuItemInfo.undefine,
  );

  /// 停止屏幕共享
  static final NEMeetingMenuItem screenShare = NESingleStateMenuItem(
    itemId: NEActionMenuIDs.screenShare,
    visibility: NEMenuVisibility.visibleToHostOnly,
    singleStateItem: NEMenuItemInfo.undefine,
  );

  /// 停止白板共享
  static final NEMeetingMenuItem whiteBoardShare = NESingleStateMenuItem(
    itemId: NEActionMenuIDs.whiteBoardShare,
    visibility: NEMenuVisibility.visibleToHostOnly,
    singleStateItem: NEMenuItemInfo.undefine,
  );

  /// 改名
  static final NEMeetingMenuItem updateNick = NESingleStateMenuItem(
    itemId: NEActionMenuIDs.updateNick,
    visibility: NEMenuVisibility.visibleToHostOnly,
    singleStateItem: NEMenuItemInfo.undefine,
  );

  /// 关闭音视频、打开音视频
  static final NEMeetingMenuItem audioAndVideo = NECheckableMenuItem(
    itemId: NEActionMenuIDs.audioAndVideo,
    visibility: NEMenuVisibility.visibleToHostOnly,
    uncheckStateItem: NEMenuItemInfo.undefine,
    checkedStateItem: NEMenuItemInfo.undefine,
  );

  /// 设为联席主持人、取消联席主持人,仅主持人展示，联席主持人不展示
  static final NEMeetingMenuItem coHost = NECheckableMenuItem(
    itemId: NEActionMenuIDs.coHost,
    visibility: NEMenuVisibility.visibleToHostExcludeCoHost,
    uncheckStateItem: NEMenuItemInfo.undefine,
    checkedStateItem: NEMenuItemInfo.undefine,
  );

  /// 移至等候室
  static final NEMeetingMenuItem putInWaitingRoom = NESingleStateMenuItem(
    itemId: NEActionMenuIDs.putInWaitingRoom,
    visibility: NEMenuVisibility.visibleToHostOnly,
    singleStateItem: NEMenuItemInfo.undefine,
  );

  /// 私聊
  static final NEMeetingMenuItem chatPrivate = NESingleStateMenuItem(
    itemId: NEActionMenuIDs.chatPrivate,
    visibility: NEMenuVisibility.visibleExcludeRoomSystemDevice,
    singleStateItem: NEMenuItemInfo.undefine,
  );
}
