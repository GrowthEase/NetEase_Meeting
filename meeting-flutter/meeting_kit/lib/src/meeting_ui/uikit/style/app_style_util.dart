// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

///自定义状态栏风格
class NEMeetingKitUIStyle {
  /// 深色状态栏图标，适用于浅色的背景
  static late final systemUiOverlayStyleDark =
      SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  /// 浅色状态栏图标，适用于深色的背景
  static late final systemUiOverlayStyleLight =
      SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static void setSystemUIOverlayStyleDark() {
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyleDark);
  }

  static void setSystemUIOverlayStyle(
      {Color? statusBarColor,
      Brightness? statusBarBrightness,
      Brightness? statusBarIconBrightness}) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: statusBarColor ?? Colors.transparent, // 状态栏背景颜色
        statusBarBrightness:
            statusBarBrightness ?? Brightness.light, // 状态栏文本颜色亮或暗
        statusBarIconBrightness:
            statusBarIconBrightness ?? Brightness.light // 状态栏图标亮或暗
        ));
  }
}
