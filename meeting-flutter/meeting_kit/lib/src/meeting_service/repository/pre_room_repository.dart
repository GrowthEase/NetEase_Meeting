// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 会议前服务
class PreRoomRepository {
  ///预约会议
  static Future<NEResult<NEMeetingItem>> scheduleRoom(NEMeetingItem item) {
    return HttpApiHelper._scheduleRoom(item);
  }

  ///编辑预约会议
  static Future<NEResult<NEMeetingItem>> editRoom(
      NEMeetingItem item, bool editRecurringMeeting) {
    return HttpApiHelper._editRoom(item, editRecurringMeeting);
  }

  ///取消预约会议，开始前可以取消
  static Future<NEResult<void>> cancelRoom(
      int roomUniqueId, bool cancelRecurringMeeting) {
    return HttpApiHelper._cancelRoom(roomUniqueId, cancelRecurringMeeting);
  }

  ///删除预约会议
  static Future<NEResult<void>> deleteRoom(int roomUniqueId) {
    return HttpApiHelper._deleteRoom(roomUniqueId);
  }

  ///根据meetingNum获取会议信息
  static Future<NEResult<NEMeetingItem>> getRoomItemByNum(String meetingNum) {
    return HttpApiHelper._getMeetingItemByNum(meetingNum);
  }

  ///根据会议状态查询会议信息列表，
  static Future<NEResult<List<NEMeetingItem>>> getRoomList(
      List<NEMeetingItemStatus> status) {
    return HttpApiHelper._getRoomList(status);
  }

  /// 获取预约会议参会者列表接口
  static Future<NEResult<List<NEScheduledMember>>> getScheduledMembers(
      String meetingNum) {
    return HttpApiHelper._getScheduledMembers(meetingNum);
  }

  /// 根据MeetingId查询会议信息，如果是周期性会议的话，返回的是周期性会议最新的一次会议信息
  static Future<NEResult<NEMeetingItem>> getMeetingItemById(int meetingId) {
    return HttpApiHelper._getMeetingItemById(meetingId);
  }

  /// 获取收藏会议列表
  static Future<NEResult<List<NERemoteHistoryMeeting>>> getFavoriteMeetings(
      int? startId, int limit) {
    return HttpApiHelper._getFavoriteMeetings(startId, limit);
  }

  /// 添加收藏会议
  static Future<NEResult<int>> addFavoriteMeeting(int roomArchiveId) {
    return HttpApiHelper._addFavoriteMeeting(roomArchiveId);
  }

  /// 取消收藏会议
  static Future<VoidResult> removeFavoriteMeetingByFavoriteId(int favoriteId) {
    return HttpApiHelper._removeFavoriteMeetingByFavoriteId(favoriteId);
  }

  /// 取消收藏会议
  static Future<VoidResult> removeFavoriteMeetingByRoomArchiveId(
      int roomArchiveId) {
    return HttpApiHelper._removeFavoriteMeetingByRoomArchiveId(roomArchiveId);
  }

  /// 获取历史会议列表
  static Future<NEResult<List<NERemoteHistoryMeeting>>> getHistoryMeetings(
      int? startId, int limit) {
    return HttpApiHelper._getHistoryMeetings(startId, limit);
  }

  /// 获取历史会议详情
  static Future<NEResult<NERemoteHistoryMeetingDetail>> getHistoryMeetingDetail(
      int roomArchiveId) {
    return HttpApiHelper._getHistoryMeetingDetail(roomArchiveId);
  }

  /// 获取历史会议
  static Future<NEResult<NERemoteHistoryMeeting>> getHistoryMeeting(
      int meetingId) {
    return HttpApiHelper._getHistoryMeeting(meetingId);
  }
}
