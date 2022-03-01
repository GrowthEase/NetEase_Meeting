// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:base/util/error.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:service/client/http_code.dart';
import 'package:service/config/scene_type.dart';
import 'package:service/config/servers.dart';
import 'package:service/repo/auth_repo.dart';
import 'package:uikit/utils/nav_utils.dart';
import 'package:uikit/utils/router_name.dart';
import 'package:uikit/values/colors.dart';
import 'package:uikit/values/strings.dart';
import 'package:nemeeting/arguments/webview_arguments.dart';
import 'package:nemeeting/state/auth_base_state.dart';
import 'package:nemeeting/widget/check_code_widget.dart';

class CheckMobileRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CheckMobileState();
  }
}

class CheckMobileState extends AuthBaseState {
  final TextEditingController _pinEditingController = TextEditingController();
  final int _pinLength = 4;
  bool _btnEnable = false;

  final TapGestureRecognizer _tapPrivacy = TapGestureRecognizer();

  final TapGestureRecognizer _tapUserProtocol = TapGestureRecognizer();

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

  Widget protocolTips() {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 16),
      child: Text.rich(TextSpan(children: [
        TextSpan(
            text: Strings.joinAppTipsPrefix,
            style: buildTextStyle(AppColors.color_999999)),
        TextSpan(
            text: Strings.joinAppPrivacy,
            style: buildTextStyle(AppColors.blue_337eff),
            recognizer: _tapPrivacy
              ..onTap = () {
                NavUtils.pushNamed(context, RouterName.webview,
                    arguments:
                        WebViewArguments(servers.privacy, Strings.privacy));
              }),
        TextSpan(
            text: Strings.joinAppAnd,
            style: buildTextStyle(AppColors.color_999999)),
        TextSpan(
            text: Strings.joinAppUserProtocol,
            style: buildTextStyle(AppColors.blue_337eff),
            recognizer: _tapUserProtocol
              ..onTap = () {
                NavUtils.pushNamed(context, RouterName.webview,
                    arguments: WebViewArguments(
                        servers.userProtocol, Strings.user_protocol));
              }),
      ])),
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
        onPressed: _btnEnable ? getCheckCodeServer : null,
        child: Text(
          Strings.nextStep,
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
            height: 48,
            width: 264,
            child: PinInputTextField(
              pinLength: _pinLength,
              decoration: BoxLooseDecoration(
                strokeColorBuilder: PinListenColorBuilder(
                    AppColors.color_337eff, AppColors.colorC9cfe5),
                bgColorBuilder: FixedColorBuilder(AppColors.white),
                strokeWidth: 1,
                gapSpace: 24,
                obscureStyle: ObscureStyle(
                  isTextObscure: false,
                  //                          obscureText: '',
                ),
                //                        hintText: 'dsfs',
              ),
              controller: _pinEditingController,
              textInputAction: TextInputAction.go,
              enabled: true,
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
            child: CheckCodeWidget(),
          ),
        ],
      ),
    );
  }

  Container buildVerifyCodeTips() {
    return Container(
      margin: EdgeInsets.only(left: 30, top: 7, right: 30),
      child: Text(
        '验证码已经发送至 +86-${authModel.mobile}，请在下方输入验证码',
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
    return Strings.enterCheckCode;
  }

  void getCheckCodeServer() {
    authModel.verifyCode = _pinEditingController.text;
    Alog.d(tag:tag,
        content:
            'before getAuthCode server param: authModel = ${authModel.toString()}');
    var authRepo = AuthRepo();

    if (SceneType.login == authModel.sceneType) {
      var result =
          authRepo.loginByVerify(authModel.mobile!, authModel.verifyCode!);
      lifecycleExecuteUI(result).then((result) {
        if (result?.code == HttpCode.success) {
          NavUtils.pushNamedAndRemoveUntil(context, RouterName.homePage);
        } else {
          ErrorUtil.showError(context, HttpCode.getMsg(result?.msg));
        }
      });
    }
  }

  @override
  void dispose() {
    _pinEditingController.dispose();
    _tapPrivacy.dispose();
    _tapUserProtocol.dispose();
    super.dispose();
  }
}
