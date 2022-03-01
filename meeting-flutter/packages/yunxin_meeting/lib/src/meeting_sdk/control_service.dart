// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_sdk;

class NEControlParams {
  /// 会议中的用户昵称，不能为空
  /// 使用电视的昵称入会（目前做兼容TV老版本使用）
  final String displayName;
  NEControlParams({required this.displayName});
}

class NEControlOptions {
  /// 遥控器首页右上角设置自定义按钮，可添加监听器处理菜单点击事件
  final NEControlMenuItem? settingMenu;
  /// 遥控器会控页面邀请设置自定义按钮，可添加监听器处理菜单点击事件
  final NEControlMenuItem? shareMenu;
  /// "Toolbar"自定义菜单
  late final List<NEMeetingMenuItem> injectedToolbarMenuItems;
  /// "更多"自定义菜单，可添加监听器处理菜单点击事件
  late final List<NEMeetingMenuItem> injectedMoreMenuItems;

  static NEControlOptions fromJson(Map<String, dynamic> json) {
    return NEControlOptions(
      settingMenu: handleControlMenuItem(json['settingMenu']),
      shareMenu: handleControlMenuItem(json['shareMenu']),
      injectedToolbarMenuItems:
          buildMenuItemList(json['fullToolbarMenuItems'] as List?),
      injectedMoreMenuItems:
          buildMenuItemList(json['fullMoreMenuItems'] as List?),
    );
  }

  NEControlOptions({
    this.settingMenu,
    this.shareMenu,
    List<NEMeetingMenuItem>? injectedToolbarMenuItems,
    List<NEMeetingMenuItem>? injectedMoreMenuItems,
  }) {
    this.injectedToolbarMenuItems = injectedToolbarMenuItems ?? NEControlMenuItems.defaultToolbarMenuItems;
    this.injectedMoreMenuItems = injectedMoreMenuItems ?? NEControlMenuItems.defaultMoreMenuItems;
  }

  @override
  String toString() {
    return 'NEControlOptions{settingMenu: $settingMenu, shareMenu: $shareMenu, injectedToolbarMenuItems: $injectedToolbarMenuItems, injectedMoreMenuItems: $injectedMoreMenuItems}';
  }
}

NEControlMenuItem? handleControlMenuItem(json) {
  if(json == null){
    return null;
  }
  return NEControlMenuItem.fromJson(json as Map<String, dynamic>);
}

/// 遥控器自定义设置菜单按钮点击事件回调，通过 NEControlService.setOnSettingMenuItemClickListener 设置回调监听
/// 遥控器自定义分享菜单按钮点击事件回调，通过 NEControlService.setOnShareMenuItemClickListener 设置回调监听
///
/// [NEControlMenuItem] 为当前点击的菜单项
typedef NEControlMenuItemClickListener = void Function(NEControlMenuItem menuItem, NEMeetingInfo? meetingInfo);

/// 遥控器自定义按钮
class NEControlMenuItem {
  /// 名称
  final String title;

  NEControlMenuItem.fromJson(Map<String, dynamic> json)
      : title = json['title'] as String;

  Map<String, dynamic> toJson() =>
      {
        'title': title,
      };

  NEControlMenuItem(this.title);
}

/// 用于提供遥控器服务
/// 通过[NEMeetingSDK.getControlService]获取账号服务的实例
abstract class NEControlService {
  /// 打开遥控器
  Future<NEResult<void>> openControl(BuildContext context, NEControlParams params, NEControlOptions opts);

  /// 设置遥控器首页右上角点击事件回调
  void setOnSettingMenuItemClickListener(NEControlMenuItemClickListener listener);

  /// 获取当前会议详情。如果当前无正在进行中的会议，则回调数据对象为空
  NEMeetingInfo? getCurrentMeetingInfo();

  /// 获取当前会议状态
  NEMeetingStatus getMeetingStatus();

  /// 自定义工具栏回调
  void setOnInjectedMenuItemClickListener(NEMeetingOnInjectedMenuItemClickListener listener);

  /// 注册监听遥控器回调
  void registerControlListener(ControlListener listener);

  /// 反注册监听遥控器回调
  void unRegisterControlListener(ControlListener listener);
}

/// 会议登陆状态回调
abstract class ControlListener {
  /// 创建会议回调
  void onStartMeetingResult(NEControlResult status);

  /// 加入会议回调
  void onJoinMeetingResult(NEControlResult status);

  /// 解除绑定
  void onUnbind(int unBindType);

  /// 遥控器、TV协议有变更
  void onTCProtocolUpgrade(NETCProtocolUpgrade protocolUpgrade);
}

/// Control status.
class NEControlResult {
  final int code;
  final String? message;

  NEControlResult.fromJson(Map<String, dynamic> json)
      : code = json['code'] as int,
        message = json['message'] as String?;

  Map<String, dynamic> toJson() =>
      {
        'code': code,
        'message': message,
      };

  NEControlResult(this.code, [this.message]);
}

class NEUnbindType {
  static const int tvUnbind = 1;
  static const int forceUnbind = 2;
}

class NETCProtocolUpgrade {
  String controllerProtocolVersion;
  String tvProtocolVersion;
  bool isCompatible;

  NETCProtocolUpgrade.fromJson(Map<String, dynamic> json)
      : controllerProtocolVersion = json['controllerProtocolVersion'] as String,
        tvProtocolVersion = json['tvProtocolVersion'] as String,
        isCompatible = json['isCompatible'] as bool;

  Map<String, dynamic> toJson() =>
      {
        'controllerProtocolVersion': controllerProtocolVersion,
        'tvProtocolVersion': tvProtocolVersion,
        'isCompatible': isCompatible,
      };
  NETCProtocolUpgrade(this.controllerProtocolVersion, this.tvProtocolVersion, this.isCompatible);
}
