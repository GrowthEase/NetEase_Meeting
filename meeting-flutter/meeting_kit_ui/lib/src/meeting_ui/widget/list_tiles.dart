// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 展示 标题 和 向右箭头
class GotoTile extends StatelessWidget {
  final VoidCallback? onTap;
  final double height;
  final Color background;
  final String title;
  final TextStyle titleTextStyle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final Decoration? decoration;
  final int? maxLines;

  const GotoTile({
    super.key,
    this.onTap,
    this.height = 56.0,
    this.background = _UIColors.white,
    required this.title,
    this.titleTextStyle = const TextStyle(
      color: _UIColors.color_222222,
      fontSize: 16,
    ),
    this.trailing,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.decoration,
    this.maxLines,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      height: height,
      color: decoration != null ? null : background,
      padding: padding,
      decoration: decoration,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: titleTextStyle,
              maxLines: maxLines,
            ),
          ),
          // Spacer(),
          if (trailing != null) trailing!,
          if (trailing == null)
            Icon(
              icon ?? NEMeetingIconFont.icon_yx_allowx,
              size: iconSize ?? 14.0,
              color: iconColor ?? _UIColors.greyCCCCCC,
            ),
        ],
      ),
    );
    return onTap != null
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: child,
          )
        : child;
  }
}

/// 展示 标题、副标题 和 切换开关
class SwitchTile extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final double? height;
  final Color? background;
  final String? summary;
  final Color? summaryColor;
  final bool value;
  final ValueChanged<bool>? onChange;
  final EdgeInsetsGeometry padding;

  const SwitchTile({
    ValueKey? key,
    required this.title,
    this.summary,
    this.summaryColor,
    required this.value,
    this.onChange,
    this.background,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.height,
    this.titleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 56,
      color: background ?? _UIColors.white,
      padding: padding,
      child: Row(
        children: <Widget>[
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: titleColor ?? _UIColors.black_222222,
                  fontSize: 16,
                ),
              ),
              if (summary != null)
                Text(
                  summary!,
                  style: TextStyle(
                    color: summaryColor ?? _UIColors.color_999999,
                    fontSize: 12,
                  ),
                ),
            ],
          )),
          CupertinoSwitch(
            key: key,
            value: value,
            onChanged: onChange,
            activeColor: _UIColors.blue_337eff,
          ),
        ],
      ),
    );
  }
}
