// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

/// 会议设置服务，可设置入会时、会议中的一些配置信息
/// 如入会时的音视频开关选项，如果在入会时未指定[NEMeetingOptions]，则使用该设置服务提供的默认值
/// 该设置服务使用设备本地存储，暂不支持漫游
/// 可通过 {@link NEMeetingKit#getSettingsService()} 获取对应的服务实例。
abstract class NESettingsService extends ValueNotifier<Map> {
  NESettingsService() : super({});

  /// 设置是否显示会议时长
  ///
  /// [enable] true-开启，false-关闭
  void enableShowMyMeetingElapseTime(bool enable);

  /// 查询是否显示会议时长
  Future<bool> isShowMyMeetingElapseTimeEnabled();

  /// 设置入会时是否打开本地视频
  ///
  /// [enable] true-入会时打开视频，false-入会时关闭视频
  void enableTurnOnMyVideoWhenJoinMeeting(bool enable);

  /// 查询入会时是否打开本地视频
  Future<bool> isTurnOnMyVideoWhenJoinMeetingEnabled();

  /// 设置入会时是否打开本地音频
  ///
  /// [enable] true-入会时打开音频，false-入会时关闭音频
  void enableTurnOnMyAudioWhenJoinMeeting(bool enable);

  /// 查询入会时是否打开本地音频
  Future<bool> isTurnOnMyAudioWhenJoinMeetingEnabled();

  /// 查询应用是否支持会议直播
  Future<bool> isMeetingLiveSupported();

  /// 查询应用是否支持白板共享
  Future<bool> isMeetingWhiteboardSupported();

  /// 查询应用是否支持云端录制服务
  Future<bool> isMeetingCloudRecordSupported();

  /// 设置是否打开音频智能降噪
  ///
  /// [enable] true-开启，false-关闭
  void enableAudioAINS(bool enable);

  /// 查询音频智能降噪是否打开
  Future<bool> isAudioAINSEnabled();

  /// 设置是否显示虚拟背景
  ///
  /// [enable] true 显示 false不显示
  void enableVirtualBackground(bool enable);

  /// 查询虚拟背景是否显示
  Future<bool> isVirtualBackgroundEnabled();

  /// 设置内置虚拟背景图片路径列表
  ///
  /// [pathList] 虚拟背景图片路径列表
  void setBuiltinVirtualBackgroundList(List<String> pathList);

  /// 获取内置虚拟背景图片路径列表
  Future<List<String>> getBuiltinVirtualBackgroundList();

  /// 设置外部虚拟背景图片路径列表
  ///
  /// [pathList] 虚拟背景图片路径列表
  void setExternalVirtualBackgroundList(List<String> pathList);

  /// 获取外部虚拟背景图片路径列表
  Future<List<String>> getExternalVirtualBackgroundList();

  /// 设置最近选择的虚拟背景图片路径
  ///
  /// [path] 虚拟背景图片路径,为空代表不设置虚拟背景
  void setCurrentVirtualBackground(String? path);

  /// 获取最近选择的虚拟背景图片路径
  Future<String?> getCurrentVirtualBackground();

  /// 设置是否开启语音激励
  ///
  /// [enable] true-开启，false-关闭
  void enableSpeakerSpotlight(bool enable);

  /// 查询是否打开语音激励
  Future<bool> isSpeakerSpotlightEnabled();

  /// 设置是否打开前置摄像头镜像
  ///
  /// [enable] true-打开，false-关闭
  Future<void> enableFrontCameraMirror(bool enable);

  /// 查询前置摄像头镜像是否打开
  Future<bool> isFrontCameraMirrorEnabled();

  /// 设置是否打开白板透明
  ///
  /// [enable] true-打开，false-关闭
  Future<void> enableTransparentWhiteboard(bool enable);

  /// 查询白板透明是否打开
  Future<bool> isTransparentWhiteboardEnabled();

  /// 查询应用是否支持美颜
  Future<bool> isBeautyFaceSupported();

  /// 获取当前美颜参数，关闭返回0
  Future<int> getBeautyFaceValue();

  /// 设置美颜参数
  ///
  /// [value] 传入美颜等级，参数规则为[0,10]整数
  Future<void> setBeautyFaceValue(int value);

  /// 查询应用是否支持等候室
  Future<bool> isWaitingRoomSupported();

  /// 查询应用是否支持虚拟背景
  Future<bool> isVirtualBackgroundSupported();
}
