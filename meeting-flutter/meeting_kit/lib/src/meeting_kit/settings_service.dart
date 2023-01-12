// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

/// 会议设置服务，可设置入会时、会议中的一些配置信息
/// 如入会时的音视频开关选项，如果在入会时未指定[NEMeetingOptions]，则使用该设置服务提供的默认值
/// 该设置服务使用设备本地存储，暂不支持漫游
abstract class NESettingsService extends ValueNotifier<Map> {
  NESettingsService() : super({});

  Stream<bool> get sdkConfigChangeStream;

  /// 开启或关闭显示会议时长功能
  ///
  /// show true-开启，false-关闭
  void enableShowMyMeetingElapseTime(bool show);

  /// 查询显示会议时长功能开启状态
  ///
  /// 返回：true-已开启，false-已关闭
  Future<bool> isShowMyMeetingElapseTimeEnabled();

  /// 开启或关闭音频智能降噪
  ///
  /// enable true-开启，false-关闭
  void enableAudioAINS(bool enable);

  /// 查询音频智能降噪开启状态
  ///
  /// 返回：true-已开启，false-已关闭
  Future<bool> isAudioAINSEnabled();

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

  /// 查询美颜服务开关状态，关闭在隐藏会中美颜按钮
  /// return true-打开，false-关闭
  Future<bool> isBeautyFaceEnabled();

  /// 获取当前美颜参数，关闭返回0
  /// return true-打开，false-关闭
  Future<int> getBeautyFaceValue();

  /// 设置美颜参数
  ///  [value] 传入美颜等级，参数规则为[0,10]整数
  Future<void> setBeautyFaceValue(int value);

  ///
  /// 查询会议是否拥有直播权限
  ///
  Future<bool> isMeetingLiveEnabled();

  ///
  /// 更新历史会议列表
  ///
  void updateHistoryMeetingItem(NEHistoryMeetingItem? item);

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

  ///
  /// 虚拟背景是否显示
  /// [enable] true 显示 false不显示
  ///
  void enableVirtualBackground(bool enable);

  ///
  /// 查询虚拟背景显示状态
  /// true 显示，false不显示
  ///
  Future<bool> isVirtualBackgroundEnabled();

  ///
  /// 查询静音时是否需要关闭音频流pub
  ///
  bool shouldUnpubOnAudioMute();

  ///
  /// 设置内置虚拟背景列表
  /// [virtualBackgrounds] 虚拟背景图列表 @link[NEMeetingVirtualBackground]
  ///
  void setBuiltinVirtualBackgrounds(
      List<NEMeetingVirtualBackground> virtualBackgrounds);

  ///
  /// 获取内置虚拟背景列表
  ///
  Future<List<NEMeetingVirtualBackground>> getBuiltinVirtualBackgrounds();
}

class NEMeetingVirtualBackground {
  /// 虚拟背景图片地址列表
  late String path;
  NEMeetingVirtualBackground(this.path);

  NEMeetingVirtualBackground.fromMap(Map map) {
    path = map['path'];
  }

  Map toJson() => {'path': path};
}

/// 会议历史记录对象
class NEHistoryMeetingItem {
  /// 会议唯一ID
  final int meetingUniqueId;

  /// 会议ID
  final String meetingId;

  /// 会议短号
  final String? shortMeetingId;

  /// 会议主题
  final String subject;

  /// 会议密码
  final String? password;

  /// 会议昵称
  String nickname;

  /// sipId
  String? sipId;

  NEHistoryMeetingItem({
    required this.meetingUniqueId,
    required this.meetingId,
    this.shortMeetingId,
    required this.subject,
    this.password,
    this.sipId,
    required this.nickname,
  });

  static NEHistoryMeetingItem? fromJson(Map<dynamic, dynamic>? json) {
    if (json == null) return null;
    try {
      return NEHistoryMeetingItem(
        meetingUniqueId: json['meetingUniqueId'] as int,
        meetingId: json['meetingId'] as String,
        shortMeetingId: json['shortMeetingId'] as String?,
        password: json['password'] as String?,
        subject: json['subject'] as String,
        nickname: json['nickname'] as String,
        sipId: json['sipId'] as String?,
      );
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'meetingUniqueId': meetingUniqueId,
        'meetingId': meetingId,
        if (shortMeetingId != null) 'shortMeetingId': shortMeetingId,
        if (password != null) 'password': password,
        'subject': subject,
        'nickname': nickname,
        if (sipId != null) 'sipId': sipId,
      };
}
