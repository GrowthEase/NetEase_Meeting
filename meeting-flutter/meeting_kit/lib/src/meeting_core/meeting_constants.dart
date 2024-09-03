// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class MeetingSecurityCtrlValue {
  /// 是否允许批注
  static var ANNOTATION_DISABLE = 0x1;

  /// 是否允许屏幕共享
  static final SCREEN_SHARE_DISABLE = 0x2;

  /// 是否允许开启白板
  static final WHILE_BOARD_SHARE_DISABLE = 0x4;

  /// 是否允许自己改名
  static final EDIT_NAME_DISABLE = 0x8;

  /// 是否是全体静音
  static final AUDIO_OFF = 0x10;

  /// 是否允许自行解除静音
  static final AUDIO_NOT_ALLOW_SELF_ON = 0x20;

  /// 是否是全体关闭视频
  static final VIDEO_OFF = 0x40;

  /// 是否允许自行打开视频
  static final VIDEO_NOT_ALLOW_SELF_ON = 0x80;

  /// 表情回复开关
  static final EMOJI_RESP_DISABLE = 0x100;

  /// 本地录制开关
  static final LOCAL_RECORD_DISABLE = 0x200;

  /// 成员加入离开播放提示音
  static final PLAY_SOUND = 0x400;

  /// 头像显示隐藏
  static final AVATAR_HIDE = 0x800;
}

class MeetingSecurityCtrlKey {
  static final securityCtrlKey = 'securityCtrl';

  /// 是否允许批注
  static final ANNOTATION_DISABLE = 'ANNOTATION_DISABLE';

  /// 是否允许屏幕共享
  static final SCREEN_SHARE_DISABLE = 'SCREEN_SHARE_DISABLE';

  /// 是否允许开启白板
  static final WHILE_BOARD_SHARE_DISABLE = 'WHILE_BOARD_SHARE_DISABLE';

  /// 是否允许自己改名
  static final EDIT_NAME_DISABLE = 'EDIT_NAME_DISABLE';

  /// 是否是全体静音
  static final AUDIO_OFF = 'AUDIO_OFF';

  /// 是否允许自行解除静音
  static final AUDIO_NOT_ALLOW_SELF_ON = 'AUDIO_NOT_ALLOW_SELF_ON';

  /// 是否是全体关闭视频
  static final VIDEO_OFF = 'VIDEO_OFF';

  /// 是否允许自行打开视频
  static final VIDEO_NOT_ALLOW_SELF_ON = 'VIDEO_NOT_ALLOW_SELF_ON';

  /// 表情回复开关
  static final EMOJI_RESP_DISABLE = 'EMOJI_RESP_DISABLE';

  /// 本地录制开关
  static final LOCAL_RECORD_DISABLE = 'LOCAL_RECORD_DISABLE';

  /// 成员加入离开播放提示音
  static final PLAY_SOUND = 'PLAY_SOUND';

  /// 头像显示隐藏
  static final AVATAR_HIDE = 'AVATAR_HIDE';
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
