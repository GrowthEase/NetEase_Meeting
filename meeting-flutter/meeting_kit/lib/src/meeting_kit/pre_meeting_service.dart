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
  /// * [anchorId] 锚点 Id，用于分页查询
  /// * [limit] 查询数量
  Future<NEResult<List<NERemoteHistoryMeeting>>> getFavoriteMeetingList(
      int anchorId, int limit);

  /// 添加收藏会议
  /// * [meetingId] 会议唯一Id
  Future<NEResult<int>> addFavoriteMeeting(int meetingId);

  /// 取消收藏会议
  /// * [meetingId] 会议唯一Id
  Future<VoidResult> removeFavoriteMeeting(int meetingId);

  /// 获取历史会议列表，返回会议时间早于 anchorId 的最多 limit 个会议。
  /// 如果 anchorId 小于等于 0，则从头开始查询。
  /// * [anchorId] 锚点Id，用于分页查询
  /// * [limit] 查询数量
  Future<NEResult<List<NERemoteHistoryMeeting>>> getHistoryMeetingList(
      int anchorId, int limit);

  /// 获取历史会议详情
  /// * [meetingId] 会议唯一Id
  Future<NEResult<NERemoteHistoryMeetingDetail>> getHistoryMeetingDetail(
      int meetingId);

  /// 根据 meetingId 查询历史会议
  /// * [meetingId] 会议唯一Id
  Future<NEResult<NERemoteHistoryMeeting>> getHistoryMeeting(int meetingId);

  /// 预约会议
  /// * [item] 会议条目
  Future<NEResult<NEMeetingItem>> scheduleMeeting(NEMeetingItem item);

  /// 修改已预定的会议信息
  /// * [item] 会议条目
  /// * [editRecurringMeeting] 是否修改所有周期性会议
  Future<NEResult<NEMeetingItem>> editMeeting(
      NEMeetingItem item, bool editRecurringMeeting);

  /// 取消预约会议，开始前可以取消
  /// * [meetingId] 会议唯一Id
  /// * [cancelRecurringMeeting] 是否取消所有周期性会议
  Future<NEResult<void>> cancelMeeting(
      int meetingId, bool cancelRecurringMeeting);

  /// 根据 meetingNum 获取会议信息
  /// * [meetingNum] 会议号
  Future<NEResult<NEMeetingItem>> getMeetingItemByNum(String meetingNum);

  /// 根据邀请码获取会议信息
  /// * [inviteCode] 邀请码
  Future<NEResult<NEMeetingItem>> getMeetingItemByInviteCode(String inviteCode);

  /// 根据 meetingId 查询预定会议信息
  /// * [meetingId] 会议唯一Id
  Future<NEResult<NEMeetingItem>> getMeetingItemById(int meetingId);

  /// 查询特定状态下的会议列表，不指定则返回 init，started 列表。
  /// 目前不支持查询 cancel，recycled 状态下的会议列表
  /// * [status] 目标会议状态列表
  Future<NEResult<List<NEMeetingItem>>> getMeetingList(
      List<NEMeetingItemStatus> status);

  /// 根据 meetingNum 获取预约会议成员列表
  /// * [meetingNum] 会议号
  Future<NEResult<List<NEScheduledMember>>> getScheduledMeetingMemberList(
      String meetingNum);

  /// 获取当前语言环境下的邀请信息
  /// * [item] 会议条目
  Future<String> getInviteInfo(NEMeetingItem item);

  ///
  /// 获取历史会议的转写信息
  /// * [meetingId] 会议唯一 Id
  ///
  Future<NEResult<List<NEMeetingTranscriptionInfo>>>
      getHistoryMeetingTranscriptionInfo(int meetingId);

  ///
  /// 获取历史会议的转写文件下载地址
  /// * [meetingId] 会议唯一 Id
  /// * [fileKey] 转写文件的文件 key
  ///
  Future<NEResult<String>> getHistoryMeetingTranscriptionFileUrl(
      int meetingId, String fileKey);

  ///
  /// 获取历史会议的转写文件的消息列表
  /// * [meetingId] 会议唯一 Id
  /// * [fileKey] 原始转写文件的文件 key。 [NEMeetingTranscriptionInfo.originalNosFileKeys]
  ///
  Future<NEResult<List<NEMeetingTranscriptionMessage>>>
      getHistoryMeetingTranscriptionMessageList(int meetingId, String fileKey);

  /// 添加会前监听器
  /// * [listener] 监听器
  void addListener(NEPreMeetingListener listener);

  /// 移除会前监听器
  /// * [listener] 监听器
  void removeListener(NEPreMeetingListener listener);

  ///
  /// 获取本地历史会议记录列表，不支持漫游保存，默认保存最近10条记录
  /// 结果，数据类型为[NELocalHistoryMeeting]列表
  ///
  List<NELocalHistoryMeeting> getLocalHistoryMeetingList();

  ///
  /// 清空本地历史会议列表
  ///
  void clearLocalHistoryMeetingList();

  ///
  /// 获取会议云录制记录列表,仅在返回错误码为成功时,才代表有云录制任务,解码任务过程中获取列表可能会有延迟
  ///
  /// * [meetingId] 会议ID
  ///
  Future<NEResult<List<NEMeetingRecord>>> getMeetingCloudRecordList(
      int meetingId);

  ///
  /// 加载小应用页面，用于会议历史详情的展示
  /// * [meetingId] 会议唯一 Id
  /// * [item] 小应用对象，通过[NERemoteHistoryMeetingDetail.pluginInfoList]对象获取到
  ///
  Widget loadWebAppView(
    int meetingId,
    NEMeetingWebAppItem item,
  );

  ///
  /// 查询会议聊天室历史消息
  /// * [meetingId] 会议唯一 Id
  /// * [option] 查询选项
  ///
  Future<NEResult<List<NERoomChatMessage>>> fetchChatroomHistoryMessageList(
      int meetingId, NEChatroomHistoryMessageSearchOption option);

  ///
  /// 加载会议聊天室历史消息页面
  /// * [meetingId] 会议唯一 Id
  ///
  Widget loadChatroomHistoryMessageView(int meetingId);
}
