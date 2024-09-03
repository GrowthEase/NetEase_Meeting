// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class EmojisPanel extends StatefulWidget {
  final Function() sendAction;
  final TextEditingController controller;
  final GlobalKey<ExtendedTextFieldState> textFieldKey;
  final double height;
  final double paddingBottom;

  EmojisPanel({
    super.key,
    required this.sendAction,
    required this.controller,
    required this.textFieldKey,
    required this.height,
    required this.paddingBottom,
  });

  @override
  State<EmojisPanel> createState() => _EmojisPanelState();
}

class _EmojisPanelState extends State<EmojisPanel> {
  final emojiTags = NEMeetingEmojis.emojiTags;

  final MeetingTextSpanBuilder _meetingTextSpanBuilder =
      MeetingTextSpanBuilder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height + widget.paddingBottom,
      color: _UIColors.colorF5F6F7,
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Container(
              padding: EdgeInsets.only(
                  top: 8,
                  bottom: 12 + widget.paddingBottom + 40,
                  left: 10,
                  right: 10),
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        insertText(emojiTags[index]);
                      },
                      child: Container(
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          child: Image(
                            image: NEMeetingEmojis.assetImageProvider(
                                emojiTags[index]),
                            width: 30,
                            height: 30,
                            fit: BoxFit.contain,
                          )),
                    );
                  },
                  itemCount: emojiTags.length,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: buildActions(widget.paddingBottom),
          ),
        ],
      ),
    );
  }

  Widget buildActions(double paddingBottom) {
    final buttonHeight = 40.0;
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 20,
            width: 153,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _UIColors.colorF5F6F7.withOpacity(0),
                  _UIColors.colorF5F6F7,
                ],
              ),
            ),
          ),
          Container(
            color: _UIColors.colorF5F6F7,
            padding:
                EdgeInsets.only(bottom: paddingBottom, left: 21, right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: manualDelete,
                  child: Container(
                    width: 54,
                    height: buttonHeight,
                    decoration: BoxDecoration(
                      color: _UIColors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      NEMeetingIconFont.icon_emoji_delete,
                      size: 24,
                      color: _UIColors.colorB1B6C2,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                GestureDetector(
                    onTap: () {
                      if (widget.controller.text.isNotEmpty) {
                        widget.sendAction();
                      }
                    },
                    child: ValueListenableBuilder(
                      valueListenable: widget.controller,
                      builder: (context, value, child) {
                        return Container(
                          width: 54,
                          height: buttonHeight,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: widget.controller.text.isNotEmpty
                                ? _UIColors.color_337eff
                                : _UIColors.colorB1B6C2,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                              NEMeetingUIKit.instance
                                  .getUIKitLocalizations()
                                  .globalSend,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400)),
                        );
                      },
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void manualDelete() {
    //delete by code
    final TextEditingValue _value = widget.controller.value;
    final TextSelection selection = _value.selection;
    if (!selection.isValid) {
      return;
    }

    TextEditingValue value;
    final String actualText = _value.text;
    if (selection.isCollapsed && selection.start == 0) {
      return;
    }

    final int start =
        selection.isCollapsed ? selection.start - 1 : selection.start;
    final int end = selection.end;
    final CharacterRange characterRange =
        CharacterRange.at(actualText, start, end);
    value = TextEditingValue(
      text: characterRange.stringBefore + characterRange.stringAfter,
      selection:
          TextSelection.collapsed(offset: characterRange.stringBefore.length),
    );

    final TextSpan oldTextSpan = _meetingTextSpanBuilder.build(_value.text);

    value = ExtendedTextLibraryUtils.handleSpecialTextSpanDelete(
      value,
      _value,
      oldTextSpan,
      null,
    );

    widget.controller.value = value;
  }

  void insertText(String text) {
    final TextEditingValue value = widget.controller.value;
    final int start = value.selection.baseOffset;
    int end = value.selection.extentOffset;
    if (value.selection.isValid) {
      String newText = '';
      if (value.selection.isCollapsed) {
        if (end > 0) {
          newText += value.text.substring(0, end);
        }
        newText += text;
        if (value.text.length > end) {
          newText += value.text.substring(end, value.text.length);
        }
      } else {
        newText = value.text.replaceRange(start, end, text);
        end = start;
      }

      widget.controller.value = value.copyWith(
          text: newText,
          selection: value.selection.copyWith(
              baseOffset: end + text.length, extentOffset: end + text.length));
    } else {
      widget.controller.value = TextEditingValue(
          text: text,
          selection:
              TextSelection.fromPosition(TextPosition(offset: text.length)));
    }

    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      widget.textFieldKey.currentState
          ?.bringIntoView(widget.controller.selection.base);
    });
  }
}
