// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class EmojiResponsePanel extends StatefulWidget {
  final void Function(String emojiTag) onEmojiTap;
  final VoidCallback onRaiseHandTap;
  final HandsUpHelper handsUpHelper;
  final EmojiResponseHelper emojiResponseHelper;
  final double? maxWidth;
  final Color? emojiPanelColor;
  final EdgeInsets? padding;
  final bool showEmojiResponse;
  final bool showHandsUp;

  const EmojiResponsePanel({
    super.key,
    required this.onEmojiTap,
    required this.onRaiseHandTap,
    required this.handsUpHelper,
    required this.emojiResponseHelper,
    this.maxWidth,
    this.emojiPanelColor,
    this.padding,
    required this.showEmojiResponse,
    required this.showHandsUp,
  });

  @override
  State<EmojiResponsePanel> createState() => _EmojiResponsePanelState();
}

class _EmojiResponsePanelState extends State<EmojiResponsePanel> {
  final _emojiRespList = NEMeetingEmojiResp.emojiRespTags;

  @override
  Widget build(BuildContext context) {
    if (widget.showEmojiResponse == false && widget.showHandsUp == false)
      return SizedBox.shrink();
    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: _UIColors.color1C1C1C,
        borderRadius: BorderRadius.circular(16),
      ),
      width: widget.maxWidth ?? double.infinity,
      child: Column(children: [
        if (widget.showEmojiResponse)
          ValueListenableBuilder<bool>(
              valueListenable:
                  widget.emojiResponseHelper.isEmojiResponseEnabled,
              builder: (context, enabled, _) {
                return buildEmojiPanel(
                    enabled || widget.emojiResponseHelper.isMySelfHostOrCoHost);
              }),
        if (widget.showHandsUp && widget.showEmojiResponse) SizedBox(height: 8),
        if (widget.showHandsUp) buildRaiseHandButton(),
      ]),
    );
  }

  Widget buildEmojiPanel(bool enable) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.emojiPanelColor ?? _UIColors.color292929,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Opacity(
        opacity: enable ? 1.0 : 0.4,
        child: Row(
          children: _emojiRespList.map((e) {
            return Expanded(
              child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: enable ? () => widget.onEmojiTap.call(e) : null,
                  child: NEMeetingEmojiResp.assetImage(
                    e,
                    width: 40,
                    height: 40,
                    isCover: true,
                  )),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildRaiseHandButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onRaiseHandTap.call(),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _UIColors.color292929,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          NEMeetingImages.assetImage(
            NEMeetingImages.iconHandsUp,
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 4.0),
          ValueListenableBuilder<bool>(
              valueListenable: widget.handsUpHelper.isMySelfHandsUp,
              builder: (context, handsUp, _) {
                return Text(
                  handsUp
                      ? NEMeetingUIKitLocalizations.of(context)!
                          .meetingHandsUpDown
                      : NEMeetingUIKitLocalizations.of(context)!
                          .meetingRaiseHand,
                  style: TextStyle(
                    color: _UIColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                  ),
                );
              }),
        ]),
      ),
    );
  }
}
