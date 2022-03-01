// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

/// 遥控器首页
class ControlHomePage extends StatefulWidget {
  final ControlArguments arguments;

  ControlHomePage(this.arguments);

  @override
  State<StatefulWidget> createState() {
    return _ControlHomePageState(arguments);
  }
}

class _ControlHomePageState extends ControlBaseState<ControlHomePage> {
  static const _tag = 'ControlHomePage';
  StreamSubscription<MeetingAction>? subscription;
  static const int unbindAction = 1;
  static const int unbindActionForce = 2;
  static const int requestIdUpgradeForce = 1;

  EventCallback? _eventCallback;
  final ControlArguments controlArguments;
  String? _tvNickname;

  _ControlHomePageState(this.controlArguments);

  @override
  void initState() {
    super.initState();
    registerTVControlListener();
    ControlInMeetingRepository.bindTV(SyncControlAccountData(
      UserProfile.accountId!,
      controlArguments.pairCode!,
      DeviceInfo.deviceId,
      ControlProfile.nickName!,
      TCProtocol.controllerProtocolVersion,
    )).then((value) {
      Alog.d(tag: _tag,moduleName: _moduleName, content: 'value ===== $value');
    });

    _eventCallback = (arg) {
      showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(_Strings.notify),
              content: Text(_Strings.hostCloseMeeting),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(_Strings.sure),
                  onPressed: () {
                    UINavUtils.pop(context);
                  },
                )
              ],
            );
          });
    };
    EventBus().subscribe(_EventName.meetingClose, _eventCallback!);
  }

  @override
  Widget buildBody() {
    return Container(
      color: UIColors.globalBg,
      child: Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: UIColors.white,
          boxShadow: [
            BoxShadow(
              color: UIColors.color_19242744,
              offset: Offset(0, 4),
              blurRadius: 8,
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
        child: Column(
          children: [
            Container(
              height: 44,
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.only(top: 6),
                child: Text(
                  TextUtils.isEmpty(ControlProfile.controlName)
                      ? '${_Strings.tvControlTitle}'
                      : '${ControlProfile.controlName}${_Strings.tvControlTitleSuffix}',
                  style: TextStyle(fontSize: 14, color: UIColors.black_333333),
                ),
              ),
            ),
            Divider(
              thickness: 1,
              color: UIColors.globalBg,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildMeetBtns(),
                  buildDisconnectBtn(),
                ],
              ),
            ),
            if (TextUtils.isNotEmpty(controlArguments.tvStatus?.tvNick)) buildNickWidget(),
          ],
        ),
      ),
    );
  }

  @override
  String getTitle() {
    return _Strings.tvControl;
  }

  String getNickLeading() {
    if (TextUtils.isEmpty(_tvNickname)) {
      return '';
    }
    return _tvNickname!.substring(0, 1);
  }

  Widget buildMeetBtns() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            child: Column(
              children: [
                Image.asset(
                  NEMeetingImages.controlCreateMeeting,
                  package: NEMeetingImages.package,
                  fit: BoxFit.none,
                ),
                Text(
                  _Strings.createMeeting,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: UIColors.primaryText,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            onTap: () => _NavUtils.toControlMeetCreatePage(context, controlArguments),
          ),
          Container(
            margin: EdgeInsets.only(left: 41),
            child: GestureDetector(
              child: Column(
                children: <Widget>[
                  Image.asset(
                    NEMeetingImages.controlJoinMeeting,
                    package: NEMeetingImages.package,
                    fit: BoxFit.none,
                  ),
                  Text(
                    _Strings.joinMeeting,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: UIColors.primaryText,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              onTap: () => _NavUtils.toControlMeetJoinPage(context, controlArguments),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDisconnectBtn() {
    return GestureDetector(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Image.asset(
              NEMeetingImages.controlDisconnectMeeting,
              package: NEMeetingImages.package,
              fit: BoxFit.none,
            ),
          ),
          Text(
            _Strings.disconnect,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: UIColors.primaryText,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ],
      ),
      onTap: () {
        _disconnect();
      },
    );
  }

  @override
  List<Widget>? buildActions() {
    final settingMenu = controlArguments.opts?.settingMenu;
    final settingMenuTitle = settingMenu?.title;
    if (TextUtils.isEmpty(settingMenuTitle)) {
      return null;
    } else {
      return <Widget>[
        TextButton(
          child: Text(
            settingMenuTitle!,
            style: TextStyle(
              color: UIColors.color_222222,
              fontSize: 15.0,
            ),
          ),
          onPressed: () {
            MeetingControl().notifySettingClick(settingMenu!);
          },
        )
      ];
    }
  }

  @override
  bool onWillPop() {
    showExitDialog(_Strings.backConfirmDisconnect);
    return false;
  }

  void _disconnect() {
    showExitDialog(_Strings.confirmDisconnect);
  }

  void showExitDialog(String tip) {
    DialogUtils.showCommonDialog(context, _Strings.disconnect, tip, () {
      UINavUtils.pop(context);
    }, () {
      ControlInMeetingRepository.disconnectTV().then((result) {
        if (result.code == ControlCode.success) {
          _unregisterListener();
          Navigator.of(context).popUntil((route) => false);
        } else if (result.code == RoomErrorCode.networkError) {
          ToastUtils.showToast(context, _Strings.networkUnavailable);
        }
      });
    });
  }

  void registerTVControlListener() {
    var stream = ControlInMeetingRepository.controlMessageStream();
    subscription = stream.listen((MeetingAction action) {
      var isVisible = ModalRoute.of(context)?.isCurrent ?? false;
      if (action.type == TCProtocol.bindResult2Controller && action is TCBindTVResultAction) {
        if (errorCodeUpgrading == action.code) {
          ToastUtils.showToast(context, _Strings.errorTVUpgrading);
          Alog.d(tag: _tag,moduleName: _moduleName,content:  'tv is upgrading');
          UINavUtils.pushNamedAndRemoveUntil(context, _PageName.controlPair, utilRouteName: _PageName.homePage);
          return;
        }

        if (errorCodeCannotMatchTv == action.code) {
          ToastUtils.showToast(context, _Strings.errorTVCannotMatch);
          Alog.d(tag: _tag,moduleName: _moduleName,content:  'tv can not match');
          UINavUtils.pushNamedAndRemoveUntil(context, _PageName.controlPair, utilRouteName: _PageName.homePage);
          return;
        }

        controlArguments.tvStatus = action.tvStatus;
        Alog.d(tag: _tag,moduleName: _moduleName,content:'bindTVResult result isVisible = $isVisible, tvStatus = ${controlArguments.tvStatus?.toString()}');

        ///这个里面的逻辑只有页面可见才触发
        if (isVisible) {
          if (controlArguments.tvStatus?.status != StatusType.init) {
            var meetingInfo = ControlJoinMeetingInfo(
              avRoomUid: action.tvStatus.avRoomUid,
              meetingId: action.tvStatus.meetingId!,
            );

            controlArguments.fromRoute = _PageName.controlHome;
            _NavUtils.toControlMeetingPage(context, ControlMeetingArguments(
                meetingInfo: meetingInfo,
                options: ControllerMeetingOptions(restorePreferredOrientations: [DeviceOrientation.portraitUp],
                    injectedToolbarMenuItems: controlArguments.opts?.injectedToolbarMenuItems,
                    injectedMoreMenuItems: controlArguments.opts?.injectedMoreMenuItems,
                    audioMute: action.tvStatus.muteAudio != AVState.open,
                    videoMute: action.tvStatus.muteVideo != AVState.open),
                pairId: controlArguments.pairCode,
                fromRoute: _PageName.controlHome,
                tvStatus: action.tvStatus));
          }
        }

        _tvNickname = action.tvStatus.tvNick;
        setState(() {});
      }

      if (isVisible) {
        if (action is TCCheckUpdateResultAction && action.requestId == requestIdUpgradeForce) {
          var hasNewVersion = action.hasNewVersion;
          if (hasNewVersion) {
            DialogUtils.showCommonDialog(context, _Strings.tvUpdate, _Strings.findNewVersionContent, () {
              UINavUtils.pushNamedAndRemoveUntil(context, _PageName.controlPair, utilRouteName: _PageName.homePage);
              ControlInMeetingRepository.disconnectTV();
            }, () {
              ControlInMeetingRepository.notifyTVUpdate(ControlProfile.pairedAccountId);
              UINavUtils.pop(context);
              DialogUtils.showOneButtonCommonDialog(context, _Strings.tvUpdate, _Strings.waitTvUpdate, () {
                UINavUtils.pushNamedAndRemoveUntil(context, _PageName.controlPair, utilRouteName: _PageName.homePage);
              }, canBack: false);
            }, cancelText: _Strings.cancel, acceptText: _Strings.update, canBack: false);
          }
        }
      }

      ///遥控器被踢下线要全局监听
      if (action.type == TCProtocol.unbind2Controller) {
        var actionType = (action as TCUnBindResultAction).action;
        if (actionType == unbindAction) {
          Navigator.of(context).popUntil((route) => false);
          MeetingControl().notifyUnbind(UnbindType.tvUnbind);
        } else if (actionType == unbindActionForce &&
            DeviceInfo.deviceId != action.controllerDeviceId) {
          Navigator.of(context).popUntil((route) => false);
          MeetingControl().notifyUnbind(UnbindType.forceUnbind);
        }
      } else if (action.type == TCProtocol.feedback2Controller) {
        // FeedbackSDK.feedback(
        //     context,
        //     'Controller',
        //     (action as TVFeedbackAction)?.meetingId,
        //     (action as TVFeedbackAction)?.channelId,
        //     (action as TVFeedbackAction)?.deviceId,
        //     (action as TVFeedbackAction)?.category,
        //     (action as TVFeedbackAction)?.des);
      }
    });
  }

  Widget buildNickWidget() {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
                child: Container(
                  height: 16,
                  width: 16,
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[UIColors.blue_5996FF, UIColors.blue_2575FF],
                      ),
                      shape: Border()),
                  alignment: Alignment.center,
                  child: Text(
                    getNickLeading(),
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                )),
            Container(
              margin: EdgeInsets.only(left: 2),
              child: Text(
                _tvNickname ?? '',
                style: TextStyle(fontSize: 14, color: UIColors.black_333333),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        _NavUtils.toControlNickSettingPage(context, controlArguments).then((value) {
          if (TextUtils.isNotEmpty(value as String?)) {
            _tvNickname = value;
          }
          setState(() {});
        });
      },
    );
  }


  @override
  void dispose() {
    _unregisterListener();
    EventBus().unsubscribe(_EventName.meetingClose, _eventCallback);
    EventBus().emit(UIEventName.flutterEngineCanRecycle);
    super.dispose();
  }

  void _unregisterListener() {
    subscription?.cancel();
    Alog.d(tag: _tag,moduleName: _moduleName,content:  'subscription is canceled');
  }
}
