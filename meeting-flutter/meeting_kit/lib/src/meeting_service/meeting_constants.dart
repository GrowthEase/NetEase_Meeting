// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

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

  ///
  /// 未启用
  ///
  static const disable = "disable";

  ///
  /// 自动关闭，允许自行解除
  ///
  static const offAllowSelfOn = "offAllowSelfOn";

  ///
  /// 自动关闭，不允许自行解除
  ///
  static const offNotAllowSelfOn = "offNotAllowSelfOn";
}

///
/// 视频控制
///
class VideoControlProperty {
  static const key = 'videoOff';

  ///
  /// 未启用
  ///
  static const disable = "disable";

  ///
  /// 自动关闭，允许自行解除
  ///
  static const offAllowSelfOn = "offAllowSelfOn";

  ///
  /// 自动关闭，不允许自行解除
  ///
  static const offNotAllowSelfOn = "offNotAllowSelfOn";
}

class MeetingRoles {
  MeetingRoles._();

  /// 主持人
  static const kHost = 'host';

  /// 与会者
  static const kMember = 'member';

  /// 联系主持人
  static const kCohost = 'cohost';

  /// 传空，服务端会自动分配角色
  static const kUndefined = '';

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
    }
    return roleType;
  }
}
