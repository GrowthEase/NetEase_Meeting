// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:nemeeting/base/util/text_util.dart';
import 'package:nemeeting/constants.dart';
import 'package:nemeeting/language/localizations.dart';
import 'package:nemeeting/routes/entrance.dart';
import 'package:nemeeting/uikit/const/consts.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/utils/dialog_utils.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:nemeeting/widget/meeting_text_field.dart';
import 'package:nemeeting/widget/ne_widget.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';

import '../base/util/error.dart';
import '../service/client/http_code.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/utils/nav_utils.dart';
import '../uikit/utils/router_name.dart';

class GuestLoginArguments {
  final String meetingNum;
  final String displayName;
  final bool noAudio;
  final bool noVideo;

  GuestLoginArguments({
    required this.meetingNum,
    required this.displayName,
    required this.noAudio,
    required this.noVideo,
  });
}

class GuestLoginRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GuestLoginState();
  }
}

class GuestLoginState extends AppBaseState<GuestLoginRoute>
    with AppLogger, GuestJoinController {
  late String mobile;
  late TextEditingController _mobileController, _smsCodeController;
  late MaskTextInputFormatter _mobileFormatter;
  final FocusNode _mobileFocusNode = FocusNode();
  final FocusNode _smsFocusNode = FocusNode();
  bool _mobileFocus = false;
  bool _mobileValid = false;
  bool _btnEnable = false;
  Stream<int>? _smsSecondsCountDownStream;
  late GuestLoginArguments arguments;

  @override
  void initState() {
    super.initState();
    mobile = '';
    _mobileFormatter = MaskTextInputFormatter(
        mask: '### #### ####', filter: {"#": RegExp(r'[0-9]')});
    _mobileController = TextEditingController(text: mobile);
    _mobileFocusNode.addListener(() {
      setState(() {
        _mobileFocus = _mobileFocusNode.hasFocus;
      });
    });
    _smsCodeController = TextEditingController();
    Listenable.merge([_mobileController, _smsCodeController])
        .addListener(refreshUI);

    _smsFocusNode.addListener(refreshUI);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    arguments =
        ModalRoute.of(context)!.settings.arguments as GuestLoginArguments;
  }

  void refreshUI() {
    setState(() {
      _mobileValid = _mobileController.text.length >= mobileLength;
      _btnEnable = _mobileValid && _smsCodeController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _mobileFocusNode.dispose();
    _smsCodeController.dispose();
    _smsFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget buildBody() {
    return NEGestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: AppColors.white,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: EdgeInsets.only(left: 30, top: 16),
                    child: Text(
                      getAppLocalizations().meetingGuestJoinVerify,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.black_222222,
                        fontWeight: FontWeight.w500,
                        fontSize: 28.sp,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 30, top: 16),
                  child: Text(
                    getAppLocalizations().meetingGuestJoinVerifyTip,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.black_333333,
                      fontWeight: FontWeight.normal,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 50,
                    margin: EdgeInsets.only(left: 30, top: 24, right: 30),
                    decoration: BoxDecoration(
                      color: AppColors.primaryElement,
                    ),
                    child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topLeft,
                        children: <Widget>[
                          Row(children: <Widget>[
                            Text(
                              '+86',
                              style: TextStyle(fontSize: 17),
                            ),
                            Container(
                              height: 20,
                              child:
                                  VerticalDivider(color: AppColors.colorDCDFE5),
                            ),
                            Expanded(
                              child: TextField(
                                key: MeetingValueKey.hintMobile,
                                focusNode: _mobileFocusNode,
                                controller: _mobileController,
                                keyboardType: TextInputType.number,
                                cursorColor: AppColors.blue_337eff,
                                keyboardAppearance: Brightness.light,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(
                                      mobileLength),
                                  _mobileFormatter
                                ],
                                decoration: InputDecoration(
                                    hintText:
                                        getAppLocalizations().authEnterMobile,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                        fontSize: 17,
                                        color: AppColors.colorDCDFE5),
                                    suffixIcon: !_mobileFocusNode.hasFocus ||
                                            TextUtil.isEmpty(
                                                _mobileController.text)
                                        ? null
                                        : ClearIconButton(
                                            onPressed: () {
                                              _mobileController.clear();
                                            },
                                          )),
                              ),
                              flex: 1,
                            ),
                          ]),
                          Container(
                            margin: EdgeInsets.only(top: 35),
                            child: Divider(
                              thickness: 1,
                              color: _mobileFocus
                                  ? AppColors.blue_337eff
                                  : AppColors.colorDCDFE5,
                            ),
                          ),
                        ]),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 30, top: 20, right: 30),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 1.h,
                        color: _smsFocusNode.hasFocus
                            ? AppColors.blue_337eff
                            : AppColors.colorDCDFE5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: MeetingTextField(
                          height: 44,
                          fontSize: 17,
                          hintFontSize: 17,
                          keyboardType: TextInputType.number,
                          focusNode: _smsFocusNode,
                          hintText: getAppLocalizations().authEnterCheckCode,
                          controller: _smsCodeController,
                          showUnderline: false,
                          showClearIcon: false,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      StreamBuilder(
                        stream: _smsSecondsCountDownStream,
                        initialData: null,
                        builder: (context, snapshot) {
                          int? seconds =
                              snapshot.connectionState == ConnectionState.none
                                  ? null
                                  : snapshot.data;
                          return GestureDetector(
                            onTap: () {
                              if (_smsSecondsCountDownStream == null &&
                                  _mobileValid) {
                                getCheckCodeServer();
                                _smsSecondsCountDownStream = () async* {
                                  for (var i = 60; i > 0; i--) {
                                    yield i;
                                    await Future.delayed(Duration(seconds: 1));
                                  }
                                  if (mounted) {
                                    setState(() {
                                      _smsSecondsCountDownStream = null;
                                    });
                                  }
                                }();
                                setState(() {});
                              }
                            },
                            child: Text(
                              seconds != null
                                  ? getAppLocalizations()
                                      .authGetCheckCodeAgain(seconds)
                                  : getAppLocalizations().authGetCheckCode,
                              style: TextStyle(
                                fontSize: 17,
                                color: seconds != null || !_mobileValid
                                    ? AppColors.greyB0B6BE
                                    : AppColors.color_337eff,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Container(
                  margin: EdgeInsets.only(left: 30, top: 50, right: 30),
                  child: MeetingActionButton(
                    key: MeetingValueKey.createMeetingBtn,
                    onTap: _btnEnable ? _guestJoinMeeting : null,
                    text: getAppLocalizations().meetingJoin,
                  ),
                ),
                SizedBox(
                  height: 16 + MediaQuery.paddingOf(context).bottom,
                ),
              ]),
        ));
  }

  void getCheckCodeServer() {
    final mobile = TextUtil.replaceAllBlank(_mobileController.text);
    logger.i('Get check code: mobile = $mobile');
    var result = NEMeetingKit.instance
        .getGuestService()
        .requestSmsCodeForGuestJoin(arguments.meetingNum, mobile);
    lifecycleExecuteUI(result).then((result) {
      if (result == null) return;
      if (result.code == NEMeetingErrorCode.success) {
        _smsFocusNode.requestFocus();
      } else if (result.code == HttpCode.phoneErrorTip) {
        ErrorUtil.showError(context, getAppLocalizations().authPhoneErrorTip);
      } else {
        ErrorUtil.showError(context, HttpCode.getMsg(result.msg));
      }
    });
  }

  void _guestJoinMeeting() async {
    guestJoinMeeting(
      meetingNum: arguments.meetingNum,
      displayName: arguments.displayName,
      noAudio: arguments.noAudio,
      noVideo: arguments.noVideo,
      phoneNum: TextUtil.replaceAllBlank(_mobileController.text),
      smsCode: _smsCodeController.text,
    );
  }

  @override
  bool isShowBackBtn() {
    return true;
  }

  @override
  String getTitle() {
    return '';
  }
}

mixin GuestJoinController<T extends StatefulWidget> on State<T> {
  void guestJoinMeeting({
    required String meetingNum,
    required String displayName,
    String? phoneNum,
    String? smsCode,
    bool noAudio = true,
    bool noVideo = true,
  }) async {
    LoadingUtil.showLoading();
    final result =
        await NEMeetingKit.instance.getGuestService().joinMeetingAsGuest(
      context,
      NEGuestJoinMeetingParams(
        meetingNum: meetingNum,
        displayName: displayName,
        phoneNumber: phoneNum,
        smsCode: smsCode,
        watermarkConfig: NEWatermarkConfig(
          name: displayName,
        ),
      ),
      NEMeetingOptions(
        title: getAppLocalizations().globalAppName,
        noAudio: noAudio,
        noVideo: noVideo,
        enablePictureInPicture: true,
      ),
      onPasswordPageRouteWillPush: () async {
        LoadingUtil.cancelLoading();
      },
      onMeetingPageRouteWillPush: () async {
        LoadingUtil.cancelLoading();
        if (!mounted) return;
        NavUtils.popUntil(context, RouterName.entrance);
      },
    );
    if (!mounted) return;
    final errorCode = result.code;
    final errorMessage = result.msg;
    LoadingUtil.cancelLoading();
    if (errorCode == NEMeetingErrorCode.success) {
    } else if (errorCode == NEMeetingErrorCode.noNetwork) {
      ToastUtils.showToast(
          context, getAppLocalizations().globalNetworkUnavailableCheck);
    } else if (errorCode == NEMeetingErrorCode.alreadyInMeeting) {
      ToastUtils.showToast(
          context, getAppLocalizations().meetingOperationNotSupportedInMeeting);
    } else if (errorCode == NEMeetingErrorCode.guestJoinNotSupported) {
      AppDialogUtils.showOneButtonCommonDialog(
        context,
        getAppLocalizations().meetingGuestJoinNotSupportedTitle,
        getAppLocalizations().meetingGuestJoinNotSupported,
        () => Navigator.pop(context),
      );
    } else if (errorCode == NEMeetingErrorCode.guestJoinNeedVerify) {
      NavUtils.pushNamed(
        context,
        RouterName.guestLogin,
        arguments: GuestLoginArguments(
          meetingNum: meetingNum,
          displayName: displayName,
          noAudio: noAudio,
          noVideo: noVideo,
        ),
      );
    } else if (errorCode == NEMeetingErrorCode.meetingLocked) {
      AppDialogUtils.showOneButtonCommonDialog(
        context,
        NEMeetingUIKit.instance.getUIKitLocalizations().meetingLocked,
        NEMeetingUIKit.instance.getUIKitLocalizations().meetingLockedTip,
        () => Navigator.pop(context),
      );
    } else if (errorCode == NEMeetingErrorCode.cancelled) {
      /// 暂不处理
    } else {
      var errorTips =
          HttpCode.getMsg(errorMessage, getAppLocalizations().meetingJoinFail);
      ToastUtils.showToast(context, errorTips);
    }
  }
}
