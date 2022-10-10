// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_service;

class NERoomControl {
  static const controlTypeUnknown = -1;

  static const controlTypeAudio = 0;

  static const controlTypeVideo = 1;

  static const _controlTypeAudioKey = 'audio';

  static const _controlTypeVideoKey = 'video';

  final int controlType;

  Map<String, dynamic> toJson() => {
        if (controlType == controlTypeAudio) 'type': _controlTypeAudioKey,
        if (controlType == controlTypeVideo) 'type': _controlTypeVideoKey,
      };

  NERoomControl(this.controlType);

  factory NERoomControl.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    final offType = NERoomAttendeeOffType.values.firstWhere(
      (element) =>
          element.index ==
          (json['attendeeOff'] as int? ?? NERoomAttendeeOffType.none.index),
    );
    final enabled = (json['state'] as int?) == 1;
    final allowSelfOn = (json['allowSelfOn'] as bool?) == true;
    switch (type) {
      case _controlTypeAudioKey:
        return json.containsKey('state')
            ? NEInRoomAudioControl(
                enabled: enabled,
                allowSelfOn: allowSelfOn,
                attendeeOff: offType,
              )
            : NERoomAudioControl(offType);
      case _controlTypeVideoKey:
        return json.containsKey('state')
            ? NEInRoomVideoControl(
                enabled: enabled,
                allowSelfOn: allowSelfOn,
                attendeeOff: offType,
              )
            : NERoomVideoControl(offType);
      default:
        return NERoomControl(controlTypeUnknown);
    }
  }
}

class NERoomAudioControl extends NERoomControl {
  ///
  /// 音频控制类型
  ///
  var attendeeOff = NERoomAttendeeOffType.none;

  NERoomAudioControl([this.attendeeOff = NERoomAttendeeOffType.none])
      : super(NERoomControl.controlTypeAudio);

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'attendeeOff': attendeeOff.index,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NERoomAudioControl &&
          runtimeType == other.runtimeType &&
          controlType == other.controlType &&
          attendeeOff == other.attendeeOff;

  @override
  int get hashCode => controlType.hashCode ^ attendeeOff.hashCode;
}

class NERoomVideoControl extends NERoomControl {
  ///
  /// 视频控制类型
  ///
  var attendeeOff = NERoomAttendeeOffType.none;

  NERoomVideoControl([this.attendeeOff = NERoomAttendeeOffType.none])
      : super(NERoomControl.controlTypeVideo);

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'attendeeOff': attendeeOff.index,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NERoomVideoControl &&
          runtimeType == other.runtimeType &&
          controlType == other.controlType &&
          attendeeOff == other.attendeeOff;

  @override
  int get hashCode => controlType.hashCode ^ attendeeOff.hashCode;
}

enum NERoomAttendeeOffType {
  ///
  /// 无操作
  ///
  none,

  ///
  /// 自动关闭，允许自行解除
  ///
  offAllowSelfOn,

  ///
  /// 自动关闭，不允许自行解除
  ///
  offNotAllowSelfOn,
}

/// 房间内音频控制
class NEInRoomAudioControl extends NERoomAudioControl {
  ///
  /// 当前是否开启音频控制
  ///
  final bool enabled;

  ///
  /// 如果开启了控制，是否允许自行解除
  ///
  final bool allowSelfOn;

  NEInRoomAudioControl.none()
      : this(
          attendeeOff: NERoomAttendeeOffType.none,
          enabled: false,
          allowSelfOn: true,
        );

  factory NEInRoomAudioControl.fromJson(Map<dynamic, dynamic>? json) {
    bool allowSelfOn = true;
    bool enabled = false;
    NERoomAttendeeOffType attendeeOff = NERoomAttendeeOffType.none;
    if (json != null) {
      final value = json['value'] as String;
      if (value.startsWith(RegExp('${AudioControlProperty.offAllowSelfOn}'))) {
        allowSelfOn = true;
        enabled = true;
        attendeeOff = NERoomAttendeeOffType.offAllowSelfOn;
      } else if (value
          .startsWith(RegExp('${AudioControlProperty.offNotAllowSelfOn}'))) {
        allowSelfOn = false;
        enabled = true;
        attendeeOff = NERoomAttendeeOffType.offNotAllowSelfOn;
      }
    }
    return NEInRoomAudioControl(
        attendeeOff: attendeeOff, enabled: enabled, allowSelfOn: allowSelfOn);
  }

  NEInRoomAudioControl({
    required NERoomAttendeeOffType attendeeOff,
    required this.enabled,
    required this.allowSelfOn,
  }) : super(attendeeOff);

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'state': enabled ? 1 : 0,
        'allowSelfOn': allowSelfOn,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is NEInRoomAudioControl &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          allowSelfOn == other.allowSelfOn;

  @override
  int get hashCode => super.hashCode ^ enabled.hashCode ^ allowSelfOn.hashCode;
}

/// 房间内视频控制
class NEInRoomVideoControl extends NERoomVideoControl {
  ///
  /// 当前是否开启视频控制
  ///
  final bool enabled;

  ///
  /// 如果开启了控制，是否允许成员自行解除
  ///
  final bool allowSelfOn;

  NEInRoomVideoControl.none()
      : this(
          attendeeOff: NERoomAttendeeOffType.none,
          enabled: false,
          allowSelfOn: true,
        );

  factory NEInRoomVideoControl.fromJson(Map<dynamic, dynamic>? json) {
    bool allowSelfOn = true;
    bool enabled = false;
    NERoomAttendeeOffType attendeeOff = NERoomAttendeeOffType.none;
    if (json != null) {
      final value = json['value'] as String;
      if (value.startsWith(RegExp('${VideoControlProperty.offAllowSelfOn}'))) {
        allowSelfOn = true;
        enabled = true;
        attendeeOff = NERoomAttendeeOffType.offAllowSelfOn;
      } else if (value
          .startsWith(RegExp('${VideoControlProperty.offNotAllowSelfOn}'))) {
        allowSelfOn = false;
        enabled = true;
        attendeeOff = NERoomAttendeeOffType.offNotAllowSelfOn;
      }
    }
    return NEInRoomVideoControl(
        attendeeOff: attendeeOff, enabled: enabled, allowSelfOn: allowSelfOn);
  }

  NEInRoomVideoControl({
    required NERoomAttendeeOffType attendeeOff,
    required this.enabled,
    required this.allowSelfOn,
  }) : super(attendeeOff);

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'state': enabled ? 1 : 0,
        'allowSelfOn': allowSelfOn,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is NEInRoomVideoControl &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          allowSelfOn == other.allowSelfOn;

  @override
  int get hashCode => super.hashCode ^ enabled.hashCode ^ allowSelfOn.hashCode;
}
