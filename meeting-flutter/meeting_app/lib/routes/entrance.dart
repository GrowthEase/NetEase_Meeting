// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:nemeeting/arguments/webview_arguments.dart';
import 'package:nemeeting/base/util/error.dart';
import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:nemeeting/base/util/text_util.dart';
import 'package:nemeeting/base/util/url_util.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/service/config/servers.dart';
import 'package:nemeeting/utils/privacy_util.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/config/app_config.dart';
import 'package:nemeeting/service/config/scene_type.dart';
import 'package:nemeeting/service/profile/app_profile.dart';
import 'package:nemeeting/service/repo/auth_repo.dart';
import '../uikit/utils/nav_utils.dart';
import '../uikit/utils/router_name.dart';
import '../uikit/values/borders.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/strings.dart';
import 'package:nemeeting/arguments/auth_arguments.dart';
import '../uikit/values/asset_name.dart';
import 'package:nemeeting/channel/ne_platform_channel.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

class EntranceRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EntranceRouteState();
  }
}

class _EntranceRouteState extends LifecycleBaseState {
  late NEMeetingChannelCallback _callback;

  @override
  void initState() {
    super.initState();

    ///需求默认加载未登录
    PrivacyUtil.privateAgreementChecked = false;
    _callback = (String uri) => deepLink(uri);
    NEPlatformChannel().listen(_callback);
    GlobalPreferences().hasPrivacyDialogShowed.then((value) {
      if (value != true) {
        showPrivacyDialog(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: SafeArea(
          child: Stack(children: <Widget>[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  buildIcon(),
                  Container(
                    height: 148,
                    margin: EdgeInsets.only(left: 30, right: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildRegisterAndLogin(),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            buildPowerBy(),
            Column(
                children: <Widget>[Spacer(), PrivacyUtil.protocolTips(context)])
          ]),
        ));
  }

  Align buildPowerBy() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          AssetName.provider,
          //package: AssetName.package,
          fit: BoxFit.none,
        ),
      ),
    );
  }

  TextStyle buildTextStyle(Color color) {
    return TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none);
  }

  GestureDetector buildRegister() {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.only(left: 50, top: 6, right: 50, bottom: 6),
          child: Text(
            Strings.immediatelyRegister,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.blue_337eff,
                fontWeight: FontWeight.w400,
                fontSize: 12,
                decoration: TextDecoration.none),
          ),
        ),
        onTap: () {
          var authModel = AuthArguments();
          authModel.sceneType = SceneType.register;
          NavUtils.pushNamed(context, RouterName.getMobileCheckCode,
              arguments: authModel);
        });
  }

  GestureDetector buildLogin() {
    return GestureDetector(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          border: Border.fromBorderSide(Borders.secondaryBorder),
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
        alignment: Alignment.center,
        child: Text(
          AppConfig().isPublicFlavor ? Strings.login : Strings.mailLogin,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.blue_337eff,
              fontWeight: FontWeight.w400,
              fontSize: 16,
              decoration: TextDecoration.none),
        ),
      ),
      onTap: () {
        if (!PrivacyUtil.privateAgreementChecked) {
          ToastUtils.showToast(context, Strings.privacyCheckedTips);
          return;
        }
        var authModel = AuthArguments();
        authModel.sceneType = SceneType.login;
        NavUtils.pushNamed(context, RouterName.login, arguments: authModel);
      },
    );
  }

  GestureDetector buildRegisterAndLogin() {
    return GestureDetector(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.accentElement,
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
        alignment: Alignment.center,
        child: Text(
          Strings.registerAndLogin,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w400,
              fontSize: 16,
              decoration: TextDecoration.none),
        ),
      ),
      onTap: () {
        if (!PrivacyUtil.privateAgreementChecked) {
          ToastUtils.showToast(context, Strings.privacyCheckedTips);
          return;
        }
        launchLogin();
      },
    );
  }

  int _tapCount = 0;
  int _tapTime = 0;

  Widget buildIcon() {
    return GestureDetector(
      child: Container(
        width: 166,
        height: 159,
        child: Image.asset(
          AssetName.meet,
          //package: AssetName.package,
          fit: BoxFit.none,
        ),
      ),
      onTap: () {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - _tapTime > 200) {
          _tapCount = 1;
        } else {
          _tapCount++;
        }
        _tapTime = now;
        if (_tapCount >= 20) {
          _tapCount = 0;
          NavUtils.pushNamed(context, RouterName.backdoor);
        }
      },
    );
  }

  void openAnonyMeetJoin() {
    var authModel = AuthArguments();
    authModel.sceneType = SceneType.login;
    NavUtils.pushNamed(context, RouterName.anonyMeetJoin, arguments: authModel);
  }

  Future<void> ssoLogin(String uuid, String ssoToken, String appKey) async {
    await AuthRepo().loginByToken(uuid, ssoToken, appKey).then((result) {
      if (result.code == HttpCode.success) {
        NavUtils.pushNamedAndRemoveUntil(context, RouterName.homePage);
      } else {
        ErrorUtil.showError(context, HttpCode.getMsg(result.msg));
      }
    });
  }

  @override
  void dispose() {
    PrivacyUtil.dispose();
    NEPlatformChannel().unListen(_callback);
    super.dispose();
  }

  void deepLink(String uri) {
    var meetingId = UrlUtil.getParamValue(uri, UrlUtil.paramMeetingId);
    AppProfile.deepLinkMeetingId = meetingId;
    if (!TextUtil.isEmpty(meetingId)) {
      if (ModalRoute.of(context)!.isCurrent) {
        openAnonyMeetJoin();
      }
    }

    var appKey = UrlUtil.getParamValue(uri, UrlUtil.paramAppId);
    var ssoToken = UrlUtil.getParamValue(uri, UrlUtil.paramUserToken);
    var userUuid = UrlUtil.getParamValue(uri, UrlUtil.paramUserUuid);
    if (!TextUtil.isEmpty(userUuid) && !TextUtil.isEmpty(ssoToken)) {
      ssoLogin(userUuid!, ssoToken!, appKey!);
    }
  }

  //发起URS登录
  void launchLogin() {
    // var authRepo = AuthRepo();
    // authRepo.loginByURS();
    var authModel = AuthArguments();
    authModel.sceneType = SceneType.login;
    NavUtils.pushNamed(context, RouterName.login, arguments: authModel);
  }

  //处理URS登录的信息
  void handlerLoginInfo(String result) {
    var authRepo = AuthRepo();
    var resultMap = (jsonDecode(result) as Map);
    var type = resultMap['type']
        as int; // 0 init  1 login  2 login result  3 logout 4 server config
    print("flutter login parse : " + result);
    if (type != 2) {
      //只需处理 login result 结果
      return;
    }
    var loginResult = authRepo.loginByInfo(resultMap);
    lifecycleExecuteUI(loginResult).then((result) {
      if (result?.code == HttpCode.success) {
        NavUtils.pushNamedAndRemoveUntil(context, RouterName.homePage);
      } else {
        ErrorUtil.showError(context, HttpCode.getMsg(result?.msg));
      }
    });
  }

  void showPrivacyDialog(BuildContext context) async {
    TextSpan buildTextSpan(String text, WebViewArguments? arguments) {
      return TextSpan(
        text: text,
        style: buildTextStyle(
          arguments != null ? AppColors.blue_337eff : AppColors.color_999999,
        ),
        recognizer: arguments == null
            ? null
            : (TapGestureRecognizer()
              ..onTap = () {
                NavUtils.pushNamed(context, RouterName.webview,
                    arguments: arguments);
              }),
      );
    }

    final userArguments =
        WebViewArguments(servers.userProtocol, Strings.user_protocol);
    final privacyArguments = WebViewArguments(servers.privacy, Strings.privacy);

    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(Strings.privacyDialogTitle),
            content: Text.rich(
              TextSpan(
                children: [
                  buildTextSpan(Strings.privacyDialogMessagePart1, null),
                  buildTextSpan(
                      Strings.privacyDialogMessagePart2, userArguments),
                  buildTextSpan(Strings.privacyDialogMessagePart3, null),
                  buildTextSpan(
                      Strings.privacyDialogMessagePart4, privacyArguments),
                  buildTextSpan(Strings.privacyDialogMessagePart5, null),
                ],
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text(Strings.privacyDialogActionQuit),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              CupertinoDialogAction(
                child: const Text(Strings.privacyDialogActionAgree),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        }).then((value) {
      if (value == false) {
        exit(0);
      } else if (value == true) {
        GlobalPreferences().setPrivacyDialogShowed(true);
      }
    });
  }
}
