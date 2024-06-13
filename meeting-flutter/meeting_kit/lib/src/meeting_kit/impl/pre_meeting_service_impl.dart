// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

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
        NEMessageChannelCallback(
            onCustomMessageReceiveCallback: (message) async {
      try {
        commonLogger.i('scheduleMeeting ,message ${message.data}');
        List<NEMeetingItem> changeItems = [];

        var data = jsonDecode(message.data);
        final type = data['type'] as int?;
        final meetingType = data['meetingType'] as int?;
        final state =
            data['state'] as int? ?? NEMeetingItemStatus.invalid.index;
        final preState =
            data['preState'] as int? ?? NEMeetingItemStatus.invalid.index;

        if ((type == kTypeMeetingInfoChanged &&
                meetingType == NEMeetingType.kReservation.type) ||
            (type == kTypeMeetingStateChanged &&
                state != preState &&
                state <= NEMeetingItemStatus.ended.index)) {
          final result =
              await getMeetingItemByNum(data['meetingNum'] as String);
          if (result.isSuccess() &&
              result.nonNullData.meetingType == NEMeetingType.kReservation) {
            changeItems.add(result.nonNullData);
          }
        } else if (type == kTypeMeetingStateChanged &&
            state > NEMeetingItemStatus.ended.index) {
          // 已经结束的会议查询会议信息会失败，所以不能走getMeetingItemById接口增量查询，需要全量查询一次
          changeItems.add(NEMeetingItem.fromJson({
            'roomUuid': data['meetingNum'],
            'meetingNum': data['meetingNum'],
            'meetingId': data['meetingId'],
            'state': state,
            'type': meetingType,
          }));
        }

        /// 预约会议指定成员后，移除指定成员收到该事件
        else if (type == kTypeMeetingScheduleInviteCancel) {
          changeItems.add(NEMeetingItem.fromJson({
            'roomUuid': data['meetingNum'],
            'meetingNum': data['meetingNum'],
            'meetingId': data['meetingId'],
            'type': meetingType,
            'state': NEMeetingItemStatus.cancel.index,
          }));
        }

        if (changeItems.isNotEmpty) {
          for (var listener in _listeners.toList()) {
            listener.onMeetingItemInfoChanged(changeItems);
          }
        }
      } catch (e) {
        debugPrint('parse message channel service message error: $e');
      }
    }));
  }

  final _listeners = <NEPreMeetingListener>{};

  @override
  Future<NEResult<List<NERemoteHistoryMeeting>>> getFavoriteMeetingList(
      int? anchorId, int limit) {
    apiLogger.i('getFavoriteMeetings $anchorId $limit');
    return PreRoomRepository.getFavoriteMeetings(anchorId, limit);
  }

  @override
  Future<NEResult<int>> addFavoriteMeeting(int meetingId) {
    apiLogger.i('addFavoriteMeeting $meetingId');
    return PreRoomRepository.addFavoriteMeeting(meetingId);
  }

  @override
  Future<VoidResult> removeFavoriteMeeting(int meetingId) {
    apiLogger.i('removeFavoriteMeeting $meetingId');
    return PreRoomRepository.removeFavoriteMeetingByRoomArchiveId(meetingId);
  }

  @override
  Future<NEResult<List<NERemoteHistoryMeeting>>> getHistoryMeetingList(
      int anchorId, int limit) {
    apiLogger.i('getHistoryMeetingList $anchorId $limit');
    return PreRoomRepository.getHistoryMeetings(anchorId, limit);
  }

  @override
  Future<NEResult<NERemoteHistoryMeetingDetail>> getHistoryMeetingDetail(
      int meetingId) {
    apiLogger.i('getHistoryMeetingDetail $meetingId');
    return PreRoomRepository.getHistoryMeetingDetail(meetingId);
  }

  @override
  Future<NEResult<NERemoteHistoryMeeting>> getHistoryMeeting(int meetingId) {
    apiLogger.i('getHistoryMeeting $meetingId');
    return PreRoomRepository.getHistoryMeeting(meetingId);
  }

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
  Future<NEResult<NEMeetingItem>> getMeetingItemById(int meetingId) {
    apiLogger.i('getMeetingItemById $meetingId');
    return PreRoomRepository.getMeetingItemById(meetingId);
  }

  @override
  Future<NEResult<List<NEMeetingItem>>> getMeetingList(
      List<NEMeetingItemStatus> status) {
    apiLogger.i('getMeetingList ,status${status.toString()}');
    return PreRoomRepository.getRoomList(status);
  }

  @override
  Future<NEResult<List<NEScheduledMember>>> getScheduledMeetingMemberList(
      String meetingNum) {
    apiLogger.i('getScheduledMeetingMemberList $meetingNum');
    return PreRoomRepository.getScheduledMembers(meetingNum);
  }

  @override
  void addListener(NEPreMeetingListener listener) {
    apiLogger.i('addListener');
    _listeners.add(listener);
  }

  @override
  void removeListener(NEPreMeetingListener listener) {
    apiLogger.i('removeListener');
    _listeners.remove(listener);
  }
}
