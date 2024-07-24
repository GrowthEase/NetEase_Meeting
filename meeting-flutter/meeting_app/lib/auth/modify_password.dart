// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/language/localizations.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/auth/password_utils.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/uikit/state/meeting_base_state.dart';
import 'package:nemeeting/uikit/utils/nav_utils.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/utils/state_utils.dart';
import 'package:nemeeting/widget/meeting_text_field.dart';
import 'package:nemeeting/widget/ne_widget.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';

class ModifyPasswordRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ModifyPasswordState();
  }
}

class ModifyPasswordState extends AppBaseState {
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
  String getTitle() {
    return getAppLocalizations().settingModifyPassword;
  }

  @override
  Widget buildBody() {
    return NEGestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MeetingCard(children: [
            buildOldPassword(),
          ]),
          MeetingCard(children: [
            buildNewPassword(),
            buildNewPasswordAgain(),
          ]),
          SizedBox(
            height: 34.h,
          ),
          Container(
            padding: EdgeInsets.only(left: 16.w, right: 16.w),
            child: ListenableBuilder(
              listenable: passwordTextListenable,
              builder: (context, child) {
                return MeetingActionButton(
                    text: getAppLocalizations().globalSure,
                    onTap: isButtonEnable ? save : null);
              },
            ),
          ),
          16.verticalSpace,
          Align(
            alignment: Alignment.center,
            child: Text(
              getAppLocalizations().settingModifyAndReLogin,
              style: TextStyle(
                fontSize: 12.spMin,
                color: AppColors.color_8D90A0,
              ),
            ),
          ),
        ],
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

  Widget buildOldPassword() {
    return buildItem(
      getAppLocalizations().oldPassword,
      _oldPasswordController,
      getAppLocalizations().authEnterOldPassword,
      ListenableBuilder(
        listenable: passwordTextListenable,
        builder: (context, child) {
          return oldPasswordErrorText.isNotEmpty
              ? Text(
                  oldPasswordErrorText,
                  style: TextStyle(
                    fontSize: 12.spMin,
                    color: AppColors.colorF24957,
                  ),
                )
              : Container();
        },
      ),
      null,
    );
  }

  Widget buildNewPassword() {
    return buildItem(
      getAppLocalizations().newPassword,
      _passwordController,
      getAppLocalizations().settingEnterNewPasswordTips,
      null,
      null,
    );
  }

  Widget buildNewPasswordAgain() {
    return buildItem(
        getAppLocalizations().confirmPassword,
        _passwordConfirmController,
        getAppLocalizations().settingEnterPasswordConfirm,
        ListenableBuilder(
          listenable: passwordTextListenable,
          builder: (context, child) {
            String errorText = '';
            final password1 = _passwordController.text;
            final password2 = _passwordConfirmController.text;
            if (password1.isNotEmpty && !PasswordUtils.isValid(password1)) {
              errorText = getAppLocalizations().settingValidatorPwdTip;
            } else if (password2.isNotEmpty &&
                !PasswordUtils.isValid(password2)) {
              errorText = getAppLocalizations().settingValidatorPwdTip;
            }
            return errorText.isNotEmpty
                ? Text(
                    errorText,
                    style: TextStyle(
                      fontSize: 12.spMin,
                      color: (_passwordController.text.isEmpty &&
                                  _passwordController.text.isEmpty) ||
                              isPasswordValid()
                          ? AppColors.color_8D90A0
                          : AppColors.color_F51D45,
                    ),
                  )
                : Container();
          },
        ),
        ListenableBuilder(
          listenable: passwordTextListenable,
          builder: (context, child) {
            String errorText = '';
            final password1 = _passwordController.text;
            final password2 = _passwordConfirmController.text;
            if (password1.isNotEmpty &&
                password2.isNotEmpty &&
                password1 != password2) {
              errorText = getAppLocalizations().settingPasswordDifferent;
            }
            return errorText.isNotEmpty
                ? Text(
                    errorText,
                    style: TextStyle(
                      fontSize: 12.spMin,
                      color: (password1.isNotEmpty &&
                                  password2.isNotEmpty &&
                                  password1 != password2) ||
                              isPasswordValid()
                          ? AppColors.color_F51D45
                          : AppColors.color_8D90A0,
                    ),
                  )
                : Container();
          },
        ));
  }

  bool isPasswordValid() {
    final password1 = _passwordController.text;
    final password2 = _passwordConfirmController.text;
    if (PasswordUtils.isValid(password1) &&
        PasswordUtils.isValid(password2) &&
        password1 == password2) {
      return true;
    } else {
      return false;
    }
  }

  void save() {
    doIfNetworkAvailable(() async {
      final oldPassword = _oldPasswordController.text;
      final newPassword = _passwordConfirmController.text;
      LoadingUtil.showLoading();
      final result =
          await NEMeetingKit.instance.getAccountService().resetPassword(
                AuthManager().accountId!,
                oldPassword,
                newPassword,
              );
      if (!mounted) return;
      LoadingUtil.cancelLoading();
      if (result.code == HttpCode.success) {
        AuthManager().logout();
        ToastUtils.showToast(
            context, getAppLocalizations().settingModifySuccess,
            duration: const Duration(seconds: 1), onDismiss: () {
          if (!mounted) return;
          NavUtils.toEntrance(context);
        });
      } else {
        var errorMsg = result.msg ?? getAppLocalizations().settingModifyFailed;
        if (result.code == HttpCode.oldPasswordError) {
          errorMsg = getAppLocalizations().authOldPasswordError;
          setState(() {
            oldPasswordErrorText = errorMsg;
          });
        } else if (result.code == HttpCode.newPasswordIsSameToTheOld) {
          errorMsg = getAppLocalizations().settingPasswordSameToOld;
          setState(() {
            newPasswordErrorText = errorMsg;
          });
        }
        ToastUtils.showToast(context, errorMsg);
      }
    });
  }

  Widget buildItem(String title, TextEditingController controller,
      String hintText, Widget? errorWidget1, Widget? errorWidget2) {
    return Container(
      padding: EdgeInsets.only(left: 16.w, right: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80.w,
                height: 48.h,
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(
                      color: AppColors.color_1E1E27,
                      fontSize: 14.spMin,
                      height: 1.0,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                  child: MeetingTextField(
                height: 44.h,
                fontSize: 14.spMin,
                hintFontSize: 14.spMin,
                controller: controller,
                obscureText: true,
                hintText: hintText,
                inputFormatters: PasswordUtils.passwordTextInputFormatters,
                onChanged: resetErrorText,
                showUnderline: false,
              )),
            ],
          ),
          errorWidget1 ?? Container(),
          errorWidget2 ?? Container(),
          SizedBox(
            height: 4.h,
          ),
        ],
      ),
    );
  }
}
