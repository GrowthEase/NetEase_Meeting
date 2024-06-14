// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class TitleBarCloseIcon extends StatelessWidget {
  final IconData? icon;
  final VoidCallback? onPressed;
  final double height;

  const TitleBarCloseIcon({
    super.key,
    this.icon,
    this.onPressed,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed ??
          () {
            Navigator.of(context).pop();
          },
      child: SizedBox.square(
        dimension: height,
        child: Icon(
          icon ?? NEMeetingIconFont.icon_yx_tv_duankaix,
          color: _UIColors.color_666666,
          size: 16,
          key: MeetingUIValueKeys.close,
        ),
      ),
    );
  }
}

class TitleBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;

  final Widget? title;

  final Widget? leading;

  final Widget? trailing;

  final bool showBottomDivider;

  const TitleBar({
    super.key,
    this.title,
    this.leading,
    this.height = 48.0,
    this.trailing = const TitleBarCloseIcon(),
    this.showBottomDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      color: Colors.white,
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: leading != null ? leading! : SizedBox.shrink(),
              ),
            ),
            if (title != null) title!,
            Expanded(
              flex: 1,
              child: Align(
                  alignment: Alignment.centerRight,
                  child: trailing != null ? trailing! : SizedBox.shrink()),
            ),
          ],
        ),
      ),
    );
    if (showBottomDivider) {
      child = Container(
        padding: EdgeInsets.only(bottom: 1),
        color: _UIColors.colorEBEDF0,
        child: child,
      );
    }
    return child;
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class TitleBarTitle extends StatelessWidget {
  const TitleBarTitle(
    this.title, {
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: _UIColors.color_333333,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class AutoHideStatusBar extends StatefulWidget {
  final Widget child;
  final bool hide;

  const AutoHideStatusBar({
    super.key,
    required this.child,
    this.hide = true,
  });

  @override
  State<AutoHideStatusBar> createState() => _AutoHideStatusBarState();
}

class _AutoHideStatusBarState extends State<AutoHideStatusBar> {
  @override
  void initState() {
    super.initState();
    if (widget.hide) {
      _HideStatusBarActor().hide();
    }
  }

  @override
  void didUpdateWidget(AutoHideStatusBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hide != widget.hide) {
      if (widget.hide) {
        _HideStatusBarActor().hide();
      } else {
        _HideStatusBarActor().show();
      }
    }
  }

  @override
  void dispose() {
    _HideStatusBarActor().show();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _HideStatusBarActor {
  _HideStatusBarActor._();

  static final instance = _HideStatusBarActor._();

  factory _HideStatusBarActor() => instance;
  var clients = 0;

  void hide() {
    if (clients++ == 0) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom]);
    }
  }

  void show() {
    if (--clients == 0) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
        SystemUiOverlay.top,
        SystemUiOverlay.bottom,
      ]);
    }
  }
}

Future<T?> showMeetingPopupPageRoute<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
  RouteSettings? routeSettings,
  Color? barrierColor,
}) {
  var Size(:longestSide, :shortestSide) = MediaQuery.sizeOf(context);
  var maxHeight = longestSide * (1.0 - 100.0 / 812);
  return showModalBottomSheet<T>(
    context: context,
    routeSettings: routeSettings,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      ),
    ),
    barrierColor: barrierColor,
    isScrollControlled: true,
    clipBehavior: Clip.antiAlias,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    constraints: BoxConstraints.tightFor(height: max(shortestSide, maxHeight)),
    builder: (context) {
      return OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;
          Widget child = AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeIn,
            child: builder(context),
          );

          /// 如果是切换为横屏模式，则隐藏状态栏
          /// 补充SafeArea，避免导航栏遮挡关闭按钮
          return AutoHideStatusBar(
            child: SafeArea(child: child, bottom: false),
            hide: !isPortrait,
          );
        },
      );
    },
  );
}
