// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/language/localizations.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/auth/password_utils.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/repo/corp_repo.dart';
import 'package:nemeeting/uikit/utils/nav_utils.dart';
import 'package:nemeeting/uikit/utils/router_name.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import 'package:nemeeting/utils/state_utils.dart';
import 'package:nemeeting/widget/meeting_text_field.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

class ModifyPasswordRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ModifyPasswordState();
  }
}

class ModifyPasswordState extends BaseState with MeetingAppLocalizationsMixin {
  final _oldPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  late final passwordTextListenable = Listenable.merge([
    _oldPasswordController,
    _passwordController,
    _passwordConfirmController
  ]);
  String oldPasswordErrorText = '';
  String newPasswordErrorText = '';

  void resetErrorText(_) {
    setState(() {
      oldPasswordErrorText = '';
      newPasswordErrorText = '';
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
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
              meetingAppLocalizations.settingModifyPassword,
              style: TextStyle(
                fontSize: 28.spMin,
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
              controller: _oldPasswordController,
              obscureText: true,
              hintText: meetingAppLocalizations.authEnterOldPassword,
              inputFormatters: PasswordUtils.passwordTextInputFormatters,
              onChanged: resetErrorText,
            ),
            SizedBox(
              height: 4.h,
            ),
            ListenableBuilder(
              listenable: passwordTextListenable,
              builder: (context, child) {
                return Text(
                  oldPasswordErrorText,
                  style: TextStyle(
                    fontSize: 12.spMin,
                    color: AppColors.colorF24957,
                  ),
                );
              },
            ),
            SizedBox(
              height: 20.h,
            ),
            MeetingTextField(
              height: 44.h,
              controller: _passwordController,
              obscureText: true,
              hintText: meetingAppLocalizations.settingEnterNewPasswordTips,
              inputFormatters: PasswordUtils.passwordTextInputFormatters,
              onChanged: resetErrorText,
            ),
            SizedBox(
              height: 4.h,
            ),
            ListenableBuilder(
              listenable: _passwordController,
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
                    fontSize: 12.spMin,
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
              obscureText: true,
              hintText: meetingAppLocalizations.settingEnterPasswordConfirm,
              inputFormatters: PasswordUtils.passwordTextInputFormatters,
              onChanged: resetErrorText,
            ),
            SizedBox(
              height: 4.h,
            ),
            ListenableBuilder(
              listenable: passwordTextListenable,
              builder: (context, child) {
                String errorText = newPasswordErrorText;
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
                    fontSize: 12.spMin,
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
                    text: meetingAppLocalizations.globalSure,
                    onTap: isButtonEnable ? save : null);
              },
            ),
            16.verticalSpace,
            Align(
              alignment: Alignment.center,
              child: Text(
                meetingAppLocalizations.settingModifyAndReLogin,
                style: TextStyle(
                  fontSize: 12.spMin,
                  color: AppColors.colorB6B9BE,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get isButtonEnable {
    return isValidOldPasswordFormat &&
        isValidPasswordFormat &&
        _passwordController.text == _passwordConfirmController.text;
  }

  // 旧的密码格式是否合法
  // 老版本可能没有约束密码格式，所以只要密码非空，就认为合法
  bool get isValidOldPasswordFormat {
    final text = _oldPasswordController.text;
    return text.isNotEmpty;
  }

  bool get isValidPasswordFormat {
    final text = _passwordController.text;
    return PasswordUtils.isValid(text);
  }

  void save() {
    doIfNetworkAvailable(() async {
      final oldPassword = _oldPasswordController.text;
      final newPassword = _passwordConfirmController.text;
      LoadingUtil.showLoading();
      final result = await CorpRepo.resetPassword(
        AuthManager().appKey!,
        oldPassword,
        newPassword,
        accountId: AuthManager().accountId,
      );
      if (!mounted) return;
      LoadingUtil.cancelLoading();
      if (result.code == HttpCode.success) {
        AuthManager().logout();
        ToastUtils.showToast(
            context, meetingAppLocalizations.settingModifySuccess,
            duration: const Duration(seconds: 1), onDismiss: () {
          if (!mounted) return;
          NavUtils.toEntrance(context);
        });
      } else {
        var errorMsg =
            result.msg ?? meetingAppLocalizations.settingModifyFailed;
        if (result.code == HttpCode.oldPasswordError) {
          errorMsg = meetingAppLocalizations.authOldPasswordError;
          setState(() {
            oldPasswordErrorText = errorMsg;
          });
        } else if (result.code == HttpCode.newPasswordIsSameToTheOld) {
          errorMsg = meetingAppLocalizations.settingPasswordSameToOld;
          setState(() {
            newPasswordErrorText = errorMsg;
          });
        }
        ToastUtils.showToast(context, errorMsg);
      }
    });
  }
}
