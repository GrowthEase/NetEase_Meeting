// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:nemeeting/auth/verify_mobile_check_code.dart';
import 'package:nemeeting/language/localizations.dart';
import 'package:nemeeting/state/auth_base_state.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import 'package:nemeeting/base/util/error.dart';
import 'package:nemeeting/base/util/text_util.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/config/app_config.dart';
import 'package:nemeeting/service/repo/auth_repo.dart';
import 'package:nemeeting/widget/ne_widget.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:nemeeting/uikit/const/consts.dart';
import 'package:nemeeting/uikit/utils/nav_utils.dart';
import 'package:nemeeting/uikit/utils/router_name.dart';
import 'package:nemeeting/constants.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class LoginMobileRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginMobileState();
  }
}

class LoginMobileState extends AuthBaseState {
  static const String TAG = 'LoginByMobileState';
  late final appKey = AppConfig().appKey;
  late String mobile;
  late TextEditingController _mobileController;
  late MaskTextInputFormatter _mobileFormatter;
  final FocusNode _focusNode = FocusNode();
  bool _mobileFocus = false;
  bool _btnEnable = false;

  @override
  void initState() {
    super.initState();
    mobile = '';
    _mobileFormatter = MaskTextInputFormatter(
        mask: '### #### ####', filter: {"#": RegExp(r'[0-9]')});
    _mobileController = TextEditingController(text: mobile);
    _focusNode.addListener(() {
      setState(() {
        _mobileFocus = _focusNode.hasFocus;
      });
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
  Widget getSubject() {
    return NEGestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
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
                              focusNode: _focusNode,
                              controller: _mobileController,
                              keyboardType: TextInputType.number,
                              cursorColor: AppColors.blue_337eff,
                              keyboardAppearance: Brightness.light,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(mobileLength),
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
                                  suffixIcon: !_focusNode.hasFocus ||
                                          TextUtil.isEmpty(
                                              _mobileController.text)
                                      ? null
                                      : ClearIconButton(
                                          onPressed: () {
                                            _mobileController.clear();
                                            setState(() {
                                              _btnEnable = false;
                                            });
                                          },
                                        )),
                              onSubmitted: (value) {
                                if (appKey?.isNotEmpty ?? false) {
                                  getCheckCodeServer(appKey!);
                                } else {
                                  Alog.e(tag: TAG, content: 'appKey is empty');
                                }
                              },
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
                height: 48,
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
                          borderRadius: BorderRadius.all(Radius.circular(8))))),
                  onPressed: () {
                    if (_btnEnable) {
                      if (appKey?.isNotEmpty ?? false) {
                        getCheckCodeServer(appKey!);
                      } else {
                        Alog.e(tag: TAG, content: 'appKey is empty');
                      }
                    }
                  },
                  child: Text(
                    getAppLocalizations().authGetCheckCode,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ));
  }

  void getCheckCodeServer(String appKey) {
    final mobile = TextUtil.replaceAllBlank(_mobileController.text);

    Alog.d(
        moduleName: Constants.moduleName,
        tag: toString(),
        content: 'Get check code: mobile = $mobile');
    var loginResult = AuthRepo().getMobileCheckCode(appKey, mobile);
    lifecycleExecuteUI(loginResult).then((result) {
      if (result == null) return;
      if (result.code == HttpCode.success) {
        NavUtils.pushNamed(context, RouterName.verifyMobileCheckCode,
            arguments: VerifyMobileCheckCodeArguments(appKey, mobile));
      } else if (result.code == HttpCode.phoneErrorTip) {
        ErrorUtil.showError(context, getAppLocalizations().authPhoneErrorTip);
      } else {
        ErrorUtil.showError(context, HttpCode.getMsg(result.msg));
      }
    });
  }

  @override
  String getSubTitle() {
    return getAppLocalizations().authLoginByMobile;
  }
}
