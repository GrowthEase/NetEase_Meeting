// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:service/repo/auth_repo.dart';
import 'package:uikit/values/strings.dart';
import 'package:nemeeting/arguments/auth_arguments.dart';
import 'package:uikit/values/colors.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import 'package:yunxin_meeting/meeting_uikit.dart';
import 'package:nemeeting/constants.dart';

var countDownTime = 60;

///倒计时组建
class CheckCodeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CheckCodeState();
  }
}

class _CheckCodeState extends LifecycleBaseState<CheckCodeWidget> {
  static  const _tag = 'CheckCodeWidget';
  Timer? _countDownTimer;
  String _countDownText = countDownTime.toString();
  bool _showCountDown = true;
  late AuthArguments authModel;

  @override
  void initState() {
    super.initState();
    _countDown();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: _showCountDown
            ? Text.rich(TextSpan(children: [
                TextSpan(
                  text: _countDownText,
                  style: TextStyle(color: AppColors.color_2953ff),
                ),
                TextSpan(
                  text: Strings.reSendSuf,
                  style: TextStyle(
                    color: AppColors.black_333333,
                  ),
                ),
              ]))
            : GestureDetector(
                child: Text(
                  Strings.reSend,
                  style: TextStyle(color: AppColors.blue),
                ),
                onTap: () {
                  Alog.d(
                      tag: _tag,
                      content: '_tapGestureRecognizer onTap');
                  _getAuthCode();
                },
              ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    //var object = ModalRoute.of(context)?.settings.arguments;
    authModel = ModalRoute.of(context)?.settings.arguments as AuthArguments;
  }

  void _getAuthCode() {
    Alog.d(
        moduleName: Constants.moduleName,
        tag: toString(),
        content:
            'getAuthCode mobile = ${authModel.mobile}, sceneType = ${authModel.sceneType?.toString()}');
    if (authModel.mobile != null && authModel.sceneType != null) {
      var authRepo = AuthRepo();
      lifecycleExecuteUI(
          authRepo.getAuthCode(authModel.mobile!, authModel.sceneType!));
      _countDown();
    }
  }

  void _countDown() {
    _countDownTimer?.cancel();
    _countDownTimer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        if (countDownTime - t.tick > 0) {
          _countDownText = '${countDownTime - t.tick}s';
          _showCountDown = true;
        } else {
          _countDownText = Strings.getCheckCode;
          _countDownTimer?.cancel();
          _countDownTimer = null;
          _showCountDown = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _countDownTimer?.cancel();
    _countDownTimer = null;
    super.dispose();
  }
}
