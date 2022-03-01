// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:core';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:yunxin_event_track/yunxin_event_track.dart';
import 'package:yunxin_meeting/meeting_sdk.dart';
import 'package:nemeeting/utils/const_config.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:service/auth/auth_manager.dart';
import 'package:service/client/http_code.dart';
import 'package:service/config/app_config.dart';
import 'package:service/event/track_app_event.dart';
import 'package:uikit/utils/nav_utils.dart';
import 'package:uikit/utils/router_name.dart';
import 'package:uikit/values/dimem.dart';
import 'package:uikit/values/fonts.dart';
import 'package:uikit/values/strings.dart';
import 'package:uikit/values/colors.dart';
import 'package:base/util/textutil.dart';
import 'package:yunxin_meeting/meeting_uikit.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:uikit/const/consts.dart';

class MeetCreateRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeetCreateRouteState();
  }
}

class _MeetCreateRouteState extends LifecycleBaseState<MeetCreateRoute> {
  bool userSelfMeetingId = false;

  bool openCamera = true;

  bool openMicrophone = true;

  bool openRecord = !noCloudRecord;

  bool showMeetingRecord = false;

  bool showMeetingTime = true;

  bool meetingPwdSwitch = false;

  final _meetingPasswordController = TextEditingController();

  var _createEnable = true;

  @override
  void initState() {
    super.initState();
    AppConfig().init();
    var settingsService = NEMeetingSDK.instance.getSettingsService();
    Future.wait([
      settingsService.isTurnOnMyVideoWhenJoinMeetingEnabled(),
      settingsService.isTurnOnMyAudioWhenJoinMeetingEnabled(),
      settingsService.isShowMyMeetingElapseTimeEnabled(),
      settingsService.isMeetingCloudRecordEnabled(),
    ]).then((values) {
      setState(() {
        openCamera = values[0];
        openMicrophone = values[1];
        showMeetingTime = values[2];
        // showMeetingRecord = values[3];
      });
    });
  }

  @override
  void dispose() { 
    _meetingPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.globalBg,
        appBar: AppBar(
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(
                    IconFont.iconyx_returnx,
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
            title: Text(Strings.createMeeting,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.black_222222, fontSize: 17))),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 10),
            buildUseSelfMeetingItem(),
            if (!TextUtil.isEmpty(MeetingUtil.getShortMeetingId()))
              ...buildShortMeetingIdItem(),
            ...buildMeetingIdItem(),
            Container(
              color: AppColors.globalBg,
              height: Dimen.globalPadding,
            ),
            buildPwd(),
            if (meetingPwdSwitch) buildSplit(),
            if (meetingPwdSwitch) buildPwdInput(),
            Container(
              color: AppColors.globalBg,
              height: Dimen.globalPadding,
            ),
            buildCameraItem(),
            buildSplit(),
            buildMicrophoneItem(),
            if (showMeetingRecord) buildRecordItem(),
            buildCreate()
          ],
        ),
      ),
    );
  }

  Container buildSplit() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(left: 20),
      height: 1,
      child: Divider(height: 1),
    );
  }

  Container buildUseSelfMeetingItem() {
    return Container(
      height: 56,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              Strings.usePersonalMeetId,
              style: TextStyle(color: AppColors.black_222222, fontSize: 17),
            ),
          ),
          MeetingValueKey.addTextWidgetTest(
              valueKey: MeetingValueKey.userSelfMeetingIdCreateMeeting, value: userSelfMeetingId),
          CupertinoSwitch(
              key: MeetingValueKey.userSelfMeetingIdCreateMeeting,
              value: userSelfMeetingId,
              onChanged: (bool value) {
                setState(() {
                  userSelfMeetingId = value;
                });
                EventTrack().trackEvent(ActionEvent.periodic(TrackAppEventName.usePersonalId,
                    module: AppModuleName.moduleName, extra: {'value': value ? 1 : 0}));
              },
              activeColor: AppColors.blue_337eff)
        ],
      ),
    );
  }

  List<Widget> buildShortMeetingIdItem() {
    return [
      buildSplit(),
      Container(
        height: 56,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            Text(
              Strings.personalShortMeetingId,
              style: TextStyle(fontSize: 16, color: AppColors.black_222222),
            ),
            Container(
              margin: EdgeInsets.only(left: 6),
              padding: EdgeInsets.only(left: 6, right: 6, bottom: 2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: AppColors.color_1a337eff,
                  border: Border.all(color: AppColors.color_33337eff)),
              child: Text(
                Strings.internalSpecial,
                style: TextStyle(fontSize: 12, color: AppColors.color_337eff),
              ),
            ),
            Spacer(),
            Text(
              MeetingUtil.getShortMeetingId(),
              style: TextStyle(fontSize: 14, color: AppColors.color_999999),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> buildMeetingIdItem() {
    return [
      buildSplit(),
      Container(
        height: 56,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            Text(
              Strings.personalMeetingId,
              style: TextStyle(fontSize: 16, color: AppColors.black_222222),
            ),
            Spacer(),
            Text(
              TextUtil.applyMask(MeetingUtil.getMeetingId(), '000-000-0000'),
              key: MeetingValueKey.personalMeetingId,
              style: TextStyle(fontSize: 14, color: AppColors.color_999999),
            ),
          ],
        ),
      ),
    ];
  }

  Widget buildPwd() {
    return Container(
      height: 56,
      color: AppColors.white,
      padding: EdgeInsets.only(left: 20, right: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              Strings.meetingPassword,
              style: TextStyle(color: AppColors.black_222222, fontSize: 16),
            ),
          ),
          MeetingValueKey.addTextWidgetTest(valueKey: MeetingValueKey.schedulePwdSwitch, value: meetingPwdSwitch),
          CupertinoSwitch(
              key: MeetingValueKey.schedulePwdSwitch,
              value: meetingPwdSwitch,
              onChanged: (bool value) {
                setState(() {
                  meetingPwdSwitch = value;
                  if (meetingPwdSwitch && TextUtil.isEmpty(_meetingPasswordController.text)) {
                    _meetingPasswordController.text =
                        (Random().nextInt(900000) + 100000).toString();
                  }
                  _createEnable = _updateCreateEnableState();
                });
              },
              activeColor: AppColors.blue_337eff)
        ],
      ),
    );
  }

  Widget buildPwdInput() {
    return Container(
      height: Dimen.primaryItemHeight,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
      alignment: Alignment.center,
      child: TextField(
        key: MeetingValueKey.schedulePwdInput,
        autofocus: false,
        keyboardAppearance: Brightness.light,
        controller: _meetingPasswordController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(meetingPasswordLengthMax),
          FilteringTextInputFormatter.allow(RegExp(r'\d+')),
        ],
        onChanged: (value) {
          setState(() {
            _createEnable = _updateCreateEnableState();
          });
        },
        decoration: InputDecoration(
            hintText: '${Strings.pleaseInputMeetingPasswordHint}',
            hintStyle: TextStyle(fontSize: 14, color: AppColors.color_999999),
            border: InputBorder.none,
            suffixIcon: TextUtil.isEmpty(_meetingPasswordController.text)
                ? null
                : ClearIconButton(
                    key: MeetingValueKey.clearInputMeetingPassword,
                    onPressed: () {
                      setState(() {
                        _meetingPasswordController.clear();
                        _createEnable = _updateCreateEnableState();
                      });
                    })),
        style: TextStyle(color: AppColors.color_222222, fontSize: 16),
      ),
    );
  }

  bool _updateCreateEnableState() {
    return !meetingPwdSwitch || _meetingPasswordController.text.length == 6;
  }

  Container buildCameraItem() {
    return Container(
      height: 56,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              Strings.openCameraEnterMeeting,
              style: TextStyle(color: AppColors.black_222222, fontSize: 16),
            ),
          ),
          MeetingValueKey.addTextWidgetTest(valueKey: MeetingValueKey.openCameraCreateMeeting, value: openCamera),
          CupertinoSwitch(
              key: MeetingValueKey.openCameraCreateMeeting,
              value: openCamera,
              onChanged: (bool value) {
                setState(() {
                  openCamera = value;
                });
                EventTrack().trackEvent(ActionEvent.periodic(TrackAppEventName.openCamera,
                    module: AppModuleName.moduleName, extra: {'value': openCamera ? 1 : 0}));
              },
              activeColor: AppColors.blue_337eff)
        ],
      ),
    );
  }

  Container buildRecordItem() {
    return Container(
      height: 56,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              Strings.openRecordEnterMeeting,
              style: TextStyle(color: AppColors.black_222222, fontSize: 16),
            ),
          ),
          MeetingValueKey.addTextWidgetTest(
              valueKey: MeetingValueKey.openRecordEnterMeeting,
              value: openRecord),
          CupertinoSwitch(
              key: MeetingValueKey.openRecordEnterMeeting,
              value: openRecord,
              onChanged: (bool value) {
                setState(() {
                  openRecord = value;
                });
                EventTrack().trackEvent(ActionEvent.periodic(
                    TrackAppEventName.openRecord,
                    module: AppModuleName.moduleName,
                    extra: {'value': openRecord ? 1 : 0}));
              },
              activeColor: AppColors.blue_337eff)
        ],
      ),
    );
  }

  Container buildMicrophoneItem() {
    return Container(
      height: 56,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              Strings.openMicroEnterMeeting,
              style: TextStyle(color: AppColors.black_222222, fontSize: 16),
            ),
          ),
          MeetingValueKey.addTextWidgetTest(
              valueKey: MeetingValueKey.openMicrophoneCreateMeeting, value: openMicrophone),
          CupertinoSwitch(
              key: MeetingValueKey.openMicrophoneCreateMeeting,
              value: openMicrophone,
              onChanged: (bool value) {
                setState(() {
                  openMicrophone = value;
                });
                EventTrack().trackEvent(ActionEvent.periodic(TrackAppEventName.openMicro,
                    module: AppModuleName.moduleName, extra: {'value': openMicrophone ? 1 : 0}));
              },
              activeColor: AppColors.blue_337eff)
        ],
      ),
    );
  }

  Container buildCreate() {
    return Container(
      padding: EdgeInsets.all(30),
      child: ElevatedButton(
        key: MeetingValueKey.createMeetingBtn,
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.disabled)) {
                return AppColors.blue_50_337eff;
              }
              return AppColors.blue_337eff;
            }),
            padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 13)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                side: BorderSide(color: AppColors.blue_337eff, width: 0),
                borderRadius: BorderRadius.all(Radius.circular(25))))),
        onPressed: _createEnable ? createMeeting : null,
        child: Text(
          Strings.createMeeting,
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> createMeeting() async {
    var historyItem  = await NEMeetingSDK.instance.getSettingsService().getHistoryMeetingItem();
    String? lastUsedNickname;
    if (historyItem != null &&
        historyItem.isNotEmpty &&
        (historyItem.first.meetingId ==
                (userSelfMeetingId ? MeetingUtil.getMeetingId() : '') ||
            historyItem.first.shortMeetingId ==
                (userSelfMeetingId ? MeetingUtil.getShortMeetingId() : ''))) {
      lastUsedNickname = historyItem.first.nickname;
    }
    onCreateMeeting(nickname: lastUsedNickname);
  }

  void onCreateMeeting({String? nickname}) {
    final useSelfId = userSelfMeetingId;
    final openCamera = this.openCamera;
    final openMicrophone = this.openMicrophone;

    var meetingId = useSelfId ? MeetingUtil.getMeetingId() : '';
    LoadingUtil.showLoading();
    NEMeetingSDK.instance.getMeetingService().startMeeting(
        context,
        NEStartMeetingParams(
          meetingId: meetingId,
          password: meetingPwdSwitch ? _meetingPasswordController.text : null,
          displayName: nickname ?? MeetingUtil.getNickName(),
        ),
        NEStartMeetingOptions(
            noVideo: !openCamera,
            noAudio: !openMicrophone,
            noWhiteBoard: !openWhiteBoard,
            showMeetingTime: showMeetingTime,
            noRecord: !openRecord,
            restorePreferredOrientations: [DeviceOrientation.portraitUp]), ({required errorCode, errorMessage, result}) {
      LoadingUtil.cancelLoading();
      if (errorCode == NEMeetingErrorCode.success) {
        NavUtils.pop(context);
      } else if (errorCode == NEMeetingErrorCode.meetingAlreadyExist && useSelfId) {
        switchToJoin(
            context,
            NEJoinMeetingParams(meetingId: meetingId, displayName: nickname ?? MeetingUtil.getNickName()),
            NEJoinMeetingOptions(
                noVideo: !openCamera,
                noAudio: !openMicrophone,
                noWhiteBoard: !openWhiteBoard,
                showMeetingTime: showMeetingTime,
                restorePreferredOrientations: [DeviceOrientation.portraitUp]), ({required errorCode, errorMessage, result}) {
          if (errorCode == NEMeetingErrorCode.success) {
            NavUtils.pop(context);
          } else {
            var errorTips = HttpCode.getMsg(errorMessage, Strings.joinMeetingFail);
            ToastUtils.showToast(context, errorTips);
          }
        });
      } else if (errorCode == NEMeetingErrorCode.noNetwork) {
        ToastUtils.showToast(context, Strings.networkUnavailableCheck);
      } else if (errorCode == NEMeetingErrorCode.noAuth) {
        ToastUtils.showToast(context, Strings.noAuth);
        AuthManager().logout();
        NavUtils.pushNamedAndRemoveUntil(context, RouterName.entrance);
      } else if (errorCode == NEMeetingErrorCode.alreadyInMeeting) {
        //不作处理
      } else {
        var errorTips = HttpCode.getMsg(errorMessage, Strings.createMeetingFail);
        ToastUtils.showToast(context, errorTips);
      }
    });
  }

  void switchToJoin(
      BuildContext context, NEJoinMeetingParams param, NEJoinMeetingOptions opts, NECompleteListener listener) {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return CupertinoAlertDialog(
            content: Text(Strings.createAlreadyInMeetingTip),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(Strings.no),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text(Strings.yes),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  NEMeetingSDK.instance.getMeetingService().joinMeeting(context, param, opts, listener);
                },
              ),
            ],
          );
        });
  }
}
