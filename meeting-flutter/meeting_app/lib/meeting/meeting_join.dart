// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/routes/home_page.dart';
import 'package:nemeeting/utils/const_config.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:nemeeting/uikit/const/consts.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/profile/app_profile.dart';
import '../language/localizations.dart';
import '../uikit/utils/nav_utils.dart';
import '../uikit/utils/router_name.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/fonts.dart';
import 'package:nemeeting/base/util/text_util.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

class MeetJoinRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeetJoinRouteState();
  }
}

class _MeetJoinRouteState extends LifecycleBaseState<MeetJoinRoute>
    with MeetingAppLocalizationsMixin {
  bool openCamera = true;

  bool openMicrophone = true;

  final maxIdLength = 12;

  late TextEditingController _meetingIdController;

  bool joinEnable = false;

  final NESettingsService settingsService =
      NEMeetingKit.instance.getSettingsService();

  @override
  void initState() {
    super.initState();
    var meetingId = AppProfile.deepLinkMeetingId;
    AppProfile.deepLinkMeetingId = null;
    _meetingIdController = TextEditingController(text: meetingId);
    _onMeetingIdChanged();

    Future.wait([
      settingsService.isTurnOnMyVideoWhenJoinMeetingEnabled(),
      settingsService.isTurnOnMyAudioWhenJoinMeetingEnabled(),
    ]).then((values) {
      setState(() {
        openCamera = values[0];
        openMicrophone = values[1];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(
                  key: MeetingValueKey.back,
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
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text(''),
          // systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
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
              buildMicrophoneItem(),
              buildCameraItem(),
              buildJoin()
            ],
          ),
        ));
  }

  Container buildJoinTitle() {
    return Container(
      padding: EdgeInsets.only(left: 30),
      child: Text(
        meetingAppLocalizations.meetingJoin,
        style: TextStyle(
            fontSize: 28,
            color: AppColors.black_222222,
            fontWeight: FontWeight.w500),
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
          autofocus: _meetingIdController.text.isEmpty,
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
              hintText: meetingAppLocalizations.meetingEnterId,
              hintStyle: TextStyle(fontSize: 17, color: AppColors.greyB0B6BE),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: AppColors.color_337eff,
                    width: 1,
                    style: BorderStyle.solid),
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
              meetingAppLocalizations.meetingJoinCameraOn,
              style: TextStyle(color: AppColors.black_222222, fontSize: 14),
            ),
          ),
          MeetingValueKey.addTextWidgetTest(
              valueKey: MeetingValueKey.openCameraJoinMeeting,
              value: openCamera),
          CupertinoSwitch(
            key: MeetingValueKey.openCameraJoinMeeting,
            value: openCamera,
            onChanged: (bool value) {
              setState(() {
                openCamera = value;
                settingsService.setTurnOnMyVideoWhenJoinMeeting(value);
              });
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
              meetingAppLocalizations.meetingJoinMicrophoneOn,
              style: TextStyle(color: AppColors.black_222222, fontSize: 14),
            ),
          ),
          MeetingValueKey.addTextWidgetTest(
              valueKey: MeetingValueKey.openMicrophoneJoinMeeting,
              value: openMicrophone),
          CupertinoSwitch(
              key: MeetingValueKey.openMicrophoneJoinMeeting,
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
            padding:
                MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 13)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                side: BorderSide(
                    color: joinEnable
                        ? AppColors.blue_337eff
                        : AppColors.blue_50_337eff,
                    width: 0),
                borderRadius: BorderRadius.all(Radius.circular(25))))),
        onPressed: joinEnable ? joinMeeting : null,
        child: Text(
          meetingAppLocalizations.meetingJoin,
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> joinMeeting() async {
    FocusScope.of(context).requestFocus(FocusNode());
    var historyItem = await NEMeetingKit.instance
        .getSettingsService()
        .getHistoryMeetingItem();
    String? lastUsedNickname;

    if (historyItem != null &&
        historyItem.isNotEmpty &&
        (historyItem.first.meetingNum == targetMeetingNum ||
            historyItem.first.shortMeetingNum == targetMeetingNum)) {
      lastUsedNickname = historyItem.first.nickname;
    }
    _onJoinMeeting(nickname: lastUsedNickname);
  }

  String get targetMeetingNum =>
      TextUtil.replace(_meetingIdController.text, RegExp(r'-'), '');

  void _onJoinMeeting({String? nickname}) async {
    LoadingUtil.showLoading();
    //shareScreenTips 屏幕弹窗提示共享文案
    final result = await NEMeetingUIKit().joinMeetingUI(
      context,
      NEJoinMeetingUIParams(
        meetingNum: targetMeetingNum,
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
      onPasswordPageRouteWillPush: () async {
        LoadingUtil.cancelLoading();
      },
      onMeetingPageRouteWillPush: () async {
        LoadingUtil.cancelLoading();
        if (!mounted) return;
        NavUtils.pop(context);
      },
      backgroundWidget: MeetingAppLocalizationsScope(child: HomePageRoute()),
    );
    if (!mounted) return;
    final errorCode = result.code;
    final errorMessage = result.msg;
    LoadingUtil.cancelLoading();
    if (errorCode == NEMeetingErrorCode.success) {
    } else if (errorCode == NEMeetingErrorCode.noNetwork) {
      ToastUtils.showToast(
          context, meetingAppLocalizations.globalNetworkUnavailableCheck);
    } else if (errorCode == NEMeetingErrorCode.noAuth) {
      ToastUtils.showToast(
          context, meetingAppLocalizations.authLoginOnOtherDevice);
      AuthManager().logout();
      NavUtils.toEntrance(context);
    } else if (errorCode == NEMeetingErrorCode.alreadyInMeeting) {
      ToastUtils.showToast(context,
          meetingAppLocalizations.meetingOperationNotSupportedInMeeting);
    } else if (errorCode == NEMeetingErrorCode.cancelled) {
      /// 暂不处理
    } else {
      var errorTips = HttpCode.getMsg(
          errorMessage, meetingAppLocalizations.meetingJoinFail);
      ToastUtils.showToast(context, errorTips);
    }
  }

  void _onMeetingIdChanged() {
    var meetingId = _meetingIdController.text;
    joinEnable = meetingId.length >= meetIdLengthMin;
  }

  @override
  void dispose() {
    _meetingIdController.dispose();
    LoadingUtil.cancelLoading();
    super.dispose();
  }
}
