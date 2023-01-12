// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nemeeting/arguments/auth_arguments.dart';
import 'package:nemeeting/base/util/error.dart';
import 'package:nemeeting/base/util/text_util.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/config/app_config.dart';
import 'package:nemeeting/service/config/login_type.dart';
import 'package:nemeeting/service/model/login_info.dart';
import 'package:nemeeting/uikit/utils/nav_utils.dart';
import 'package:nemeeting/uikit/utils/router_name.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import 'package:nemeeting/uikit/values/strings.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

class AccountTokenLoginRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AccountTokenLoginRouteState();
  }
}

class AccountTokenLoginRouteState extends BaseState {
  late AuthArguments authModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    authModel = ModalRoute.of(context)?.settings.arguments as AuthArguments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          //title: Text(''),
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: IconButton(
            icon: const Icon(
              IconFont.iconyx_returnx,
              size: 18,
              color: AppColors.black_333333,
            ),
            onPressed: () {
              Navigator.maybePop(context);
            },
          ),
        ),
        body: LoginByAccountTokenWidget(),
    );
  }
}

class LoginByAccountTokenWidget extends StatefulWidget {

  LoginByAccountTokenWidget();

  @override
  State<StatefulWidget> createState() {
    return LoginByAccountTokenState();
  }
}

class LoginByAccountTokenState extends LifecycleBaseState {
  late TextEditingController _accountIdController;
  final TextEditingController _accountTokenController = TextEditingController();
  bool _tokenShow = false;
  bool _accountIdFocused = false;
  final FocusNode _focusNode = FocusNode();
  late VoidCallback focusCallback;

  bool _btnEnable = false;
  late String _inputAccount;
  String? _inputToken;

  @override
  void initState() {
    super.initState();
    _accountIdController = TextEditingController();
    // MaskedTextController(text: mobile, mask: '000 0000 0000');
    focusCallback = () {
      setState(() {
        _accountIdFocused = _focusNode.hasFocus;
      });
    };
    _focusNode.addListener(focusCallback);
  }

  @override
  void dispose() {
    _accountIdController.dispose();
    _accountTokenController.dispose();
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
                    Strings.login,
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
                child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topLeft,
                    children: <Widget>[
                      Row(children: <Widget>[
                        Container(
                          width: 250,
                          child: TextField(
                            focusNode: _focusNode,
                            controller: _accountIdController,
                            keyboardAppearance: Brightness.light,
                            decoration: InputDecoration.collapsed(
                                hintText: Strings.hintAccount,
                                hintStyle: TextStyle(
                                    fontSize: 17,
                                    color: AppColors.colorB6B9BE)),
                            onChanged: (value) {
                              _inputAccount = value;
                              setState(() {
                                _btnEnable = _inputAccount.length >= 3 &&
                                    !TextUtil.isEmpty(_inputToken);
                              });
                            },
                          ),
                        ),
                      ]),
                      Container(
                        margin: EdgeInsets.only(top: 35),
                        child: Divider(
                          thickness: 1,
                          color: _accountIdFocused
                              ? AppColors.blue_337eff
                              : AppColors.colorDCDFE5,
                        ),
                      ),
                    ]),
              ),
              Container(
                height: 44,
                margin: EdgeInsets.only(left: 30, top: 10, right: 30),
                child: TextField(
                  key: MeetingValueKey.hintPassword,
                  controller: _accountTokenController,
                  keyboardAppearance: Brightness.light,
                  cursorColor: AppColors.blue_337eff,
                  decoration: InputDecoration(
                      hintText: Strings.hintPassword,
                      hintStyle:
                      TextStyle(fontSize: 17, color: AppColors.colorB6B9BE),
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
                        key: MeetingValueKey.showPassword,
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        padding: EdgeInsets.all(0),
                        alignment: Alignment.centerRight,
                        icon: Icon(
                          _tokenShow
                              ? IconFont.iconpassword_displayx
                              : IconFont.iconpassword_hidex,
                          size: 20,
                          color: AppColors.color_3C3C43,
                        ),
                        onPressed: () {
                          setState(() {
                            _tokenShow = !_tokenShow;
                          });
                        },
                      )),
                  onChanged: (value) {
                    _inputToken = value;
                    setState(() {
                      _btnEnable = _inputAccount.length >= 3 &&
                          !TextUtil.isEmpty(_inputToken);
                    });
                  },
                  obscureText: !_tokenShow,
                  onSubmitted: (value) => loginServer(),
                ),
              ),
              Container(
                height: 50,
                margin: EdgeInsets.only(left: 30, top: 50, right: 30),
                child: ElevatedButton(
                  key: MeetingValueKey.login,
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.disabled)) {
                          return AppColors.blue_50_337eff;
                        }
                        return AppColors.blue_337eff;
                      }),
                      padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(vertical: 13)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          side: BorderSide(
                              color: _btnEnable
                                  ? AppColors.blue_337eff
                                  : AppColors.blue_50_337eff,
                              width: 0),
                          borderRadius:
                          BorderRadius.all(Radius.circular(25))))),
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
    final loginResult = AuthManager().loginMeetingKitWithToken(
        LoginType.token,
        LoginInfo(
          accountId: _accountIdController.value.text,
          accountToken: _accountTokenController.value.text,
          appKey: AppConfig().appKey,
        ));
    lifecycleExecuteUI(loginResult).then((result) {
      if (result?.code == NEMeetingErrorCode.success) {
        NavUtils.pushNamedAndRemoveUntil(context, RouterName.homePage);
      } else {
        ErrorUtil.showError(context, result?.msg  ?? 'login fail');
      }
    });
  }
}
