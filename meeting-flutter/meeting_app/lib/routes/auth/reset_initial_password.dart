// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/auth/password_utils.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/config/login_type.dart';
import 'package:nemeeting/service/repo/auth_repo.dart';
import 'package:nemeeting/service/repo/corp_repo.dart';
import 'package:nemeeting/uikit/utils/nav_utils.dart';
import 'package:nemeeting/uikit/utils/router_name.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import 'package:nemeeting/utils/state_utils.dart';
import 'package:nemeeting/widget/meeting_text_field.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

import '../../language/localizations.dart';

class ResetPasswordRequest {
  final String appKey;
  final String account;
  final String initialPassword;
  final bool resetToLogin;

  ResetPasswordRequest(
    this.appKey,
    this.account,
    this.initialPassword, {
    this.resetToLogin = false,
  });
}

class ResetInitialPasswordRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ResetInitialPasswordState();
  }
}

class ResetInitialPasswordState extends BaseState
    with MeetingAppLocalizationsMixin {
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  late final passwordTextListenable =
      Listenable.merge([_passwordController, _passwordConfirmController]);
  ResetPasswordRequest? _request;
  String passwordErrorText = '';

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_request == null) {
      _request =
          ModalRoute.of(context)!.settings.arguments as ResetPasswordRequest;
    }
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
      body: Padding(
        padding: EdgeInsets.only(left: 30.w, right: 30.w, top: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meetingAppLocalizations.authResetInitialPasswordTitle,
              style: TextStyle(
                fontSize: 28.sp,
                color: AppColors.black_222222,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: 25.h,
            ),
            MeetingTextField(
              height: 44.h,
              controller: _passwordController,
              hintText: meetingAppLocalizations.settingEnterNewPasswordTips,
              obscureText: true,
              inputFormatters: PasswordUtils.passwordTextInputFormatters,
              onChanged: (_) => passwordErrorText = '',
            ),
            SizedBox(
              height: 4.h,
            ),
            ListenableBuilder(
              listenable: passwordTextListenable,
              builder: (context, child) {
                final password = _passwordController.text;
                final color = password == ''
                    ? AppColors.color_999999
                    : PasswordUtils.isLengthValid(password) &&
                            !isValidPasswordFormat
                        ? AppColors.colorF24957
                        : AppColors.color_337eff;
                return Text(
                  meetingAppLocalizations.settingValidatorPwdTip,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: color,
                  ),
                );
              },
            ),
            SizedBox(
              height: 20.h,
            ),
            MeetingTextField(
              height: 44.h,
              controller: _passwordConfirmController,
              hintText: meetingAppLocalizations.settingEnterPasswordConfirm,
              obscureText: true,
              inputFormatters: PasswordUtils.passwordTextInputFormatters,
              onChanged: (_) => passwordErrorText = '',
            ),
            SizedBox(
              height: 4.h,
            ),
            ListenableBuilder(
              listenable: passwordTextListenable,
              builder: (context, child) {
                String errorText = passwordErrorText;
                if (errorText.isEmpty) {
                  final password1 = _passwordController.text;
                  final password2 = _passwordConfirmController.text;
                  if (PasswordUtils.isLengthValid(password2)) {
                    if (!PasswordUtils.isValid(password2)) {
                      errorText =
                          meetingAppLocalizations.settingValidatorPwdTip;
                    } else if (PasswordUtils.isValid(password1) &&
                        password1 != password2) {
                      errorText =
                          meetingAppLocalizations.settingPasswordDifferent;
                    }
                  }
                }
                return Text(
                  errorText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.colorF24957,
                  ),
                );
              },
            ),
            SizedBox(
              height: 34.h,
            ),
            ListenableBuilder(
              listenable: passwordTextListenable,
              builder: (context, child) {
                return MeetingActionButton(
                    text: meetingAppLocalizations.globalSave,
                    onTap: isButtonEnable ? save : null);
              },
            ),
          ],
        ),
      ),
    );
  }

  bool get isButtonEnable {
    return isValidPasswordFormat && isPasswordTheSame;
  }

  bool get isValidPasswordFormat {
    final text = _passwordController.text;
    return PasswordUtils.isValid(text);
  }

  bool get isPasswordTheSame {
    return _passwordConfirmController.text == _passwordController.text;
  }

  void save() {
    doIfNetworkAvailable(() async {
      final newPassword = _passwordConfirmController.text;
      LoadingUtil.showLoading();
      final result = await CorpRepo.resetPassword(
        _request!.appKey,
        _request!.initialPassword,
        newPassword,
        account: _request!.account,
      );
      if (!mounted) return;
      if (result.code == HttpCode.success) {
        if (_request!.resetToLogin) {
          final loginResult = await AuthRepo().loginByToken(
              LoginType.password,
              result.data!.accountId,
              result.data!.accountToken,
              _request!.appKey);
          if (!mounted) return;
          LoadingUtil.cancelLoading();
          if (loginResult.isSuccess()) {
            NavUtils.pushNamedAndRemoveUntil(context, RouterName.homePage);
          } else if (loginResult.msg != null) {
            ToastUtils.showToast(context, loginResult.msg);
          }
        } else {
          LoadingUtil.cancelLoading();
          AuthManager().logout();
          NavUtils.pushNamedAndRemoveUntil(context, RouterName.entrance);
        }
      } else {
        LoadingUtil.cancelLoading();
        var errorMsg =
            result.msg ?? meetingAppLocalizations.settingModifyFailed;
        if (result.code == HttpCode.newPasswordIsSameToTheOld) {
          errorMsg = meetingAppLocalizations.settingPasswordSameToOld;
          setState(() {
            passwordErrorText = errorMsg;
          });
        }
        ToastUtils.showToast(context, errorMsg);
      }
    });
  }
}
