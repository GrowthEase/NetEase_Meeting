// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

extension _ShowBottomSheetExtension on Widget {
  Future<T?> showAsBottomSheet<T>(
    BuildContext context, {
    RouteSettings? routeSettings,
    Color backgroundColor = Colors.transparent,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      builder: (BuildContext context) => this,
      backgroundColor: backgroundColor,
      routeSettings: routeSettings,
      isScrollControlled: true,
    );
  }
}

/// 底部菜单弹窗
class MeetingActionSheet extends StatelessWidget {
  final Widget? title;
  final String? titleLabel;
  final List<Widget> actions;
  final String? cancelLabel;
  final Widget? cancel;
  final Color background;

  const MeetingActionSheet({
    super.key,
    this.title,
    this.titleLabel,
    required this.actions,
    this.cancelLabel,
    this.cancel,
    this.background = _UIColors.colorF0F1F5,
  });

  @override
  Widget build(BuildContext context) {
    final titleButton = title ??
        (titleLabel != null
            ? MeetingActionSheetTitle(title: titleLabel!)
            : null);
    final cancelButton = cancel ??
        (cancelLabel != null
            ? MeetingActionSheetCancel(title: cancelLabel!)
            : null);
    final safePaddings = MediaQuery.paddingOf(context);
    final horizontalPadding = max(safePaddings.right, safePaddings.left);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context),
      child: Container(
        alignment: Alignment.bottomCenter,
        height: MediaQuery.sizeOf(context).height * 0.8,
        padding: EdgeInsets.only(
          left: max(8, horizontalPadding),
          right: max(8, horizontalPadding),
          bottom: max(8, safePaddings.bottom),
        ),
        child: Container(
          width: 359,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: background,
          ),
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 8),
              if (titleButton != null)
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                  child: titleButton,
                ),
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: titleButton != null ? Radius.zero : Radius.circular(8),
                    bottom: Radius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: actions,
                    ),
                  ),
                ),
              ),
              if (cancelButton != null) cancelButton,
              if (cancelButton == null) SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class MeetingActionSheetAction<T> extends StatelessWidget {
  final String title;
  final T? value;
  final VoidCallback? onPress;
  final Color backgroundColor;

  const MeetingActionSheetAction({
    super.key,
    required this.title,
    this.onPress,
    this.value,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress ?? () => Navigator.pop(context, value),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        color: backgroundColor,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: _UIColors.color1E1F27,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

class MeetingActionSheetCancel extends StatelessWidget {
  final String title;

  const MeetingActionSheetCancel({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 56,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: _UIColors.color3D3D3D,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

class MeetingActionSheetTitle extends StatelessWidget {
  final String title;

  const MeetingActionSheetTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: _UIColors.white,
      padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          color: _UIColors.color8D90A0,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
