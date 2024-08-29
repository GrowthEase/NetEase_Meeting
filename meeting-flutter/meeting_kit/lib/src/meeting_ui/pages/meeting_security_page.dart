// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingSecurityPage extends StatefulWidget {
  static const String routeName = "/meetingSecurity";
  final SecurityArguments _arguments;

  MeetingSecurityPage(this._arguments);

  @override
  State<StatefulWidget> createState() {
    return MeetingSecurityState(_arguments);
  }
}

class MeetingSecurityState extends LifecycleBaseState<MeetingSecurityPage>
    with MeetingKitLocalizationsMixin, MeetingStateScope, _AloggerMixin {
  final SecurityArguments _arguments;
  late final NERoomContext _roomContext;
  late final NERoomEventCallback roomEventCallback;
  final watermarkEnabled = ValueNotifier<bool>(false);
  final isLocked = ValueNotifier<bool>(false);
  final isBlackListEnabled = ValueNotifier<bool>(true);
  final guestJoinEnabled = ValueNotifier<bool>(false);
  final hideAvatar = ValueNotifier<bool>(false);

  final meetingChatEnabled = ValueNotifier<bool>(true);
  final isAnnotationPermissionEnabled = ValueNotifier<bool>(true);
  final isShareScreenEnabled = ValueNotifier<bool>(true);
  final isUnmuteAudioBySelfEnabled = ValueNotifier<bool>(true);
  final isUnmuteVideoBySelfEnabled = ValueNotifier<bool>(true);
  final isUpdateNicknameBySelfEnabled = ValueNotifier<bool>(true);
  final isShareWhiteboardEnabled = ValueNotifier<bool>(true);
  final isLocalRecordEnabled = ValueNotifier<bool>(false);

  MeetingSecurityState(this._arguments);

  @override
  void initState() {
    super.initState();
    _roomContext = _arguments.roomContext;
    isLocked.value = _roomContext.isRoomLocked;
    watermarkEnabled.value = _roomContext.watermark.isEnable();
    guestJoinEnabled.value = _roomContext.isGuestJoinEnabled;
    hideAvatar.value = _roomContext.isAvatarHidden;
    isBlackListEnabled.value = _roomContext.isRoomBlackListEnabled;
    isAnnotationPermissionEnabled.value =
        _roomContext.isAnnotationPermissionEnabled;
    isShareScreenEnabled.value = _roomContext.isScreenSharePermissionEnabled;
    isUnmuteAudioBySelfEnabled.value = _roomContext.isUnmuteAudioBySelfEnabled;
    isUnmuteVideoBySelfEnabled.value = _roomContext.isUnmuteVideoBySelfEnabled;
    isUpdateNicknameBySelfEnabled.value =
        _roomContext.isUpdateNicknamePermissionEnabled;
    isShareWhiteboardEnabled.value = _roomContext.isWhiteboardPermissionEnabled;
    isLocalRecordEnabled.value = _roomContext.isLocalRecordPermissionEnabled;
    meetingChatEnabled.value =
        _roomContext.chatPermission != NEChatPermission.noChat;
    _roomContext.addEventCallback(roomEventCallback = NERoomEventCallback(
      roomLockStateChanged: (value) => isLocked.value = value,
      roomPropertiesChanged: _onRoomPropertiesChanged,
      roomBlacklistStateChanged: (value) => isBlackListEnabled.value = value,
    ));
    _arguments.waitingRoomManager.waitingRoomEnabledOnEntryListenable
        .addListener(_onWaitingRoomEnabledOnEntryChanged);
  }

  @override
  void dispose() {
    _arguments.waitingRoomManager.waitingRoomEnabledOnEntryListenable
        .removeListener(_onWaitingRoomEnabledOnEntryChanged);
    _roomContext.removeEventCallback(roomEventCallback);
    super.dispose();
  }

  void _onWaitingRoomEnabledOnEntryChanged() {
    if (_arguments.waitingRoomManager.waitingRoomController
        .isWaitingRoomEnabledOnEntry()) {
      showToast(meetingUiLocalizations.waitingRoomEnabledOnEntry);
    } else {
      showToast(meetingUiLocalizations.waitingRoomDisabledOnEntry);
    }
  }

  void _onRoomPropertiesChanged(Map<String, String> properties) {
    if (properties.containsKey(WatermarkProperty.key)) {
      watermarkEnabled.value = _roomContext.watermark.isEnable();
      showToast(watermarkEnabled.value
          ? NEMeetingUIKitLocalizations.of(context)!.meetingWatermarkEnabled
          : NEMeetingUIKitLocalizations.of(context)!.meetingWatermarkDisabled);
    }
    if (properties.containsKey(NEChatPermissionProperty.key)) {
      meetingChatEnabled.value =
          _roomContext.chatPermission != NEChatPermission.noChat;
      showToast(meetingChatEnabled.value
          ? NEMeetingUIKitLocalizations.of(context)!.meetingChatEnabled
          : NEMeetingUIKitLocalizations.of(context)!.meetingChatDisabled);
    }
    if (properties.containsKey(GuestJoinProperty.key)) {
      guestJoinEnabled.value = _roomContext.isGuestJoinEnabled;
      showToast(guestJoinEnabled.value
          ? NEMeetingUIKitLocalizations.of(context)!.meetingGuestJoinEnabled
          : NEMeetingUIKitLocalizations.of(context)!.meetingGuestJoinDisabled);
    }
    if (properties.containsKey(MeetingSecurityCtrlKey.securityCtrlKey)) {
      hideAvatar.value = _roomContext.isAvatarHidden;
      isAnnotationPermissionEnabled.value =
          _roomContext.isAnnotationPermissionEnabled;
      isShareScreenEnabled.value = _roomContext.isScreenSharePermissionEnabled;
      isUnmuteVideoBySelfEnabled.value =
          _roomContext.isUnmuteVideoBySelfEnabled;
      isUnmuteAudioBySelfEnabled.value =
          _roomContext.isUnmuteAudioBySelfEnabled;
      isUpdateNicknameBySelfEnabled.value =
          _roomContext.isUpdateNicknamePermissionEnabled;
      isShareWhiteboardEnabled.value =
          _roomContext.isWhiteboardPermissionEnabled;
      isLocalRecordEnabled.value = _roomContext.isLocalRecordPermissionEnabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Scaffold(
      backgroundColor: _UIColors.globalBg,
      appBar: TitleBar(
        title: TitleBarTitle(meetingUiLocalizations.meetingSecurity),
      ),
      body: _buildBody(),
    );
    return AutoPopScope(
      listenable: _arguments.isMySelfManagerListenable,
      onWillAutoPop: (_) {
        return !_arguments.isMySelfManagerListenable.value;
      },
      child: child,
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// 管理成员模块
                MeetingCard(
                    title: meetingUiLocalizations.meetingManagement,
                    iconData: NEMeetingIconFont.icon_settings,
                    iconColor: _UIColors.color8D90A0,
                    children: [
                      if (_arguments.waitingRoomManager.isFeatureSupported) ...[
                        _buildWaitingRoom(),
                      ],
                      if (!_roomContext.watermark.isForce()) ...[
                        _buildWatermark(),
                      ],
                      _buildLockMeeting(),
                      _buildBlackList(),
                      if (_arguments.isGuestJoinSupported) ...[
                        _buildGuestJoin(),
                      ],
                      _buildHideAvatar(),
                    ]),

                /// 允许成员
                MeetingCard(
                  title: meetingUiLocalizations.meetingAllowMembersTo,
                  iconData: NEMeetingIconFont.icon_members,
                  iconColor: _UIColors.color_337eff,
                  children: [
                    if (meetingUIState.sdkConfig.isMeetingChatSupported)
                      _buildMeetingChat(),
                    _buildShareScreen(),
                    _buildUnmuteAudioBySelf(),
                    _buildUnmuteVideoBySelf(),
                    _buildUpdateNicknameBySelf(),
                    _buildShareWhiteboard(),
                    _buildAnnotationPermission(),
                    // 本地录制，暂时还没有
                    // _buildLocalRecord(),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
        Container(
          color: _UIColors.white,
          child: Padding(
            padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 10,
                bottom: 10 + MediaQuery.of(context).padding.bottom),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(width: 1, color: _UIColors.colorF51D45),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  meetingUiLocalizations.suspendParticipantActivities,
                  style: TextStyle(
                    color: _UIColors.colorF51D45,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                onPressed: () {
                  DialogUtils.showCommonDialog(
                    context,
                    meetingUiLocalizations.suspendAllParticipantActivities,
                    meetingUiLocalizations.suspendParticipantActivitiesTips,
                    acceptText: meetingUiLocalizations.globalPause,
                    () {
                      Navigator.of(context).pop();
                    },
                    () {
                      _stopMemberActivities();
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  MeetingSwitchItem _buildWaitingRoom() {
    return MeetingSwitchItem(
      switchKey: MeetingUIValueKeys.waitingRoomSwitch,
      title: meetingUiLocalizations.waitingRoom,
      valueNotifier:
          _arguments.waitingRoomManager.waitingRoomEnabledOnEntryListenable,
      onChanged: (on) async {
        if (on) {
          doIfNetworkAvailable(() async {
            _arguments.waitingRoomManager.waitingRoomController
                .enableWaitingRoomOnEntry()
                .then((result) {
              if (mounted && !result.isSuccess()) {
                showToast(
                  result.msg ?? meetingUiLocalizations.globalOperationFail,
                );
              }
            });
          });
        } else {
          if (_arguments.waitingRoomManager.currentMemberCount > 0) {
            showConfirmDialogWithCheckbox(
              title: meetingUiLocalizations.waitingRoomDisableDialogTitle,
              message: meetingUiLocalizations.waitingRoomDisableDialogMessage,
              checkboxMessage:
                  meetingUiLocalizations.waitingRoomDisableDialogAdmitAll,
              initialChecked: false,
              cancelLabel: meetingUiLocalizations.globalCancel,
              okLabel: meetingUiLocalizations.waitingRoomCloseRightNow,
              contentWrapperBuilder: (child) {
                return AutoPopScope(
                  listenable: _arguments.isMySelfManagerListenable,
                  onWillAutoPop: (_) {
                    return !_arguments.isMySelfManagerListenable.value;
                  },
                  child: child,
                );
              },
            ).then((result) {
              if (!mounted || result == null) return;
              disableWaitingRoomOnEntry(result.checked);
            });
          } else {
            disableWaitingRoomOnEntry(false);
          }
        }
      },
    );
  }

  void disableWaitingRoomOnEntry(bool admitAll) {
    doIfNetworkAvailable(() async {
      _arguments.waitingRoomManager.waitingRoomController
          .disableWaitingRoomOnEntry(admitAll)
          .then((result) {
        if (mounted && !result.isSuccess()) {
          showToast(
            result.msg ?? meetingUiLocalizations.globalOperationFail,
          );
        }
      });
    });
  }

  MeetingSwitchItem _buildGuestJoin() {
    return MeetingSwitchItem(
        switchKey: MeetingUIValueKeys.meetingEnableGuestJoin,
        title: meetingUiLocalizations.meetingGuestJoin,
        contentBuilder: (enable) => Text(
              enable
                  ? meetingUiLocalizations.meetingGuestJoinSecurityNotice
                  : meetingUiLocalizations.meetingGuestJoinEnableTip,
              style: TextStyle(
                fontSize: 12,
                color: enable ? _UIColors.color_f29900 : _UIColors.color_999999,
              ),
            ),
        valueNotifier: guestJoinEnabled,
        onChanged: (newValue) => _handleGuestJoin(newValue));
  }

  MeetingSwitchItem _buildAnnotationPermission() {
    return MeetingSwitchItem(
        switchKey: MeetingUIValueKeys.meetingAnnotationPermissionEnabled,
        title: meetingUiLocalizations.meetingAnnotationPermissionEnabled,
        valueNotifier: isAnnotationPermissionEnabled,
        onChanged: (newValue) => _enableAnnotationPermission(newValue));
  }

  MeetingSwitchItem _buildWatermark() {
    return MeetingSwitchItem(
        switchKey: MeetingUIValueKeys.watermarkSwitch,
        title: meetingUiLocalizations.meetingWatermark,
        valueNotifier: watermarkEnabled,
        onChanged: (newValue) => _updateWatermarkState(newValue));
  }

  MeetingSwitchItem _buildLockMeeting() {
    return MeetingSwitchItem(
        switchKey: MeetingUIValueKeys.meetingLockSwitch,
        title: meetingUiLocalizations.meetingLock,
        valueNotifier: isLocked,
        onChanged: (newValue) => _updateLockState(newValue));
  }

  MeetingSwitchItem _buildHideAvatar() {
    return MeetingSwitchItem(
        switchKey: MeetingUIValueKeys.meetingHideAvatar,
        title: meetingUiLocalizations.hideAvatar,
        valueNotifier: hideAvatar,
        onChanged: (newValue) => _updateHideAvatar(newValue));
  }

  MeetingSwitchItem _buildBlackList() {
    return MeetingSwitchItem(
        switchKey: MeetingUIValueKeys.meetingBlacklist,
        title: meetingUiLocalizations.meetingBlacklist,
        content: meetingUiLocalizations.meetingBlacklistDetail,
        valueNotifier: isBlackListEnabled,
        onChanged: (newValue) => _updateBlackListState(newValue));
  }

  MeetingSwitchItem _buildMeetingChat() {
    return MeetingSwitchItem(
        switchKey: MeetingUIValueKeys.meetingChat,
        title: meetingUiLocalizations.meetingChat,
        valueNotifier: meetingChatEnabled,
        onChanged: (newValue) => _updateMeetingChatState(newValue));
  }

  MeetingSwitchItem _buildShareScreen() {
    return MeetingSwitchItem(
        switchKey: MeetingUIValueKeys.meetingShareScreen,
        title: meetingUiLocalizations.screenShare,
        valueNotifier: isShareScreenEnabled,
        onChanged: (newValue) => _updateScreenSharePermission(newValue));
  }

  MeetingSwitchItem _buildUnmuteAudioBySelf() {
    return MeetingSwitchItem(
        switchKey: MeetingUIValueKeys.unmuteAudioBySelf,
        title: meetingUiLocalizations.unmuteAudioBySelf,
        valueNotifier: isUnmuteAudioBySelfEnabled,
        onChanged: (newValue) => _updateUnmuteAudioBySelfPermission(newValue));
  }

  MeetingSwitchItem _buildUnmuteVideoBySelf() {
    return MeetingSwitchItem(
        switchKey: MeetingUIValueKeys.unmuteVideoBySelf,
        title: meetingUiLocalizations.participantStartVideo,
        valueNotifier: isUnmuteVideoBySelfEnabled,
        onChanged: (newValue) => _updateUnmuteVideoBySelfPermission(newValue));
  }

  MeetingSwitchItem _buildUpdateNicknameBySelf() {
    return MeetingSwitchItem(
        switchKey: MeetingUIValueKeys.updateNicknameBySelf,
        title: meetingUiLocalizations.updateNicknameBySelf,
        valueNotifier: isUpdateNicknameBySelfEnabled,
        onChanged: (newValue) => _updateNicknamePermission(newValue));
  }

  MeetingSwitchItem _buildShareWhiteboard() {
    return MeetingSwitchItem(
        switchKey: MeetingUIValueKeys.meetingShareWhiteboard,
        title: meetingUiLocalizations.whiteboardShare,
        valueNotifier: isShareWhiteboardEnabled,
        onChanged: (newValue) => _updateWhiteboardPermission(newValue));
  }

  MeetingArrowItem _buildLocalRecord() {
    return MeetingArrowItem(
      title: meetingUiLocalizations.localRecordPermission,
      content: meetingUiLocalizations.localRecordOnlyHost,
    );
  }

  /// 锁定会议
  void _updateLockState(bool lock) {
    doIfNetworkAvailable(() {
      lifecycleExecute(
              lock ? _roomContext.lockRoom() : _roomContext.unlockRoom())
          .then((result) {
        if (!mounted) return;
        if (result?.isSuccess() == true) {
          showToast(lock
              ? meetingUiLocalizations.meetingLockMeetingByHost
              : meetingUiLocalizations.meetingUnLockMeetingByHost);
        } else {
          showToast(lock
              ? meetingUiLocalizations.meetingLockMeetingByHostFail
              : meetingUiLocalizations.meetingUnLockMeetingByHostFail);
        }
      });
    });
  }

  /// 设置头像显示隐藏
  void _updateHideAvatar(bool hide) {
    doIfNetworkAvailable(() {
      lifecycleExecute(_roomContext.updateHideAvatar(hide));
    });
  }

  /// 设置是否允许成员批注
  void _enableAnnotationPermission(bool enabled) {
    doIfNetworkAvailable(() {
      lifecycleExecute(_roomContext.enableAnnotationPermission(enabled));
    });
  }

  /// 点击访客入会开关处理
  void _handleGuestJoin(bool enable) {
    if (!enable) {
      _enableGuestJoin(false);
    } else {
      DialogUtils.showCommonDialog(
          context,
          meetingUiLocalizations.meetingGuestJoinConfirm,
          meetingUiLocalizations.meetingGuestJoinConfirmTip, () {
        Navigator.of(context).pop();
      }, () {
        _enableGuestJoin(true);
        Navigator.of(context).pop();
      });
    }
  }

  /// 设置是否支持访客入会
  void _enableGuestJoin(bool enable) {
    doIfNetworkAvailable(() {
      lifecycleExecute(_roomContext.enableGuestJoin(enable));
    });
  }

  /// 开关会议水印
  void _updateWatermarkState(bool watermark) {
    doIfNetworkAvailable(() {
      lifecycleExecute(_roomContext.enableConfidentialWatermark(watermark));
    });
  }

  /// 黑名单
  void _updateBlackListState(bool enable) {
    if (enable) {
      modifyBlackListState2Server(true);
    } else {
      DialogUtils.showCommonDialog(
          context,
          meetingUiLocalizations.unableMeetingBlacklistTitle,
          meetingUiLocalizations.unableMeetingBlacklistTip, () {
        Navigator.of(context).pop();
      }, () {
        modifyBlackListState2Server(false);
        Navigator.of(context).pop();
      });
    }
  }

  void modifyBlackListState2Server(bool enable) {
    doIfNetworkAvailable(() {
      lifecycleExecute(_roomContext.enableRoomBlacklist(enable)).then((result) {
        commonLogger
            .i('modifyBlackListState2Server enable: $enable result: $result');
      });
    });
  }

  /// 开关会中聊天
  void _updateMeetingChatState(bool enable) {
    doIfNetworkAvailable(() {
      lifecycleExecute(_roomContext.updateChatPermission(
              enable ? NEChatPermission.freeChat : NEChatPermission.noChat))
          .then((result) {
        if (!mounted) return;
      });
    });
  }

  /// 暂停参会者活动
  void _stopMemberActivities() {
    doIfNetworkAvailable(() {
      lifecycleExecute(_roomContext.stopMemberActivities()).then((result) {
        commonLogger.i('stopMemberActivities result: $result');
        if (!mounted) return;
      });
    });
  }

  void _updateScreenSharePermission(bool enable) {
    doIfNetworkAvailable(() {
      lifecycleExecute(_roomContext.updateScreenSharePermission(enable));
    });
  }

  void _updateWhiteboardPermission(bool enable) {
    doIfNetworkAvailable(() {
      lifecycleExecute(_roomContext.updateWhiteboardPermission(enable));
    });
  }

  void _updateNicknamePermission(bool enable) {
    doIfNetworkAvailable(() {
      lifecycleExecute(_roomContext.updateNicknamePermission(enable));
    });
  }

  void _updateLocalRecordPermission(bool enable) {
    doIfNetworkAvailable(() {
      lifecycleExecute(_roomContext.updateLocalRecordPermission(enable));
    });
  }

  void _updateUnmuteAudioBySelfPermission(bool enable) {
    doIfNetworkAvailable(() {
      lifecycleExecute(_roomContext.updateUnmuteAudioBySelfPermission(enable));
    });
  }

  void _updateUnmuteVideoBySelfPermission(bool enable) {
    doIfNetworkAvailable(() {
      lifecycleExecute(_roomContext.updateUnmuteVideoBySelfPermission(enable));
    });
  }
}
