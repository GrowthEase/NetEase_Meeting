// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

typedef ScheduledRoomStatusListener<T> = void Function(
    T data, bool incremental);

/// 预定会议实现类
class _NEPreMeetingServiceImpl extends NEPreMeetingService with _AloggerMixin {
  static const kTypeMeetingInfoChanged = 100;
  static const kTypeMeetingStateChanged = 101;
  static const kTypeMeetingScheduleInviteCancel = 201;

  static final _NEPreMeetingServiceImpl _instance =
      _NEPreMeetingServiceImpl._();

  factory _NEPreMeetingServiceImpl() => _instance;

  _NEPreMeetingServiceImpl._() {
    NERoomKit.instance.messageChannelService.addMessageChannelCallback(
        NEMessageChannelCallback(onReceiveCustomMessage: (message) async {
      try {
        commonLogger.i('scheduleMeeting ,message ${message.data}');
        List<NEMeetingItem> changeItems = [];

        var data = jsonDecode(message.data);
        final type = data['type'] as int?;
        final meetingType = data['meetingType'] as int?;
        final state = data['state'] as int? ?? NEMeetingState.invalid.index;
        final preState =
            data['preState'] as int? ?? NEMeetingState.invalid.index;

        if ((type == kTypeMeetingInfoChanged &&
                meetingType == NEMeetingType.kReservation.type) ||
            (type == kTypeMeetingStateChanged &&
                state != preState &&
                state <= NEMeetingState.ended.index)) {
          final result =
              await getMeetingItemByNum(data['meetingNum'] as String);
          if (result.isSuccess() &&
              result.nonNullData.meetingType ==
                  NEMeetingType.kReservation.type) {
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

        /// 预约会议指定成员后，移除指定成员收到该事件
        else if (type == kTypeMeetingScheduleInviteCancel) {
          changeItems.add(NEMeetingItem.fromJson({
            'roomUuid': data['meetingNum'],
            'meetingNum': data['meetingNum'],
            'meetingId': data['meetingId'],
            'state': NEMeetingState.cancel.index,
          }));
        }

        if (changeItems.isNotEmpty) {
          for (var listener in _listeners.toList()) {
            listener(changeItems, true);
          }
        }
      } catch (e) {
        debugPrint('parse message channel service message error: $e');
      }
    }));
  }

  final List<ScheduleCallback<List<NEMeetingItem>>> _listeners =
      <ScheduledRoomStatusListener<List<NEMeetingItem>>>[];

  @override
  Future<NEResult<NEMeetingItem>> scheduleMeeting(NEMeetingItem item) {
    apiLogger.i('scheduleMeeting ,item${item.toString()}');
    return PreRoomRepository.scheduleRoom(item);
  }

  @override
  Future<NEResult<NEMeetingItem>> editMeeting(
      NEMeetingItem item, bool editRecurringMeeting) {
    apiLogger.i('editMeeting ,item${item.toString()} $editRecurringMeeting');
    return PreRoomRepository.editRoom(item, editRecurringMeeting);
  }

  @override
  Future<NEResult<void>> cancelMeeting(
      int meetingId, bool cancelRecurringMeeting) {
    apiLogger.i('cancelMeeting $meetingId $cancelRecurringMeeting');
    return PreRoomRepository.cancelRoom(meetingId, cancelRecurringMeeting);
  }

  @override
  Future<NEResult<NEMeetingItem>> getMeetingItemByNum(String meetingNum) {
    apiLogger.i('getMeetingItemByNum $meetingNum');
    return PreRoomRepository.getRoomItemByNum(meetingNum);
  }

  @override
  Future<NEResult<List<NEMeetingItem>>> getMeetingList(
      List<NEMeetingState> status) {
    apiLogger.i('getMeetingList ,status${status.toString()}');
    return PreRoomRepository.getRoomList(status);
  }

  @override
  void registerScheduleMeetingStatusChange(
      ScheduleCallback<List<NEMeetingItem>> callback) {
    apiLogger.i('registerScheduleMeetingStatusChange');
    if (_listeners.contains(callback)) {
      return;
    }
    _listeners.add(callback);
  }

  @override
  void unRegisterScheduleMeetingStatusChange(
      ScheduleCallback<List<NEMeetingItem>> callback) {
    apiLogger.i('unRegisterScheduleMeetingStatusChange');
    if (_listeners.contains(callback)) {
      _listeners.remove(callback);
    }
  }

  @override
  Future<NEResult<NEMeetingItem>> getMeetingItemById(int meetingId) {
    apiLogger.i('getMeetingItemById $meetingId');
    return PreRoomRepository.getMeetingItemById(meetingId);
  }

  @override
  Future<NEResult<List<NEScheduledMember>>> getScheduledMembers(
      String meetingNum) {
    apiLogger.i('getScheduledMembers $meetingNum');
    return PreRoomRepository.getScheduledMembers(meetingNum);
  }
}
