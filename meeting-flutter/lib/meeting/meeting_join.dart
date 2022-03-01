// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:yunxin_event_track/yunxin_event_track.dart';
import 'package:yunxin_meeting/meeting_sdk.dart';
import 'package:nemeeting/utils/const_config.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:service/event/track_app_event.dart';
import 'package:uikit/const/consts.dart';
import 'package:service/auth/auth_manager.dart';
import 'package:service/client/http_code.dart';
import 'package:service/profile/app_profile.dart';
import 'package:uikit/utils/nav_utils.dart';
import 'package:uikit/utils/router_name.dart';
import 'package:uikit/values/colors.dart';
import 'package:uikit/values/strings.dart';
import 'package:uikit/values/fonts.dart';
import 'package:base/util/textutil.dart';
import 'package:yunxin_meeting/meeting_uikit.dart';

class MeetJoinRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeetJoinRouteState();
  }
}

class _MeetJoinRouteState extends LifecycleBaseState<MeetJoinRoute> {
  bool openCamera = true;

  bool openMicrophone = true;

  bool showMeetingTime = true;

  final maxIdLength = 12;

  late TextEditingController _meetingIdController;

  bool joinEnable = false;

  @override
  void initState() {
    super.initState();
    var meetingId = AppProfile.deepLinkMeetingId;
    AppProfile.deepLinkMeetingId = null;
    _meetingIdController = TextEditingController(text: meetingId);
    _onMeetingIdChanged();

    var settingsService = NEMeetingSDK.instance.getSettingsService();
    Future.wait([
      settingsService.isTurnOnMyVideoWhenJoinMeetingEnabled(),
      settingsService.isTurnOnMyAudioWhenJoinMeetingEnabled(),
      settingsService.isShowMyMeetingElapseTimeEnabled(),
    ]).then((values) {
      setState(() {
        openCamera = values[0];
        openMicrophone = values[1];
        showMeetingTime = values[2];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(
                    IconFont.iconyx_returnx,
                    color: AppColors.black_333333,
                    size: 18,
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
            title: Text('')),
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
              SizedBox(
                height: 12,
              ),
              buildCameraItem(),
              buildMicrophoneItem(),
              buildJoin()
            ],
          ),
        ));
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
          autofocus: true,
          style: TextStyle(color: AppColors.color_333333, fontSize: 17),
          inputFormatters: [
            LengthLimitingTextInputFormatter(maxIdLength),
            FilteringTextInputFormatter.allow(RegExp(r'\d[-\d]*')),
          ],
          keyboardType: TextInputType.number,
          cursorColor: AppColors.blue_337eff,
          controller: _meetingIdController,
          textAlign: TextAlign.left,
          onChanged: (value) {
            _onMeetingIdChanged();
            setState(() {});
          },
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.only(top: 11, bottom: 11),
              hintText: Strings.inputMeetingId,
              hintStyle: TextStyle(fontSize: 17, color: AppColors.greyB0B6BE),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.color_337eff, width: 1, style: BorderStyle.solid),
              ),
              suffixIcon: TextUtil.isEmpty(_meetingIdController.text)
                  ? null
                  : ClearIconButton(
                      onPressed: () {
                        _meetingIdController.clear();
                        _onMeetingIdChanged();
                        setState(() {});
                      },
                    )),
        ),
      ),
    );
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
          MeetingValueKey.addTextWidgetTest(valueKey: MeetingValueKey.openCameraJoinMeeting, value: openCamera),
          CupertinoSwitch(
            key: MeetingValueKey.openCameraJoinMeeting,
            value: openCamera,
            onChanged: (bool value) {
              setState(() {
                openCamera = value;
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
          MeetingValueKey.addTextWidgetTest(valueKey: MeetingValueKey.openMicrophoneJoinMeeting, value: openMicrophone),
          CupertinoSwitch(
              key: MeetingValueKey.openMicrophoneJoinMeeting,
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

  Container buildJoin() {
    return Container(
      padding: EdgeInsets.all(30),
      child: ElevatedButton(
        key: MeetingValueKey.joinMeetingBtn,
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.disabled)) {
                return AppColors.blue_50_337eff;
              }
              return AppColors.blue_337eff;
            }),
            padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 13)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                side: BorderSide(color: joinEnable ? AppColors.blue_337eff : AppColors.blue_50_337eff, width: 0),
                borderRadius: BorderRadius.all(Radius.circular(25))))),
        onPressed: joinEnable ? joinMeeting : null,
        child: Text(
          Strings.joinMeeting,
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> joinMeeting() async {
    var historyItem = await NEMeetingSDK.instance
        .getSettingsService()
        .getHistoryMeetingItem();
    String? lastUsedNickname;

    if (historyItem != null &&
        historyItem.isNotEmpty &&
        (historyItem.first.meetingId == targetMeetingID ||
            historyItem.first.shortMeetingId == targetMeetingID)) {
      lastUsedNickname = historyItem.first.nickname;
    }
    _onJoinMeeting(nickname: lastUsedNickname);
  }

  String get targetMeetingID => TextUtil.replace(_meetingIdController.text, RegExp(r'-'), '');

  void _onJoinMeeting({String? nickname}) {
    LoadingUtil.showLoading();
    NEMeetingSDK.instance.getMeetingService().joinMeeting(
        context,
        NEJoinMeetingParams(meetingId: targetMeetingID, displayName: nickname ?? MeetingUtil.getNickName()),
        NEJoinMeetingOptions(
            noVideo: !openCamera,
            noAudio: !openMicrophone,
            noWhiteBoard: !openWhiteBoard,
            showMeetingTime: showMeetingTime,
            restorePreferredOrientations: [DeviceOrientation.portraitUp]), ({required errorCode, errorMessage, result}) {
      LoadingUtil.cancelLoading();
      if (errorCode == NEMeetingErrorCode.success) {
        // Navigator.of(context).removeRoute(ModalRoute.of(context));
        NavUtils.pop(context);
      } else if (errorCode == NEMeetingErrorCode.noNetwork) {
        ToastUtils.showToast(context, Strings.networkUnavailableCheck);
      } else if (errorCode == NEMeetingErrorCode.noAuth) {
        ToastUtils.showToast(context, Strings.loginOnOtherDevice);
        AuthManager().logout();
        NavUtils.pushNamedAndRemoveUntil(context, RouterName.entrance);
      } else if (errorCode == NEMeetingErrorCode.alreadyInMeeting ||
          errorCode == NEMeetingErrorCode.cancelled ||
          errorCode == NEMeetingErrorCode.meetingPasswordRequired) {
        //不作处理
      } else {
        var errorTips = HttpCode.getMsg(errorMessage, Strings.joinMeetingFail);
        ToastUtils.showToast(context, errorTips);
      }
    });
  }

  void _onMeetingIdChanged() {
    var meetingId = _meetingIdController.text;
    joinEnable = meetingId.length >= meetIdLengthMin;
  }

  @override
  void dispose() {
    _meetingIdController.dispose();
    super.dispose();
  }
}
