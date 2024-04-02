// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

///自定义状态栏风格
class AppStyle {
  static late final systemUiOverlayStyleDark =
      SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static late final systemUiOverlayStyleLight =
      SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static void setSystemUIOverlayStyleDark() {
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyleDark);
  }
}
