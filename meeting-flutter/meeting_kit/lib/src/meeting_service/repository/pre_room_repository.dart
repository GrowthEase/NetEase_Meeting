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
  static Future<NEResult<NEMeetingItem>> editRoom(NEMeetingItem item) {
    return HttpApiHelper._editRoom(item);
  }

  ///取消预约会议，开始前可以取消
  static Future<NEResult<void>> cancelRoom(int roomUniqueId) {
    return HttpApiHelper._cancelRoom(roomUniqueId);
  }

  ///删除预约会议
  static Future<NEResult<void>> deleteRoom(int roomUniqueId) {
    return HttpApiHelper._deleteRoom(roomUniqueId);
  }

  ///根据唯一id获取会议信息
  static Future<NEResult<NEMeetingItem>> getRoomItemById(String meetingNum) {
    return HttpApiHelper._getRoomItemById(meetingNum);
  }

  ///根据会议状态查询会议信息列表，
  static Future<NEResult<List<NEMeetingItem>>> getRoomList(
      List<NEMeetingState> status) {
    return HttpApiHelper._getRoomList(status);
  }
}
