// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import 'package:nemeeting/service/config/app_config.dart';
import 'package:nemeeting/service/config/servers.dart';

import '../uikit/state/meeting_base_state.dart';
import '../uikit/utils/nav_utils.dart';
import '../uikit/utils/router_name.dart';
import '../uikit/values/asset_name.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/dimem.dart';
import '../uikit/values/fonts.dart';
import '../uikit/values/strings.dart';
import 'package:nemeeting/arguments/webview_arguments.dart';

import '../webview/webview_page.dart';

class About extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AboutState();
  }
}

class _AboutState extends MeetingBaseState<About> {

  @override
  String getTitle() {
    return Strings.about;
  }

  @override
  Widget buildBody() {
    return SafeArea(
        left: false,
        right: false,
        top: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildIcon(),
            buildVersion(),
            SizedBox(
              height: 40,
            ),
            buildProtocol(),
            buildSplit(),
            buildPrivacy(),
            SizedBox(
              height: 12,
            )
          ],
        ));
  }

  Widget buildIcon() {
    return Container(
      margin: EdgeInsets.only(top: 42, bottom: 3),
      width: 124,
      height: 118,
      child: Image.asset(
        AssetName.aboutIcon,
        //package: AssetName.package,
        fit: BoxFit.none,
      ),
    );
  }

  Widget buildVersion() {
    return Text(
      '${Strings.version}${AppConfig().versionName}.${AppConfig().versionCode}',
      style: TextStyle(color: AppColors.black_333333, fontSize: 12),
      textAlign: TextAlign.center,
    );
  }

  Widget buildProtocol() {
    return buildItem(
        Strings.user_protocol,
        () => NavUtils.pushNamed(context, RouterName.webview,
            arguments:
                WebViewArguments(servers.userProtocol, Strings.user_protocol)));
  }

  Widget buildPrivacy() {
    return buildItem(
        Strings.privacy,
        () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebViewPage(
                    WebViewArguments(servers.privacy, Strings.privacy)))));
    // NavUtils.pushNamed(context, RouterName.webview,
    // arguments: WebViewArguments(servers.privacy, Strings.privacy)));
  }

  // Widget buildPlayer() {
  //   return buildItem(Strings.livePlayer,
  //       () => NavUtils.pushNamed(context, RouterName.playerConfig));
  // }

  Container buildSplit() {
    return Container(
      padding: EdgeInsets.only(left: 20),
      color: AppColors.white,
      child: Container(
        color: AppColors.globalBg,
      ),
      height: 1,
    );
  }

  Widget buildItem(String title, VoidCallback fun) {
    return GestureDetector(
      child: Container(
        height: Dimen.primaryItemHeight,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
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
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Text(
          Strings.copyright,
          style: TextStyle(color: AppColors.black_333333, fontSize: 12),
        ),
      ),
    );
  }
}
