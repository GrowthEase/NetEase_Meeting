// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:nemeeting/routes/home_page.dart';
import 'package:nemeeting/service/auth/password_utils.dart';
import 'package:nemeeting/service/config/app_config.dart';
import 'package:nemeeting/service/repo/auth_repo.dart';
import 'package:nemeeting/service/repo/corp_repo.dart';
import 'package:nemeeting/uikit/values/asset_name.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import 'package:nemeeting/utils/privacy_util.dart';
import 'package:nemeeting/utils/state_utils.dart';
import 'package:nemeeting/widget/meeting_text_field.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

import '../../language/localizations.dart';
import '../../service/client/http_code.dart';
import '../../uikit/utils/nav_utils.dart';
import '../../uikit/utils/router_name.dart';
import 'reset_initial_password.dart';

class LoginCorpAccountRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginCorpAccountState();
  }
}

class LoginCorpAccountState extends BaseState
    with MeetingAppLocalizationsMixin {
  late NECorpInfo corpInfo;
  final _corpAccountController = TextEditingController();
  final _corpPasswordController = TextEditingController();

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
    corpInfo = ModalRoute.of(context)!.settings.arguments as NECorpInfo;
  }

  @override
  void dispose() {
    _corpAccountController.dispose();
    _corpPasswordController.dispose();
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
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                corpInfo.corpName,
                style: TextStyle(
                  fontSize: 28.spMin,
                  color: AppColors.black_222222,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              height: 25.h,
            ),
            MeetingTextField(
              height: 44.h,
              controller: _corpAccountController,
              hintText: meetingAppLocalizations.authEnterAccount,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(
              height: 20.h,
            ),
            MeetingTextField(
              height: 44.h,
              controller: _corpPasswordController,
              hintText: meetingAppLocalizations.authEnterPassword,
              inputFormatters: PasswordUtils.passwordTextInputFormatters,
              obscureText: true,
            ),
            SizedBox(
              height: 16.h,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                  child: Text(
                    meetingAppLocalizations.authLoginBySSO,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.blue_337eff,
                      fontSize: 14.spMin,
                    ),
                  ),
                  onTap: () async {
                    if (!await PrivacyUtil.ensurePrivacyAgree(context)) {
                      return;
                    }
                    NavUtils.pushNamed(context, RouterName.ssoLogin,
                        arguments: corpInfo.corpCode);
                  }),
            ),
            SizedBox(
              height: 20.h,
            ),
            ListenableBuilder(
              listenable: Listenable.merge(
                  [_corpAccountController, _corpPasswordController]),
              builder: (context, child) {
                return MeetingActionButton(
                    text: meetingAppLocalizations.authLogin,
                    onTap: isLoginButtonEnable ? login : null);
              },
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w),
              child: PrivacyUtil.protocolTips(),
            ),
            SizedBox(
              height: 16.h,
            ),
            SizedBox(
              height: 10.h,
            ),
          ],
        ),
      ),
    );
  }

  bool get isLoginButtonEnable {
    return _corpAccountController.text.trim().isNotEmpty &&
        PasswordUtils.isLengthValid(_corpPasswordController.text.trim());
  }

  Future<void> login() async {
    if (!await PrivacyUtil.ensurePrivacyAgree(context)) {
      return;
    }
    doIfNetworkAvailable(() async {
      final account = _corpAccountController.text.trim();
      final password = _corpPasswordController.text.trim();
      LoadingUtil.showLoading();
      final result =
          await AuthRepo().loginByPwd(corpInfo.appKey, account, password);
      LoadingUtil.cancelLoading();
      if (result.code == HttpCode.success) {
        NavUtils.pushNamedAndRemoveUntil(context, RouterName.homePage,
            arguments: result.data!.isInitialPassword
                ? HomePageRouteArguments(
                    resetPasswordRequest: ResetPasswordRequest(
                        corpInfo.appKey, account, password))
                : null);
      } else if (result.code == CorpRepo.accountPasswordNeedReset) {
        Navigator.of(context).pushNamed(RouterName.resetInitialPassword,
            arguments: ResetPasswordRequest(corpInfo.appKey, account, password,
                resetToLogin: true));
      } else if (result.msg != null) {
        ToastUtils.showToast(context, result.msg!);
      }
    });
  }
}
