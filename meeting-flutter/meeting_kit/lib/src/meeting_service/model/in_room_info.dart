// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

///会议中信息
// class MeetingInfo {
//   /// 预定成功后， 服务器生成唯一id
//   final int meetingUniqueId;
//
//   /// 会议ID
//   final String meetingId;
//
//   /// 会议短号ID
//   final String? shortMeetingId;
//
//   /// Sip会议ID
//   final String? sipCid;
//
//   /// 会议类型
//   final int type;
//
//   /// 会议主题
//   final String subject;
//
//   /// 会议密码
//   final String? password;
//
//   /// 会议预约开始时间
//   final int scheduleStartTime;
//
//   /// 会议预约结束时间
//   final int scheduleEndTime;
//
//   /// 是否有全体禁音，0：否，1：有
//   final int audioAllMute;
//
//   /// 会议加入控制类型:，1：允许任何人直接加入，2：不允许任何人加入
//   /// [JoinControlType]
//   int joinControlType;
//
//   /// 主持人，视频会议帐号id
//   String hostAccountId;
//
//   /// 焦点视频角色，视频会议帐号id
//   String? focusAccountId;
//
//   /// 会议中的屏幕共享者
//   final Set<String> screenSharersAccountId;
//
//   /// 会议中的白板共享者
//   final Set<String> whiteboardAvRoomUid;
//
//   /// 白板拥有者imAccid
//   final Set<String> whiteboardOwnerImAccid;
//
//   ///白板共享状态，0关闭，1开启
//   int whiteboardSharing;
//
//   ///共享模式，0.未开启共享，1.屏幕，2.白板，3.混合
//   int shareMode;
//
//   /// 会议设置
//   NERoomItemSettings? settings;
//
//   /// 会议直播设置
//   NERoomItemLive? live;
//
//   List<InMeetingMemberInfo> members;
//
//   /// 透传额外字段
//   String? extraData;
//
//   MeetingInfo({
//     required this.meetingUniqueId,
//     required this.meetingId,
//     required this.shortMeetingId,
//     required this.sipCid,
//     required this.type,
//     required this.subject,
//     required this.password,
//     required this.scheduleStartTime,
//     required this.scheduleEndTime,
//     required this.audioAllMute,
//     required this.joinControlType,
//     required this.hostAccountId,
//     required this.focusAccountId,
//     required this.screenSharersAccountId,
//     required this.whiteboardAvRoomUid,
//     required this.whiteboardOwnerImAccid,
//     required this.whiteboardSharing,
//     required this.shareMode,
//     required this.settings,
//     required this.live,
//     required this.members,
//     this.extraData,
//   });
//
//   factory MeetingInfo.fromMap(String? meetingId, Map map) {
//     final meeting = map['meeting'] as Map;
//     return MeetingInfo(
//       meetingUniqueId: (meeting['meetingUniqueId'] ?? 0) as int, //遥控器没有传meetingUniqueId字段过来
//       meetingId: meetingId ?? meeting['meetingId'] as String,
//       shortMeetingId: meeting['shortId'] as String?,
//       sipCid: meeting['sipCid'] as String?,
//       extraData: meeting['extraData'] as String?,
//       type: (meeting['type'] ?? NERoomType.now) as int, //遥控器没有回传该字段
//       password: meeting['password'] as String?,
//       subject: meeting['subject'] as String,
//       scheduleStartTime: (meeting['startTime'] ?? 0) as int,
//       scheduleEndTime: (meeting['endTime'] ?? 0) as int,
//       audioAllMute: meeting['audioAllMute'] as int,
//       hostAccountId: meeting['hostAccountId'] as String,
//       focusAccountId: meeting['focusAccountId'] as String?,
//       joinControlType: meeting['joinControlType'] as int,
//       whiteboardSharing: (meeting['whiteboardSharing'] ?? 0) as int,
//       shareMode: (meeting['shareMode'] ?? 0) as int,
//       settings: NERoomItemSettings.fromJson(meeting['settings'] as Map?),
//       live: NERoomItemLive.fromJson(meeting['live'] as Map?),
//       screenSharersAccountId:
//       ((meeting['screenSharersAccountId'] ?? []) as List)
//           .whereType<String>()
//           .toSet(),
//       whiteboardAvRoomUid: ((meeting['whiteboardAvRoomUid'] ?? []) as List)
//           .whereType<String>()
//           .toSet(),
//       whiteboardOwnerImAccid:
//       ((meeting['whiteboardOwnerImAccid'] ?? []) as List)
//           .whereType<String>()
//           .toSet(),
//       members: InMeetingMemberInfo.fromArrays(map['members'] as List?) ?? [],
//     );
//   }
//
// }
