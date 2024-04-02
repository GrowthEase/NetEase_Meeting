// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

typedef ScheduleCallback<T> = void Function(T data, bool incremental);

/// 会议前服务， 主要提供会议开始前的一系列方法， eg： 会议预定
abstract class NEPreMeetingService {
  /// 预约会议
  Future<NEResult<NEMeetingItem>> scheduleMeeting(NEMeetingItem item);

  /// 编辑预约会议
  Future<NEResult<NEMeetingItem>> editMeeting(
      NEMeetingItem item, bool editRecurringMeeting);

  /// 取消预约会议，开始前可以取消
  Future<NEResult<void>> cancelMeeting(
      int meetingId, bool cancelRecurringMeeting);

  /// 根据唯一id获取会议信息
  Future<NEResult<NEMeetingItem>> getMeetingItemById(String meetingNum);

  /// 根据会议状态查询会议信息列表， 不传默认返回NEMeetingItemStatus.init, NEMeetingItemStatus.started
  Future<NEResult<List<NEMeetingItem>>> getMeetingList(
      List<NEMeetingState> status);

  /// 注册监听预定会议状态变更回调
  void registerScheduleMeetingStatusChange(
      ScheduleCallback<List<NEMeetingItem>> callback);

  /// 反注册监听预定会议状态变更回调
  void unRegisterScheduleMeetingStatusChange(
      ScheduleCallback<List<NEMeetingItem>> callback);
}
