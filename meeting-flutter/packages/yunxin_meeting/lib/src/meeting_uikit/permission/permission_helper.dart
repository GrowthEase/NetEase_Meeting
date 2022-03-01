// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_uikit;

enum ConfirmAction { cancel, accept }

class PermissionHelper {
  static Future<bool> requestPermissionSingle(
      BuildContext context, Permission permission,String title,String tips,) async {
    PermissionStatus status = await permission.status;
    bool granted = status == PermissionStatus.granted;
    if (granted) return granted;
    final action = await showDialog<ConfirmAction>(
        context: context,
        builder: (BuildContext context) {
          return buildPermissionDialog(context,title,tips);
        });
    if (action == ConfirmAction.accept) {
      granted = await requestSingle(permission);
    }
    return granted;
  }

  static CupertinoAlertDialog buildPermissionDialog(BuildContext context,String title,String tips) {
    return CupertinoAlertDialog(
      title: Text('${UIStrings.notWork}$tips'),
      content: Text(
          '${UIStrings.funcNeed}$tips,${UIStrings.needPermissionTipsFirst}$title${UIStrings.needPermissionTipsTail}$tips${UIStrings.permissionTips}？'),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text(UIStrings.cancel),
          onPressed: () {
            Navigator.of(context).pop(ConfirmAction.cancel);
          },
        ),
        CupertinoDialogAction(
          child: Text(UIStrings.toSetUp),
          onPressed: () {
            Navigator.of(context).pop(ConfirmAction.accept);
          },
        ),
      ],
    );
  }

  static Future<bool> requestSingle(Permission request) async {
    PermissionStatus status = await request.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    return status == PermissionStatus.granted;
  }
}
