// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_ui;

enum ConfirmAction { cancel, accept }

class PermissionHelper {
  static const tag = '#permissionHelper';

  static Future<bool> enableLocalVideoAndCheckPermission(
      BuildContext context, bool on, String title) async {
    var result = true;
    if (on) {
      result = await requestPermissionSingle(
          context, Permission.camera, title, _Strings.cameraPermission,
          message:
              '${_Strings.permissionRationalePrefix}${_Strings.cameraPermission}${_Strings.permissionRationaleSuffixVideo}',
          useDialog: Platform.isAndroid);
    }
    return result;
  }

  static Future<bool> enableLocalAudioAndCheckPermission(
      BuildContext context, bool on, String title) async {
    var result = true;
    if (on) {
      result = await PermissionHelper.requestPermissionSingle(
          context, Permission.microphone, title, _Strings.microphonePermission,
          message:
              '${_Strings.permissionRationalePrefix}${_Strings.microphonePermission}${_Strings.permissionRationaleSuffixAudio}',
          useDialog: Platform.isAndroid);
    }
    return result;
  }

  static Future<bool> requestPermissionSingle(BuildContext context,
      Permission permission, String title, String permissionName,
      {String? message, bool useDialog = true}) async {
    var status = await permission.status;
    var granted = status == PermissionStatus.granted;
    Alog.i(
        tag: tag,
        moduleName: _moduleName,
        content: "request permission: $status $useDialog");
    if (granted) return granted;
    if (useDialog) {
      final action = await showDialog<ConfirmAction>(
          context: context,
          builder: (BuildContext context) {
            return buildPermissionDialog(
                context, title, permissionName, message);
          });
      if (action == ConfirmAction.accept) {
        granted = await requestSingle(permission);
      }
    } else {
      granted = await requestSingle(permission);
    }
    return granted;
  }

  static CupertinoAlertDialog buildPermissionDialog(BuildContext context,
      String title, String permissionName, String? message) {
    return CupertinoAlertDialog(
      title: Text('${_Strings.notWork}$permissionName'),
      content: Text(message ??
          '${_Strings.funcNeed}$permissionName,${_Strings.needPermissionTipsFirst}$title${_Strings.needPermissionTipsTail}$permissionName${_Strings.permissionTips}？'),
      actions: <Widget>[
        CupertinoDialogAction(
          child: const Text(_Strings.cancel),
          onPressed: () {
            Navigator.of(context).pop(ConfirmAction.cancel);
          },
        ),
        CupertinoDialogAction(
          child: const Text(_Strings.toSetUp),
          onPressed: () {
            Navigator.of(context).pop(ConfirmAction.accept);
          },
        ),
      ],
    );
  }

  static Future<bool> requestSingle(Permission request) async {
    PermissionStatus status = await request.request();
    Alog.i(
        tag: tag,
        moduleName: _moduleName,
        content:
            "request single permission: $status ${status.isPermanentlyDenied}");
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    return status == PermissionStatus.granted;
  }
}
