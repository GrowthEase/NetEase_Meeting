// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class _MeetingItemImpl extends NEMeetingItem {
  _MeetingItemImpl() : super._();

  String? _roomUuid;

  int? _roomConfigId;

  String? _meetingNum;

  int? _meetingId;

  String? _shortMeetingNum;

  String? _subject;

  int? _startTime;

  int? _endTime;

  String? _password;

  bool _noSip = true;

  NEMeetingItemSettings? _setting;

  NEMeetingItemLive? _live;

  Map<String, NEMeetingRoleType>? _roleBinds;

  NEMeetingState _state = NEMeetingState.invalid;

  @override
  String? get meetingNum => _meetingNum;

  set meetingNum(String? meetingNum) {
    _meetingNum = meetingNum;
  }

  @override
  String? get shortMeetingNum => _shortMeetingNum;

  set shortMeetingNum(String? shortMeetingNum) {
    _shortMeetingNum = shortMeetingNum;
  }

  @override
  String? get roomUuid => _roomUuid;

  set roomUuid(String? roomUuid) {
    _roomUuid = roomUuid;
  }

  @override
  int? get roomConfigId => _roomConfigId;

  set roomConfigId(int? roomConfigId) {
    _roomConfigId = roomConfigId;
  }

  @override
  String? get subject => _subject;

  @override
  set subject(String? subject) {
    _subject = subject;
  }

  @override
  int get startTime => _startTime ?? 0;

  @override
  set startTime(int start) {
    _startTime = start;
  }

  @override
  int get endTime => _endTime ?? 0;

  @override
  set endTime(int end) {
    _endTime = end;
  }

  @override
  String? get password => _password;

  @override
  set password(String? password) {
    _password = password;
  }

  @override
  set noSip(bool? noSip) {
    _noSip = noSip ?? true;
  }

  @override
  bool get noSip => _noSip;

  @override
  NEMeetingItemSettings get settings => _setting ?? NEMeetingItemSettings();

  @override
  set settings(NEMeetingItemSettings setting) {
    _setting = setting;
  }

  @override
  NEMeetingState get state => _state;

  set state(NEMeetingState status) {
    _state = status;
  }

  @override
  String? extraData;

  @override
  int? get meetingId => _meetingId;

  set meetingId(int? meetingId) {
    _meetingId = meetingId;
  }

  @override
  NEMeetingItemLive? get live => _live;

  set live(NEMeetingItemLive? live) {
    _live = live;
  }

  @override
  Map<String, NEMeetingRoleType>? get roleBinds => _roleBinds;

  set roleBinds(Map<String, NEMeetingRoleType>? roleBinds) {
    _roleBinds = roleBinds;
  }

  String? _inviteUrl;

  @override
  get inviteUrl => _inviteUrl;

  set inviteUrl(String? value) {
    _inviteUrl = value;
  }

  Map handleRoomProperties() {
    var roomProperties = {}; // 参考 创建会议 ，从seeting里获取controls就可以了
    if (settings.controls?.isEmpty ?? true) {
      // 如果controls为空，说明没有启用 自动静音 和 自动关闭视频
      roomProperties[AudioControlProperty.key] = AudioControlProperty.disable;
      roomProperties[VideoControlProperty.key] = VideoControlProperty.disable;
    }
    settings.controls?.forEach((control) {
      if (control is NERoomAudioControl) {
        roomProperties[AudioControlProperty.key] =
            control.attendeeOff == NERoomAttendeeOffType.none
                ? AudioControlProperty.disable
                : (control.attendeeOff == NERoomAttendeeOffType.offAllowSelfOn
                    ? AudioControlProperty.offAllowSelfOn
                    : AudioControlProperty.offNotAllowSelfOn);
      }
      if (control is NERoomVideoControl) {
        roomProperties[VideoControlProperty.key] =
            control.attendeeOff == NERoomAttendeeOffType.none
                ? VideoControlProperty.disable
                : (control.attendeeOff == NERoomAttendeeOffType.offAllowSelfOn
                    ? VideoControlProperty.offAllowSelfOn
                    : VideoControlProperty.offNotAllowSelfOn);
      }
    });
    roomProperties[MeetingPropertyKeys.kExtraData] = extraData;
    Map map = roomProperties.map((k, v) => MapEntry(k, {'value': v}));
    if (live?.enable ?? false) {
      map['live'] = handleLiveProperties();
    }
    return map;
  }

  ///处理直播属性
  Map handleLiveProperties() {
    bool onlyEmployeesAllow =
        live?.liveWebAccessControlLevel == NELiveAuthLevel.appToken.index;
    var map = {
      'onlyEmployeesAllow': onlyEmployeesAllow,
      'liveChatRoomEnable': true
    };
    String jsonStr = jsonEncode(map);
    return {'extensionConfig': jsonStr};
  }

  @override
  Map toJson() => {
        /// flutter 传递 native 使用
        'roomUuid': _roomUuid,
        if (_subject != null) 'subject': _subject,
        'meetingNum': _meetingNum,
        'meetingId': _meetingId,
        'startTime': _startTime,
        'endTime': _endTime,
        'status': _state.index,
        'updateTime': 0,
        'createTime': 0,
        if (extraData != null) 'extraData': extraData,
        if (_password != null) 'password': _password,
        'settings': {
          'cloudRecordOn': settings.cloudRecordOn &&
              SDKConfig.current.isCloudRecordSupported,
          'controls':
              settings.controls?.map((e) => e.toJson()).toList(growable: false)
        },
        'live': live?.toJson(),
        'roleBinds':
            _roleBinds?.map((key, value) => MapEntry(key, value.index)),
        'noSip': !_noSip
      };

  @override
  Map request() {
    Map map = {
      'subject': _subject,
      'startTime': _startTime,
      'endTime': _endTime,
      'password': _password,
      'roomConfigId': _roomConfigId ?? kMeetingTemplateId,
      'roomProperties': handleRoomProperties(),
      'roomConfig': {
        'resource': {
          'live': live?.enable,
          'record': settings.cloudRecordOn,
          'sip': !_noSip
        }
      },
      if (_roleBinds != null)
        'roleBinds': _roleBinds?.map((key, value) {
          var roleType = MeetingRoles.mapEnumRoleToString(value);
          return MapEntry(key, roleType);
        })
    };
    return map;
  }

  static _MeetingItemImpl _fromNativeJson(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return _MeetingItemImpl();
    }
    var impl = _MeetingItemImpl();
    impl.subject = map['subject'] as String?;
    impl.meetingId = map['meetingId'] as int?;
    impl.startTime = (map['startTime'] ?? 0) as int;
    impl.endTime = (map['endTime'] ?? 0) as int;
    impl.noSip = (map['noSip'] ?? true) as bool;
    impl.state = _MeetingStateExtension.fromState(map['state'] as int);
    impl.password = map['password'] as String?;
    impl.roleBinds =
        ((map['roleBinds']) as Map<String, dynamic>?)?.map((key, value) {
      var roleType = MeetingRoles.mapIntRoleToEnum(value);
      return MapEntry(key, roleType);
    });
    impl.live = NEMeetingItemLive.fromJson(map['live']);
    impl.extraData = map['extraData'] as String?;
    impl.settings = NEMeetingItemSettings.fromNativeJson(map['settings']);
    return impl;
  }

  /// 解析 服务端数据
  static _MeetingItemImpl _fromJson(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return _MeetingItemImpl();
    }
    var impl = _MeetingItemImpl();
    impl.roomUuid = map['roomUuid'] as String?;
    impl.subject = map['subject'] as String?;
    impl.meetingType = map['type'] as int?;
    impl.meetingNum = map['meetingNum'] as String?;
    impl.meetingId = map['meetingId'] as int?;
    impl.shortMeetingNum = map['shortMeetingNum'] as String?;
    impl.startTime = (map['startTime'] ?? 0) as int;
    impl.endTime = (map['endTime'] ?? 0) as int;
    impl.state = _MeetingStateExtension.fromState(map['state'] as int);
    var settings = NEMeetingItemSettings.fromJson(map['settings'] as Map?);
    impl.settings = settings;
    impl.live = settings.live;
    impl.password = settings.password;
    impl.extraData = settings.extraData;
    impl.roleBinds = settings.roleBinds;
    impl.noSip = settings.noSip;
    impl.inviteUrl = map['meetingInviteUrl'] as String?;
    return impl;
  }

  @override
  String toString() => toJson().toString();

  @override
  int? meetingType;
}
