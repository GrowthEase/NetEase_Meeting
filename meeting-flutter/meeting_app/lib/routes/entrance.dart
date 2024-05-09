// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:nemeeting/channel/deep_link_manager.dart';
import 'package:nemeeting/service/config/servers.dart';
import 'package:nemeeting/service/repo/corp_repo.dart';
import 'package:nemeeting/utils/privacy_util.dart';
import 'package:nemeeting/utils/security_notice_util.dart';
import 'package:nemeeting/utils/state_utils.dart';
import 'package:nemeeting/webview/webview_page.dart';
import 'package:nemeeting/widget/meeting_text_field.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

import '../language/localizations.dart';
import '../uikit/utils/nav_utils.dart';
import '../uikit/utils/router_name.dart';
import '../uikit/values/asset_name.dart';
import '../uikit/values/colors.dart';

enum _Edition {
  corp,
  trial,
}

class EntranceRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EntranceRouteState();
  }
}

class _EntranceRouteState extends LifecycleBaseState
    with MeetingAppLocalizationsMixin {
  var _edition = _Edition.corp;
  final _corpCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    ///需求默认加载未登录
    PrivacyUtil.privateAgreementChecked = false;
    AppNotificationManager().reset();
    GlobalPreferences().hasPrivacyDialogShowed.then((value) {
      if (value != true) {
        PrivacyUtil.showPrivacyDialog(context);
      }
    });

    DeepLinkManager().attach(context);
  }

  @override
  Widget build(BuildContext context) {
    final child = Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 73.h,
            ),
            buildIcon(),
            if (_edition == _Edition.corp) ...[
              SizedBox(
                height: 54.h,
              ),
              SizedBox(
                height: 44.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: MeetingTextField(
                    controller: _corpCodeController,
                    hintText: meetingAppLocalizations.authEnterCorpCode,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: launchCorpLogin,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: 33.w, right: 33.w, top: 16.h, bottom: 20.h),
                child: buildCorpLoginSubActions(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: ListenableBuilder(
                  listenable: _corpCodeController,
                  builder: (context, child) {
                    return MeetingActionButton(
                      text: meetingAppLocalizations.authNextStep,
                      onTap: _corpCodeController.text.trim().isNotEmpty
                          ? launchCorpLogin
                          : null,
                    );
                  },
                ),
              ),
              SizedBox(
                height: 16.h,
              ),
              buildSSO(),
            ],
            if (_edition == _Edition.trial) ...[
              SizedBox(
                height: 113.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: MeetingActionButton(
                  text: meetingAppLocalizations.authRegisterAndLogin,
                  onTap: launchTrialLogin,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 33.w, right: 33.w, top: 16.h),
                child: buildTrialLoginSubActions(),
              ),
            ],
            Spacer(),
            Padding(
              padding: EdgeInsets.only(left: 33.w, right: 33.w),
              child: PrivacyUtil.protocolTips(),
            ),
            SizedBox(
              height: 16.h,
            ),
            Image.asset(
              AssetName.provider,
              fit: BoxFit.none,
            ),
            SizedBox(
              height: 10.h,
            ),
          ],
        ),
      ),
      // ]),
    );
    return AutoHideKeyboard(
      child: child,
    );
  }

  TextStyle buildTextStyle(Color color) {
    return TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none);
  }

  Widget buildCorpLoginSubActions() {
    return Row(
      children: <Widget>[
        Text(
          meetingAppLocalizations.authNoCorpCode +
              meetingAppLocalizations.authCreateAccountByPC,
          style: TextStyle(
            color: AppColors.color_666666,
            fontSize: 12.spMin,
          ),
        ),
        Spacer(),
        GestureDetector(
          child: Text(
            meetingAppLocalizations.authLoginToTrialEdition,
            style: TextStyle(
              color: AppColors.blue_337eff,
              fontSize: 14.spMin,
            ),
          ),
          onTap: () {
            setState(() {
              _edition = _Edition.trial;
            });
          },
        ),
      ],
    );
  }

  Widget buildTrialLoginSubActions() {
    return Row(
      children: <Widget>[
        Text(
          meetingAppLocalizations.authHasCorpCode,
          style: TextStyle(
            color: AppColors.color_666666,
            fontSize: 14.spMin,
          ),
        ),
        GestureDetector(
          child: Text(
            meetingAppLocalizations.authLoginToCorpEdition,
            style: TextStyle(
              color: AppColors.blue_337eff,
              fontSize: 14.spMin,
            ),
          ),
          onTap: () {
            setState(() {
              _corpCodeController.clear();
              _edition = _Edition.corp;
            });
          },
        ),
        Spacer(),
        buildSSO(),
      ],
    );
  }

  GestureDetector buildSSO() {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Text(
          meetingAppLocalizations.authLoginBySSO,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.blue_337eff,
            fontSize: 14.spMin,
          ),
        ),
        onTap: () async {
          if (!await PrivacyUtil.ensurePrivacyAgree(context)) return;
          NavUtils.pushNamed(context, RouterName.ssoLogin,
              arguments: _corpCodeController.text.trim());
        });
  }

  Widget buildIcon() {
    return Container(
      width: 166.w,
      height: 159.h,
      child: Image.asset(
        AssetName.meet,
        //package: AssetName.package,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  void dispose() {
    PrivacyUtil.dispose();
    DeepLinkManager().detach(context);
    _corpCodeController.dispose();
    super.dispose();
  }

  void launchCorpLogin() async {
    if (!await PrivacyUtil.ensurePrivacyAgree(context)) return;
    doIfNetworkAvailable(() async {
      final corpCode = _corpCodeController.text.trim();
      LoadingUtil.showLoading();
      final result = await CorpRepo.getCorpInfo(corpCode: corpCode);
      LoadingUtil.cancelLoading();
      final corpInfo = result.data;
      if (corpInfo == null) {
        ToastUtils.showToast(context, meetingAppLocalizations.authCorpNotFound);
        return;
      }
      NavUtils.pushNamed(context, RouterName.corpAccountLogin,
          arguments: corpInfo);
    });
  }

  //发起URS登录
  void launchTrialLogin() async {
    if (!await PrivacyUtil.ensurePrivacyAgree(context)) return;
    NavUtils.pushNamed(context, RouterName.mobileLogin);
  }
}
