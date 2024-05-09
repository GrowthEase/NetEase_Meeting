// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_ui;

enum ConfirmAction { cancel, accept }

class PermissionHelper {
  static const tag = '#permissionHelper';

  static Completer? _ongoing;

  static Future<bool> enableLocalVideoAndCheckPermission(
      BuildContext context, bool on, String title) async {
    var result = true;
    if (on) {
      result = await requestPermissionSingle(context, Permission.camera, title,
          NEMeetingUIKitLocalizations.of(context)!.meetingCamera,
          message: NEMeetingUIKitLocalizations.of(context)!
              .meetingNeedRationaleVideoPermission(
                  NEMeetingUIKitLocalizations.of(context)!.meetingCamera),
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
          NEMeetingUIKitLocalizations.of(context)!.meetingMicrophone,
          message: NEMeetingUIKitLocalizations.of(context)!
              .meetingNeedRationaleAudioPermission(
                  NEMeetingUIKitLocalizations.of(context)!.meetingMicrophone),
          useDialog: Platform.isAndroid);
    }
    return result;
  }

  static Future<bool> requestContactsPermission(BuildContext context) async {
    return await requestPermissionSingle(
        context,
        Permission.contacts,
        NEMeetingUIKitLocalizations.of(context)!.sipLocalContacts,
        NEMeetingUIKitLocalizations.of(context)!.sipLocalContacts,
        message: NEMeetingUIKitLocalizations.of(context)!.sipContactsPrivacy);
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
        granted = await _requestSingle(permission);
      }
    } else {
      granted = await _requestSingle(permission);
    }
    return granted;
  }

  static Widget _buildPermissionDialog(BuildContext context, String title,
      String permissionName, String? message) {
    return CupertinoAlertDialog(
      title: Text(NEMeetingUIKitLocalizations.of(context)!
          .globalNotWork(permissionName)),
      content: Text(message ??
          NEMeetingUIKitLocalizations.of(context)!
              .globalNeedPermissionTips(permissionName, title)),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text(NEMeetingUIKitLocalizations.of(context)!.globalCancel),
          onPressed: () {
            Navigator.of(context).pop(ConfirmAction.cancel);
          },
        ),
        CupertinoDialogAction(
          child: Text(NEMeetingUIKitLocalizations.of(context)!.globalToSetUp),
          onPressed: () {
            Navigator.of(context).pop(ConfirmAction.accept);
          },
        ),
      ],
    );
  }

  static Future<bool> _requestSingle(Permission request) async {
    if (_ongoing == null || _ongoing?.isCompleted == true) {
      _ongoing = Completer();
    } else {
      await _ongoing?.future;
    }
    PermissionStatus status = await request.request();
    Alog.i(
        tag: tag,
        moduleName: _moduleName,
        content:
            "request single permission: $status ${status.isPermanentlyDenied}");
    if (_ongoing?.isCompleted == false) {
      _ongoing?.complete();
    }
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    return status == PermissionStatus.granted;
  }
}
