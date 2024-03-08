// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:nemeeting/language/localizations.dart';
import '../service/repo/auth_repo.dart';
import '../uikit/values/colors.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import 'package:nemeeting/constants.dart';

var countDownTime = 60;

///倒计时组建
class CheckCodeWidget extends StatefulWidget {
  final String appKey;
  final String mobile;

  CheckCodeWidget(this.appKey, this.mobile);

  @override
  State<StatefulWidget> createState() {
    return _CheckCodeState();
  }
}

class _CheckCodeState extends LifecycleBaseState<CheckCodeWidget>
    with MeetingAppLocalizationsMixin {
  static const _tag = 'CheckCodeWidget';
  Timer? _countDownTimer;
  String _countDownText = countDownTime.toString();
  bool _showCountDown = true;

  @override
  void initState() {
    super.initState();
    _countDown();
  }

  @override
  Widget build(BuildContext context) {
    final reSendSuf = meetingAppLocalizations.authResendCode('##time##');
    final resendTextList = reSendSuf.split('##');
    return Center(
        child: _showCountDown
            ? Text.rich(TextSpan(children: [
                for (int i = 0; i < resendTextList.length; i++)
                  resendTextList[i] == 'time'
                      ? TextSpan(
                          text: _countDownText,
                          style: TextStyle(color: AppColors.color_2953ff),
                        )
                      : TextSpan(
                          text: resendTextList[i],
                          style: TextStyle(
                            color: AppColors.black_333333,
                          ),
                        ),
              ]))
            : GestureDetector(
                child: Text(
                  meetingAppLocalizations.authResend,
                  style: TextStyle(color: AppColors.blue),
                ),
                onTap: () {
                  Alog.d(tag: _tag, content: '_tapGestureRecognizer onTap');
                  _getAuthCode();
                },
              ));
  }

  void _getAuthCode() {
    final mobile = widget.mobile;
    Alog.d(
        moduleName: Constants.moduleName,
        tag: toString(),
        content: 'Get check code mobile = $mobile');
    lifecycleExecuteUI(AuthRepo().getMobileCheckCode(widget.appKey, mobile));
    _countDown();
  }

  void _countDown() {
    _countDownTimer?.cancel();
    _countDownTimer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        if (countDownTime - t.tick > 0) {
          _countDownText = '${countDownTime - t.tick}s';
          _showCountDown = true;
        } else {
          _countDownText = meetingAppLocalizations.authGetCheckCode;
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
