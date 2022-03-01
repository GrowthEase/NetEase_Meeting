// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_sdk;

/// 预定会议实现类
class _NEPreMeetingServiceImpl extends NEPreMeetingService {
  static const _tag = 'NEPreMeetingService';
  static final _NEPreMeetingServiceImpl _instance =
      _NEPreMeetingServiceImpl._();

  factory _NEPreMeetingServiceImpl() => _instance;

  _NEPreMeetingServiceImpl._();

  @override
  NERoomItem createScheduleMeetingItem() {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'createScheduleMeetingItem');
    return NERoomItem();
  }

  @override
  Future<NEResult<NERoomItem>> scheduleMeeting(NERoomItem item) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'scheduleMeeting ,item${item.toString()}');
    if (item.subject == null) {
      return Future.value(NEResult(code: RoomErrorCode.paramsError));
    }
    return NERoomKit.instance.getPreRoomService().scheduleRoom(item);
  }

  @override
  Future<NEResult<NERoomItem>> editMeeting(NERoomItem item) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'editMeeting ,item${item.toString()}');
    if (item.subject == null) {
      return Future.value(NEResult(code: RoomErrorCode.paramsError));
    }
    return NERoomKit.instance.getPreRoomService().editRoom(item);
  }

  @override
  Future<NEResult<void>> cancelMeeting(int uniqueId) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'cancelMeeting $uniqueId');
    return NERoomKit.instance.getPreRoomService().cancelRoom(uniqueId);
  }

  // @override
  // Future<NEResult<void>> deleteMeeting(int meetingUniqueId) {
  //   Alog.i(
  //       tag: _tag,
  //       moduleName: moduleName,
  //       type: AlogType.api,
  //       content: 'deleteMeeting ,meetingUniqueId$meetingUniqueId');
  //   if (meetingUniqueId == null) {
  //     return Future.value(NEResult(code: ErrorCode.paramsError));
  //   }
  //   return PreRoomRepository.deleteRoom(meetingUniqueId);
  // }

  @override
  Future<NEResult<NERoomItem>> getMeetingItemById(int uniqueId) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'getMeetingItemById $uniqueId');
    return NERoomKit.instance.getPreRoomService().getRoomItemByUniqueId(uniqueId);
  }

  @override
  Future<NEResult<List<NERoomItem>>> getMeetingList(
      List<NERoomItemStatus> status) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'getMeetingList ,status${status.toString()}');
    return NERoomKit.instance.getPreRoomService().getRoomList(status);
  }

  @override
  void registerScheduleMeetingStatusChange(
      ScheduleCallback<List<NERoomItem>> callback) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'registerScheduleMeetingStatusChange');
    NERoomKit.instance.getPreRoomService().addScheduledRoomStatusListener(callback);
  }

  @override
  void unRegisterScheduleMeetingStatusChange(
      ScheduleCallback<List<NERoomItem>> callback) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'unRegisterScheduleMeetingStatusChange');
    NERoomKit.instance.getPreRoomService().removeScheduledRoomStatusListener(callback);
  }
}
