// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:base/util/error.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import 'package:base/util/textutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:service/client/http_code.dart';
import 'package:uikit/const/consts.dart';
import 'package:uikit/utils/nav_utils.dart';
import 'package:uikit/utils/router_name.dart';
import 'package:uikit/values/strings.dart';
import 'package:nemeeting/arguments/auth_arguments.dart';
import 'package:nemeeting/routes/auth/login.dart';
import 'package:nemeeting/constants.dart';
import 'package:service/repo/auth_repo.dart';
import 'package:service/config/scene_type.dart';
import 'package:uikit/values/colors.dart';
import 'package:yunxin_meeting/meeting_uikit.dart';

class LoginByMobileWidget extends StatefulWidget {
  final String mobile;

  LoginByMobileWidget(this.mobile);

  @override
  State<StatefulWidget> createState() {
    return LoginByMobileState(mobile);
  }
}

class LoginByMobileState extends LifecycleBaseState {
  final String mobile;
  late TextEditingController _mobileController;
  final FocusNode _focusNode = FocusNode();
  bool _mobileFocus = false;
  AuthArguments? authModel;
  bool _btnEnable = false;

  LoginByMobileState(this.mobile);

  @override
  void initState() {
    super.initState();
    _mobileController = TextEditingController();
    _focusNode.addListener(() {
      setState(() {
        _mobileFocus = _focusNode.hasFocus;
      });
    });
    _mobileController.addListener(() {
      var mobile = TextUtil.replaceAllBlank(_mobileController.text);
      eventBus.fire(MobileEvent(mobile));
    });
    _btnEnable = _mobileController.text.length >= mobileLength;
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var object = ModalRoute.of(context)?.settings.arguments;
    authModel = object is AuthArguments ? object : null;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_statements
    // LoginModelProvider.of(context).loginByMobile;
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
                    Strings.loginByMobile,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.black_222222,
                      fontWeight: FontWeight.w500,
                      fontSize: 28,
                    ),
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
                              //focusNode: _focusNode,
                              controller: _mobileController,
                              keyboardType: TextInputType.number,
                              cursorColor: AppColors.blue_337eff,
                              keyboardAppearance: Brightness.light,
                              inputFormatters: [
//                            WhitelistingTextInputFormatter(
//                                RegExp("[a-z,A-Z,0-9]")),
                                //限制只允许输入字母和数字
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'\d+|s')),
                                //限制只允许输入数字
                                LengthLimitingTextInputFormatter(
                                    mobileLength), //限制输入长度不超过13位
                              ],
                              decoration: InputDecoration(
                                  hintText: Strings.hintMobile,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.auto,
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                      fontSize: 17,
                                      color: AppColors.colorDCDFE5),
                                  suffixIcon:
                                      TextUtil.isEmpty(_mobileController.text)
                                          ? null
                                          : ClearIconButton(
                                              onPressed: () {
                                                _mobileController.clear();
                                                setState(() {
                                                  _btnEnable = false;
                                                });
                                              },
                                            )),
                              onSubmitted: (value) => getCheckCodeServer(),
                              onChanged: (value) {
                                setState(() {
                                  _btnEnable = value.length >= mobileLength;
                                });
                              },
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
                height: 50,
                margin: EdgeInsets.only(left: 30, top: 50, right: 30),
                child: ElevatedButton(
                  key: MeetingValueKey.getCheckCode,
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
                  onPressed: _btnEnable ? getCheckCodeServer : null,
                  child: Text(
                    Strings.getCheckCode,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ));
  }

  void getCheckCodeServer() {
    var mobile = TextUtil.replaceAllBlank(_mobileController.text);
    Alog.d(
        moduleName: Constants.moduleName,
        tag: toString(),
        content:
            'getAuthCode mobile = $mobile sceneType = login, authModel = ${authModel?.toString()}');
    var authRepo = AuthRepo();
    var loginResult = authRepo.getAuthCode(mobile, SceneType.login);
    lifecycleExecuteUI(loginResult).then((result) {
      if (result == null) return;
      authModel?.sceneType = SceneType.login;
      authModel?.mobile = mobile;
      if (result.code == HttpCode.success) {
        NavUtils.pushNamed(context, RouterName.checkMobile,
            arguments: authModel);
      } else {
        ErrorUtil.showError(context, HttpCode.getMsg(result.msg));
      }
    });
  }
}
