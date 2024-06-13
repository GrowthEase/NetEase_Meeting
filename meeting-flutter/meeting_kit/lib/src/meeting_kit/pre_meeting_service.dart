// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

mixin class NEPreMeetingListener {
  void onMeetingItemInfoChanged(List<NEMeetingItem> meetingItemList) {}
}

/// NEPreMeetingService为会前服务，通过这个服务可以进行历史会议查询、会议收藏等操作。
abstract class NEPreMeetingService {
  /// 获取收藏会议列表，返回会议时间早于 anchorId 的最多 limit 个会议。
  /// 如果 anchorId 小于等于 0，则从头开始查询。
  /// [anchorId] 锚点 Id，用于分页查询
  /// [limit] 查询数量
  Future<NEResult<List<NERemoteHistoryMeeting>>> getFavoriteMeetingList(
      int anchorId, int limit);

  /// 添加收藏会议
  /// [meetingId] 会议唯一Id
  Future<NEResult<int>> addFavoriteMeeting(int meetingId);

  /// 取消收藏会议
  /// [meetingId] 会议唯一Id
  Future<VoidResult> removeFavoriteMeeting(int meetingId);

  /// 获取历史会议列表，返回会议时间早于 anchorId 的最多 limit 个会议。
  /// 如果 anchorId 小于等于 0，则从头开始查询。
  /// [anchorId] 锚点Id，用于分页查询
  /// [limit] 查询数量
  Future<NEResult<List<NERemoteHistoryMeeting>>> getHistoryMeetingList(
      int anchorId, int limit);

  /// 获取历史会议详情
  /// [meetingId] 会议唯一Id
  Future<NEResult<NERemoteHistoryMeetingDetail>> getHistoryMeetingDetail(
      int meetingId);

  /// 根据 meetingId 查询历史会议
  /// [meetingId] 会议唯一Id
  Future<NEResult<NERemoteHistoryMeeting>> getHistoryMeeting(int meetingId);

  /// 预约会议
  /// [item] 会议条目
  Future<NEResult<NEMeetingItem>> scheduleMeeting(NEMeetingItem item);

  /// 修改已预定的会议信息
  /// [item] 会议条目
  /// [editRecurringMeeting] 是否修改所有周期性会议
  Future<NEResult<NEMeetingItem>> editMeeting(
      NEMeetingItem item, bool editRecurringMeeting);

  /// 取消预约会议，开始前可以取消
  /// [meetingId] 会议唯一Id
  /// [cancelRecurringMeeting] 是否取消所有周期性会议
  Future<NEResult<void>> cancelMeeting(
      int meetingId, bool cancelRecurringMeeting);

  /// 根据 meetingNum 获取会议信息
  /// [meetingNum] 会议号
  Future<NEResult<NEMeetingItem>> getMeetingItemByNum(String meetingNum);

  /// 根据 meetingId 查询预定会议信息
  /// [meetingId] 会议唯一Id
  Future<NEResult<NEMeetingItem>> getMeetingItemById(int meetingId);

  /// 查询特定状态下的会议列表，不指定则返回 init，started 列表。
  /// 目前不支持查询 cancel，recycled 状态下的会议列表
  /// [status] 目标会议状态列表
  Future<NEResult<List<NEMeetingItem>>> getMeetingList(
      List<NEMeetingItemStatus> status);

  /// 根据 meetingNum 获取预约会议成员列表
  /// [meetingNum] 会议号
  Future<NEResult<List<NEScheduledMember>>> getScheduledMeetingMemberList(
      String meetingNum);

  /// 添加会前监听器
  /// [listener] 监听器
  void addListener(NEPreMeetingListener listener);

  /// 移除会前监听器
  /// [listener] 监听器
  void removeListener(NEPreMeetingListener listener);
}
