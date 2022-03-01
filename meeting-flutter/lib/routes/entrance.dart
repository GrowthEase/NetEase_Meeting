// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:base/util/error.dart';
import 'package:base/util/textutil.dart';
import 'package:base/util/url_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nemeeting/utils/privacy_util.dart';
import 'package:service/client/http_code.dart';
import 'package:service/config/app_config.dart';
import 'package:service/config/login_type.dart';
import 'package:service/config/scene_type.dart';
import 'package:service/model/login_info.dart';
import 'package:service/profile/app_profile.dart';
import 'package:service/repo/auth_repo.dart';
import 'package:uikit/const/packages.dart';
import 'package:uikit/utils/nav_utils.dart';
import 'package:uikit/utils/router_name.dart';
import 'package:uikit/values/borders.dart';
import 'package:uikit/values/colors.dart';
import 'package:uikit/values/strings.dart';
import 'package:nemeeting/arguments/auth_arguments.dart';
import 'package:uikit/values/asset_name.dart';
import 'package:nemeeting/channel/ne_platform_channel.dart';
import 'package:yunxin_meeting/meeting_uikit.dart';

class EntranceRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EntranceRouteState();
  }
}

class _EntranceRouteState extends BaseState<EntranceRoute> {
  late Callback _callback;
  @override
  void initState() {
    super.initState();
    ///需求默认加载未登录
    PrivacyUtil.privateAgreementChecked = false;
    _callback = (String uri) => deepLink(uri);
    NEPlatformChannel().listen(_callback);
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
                        buildJoin(),
                        SizedBox(
                          height: 15,
                        ),
                        buildLogin(),
                        Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            buildPowerBy(),
            Column(children: <Widget>[
              Spacer(),
              PrivacyUtil.protocolTips(context)
            ])
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
          package: Packages.uiKit,
          fit: BoxFit.none,
        ),
      ),
    );
  }

  TextStyle buildTextStyle(Color color) {
    return TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w400, decoration: TextDecoration.none);
  }

  GestureDetector buildSSO() {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.only(left: 50, top: 6, right: 50, bottom: 6),
          child: Text(
            Strings.loginBySSO,
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
          NavUtils.pushNamed(context, RouterName.ssoLogin, arguments: authModel);
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
              color: AppColors.blue_337eff, fontWeight: FontWeight.w400, fontSize: 16, decoration: TextDecoration.none),
        ),
      ),
      onTap: () {
        if (!PrivacyUtil.privateAgreementChecked) {
          ToastUtils.showToast(context, Strings.privacyCheckedTips);
          return;
        }
        if (AppConfig().isPublicFlavor) {
          var authModel = AuthArguments();
          authModel.sceneType = SceneType.login;
          NavUtils.pushNamed(context, RouterName.login, arguments: authModel);
        } else {
          NavUtils.pushNamed(context, RouterName.mailLogin);
        }
      },
    );
  }

  GestureDetector buildJoin() {
    return GestureDetector(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.accentElement,
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
        alignment: Alignment.center,
        child: Text(
          Strings.joinMeeting,
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
        openAnonyMeetJoin();
      },
    );
  }

  Widget buildIcon() {
    return Container(
      width: 166,
      height: 159,
      child: Image.asset(
        AssetName.meet,
        package: Packages.uiKit,
        fit: BoxFit.none,
      ),
    );
  }

  void openAnonyMeetJoin() {
    var authModel = AuthArguments();
    authModel.sceneType = SceneType.login;
    NavUtils.pushNamed(context, RouterName.anonyMeetJoin, arguments: authModel);
  }

  Future<void> ssoLogin(String ssoToken) async {
    var parseSSOTokenResult = await AuthRepo().parseSSOToken(ssoToken);
    if (parseSSOTokenResult.code != HttpCode.success) {
      ErrorUtil.showError(context, HttpCode.getMsg(parseSSOTokenResult.msg));
      return;
    }
    AppProfile.appKey = parseSSOTokenResult.data?.appKey;
    AppProfile.accountId = parseSSOTokenResult.data?.accountId;
    AppProfile.accountToken = parseSSOTokenResult.data?.accountToken;

    await AuthRepo().loginBySSO(
        LoginInfo(
            appKey: AppProfile.appKey!,
            accountId: AppProfile.accountId!,
            accountToken: AppProfile.accountToken!,
            loginType: LoginType.sso.index),
        ssoToken)
        .then((result) {
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

    var appKey = UrlUtil.getParamValue(uri, UrlUtil.paramAppKey);
    var ssoToken = UrlUtil.getParamValue(uri, UrlUtil.paramSSOToken);
    if(!TextUtil.isEmpty(appKey) && !TextUtil.isEmpty(ssoToken)){
      ssoLogin(ssoToken!);
    }
  }
}
