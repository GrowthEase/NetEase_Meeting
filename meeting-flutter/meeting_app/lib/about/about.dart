// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/uikit/values/dimem.dart';
import 'package:nemeeting/widget/ne_widget.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';
import 'package:nemeeting/service/config/app_config.dart';
import 'package:nemeeting/service/config/servers.dart';

import '../language/localizations.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/utils/nav_utils.dart';
import '../uikit/values/asset_name.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/fonts.dart';

import 'package:yunxin_alog/yunxin_alog.dart';
import '../webview/webview_page.dart';

class About extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AboutState();
  }
}

class _AboutState extends AppBaseState<About> {
  static const String TAG = 'About';
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
    return getAppLocalizations().settingAbout;
  }

  Color get backgroundColor => AppColors.white;

  @override
  Widget buildBody() {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: Dimen.settingItemHorizontalPadding),
      color: AppColors.globalBg,
      child: ListView(
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
          NESettingItemGroup(children: [
            buildProtocol(),
            buildPrivacy(),
            SizedBox(
              height: 56.h,
            ),
          ]),
          SizedBox(
            height: 216.h,
          ),
          buildAppRegistryNO(),
          SizedBox(
            height: 10.h,
          ),
          buildCopyright(),
        ],
      ),
    );
  }

  Widget buildUpgrade() {
    return NEGestureDetector(
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: <Widget>[
            Text(
              getAppLocalizations().settingCheckUpdate,
              style: TextStyle(
                  fontSize: 16,
                  color: AppColors.black_222222,
                  fontWeight: FontWeight.w500),
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
                getAppLocalizations().settingFindNewVersion,
                style: TextStyle(
                    fontSize: 16.spMin, color: AppColors.color_999999),
              ),
            NESettingItemArrow(),
          ],
        ),
      ),
      onTap: () async {
        if (NEMeetingKit.instance.getMeetingService().getCurrentMeetingInfo() !=
            null) {
          ToastUtils.showToast(context,
              getAppLocalizations().meetingOperationNotSupportedInMeeting);
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
      '${getAppLocalizations().settingVersion}${AppConfig().versionName}.${AppConfig().versionCode}',
      style: TextStyle(color: AppColors.color_999999, fontSize: 12.spMin),
      textAlign: TextAlign.center,
    );
  }

  Widget buildProtocol() {
    return NESettingItem(getAppLocalizations().authServiceAgreement, onTap: () {
      if (Servers().userProtocol?.isNotEmpty ?? false) {
        Navigator.push(
            context,
            NEMeetingPageRoute(
                builder: (context) => WebViewPage(WebViewArguments(
                    Servers().userProtocol,
                    getAppLocalizations().authServiceAgreement))));
      } else {
        Alog.e(tag: TAG, content: "userProtocol is empty");
      }
    });
  }

  Widget buildPrivacy() {
    return NESettingItem(getAppLocalizations().authPrivacy, onTap: () {
      if (Servers().privacy?.isNotEmpty ?? false) {
        Navigator.push(
            context,
            NEMeetingPageRoute(
                builder: (context) => WebViewPage(WebViewArguments(
                    Servers().privacy, getAppLocalizations().authPrivacy))));
      } else {
        Alog.e(tag: TAG, content: "privacy is empty");
      }
    });
  }

  Widget buildCopyright() {
    return Text(
      getAppLocalizations().globalCopyright,
      textAlign: TextAlign.center,
      style: TextStyle(color: AppColors.color_999999, fontSize: 12.spMin),
    );
  }

  // 备案号
  Widget buildAppRegistryNO() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NEGestureDetector(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              getAppLocalizations().globalAppRegistryNO,
              style: TextStyle(
                color: AppColors.color_333333,
                fontSize: 12.spMin,
              ),
            ),
          ),
          onTap: () {},
        ),
        Icon(
          IconFont.iconyx_allowx,
          size: 10,
          color: AppColors.color_8D90A0,
        ),
      ],
    );
  }

  @override
  Color getAppBarBackgroundColor() {
    return AppColors.globalBg;
  }
}
