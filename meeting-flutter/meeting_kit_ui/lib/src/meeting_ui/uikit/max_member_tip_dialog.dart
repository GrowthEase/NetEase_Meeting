// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class _MaxMemberTipDialog extends Dialog {
  final Function onOK;
  final Function onCancel;
  final String? title;
  final String? okTitle;
  final String? cancelTitle;
  final String content;

  const _MaxMemberTipDialog({
    Key? key,
    this.title,
    this.okTitle,
    required this.cancelTitle,
    required this.content,
    required this.onOK,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(12),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
//              height: 200,
              width: 270,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.all(Radius.circular(14))),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    title ??
                        NEMeetingUIKitLocalizations.of(context)!
                            .meetingMemberMaxTip,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        decoration: TextDecoration.none),
                  ),
                  SizedBox(
                    width: 16,
                    height: 11,
                  ),
                  Text("$content",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: _UIColors.color_333333,
                          fontSize: 12,
                          decoration: TextDecoration.none)),
                  SizedBox(
                    height: 15,
                  ),
                  Divider(
                    height: 1,
                    color: _UIColors.color_0D000050,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RawMaterialButton(
                        onPressed: _cancel,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(14),
                                bottomRight: Radius.circular(14))),
                        constraints: const BoxConstraints(minHeight: 43),
                        child: Text(
                          cancelTitle ??
                              NEMeetingUIKitLocalizations.of(context)!
                                  .globalGotIt,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: _UIColors.black_222222,
                              fontSize: 17,
                              decoration: TextDecoration.none),
                        ),
                      ),
                      if (okTitle != null && okTitle!.isNotEmpty)
                        RawMaterialButton(
                          onPressed: _ok,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(14),
                                  bottomRight: Radius.circular(14))),
                          constraints: const BoxConstraints(minHeight: 43),
                          child: Text(
                            okTitle!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: _UIColors.blue_337eff,
                                fontSize: 17,
                                decoration: TextDecoration.none),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// 确定
  void _ok() {
    onOK();
  }

  /// 取消
  void _cancel() {
    onCancel();
  }
}
