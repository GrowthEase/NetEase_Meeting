// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:nemeeting/language/localizations.dart';
import 'package:nemeeting/service/config/login_type.dart';
import 'package:nemeeting/service/config/servers.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:nemeeting/webview/webview_page.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/utils/nav_utils.dart';
import '../uikit/utils/router_name.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/dimem.dart';
import '../uikit/values/fonts.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';

class AccountAndSafetySettingRoute extends StatefulWidget {
  AccountAndSafetySettingRoute();

  @override
  State<StatefulWidget> createState() {
    return _AccountAndSafetySettingState();
  }
}

class _AccountAndSafetySettingState
    extends MeetingBaseState<AccountAndSafetySettingRoute>
    with MeetingAppLocalizationsMixin {
  @override
  Widget buildBody() {
    final child = Column(
      children: <Widget>[
        _buildWideSplit(),
        _buildMobileItem(),
        _buildSplit(),
        _buildEmailItem(),
        _buildWideSplit(),
        if (canModifyPwd()) _buildModifyPwd(),
        if (canDeleteAccount()) ...[
          _buildSplit(),
          _buildDeleteAccount(),
        ],
      ],
    );
    return ListenableBuilder(
      listenable: NEMeetingKit.instance.getAccountService(),
      builder: (context, child) => child!,
      child: child,
    );
  }

  Widget _buildMobileItem() {
    return _buildItem(
      title: meetingAppLocalizations.authMobileNum,
      arrowTip: getMobile(),
      isShowArrow: false,
    );
  }

  Widget _buildEmailItem() {
    return _buildItem(
      title: meetingAppLocalizations.settingEmail,
      arrowTip: AuthManager().email ?? meetingAppLocalizations.authUnavailable,
      isShowArrow: false,
    );
  }

  Widget _buildDeleteAccount() {
    return _buildItem(
        title: meetingAppLocalizations.settingDeleteAccount,
        arrowTip: '',
        isShowArrow: true,
        onTap: () {
          if (NEMeetingUIKit().getCurrentMeetingInfo() != null) {
            ToastUtils.showToast(context,
                meetingAppLocalizations.meetingOperationNotSupportedInMeeting);
            return;
          }
          var uri = Uri.parse(Servers.deleteAccountWebServiceUrl);
          uri = uri.replace(queryParameters: {
            if (AuthManager().appKey != null) 'appKey': AuthManager().appKey!,
            if (AuthManager().accountId != null) 'id': AuthManager().accountId!,
            if (AuthManager().accountToken != null)
              't': AuthManager().accountToken!,
          });
          NavUtils.pushNamed(context, RouterName.webview,
              arguments: WebViewArguments(uri.toString(),
                  meetingAppLocalizations.settingDeleteAccount));
        });
  }

  Widget _buildModifyPwd() {
    return GestureDetector(
      child: Container(
        height: Dimen.primaryItemHeight,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
        child: Row(
          children: <Widget>[
            Text(
              meetingAppLocalizations.settingModifyPassword,
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
      onTap: () => NavUtils.pushNamed(context, RouterName.modifyPassword),
    );
  }

  GestureDetector _buildItem(
      {required String title,
      String arrowTip = '',
      bool isShowArrow = true,
      VoidCallback? onTap}) {
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
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Text(
                arrowTip,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 14, color: AppColors.color_999999),
              ),
            ),
            if (isShowArrow) ...[
              SizedBox(
                width: 8,
              ),
              Icon(
                IconFont.iconyx_allowx,
                size: 14,
                color: AppColors.greyCCCCCC,
              ),
            ]
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  Container _buildSplit() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(left: 20),
      height: 0.5,
      child: Divider(height: 0.5),
    );
  }

  Widget _buildWideSplit() {
    return Container(
      color: AppColors.globalBg,
      height: Dimen.globalPadding,
    );
  }

  @override
  String getTitle() {
    return meetingAppLocalizations.settingAccountAndSafety;
  }

  bool canModifyPwd() {
    return AuthManager().loginType == LoginType.password.index;
  }

  bool canDeleteAccount() {
    return AuthManager().loginType == LoginType.verify.index;
  }

  String getMobile() {
    return MeetingUtil.getMobilePhone().isEmpty
        ? meetingAppLocalizations.authUnavailable
        : StringUtil.hideMobileNumMiddleFour(MeetingUtil.getMobilePhone());
  }
}
