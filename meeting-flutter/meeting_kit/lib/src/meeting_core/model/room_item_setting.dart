// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 会议信息选项
class NEMeetingItemSetting {
  /// 成员音视频控制
  List<NEMeetingControl>? controls;

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
      setting.controls = (map['controls'] as List?)
          ?.map((e) =>
              NEMeetingControl.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return setting;
  }

  Map toJson() {
    return {
      'controls': controls?.map((e) => e.toJson()).toList(),
    };
  }
}

/// 云端录制配置
class NECloudRecordConfig {
  /// 是否开启云端录制
  bool enable;

  /// 默认为0
  /// 0：主持人加入房间开始录制
  /// 1：成员加入房间开始录制
  NERecordStrategyType recordStrategy;

  NECloudRecordConfig(
      {this.enable = false,
      this.recordStrategy = NERecordStrategyType.hostJoin});

  Map toJson() {
    return {
      'enable': enable,
      'recordStrategy': recordStrategy.value,
    };
  }

  factory NECloudRecordConfig.fromJson(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return NECloudRecordConfig();
    }
    return NECloudRecordConfig(
      enable: (map['enable'] ?? false) as bool,
      recordStrategy: NERecordStrategyTypeExtension.mapValueToEnum(
          map['recordStrategy'] as int?),
    );
  }
}

enum NERecordStrategyType {
  /// 主持人加入房间开始录制
  hostJoin,

  /// 成员加入房间开始录制
  memberJoin,
}

extension NERecordStrategyTypeExtension on NERecordStrategyType {
  int get value {
    switch (this) {
      case NERecordStrategyType.hostJoin:
        return 0;
      case NERecordStrategyType.memberJoin:
        return 1;
    }
  }

  static NERecordStrategyType mapValueToEnum(int? value) {
    switch (value) {
      case 0:
        return NERecordStrategyType.hostJoin;
      case 1:
        return NERecordStrategyType.memberJoin;
      default:
        return NERecordStrategyType.hostJoin;
    }
  }
}

/// 聊天消息提醒类型
enum NEChatMessageNotificationType {
  /// 弹幕
  barrage,

  /// 气泡
  bubble,

  /// 不提醒
  noRemind,
}

extension NEChatMessageNotificationTypeExtension
    on NEChatMessageNotificationType {
  int get value {
    switch (this) {
      case NEChatMessageNotificationType.barrage:
        return 0;
      case NEChatMessageNotificationType.bubble:
        return 1;
      case NEChatMessageNotificationType.noRemind:
        return 2;
    }
  }

  static NEChatMessageNotificationType mapValueToEnum(int? value) {
    switch (value) {
      case 0:
        return NEChatMessageNotificationType.barrage;
      case 1:
        return NEChatMessageNotificationType.bubble;
      case 2:
        return NEChatMessageNotificationType.noRemind;
    }
    return NEChatMessageNotificationType.barrage;
  }
}
