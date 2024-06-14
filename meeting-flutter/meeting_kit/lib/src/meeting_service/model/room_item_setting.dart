// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 会议信息选项
class NEMeetingItemSetting {
  /// 成员音视频控制
  List<NEMeetingControl>? controls;

  /// 入会时云端录制开关
  bool cloudRecordOn = false;

  bool get isAudioOffAllowSelfOn {
    for (NEMeetingControl control in controls ?? []) {
      if (control is NEInMeetingAudioControl) {
        return control.enabled && control.allowSelfOn;
      }
    }
    return false;
  }

  bool get isAudioOffNotAllowSelfOn {
    for (NEMeetingControl control in controls ?? []) {
      if (control is NEInMeetingAudioControl) {
        return control.enabled && !control.allowSelfOn;
      }
    }
    return false;
  }

  /// native 传递到flutter页面解析
  static NEMeetingItemSetting fromNativeJson(Map<dynamic, dynamic>? map) {
    var setting = NEMeetingItemSetting();
    if (map != null) {
      setting.cloudRecordOn = (map['cloudRecordOn'] ?? false) as bool;
      setting.controls = (map['controls'] as List?)
          ?.map((e) =>
              NEMeetingControl.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return setting;
  }
}
