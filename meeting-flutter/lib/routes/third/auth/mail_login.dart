// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:base/util/error.dart';
import 'package:base/util/textutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:service/client/http_code.dart';
import 'package:service/repo/auth_repo.dart';
import 'package:uikit/const/packages.dart';
import 'package:uikit/state/meeting_base_state.dart';
import 'package:uikit/utils/nav_utils.dart';
import 'package:uikit/utils/router_name.dart';
import 'package:uikit/values/asset_name.dart';
import 'package:uikit/values/borders.dart';
import 'package:uikit/values/colors.dart';
import 'package:uikit/values/fonts.dart';
import 'package:uikit/values/strings.dart';
import 'package:yunxin_meeting/meeting_uikit.dart';

class MailLoginRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MailLoginState();
  }
}

class MailLoginState extends MeetingBaseState {
  late TextEditingController _emailController;

  late TextEditingController _pwdController;

  bool _emailOk = false, _pwdOk = false;

  bool _pwdShow = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _pwdController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  @override
  Widget buildBody() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          buildIcon(),
          Container(
            margin: EdgeInsets.only(top: 43, left: 30, right: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [buildInputEmail(), SizedBox(height: 10), buildInputPwd(), buildAuth()],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIcon() {
    return Container(
      margin: EdgeInsets.only(top: 24),
      height: 56,
      child: Image.asset(
        AssetName.iconMail,
        package: Packages.uiKit,
        fit: BoxFit.none,
      ),
    );
  }

  @override
  String getTitle() {
    return '';
  }

  Widget buildInputEmail() {
    return Theme(
      data: ThemeData(hintColor: AppColors.greyDCDFE5),
      child: TextField(
        autofocus: true,
        style: TextStyle(color: AppColors.blue_337eff, fontSize: 17, decoration: TextDecoration.none),
        keyboardType: TextInputType.text,
        cursorColor: AppColors.blue_337eff,
        controller: _emailController,
        textAlign: TextAlign.left,
        keyboardAppearance: Brightness.light,
        onChanged: (value) {
          setState(() {
            _emailOk = !TextUtil.isEmpty(_emailController.text);
          });
        },
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.only(top: 11, bottom: 11),
            hintText: Strings.inputEmailHint,
            hintStyle: TextStyle(fontSize: 17, color: AppColors.greyB0B6BE),
            focusedBorder: UnderlineInputBorder(borderSide: Borders.textFieldBorder),
            focusedErrorBorder: UnderlineInputBorder(borderSide: Borders.textFieldBorder),
            errorBorder: UnderlineInputBorder(borderSide: Borders.textFieldBorder),
            suffixIcon: TextUtil.isEmpty(_emailController.text)
                ? null
                : ClearIconButton(
                    onPressed: () {
                      _emailController.clear();
                      setState(() {
                        _emailOk = false;
                      });
                    },
                  )),
      ),
    );
  }

  Widget buildInputPwd() {
    return Theme(
      data: ThemeData(hintColor: AppColors.greyDCDFE5),
      child: TextField(
        autofocus: false,
        style: TextStyle(color: AppColors.blue_337eff, fontSize: 17, decoration: TextDecoration.none),
        keyboardType: TextInputType.text,
        cursorColor: AppColors.blue_337eff,
        controller: _pwdController,
        textAlign: TextAlign.left,
        onChanged: (value) {
          setState(() {
            _pwdOk = !TextUtil.isEmpty(_pwdController.text);
          });
        },
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.only(top: 11, bottom: 11),
            hintText: Strings.inputEmailPwdHint,
            hintStyle: TextStyle(fontSize: 17, color: AppColors.greyB0B6BE),
            focusedBorder: UnderlineInputBorder(borderSide: Borders.textFieldBorder),
            focusedErrorBorder: UnderlineInputBorder(borderSide: Borders.textFieldBorder),
            errorBorder: UnderlineInputBorder(borderSide: Borders.textFieldBorder),
            suffixIcon: IconButton(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              padding: EdgeInsets.all(0),
              alignment: Alignment.centerRight,
              icon: Icon(_pwdShow ? IconFont.iconpassword_displayx : IconFont.iconpassword_hidex,
                  color: AppColors.blue_337eff),
              onPressed: () {
                setState(() {
                  _pwdShow = !_pwdShow;
                });
              },
            )),
        obscureText: !_pwdShow,
      ),
    );
  }

  Container buildAuth() {
    return Container(
      padding: EdgeInsets.only(top: 50),
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
                    color:  _pwdOk && _emailOk ? AppColors.blue_337eff : AppColors.blue_50_337eff, width: 0),
                borderRadius: BorderRadius.all(Radius.circular(25))))),

        onPressed: _pwdOk && _emailOk ? authLogin : null,
        child: Text(
          Strings.authAndLogin,
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void authLogin() {
    var loginResult = AuthRepo().loginByThird(_emailController.text, _pwdController.text);
    lifecycleExecuteUI(loginResult).then((result) {
      if (result == null) return;
      if (result.code == HttpCode.success) {
        NavUtils.pushNamedAndRemoveUntil(context, RouterName.homePage);
      } else {
        ErrorUtil.showError(context, HttpCode.getMsg(result.msg));
      }
    });
  }
}
