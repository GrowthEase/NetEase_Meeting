// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class MeetingSecurityCtrlValue {
  /// 是否允许批注
  static const ANNOTATION_DISABLE = 0x1 << 0;

  /// 是否允许屏幕共享
  static const SCREEN_SHARE_DISABLE = 0x1 << 1;

  /// 是否允许开启白板
  static const WHILE_BOARD_SHARE_DISABLE = 0x1 << 2;

  /// 是否允许自己改名
  static const EDIT_NAME_DISABLE = 0x1 << 3;

  /// 是否是全体静音
  static const AUDIO_OFF = 0x1 << 4;

  /// 是否允许自行解除静音
  static const AUDIO_NOT_ALLOW_SELF_ON = 0x1 << 5;

  /// 是否是全体关闭视频
  static const VIDEO_OFF = 0x1 << 6;

  /// 是否允许自行打开视频
  static const VIDEO_NOT_ALLOW_SELF_ON = 0x1 << 7;

  /// 表情回复开关
  static const EMOJI_RESP_DISABLE = 0x1 << 8;

  /// 本地录制开关
  static const LOCAL_RECORD_DISABLE = 0x1 << 9;

  /// 成员加入离开播放提示音
  static const PLAY_SOUND = 0x1 << 10;

  /// 头像显示隐藏
  static const AVATAR_HIDE = 0x1 << 11;

  /// 智能会议纪要
  static const SMART_SUMMARY = 0x1 << 12;
}

class MeetingSecurityCtrlKey {
  static const securityCtrlKey = 'securityCtrl';

  /// 是否允许批注
  static const ANNOTATION_DISABLE = 'ANNOTATION_DISABLE';

  /// 是否允许屏幕共享
  static const SCREEN_SHARE_DISABLE = 'SCREEN_SHARE_DISABLE';

  /// 是否允许开启白板
  static const WHILE_BOARD_SHARE_DISABLE = 'WHILE_BOARD_SHARE_DISABLE';

  /// 是否允许自己改名
  static const EDIT_NAME_DISABLE = 'EDIT_NAME_DISABLE';

  /// 是否是全体静音
  static const AUDIO_OFF = 'AUDIO_OFF';

  /// 是否允许自行解除静音
  static const AUDIO_NOT_ALLOW_SELF_ON = 'AUDIO_NOT_ALLOW_SELF_ON';

  /// 是否是全体关闭视频
  static const VIDEO_OFF = 'VIDEO_OFF';

  /// 是否允许自行打开视频
  static const VIDEO_NOT_ALLOW_SELF_ON = 'VIDEO_NOT_ALLOW_SELF_ON';

  /// 表情回复开关
  static const EMOJI_RESP_DISABLE = 'EMOJI_RESP_DISABLE';

  /// 本地录制开关
  static const LOCAL_RECORD_DISABLE = 'LOCAL_RECORD_DISABLE';

  /// 成员加入离开播放提示音
  static const PLAY_SOUND = 'PLAY_SOUND';

  /// 头像显示隐藏
  static const AVATAR_HIDE = 'AVATAR_HIDE';
}

const kMeetingTemplateId = 40;

class MeetingPropertyKeys {
  MeetingPropertyKeys._();

  ///
  /// 房间额外属性
  ///
  static const kExtraData = 'extraData';

  ///
  /// 成员自定义属性
  ///
  static const kMemberTag = 'tag';
}

///
/// 系统来电的状态。移动端会修改该属性，其他端仅读该属性
///
class PhoneStateProperty {
  static const key = 'phoneState';
  static const valueIsInCall = '1';
}

///
/// 音频控制
///
class AudioControlProperty {
  static const key = 'audioOff';
}

///
/// 视频控制
///
class VideoControlProperty {
  static const key = 'videoOff';
}

///
/// 水印房间属性Key
///
class WatermarkProperty {
  static const key = 'watermark';
}

///
/// 访客入会开关属性Key
///
class GuestJoinProperty {
  static const key = 'guest';

  /// 未启用
  static const disable = '0';

  /// 启用
  static const enable = '1';
}

class MeetingRoles {
  MeetingRoles._();

  /// 主持人
  static const kHost = 'host';

  /// 与会者
  static const kMember = 'member';

  /// 联系主持人
  static const kCohost = 'cohost';

  /// 投屏端，默认在startShare时使用该角色
  static const kScreenSharer = 'screen_sharer';

  /// 传空，服务端会自动分配角色
  static const kUndefined = '';

  /// 外部访客
  static const kGuest = 'guest';

  ///
  /// 将 String类型的roleType 转换为 枚举
  ///
  static NEMeetingRoleType mapStringRoleToEnum(String role) {
    var roleType = NEMeetingRoleType.member;
    switch (role) {
      case MeetingRoles.kHost:
        roleType = NEMeetingRoleType.host;
        break;
      case MeetingRoles.kCohost:
        roleType = NEMeetingRoleType.coHost;
        break;
      case MeetingRoles.kGuest:
        roleType = NEMeetingRoleType.guest;
        break;
    }
    return roleType;
  }

  ///
  /// 将 枚举类型的roleType 转换为 String
  ///
  static String mapEnumRoleToString(NEMeetingRoleType role) {
    var roleType = MeetingRoles.kMember;
    switch (role) {
      case NEMeetingRoleType.host:
        roleType = MeetingRoles.kHost;
        break;
      case NEMeetingRoleType.coHost:
        roleType = MeetingRoles.kCohost;
        break;
      case NEMeetingRoleType.member:
        break;
      case NEMeetingRoleType.guest:
        roleType = MeetingRoles.kGuest;
        break;
    }
    return roleType;
  }

  ///
  /// 将 int类型的roleType 转换为 枚举，目前用于native过来的 角色类型
  ///
  static NEMeetingRoleType mapIntRoleToEnum(int role) {
    var roleType = NEMeetingRoleType.member;
    switch (role) {
      case 0:
        roleType = NEMeetingRoleType.host;
        break;
      case 1:
        roleType = NEMeetingRoleType.coHost;
        break;
      case 3:
        roleType = NEMeetingRoleType.guest;
        break;
    }
    return roleType;
  }
}
