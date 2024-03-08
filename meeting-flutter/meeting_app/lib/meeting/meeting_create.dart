// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:core';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/language/localizations.dart';
import 'package:nemeeting/routes/home_page.dart';
import 'package:nemeeting/utils/const_config.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/config/app_config.dart';
import '../uikit/utils/nav_utils.dart';
import '../uikit/utils/router_name.dart';
import '../uikit/values/dimem.dart';
import '../uikit/values/fonts.dart';
import '../uikit/values/colors.dart';
import 'package:nemeeting/base/util/text_util.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import 'package:nemeeting/utils/integration_test.dart';
import '../uikit/const/consts.dart';

class MeetCreateRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeetCreateRouteState();
  }
}

class _MeetCreateRouteState extends LifecycleBaseState<MeetCreateRoute>
    with MeetingAppLocalizationsMixin {
  bool userSelfMeetingNum = false;

  bool openCamera = true;

  bool openMicrophone = true;

  bool openRecord = !kNoCloudRecord;

  bool showMeetingRecord = false;

  bool meetingPwdSwitch = false;

  final _meetingPasswordController = TextEditingController();

  var _createEnable = true;

  final NESettingsService settingsService =
      NEMeetingKit.instance.getSettingsService();

  @override
  void initState() {
    super.initState();
    AppConfig().init();
    Future.wait([
      settingsService.isTurnOnMyVideoWhenJoinMeetingEnabled(),
      settingsService.isTurnOnMyAudioWhenJoinMeetingEnabled(),
      settingsService.isMeetingCloudRecordEnabled(),
    ]).then((values) {
      setState(() {
        openCamera = values[0];
        openMicrophone = values[1];
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
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text(meetingAppLocalizations.meetingCreate,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.black_222222, fontSize: 17)),
          // systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 10),
            buildUseSelfMeetingItem(),
            if (!TextUtil.isEmpty(MeetingUtil.getShortMeetingNum()))
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
            buildMicrophoneItem(),
            buildSplit(),
            buildCameraItem(),
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
              meetingAppLocalizations.meetingUsePersonalMeetId,
              style: TextStyle(color: AppColors.black_222222, fontSize: 17),
            ),
          ),
          MeetingValueKey.addTextWidgetTest(
              valueKey: MeetingValueKey.userSelfMeetingNumCreateMeeting,
              value: userSelfMeetingNum),
          CupertinoSwitch(
              key: MeetingValueKey.userSelfMeetingNumCreateMeeting,
              value: userSelfMeetingNum,
              onChanged: (bool value) {
                setState(() {
                  userSelfMeetingNum = value;
                });
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
              meetingAppLocalizations.meetingPersonalShortMeetingID,
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
                meetingAppLocalizations.settingInternalDedicated,
                style: TextStyle(fontSize: 12, color: AppColors.color_337eff),
              ),
            ),
            Spacer(),
            Text(
              MeetingUtil.getShortMeetingNum(),
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
              meetingAppLocalizations.meetingPersonalMeetingID,
              style: TextStyle(fontSize: 16, color: AppColors.black_222222),
            ),
            Spacer(),
            Text(
              TextUtil.applyMask(MeetingUtil.getMeetingNum(), '000-000-0000'),
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
              meetingAppLocalizations.meetingPassword,
              style: TextStyle(color: AppColors.black_222222, fontSize: 16),
            ),
          ),
          MeetingValueKey.addTextWidgetTest(
              valueKey: MeetingValueKey.schedulePwdSwitch,
              value: meetingPwdSwitch),
          CupertinoSwitch(
              key: MeetingValueKey.schedulePwdSwitch,
              value: meetingPwdSwitch,
              onChanged: (bool value) {
                setState(() {
                  meetingPwdSwitch = value;
                  if (meetingPwdSwitch &&
                      TextUtil.isEmpty(_meetingPasswordController.text)) {
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
            hintText: '${meetingAppLocalizations.meetingEnterPassword}',
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
              meetingAppLocalizations.meetingJoinCameraOn,
              style: TextStyle(color: AppColors.black_222222, fontSize: 16),
            ),
          ),
          MeetingValueKey.addTextWidgetTest(
              valueKey: MeetingValueKey.openCameraCreateMeeting,
              value: openCamera),
          CupertinoSwitch(
              key: MeetingValueKey.openCameraCreateMeeting,
              value: openCamera,
              onChanged: (bool value) {
                setState(() {
                  openCamera = value;
                  settingsService.setTurnOnMyVideoWhenJoinMeeting(value);
                });
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
              meetingAppLocalizations.meetingJoinCloudRecordOn,
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
              meetingAppLocalizations.meetingJoinMicrophoneOn,
              style: TextStyle(color: AppColors.black_222222, fontSize: 16),
            ),
          ),
          MeetingValueKey.addTextWidgetTest(
              valueKey: MeetingValueKey.openMicrophoneCreateMeeting,
              value: openMicrophone),
          CupertinoSwitch(
              key: MeetingValueKey.openMicrophoneCreateMeeting,
              value: openMicrophone,
              onChanged: (bool value) {
                setState(() {
                  openMicrophone = value;
                  settingsService.setTurnOnMyAudioWhenJoinMeeting(value);
                });
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
            padding:
                MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 13)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                side: BorderSide(color: AppColors.blue_337eff, width: 0),
                borderRadius: BorderRadius.all(Radius.circular(25))))),
        onPressed: _createEnable ? createMeeting : null,
        child: Text(
          meetingAppLocalizations.meetingCreate,
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> createMeeting() async {
    var historyItem = await NEMeetingKit.instance
        .getSettingsService()
        .getHistoryMeetingItem();
    String? lastUsedNickname;
    if (historyItem != null &&
        historyItem.isNotEmpty &&
        (historyItem.first.meetingNum ==
                (userSelfMeetingNum ? MeetingUtil.getMeetingNum() : '') ||
            historyItem.first.shortMeetingNum ==
                (userSelfMeetingNum ? MeetingUtil.getShortMeetingNum() : ''))) {
      lastUsedNickname = historyItem.first.nickname;
    }
    onCreateMeeting(nickname: lastUsedNickname);
  }

  void onCreateMeeting({String? nickname}) async {
    final useSelfNum = userSelfMeetingNum;
    final openCamera = this.openCamera;
    final openMicrophone = this.openMicrophone;

    var meetingNum = useSelfNum ? MeetingUtil.getMeetingNum() : null;
    LoadingUtil.showLoading();
    final result = await NEMeetingUIKit().startMeetingUI(
      context,
      NEStartMeetingUIParams(
        meetingNum: meetingNum,
        password: meetingPwdSwitch ? _meetingPasswordController.text : null,
        displayName: nickname ?? MeetingUtil.getNickName(),
        watermarkConfig: NEWatermarkConfig(name: MeetingUtil.getNickName()),
      ),
      await buildMeetingUIOptions(
        noVideo: !openCamera,
        noAudio: !openMicrophone,
        noCloudRecord: !openRecord,
        context: context,
      ),
      onMeetingPageRouteWillPush: () async {
        LoadingUtil.cancelLoading();
        if (mounted) {
          NavUtils.pop(context);
        }
      },
      backgroundWidget: MeetingAppLocalizationsScope(child: HomePageRoute()),
    );
    LoadingUtil.cancelLoading();
    if (!mounted) return;
    final errorCode = result.code;
    final errorMessage = result.msg;
    if (errorCode == NEMeetingErrorCode.success) {
      //do nothing
    } else if (errorCode == NEMeetingErrorCode.meetingAlreadyExist &&
        useSelfNum) {
      //shareScreenTips 屏幕共享弹窗提示文案
      switchToJoin(
        context,
        NEJoinMeetingUIParams(
          meetingNum: meetingNum!,
          displayName: nickname ?? MeetingUtil.getNickName(),
          watermarkConfig: NEWatermarkConfig(
            name: MeetingUtil.getNickName(),
          ),
        ),
        await buildMeetingUIOptions(
          noVideo: !openCamera,
          noAudio: !openMicrophone,
          context: context,
        ),
      );
    } else if (errorCode == NEMeetingErrorCode.noNetwork) {
      ToastUtils.showToast(
          context, meetingAppLocalizations.globalNetworkUnavailableCheck);
    } else if (errorCode == NEMeetingErrorCode.noAuth) {
      ToastUtils.showToast(context, meetingAppLocalizations.authNoAuth);
      AuthManager().logout();
      NavUtils.pushNamedAndRemoveUntil(context, RouterName.entrance);
    } else if (errorCode == NEMeetingErrorCode.alreadyInMeeting) {
      ToastUtils.showToast(context,
          meetingAppLocalizations.meetingOperationNotSupportedInMeeting);
    } else if (errorCode == NEMeetingErrorCode.cancelled) {
      /// 暂不处理
    } else {
      var errorTips = HttpCode.getMsg(
          errorMessage, meetingAppLocalizations.meetingCreateFail);
      ToastUtils.showToast(context, errorTips);
    }
  }

  void switchToJoin(BuildContext context, NEJoinMeetingUIParams param,
      NEMeetingUIOptions opts) {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return CupertinoAlertDialog(
            content: Text(meetingAppLocalizations.meetingCreateAlreadyInTip),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(meetingAppLocalizations.globalNo),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text(meetingAppLocalizations.globalYes),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  NEMeetingUIKit().joinMeetingUI(context, param, opts,
                      backgroundWidget:
                          MeetingAppLocalizationsScope(child: HomePageRoute()),
                      onMeetingPageRouteWillPush: () async {
                    NavUtils.pop(context);
                  }).then((value) {
                    if (!value.isSuccess()) {
                      var errorTips = HttpCode.getMsg(
                          value.msg, meetingAppLocalizations.meetingJoinFail);
                      ToastUtils.showToast(context, errorTips);
                    }
                  });
                },
              ),
            ],
          );
        });
  }
}
