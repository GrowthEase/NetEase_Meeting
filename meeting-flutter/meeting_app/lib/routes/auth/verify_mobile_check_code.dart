// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/base/util/error.dart';
import 'package:nemeeting/language/localizations.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/repo/auth_repo.dart';
import 'package:nemeeting/uikit/utils/nav_utils.dart';
import 'package:nemeeting/uikit/utils/router_name.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/state/auth_base_state.dart';
import 'package:nemeeting/widget/check_code_widget.dart';

import '../../utils/integration_test.dart';

class VerifyMobileCheckCodeArguments {
  final String appKey;
  final String mobile;

  VerifyMobileCheckCodeArguments(this.appKey, this.mobile);
}

class VerifyMobileCheckCodeRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return VerifyMobileCheckCodeState();
  }
}

class VerifyMobileCheckCodeState extends AuthBaseState
    with MeetingAppLocalizationsMixin {
  final TextEditingController _pinEditingController = TextEditingController();
  final int _pinLength = 6;
  bool _btnEnable = false;

  final TapGestureRecognizer _tapPrivacy = TapGestureRecognizer();

  final TapGestureRecognizer _tapUserProtocol = TapGestureRecognizer();

  late String appKey;
  late String mobile;

  @override
  Color get backgroundColor => AppColors.white;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)!.settings.arguments
        as VerifyMobileCheckCodeArguments;
    appKey = arguments.appKey;
    mobile = arguments.mobile;
  }

  @override
  Widget getSubject() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        buildVerifyCodeTips(),
        buildInputBox(),
        buildNextBtn(),
      ],
    );
  }

  TextStyle buildTextStyle(Color color) {
    return TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none);
  }

  Container buildNextBtn() {
    return Container(
      height: 50,
      margin: EdgeInsets.only(left: 30, top: 50, right: 30),
      child: ElevatedButton(
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
                    color: _btnEnable
                        ? AppColors.blue_337eff
                        : AppColors.blue_50_337eff,
                    width: 0),
                borderRadius: BorderRadius.all(Radius.circular(25))))),
        onPressed: _btnEnable ? verifyMobileCheckCodeServer : null,
        child: Text(
          meetingAppLocalizations.authNextStep,
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Container buildInputBox() {
    return Container(
      height: 81,
      margin: EdgeInsets.only(top: 31),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            height: 48,
            // width: 264,
            child: PinInputTextField(
              key: MeetingValueKey.pinInput,
              pinLength: _pinLength,
              decoration: BoxLooseDecoration(
                strokeColorBuilder: PinListenColorBuilder(
                    AppColors.color_337eff, AppColors.colorC9cfe5),
                bgColorBuilder: FixedColorBuilder(AppColors.white),
                strokeWidth: 1,
                //gapSpace: 24,
                obscureStyle: ObscureStyle(
                  isTextObscure: false,
                  //                          obscureText: '',
                ),
                //                        hintText: 'dsfs',
              ),
              controller: _pinEditingController,
              textInputAction: TextInputAction.go,
              enabled: true,
              autoFocus: true,
              onSubmit: (pin) {
                debugPrint('submit pin:$pin');
              },
              onChanged: (pin) {
                setState(() {
                  _btnEnable = pin.length >= _pinLength;
                });
              },
            ),
          ),
          Spacer(),
          Align(
            alignment: Alignment.topCenter,
            child: CheckCodeWidget(appKey, mobile),
          ),
        ],
      ),
    );
  }

  Container buildVerifyCodeTips() {
    return Container(
      margin: EdgeInsets.only(left: 30, top: 7, right: 30),
      child: Text(
        meetingAppLocalizations.authCheckCodeHasSendToMobile('+86-$mobile'),
        textAlign: TextAlign.left,
        style: TextStyle(
          color: AppColors.primaryText,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          letterSpacing: -0.33765,
          height: 1.57143,
        ),
      ),
    );
  }

  @override
  String getSubTitle() {
    return meetingAppLocalizations.authEnterCheckCode;
  }

  void verifyMobileCheckCodeServer() {
    final checkCode = _pinEditingController.text;
    Alog.d(tag: tag, content: 'Verify check code: authModel = $checkCode');
    var result = AuthRepo().loginByMobileCheckCode(appKey, mobile, checkCode);
    lifecycleExecuteUI(result).then((result) {
      if (result?.code == HttpCode.success) {
        NavUtils.pushNamedAndRemoveUntil(context, RouterName.homePage);
      } else if (result?.code == HttpCode.verifyCodeErrorTip) {
        ErrorUtil.showError(
            context, meetingAppLocalizations.authVerifyCodeErrorTip);
      } else {
        ErrorUtil.showError(context, HttpCode.getMsg(result?.msg));
      }
    });
  }

  @override
  void dispose() {
    _pinEditingController.dispose();
    _tapPrivacy.dispose();
    _tapUserProtocol.dispose();
    super.dispose();
  }
}
