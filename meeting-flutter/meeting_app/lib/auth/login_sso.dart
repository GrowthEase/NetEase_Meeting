// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:nemeeting/channel/ne_platform_channel.dart';
import 'package:nemeeting/constants.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/state/auth_base_state.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import 'package:nemeeting/utils/state_utils.dart';
import 'package:nemeeting/widget/ne_widget.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../language/localizations.dart';
import '../../service/repo/auth_repo.dart';
import '../../uikit/utils/nav_utils.dart';
import '../../uikit/utils/router_name.dart';
import '../../widget/meeting_text_field.dart';

class LoginSSORoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginSSOState();
  }
}

class LoginSSOState extends AuthBaseState with NESSOLoginControllerMixin {
  bool _loginByCorpCode = true;
  final corpCodeController = TextEditingController();
  final corpEmailController = TextEditingController();
  bool _parseInitialCorpCode = true;
  bool _hasInputChanged = false;

  TextEditingController getTextController() {
    return _loginByCorpCode ? corpCodeController : corpEmailController;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_parseInitialCorpCode) {
      _parseInitialCorpCode = false;
      final corpCode = ModalRoute.of(context)!.settings.arguments as String?;
      if (corpCode != null && corpCode.isNotEmpty) {
        corpCodeController.text = corpCode;
      } else {
        GlobalPreferences().savedCorpCode.then((value) {
          if (!mounted ||
              value == null ||
              _hasInputChanged ||
              !_loginByCorpCode) return;
          corpCodeController.text = value;
        });
      }
    }
  }

  @override
  void dispose() {
    corpCodeController.dispose();
    corpEmailController.dispose();
    super.dispose();
  }

  @override
  Widget getSubject() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 30.h, horizontal: 30.w),
      child: Column(
        children: [
          MeetingTextField(
            prefixIcon: Icon(
              _loginByCorpCode ? IconFont.icon_corp : IconFont.icon_email,
              color: AppColors.color_CDCFD7,
            ),
            height: 44.h,
            controller: getTextController(),
            onChanged: (_) => _hasInputChanged = true,
            hintText: _loginByCorpCode
                ? getAppLocalizations().authEnterCorpCode
                : getAppLocalizations().authEnterCorpMail,
            keyboardType: _loginByCorpCode ? null : TextInputType.emailAddress,
          ),
          10.verticalSpace,
          Container(
            alignment: Alignment.bottomLeft,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _loginByCorpCode
                        ? getAppLocalizations().authGetCorpCodeFromAdmin
                        : '',
                    style: TextStyle(
                      fontSize: 12.spMin,
                      color: AppColors.greyB0B6BE,
                    ),
                  ),
                ),
                NEGestureDetector(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 130, // 设置最大宽度
                    ),
                    child: Text(
                      _loginByCorpCode
                          ? getAppLocalizations().authIDontKnowCorpCode
                          : getAppLocalizations().authIKnowCorpCode,
                      style: TextStyle(
                        color: AppColors.color_337eff,
                        fontSize: 14.0.spMin,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _loginByCorpCode = !_loginByCorpCode;
                    });
                  },
                ),
              ],
            ),
          ),
          30.verticalSpace,
          ListenableBuilder(
            listenable: getTextController(),
            builder: (context, child) {
              return MeetingActionButton(
                text: getAppLocalizations().authLogin,
                onTap: isLoginButtonEnable ? login : null,
              );
            },
          ),
        ],
      ),
    );
  }

  bool get isLoginButtonEnable {
    return getTextController().text.trim().isNotEmpty;
  }

  void login() async {
    final codeOrEmail = getTextController().text.trim();
    _loginByCorpCode
        ? startSSOLoginByCorpCode(codeOrEmail)
        : startSSOLoginByCorpMail(codeOrEmail);
  }

  @override
  String getSubTitle() {
    return _loginByCorpCode
        ? getAppLocalizations().authLoginBySSO
        : getAppLocalizations().authLoginByCorpMail;
  }
}

mixin NESSOLoginControllerMixin<T extends StatefulWidget> on State<T> {
  final logger = AppLoggerFactory.get('NESSOLoginController');
  String? _corpCode;
  String? _corpEmail;

  @override
  void initState() {
    super.initState();
    NEPlatformChannel().listen(_maybeHandleSSOLoginAuthResult);
  }

  @override
  void dispose() {
    NEPlatformChannel().unListen(_maybeHandleSSOLoginAuthResult);
    super.dispose();
  }

  void _maybeHandleSSOLoginAuthResult(String uri) async {
    if (_ssoLoginCompleter == null || !ModalRoute.of(context)!.isCurrent) {
      return;
    }
    await doIfNetworkAvailable(() async {
      LoadingUtil.showLoading();
      final result = await AuthRepo()
          .loginBySSOUri(uri, corpCode: _corpCode, corpEmail: _corpEmail);
      LoadingUtil.cancelLoading();
      if (!mounted || result.code != NEMeetingErrorCode.success) {
        _notifySSOLoginResult(false);
      } else {
        NavUtils.pushNamedAndRemoveUntil(context, RouterName.homePage);
        _notifySSOLoginResult(true);
      }
    });
  }

  Future<bool> startSSOLoginByCorpInfo(NEMeetingCorpInfo corpInfo) async {
    final success = await _startSSOLogin(corpCode: corpInfo.corpCode) == true;
    if (success) {
      GlobalPreferences().saveCorpCode(corpInfo.corpCode);
    }
    return success;
  }

  Future<bool> startSSOLoginByCorpMail(String corpEmail) async {
    return await _startSSOLogin(corpEmail: corpEmail) == true;
  }

  Future<bool> startSSOLoginByCorpCode(String corpCode) async {
    final success = await _startSSOLogin(corpCode: corpCode) == true;
    if (success) {
      GlobalPreferences().saveCorpCode(corpCode);
    }
    return success;
  }

  Completer<bool>? _ssoLoginCompleter;
  void _notifySSOLoginResult(bool success) {
    final completer = _ssoLoginCompleter;
    _ssoLoginCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete(success);
    }
  }

  Future<bool?> _startSSOLogin({
    String? corpEmail,
    String? corpCode,
  }) {
    bool failAndToast(int code, [String? msg]) {
      if (!mounted) return false;
      switch (code) {
        case NEMeetingErrorCode.corpNotFound:
          ToastUtils.showToast(context, getAppLocalizations().authCorpNotFound);
          break;
        case NEMeetingErrorCode.corpNotSupportSSO:
          ToastUtils.showToast(
              context, getAppLocalizations().authSSONotSupport);
          break;
        case != NEMeetingErrorCode.success:
          ToastUtils.showToast(
              context, msg ?? getAppLocalizations().authSSOLoginFail);
          break;
      }
      return code != NEMeetingErrorCode.success;
    }

    return doIfNetworkAvailable(() async {
      if (corpCode != null || corpEmail != null) {
        final initResult = await AuthManager().initialize(
          corpCode: corpCode,
          corpEmail: corpEmail,
        );
        if (!initResult.isSuccess()) {
          return failAndToast(initResult.code, initResult.msg);
        }
      }
      final ssoLoginUrlResult = await NEMeetingKit.instance
          .getAccountService()
          .generateSSOLoginWebURL();
      if (!ssoLoginUrlResult.isSuccess()) {
        return failAndToast(ssoLoginUrlResult.code);
      }
      // 打开认证页面
      var launchSuccess = false;
      try {
        final url = ssoLoginUrlResult.nonNullData;
        logger.i('launchAuthPage url: $url');
        launchSuccess = await launchUrlString(
          url,
          mode: LaunchMode.externalApplication,
        );
      } catch (e, s) {
        debugPrintStack(label: 'launchAuthPage error', stackTrace: s);
        logger.e('launchAuthPage error: $e');
      }
      if (!launchSuccess) {
        return failAndToast(NEMeetingErrorCode.failed);
      }
      _corpCode = corpCode;
      _corpEmail = corpEmail;
      _ssoLoginCompleter = Completer();
      return _ssoLoginCompleter!.future;
    });
  }
}
