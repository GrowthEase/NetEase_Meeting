// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uikit/values/fonts.dart';
import 'package:uikit/values/strings.dart';
import 'package:nemeeting/arguments/auth_arguments.dart';
import 'package:nemeeting/widget/login_by_mobile_widget.dart';
import 'package:nemeeting/widget/login_by_password_widget.dart';
import 'package:uikit/values/colors.dart';
import 'package:event_bus/event_bus.dart';
import 'package:yunxin_meeting/meeting_uikit.dart';

class LoginRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends BaseState {
  bool _loginByMobile = true;
  late AuthArguments authModel;
  String? mobile;
  late StreamSubscription streamSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    authModel = ModalRoute.of(context)?.settings.arguments as AuthArguments;
  }

  @override
  void initState() {
    super.initState();
    streamSubscription = eventBus.on<MobileEvent>().listen((MobileEvent data) {
      mobile = data.mobile;
    });
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
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
          actions: <Widget>[
            TextButton(
              child: Text(
                _loginByMobile ? Strings.loginByPassword : Strings.loginByMobile,
                style: TextStyle(color: AppColors.black_333333, fontSize: 14.0, fontWeight: FontWeight.w400),
              ),
              onPressed: () {
                setState(() {
                  _loginByMobile = !_loginByMobile;
                });
              },
            )
          ],
        ),
        body: _loginByMobile ? LoginByMobileWidget(mobile ?? '') : LoginByPasswordWidget(mobile ?? ''));
  }
}

// class LoginModelProvider extends InheritedWidget {
//   final bool loginByMobile;
//
//   LoginModelProvider({required this.loginByMobile, required Widget child}) : super(child: child);
//
//   static LoginModelProvider of(BuildContext context) =>
//       context.dependOnInheritedWidgetOfExactType() as LoginModelProvider;
//
//   @override
//   bool updateShouldNotify(InheritedWidget oldWidget) {
//     return true;
//   }
// }

EventBus eventBus = EventBus();

class MobileEvent {
  String mobile;

  MobileEvent(this.mobile);
}
