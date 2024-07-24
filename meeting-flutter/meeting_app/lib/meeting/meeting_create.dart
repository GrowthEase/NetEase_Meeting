// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:core';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/language/localizations.dart';
import 'package:nemeeting/routes/home_page.dart';
import 'package:nemeeting/uikit/state/meeting_base_state.dart';
import 'package:nemeeting/utils/const_config.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/config/app_config.dart';
import 'package:nemeeting/widget/ne_widget.dart';
import '../uikit/utils/nav_utils.dart';
import '../uikit/values/colors.dart';
import 'package:nemeeting/base/util/text_util.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';
import 'package:nemeeting/utils/integration_test.dart';
import '../uikit/const/consts.dart';
import '../widget/meeting_text_field.dart';

class MeetCreateRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeetCreateRouteState();
  }
}

class _MeetCreateRouteState extends AppBaseState<MeetCreateRoute> {
  ValueNotifier<bool> userSelfMeetingNum = ValueNotifier(false);

  ValueNotifier<bool> openCamera = ValueNotifier(true);

  ValueNotifier<bool> openMicrophone = ValueNotifier(true);

  ValueNotifier<bool> openRecord = ValueNotifier(!kNoCloudRecord);

  bool showMeetingRecord = false;

  ValueNotifier<bool> meetingPwdSwitch = ValueNotifier(false);

  final _meetingPasswordController = TextEditingController();

  ValueNotifier<bool> _createEnable = ValueNotifier(true);

  FocusNode passwordFocusNode = FocusNode();

  final NESettingsService settingsService =
      NEMeetingKit.instance.getSettingsService();

  @override
  void initState() {
    super.initState();
    AppConfig().init();
    Future.wait([
      settingsService.isTurnOnMyVideoWhenJoinMeetingEnabled(),
      settingsService.isTurnOnMyAudioWhenJoinMeetingEnabled(),
    ]).then((values) {
      openCamera.value = values[0];
      openMicrophone.value = values[1];
    });
    passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _meetingPasswordController.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  String getTitle() {
    return getAppLocalizations().meetingHold;
  }

  @override
  Widget buildBody() {
    return NEGestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MeetingCard(children: [
                    buildUseSelfMeetingItem(),
                    if (!TextUtil.isEmpty(MeetingUtil.getShortMeetingNum()))
                      buildShortMeetingIdItem(),
                    buildMeetingIdItem(),
                  ]),
                  MeetingCard(children: [
                    buildPwd(),
                    ValueListenableBuilder(
                        valueListenable: meetingPwdSwitch,
                        builder: (context, value, child) {
                          return Visibility(
                            visible: value,
                            child: buildPwdInput(),
                          );
                        }),
                  ]),
                  MeetingCard(children: [
                    buildMicrophoneItem(),
                    buildCameraItem(),
                    if (showMeetingRecord) buildRecordItem(),
                  ]),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
          buildCreate()
        ],
      ),
    );
  }

  Widget buildUseSelfMeetingItem() {
    return MeetingSwitchItem(
        switchKey: MeetingValueKey.userSelfMeetingNumCreateMeeting,
        title: getAppLocalizations().meetingUsePersonalMeetId,
        valueNotifier: userSelfMeetingNum,
        onChanged: (bool value) {
          userSelfMeetingNum.value = value;
        });
  }

  Widget buildShortMeetingIdItem() {
    return MeetingArrowItem(
      title: getAppLocalizations().meetingPersonalShortMeetingID,
      showArrow: false,
      tag: Container(
        margin: EdgeInsets.only(left: 6.w),
        padding: EdgeInsets.only(left: 6.w, right: 6.w, bottom: 2.h),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: AppColors.color_1a337eff,
            border: Border.all(color: AppColors.color_33337eff)),
        child: Text(
          getAppLocalizations().settingInternalDedicated,
          style: TextStyle(fontSize: 12, color: AppColors.color_337eff),
        ),
      ),
      content: MeetingUtil.getShortMeetingNum(),
    );
  }

  Widget buildMeetingIdItem() {
    return MeetingArrowItem(
      key: MeetingValueKey.personalMeetingId,
      title: getAppLocalizations().meetingPersonalMeetingID,
      content: TextUtil.applyMask(MeetingUtil.getMeetingNum(), '000-000-0000'),
      showArrow: false,
    );
  }

  Widget buildPwd() {
    return MeetingSwitchItem(
        switchKey: MeetingValueKey.schedulePwdSwitch,
        title: getAppLocalizations().meetingPassword,
        valueNotifier: meetingPwdSwitch,
        onChanged: (bool value) {
          meetingPwdSwitch.value = value;
          if (meetingPwdSwitch.value &&
              TextUtil.isEmpty(_meetingPasswordController.text)) {
            _meetingPasswordController.text =
                (Random().nextInt(900000) + 100000).toString();
          }
          _createEnable.value = _updateCreateEnableState();
        });
  }

  Widget buildPwdInput() {
    return Container(
      height: 48,
      margin: EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(
              color: passwordFocusNode.hasFocus
                  ? AppColors.color_337eff
                  : AppColors.colorE6E7EB,
              width: 1),
          borderRadius: BorderRadius.circular(4.r),
        ),
        padding: EdgeInsets.only(left: 12.w),
        child: Row(children: [
          Expanded(
              child: TextField(
            key: MeetingValueKey.schedulePwdInput,
            autofocus: false,
            focusNode: passwordFocusNode,
            keyboardAppearance: Brightness.light,
            controller: _meetingPasswordController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(meetingPasswordLengthMax),
              FilteringTextInputFormatter.allow(RegExp(r'\d+')),
            ],
            textAlignVertical: TextAlignVertical.center,
            onChanged: (value) {
              _createEnable.value = _updateCreateEnableState();
            },
            decoration: InputDecoration(
              hintText: '${getAppLocalizations().meetingEnterPassword}',
              hintStyle: TextStyle(fontSize: 16, color: AppColors.color_999999),
              isCollapsed: true,
              border: InputBorder.none,
            ),
            style: TextStyle(color: AppColors.color_1E1E27, fontSize: 16),
          )),
          TextUtil.isEmpty(_meetingPasswordController.text) ||
                  !passwordFocusNode.hasFocus
              ? SizedBox.shrink()
              : ClearIconButton(
                  key: MeetingValueKey.clearInputMeetingPassword,
                  padding:
                      EdgeInsets.only(right: 12, top: 6, bottom: 6, left: 6),
                  onPressed: () {
                    _meetingPasswordController.clear();
                    _createEnable.value = _updateCreateEnableState();
                  })
        ]),
      ),
    );
  }

  bool _updateCreateEnableState() {
    return !meetingPwdSwitch.value ||
        _meetingPasswordController.text.length == 6;
  }

  Widget buildCameraItem() {
    return MeetingSwitchItem(
      switchKey: MeetingValueKey.openCameraCreateMeeting,
      title: getAppLocalizations().meetingJoinCameraOn,
      valueNotifier: openCamera,
      onChanged: (bool value) {
        openCamera.value = value;
        settingsService.enableTurnOnMyVideoWhenJoinMeeting(value);
      },
    );
  }

  Widget buildRecordItem() {
    return MeetingSwitchItem(
      switchKey: MeetingValueKey.openRecordEnterMeeting,
      title: getAppLocalizations().meetingJoinCloudRecordOn,
      valueNotifier: openRecord,
      onChanged: (bool value) {
        openRecord.value = value;
      },
    );
  }

  Widget buildMicrophoneItem() {
    return MeetingSwitchItem(
      switchKey: MeetingValueKey.openMicrophoneCreateMeeting,
      title: getAppLocalizations().meetingJoinMicrophoneOn,
      valueNotifier: openMicrophone,
      onChanged: (bool value) {
        openMicrophone.value = value;
        settingsService.enableTurnOnMyAudioWhenJoinMeeting(value);
      },
    );
  }

  Widget buildCreate() {
    return ValueListenableBuilder(
        valueListenable: _createEnable,
        builder: (context, value, child) {
          return SafeArea(
              child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: MeetingActionButton(
              key: MeetingValueKey.createMeetingBtn,
              onTap: value ? createMeeting : null,
              text: getAppLocalizations().meetingHold,
            ),
          ));
        });
  }

  Future<void> createMeeting() async {
    final lastUsedNickname = LocalHistoryMeetingManager().getLatestNickname(
        userSelfMeetingNum.value ? MeetingUtil.getMeetingNum() : '');
    onCreateMeeting(nickname: lastUsedNickname);
  }

  void onCreateMeeting({String? nickname}) async {
    final useSelfNum = userSelfMeetingNum.value;

    var meetingNum = useSelfNum ? MeetingUtil.getMeetingNum() : null;
    LoadingUtil.showLoading();
    final result = await NEMeetingKit.instance.getMeetingService().startMeeting(
      context,
      NEStartMeetingParams(
        meetingNum: meetingNum,
        password:
            meetingPwdSwitch.value ? _meetingPasswordController.text : null,
        displayName: nickname ?? MeetingUtil.getNickName(),
        watermarkConfig: NEWatermarkConfig(name: MeetingUtil.getNickName()),
      ),
      await buildMeetingUIOptions(
        noVideo: !openCamera.value,
        noAudio: !openMicrophone.value,
        noCloudRecord: !openRecord.value,
        context: context,
      ),
      onMeetingPageRouteWillPush: () async {
        LoadingUtil.cancelLoading();
        if (mounted) {
          NavUtils.pop(context);
        }
      },
      backgroundWidget: HomePageRoute(),
    );
    LoadingUtil.cancelLoading();
    if (!mounted) return;
    final errorCode = result.code;
    final errorMessage = result.msg;
    if (errorCode == NEMeetingErrorCode.success) {
    } else if (errorCode == NEMeetingErrorCode.meetingAlreadyExist &&
        useSelfNum) {
      //shareScreenTips 屏幕共享弹窗提示文案
      switchToJoin(
        context,
        NEJoinMeetingParams(
          meetingNum: meetingNum!,
          displayName: nickname ?? MeetingUtil.getNickName(),
          watermarkConfig: NEWatermarkConfig(
            name: MeetingUtil.getNickName(),
          ),
        ),
        await buildMeetingUIOptions(
          noVideo: !openCamera.value,
          noAudio: !openMicrophone.value,
          context: context,
        ),
      );
    } else if (errorCode == NEMeetingErrorCode.noNetwork) {
      ToastUtils.showToast(
          context, getAppLocalizations().globalNetworkUnavailableCheck);
    } else if (errorCode == NEMeetingErrorCode.noAuth) {
      ToastUtils.showToast(context, getAppLocalizations().authNoAuth);
      AuthManager().logout();
      NavUtils.toEntrance(context);
    } else if (errorCode == NEMeetingErrorCode.alreadyInMeeting) {
      ToastUtils.showToast(
          context, getAppLocalizations().meetingOperationNotSupportedInMeeting);
    } else if (errorCode == NEMeetingErrorCode.cancelled) {
      /// 暂不处理
    } else {
      var errorTips = HttpCode.getMsg(
          errorMessage, getAppLocalizations().meetingCreateFail);
      ToastUtils.showToast(context, errorTips);
    }
  }

  void switchToJoin(
      BuildContext context, NEJoinMeetingParams param, NEMeetingOptions opts) {
    showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return CupertinoAlertDialog(
            content: Text(getAppLocalizations().meetingCreateAlreadyInTip),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(getAppLocalizations().globalNo),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text(getAppLocalizations().globalYes),
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
              ),
            ],
          );
        }).then((ok) {
      if (!context.mounted || ok != true) return;
      NEMeetingKit.instance
          .getMeetingService()
          .joinMeeting(context, param, opts, backgroundWidget: HomePageRoute(),
              onMeetingPageRouteWillPush: () async {
        NavUtils.pop(context);
      }).then((value) {
        if (!value.isSuccess() && context.mounted) {
          var errorTips =
              HttpCode.getMsg(value.msg, getAppLocalizations().meetingJoinFail);
          ToastUtils.showToast(context, errorTips);
        }
      });
    });
  }
}
