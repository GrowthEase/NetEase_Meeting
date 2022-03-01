// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:base/util/error.dart';
import 'package:base/util/stringutil.dart';
import 'package:base/util/textutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:service/client/http_code.dart';
import 'package:service/repo/auth_repo.dart';
import 'package:uikit/const/consts.dart';
import 'package:uikit/utils/nav_utils.dart';
import 'package:uikit/utils/router_name.dart';
import 'package:uikit/values/borders.dart';
import 'package:uikit/values/colors.dart';
import 'package:uikit/values/fonts.dart';
import 'package:uikit/values/strings.dart';
import 'package:uikit/values/styles.dart';
import 'package:nemeeting/state/auth_base_state.dart';
import 'package:yunxin_meeting/meeting_uikit.dart';

class PasswordVerifyRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PasswordVerifyRouteState();
  }
}

class _PasswordVerifyRouteState extends AuthBaseState<PasswordVerifyRoute> {
  final TextEditingController _newPwdController =  TextEditingController();
  final TextEditingController _againNewPwdController =  TextEditingController();
  final bool _nameAutoFocus = true;
  bool _pwdShow = false;
  bool _againPwdShow = false;
  String? _errorPwdTip;
  String? _errorPwdAgainTip;
  bool _btnEnable = false;
  final FocusNode _pwdFocusNode =  FocusNode();
  final FocusNode _againPwdFocusNode =  FocusNode();

  @override
  void initState() {
    super.initState();
    _pwdFocusNode.addListener(() {
      setState(() {
        _checkPassword();
      });
    });
    _againPwdFocusNode.addListener(() {
      setState(() {
        _checkAgainPassword();
      });
    });
  }

  @override
  void dispose() {
    _newPwdController.dispose();
    _againNewPwdController.dispose();
    _pwdFocusNode.dispose();
    _againPwdFocusNode.dispose();
    super.dispose();
  }

  @override
  String getSubTitle() {
    return Strings.modifyPassword;
  }

  @override
  Widget getSubject() {
    return Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      Container(
        height: 72,
        margin: EdgeInsets.only(left: 30, top: 24, right: 30),
        decoration: BoxDecoration(
          color: AppColors.primaryElement,
        ),
        child: TextField(
          key: MeetingValueKey.hintNewPassword,
          autofocus: _nameAutoFocus,
          controller: _newPwdController,
          keyboardAppearance: Brightness.light,
          focusNode: _pwdFocusNode,
          inputFormatters: [
            LengthLimitingTextInputFormatter(pwdLengthMax),
            FilteringTextInputFormatter.allow(RegExp(StringUtil.regexLetterOrDigitalLimit)),
          ],
          decoration: InputDecoration(
              hintText: Strings.hintNewPassword,
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                color: AppColors.blue_337eff,
                width: 1,
              )),
              errorText: _errorPwdTip,
              focusColor: AppColors.blue_337eff,
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: Borders.textFieldBorder,
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: Borders.textFieldBorder,
              ),
              errorStyle: Styles.errorTextStyle,
              suffixIcon: IconButton(
                key: MeetingValueKey.clearHintNewPasswordInput,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                padding: EdgeInsets.all(0),
                alignment: Alignment.centerRight,
                icon: Icon(_pwdShow ? IconFont.iconpassword_displayx : IconFont.iconpassword_hidex, color: AppColors.black),
                onPressed: () {
                  setState(() {
                    _pwdShow = !_pwdShow;
                  });
                },
              )),
          onChanged: (value) {
            setState(() {
              _checkButtonEnable();
            });
          },
          obscureText: !_pwdShow,
        ),
      ),
      Container(
        height: 72,
        margin: EdgeInsets.only(left: 30, right: 30),
        child: TextField(
          key: MeetingValueKey.hintConfirmPassword,
          controller: _againNewPwdController,
          autofocus: !_nameAutoFocus,
          focusNode: _againPwdFocusNode,
          keyboardAppearance: Brightness.light,
          inputFormatters: [
            LengthLimitingTextInputFormatter(pwdLengthMax),
            FilteringTextInputFormatter.allow(RegExp(StringUtil.regexLetterOrDigitalLimit)),
          ],
          decoration: InputDecoration(
              hintText: Strings.hintConfirmPassword,
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                color: AppColors.blue_337eff,
                width: 1,
              )),
              errorText: _errorPwdAgainTip,
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: Borders.textFieldBorder,
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: Borders.textFieldBorder,
              ),
              errorStyle: Styles.errorTextStyle,
              suffixIcon: IconButton(
                key: MeetingValueKey.clearHintConfirmPasswordInput,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                padding: EdgeInsets.all(0),
                alignment: Alignment.centerRight,
                icon: Icon(_againPwdShow ? IconFont.iconpassword_displayx : IconFont.iconpassword_hidex, color: AppColors.blue_337eff),
                onPressed: () {
                  setState(() {
                    _againPwdShow = !_againPwdShow;
                  });
                },
              )),
          obscureText: !_againPwdShow,
          onChanged: (value) {
            setState(() {
              _checkButtonEnable();
            });
          },
        ),
      ),
      Container(
        height: 50,
        margin: EdgeInsets.only(left: 30, top: 24, right: 30),
        child: ElevatedButton(
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
                      color: _btnEnable ? AppColors.blue_337eff : AppColors.blue_50_337eff, width: 0),
                  borderRadius: BorderRadius.all(Radius.circular(25))))),
          onPressed: _btnEnable ? modifyPwdServer : null,
          child: Text(
            Strings.done,
            style: TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ]));
  }

  void modifyPwdServer() {
    if (!_checkParam()) {
      _newPwdController.clear();
      _againNewPwdController.clear();
      _pwdFocusNode.requestFocus();
      setState(() {
        _checkButtonEnable();
      });
      return;
    }

    var _password = _newPwdController.text;

    var authRepo = AuthRepo();
    var modifyResult = authModel.verifyExchangeCode == null
        ? authRepo.passwordResetAfterLogin(_password)
        : authRepo.passwordResetByMobileCode(
            authModel.mobile!, _password, authModel.verifyExchangeCode!);
    lifecycleExecuteUI(modifyResult).then((result) {
      if (result == null) return;
      if (result.code == HttpCode.success) {
        NavUtils.pushNamedAndRemoveUntil(context, RouterName.entrance);
      } else {
        ToastUtils.showToast(context, HttpCode.getMsg(result.msg));
      }
    });
  }

  bool _checkPassword() {
    var _password = _newPwdController.text;
    var pwdOK = !TextUtil.isEmpty(_password) &&
        StringUtil.isLetterOrDigital(_password) &&
        _password.length >= pwdLengthMin &&
        _password.length <= pwdLengthMax;
    if (pwdOK) {
      _errorPwdTip = null;
    } else {
      _errorPwdTip = Strings.validatorPwdTip;
    }
    return pwdOK;
  }

  bool _checkAgainPassword() {
    var _againPassword = _againNewPwdController.text;
    var pwdOK = !TextUtil.isEmpty(_againPassword) &&
        StringUtil.isLetterOrDigital(_againPassword) &&
        _againPassword.length >= pwdLengthMin &&
        _againPassword.length <= pwdLengthMax;
    if (pwdOK) {
      _errorPwdAgainTip = null;
    } else {
      _errorPwdAgainTip = Strings.validatorPwdTip;
    }
    return pwdOK;
  }

  bool _checkParam() {
    var _password = _newPwdController.text;
    var _againPassword = _againNewPwdController.text;
    if (_password != _againPassword) {
      ErrorUtil.showError(context, Strings.passwordDifferent);
      return false;
    }

    var pwdOk = _checkPassword() && _checkAgainPassword();
    setState(() {
      if (pwdOk) {
        _errorPwdTip = null;
      } else {
        ErrorUtil.showError(context, Strings.passwordFormatError);
        _errorPwdTip = Strings.validatorPwdTip;
      }
    });

    return pwdOk;
  }

  void _checkButtonEnable() {
    var _password = _newPwdController.text;
    var _againPassword = _againNewPwdController.text;
    _btnEnable = (_password.isNotEmpty && _againPassword.isNotEmpty);
  }
}
