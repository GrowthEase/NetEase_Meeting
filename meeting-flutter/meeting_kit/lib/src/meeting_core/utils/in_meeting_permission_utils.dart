// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

typedef InMeetingPermissionRequestListener = void Function(String);

class InMeetingPermissionUtils {
  static final _listeners = <InMeetingPermissionRequestListener>{};

  static void addPermissionRequestListener(
      InMeetingPermissionRequestListener listener) {
    _listeners.add(listener);
  }

  static void removePermissionRequestListener(
      InMeetingPermissionRequestListener listener) {
    _listeners.remove(listener);
  }

  static void notifyPermissionRequest(String permissionName) {
    if (Platform.isIOS) return;
    _listeners.forEach((e) {
      e.call(permissionName);
    });
  }
}
