// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingCard extends StatefulWidget {
  final String? title;
  final String? summary;
  final Color? titleColor;
  final double? titleFontSize;
  final IconData? iconData;
  final Color? iconColor;
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  final CrossAxisAlignment crossAxisAlignment;

  const MeetingCard({
    super.key,
    this.title,
    this.summary,
    this.iconData,
    this.iconColor,
    this.titleColor,
    this.titleFontSize,
    this.margin,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    required this.children,
  });

  @override
  State<MeetingCard> createState() => _MeetingCardState();
}

class _MeetingCardState extends State<MeetingCard> {
  final _summaryVisible = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? EdgeInsets.only(top: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: _UIColors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(7),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: widget.crossAxisAlignment,
        children: [
          _buildTitle(),
          _buildSummary(),
          ...widget.children,
        ],
      ),
    );
  }

  /// 构建标题
  Widget _buildTitle() {
    if (widget.title == null && widget.iconData == null)
      return SizedBox.shrink();
    return Container(
      height: 32,
      alignment: Alignment.bottomLeft,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 4,
      ),
      child: Row(
        children: [
          if (widget.iconData != null) ...[
            Icon(
              widget.iconData,
              size: 13,
              color: widget.iconColor,
            ),
            SizedBox(width: 4),
          ],
          if (widget.title != null)
            Text(
              widget.title!,
              strutStyle: StrutStyle(forceStrutHeight: true, height: 1),
              style: TextStyle(
                fontSize: widget.titleFontSize ?? 12,
                color: widget.titleColor ?? _UIColors.color8D90A0,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (widget.summary != null)
            GestureDetector(
              onTap: () {
                _summaryVisible.value = !_summaryVisible.value;
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(
                  NEMeetingIconFont.icon_info,
                  size: 14,
                  color: _UIColors.colorCDCFD7,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    if (widget.summary == null) return SizedBox.shrink();
    return ValueListenableBuilder<bool>(
      valueListenable: _summaryVisible,
      builder: (context, visible, child) {
        if (!visible) return SizedBox.shrink();
        return Container(
          margin: EdgeInsets.only(left: 16, right: 16, top: 4),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: ShapeDecoration(
            color: _UIColors.colorF0F1F5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Text(
            widget.summary!,
            style: TextStyle(
              fontSize: 12,
              color: _UIColors.color8D90A0,
            ),
          ),
        );
      },
    );
  }
}

/// 设置选项开关Widget
class MeetingSwitchItem extends StatelessWidget {
  final Key? switchKey;
  final String title;
  final String? content;
  final Widget Function(bool enable)? contentBuilder;
  final ValueNotifier<bool> valueNotifier;
  final ValueChanged<bool>? onChanged;
  final EdgeInsetsGeometry? padding;
  final TextStyle? titleTextStyle;
  final double? minHeight;

  const MeetingSwitchItem({
    this.switchKey,
    required this.title,
    this.content,
    this.contentBuilder,
    this.padding,
    this.titleTextStyle,
    this.minHeight,
    required this.valueNotifier,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight ?? 48),
      child: Container(
        padding: padding ??
            EdgeInsets.only(
              left: 16,
              right: 10,
              top: 3,
              bottom: 3,
            ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: titleTextStyle ??
                        TextStyle(
                            fontSize: 16,
                            color: _UIColors.color1E1F27,
                            fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (contentBuilder != null) ...[
                    SizedBox(height: 4),
                    ValueListenableBuilder<bool>(
                        valueListenable: valueNotifier,
                        builder: (context, value, child) {
                          return contentBuilder!(value);
                        }),
                  ],
                  if (content != null) ...[
                    SizedBox(height: 4),
                    Container(
                      child: Text(
                        content!,
                        style: TextStyle(
                            fontSize: 12, color: _UIColors.color8D90A0),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            SizedBox(width: 5),
            GestureDetector(
              onTap: () {
                onChanged?.call(!valueNotifier.value);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: EdgeInsets.all(6),
                width: 40,
                height: 24,
                child: Transform.scale(
                  scale: 0.8,
                  child: ValueListenableBuilder<bool>(
                      valueListenable: valueNotifier,
                      builder: (context, value, child) {
                        return CupertinoSwitch(
                            key: switchKey,
                            value: value,
                            onChanged: onChanged,
                            activeColor: _UIColors.blue_337eff);
                      }),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// 会议列表可复制Widget
class MeetingListCopyable extends StatelessWidget {
  final String? title;
  final String? content;
  final bool justTopCorner;
  final bool justBottomCorner;
  final IconData? iconData;

  /// enableCopyNotifier.value = true
  final ValueNotifier<bool>? enableCopyNotifier;

  /// transformNotifier.value = false
  final ValueNotifier<bool>? transformNotifier;

  const MeetingListCopyable({
    super.key,
    required this.title,
    this.content,
    this.iconData,
    this.justTopCorner = false,
    this.justBottomCorner = false,
    this.enableCopyNotifier,
    this.transformNotifier,
  });

  /// 顶部圆角
  MeetingListCopyable.withTopCorner({
    required this.title,
    this.content,
    this.iconData,
    this.enableCopyNotifier,
    this.transformNotifier,
  })  : justTopCorner = true,
        justBottomCorner = false;

  /// 底部圆角
  MeetingListCopyable.withBottomCorner({
    required this.title,
    this.content,
    this.iconData,
    this.enableCopyNotifier,
    this.transformNotifier,
  })  : justTopCorner = false,
        justBottomCorner = true;

  /// 顶部和底部圆角
  MeetingListCopyable.withAllCorner({
    required this.title,
    this.content,
    this.iconData,
    this.enableCopyNotifier,
    this.transformNotifier,
  })  : justTopCorner = true,
        justBottomCorner = true;

  /// 无圆角
  MeetingListCopyable.withNoCorner({
    required this.title,
    this.content,
    this.iconData,
    this.enableCopyNotifier,
    this.transformNotifier,
  })  : justTopCorner = false,
        justBottomCorner = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          // horizontal: 16,
          // vertical: 8,
          ),
      child: _buildCopyItem(title, content,
          transform: transformNotifier?.value ?? false,
          enableCopy: enableCopyNotifier?.value ?? true),
    );
  }

  ///
  /// 构建标题
  /// [itemTitle] 标题
  /// [itemDetail] 详情
  /// [transform] 是否需要转换
  /// [enableCopy] 是否可以复制
  Widget _buildCopyItem(String? itemTitle, String? itemDetail,
      {bool transform = false, required bool enableCopy}) {
    return Container(
      height: _MeetingDimen.primaryItemHeight,
      padding: EdgeInsets.only(
          left: _MeetingDimen.globalPadding,
          right: _MeetingDimen.globalPadding),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(justTopCorner ? 7 : 0),
          topRight: Radius.circular(justTopCorner ? 7 : 0),
          bottomLeft: Radius.circular(justBottomCorner ? 7 : 0),
          bottomRight: Radius.circular(justBottomCorner ? 7 : 0),
        ),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(itemTitle ?? '',
              style: TextStyle(
                  fontSize: 16,
                  color: _UIColors.color1E1F27,
                  fontWeight: FontWeight.w500)),
          // Spacer(),
          Expanded(
            child: Text('   ${itemDetail ?? ''}',
                textAlign: TextAlign.right,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, color: _UIColors.color53576A)),
          ),
          if (enableCopy)
            GestureDetector(
              key: MeetingUIValueKeys.copy,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 12.0,
                ),
                child: Icon(iconData ?? NEMeetingIconFont.icon_copy,
                    size: 24, color: _UIColors.blue_337eff),
              ),
              onTap: () {
                if (itemDetail == null) return;
                final value = transform
                    ? itemDetail.replaceAll(RegExp(r'-'), '')
                    : itemDetail;
                Clipboard.setData(ClipboardData(text: value));
                ToastUtils.showBotToast(NEMeetingUIKit.instance
                    .getUIKitLocalizations()
                    .globalCopySuccess);
              },
            ),
        ],
      ),
    );
  }
}

/// 会议列表Item
///
class _MeetingDimen {
  static const double primaryItemHeight = 48.0;
  static const double globalPadding = 16;
}

/// 带勾选Widget
class MeetingCheckItem extends StatelessWidget {
  const MeetingCheckItem({
    super.key,
    required this.title,
    this.titleStyle,
    this.subTitle,
    required this.isSelected,
    this.height = 48,
    this.onTap,
    this.padding,
    this.clickAble = true,
  });

  final String title;
  final double height;
  final String? subTitle;
  final bool isSelected;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final TextStyle? titleStyle;
  final bool clickAble;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (clickAble) {
          onTap?.call();
        }
      },
      child: Container(
        padding: padding ?? EdgeInsets.symmetric(horizontal: 16),
        height: height,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: [
                  Text(
                    title,
                    style: titleStyle ??
                        TextStyle(
                          fontSize: 16,
                          color: _UIColors.color1E1F27,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  if (subTitle != null)
                    Text(
                      subTitle!,
                      style:
                          TextStyle(fontSize: 12, color: _UIColors.color8D90A0),
                    ),
                ],
              ),
            ),
            isSelected
                ? Icon(
                    NEMeetingIconFont.icon_check_line,
                    size: 16,
                    color: clickAble
                        ? _UIColors.color_337eff
                        : _UIColors.color_337eff.withOpacity(0.5),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

/// 带箭头Widget
class MeetingArrowItem extends StatelessWidget {
  const MeetingArrowItem({
    super.key,
    required this.title,
    this.tag,
    this.content,
    this.minHeight = 48,
    this.onTap,
    this.padding,
    this.titleTextStyle,
    this.contentTextStyle,
    this.showArrow = true,
  });

  final String title;
  final Widget? tag;
  final String? content;
  final double minHeight;
  final VoidCallback? onTap;
  final TextStyle? titleTextStyle;
  final TextStyle? contentTextStyle;
  final EdgeInsetsGeometry? padding;
  final bool showArrow;

  /// item左侧标题
  Widget getTitle({required String text}) {
    return Text(
      text,
      softWrap: true,
      style: titleTextStyle ??
          TextStyle(
              color: _UIColors.color1E1E27,
              fontSize: 16,
              fontWeight: FontWeight.w500),
      strutStyle: StrutStyle(
        forceStrutHeight: true,
        height: 1.3,
      ),
    );
  }

  /// item右侧内容
  Widget getContent({required String text}) {
    return Text(
      text,
      style: contentTextStyle ??
          TextStyle(
            fontSize: 16,
            color: _UIColors.color53576A,
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.none,
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      strutStyle: StrutStyle(
        forceStrutHeight: true,
        height: 1.3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleWidget = getTitle(text: title);
    return GestureDetector(
      key: key,
      child: Container(
        constraints: BoxConstraints(
          minHeight: minHeight,
        ),
        padding: padding ??
            EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 3,
            ),
        child: Row(
          children: <Widget>[
            if (content == null)
              Expanded(
                child: titleWidget,
              )
            else
              titleWidget,
            if (tag != null) tag!,
            SizedBox(width: 8),
            if (content != null)
              Expanded(
                  child: Align(
                alignment: Alignment.centerRight,
                child: getContent(text: content!),
              )),
            if (showArrow) ...[
              SizedBox(width: 12),
              Icon(NEMeetingIconFont.icon_yx_allowx,
                  size: 16, color: _UIColors.color8D90A0),
            ]
          ],
        ),
      ),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
    );
  }
}

class MeetingRadioItem extends StatelessWidget {
  final String title;
  final bool value;
  final bool groupValue;
  final void Function(bool?) onChanged;
  final double height;
  final EdgeInsetsGeometry padding;

  MeetingRadioItem(
      {super.key,
      required this.title,
      required this.value,
      required this.groupValue,
      required this.onChanged,
      this.height = 40,
      this.padding = const EdgeInsets.only(left: 32, right: 16)});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: padding,
        height: height,
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              child: Radio<bool>(
                value: value,
                groupValue: groupValue,
                onChanged: onChanged,
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return _UIColors.color_337eff.withOpacity(
                      states.contains(WidgetState.disabled) ? 0.5 : 1.0,
                    );
                  }
                  return _UIColors.colorE6E7EB;
                }),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        color: _UIColors.color53576A,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none))),
          ],
        ),
      ),
      onTap: () => onChanged.call(value),
    );
  }
}
