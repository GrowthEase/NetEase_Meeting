// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_uikit;

class InviteDialog extends Dialog {
  final Function onOK;
  final String title;
  final String content;

  InviteDialog({Key? key, required this.title, required this.content, required this.onOK}) : super(key: key);

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
                    side: BorderSide(color: Colors.white), borderRadius: BorderRadius.all(Radius.circular(14))),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontSize: 17, decoration: TextDecoration.none),
                  ),
                  SizedBox(
                    width: 16,
                    height: 11,
                  ),
                  Text("$content",
                      textAlign: TextAlign.left,
                      style: TextStyle(color: UIColors.color_333333, fontSize: 12, decoration: TextDecoration.none)),
                  SizedBox(
                    height: 15,
                  ),
                  Divider(
                    height: 1,
                    color: UIColors.color_0D000050,
                  ),
                  RawMaterialButton(
                    onPressed: _ok,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.only(bottomLeft: Radius.circular(14), bottomRight: Radius.circular(14))),
                    constraints: const BoxConstraints(minHeight: 43),
                    child: Text(
                      UIStrings.copyInvite,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: UIColors.blue_337eff, fontSize: 17, decoration: TextDecoration.none),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _ok() {
    onOK();
  }
}
