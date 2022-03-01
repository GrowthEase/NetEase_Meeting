// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class ControlOptions {
  /// 遥控器首页右上角设置自定义按钮，可添加监听器处理菜单点击事件
  ControlMenuItem? settingMenu;
  /// 遥控器会控页面邀请设置自定义按钮，可添加监听器处理菜单点击事件
  ControlMenuItem? shareMenu;
  /// "Toolbar"自定义菜单
  List<NEMeetingMenuItem>? injectedToolbarMenuItems;
  /// "更多"自定义菜单，可添加监听器处理菜单点击事件
  List<NEMeetingMenuItem>? injectedMoreMenuItems;

  ControlOptions(
      {
      this.settingMenu,
      this.shareMenu,
      this.injectedToolbarMenuItems,
      this.injectedMoreMenuItems,
      });
}

class MeetingIdDisplayOption {

  static const int displayAll = 0;

  static const int displayLongIdOnly = 1;

  static const int displayShortIdOnly = 2;

}
