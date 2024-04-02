// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:nemeeting/channel/ne_platform_channel.dart';
import 'package:nemeeting/service/repo/corp_repo.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import 'package:nemeeting/utils/state_utils.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

import '../../language/localizations.dart';
import '../../service/client/http_code.dart';
import '../../service/repo/auth_repo.dart';
import '../../uikit/utils/nav_utils.dart';
import '../../uikit/utils/router_name.dart';
import '../../widget/meeting_text_field.dart';
import 'package:nemeeting/service/config/login_type.dart';

class LoginSSORoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginSSOState();
  }
}

class LoginSSOState extends BaseState with MeetingAppLocalizationsMixin {
  bool _loginByCorpCode = true;
  final textFieldController = TextEditingController();
  final ssoLoginController =
      NESSOLoginController(callback: 'nemeeting://meeting.netease.im');
  bool _parseInitialCorpCode = true;
  bool _hasInputChanged = false;

  @override
  void initState() {
    super.initState();
    NEPlatformChannel().listen(maybeHandleSSOLoginAuthResult);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_parseInitialCorpCode) {
      _parseInitialCorpCode = false;
      final corpCode = ModalRoute.of(context)!.settings.arguments as String?;
      if (corpCode != null && corpCode.isNotEmpty) {
        textFieldController.text = corpCode;
      } else {
        GlobalPreferences().savedCorpCode.then((value) {
          if (!mounted ||
              value == null ||
              _hasInputChanged ||
              !_loginByCorpCode) return;
          textFieldController.text = value;
        });
      }
    }
  }

  @override
  void dispose() {
    textFieldController.dispose();
    ssoLoginController.dispose();
    NEPlatformChannel().unListen(maybeHandleSSOLoginAuthResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(
            key: MeetingUIValueKeys.back,
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
            style: ButtonStyle(
              padding: MaterialStateProperty.all(EdgeInsets.zero),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
            child: Text(
              _loginByCorpCode
                  ? meetingAppLocalizations.authLoginByCorpMail
                  : meetingAppLocalizations.authLoginBySSO,
              style: TextStyle(
                color: AppColors.color_337eff,
                fontSize: 14.0.spMin,
                fontWeight: FontWeight.w400,
              ),
            ),
            onPressed: () {
              setState(() {
                textFieldController.clear();
                _loginByCorpCode = !_loginByCorpCode;
              });
            },
          ),
          20.horizontalSpace,
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 30.w, right: 30.w, top: 16.h),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _loginByCorpCode
                    ? meetingAppLocalizations.authLoginBySSO
                    : meetingAppLocalizations.authLoginByCorpMail,
                style: TextStyle(
                  fontSize: 28.spMin,
                  color: AppColors.black_222222,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            25.verticalSpace,
            MeetingTextField(
              height: 44.h,
              controller: textFieldController,
              onChanged: (_) => _hasInputChanged = true,
              hintText: _loginByCorpCode
                  ? meetingAppLocalizations.authEnterCorpCode
                  : meetingAppLocalizations.authEnterCorpMail,
              keyboardType:
                  _loginByCorpCode ? null : TextInputType.emailAddress,
            ),
            60.verticalSpace,
            ListenableBuilder(
              listenable: textFieldController,
              builder: (context, child) {
                return MeetingActionButton(
                  text: meetingAppLocalizations.authLogin,
                  onTap: isLoginButtonEnable ? login : null,
                );
              },
            ),
          ],
        ),
      ),
    );
    return AutoHideKeyboard(
      child: child,
    );
  }

  bool get isLoginButtonEnable {
    return textFieldController.text.trim().isNotEmpty;
  }

  void maybeHandleSSOLoginAuthResult(String uri) async {
    final result = await ssoLoginController.parseAuthResult(uri);
    if (!mounted || result.code == NESSOLoginController.ignore) return;
    if (result.data != null) {
      await doIfNetworkAvailable(() async {
        LoadingUtil.showLoading();
        final accountInfo = result.nonNullData;
        final loginResult = await AuthRepo().loginByToken(
            LoginType.sso,
            accountInfo.accountId,
            accountInfo.accountToken,
            accountInfo.appKey);
        LoadingUtil.cancelLoading();
        final bool success = loginResult.code == HttpCode.success;
        if (success) {
          NavUtils.pushNamedAndRemoveUntil(context, RouterName.homePage);
        } else if (loginResult.msg != null) {
          ToastUtils.showToast(context, loginResult.msg);
        }
        if (_loginByCorpCode) {
          GlobalPreferences().saveCorpCode(
            success ? textFieldController.text.trim() : null,
          );
        }
      });
    } else {
      ToastUtils.showToast(
          context, result.msg ?? meetingAppLocalizations.authSSOLoginFail);
    }
  }

  void login() {
    doIfNetworkAvailable(() async {
      final codeOrEmail = textFieldController.text.trim();
      final code = await ssoLoginController.launchAuthPage(
        corpEmail: _loginByCorpCode ? null : codeOrEmail,
        corpCode: _loginByCorpCode ? codeOrEmail : null,
      );
      if (!mounted) return;
      switch (code) {
        case NESSOLoginController.corpNotFound:
          ToastUtils.showToast(
              context, meetingAppLocalizations.authCorpNotFound);
          break;
        case NESSOLoginController.corpNotSupportSSO:
          ToastUtils.showToast(
              context, meetingAppLocalizations.authSSONotSupport);
          break;
        case != NESSOLoginController.ignore && != NESSOLoginController.success:
          ToastUtils.showToast(
              context, meetingAppLocalizations.authSSOLoginFail);
          break;
      }
    });
  }
}
