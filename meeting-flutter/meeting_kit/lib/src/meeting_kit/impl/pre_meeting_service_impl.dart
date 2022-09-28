// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

typedef ScheduledRoomStatusListener<T> = void Function(
    T data, bool incremental);

/// 预定会议实现类
class _NEPreMeetingServiceImpl extends NEPreMeetingService {
  static const _tag = 'NEPreMeetingService';
  static final _NEPreMeetingServiceImpl _instance =
      _NEPreMeetingServiceImpl._();

  factory _NEPreMeetingServiceImpl() => _instance;

  _NEPreMeetingServiceImpl._() {
    NERoomKit.instance.messageChannelService.addMessageChannelCallback(
        NEMessageChannelCallback(onReceiveCustomMessage: (message) {
      Alog.i(
          tag: _tag,
          moduleName: _moduleName,
          type: AlogType.api,
          content: 'scheduleMeeting ,message ${message.data}');
      var data = jsonDecode(message.data);
      int type = data['type'] as int;
      var meetingType = data['meetingType'];
      if ((type == 100 && meetingType == NEMeetingType.kReservation.type) ||
          type == 101) {
        List<NEMeetingItem> changeItems = [];
        var meetingNum = data['meetingNum'] as String;
        getMeetingItemById(meetingNum).then((result) {
          if (result.isSuccess() &&
              result.nonNullData.meetingType ==
                  NEMeetingType.kReservation.type) {
            NEMeetingItem item = result.nonNullData;
            changeItems.add(item);
            for (var callback in _listeners) {
              callback(changeItems, true);
            }
          }
        });
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
  Future<NEResult<void>> cancelMeeting(int uniqueId) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'cancelMeeting $uniqueId');
    return PreRoomRepository.cancelRoom(uniqueId);
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
