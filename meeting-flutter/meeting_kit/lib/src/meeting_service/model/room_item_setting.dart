// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class NEMeetingItemSettings {
  List<NERoomControl>? controls;

  bool cloudRecordOn = false;

  bool get isAudioOffAllowSelfOn {
    for (NERoomControl control in controls ?? []) {
      if (control is NEInRoomAudioControl) {
        return control.enabled && control.allowSelfOn;
      }
    }
    return false;
  }

  bool get isAudioOffNotAllowSelfOn {
    for (NERoomControl control in controls ?? []) {
      if (control is NEInRoomAudioControl) {
        return control.enabled && !control.allowSelfOn;
      }
    }
    return false;
  }

  /// native 传递到flutter页面解析
  static NEMeetingItemSettings fromNativeJson(Map<dynamic, dynamic>? map) {
    var setting = NEMeetingItemSettings();
    if (map != null) {
      setting.cloudRecordOn = (map['cloudRecordOn'] ?? false) as bool;
      setting.controls = (map['controls'] as List?)
          ?.map((e) =>
              NERoomControl.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return setting;
  }
}
