// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 入会邀请
class InComingInvite extends StatefulWidget {
  final Widget child;
  final bool isInMinimizedMode;

  InComingInvite({
    required this.child,
    required this.isInMinimizedMode,
  });

  @override
  _InComingInviteState createState() => _InComingInviteState();
}

class _InComingInviteState extends State<InComingInvite> {
  /// 邀请信息
  ValueListenable<CardData?> _inviteListener =
      InviteQueueUtil.instance.currentInviteData;

  @override
  Widget build(BuildContext context) {
    final bool Function() isInMeeting =
        () => NEMeetingUIKit().getCurrentMeetingInfo() != null;
    return Stack(
      alignment: Alignment.center,
      children: [
        widget.child,
        ValueListenableBuilder(
            valueListenable: _inviteListener,
            builder: (_, value, __) {
              final inviteInfo = value?.inviteInfo;
              return Visibility(
                visible: value != null,
                child: NEMeetingUIKitLocalizationsScope(
                    child: MeetingAppInviting(
                  title: value?.notifyCard?.body?.title,
                  popupDuration: value?.popupDuration ?? 60,
                  meetingSubject: '${inviteInfo?.subject}',
                  userName: '${inviteInfo?.inviterName}',
                  userAvatar: inviteInfo?.inviterIcon,
                  isFullScreen: !isInMeeting.call(),

                  /// 如果是预约会议即将开始的邀请，即outOfMeeting为true，不展示邀请人信息
                  showInviter: inviteInfo?.outOfMeeting != true,
                  isInMinimizedMode: widget.isInMinimizedMode,
                  onAction: (type) =>
                      MeetingInviteHelper.handleInviteAction(type, value),
                )),
              );
            }),
      ],
    );
  }
}

/// 处理邀请错误码
/// [code] 错误码
/// [meetingUiLocalizations] 本地化
/// [context] 上下文
///
void handleInviteCodeError(BuildContext context, int? code,
    NEMeetingUIKitLocalizations meetingUiLocalizations) {
  switch (code) {
    case 1022:
      ToastUtils.showToast(
          context, meetingUiLocalizations.memberCountOutOfRange);
      break;
    case 3006:
      ToastUtils.showToast(context, meetingUiLocalizations.sipCallIsInMeeting);
      break;
    case 601011:
      ToastUtils.showToast(
          context, meetingUiLocalizations.sipCallIsInBlacklist);
      break;
    default:
      break;
  }
}
