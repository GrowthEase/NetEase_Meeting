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
      result = await requestPermissionSingle(context, Permission.camera, title,
          NEMeetingUIKitLocalizations.of(context)!.cameraPermission,
          message:
              '${NEMeetingUIKitLocalizations.of(context)!.permissionRationalePrefix}${NEMeetingUIKitLocalizations.of(context)!.cameraPermission}${NEMeetingUIKitLocalizations.of(context)!.permissionRationaleSuffixVideo}',
          useDialog: Platform.isAndroid);
    }
    return result;
  }

  static Future<bool> enableLocalAudioAndCheckPermission(
      BuildContext context, bool on, String title) async {
    var result = true;
    if (on) {
      result = await PermissionHelper.requestPermissionSingle(
          context,
          Permission.microphone,
          title,
          NEMeetingUIKitLocalizations.of(context)!.microphonePermission,
          message:
              '${NEMeetingUIKitLocalizations.of(context)!.permissionRationalePrefix}${NEMeetingUIKitLocalizations.of(context)!.microphonePermission}${NEMeetingUIKitLocalizations.of(context)!.permissionRationaleSuffixAudio}',
          useDialog: Platform.isAndroid);
    }
    return result;
  }

  static Future<bool> requestPermissionSingle(BuildContext context,
      Permission permission, String title, String permissionName,
      {String? message,
      bool useDialog = true,
      bool useRootNavigator = false}) async {
    var status = await permission.status;
    var granted = status == PermissionStatus.granted;
    Alog.i(
        tag: tag,
        moduleName: _moduleName,
        content: "request permission: $permission $status $useDialog");
    if (granted) return granted;
    if (useDialog) {
      final action = await showDialog<ConfirmAction>(
        context: context,
        useRootNavigator: useRootNavigator,
        builder: (_) {
          return NEMeetingUIKitLocalizationsScope(
            builder: (ctx) {
              return _buildPermissionDialog(
                  ctx, title, permissionName, message);
            },
          );
        },
      );
      if (action == ConfirmAction.accept) {
        granted = await requestSingle(permission);
      }
    } else {
      granted = await requestSingle(permission);
    }
    return granted;
  }

  static Widget _buildPermissionDialog(BuildContext context, String title,
      String permissionName, String? message) {
    return CupertinoAlertDialog(
      title: Text(
          '${NEMeetingUIKitLocalizations.of(context)!.notWork}$permissionName'),
      content: Text(message ??
          '${NEMeetingUIKitLocalizations.of(context)!.funcNeed}$permissionName,${NEMeetingUIKitLocalizations.of(context)!.needPermissionTipsFirst}$title${NEMeetingUIKitLocalizations.of(context)!.needPermissionTipsTail}$permissionName${NEMeetingUIKitLocalizations.of(context)!.permissionTips}？'),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text(NEMeetingUIKitLocalizations.of(context)!.cancel),
          onPressed: () {
            Navigator.of(context).pop(ConfirmAction.cancel);
          },
        ),
        CupertinoDialogAction(
          child: Text(NEMeetingUIKitLocalizations.of(context)!.toSetUp),
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
