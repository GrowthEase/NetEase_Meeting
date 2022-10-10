// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class DialogUtils {
  static Future showCommonDialog(BuildContext context, String title,
      String content, VoidCallback cancelCallback, VoidCallback acceptCallback,
      {String cancelText = _Strings.cancel,
      String acceptText = _Strings.sure,
      bool canBack = true,
      bool isContentCenter = true}) {
    return showDialog(
        context: context,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return WillPopScope(
            child: CupertinoAlertDialog(
              title: TextUtils.isEmpty(title) ? null : Text(title),
              content: Text(content,
                  textAlign:
                      isContentCenter ? TextAlign.center : TextAlign.left),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(cancelText),
                  onPressed: cancelCallback,
                  textStyle: TextStyle(color: _UIColors.color_666666),
                ),
                CupertinoDialogAction(
                  child: Text(acceptText),
                  onPressed: acceptCallback,
                  textStyle: TextStyle(color: _UIColors.color_337eff),
                ),
              ],
            ),
            onWillPop: () async {
              return canBack;
            },
          );
        });
  }

  static Future showOneButtonCommonDialog(
      BuildContext context, String title, String content, VoidCallback callback,
      {String acceptText = _Strings.iKnow,
      bool canBack = true,
      bool isContentCenter = true}) {
    return showDialog(
        context: context,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return WillPopScope(
            child: CupertinoAlertDialog(
              title: TextUtils.isEmpty(title) ? null : Text(title),
              content: Text(content,
                  textAlign:
                      isContentCenter ? TextAlign.center : TextAlign.left),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(acceptText),
                  onPressed: callback,
                ),
              ],
            ),
            onWillPop: () async {
              return canBack;
            },
          );
        });
  }

  static void showInviteDialog(BuildContext context, String content) {
    showCupertinoDialog(
        context: context,
        useRootNavigator: false,
        barrierDismissible: true,
        builder: (context) => _InviteDialog(
              title: _Strings.inviteDialogTitle,
              content: content,
              onOK: () async {
                Clipboard.setData(ClipboardData(text: content));
                ToastUtils.showToast(
                    context, _Strings.inviteContentCopySuccess);
                Navigator.pop(context);
              },
            ));
  }

  static Future showOpenAudioDialog(
      BuildContext context,
      String title,
      String content,
      VoidCallback cancelCallback,
      VoidCallback acceptCallback) {
    return showCommonDialog(
        context, title, content, cancelCallback, acceptCallback,
        cancelText: _Strings.close, acceptText: _Strings.open, canBack: false);
  }

  static Future showOpenVideoDialog(
      BuildContext context,
      String title,
      String content,
      VoidCallback cancelCallback,
      VoidCallback acceptCallback) {
    return showCommonDialog(
        context, title, content, cancelCallback, acceptCallback,
        cancelText: _Strings.close, acceptText: _Strings.open, canBack: false);
  }

  static void showShareScreenDialog(BuildContext context, String title,
      String content, VoidCallback acceptCallback) {
    showDialog(
        context: context,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(_Strings.no),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text(_Strings.yes),
                onPressed: acceptCallback,
              ),
            ],
          );
        });
  }

  static Future<T?> showChildNavigatorDialog<T extends Object>(
      BuildContext context, Widget widgetPage) {
    return showCupertinoDialog(
        context: context,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return widgetPage;
        });
  }

  static Future<T?> showChildNavigatorPopup<T extends Object>(
      BuildContext context, Widget widgetPage) {
    return showCupertinoModalPopup(
        context: context,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return widgetPage;
        });
  }
}
