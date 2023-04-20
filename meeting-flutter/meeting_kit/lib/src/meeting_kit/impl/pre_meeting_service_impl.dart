// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

typedef ScheduledRoomStatusListener<T> = void Function(
    T data, bool incremental);

/// 预定会议实现类
class _NEPreMeetingServiceImpl extends NEPreMeetingService {
  static const _tag = 'NEPreMeetingService';

  static const kTypeMeetingInfoChanged = 100;
  static const kTypeMeetingStateChanged = 101;

  static final _NEPreMeetingServiceImpl _instance =
      _NEPreMeetingServiceImpl._();

  factory _NEPreMeetingServiceImpl() => _instance;

  _NEPreMeetingServiceImpl._() {
    NERoomKit.instance.messageChannelService.addMessageChannelCallback(
        NEMessageChannelCallback(onReceiveCustomMessage: (message) async {
      Alog.i(
          tag: _tag,
          moduleName: _moduleName,
          type: AlogType.api,
          content: 'scheduleMeeting ,message ${message.data}');
      List<NEMeetingItem> changeItems = [];

      var data = jsonDecode(message.data);
      int type = data['type'] as int;
      final meetingType = data['meetingType'];
      final state = data['state'] as int? ?? NEMeetingState.invalid.index;
      final preState = data['preState'] as int? ?? NEMeetingState.invalid.index;

      if ((type == kTypeMeetingInfoChanged &&
              meetingType == NEMeetingType.kReservation.type) ||
          (type == kTypeMeetingStateChanged &&
              state != preState &&
              state <= NEMeetingState.ended.index)) {
        final result = await getMeetingItemById(data['meetingNum'] as String);
        if (result.isSuccess() &&
            result.nonNullData.meetingType == NEMeetingType.kReservation.type) {
          changeItems.add(result.nonNullData);
        }
      } else if (type == kTypeMeetingStateChanged &&
          state > NEMeetingState.ended.index) {
        // 已经结束的会议查询会议信息会失败，所以不能走getMeetingItemById接口增量查询，需要全量查询一次
        changeItems.add(NEMeetingItem.fromJson({
          'roomUuid': data['meetingNum'],
          'meetingNum': data['meetingNum'],
          'meetingId': data['meetingId'],
          'state': state,
        }));
      }

      if (changeItems.isNotEmpty) {
        for (var listener in _listeners.toList()) {
          listener(changeItems, true);
        }
      }
    }));
  }

  final List<ScheduleCallback<List<NEMeetingItem>>> _listeners =
      <ScheduledRoomStatusListener<List<NEMeetingItem>>>[];

  @override
  Future<NEResult<NEMeetingItem>> scheduleMeeting(NEMeetingItem item) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'scheduleMeeting ,item${item.toString()}');
    return PreRoomRepository.scheduleRoom(item);
  }

  @override
  Future<NEResult<NEMeetingItem>> editMeeting(NEMeetingItem item) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'editMeeting ,item${item.toString()}');
    return PreRoomRepository.editRoom(item);
  }

  @override
  Future<NEResult<void>> cancelMeeting(int meetingId) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'cancelMeeting $meetingId');
    return PreRoomRepository.cancelRoom(meetingId);
  }

  @override
  Future<NEResult<NEMeetingItem>> getMeetingItemById(String meetingNum) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'getMeetingItemById $meetingNum');
    return PreRoomRepository.getRoomItemById(meetingNum);
  }

  @override
  Future<NEResult<List<NEMeetingItem>>> getMeetingList(
      List<NEMeetingState> status) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'getMeetingList ,status${status.toString()}');
    return PreRoomRepository.getRoomList(status);
  }

  @override
  void registerScheduleMeetingStatusChange(
      ScheduleCallback<List<NEMeetingItem>> callback) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'registerScheduleMeetingStatusChange');
    if (_listeners.contains(callback)) {
      return;
    }
    _listeners.add(callback);
  }

  @override
  void unRegisterScheduleMeetingStatusChange(
      ScheduleCallback<List<NEMeetingItem>> callback) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'unRegisterScheduleMeetingStatusChange');
    if (_listeners.contains(callback)) {
      _listeners.remove(callback);
    }
  }
}
