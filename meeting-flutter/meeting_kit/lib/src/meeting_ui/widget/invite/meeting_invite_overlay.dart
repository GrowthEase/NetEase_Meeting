// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 入会邀请
class InComingInvite extends StatefulWidget {
  final BuildContext? Function()? currentContext;
  final Widget child;
  final bool isInMinimizedMode;
  final Widget? backgroundWidget;
  final String Function() getDefaultNickName;
  final Future<NEMeetingOptions> Function(bool)? buildMeetingUIOptions;

  InComingInvite({
    this.currentContext,
    required this.child,
    required this.isInMinimizedMode,
    required this.getDefaultNickName,
    this.backgroundWidget,
    this.buildMeetingUIOptions,
  });

  @override
  _InComingInviteState createState() => _InComingInviteState();
}

class _InComingInviteState extends State<InComingInvite>
    with NEMeetingInviteStatusListener, _AloggerMixin {
  /// 邀请信息
  final _inviteListener = MeetingInviteRepository().currentInviteData;

  @override
  Widget build(BuildContext context) {
    final bool Function() isInMeeting =
        () => NEMeetingUIKit.instance.getCurrentMeetingInfo() != null;
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
                  onAction: (type) => handleInviteAction(type, value),
                )),
              );
            }),
      ],
    );
  }

  /// 处理点击事件
  void handleInviteAction(InviteJoinActionType type, CardData? cardData) async {
    if (cardData == null) return;
    final meetingId = cardData.meetingId;
    final meetingNum = cardData.meetingNum;
    if (type == InviteJoinActionType.reject) {
      if (meetingId != null) {
        NEMeetingUIKit.instance
            .getMeetingInviteService()
            .rejectInvite(meetingId);
      }
    } else {
      accept(meetingNum, type == InviteJoinActionType.videoAccept);
    }
  }

  void accept(String? meetingNum, bool videoAccept) async {
    if (meetingNum == null) {
      commonLogger.i('try to accept invite, but invite info is null');
      return;
    }
    final currentMeetingContext =
        NEMeetingUIKit.instance.getCurrentRoomContext();
    if (currentMeetingContext != null) {
      commonLogger.i('leave room before accept invite');
      await currentMeetingContext.leaveRoom();
      await Future.delayed(Duration(milliseconds: 500));
    }
    LoadingUtil.showLoading();
    final lastUsedNickname =
        LocalHistoryMeetingManager().getLatestNickname(meetingNum);
    final nickName = lastUsedNickname ?? widget.getDefaultNickName();
    final uiOption = await widget.buildMeetingUIOptions?.call(videoAccept);
    final accountInfo = AccountRepository().getAccountInfo();
    NEMeetingUIKit.instance.getMeetingInviteService().acceptInvite(
      widget.currentContext?.call() ?? context,
      NEJoinMeetingParams(
        meetingNum: meetingNum,
        displayName: nickName,
        watermarkConfig: NEWatermarkConfig(
          name: nickName,
          phone: accountInfo?.phoneNumber,
          email: accountInfo?.email,
        ),
      ),
      uiOption ?? NEMeetingOptions(noAudio: false, noVideo: !videoAccept),
      onPasswordPageRouteWillPush: () async {
        LoadingUtil.cancelLoading();
      },
      onMeetingPageRouteWillPush: () async {
        LoadingUtil.cancelLoading();
      },
      backgroundWidget: widget.backgroundWidget,
    ).then((result) {
      LoadingUtil.cancelLoading();
      if (result.isSuccess()) {
      } else {
        if (mounted) {
          ToastUtils.showToast(context, result.msg);
        }
      }
    });
  }
}

/// 处理邀请错误码
/// [code] 错误码
/// [meetingUiLocalizations] 本地化
/// [context] 上下文
///
void handleInviteCodeError(BuildContext context, int? code,
    NEMeetingUIKitLocalizations meetingUiLocalizations, bool isRoomDevice) {
  switch (code) {
    case 1022:
      ToastUtils.showToast(
          context, meetingUiLocalizations.memberCountOutOfRange);
      break;
    case 3006:
      ToastUtils.showToast(
          context,
          isRoomDevice
              ? meetingUiLocalizations.sipDeviceIsInMeeting
              : meetingUiLocalizations.sipCallIsInMeeting);
      break;
    case 601011:
      ToastUtils.showToast(
          context,
          isRoomDevice
              ? meetingUiLocalizations.sipCallDeviceIsInBlacklist
              : meetingUiLocalizations.sipCallIsInBlacklist);
      break;
    default:
      break;
  }
}
