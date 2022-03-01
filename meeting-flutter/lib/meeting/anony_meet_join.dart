// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:yunxin_base/yunxin_base.dart';
import 'package:base/util/error.dart';
import 'package:base/util/textutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:yunxin_event_track/yunxin_event_track.dart';
import 'package:yunxin_meeting/meeting_sdk.dart';
import 'package:yunxin_meeting/meeting_sdk_interface.dart';
import 'package:nemeeting/utils/const_config.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:nemeeting/widget/length_text_input_formatter.dart';
import 'package:service/auth/auth_manager.dart';
import 'package:service/client/http_code.dart';
import 'package:service/config/app_config.dart';
import 'package:service/event/track_app_event.dart';
import 'package:service/event_name.dart';
import 'package:service/profile/app_profile.dart';
import 'package:uikit/utils/nav_utils.dart';
import 'package:uikit/values/borders.dart';
import 'package:uikit/values/colors.dart';
import 'package:uikit/values/strings.dart';
import 'package:uikit/values/styles.dart';
import 'package:base/util/global_preferences.dart';
import 'package:uikit/const/consts.dart';
import 'package:yunxin_meeting/meeting_uikit.dart';
import 'package:yunxin_meeting/meeting_plugin.dart';
import 'package:yunxin_meeting_assets/yunxin_meeting_assets.dart';
import 'package:service/values/app_constants.dart';

class AnonyMeetJoinRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeetJoinRouteState();
  }
}

class _MeetJoinRouteState extends LifecycleBaseState<AnonyMeetJoinRoute> {
  bool openCamera = true;
  bool openMicrophone = true;
  late TextEditingController _meetingIdController;
  late TextEditingController _nickController;
  String? _errorNickTip;
  bool _checkMeetingIdOk = false;
  bool _checkNickOk = false;
  final FocusNode _focusNode =  FocusNode();

  late EventCallback _eventCallback;
  late NERoomStatusListener _meetingStatusListener;
  bool meetingSDKInitialed = false;

  final TapGestureRecognizer _tapPrivacy = TapGestureRecognizer();

  final TapGestureRecognizer _tapUserProtocol = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();
    var meetingId = AppProfile.deepLinkMeetingId;
    AppProfile.deepLinkMeetingId = null;
    _meetingIdController =  TextEditingController(text: meetingId);
    _nickController =  TextEditingController();
    checkMeetId();
    initWidget();
    _focusNode.addListener(() {
      setState(() {
        checkNick();
      });
    });
    _eventCallback = (arg) {
      showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(Strings.notify),
              content: Text(Strings.hostCloseMeeting),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(Strings.sure),
                  onPressed: () {
                    NavUtils.pop(context);
                  },
                )
              ],
            );
          });
    };
    EventBus().subscribe(EventName.meetingClose, _eventCallback);

    initNEMeetingSDK(({required errorCode, errorMessage, result}) {
      if (errorCode == NEMeetingErrorCode.success) {
        registerMeetingStatusListener();
        meetingSDKInitialed = true;
      }
    });
  }

  void initNEMeetingSDK(NECompleteListener function) {
    if (meetingSDKInitialed) {
      return;
    }
    var config = NEForegroundServiceConfig();
    config
      ..contentTitle = Strings.appName
      ..contentText = Strings.foregroundContentText
      ..channelName = Strings.appName
      ..channelDesc = Strings.appName;
    NEMeetingSDK.instance.initialize(
        NEMeetingSDKConfig(
            appKey: AppConfig().getAppKey,
            appName: Strings.appName,
            iosBroadcastAppGroup: iosBroadcastExtensionAppGroup,
            config: config),
        function);
  }

  void registerMeetingStatusListener() {
    _meetingStatusListener = (status) {
      if (status.event == NEMeetingEvent.disconnecting) {
        if (status.arg == NEMeetingCode.closeByHost) {
          showCupertinoDialog(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: Text(Strings.notify),
                  content: Text(Strings.hostCloseMeeting),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text(Strings.sure),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
        }
      }
    };
    NEMeetingSDK.instance.getMeetingService().addListener(_meetingStatusListener);
  }

  void initWidget() {
    GlobalPreferences().anonyMicrophoneOpen.then((value) => setState(() {
          openMicrophone = value ?? false;
        }));

    GlobalPreferences().anonyCameraOpen.then((value) => setState(() {
          openCamera = value ?? false;
        }));

    GlobalPreferences().anonyNick.then((value) {
      if (!TextUtil.isEmpty(value)) {
        _nickController.text = value!;
      }
      setState(() {
        checkNick();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        appBar: buildAppBar(),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 16),
              buildJoinTitle(),
              buildMeetingIdInput(),
              _buildMeetingNickInput(),
              SizedBox(
                height: 12,
              ),
              buildCameraItem(),
              buildMicrophoneItem(),
              buildJoin(),
            ],
          ),
        ));
  }

  AppBar buildAppBar() {
    return AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                NEMeetingIconFont.icon_yx_returnx,
                size: 18,
                color: AppColors.black_333333,
              ),
              onPressed: () {
                Navigator.maybePop(context);
              },
            );
          },
        ),
        brightness: Brightness.light,
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(''));
  }

  TextStyle buildTextStyle(Color color) {
    return TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w400, decoration: TextDecoration.none);
  }

  Container buildJoinTitle() {
    return Container(
      padding: EdgeInsets.only(left: 30),
      child: Text(
        Strings.joinMeeting,
        style: TextStyle(fontSize: 28, color: AppColors.black_222222, fontWeight: FontWeight.w500),
      ),
    );
  }

  Container buildMeetingIdInput() {
    return Container(
      padding: EdgeInsets.only(left: 30, right: 30, top: 24),
      child: Theme(
        data: ThemeData(hintColor: AppColors.greyDCDFE5),
        child: TextField(
            key: MeetingValueKey.inputMeetingId,
            autofocus: true,
            style: TextStyle(color: AppColors.color_333333),
            inputFormatters: [
              LengthLimitingTextInputFormatter(meetIdLengthMax),
              FilteringTextInputFormatter.allow(RegExp(r'\d[-\d]*')),
            ],
            keyboardType: TextInputType.number,
            controller: _meetingIdController,
            keyboardAppearance: Brightness.light,
            textAlign: TextAlign.left,
            cursorColor: AppColors.blue_337eff,
            onChanged: (value) {
              setState(() {
                checkMeetId();
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              focusColor: AppColors.blue_337eff,
              contentPadding: EdgeInsets.only(top: 11, bottom: 11),
              hintText: Strings.inputMeetingId,
              hintStyle: TextStyle(fontSize: 17, color: AppColors.greyB0B6BE),
              focusedBorder: UnderlineInputBorder(borderSide: Borders.textFieldBorder),
              suffixIcon: TextUtil.isEmpty(_meetingIdController.text) || _focusNode.hasFocus
                  ? null
                  : ClearIconButton(
                      key: MeetingValueKey.clearAnonyMeetIdInput,
                      onPressed: () {
                        _meetingIdController.clear();
                        setState(() {
                          checkMeetId();
                        });
                      },
                    ),
            )),
      ),
    );
  }

  Container _buildMeetingNickInput() {
    return Container(
        padding: EdgeInsets.only(left: 30, right: 30, top: 0),
        margin: EdgeInsets.only(top: 24),
        decoration: BoxDecoration(
          color: AppColors.primaryElement,
        ),
        child: Theme(
          data: ThemeData(hintColor: AppColors.greyDCDFE5, focusColor: AppColors.blue_337eff),
          child: TextField(
            key: MeetingValueKey.hintNick,
            focusNode: _focusNode,
            controller: _nickController,
            style: TextStyle(color: AppColors.color_333333),
            cursorColor: AppColors.blue_337eff,
            keyboardAppearance: Brightness.light,
            inputFormatters: [
              MeetingLengthLimitingTextInputFormatter(nickLengthMax),
            ],
            onChanged: (value) {
              setState(() {
                checkNick();
              });
            },
            decoration: InputDecoration(
              hintText: Strings.hintNick,
              hintStyle: Styles.hintTextStyle,
              focusedBorder: UnderlineInputBorder(borderSide: Borders.textFieldBorder),
              errorText: _errorNickTip,
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: Borders.textFieldBorder,
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: Borders.textFieldBorder,
              ),
              errorStyle: Styles.errorTextStyle,
              suffixIcon: TextUtil.isEmpty(_nickController.text) || !_focusNode.hasFocus
                  ? null
                  :  ClearIconButton(
                      key: MeetingValueKey.clearAnonyNickInput,
                      onPressed: () {
                        _nickController.clear();
                        setState(() {
                          checkNick();
                        });
                      },
                    )),
          ),
        ));
  }

  Container buildCameraItem() {
    return Container(
      height: 56,
      color: Colors.white,
      padding: EdgeInsets.only(left: 30, right: 24),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              Strings.openCameraEnterMeeting,
              style: TextStyle(color: AppColors.black_222222, fontSize: 14),
            ),
          ),
          MeetingValueKey.addTextWidgetTest(valueKey:MeetingValueKey.openCameraEnterMeeting,value: openCamera),
          CupertinoSwitch(
            key: MeetingValueKey.openCameraEnterMeeting,
            value: openCamera,
            onChanged: (bool value) {
              setState(() {
                openCamera = value;
                GlobalPreferences().setAnonyCameraOpen(openCamera);
              });
              EventTrack().trackEvent(ActionEvent.periodic(TrackAppEventName.openCamera,
                  module: AppModuleName.moduleName, extra: {'value': openCamera ? 1 : 0}));
            },
            activeColor: AppColors.blue_337eff,
          )
        ],
      ),
    );
  }

  Container buildMicrophoneItem() {
    return Container(
      height: 56,
      color: Colors.white,
      padding: EdgeInsets.only(left: 30, right: 24),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              Strings.openMicroEnterMeeting,
              style: TextStyle(color: AppColors.black_222222, fontSize: 14),
            ),
          ),
          MeetingValueKey.addTextWidgetTest(valueKey:MeetingValueKey.openMicroEnterMeeting,value: openMicrophone),
          CupertinoSwitch(
              key: MeetingValueKey.openMicroEnterMeeting,
              value: openMicrophone,
              onChanged: (bool value) {
                setState(() {
                  openMicrophone = value;
                  GlobalPreferences().setAnonyMicrophoneOpen(openMicrophone);
                });
                EventTrack().trackEvent(ActionEvent.periodic(TrackAppEventName.openMicro,
                    module: AppModuleName.moduleName, extra: {'value': openMicrophone ? 1 : 0}));
              },
              activeColor: AppColors.blue_337eff)
        ],
      ),
    );
  }

  Container buildJoin() {
    return Container(
      padding: EdgeInsets.only(top: 30, right: 30, left: 30),
      child: ElevatedButton(
        key: MeetingValueKey.anonymousMeetJoin,
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.disabled)) {
                return AppColors.blue_50_337eff;
              }
              return AppColors.blue_337eff;
            }),
            padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 13)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                side: BorderSide(
                    color: _checkMeetingIdOk && _checkNickOk ? AppColors.blue_337eff : AppColors.blue_50_337eff,
                    width: 0),
                borderRadius: BorderRadius.all(Radius.circular(25))))),
        onPressed: _checkMeetingIdOk && _checkNickOk ? _onJoinMeeting : null,
        child: Text(
          Strings.joinMeeting,
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// may be show loading state
  void _onJoinMeeting() {
    AuthManager().logout();
    var meetingId =
        TextUtil.replace(_meetingIdController.text, RegExp(r'-'), '');
    var nick = _nickController.text.trim();
    LoadingUtil.showLoading();
    if (meetingSDKInitialed) {
      _joinMeetingByMeetingSDK(meetingId, nick);
    } else {
      initNEMeetingSDK(({required errorCode, errorMessage, result}) {
        if (errorCode == NEMeetingErrorCode.success) {
          _joinMeetingByMeetingSDK(meetingId, nick);
        } else {
          LoadingUtil.cancelLoading();
        }
      });
    }
  }

  void _joinMeetingByMeetingSDK(String meetingId, String nick) {
    NEMeetingSDK.instance.getMeetingService().joinMeeting(
        context,
        NEJoinMeetingParams(meetingId: meetingId, displayName: nick),
        NEJoinMeetingOptions(
            noVideo: !openCamera,
            noAudio: !openMicrophone,
            noWhiteBoard: !openWhiteBoard,
            restorePreferredOrientations: [DeviceOrientation.portraitUp]),
        ({required errorCode, errorMessage, result}) {
      LoadingUtil.cancelLoading();
      if (errorCode == NEMeetingErrorCode.success) {
        GlobalPreferences().setAnonyNick(nick);
      } else if (errorCode == NEMeetingErrorCode.alreadyInMeeting
          || errorCode == NEMeetingErrorCode.cancelled
          || errorCode == NEMeetingErrorCode.meetingPasswordRequired) {
        //不作处理
      } else if (errorCode == NEMeetingErrorCode.noNetwork) {
        ErrorUtil.showError(context, Strings.networkUnavailableCheck);
      } else {
        var errorTips = HttpCode.getMsg(errorMessage, Strings.joinMeetingFail);
        ErrorUtil.showError(context, errorTips);
      }
    });
  }

  @override
  void dispose() {
    _meetingIdController.dispose();
    _nickController.dispose();
    _focusNode.dispose();
    _tapPrivacy.dispose();
    _tapUserProtocol.dispose();
    EventBus().unsubscribe(EventName.meetingClose, _eventCallback);
    AuthManager().logout();
    NEMeetingSDK.instance.getMeetingService().removeListener(_meetingStatusListener);
    super.dispose();
  }

  void checkMeetId() {
    _checkMeetingIdOk = _checkMeetId();
  }

  void checkNick() {
    _checkNickOk = _checkNick();
  }

  bool _checkMeetId() {
    var meetingId = _meetingIdController.text;
    return !TextUtil.isEmpty(meetingId) && meetingId.length >= meetIdLengthMin;
  }

  bool _checkNick() {
    var nameText = _nickController.text;
    var nickOk = isLetterOrDigitalOrZh(nameText) &&
        nameText.isNotEmpty &&
        nameText.length <= nickLengthMax;
    if (nickOk) {
      _errorNickTip = null;
    } else if (_focusNode.hasFocus) {
      _errorNickTip = Strings.validatorNickTip;
    }

    return nickOk;
  }

  static final _regexLetterOrDigitalOrZh = RegExp(r'^[0-9a-zA-Z\u4e00-\u9fa5]*$');
  static bool isLetterOrDigitalOrZh(String? input) {
    if (input == null || input.isEmpty) return false;
    return _regexLetterOrDigitalOrZh.hasMatch(input);
  }
}
