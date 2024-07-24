// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/language/localizations.dart';
import 'package:nemeeting/service/config/login_type.dart';
import 'package:nemeeting/service/config/servers.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:nemeeting/webview/webview_page.dart';
import 'package:nemeeting/widget/ne_widget.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/utils/nav_utils.dart';
import '../uikit/utils/router_name.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/dimem.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

class AccountAndSafetySettingRoute extends StatefulWidget {
  AccountAndSafetySettingRoute();

  @override
  State<StatefulWidget> createState() {
    return _AccountAndSafetySettingState();
  }
}

class _AccountAndSafetySettingState
    extends AppBaseState<AccountAndSafetySettingRoute> {
  static const String TAG = 'AccountAndSafetySettingRoute';
  @override
  Widget buildBody() {
    final child = Container(
      padding: EdgeInsets.only(left: 16.w, right: 16.w),
      child: Column(
        children: <Widget>[
          _buildWideSplit(),
          NESettingItemGroup(
            children: [
              _buildMobileItem(),
              _buildEmailItem(),
            ],
          ),
          _buildWideSplit(),
          NESettingItemGroup(children: [
            if (canModifyPwd()) _buildModifyPwd(),
            if (canDeleteAccount()) _buildDeleteAccount(),
          ]),
        ],
      ),
    );
    return NEAccountInfoBuilder(
      child: child,
    );
  }

  Widget _buildMobileItem() {
    return NESettingItem(
      getAppLocalizations().authMobileNum,
      arrowTip: getMobile(),
      showArrow: false,
    );
  }

  Widget _buildEmailItem() {
    return NESettingItem(
      getAppLocalizations().settingEmail,
      arrowTip: AuthManager().email ?? getAppLocalizations().authUnavailable,
      showArrow: false,
    );
  }

  Widget _buildDeleteAccount() {
    return NESettingItem(getAppLocalizations().settingDeleteAccount,
        arrowTip: '', showArrow: true, onTap: () {
      if (NEMeetingKit.instance.getMeetingService().getCurrentMeetingInfo() !=
          null) {
        ToastUtils.showToast(context,
            getAppLocalizations().meetingOperationNotSupportedInMeeting);
        return;
      }
      if (Servers().deleteAccountWebServiceUrl?.isNotEmpty ?? false) {
        var uri = Uri.parse(Servers().deleteAccountWebServiceUrl!);
        uri = uri.replace(queryParameters: {
          if (AuthManager().appKey != null) 'appKey': AuthManager().appKey!,
          if (AuthManager().accountId != null) 'id': AuthManager().accountId!,
          if (AuthManager().accountToken != null)
            't': AuthManager().accountToken!,
        });
        NavUtils.pushNamed(context, RouterName.webview,
            arguments: WebViewArguments(
                uri.toString(), getAppLocalizations().settingDeleteAccount));
      } else {
        Alog.e(tag: TAG, content: "deleteAccountWebServiceUrl is empty");
      }
    });
  }

  Widget _buildModifyPwd() {
    return NESettingItem(
      getAppLocalizations().settingModifyPassword,
      showArrow: true,
      onTap: () => NavUtils.pushNamed(context, RouterName.modifyPassword),
    );
  }

  Widget _buildWideSplit() {
    return Container(
      color: AppColors.globalBg,
      height: Dimen.globalHeightPadding,
    );
  }

  @override
  String getTitle() {
    return getAppLocalizations().settingAccountAndSafety;
  }

  bool canModifyPwd() {
    return AuthManager().loginType == LoginType.password;
  }

  bool canDeleteAccount() {
    return AuthManager().loginType == LoginType.verify;
  }

  String getMobile() {
    return MeetingUtil.getMobilePhone().isEmpty
        ? getAppLocalizations().authUnavailable
        : StringUtil.hideMobileNumMiddleFour(MeetingUtil.getMobilePhone());
  }
}
