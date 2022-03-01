// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:base/util/error.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import 'package:base/util/textutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:nemeeting/utils/privacy_util.dart';
import 'package:service/client/http_code.dart';
import 'package:service/config/scene_type.dart';
import 'package:service/repo/auth_repo.dart';
import 'package:uikit/const/consts.dart';
import 'package:uikit/utils/nav_utils.dart';
import 'package:uikit/utils/router_name.dart';
import 'package:uikit/values/colors.dart';
import 'package:uikit/values/strings.dart';
import 'package:nemeeting/state/auth_base_state.dart';
import 'package:yunxin_meeting/meeting_uikit.dart';

class GetMobileCheckCodeRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GetMobileCheckCodeState();
  }
}

class GetMobileCheckCodeState extends AuthBaseState {
  final TextEditingController _mobileController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _mobileFocus = false;
  late VoidCallback focusCallback;
  bool _btnEnable = false;

  bool initFill = false;

  @override
  void initState() {
    super.initState();
    initFill = false;
    focusCallback = () {
      setState(() {
        _mobileFocus = _focusNode.hasFocus;
      });
    };
    _focusNode.addListener(focusCallback);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initFill) {
      initFill = true;
      if (authModel.mobile != null) {
        _mobileController.text = authModel.mobile!;
        _btnEnable = authModel.mobile!.length >= mobileLength;
      }
    }
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _focusNode.removeListener(focusCallback);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  bool getShowPrivate() {
    return true;
  }

  @override
  Widget getSubject() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
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
                    Text(
                      '+86',
                      style: TextStyle(fontSize: 17),
                    ),
                    Container(
                      height: 20,
                      child: VerticalDivider(color: AppColors.colorDCDFE5),
                    ),
                    Container(
                      width: 250,
                      child: TextField(
                        focusNode: _focusNode,
                        controller: _mobileController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
//                            WhitelistingTextInputFormatter(
//                                RegExp("[a-z,A-Z,0-9]")),
                          //限制只允许输入字母和数字
                          FilteringTextInputFormatter.allow(RegExp(r'\d+|s')),
                          //限制只允许输入数字
                          LengthLimitingTextInputFormatter(
                              mobileLength), //限制输入长度不超过11位
                        ],
                        decoration: InputDecoration.collapsed(
                            hintText: Strings.hintMobile,
                            hintStyle: TextStyle(
                                fontSize: 17, color: AppColors.colorDCDFE5)),
                        onChanged: (value) {
                          setState(() {
                            _btnEnable = value.length >= mobileLength;
                          });
                        },
                      ),
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
                  )
                ]),
          ),
          Container(
            height: 50,
            margin: EdgeInsets.only(left: 30, top: 50, right: 30),
            child: ElevatedButton(
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
                      borderRadius: BorderRadius.all(Radius.circular(25))))),
              onPressed: _btnEnable ? getCheckCodeServer : null,
              child: Text(
                Strings.nextStep,
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  String getSubTitle() {
    return Strings.checkMobile;
  }

  void getCheckCodeServer() {
    if (!PrivacyUtil.privateAgreementChecked) {
      ToastUtils.showToast(context, Strings.privacyCheckedTips);
      return;
    }
    authModel.mobile = TextUtil.replaceAllBlank(_mobileController.text);
    Alog.d(tag:tag,
        content:
            'before getAuthCode server param: authModel = ${authModel.toString()}');
    var authRepo = AuthRepo();
    var getCheckCodeResult =
        authRepo.getAuthCode(authModel.mobile!, authModel.sceneType!);
    lifecycleExecuteUI(getCheckCodeResult).then((result) {
      if (result?.code == HttpCode.success) {
        NavUtils.pushNamed(context, RouterName.checkMobile,
            arguments: authModel);
      } else {
        ErrorUtil.showError(context, HttpCode.getMsg(result?.msg));
      }
    });
  }
}
