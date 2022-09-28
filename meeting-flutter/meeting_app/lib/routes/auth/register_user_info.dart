// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/base/util/error.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import 'package:nemeeting/base/util/stringutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nemeeting/widget/length_text_input_formatter.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/repo/auth_repo.dart';
import 'package:nemeeting/uikit/const/consts.dart';
import 'package:nemeeting/uikit/utils/nav_utils.dart';
import 'package:nemeeting/uikit/utils/router_name.dart';
import 'package:nemeeting/uikit/values/borders.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import 'package:nemeeting/uikit/values/strings.dart';
import 'package:nemeeting/uikit/values/styles.dart';
import 'package:nemeeting/state/auth_base_state.dart';

class RegisterUserInfoRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterUserInfoRouteState();
  }
}

class _RegisterUserInfoRouteState extends AuthBaseState<RegisterUserInfoRoute> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final bool _nameAutoFocus = true;
  bool _pwdShow = false;
  String? _errorNickTip;
  String? _errorPwdTip;
  bool _checkNickOk = false;
  bool _checkPasswordOk = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  @override
  Widget getSubject() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        buildNick(),
        buildPwd(),
        buildRegister(),
      ],
    );
  }

  Container buildRegister() {
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
                    color: _checkNickOk && _checkPasswordOk
                        ? AppColors.blue_337eff
                        : AppColors.blue_50_337eff,
                    width: 0),
                borderRadius: BorderRadius.all(Radius.circular(25))))),
        onPressed: _checkNickOk && _checkPasswordOk ? register : null,
        child: Text(
          Strings.register,
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Container buildPwd() {
    return Container(
      height: 70,
      margin: EdgeInsets.only(left: 30, right: 30),
      child: TextField(
          controller: _pwdController,
          autofocus: !_nameAutoFocus,
          inputFormatters: [
            LengthLimitingTextInputFormatter(pwdLengthMax),
            FilteringTextInputFormatter.allow(
                RegExp(StringUtil.regexLetterOrDigitalLimit)),
          ],
          decoration: InputDecoration(
              hintText: Strings.hintPassword,
              hintStyle: Styles.hintTextStyle,
              focusedBorder:
                  UnderlineInputBorder(borderSide: Borders.textFieldBorder),
              errorText: _errorPwdTip,
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: Borders.textFieldBorder,
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: Borders.textFieldBorder,
              ),
              errorStyle: Styles.errorTextStyle,
              suffixIcon: IconButton(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                padding: EdgeInsets.all(0),
                alignment: Alignment.centerRight,
                icon: Icon(
                    _pwdShow
                        ? IconFont.iconpassword_displayx
                        : IconFont.iconpassword_hidex,
                    color: AppColors.blue_337eff),
                onPressed: () {
                  setState(() {
                    _pwdShow = !_pwdShow;
                  });
                },
              )),
          obscureText: !_pwdShow,
          onChanged: (value) {
            setState(() {
              checkPassword();
            });
          }),
    );
  }

  Container buildNick() {
    return Container(
      height: 70,
      margin: EdgeInsets.only(left: 30, top: 24, right: 30),
      decoration: BoxDecoration(
        color: AppColors.primaryElement,
      ),
      child: TextField(
        autofocus: _nameAutoFocus,
        controller: _nameController,
        keyboardAppearance: Brightness.light,
        inputFormatters: [
          MeetingLengthLimitingTextInputFormatter(nickLengthMax),
        ],
        decoration: InputDecoration(
            hintText: Strings.hintNick,
            hintStyle: Styles.hintTextStyle,
            focusedBorder:
                UnderlineInputBorder(borderSide: Borders.textFieldBorder),
            errorText: _errorNickTip,
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: Borders.textFieldBorder,
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: Borders.textFieldBorder,
            ),
            errorStyle: Styles.errorTextStyle),
        onChanged: (value) {
          setState(() {
            checkNick();
          });
        },
      ),
    );
  }

  @override
  String getSubTitle() {
    return Strings.completeSelfInfo;
  }

  void register() {
    var authRepo = AuthRepo();
    var pwd = _pwdController.text;
    Alog.d(
        tag: tag,
        content:
            'register param: authmodel=${authModel.toString()}, nick=${_nameController.text}, pwd md5=${StringUtil.pwdMD5(pwd)}');
    if (authModel.mobile != null && authModel.verifyExchangeCode != null) {
      var registerResult = authRepo.register(authModel.mobile!,
          authModel.verifyExchangeCode!, _nameController.text, pwd);
      lifecycleExecuteUI(registerResult).then((result) {
        Alog.d(
            tag: tag,
            content: 'after register server resultCode = ${result?.code}');
        if (result?.code == HttpCode.success) {
          NavUtils.pushNamedAndRemoveUntil(context, RouterName.homePage);
        } else {
          ErrorUtil.showError(context, HttpCode.getMsg(result?.msg));
        }
      });
    }
  }

  void checkNick() {
    _checkNickOk = _checkNick();
  }

  void checkPassword() {
    _checkPasswordOk = _checkPassword();
  }

  bool _checkPassword() {
    var pwdText = _pwdController.text;
    var pwdOk = StringUtil.isLetterOrDigital(pwdText) &&
        pwdText.length >= pwdLengthMin &&
        pwdText.length <= pwdLengthMax;
    if (pwdOk) {
      _errorPwdTip = null;
    } else {
      _errorPwdTip = Strings.validatorPwdTip;
    }
    return pwdOk;
  }

  bool _checkNick() {
    var nameText = _nameController.text;
    var nickOk = StringUtil.isLetterOrDigitalOrZh(nameText) &&
        nameText.isNotEmpty &&
        nameText.length <= nickLengthMax;
    if (nickOk) {
      _errorNickTip = null;
    } else {
      _errorNickTip = Strings.validatorNickTip;
    }

    return nickOk;
  }
}
