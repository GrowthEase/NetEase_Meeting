// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import 'package:nemeeting/service/config/app_config.dart';
import 'package:nemeeting/service/config/servers.dart';

import '../language/localizations.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/utils/nav_utils.dart';
import '../uikit/values/asset_name.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/dimem.dart';
import '../uikit/values/fonts.dart';

import '../webview/webview_page.dart';

class About extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AboutState();
  }
}

class _AboutState extends MeetingBaseState<About>
    with MeetingAppLocalizationsMixin {
  bool newVersionTips = false;

  @override
  void initState() {
    super.initState();
    parseNewVersionTips();
  }

  void parseNewVersionTips() {
    newVersionTips = false;
  }

  @override
  String getTitle() {
    return meetingAppLocalizations.settingAbout;
  }

  Color get backgroundColor => AppColors.white;

  @override
  Widget buildBody() {
    return ListView(
      children: <Widget>[
        SizedBox(
          height: 40.h,
        ),
        buildIcon(),
        SizedBox(
          height: 12.h,
        ),
        buildVersion(),
        SizedBox(
          height: 40.h,
        ),
        buildSplit(),
        buildProtocol(),
        buildSplit(),
        buildPrivacy(),
        buildSplit(),
        ...[
          SizedBox(
            height: 56.h,
          ),
        ],
        SizedBox(
          height: 216.h,
        ),
        buildAppRegistryNO(),
        SizedBox(
          height: 10.h,
        ),
        buildCopyright(),
      ],
    );
  }

  Widget buildUpgrade() {
    return GestureDetector(
      child: Container(
        height: 56.h,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          children: <Widget>[
            Text(
              meetingAppLocalizations.settingCheckUpdate,
              style: TextStyle(fontSize: 16, color: AppColors.black_222222),
            ),
            Spacer(),
            if (newVersionTips)
              Icon(
                Icons.fiber_manual_record,
                color: AppColors.colorFE3B30,
                size: 9,
              ),
            if (newVersionTips)
              Text(
                meetingAppLocalizations.settingFindNewVersion,
                style: TextStyle(fontSize: 16, color: AppColors.color_999999),
              ),
            Icon(
              IconFont.iconyx_allowx,
              size: 14,
              color: AppColors.greyCCCCCC,
            )
          ],
        ),
      ),
      onTap: () async {
        if (NEMeetingUIKit().getCurrentMeetingInfo() != null) {
          ToastUtils.showToast(context,
              meetingAppLocalizations.meetingOperationNotSupportedInMeeting);
          return;
        }
      },
    );
  }

  Widget buildIcon() {
    return SizedBox(
      width: 124.w,
      height: 118.h,
      child: Image.asset(
        AssetName.aboutIcon,
        //package: AssetName.package,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget buildVersion() {
    return Text(
      '${meetingAppLocalizations.settingVersion}${AppConfig().versionName}.${AppConfig().versionCode}',
      style: TextStyle(color: AppColors.color_999999, fontSize: 12),
      textAlign: TextAlign.center,
    );
  }

  Widget buildProtocol() {
    return buildItem(
        meetingAppLocalizations.authServiceAgreement,
        () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebViewPage(WebViewArguments(
                    Servers.userProtocol,
                    meetingAppLocalizations.authServiceAgreement)))));
  }

  Widget buildPrivacy() {
    return buildItem(
        meetingAppLocalizations.authPrivacy,
        () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebViewPage(WebViewArguments(
                    Servers.privacy, meetingAppLocalizations.authPrivacy)))));
  }

  Container buildSplit() {
    return Container(
      padding: EdgeInsets.only(left: 20.w),
      color: AppColors.white,
      child: Container(
        color: AppColors.globalBg,
      ),
      height: 1.h,
    );
  }

  Widget buildItem(String title, VoidCallback fun) {
    return GestureDetector(
      child: Container(
        height: 56.h,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontSize: 16, color: AppColors.black_222222),
            ),
            Spacer(),
            Icon(
              IconFont.iconyx_allowx,
              size: 14,
              color: AppColors.greyCCCCCC,
            )
          ],
        ),
      ),
      onTap: fun,
    );
  }

  Widget buildCopyright() {
    return Text(
      meetingAppLocalizations.globalCopyright,
      textAlign: TextAlign.center,
      style: TextStyle(color: AppColors.color_999999, fontSize: 12),
    );
  }

  // 备案号
  Widget buildAppRegistryNO() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              meetingAppLocalizations.globalAppRegistryNO,
              style: TextStyle(
                color: AppColors.color_333333,
                fontSize: 12,
              ),
            ),
          ),
          onTap: () {
            NavUtils.launchByURL(Servers.appRegistryDetailUrl);
          },
        ),
        Icon(
          IconFont.iconyx_allowx,
          size: 10,
          color: AppColors.color_333333,
        ),
      ],
    );
  }
}
