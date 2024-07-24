// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 调整了 iOS 平台的转场动画时长，使其更接近 iOS 原生体验
/// 未来可能定制页面的转场动画
class NEMeetingPageRoute<T> extends MaterialPageRoute<T> {
  final bool botToastInit;

  NEMeetingPageRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
    super.allowSnapshotting,
    super.barrierDismissible,
    this.botToastInit = false,
  });

  @override
  WidgetBuilder get builder {
    if (botToastInit)
      return (context) {
        return BotToastInit()(
          context,
          super.builder(context),
        );
      };
    return super.builder;
  }

  @override
  Duration get transitionDuration => Platform.isIOS
      ? const Duration(milliseconds: 500)
      : super.transitionDuration;
}
