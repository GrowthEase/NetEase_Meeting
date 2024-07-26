// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_core;

class NEMeetingControl {
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

  NEMeetingControl(this.controlType);

  factory NEMeetingControl.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    final offType = NEMeetingAttendeeOffType.values.firstWhere(
      (element) =>
          element.index ==
          (json['attendeeOff'] as int? ?? NEMeetingAttendeeOffType.none.index),
    );
    final enabled = (json['state'] as int?) == 1;
    final allowSelfOn = (json['allowSelfOn'] as bool?) == true;
    switch (type) {
      case _controlTypeAudioKey:
        return json.containsKey('state')
            ? NEInMeetingAudioControl(
                enabled: enabled,
                allowSelfOn: allowSelfOn,
                attendeeOff: offType,
              )
            : NEMeetingAudioControl(offType);
      case _controlTypeVideoKey:
        return json.containsKey('state')
            ? NEInMeetingVideoControl(
                enabled: enabled,
                allowSelfOn: allowSelfOn,
                attendeeOff: offType,
              )
            : NEMeetingVideoControl(offType);
      default:
        return NEMeetingControl(controlTypeUnknown);
    }
  }
}

class NEMeetingAudioControl extends NEMeetingControl {
  ///
  /// 音频控制类型
  ///
  var attendeeOff = NEMeetingAttendeeOffType.none;

  NEMeetingAudioControl([this.attendeeOff = NEMeetingAttendeeOffType.none])
      : super(NEMeetingControl.controlTypeAudio);

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'attendeeOff': attendeeOff.index,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NEMeetingAudioControl &&
          runtimeType == other.runtimeType &&
          controlType == other.controlType &&
          attendeeOff == other.attendeeOff;

  @override
  int get hashCode => controlType.hashCode ^ attendeeOff.hashCode;
}

class NEMeetingVideoControl extends NEMeetingControl {
  ///
  /// 视频控制类型
  ///
  var attendeeOff = NEMeetingAttendeeOffType.none;

  NEMeetingVideoControl([this.attendeeOff = NEMeetingAttendeeOffType.none])
      : super(NEMeetingControl.controlTypeVideo);

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'attendeeOff': attendeeOff.index,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NEMeetingVideoControl &&
          runtimeType == other.runtimeType &&
          controlType == other.controlType &&
          attendeeOff == other.attendeeOff;

  @override
  int get hashCode => controlType.hashCode ^ attendeeOff.hashCode;
}

enum NEMeetingAttendeeOffType {
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
class NEInMeetingAudioControl extends NEMeetingAudioControl {
  ///
  /// 当前是否开启音频控制
  ///
  final bool enabled;

  ///
  /// 如果开启了控制，是否允许自行解除
  ///
  final bool allowSelfOn;

  NEInMeetingAudioControl.none()
      : this(
          attendeeOff: NEMeetingAttendeeOffType.none,
          enabled: false,
          allowSelfOn: true,
        );

  factory NEInMeetingAudioControl.fromJson(Map<dynamic, dynamic>? json) {
    bool allowSelfOn = true;
    bool enabled = false;
    NEMeetingAttendeeOffType attendeeOff = NEMeetingAttendeeOffType.none;
    if (json != null && json['value'] != null) {
      final value = json['value'] as String;
      if (value.startsWith(RegExp('${AudioControlProperty.offAllowSelfOn}'))) {
        allowSelfOn = true;
        enabled = true;
        attendeeOff = NEMeetingAttendeeOffType.offAllowSelfOn;
      } else if (value
          .startsWith(RegExp('${AudioControlProperty.offNotAllowSelfOn}'))) {
        allowSelfOn = false;
        enabled = true;
        attendeeOff = NEMeetingAttendeeOffType.offNotAllowSelfOn;
      }
    }
    return NEInMeetingAudioControl(
        attendeeOff: attendeeOff, enabled: enabled, allowSelfOn: allowSelfOn);
  }

  NEInMeetingAudioControl({
    required NEMeetingAttendeeOffType attendeeOff,
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
          other is NEInMeetingAudioControl &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          allowSelfOn == other.allowSelfOn;

  @override
  int get hashCode => super.hashCode ^ enabled.hashCode ^ allowSelfOn.hashCode;
}

/// 房间内视频控制
class NEInMeetingVideoControl extends NEMeetingVideoControl {
  ///
  /// 当前是否开启视频控制
  ///
  final bool enabled;

  ///
  /// 如果开启了控制，是否允许成员自行解除
  ///
  final bool allowSelfOn;

  NEInMeetingVideoControl.none()
      : this(
          attendeeOff: NEMeetingAttendeeOffType.none,
          enabled: false,
          allowSelfOn: true,
        );

  factory NEInMeetingVideoControl.fromJson(Map<dynamic, dynamic>? json) {
    bool allowSelfOn = true;
    bool enabled = false;
    NEMeetingAttendeeOffType attendeeOff = NEMeetingAttendeeOffType.none;
    if (json != null && json['value'] != null) {
      final value = json['value'] as String;
      if (value.startsWith(RegExp('${VideoControlProperty.offAllowSelfOn}'))) {
        allowSelfOn = true;
        enabled = true;
        attendeeOff = NEMeetingAttendeeOffType.offAllowSelfOn;
      } else if (value
          .startsWith(RegExp('${VideoControlProperty.offNotAllowSelfOn}'))) {
        allowSelfOn = false;
        enabled = true;
        attendeeOff = NEMeetingAttendeeOffType.offNotAllowSelfOn;
      }
    }
    return NEInMeetingVideoControl(
        attendeeOff: attendeeOff, enabled: enabled, allowSelfOn: allowSelfOn);
  }

  NEInMeetingVideoControl({
    required NEMeetingAttendeeOffType attendeeOff,
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
          other is NEInMeetingVideoControl &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          allowSelfOn == other.allowSelfOn;

  @override
  int get hashCode => super.hashCode ^ enabled.hashCode ^ allowSelfOn.hashCode;
}
