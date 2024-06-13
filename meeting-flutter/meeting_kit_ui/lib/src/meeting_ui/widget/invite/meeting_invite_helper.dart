// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingInviteHelper {
  /// 处理点击事件
  static void handleInviteAction(
      InviteJoinActionType type, CardData? cardData) async {
    final event = InviteJoinActionEvent(type, cardData);
    if (type != InviteJoinActionType.reject) {
      InviteQueueUtil.instance.disposeAllInvite();
    } else {
      if (cardData?.meetingId != null) {
        NEMeetingKit.instance
            .getMeetingInviteService()
            .rejectInvite(cardData!.meetingId!);
      }
      InviteQueueUtil.instance.disposeInvite(cardData);
    }
    EventBus().emit(NEMeetingUIEvents.flutterInvitedChanged, event);
  }
}
