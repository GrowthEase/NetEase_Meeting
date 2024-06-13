// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

/// 回调接口，用于监听共享屏幕状态变更事件
/// [status] 共享屏幕状态事件对象
///
typedef NEScreenSharingStatusListener = void Function(
    NEScreenSharingEvent event);

/// 描述会议状态变更事件
class NEScreenSharingEvent {
  /// 当前会议状态
  final int event;

  /// 该状态附带的额外参数
  final int arg;

  NEScreenSharingEvent(this.event, {this.arg = -1});
}

/// [NERoomEndReason] 会议结束原因
// extension NEMeetingCode on NERoomEndReason {
//   static const MEETING_DISCONNECTING_BY_SELF = NERoomEndReason.kLeaveBySelf;
//   static const MEETING_DISCONNECTING_REMOVED_BY_HOST = NERoomEndReason.kKickOut;
//   static const MEETING_DISCONNECTING_CLOSED_BY_HOST = NERoomEndReason.kCloseByMember;
//   static const MEETING_DISCONNECTING_LOGIN_ON_OTHER_DEVICE = NERoomEndReason.kKickBySelf;
//   static const MEETING_DISCONNECTING_AUTH_INFO_EXPIRED = NERoomEndReason.kLoginStateError;
// }

/// 共享屏幕时的状态枚举
enum NEScreenSharingStatus {
  /// 未开始
  idle,

  /// 等待中
  waiting,

  /// 已开始
  started,

  /// 已结束
  ended,
}

/// 提供共享时必要的额外参数，如共享码、用户共享昵称昵称等
class NEScreenSharingParams {
  /// 共享码
  final String sharingCode;

  /// 分享昵称
  final String displayName;

  /// iOS平台的AppGroup
  String? iosAppGroup;

  IntervalEvent? trackingEvent;

  NEScreenSharingParams({
    required this.sharingCode,
    required this.displayName,
  });

  NEScreenSharingParams.fromMap(Map map)
      : this(
          sharingCode: map['sharingCode'] as String,
          displayName: (map['displayName'] ?? '') as String,
        );
}

class NEScreenSharingOptions {
  ///
  /// 开启/关闭音频共享功能。
  /// 开启后，在发起屏幕共享时，会同时自动开启设备的音频共享；
  /// 关闭后，在发起屏幕共享时，不会自动打开音频共享，但可以通过UI手动开启音频共享。
  /// 该设置默认为开启。
  ///
  final enableAudioShare;

  NEScreenSharingOptions({
    required this.enableAudioShare,
  });

  NEScreenSharingOptions.fromMap(Map map)
      : this(
          enableAudioShare: map['enableAudioShare'] as bool? ?? true,
        );
}

/// 屏幕共享服务接口，用于创建和管理屏幕共享、添加共享状态监听等。可通过 [NEMeetingKit.getMeetingService] 获取对应的服务实例
abstract class NEScreenSharingService {
  /// 开启一个开启屏幕共享，只有完成SDK的登录鉴权操作才允许开启屏幕共享。
  ///
  /// * [param] 屏幕共享参数对象，不能为空
  /// * [opts]  屏幕共享选项对象，可空；当未指定时，会使用默认的选项
  ///
  Future<NEResult<String>> startScreenShare(
    NEScreenSharingParams param,
    NEScreenSharingOptions opts,
  );

  ///
  /// 停止屏幕共享
  /// 回调接口。该回调不会返回额外的结果数据
  ///
  Future<NEResult<void>> stopScreenShare();

  ///
  /// 添加共享屏幕状态监听实例，用于接收共享屏幕状态变更通知
  ///
  /// [listener] 要添加的监听实例
  ///
  void addScreenSharingStatusListener(NEScreenSharingStatusListener listener);

  ///
  /// 移除对应的会议共享屏幕状态的监听实例
  ///
  /// [listener] 要移除的监听实例
  ///
  void removeScreenSharingStatusListener(
      NEScreenSharingStatusListener listener);
}
