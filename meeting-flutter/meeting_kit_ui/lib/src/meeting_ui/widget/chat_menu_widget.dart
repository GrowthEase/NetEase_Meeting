// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class ChatMenuWidget extends StatefulWidget {
  final Widget child;
  final bool isRight;
  final List<String> actions;
  final double menuWidth;
  final double menuHeight;
  final double textSize;
  final Color textColor;
  final Color selectedTextColor;
  final ValueChanged<int> onValueChanged;
  final VoidCallback? willShow;
  final VoidCallback? onShow;
  final bool Function()? canShow;
  final VoidCallback? onDismiss;
  final double contentMargin;

  ChatMenuWidget(
      {Key? key,
      required this.onValueChanged,
      required this.child,
      required this.isRight,
      required this.actions,
      required this.canShow,
      this.willShow,
      this.onShow,
      this.onDismiss,
      this.textColor = _UIColors.color_333333,
      this.selectedTextColor = _UIColors.color_337eff,
      this.menuWidth = 108,
      this.menuHeight = 32,
      this.textSize = 14,
      this.contentMargin = 44});

  @override
  _ChatMenuWidgetState createState() => _ChatMenuWidgetState();
}

class _ChatMenuWidgetState extends State<ChatMenuWidget> {
  BuildContext? menuContext;
  EventCallback? _eventCallback;
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      if (menuContext?.mounted == true) {
        Navigator.pop(menuContext!);
      }
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPressStart: (details) {
          if (widget.canShow?.call() == false) {
            return;
          }
          widget.willShow?.call();
          showPopupMenu(context, details);
          widget.onShow?.call();
        },
        child: widget.child,
      );
    });
  }

  @override
  void dispose() {
    if (_eventCallback != null) {
      EventBus().unsubscribe(RecallMessageNotify, _eventCallback!);
    }
    super.dispose();
  }

  void showPopupMenu(BuildContext context, LongPressStartDetails details) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Size size = box.size;
    // 表示位置（在画面边缘会自动调整位置）
    final screenWidth = MediaQuery.of(context).size.width;
    final RelativeRect position;
    if (widget.isRight) {
      position = RelativeRect.fromLTRB(
          screenWidth - widget.menuWidth - widget.contentMargin,
          details.globalPosition.dy -
              details.localPosition.dy +
              size.height +
              10,
          widget.contentMargin,
          0);
    } else {
      position = RelativeRect.fromLTRB(
          widget.contentMargin,
          details.globalPosition.dy -
              details.localPosition.dy +
              size.height +
              10,
          screenWidth - widget.menuWidth - widget.contentMargin,
          0);
    }

    List<PopupMenuEntry<int>> items = widget.actions
        .asMap()
        .map((index, text) => MapEntry(
            index,
            PopupMenuItem(
              padding: EdgeInsets.zero,
              height: widget.menuHeight,
              child: Container(
                  alignment: Alignment.centerLeft,
                  width: widget.menuWidth,
                  height: widget.menuHeight,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(text,
                      style: TextStyle(
                          color: widget.textColor,
                          fontSize: widget.textSize,
                          fontWeight: FontWeight.w400))),
              value: index + 1,
            )))
        .values
        .toList();
    menuContext = context;
    _eventCallback = (arg) {
      if (menuContext?.mounted == true) {
        widget.onDismiss?.call();
        Navigator.pop(menuContext!);
      }
    };
    EventBus().subscribe(RecallMessageNotify, _eventCallback!);

    showMenu(
      context: context,
      position: position,
      items: items,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ).then((value) {
      menuContext = null;
      if (value != null) {
        widget.onValueChanged(value);
      }
      widget.onDismiss?.call();
    });
  }
}
