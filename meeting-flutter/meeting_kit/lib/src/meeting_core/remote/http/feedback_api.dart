// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 意见反馈
class _FeedbackApi extends HttpApi<void> {
  ///用户数据
  NEFeedback feedback;

  ///用户登陆手机号
  String? phone;

  ///用户会议昵称
  String? nickname;

  ///会议ID
  String? meetingId;

  ///音视频通话频道ID
  int? channelId;

  ///log 文件 NOS 存储路径
  String? log;

  ///应用版本号
  String? ver;

  /// 意见反馈server url
  String feedbackServer;

  @override
  String path() => feedbackServer;

  @override
  String get method => 'POST';

  @override
  void result(Map map) {
    return null;
  }

  _FeedbackApi(this.feedbackServer, this.feedback, this.phone, this.nickname,
      this.meetingId, this.channelId, this.log, this.ver);

  @override
  Map data() => {
        'event': {
          'feedback': {
            'app_key': ServiceRepository().appKey,
            'device_id': DeviceInfo.deviceId,
            'platform': DeviceInfo.platform,
            'os_ver': DeviceInfo.osVer,
            'manufacturer': DeviceInfo.manufacturer,
            'model': DeviceInfo.model,
            ...feedback.toMap(),
            'ver': ver,
            'phone': phone,
            'nickname': nickname,
            'meeting_id': meetingId,
            'channel_id': channelId,
            'log': log,
            'client': 'Meeting',
          }
        }
      };

  @override
  Map<String, dynamic>? header() => {
        'sdktype': 'meeting',
        'appkey': ServiceRepository().appKey,
        'ver': ver,
        'Content-Type': 'application/json'
      };
}
