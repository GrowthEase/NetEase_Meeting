// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

const _kComponent = 'MeetingKit';
const _kVersion = SDKConfig.sdkVersionName;
const _kFramework = 'Flutter';

const _kEventLogin = "${_kComponent}_login";
const _kLoginStepAccountInfo = "account_info";
const _kLoginStepRoomKitLogin = "roomkit_login";
const _kLoginTypeToken = "token";
const _kLoginTypePassword = "password";
const _kLoginTypeAnonymous = "anonymous";

const kEventStartMeeting = "${_kComponent}_start_meeting";
const kMeetingStepCreateRoom = "create_room";
const kMeetingStepJoinRoom = "join_room";
const kMeetingStepJoinRtc = "join_rtc";
const kMeetingStepServerNotifyJoinRtc = "server_join_rtc";

const kEventJoinMeeting = "${_kComponent}_join_meeting";
const kMeetingStepMeetingInfo = "meeting_info";
const kMeetingStepAnonymousLogin = "anonymous_login";

const kEventMeetingEnd = "${_kComponent}_meeting_end";

const kEventParamUserId = 'userId';
const kEventParamType = 'type';
const kEventParamMeetingId = "meetingId";
const kEventParamMeetingNum = "meetingNum";
const kEventParamRoomArchiveId = "roomArchiveId";
const kEventParamReason = "reason";
const kEventParamMeetingDuration = "meetingDuration";
const kEventParamInputPasswordElapsed = "inputPasswordCost";
const kEventParamRequestPermissionElapsed = "requestPermissionCost";

abstract class TimeConsumingOperation {
  final int _startTime;
  int _endTime = 0;
  int _duration = 0;
  int _adjustDuration = 0;
  int? _code;
  String? _msg;
  String? _requestId;
  int _serverCost = 0;

  TimeConsumingOperation({int? startTime})
      : _startTime = startTime ?? DateTime.now().millisecondsSinceEpoch;

  TimeConsumingOperation setResult(
    int code, [
    String? message,
    String? requestId,
    int serverCost = 0,
  ]) {
    if (_code == null) {
      _code = code;
      _msg = message;
      _requestId = requestId;
      _serverCost = serverCost;
      _endTime = DateTime.now().millisecondsSinceEpoch;
      _duration = _endTime - _startTime - _adjustDuration;
    }
    return this;
  }

  final params = <String, dynamic>{};

  TimeConsumingOperation setParams(Map<String, dynamic> params) {
    this.params
      ..clear()
      ..addAll(params);
    return this;
  }

  TimeConsumingOperation addParam(String key, dynamic value) {
    if (value != null) params[key] = value;
    return this;
  }

  TimeConsumingOperation removeParam(String key) {
    params.remove(key);
    return this;
  }

  void setAdjustDuration(int duration) {
    _adjustDuration = duration;
  }

  void addAdjustDuration(int duration) {
    _adjustDuration += duration;
  }

  Map<String, dynamic> toMap() {
    final props = {
      'timeStamp': _startTime,
      'startTime': _startTime,
      'endTime': _endTime,
      'duration': _duration,
      if (_code != null) 'code': _code,
      if (_msg != null) 'message': _msg,
      if (_requestId != null) 'requestId': _requestId,
      if (_serverCost != 0) 'serverCost': _serverCost,
      if (params.isNotEmpty) 'params': params,
    };
    return props;
  }
}

class IntervalStep extends TimeConsumingOperation {
  final String name;

  IntervalStep(this.name);

  @override
  Map<String, dynamic> toMap() {
    final props = super.toMap();
    props['step'] = name;
    return props;
  }
}

enum EventPriority {
  LOW,
  NORMAL,
  HIGH,
}

abstract class Event {
  String get eventId;
  EventPriority get priority;
  Map<String, dynamic> toMap();
}

class IntervalEvent extends TimeConsumingOperation implements Event {
  @override
  final String eventId;

  final EventPriority priority;

  final steps = LinkedHashMap<String, IntervalStep>();

  IntervalEvent(
    this.eventId, {
    this.priority = EventPriority.NORMAL,
    super.startTime,
  });

  IntervalStep beginStep(String name) {
    steps.remove(name);
    final step = IntervalStep(name);
    steps[name] = step;
    return step;
  }

  IntervalEvent endStep(
    int code, [
    String? message,
    String? requestId,
    int serverCost = 0,
  ]) {
    _currentStep()?.setResult(code, message, requestId, serverCost);
    return this;
  }

  IntervalStep? getStep(String name) {
    return steps[name];
  }

  IntervalStep? _currentStep() {
    return steps.values.lastOrNull;
  }

  @override
  Map<String, dynamic> toMap() {
    final lastStep = _currentStep();
    if (_code == null && lastStep != null && lastStep._code != null) {
      setResult(lastStep._code!, lastStep._msg, lastStep._requestId);
    }
    final props = super.toMap();
    final itemList = steps.values.toList();
    if (itemList.isNotEmpty) {
      props['steps'] = itemList.asMap().entries.map((entry) {
        final index = entry.key;
        final intervalStep = entry.value;
        final stepMap = intervalStep.toMap();
        stepMap['index'] = index;
        return stepMap;
      }).toList();
    }
    return props;
  }
}
