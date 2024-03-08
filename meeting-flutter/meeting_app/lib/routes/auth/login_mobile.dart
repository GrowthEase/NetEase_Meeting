// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import 'package:nemeeting/widget/login_by_mobile_widget.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

class LoginMobileRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginMobileState();
  }
}

class LoginMobileState extends BaseState {
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
      body: LoginByMobileWidget(),
    );
  }
}
