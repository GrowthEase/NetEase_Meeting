// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/auth/auth_widgets.dart';
import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:nemeeting/routes/home_page.dart';
import 'package:nemeeting/service/auth/password_utils.dart';
import 'package:nemeeting/service/config/app_config.dart';
import 'package:nemeeting/service/repo/auth_repo.dart';
import 'package:nemeeting/state/auth_base_state.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import 'package:nemeeting/utils/privacy_util.dart';
import 'package:nemeeting/utils/state_utils.dart';
import 'package:nemeeting/widget/meeting_text_field.dart';
import 'package:netease_common/netease_common.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';

import '../../language/localizations.dart';
import '../../service/client/http_code.dart';
import '../../uikit/utils/nav_utils.dart';
import '../../uikit/utils/router_name.dart';
import 'login_sso.dart';
import 'reset_initial_password.dart';

class LoginCorpAccountRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginCorpAccountState();
  }
}

class LoginCorpAccountState extends AuthBaseState
    with NESSOLoginControllerMixin {
  late NEMeetingCorpInfo corpInfo;
  final _corpAccountController = TextEditingController();
  final _corpMobileController = TextEditingController();
  final _corpEmailController = TextEditingController();
  final _corpPasswordController = TextEditingController();
  var loginItemType = LoginItemType.accountPwd;
  final _accountFocusNode = FocusNode(), _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    GlobalPreferences().hasPrivacyDialogShowed.then((value) {
      if (value != true) {
        PrivacyUtil.showPrivacyDialog(context);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    corpInfo = ModalRoute.of(context)!.settings.arguments as NEMeetingCorpInfo;
  }

  @override
  void dispose() {
    getAccountController().dispose();
    _corpMobileController.dispose();
    _corpEmailController.dispose();
    _corpPasswordController.dispose();
    _accountFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  String getTitle() {
    return corpInfo.corpName;
  }

  @override
  Widget getSubject() {
    return Padding(
      padding: EdgeInsets.only(left: 30.w, right: 30.w, top: 16.h),
      child: Column(
        children: [
          SizedBox(
            height: 25.h,
          ),
          MeetingTextField(
            prefixIcon: Icon(
              switch (loginItemType) {
                LoginItemType.mobilePwd => IconFont.icon_mobile,
                LoginItemType.emailPwd => IconFont.icon_email,
                _ => IconFont.icon_account,
              },
              color: AppColors.color_CDCFD7,
            ),
            height: 44.h,
            controller: getAccountController(),
            hintText: switch (loginItemType) {
              LoginItemType.mobilePwd => getAppLocalizations().authEnterMobile,
              LoginItemType.emailPwd => getAppLocalizations().authEnterEmail,
              _ => getAppLocalizations().authEnterAccount,
            },
            keyboardType: switch (loginItemType) {
              LoginItemType.mobilePwd => TextInputType.number,
              LoginItemType.emailPwd => TextInputType.emailAddress,
              _ => null,
            },
            textInputAction: TextInputAction.next,
            focusNode: _accountFocusNode,
            onTap: () {
              _passwordFocusNode.unfocus();
              postOnFrame(() {
                _accountFocusNode.requestFocus();
              });
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
            controller: _corpPasswordController,
            hintText: getAppLocalizations().authEnterPassword,
            inputFormatters: PasswordUtils.passwordTextInputFormatters,
            obscureText: true,
            focusNode: _passwordFocusNode,
            onTap: () {
              _accountFocusNode.unfocus();
              postOnFrame(() {
                _passwordFocusNode.requestFocus();
              });
            },
          ),
          SizedBox(
            height: 16.h,
          ),
          SizedBox(
            height: 60.h,
          ),
          ListenableBuilder(
            listenable: Listenable.merge(
                [getAccountController(), _corpPasswordController]),
            builder: (context, child) {
              return MeetingActionButton(
                  text: getAppLocalizations().authLogin,
                  onTap: isLoginButtonEnable ? login : null);
            },
          ),
          SizedBox(
            height: 48.h,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: isPrivate()
                  ? IntrinsicHeight(child: PrivacyUtil.protocolTips())
                  : null,
            ),
          ),
          SizedBox(
            height: 161.h,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 1.h,
                width: 14.w,
                color: AppColors.colorDCDFE5,
              ),
              SizedBox(
                width: 6.w,
              ),
              Text(
                getAppLocalizations().authOtherLoginTypes,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.color_666666,
                ),
              ),
              SizedBox(
                width: 6.w,
              ),
              Container(
                height: 1.h,
                width: 14.w,
                color: AppColors.colorDCDFE5,
              ),
            ],
          ),
          SizedBox(
            height: 20.h,
          ),
          LoginItemRow(
            types: LoginItemType.values.whereNot((type) {
              return type == loginItemType;
            }).toList(),
            onTap: handleLoginTypeTap,
          ),
          SizedBox(
            height: 16.h,
          ),
          SizedBox(
            height: 10.h,
          ),
        ],
      ),
    );
  }

  void handleLoginTypeTap(LoginItemType type) {
    if (type != LoginItemType.sso) {
      setState(() {
        loginItemType = type;
        _corpPasswordController.clear();
      });
    } else {
      startSSOLoginByCorpInfo(corpInfo);
    }
  }

  bool get isLoginButtonEnable {
    return getAccountController().text.trim().isNotEmpty &&
        PasswordUtils.isLengthValid(_corpPasswordController.text.trim());
  }

  TextEditingController getAccountController() {
    return switch (loginItemType) {
      LoginItemType.mobilePwd => _corpMobileController,
      LoginItemType.emailPwd => _corpEmailController,
      _ => _corpAccountController,
    };
  }

  Future<NEResult<NEAccountInfo>> loginAction(String account, String password) {
    return switch (loginItemType) {
      LoginItemType.mobilePwd => NEMeetingKit.instance
          .getAccountService()
          .loginByPhoneNumber(account, password),
      LoginItemType.emailPwd => NEMeetingKit.instance
          .getAccountService()
          .loginByEmail(account, password),
      _ => NEMeetingKit.instance
          .getAccountService()
          .loginByPassword(account, password),
    };
  }

  Future<void> login() async {
    if (!await PrivacyUtil.ensurePrivacyAgree(context)) {
      return;
    }
    doIfNetworkAvailable(() async {
      final account = getAccountController().text.trim();
      final password = _corpPasswordController.text.trim();
      LoadingUtil.showLoading();
      final result = await AuthRepo()
          .loginByPwd(corpInfo.appKey, () => loginAction(account, password));
      LoadingUtil.cancelLoading();
      if (result.code == HttpCode.success) {
        NavUtils.pushNamedAndRemoveUntil(context, RouterName.homePage,
            arguments: result.data!.isInitialPassword
                ? HomePageRouteArguments(
                    resetPasswordRequest: ResetPasswordRequest(
                        corpInfo.appKey, account, password))
                : null);
        GlobalPreferences().saveCorpCode(corpInfo.corpCode);
      } else if (result.code == NEMeetingErrorCode.accountPasswordNeedReset) {
        Navigator.of(context).pushNamed(RouterName.resetInitialPassword,
            arguments: ResetPasswordRequest(corpInfo.appKey, account, password,
                loginWithNewPassword: (newPassword) =>
                    loginAction(account, newPassword)));
      } else if (result.msg != null) {
        ToastUtils.showToast(context, result.msg!);
      }
    });
  }

  bool isPrivate() {
    return false;
  }

  @override
  bool isShowBackBtn() {
    return !isPrivate();
  }

  @override
  String getSubTitle() {
    return switch (loginItemType) {
      LoginItemType.mobilePwd => getAppLocalizations().authLoginByMobilePwd,
      LoginItemType.emailPwd => getAppLocalizations().authLoginByEmailPwd,
      _ => getAppLocalizations().authLoginByAccountPwd,
    };
  }
}
