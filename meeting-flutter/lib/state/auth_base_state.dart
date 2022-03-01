// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/utils/privacy_util.dart';
import 'package:uikit/state/meeting_base_state.dart';
import 'package:nemeeting/arguments/auth_arguments.dart';
import 'package:uikit/values/colors.dart';

abstract class AuthBaseState<T extends StatefulWidget> extends MeetingBaseState<T> {
  late AuthArguments authModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    authModel = ModalRoute.of(context)?.settings.arguments as AuthArguments;
  }

  @override
  Widget buildBody() {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: AppColors.white,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: EdgeInsets.only(left: 30, top: 16),
                child: Text(
                  getSubTitle(),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColors.black_222222,
                    fontWeight: FontWeight.w500,
                    fontSize: 28,
                  ),
                ),
              ),
            ),
            getSubject(),
            Spacer(),
            if(getShowPrivate())
            PrivacyUtil.protocolTips(context),
          ]),
        ));
  }

  @override
  String getTitle() {
    return '';
  }

  String getSubTitle();

  Widget getSubject();

  /// 默认子类页面隐藏私有协议，需要显示的设置
  bool getShowPrivate(){
    return false;
  }
}
