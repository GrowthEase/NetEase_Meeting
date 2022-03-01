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
import 'package:service/config/scene_type.dart';
import 'package:service/repo/auth_repo.dart';
import 'package:uikit/utils/nav_utils.dart';
import 'package:uikit/utils/router_name.dart';
import 'package:uikit/values/colors.dart';
import 'package:uikit/values/fonts.dart';
import 'package:uikit/values/strings.dart';
import 'package:nemeeting/arguments/auth_arguments.dart';
import 'package:uikit/const/consts.dart';
import 'package:nemeeting/routes/auth/login.dart';
import 'package:yunxin_meeting/meeting_uikit.dart';

class LoginByPasswordWidget extends StatefulWidget {
  final String mobile;

  LoginByPasswordWidget(this.mobile);

  @override
  State<StatefulWidget> createState() {
    return LoginByPasswordState(mobile);
  }
}

class LoginByPasswordState extends LifecycleBaseState {
  final String mobile;
  late TextEditingController _phoneController;
  final TextEditingController _pwdController = TextEditingController();
  final bool _nameAutoFocus = true;
  bool _pwdShow = false;
  bool _mobileFocus = false;
  final FocusNode _focusNode = FocusNode();
  late VoidCallback focusCallback;

  bool _btnEnable = false;
  late String _inputMobile;
  String? _inputPwd;

  LoginByPasswordState(this.mobile);

  @override
  void initState() {
    super.initState();
    _inputMobile = mobile;
    _phoneController = TextEditingController();
    focusCallback = () {
      setState(() {
        _mobileFocus = _focusNode.hasFocus;
      });
    };
    _focusNode.addListener(focusCallback);

    _phoneController.addListener(() {
      var mobile = TextUtil.replaceAllBlank(_phoneController.text);
      eventBus.fire(MobileEvent(mobile));
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pwdController.dispose();
    _focusNode.removeListener(focusCallback);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: EdgeInsets.only(left: 30, top: 16),
                  child: Text(
                    Strings.loginByPassword,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.black_222222,
                      fontWeight: FontWeight.w500,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
              Container(
                height: 50,
                margin: EdgeInsets.only(left: 30, top: 24, right: 30),
                decoration: BoxDecoration(
                  color: AppColors.primaryElement,
                ),
                child: Stack(clipBehavior: Clip.none, alignment: Alignment.topLeft, children: <Widget>[
                  Row(children: <Widget>[
                    Text(
                      '+86',
                      style: TextStyle(fontSize: 17),
                    ),
                    Container(
                      height: 20,
                      child: VerticalDivider(color: AppColors.colorB6B9BE),
                    ),
                    Container(
                      width: 250,
                      child: TextField(
                        key: MeetingValueKey.hintMobile,
                        focusNode: _focusNode,
                        controller: _phoneController,
                        keyboardAppearance: Brightness.light,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
//                            WhitelistingTextInputFormatter(
//                                RegExp("[a-z,A-Z,0-9]")),
                          //限制只允许输入字母和数字
                          FilteringTextInputFormatter.allow(RegExp(r'\d+|s')),
                          //限制只允许输入数字
                          LengthLimitingTextInputFormatter(mobileLength), //限制输入长度不超过13位
                        ],
                        decoration: InputDecoration.collapsed(
                            hintText: Strings.hintMobile,
                            hintStyle: TextStyle(fontSize: 17, color: AppColors.colorB6B9BE)),
                        onChanged: (value) {
                          _inputMobile = value;
                          setState(() {
                            _btnEnable = _inputMobile.length >= mobileLength && !TextUtil.isEmpty(_inputPwd);
                          });
                        },
                      ),
                    ),
                  ]),
                  Container(
                    margin: EdgeInsets.only(top: 35),
                    child: Divider(
                      thickness: 1,
                      color: _mobileFocus ? AppColors.blue_337eff : AppColors.colorDCDFE5,
                    ),
                  ),
                ]),
              ),
              Container(
                height: 44,
                margin: EdgeInsets.only(left: 30, top: 10, right: 30),
                child: TextField(
                  key: MeetingValueKey.hintPassword,
                  controller: _pwdController,
                  autofocus: !_nameAutoFocus,
                  keyboardAppearance: Brightness.light,
                  cursorColor: AppColors.blue_337eff,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(pwdLengthMax),
                    FilteringTextInputFormatter.allow(RegExp(StringUtil.regexLetterOrDigitalLimit)),
                  ],
                  decoration: InputDecoration(
                      hintText: Strings.hintPassword,
                      hintStyle: TextStyle(fontSize: 17, color: AppColors.colorB6B9BE),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: AppColors.colorDCDFE5,
                        width: 1,
                      )),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: AppColors.blue_337eff,
                        width: 1,
                      )),
                      suffixIcon: IconButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        padding: EdgeInsets.all(0),
                        alignment: Alignment.centerRight,
                        icon: Icon(
                          _pwdShow ? IconFont.iconpassword_displayx : IconFont.iconpassword_hidex,
                          size: 20,
                          color: AppColors.color_3C3C43,
                        ),
                        onPressed: () {
                          setState(() {
                            _pwdShow = !_pwdShow;
                          });
                        },
                      )),
                  onChanged: (value) {
                    _inputPwd = value;
                    setState(() {
                      _btnEnable = _inputMobile.length >= mobileLength && !TextUtil.isEmpty(_inputPwd);
                    });
                  },
                  obscureText: !_pwdShow,
                  onSubmitted: (value) => loginServer(),
                ),
              ),
              Container(
                height: 50,
                margin: EdgeInsets.only(left: 30, top: 50, right: 30),
                child: ElevatedButton(
                  key: MeetingValueKey.login,
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
                  onPressed: _btnEnable ? loginServer : null,
                  child: Text(
                    Strings.login,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void loginServer() {
    var mobile = TextUtil.replaceAllBlank(_phoneController.text);
    var loginResult = AuthRepo().loginByPwd(mobile, _pwdController.text);
    lifecycleExecuteUI(loginResult).then((result) {
      if (result?.code == HttpCode.success) {
        NavUtils.pushNamedAndRemoveUntil(context, RouterName.homePage);
      } else {
        ErrorUtil.showError(context, HttpCode.getMsg(result?.msg));
      }
    });
  }
}
