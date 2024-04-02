// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 会议webapp页面,清理所有消息
typedef ClearAllMessage = void Function(String? sessionId)?;

class MeetingNotifyCenterActionUtil {
  static const action_pre = 'meeting://';
  static const action_plugin_pre = '${action_pre}open_plugin?';

  static const action_meeting_history = '${action_pre}meeting_history';
  static const action_no_more_remind = 'meeting://no_more_remind';

  /// 获取plugin_id
  static String? getPluginId(String action) {
    Uri uri = Uri.parse(action);
    return uri.queryParameters['plugin_id'];
  }

  /// 打开插件
  static void openPlugin(BuildContext context, NERoomContext roomContext,
      NESingleStateMenuItem<NEMeetingWebAppItem> item,
      {ClearAllMessage clearAllMessage}) {
    Navigator.of(context).push(MaterialMeetingPageRoute(
        settings: RouteSettings(name: MeetingWebAppPage.routeName),
        builder: (context) {
          return wrapWithWatermark(
              child: MeetingWebAppPage(
            roomArchiveId: roomContext.meetingInfo.roomArchiveId!,
            homeUrl: item.singleStateItem.customObject!.homeUrl,
            title: item.singleStateItem.customObject!.name,
            sessionId: item.singleStateItem.customObject!.sessionId,
            roomContext: roomContext,
            clearAllMessage: clearAllMessage,
          ));
        }));
  }

  /// 将插件转化成sessionList
  static List<String> convertToSessionList(
      List<NESingleStateMenuItem<NEMeetingWebAppItem>> webAppList) {
    return webAppList
        .map((e) => e.singleStateItem.customObject?.sessionId ?? '')
        .toList();
  }

  /// 获取sessionId
  ///
  static String? getActionSessionIdByPluginId(
      List<NESingleStateMenuItem<NEMeetingWebAppItem>> webAppList,
      String? pluginId) {
    if (webAppList.length <= 0) {
      return null;
    }
    var item = webAppList.firstWhere(
        (element) => element.singleStateItem.customObject?.pluginId == pluginId,
        orElse: () => NESingleStateMenuItem<NEMeetingWebAppItem>(
              itemId: -1,
              visibility: NEMenuVisibility.visibleAlways,
              singleStateItem: NEMenuItemInfo(text: ''),
            ));
    return item.singleStateItem.customObject?.sessionId;
  }
}
