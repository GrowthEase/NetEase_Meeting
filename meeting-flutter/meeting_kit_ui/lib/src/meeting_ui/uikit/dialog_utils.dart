// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class DialogUtils {
  static Future showCommonDialog(BuildContext context, String title,
      String content, VoidCallback cancelCallback, VoidCallback acceptCallback,
      {String? cancelText,
      String? acceptText,
      Color? cancelTextColor,
      Color? acceptTextColor,
      bool canBack = true,
      bool isContentCenter = true}) {
    return showDialog(
        context: context,
        useRootNavigator: false,
        builder: (BuildContext _) {
          return NEMeetingUIKitLocalizationsScope(
              builder: (BuildContext context) {
            return WillPopScope(
              child: CupertinoAlertDialog(
                title: TextUtils.isEmpty(title) ? null : Text(title),
                content: Text(content,
                    textAlign:
                        isContentCenter ? TextAlign.center : TextAlign.left),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(cancelText ??
                        NEMeetingUIKitLocalizations.of(context)!.cancel),
                    onPressed: cancelCallback,
                    textStyle: TextStyle(
                        color: cancelTextColor ?? _UIColors.color_666666),
                  ),
                  CupertinoDialogAction(
                    child: Text(acceptText ??
                        NEMeetingUIKitLocalizations.of(context)!.sure),
                    onPressed: acceptCallback,
                    textStyle: TextStyle(
                        color: acceptTextColor ?? _UIColors.color_337eff),
                  ),
                ],
              ),
              onWillPop: () async {
                return canBack;
              },
            );
          });
        });
  }

  static Future showOneButtonCommonDialog(
      BuildContext context, String title, String content, VoidCallback callback,
      {String? acceptText, bool canBack = true, bool isContentCenter = true}) {
    return showDialog(
        context: context,
        useRootNavigator: false,
        builder: (_) {
          return NEMeetingUIKitLocalizationsScope(
              builder: (BuildContext context) {
            return WillPopScope(
              child: CupertinoAlertDialog(
                title: TextUtils.isEmpty(title) ? null : Text(title),
                content: Text(content,
                    textAlign:
                        isContentCenter ? TextAlign.center : TextAlign.left),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(acceptText ??
                        NEMeetingUIKitLocalizations.of(context)!.iKnow),
                    onPressed: callback,
                  ),
                ],
              ),
              onWillPop: () async {
                return canBack;
              },
            );
          });
        });
  }

  static void showInviteDialog(
      BuildContext context, String contentBuilder(BuildContext context)) {
    showCupertinoDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: true,
      builder: (_) {
        return NEMeetingUIKitLocalizationsScope(builder: (context) {
          final content = contentBuilder(context);
          return _InviteDialog(
            title: NEMeetingUIKitLocalizations.of(context)!.inviteDialogTitle,
            content: content,
            onOK: () async {
              Clipboard.setData(ClipboardData(text: content));
              ToastUtils.showToast(
                  context,
                  NEMeetingUIKitLocalizations.of(context)!
                      .inviteContentCopySuccess);
              Navigator.pop(context);
            },
          );
        });
      },
    );
  }

  static void showNetworkAbnormalityAlertDialog(
      {required BuildContext context,
      required VoidCallback onLeaveMeetingCallback,
      required VoidCallback onRejoinMeetingCallback}) {
    showCommonDialog(
      context,
      NEMeetingUIKitLocalizations.of(context)!.networkAbnormality,
      NEMeetingUIKitLocalizations.of(context)!
          .networkDisconnectedPleaseCheckYourNetworkStatusOrTryToRejoin,
      onLeaveMeetingCallback,
      onRejoinMeetingCallback,
      cancelText: NEMeetingUIKitLocalizations.of(context)!.leaveMeeting,
      acceptText: NEMeetingUIKitLocalizations.of(context)!.rejoining,
      cancelTextColor: _UIColors.colorFE3B30,
      canBack: false,
    );
  }

  static Future showOpenAudioDialog(
      BuildContext context,
      String title,
      String content,
      VoidCallback cancelCallback,
      VoidCallback acceptCallback) {
    return showCommonDialog(
        context, title, content, cancelCallback, acceptCallback,
        cancelText: NEMeetingUIKitLocalizations.of(context)!.close,
        acceptText: NEMeetingUIKitLocalizations.of(context)!.open,
        canBack: false);
  }

  static Future showOpenVideoDialog(
      BuildContext context,
      String title,
      String content,
      VoidCallback cancelCallback,
      VoidCallback acceptCallback) {
    return showCommonDialog(
        context, title, content, cancelCallback, acceptCallback,
        cancelText: NEMeetingUIKitLocalizations.of(context)!.close,
        acceptText: NEMeetingUIKitLocalizations.of(context)!.open,
        canBack: false);
  }

  static void showShareScreenDialog(BuildContext context, String title,
      String content, VoidCallback acceptCallback) {
    showDialog(
        context: context,
        useRootNavigator: false,
        builder: (_) {
          return NEMeetingUIKitLocalizationsScope(
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text(title),
                content: Text(content),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(NEMeetingUIKitLocalizations.of(context)!.no),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text(NEMeetingUIKitLocalizations.of(context)!.yes),
                    onPressed: acceptCallback,
                  ),
                ],
              );
            },
          );
        });
  }

  static Future<T?> showChildNavigatorDialog<T extends Object>(
      BuildContext context, WidgetBuilder builder) {
    return showCupertinoDialog(
        context: context,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return NEMeetingUIKitLocalizationsScope(
            builder: (context) => builder(context),
          );
        });
  }

  static Future<T?> showChildNavigatorPopup<T extends Object>(
      BuildContext context, WidgetBuilder builder) {
    return showCupertinoModalPopup(
        context: context,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return NEMeetingUIKitLocalizationsScope(
            builder: (context) => builder(context),
          );
        });
  }
}
