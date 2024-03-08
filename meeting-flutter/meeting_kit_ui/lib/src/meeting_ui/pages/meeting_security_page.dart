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
    with MeetingKitLocalizationsMixin, MeetingUIStateScope {
  final SecurityArguments _arguments;
  late final NERoomContext _roomContext;
  late final NERoomEventCallback roomEventCallback;
  final isLocked = ValueNotifier<bool>(false);
  final watermarkEnabled = ValueNotifier<bool>(false);

  MeetingSecurityState(this._arguments);

  @override
  void initState() {
    super.initState();
    _roomContext = _arguments.roomContext;
    isLocked.value = _roomContext.isRoomLocked;
    watermarkEnabled.value = _roomContext.watermark.isEnable();
    _roomContext.addEventCallback(roomEventCallback = NERoomEventCallback(
      roomLockStateChanged: (value) => isLocked.value = value,
      roomPropertiesChanged: _onRoomPropertiesChanged,
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

  /// 会议成员角色变更，返回会议页面
  void _onRoomPropertiesChanged(Map<String, String> properties) {
    if (properties.containsKey(WatermarkProperty.key)) {
      watermarkEnabled.value = _roomContext.watermark.isEnable();
      showToast(watermarkEnabled.value
          ? NEMeetingUIKitLocalizations.of(context)!.meetingWatermarkEnabled
          : NEMeetingUIKitLocalizations.of(context)!.meetingWatermarkDisabled);
    }
  }

  void doIfNetworkAvailable(VoidCallback callback) async {
    final result = await Connectivity().checkConnectivity();
    if (!mounted) return;
    if (result == ConnectivityResult.none) {
      showToast(meetingKitLocalizations.networkUnavailableCheck);
      return;
    }
    callback();
  }

  @override
  Widget build(BuildContext context) {
    final child = Scaffold(
      backgroundColor: _UIColors.globalBg,
      appBar: buildAppBar(context),
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

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        meetingUiLocalizations.meetingSecurity,
        style: TextStyle(color: _UIColors.color_222222, fontSize: 17),
      ),
      centerTitle: true,
      backgroundColor: _UIColors.white,
      elevation: 0.0,
      leading: IconButton(
        icon: const Icon(
          NEMeetingIconFont.icon_yx_returnx,
          size: 18,
          color: _UIColors.color_666666,
        ),
        onPressed: () {
          Navigator.maybePop(context);
        },
      ),
      // systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  Widget _buildBody() {
    final localizations = NEMeetingUIKitLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSubTitle(localizations.meetingManagement),
          if (_arguments.waitingRoomManager.isFeatureSupported) ...[
            _buildWaitingRoom(localizations.waitingRoom),
            _buildSplit(),
          ],
          if (!_roomContext.watermark.isForce()) ...[
            _buildWatermark(localizations.meetingWatermark),
            _buildSplit(),
          ],
          _buildLockMeeting(localizations.meetingLock),
        ],
      ),
    );
  }

  Widget _buildWaitingRoom(String title) {
    return _buildItemManage(
      key: MeetingUIValueKeys.waitingRoomSwitch,
      title: title,
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

  Widget _buildWatermark(String title) {
    return _buildItemManage(
        key: MeetingUIValueKeys.watermarkSwitch,
        title: title,
        valueNotifier: watermarkEnabled,
        onChanged: (newValue) => _updateWatermarkState(newValue));
  }

  Widget _buildLockMeeting(String title) {
    return _buildItemManage(
        key: MeetingUIValueKeys.meetingLockSwitch,
        title: title,
        valueNotifier: isLocked,
        onChanged: (newValue) => _updateLockState(newValue));
  }

  Widget _buildSubTitle(String subTitle) {
    return Container(
      child: Text(subTitle,
          style: TextStyle(fontSize: 14, color: _UIColors.color_999999)),
      padding: EdgeInsets.only(left: 20, top: 16, bottom: 8),
    );
  }

  Widget _buildItemManage({
    required String title,
    required ValueNotifier<bool> valueNotifier,
    required Function(bool newValue) onChanged,
    Key? key,
  }) {
    return Container(
      height: 56,
      color: _UIColors.white,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: _UIColors.black_222222, fontSize: 16),
            ),
          ),
          ValueListenableBuilder<bool>(
              valueListenable: valueNotifier,
              builder: (context, value, child) {
                return CupertinoSwitch(
                    key: key,
                    value: value,
                    onChanged: (newValue) => onChanged.call(newValue),
                    activeColor: _UIColors.blue_337eff);
              }),
        ],
      ),
    );
  }

  Widget _buildSplit() {
    return Container(
      color: _UIColors.globalBg,
      padding: EdgeInsets.only(left: 20),
      child: Divider(height: 0.5),
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

  /// 开关会议水印
  void _updateWatermarkState(bool watermark) {
    doIfNetworkAvailable(() {
      lifecycleExecute(_roomContext.enableConfidentialWatermark(watermark))
          .then((result) {
        if (!mounted) return;
      });
    });
  }
}

mixin MeetingKitLocalizationsMixin<T extends StatefulWidget> on State<T> {
  late NEMeetingUIKitLocalizations meetingUiLocalizations;
  late NEMeetingKitLocalizations meetingKitLocalizations;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    meetingUiLocalizations = NEMeetingUIKitLocalizations.of(context)!;
    meetingKitLocalizations = NEMeetingKitLocalizations.of(context)!;
  }
}
