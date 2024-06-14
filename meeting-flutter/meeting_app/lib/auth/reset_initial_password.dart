// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/auth/password_utils.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/repo/auth_repo.dart';
import 'package:nemeeting/state/auth_base_state.dart';
import 'package:nemeeting/uikit/utils/nav_utils.dart';
import 'package:nemeeting/uikit/utils/router_name.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import 'package:nemeeting/utils/state_utils.dart';
import 'package:nemeeting/widget/meeting_text_field.dart';
import 'package:netease_common/netease_common.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

import '../../language/localizations.dart';

class ResetPasswordRequest {
  final String appKey;
  final String account;
  final String initialPassword;
  final Future<NEResult<NEAccountInfo>> Function(String newPassword)?
      loginWithNewPassword;

  ResetPasswordRequest(
    this.appKey,
    this.account,
    this.initialPassword, {
    this.loginWithNewPassword,
  });
}

class ResetInitialPasswordRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ResetInitialPasswordState();
  }
}

class ResetInitialPasswordState extends AuthBaseState {
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
  String getSubTitle() {
    return getAppLocalizations().authResetInitialPasswordTitle;
  }

  @override
  Widget getSubject() {
    return Padding(
      padding: EdgeInsets.only(left: 30.w, right: 30.w, top: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 30.h,
          ),
          MeetingTextField(
            prefixIcon: Icon(
              IconFont.icon_lock,
              color: AppColors.color_CDCFD7,
            ),
            height: 44.h,
            controller: _passwordController,
            hintText: getAppLocalizations().settingEnterNewPasswordTips,
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
                getAppLocalizations().settingValidatorPwdTip,
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
            prefixIcon: Icon(
              IconFont.icon_lock,
              color: AppColors.color_CDCFD7,
            ),
            height: 44.h,
            controller: _passwordConfirmController,
            hintText: getAppLocalizations().settingEnterPasswordConfirm,
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
                    errorText = getAppLocalizations().settingValidatorPwdTip;
                  } else if (PasswordUtils.isValid(password1) &&
                      password1 != password2) {
                    errorText = getAppLocalizations().settingPasswordDifferent;
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
                  text: getAppLocalizations().globalSave,
                  onTap: isButtonEnable ? save : null);
            },
          ),
        ],
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
      final result =
          await NEMeetingKit.instance.getAccountService().resetPassword(
                _request!.account,
                newPassword,
                _request!.initialPassword,
              );
      if (!mounted) return;
      if (result.code == HttpCode.success) {
        if (_request!.loginWithNewPassword != null) {
          final loginResult = await AuthRepo().loginByPwd(_request!.appKey,
              () => _request!.loginWithNewPassword!.call(newPassword));
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
          NavUtils.toEntrance(context);
        }
      } else {
        LoadingUtil.cancelLoading();
        var errorMsg = result.msg ?? getAppLocalizations().settingModifyFailed;
        if (result.code == HttpCode.newPasswordIsSameToTheOld) {
          errorMsg = getAppLocalizations().settingPasswordSameToOld;
          setState(() {
            passwordErrorText = errorMsg;
          });
        }
        ToastUtils.showToast(context, errorMsg);
      }
    });
  }
}
