// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class _InviteDialog extends StatelessWidget {
  final Function onOK;
  final String title;
  final String content;

  const _InviteDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.onOK,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            color: Colors.black.withOpacity(0.4), // 半透明黑色背景
          ),
        ),
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 33),
            decoration: const ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: 18,
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 11),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Text(
                    content,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: _UIColors.color_333333,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Divider(
                  height: 1,
                  color: _UIColors.color3F3F3F,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => onOK(),
                  child: Container(
                    height: 60,
                    child: Center(
                      child: Text(
                        NEMeetingUIKitLocalizations.of(context)!
                            .meetingCopyInvite,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _UIColors.color_007AFF,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
