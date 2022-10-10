// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class NEMeetingItemSettings {
  String? password;

  String? extraData;

  List<NERoomControl>? controls;

  bool cloudRecordOn = false;

  bool noSip = true;

  NEMeetingItemLive? live;

  Map<String, NEMeetingRoleType>? roleBinds;

  /// 查看是否设置了自动静音/自动静音是否启用
  bool get isAudioControlEnable =>
      controls?.any((element) {
        if (element.controlType == NERoomControl.controlTypeAudio) {
          return (element as NEInRoomAudioControl).enabled;
        }
        return false;
      }) ??
      false;

  static NEMeetingItemSettings fromJson(Map<dynamic, dynamic>? map) {
    var setting = NEMeetingItemSettings();
    if (map != null) {
      Map? roomInfo = map['roomInfo'] as Map?;
      Map? roomProperties = roomInfo?['roomProperties'];
      Map? roomConfig = roomInfo?['roomConfig'];
      Map? resource = roomConfig?['resource'];
      setting.password = roomInfo?['password'] as String?;
      setting.roleBinds =
          (roomInfo?['roleBinds'] as Map<String, dynamic>?)?.map((key, value) {
        var roleType = MeetingRoles.mapStringRoleToEnum(value);
        return MapEntry(key, roleType);
      });
      Map? extraDataMap = roomProperties?['extraData'] as Map?;
      setting.cloudRecordOn = (resource?['record'] ?? false) as bool;
      setting.noSip = (resource?['sip'] ?? true) as bool;
      setting.extraData = extraDataMap?['value'] as String?;
      final audioOffMap = roomProperties?[AudioControlProperty.key] as Map?;
      final videoOffMap = roomProperties?[VideoControlProperty.key] as Map?;
      if (setting.controls == null) {
        setting.controls = [];
      }
      setting.controls!.add(NEInRoomAudioControl.fromJson(audioOffMap));
      setting.controls!.add(NEInRoomVideoControl.fromJson(videoOffMap));
      var liveSettings = NEMeetingItemLive();
      liveSettings.liveUrl = map['liveConfig']?['liveAddress'] as String?;
      liveSettings.enable = (resource?['live'] ?? false) as bool;
      Map? liveProperties = roomProperties?['live'] as Map?;
      var liveExtensionConfig = liveProperties?['extensionConfig'] as String?;
      if (liveExtensionConfig != null) {
        var map = jsonDecode(liveExtensionConfig);
        bool onlyEmployeesAllow = (map['onlyEmployeesAllow'] ?? false) as bool;
        liveSettings.liveWebAccessControlLevel = onlyEmployeesAllow
            ? NELiveAuthLevel.appToken.index
            : NELiveAuthLevel.normal.index;
      }
      setting.live = liveSettings;
    }
    return setting;
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
