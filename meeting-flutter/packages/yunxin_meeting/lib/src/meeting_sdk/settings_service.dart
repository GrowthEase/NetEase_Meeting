// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_sdk;

/// 会议设置服务，可设置入会时、会议中的一些配置信息
/// 如入会时的音视频开关选项，如果在入会时未指定[NEMeetingOptions]，则使用该设置服务提供的默认值
/// 该设置服务使用设备本地存储，暂不支持漫游
abstract class NESettingsService extends ValueNotifier<Map> {

  NESettingsService() : super({});

  /// 开启或关闭显示会议时长功能
  ///
  /// show true-开启，false-关闭
  void enableShowMyMeetingElapseTime(bool show);

  /// 查询显示会议时长功能开启状态
  ///
  /// 返回：true-已开启，false-已关闭
  Future<bool> isShowMyMeetingElapseTimeEnabled();

  /// 设置入会时本地视频开关
  ///
  /// enabled true-入会时打开视频，false-入会时关闭视频
  void setTurnOnMyVideoWhenJoinMeeting(bool enabled);
  
  /// 查询入会时的本地视频开关设置状态
  ///
  /// 返回: true-本地视频打开，false-本地视频关闭
  Future<bool> isTurnOnMyVideoWhenJoinMeetingEnabled();

  /// 设置入会时本地音频开关
  ///
  /// enabled true-入会时打开音频，false-入会时关闭音频
  void setTurnOnMyAudioWhenJoinMeeting(bool enabled);

  /// 查询入会时的本地音频开关设置状态
  ///
  /// 返回：true-本地音频打开，false-本地音频关闭
  Future<bool> isTurnOnMyAudioWhenJoinMeetingEnabled();

  // server 暂不开放
  // /// 美颜使能接口，控制美颜服务开关
  // /// [enable] true-打开，false-关闭
  // /// return 返回执行结果
  // Future<int> enableBeautyFace(bool enable);

  /// 查询美颜服务开关状态，关闭在隐藏会中美颜按钮
  /// return true-打开，false-关闭
  Future<bool> isBeautyFaceEnabled();

  /// 打开美颜界面，必须在init之后调用该接口，支持会前设置和会中使用。
  /// [context] 上下文
  Future<NEResult<void>> openBeautyUI(BuildContext context);

  /// 获取当前美颜参数，关闭返回0
  /// return true-打开，false-关闭
  Future<int> getBeautyFaceValue();

  /// 设置美颜参数
  ///  [value] 传入美颜等级，参数规则为[0,10]整数
  void setBeautyFaceValue(int value);

  ///
  /// 查询会议是否拥有直播权限
  ///
  Future<bool> isMeetingLiveEnabled();

  ///
  /// 更新历史会议列表
  ///
  void updateHistoryMeetingItem(NEHistoryMeetingItem item);

  ///
  /// 获取历史会议列表。当前仅会返回最近一次的会议记录，不支持漫游保存。
  ///
  Future<List<NEHistoryMeetingItem>?> getHistoryMeetingItem();

  /// 查询录制服务开关状态
  /// return true-打开，false-关闭
  Future<bool> isMeetingWhiteboardEnabled();

  /// 查询云端录制服务开关状态
  /// return true-打开，false-关闭
  Future<bool> isMeetingCloudRecordEnabled();

}


