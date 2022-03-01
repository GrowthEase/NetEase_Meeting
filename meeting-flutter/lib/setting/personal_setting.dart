// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:base/util/textutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yunxin_meeting/meeting_sdk.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:service/config/app_config.dart';
import 'package:service/config/login_type.dart';
import 'package:uikit/state/meeting_base_state.dart';
import 'package:uikit/utils/nav_utils.dart';
import 'package:uikit/utils/router_name.dart';
import 'package:uikit/values/colors.dart';
import 'package:uikit/values/dimem.dart';
import 'package:uikit/values/fonts.dart';
import 'package:uikit/values/strings.dart';
import 'package:service/auth/auth_manager.dart';
import 'package:nemeeting/arguments/auth_arguments.dart';

class PersonalSetting extends StatefulWidget {
  final String companyName;
  PersonalSetting(this.companyName);
  @override
  State<StatefulWidget> createState() {
    return _PersonalSettingState();
  }
}

class _PersonalSettingState extends MeetingBaseState<PersonalSetting> {
  @override
  void initState() {
    super.initState();
    lifecycleListen(AuthManager().authInfoStream(), (event) {
      setState(() {});
    });
  }

  @override
  Widget buildBody() {
    return Column(
      children: <Widget>[
        Container(
          color: AppColors.globalBg,
          height: Dimen.globalPadding,
        ),
        buildHead(),
        _buildSplit(),
        buildPersonItem(title:Strings.nick,arrowTip:MeetingUtil.getNickName(),isShowArrow:canModifyNick(),onTap: () {
          if (canModifyNick()) {
            NavUtils.pushNamed(context, RouterName.nickSetting);
          }
        }),
        _buildSplit(),
        buildPersonItem(title: Strings.company, arrowTip: widget.companyName, isShowArrow:canSwitchCompany(),onTap: () {
          if(canSwitchCompany()) {
            NavUtils.pushNamed(context, RouterName.companySetting);
          }
        }),
        if(!TextUtil.isEmpty(MeetingUtil.getMobilePhone()) || canModifyPwd()) Container(
          color: AppColors.globalBg,
          height: Dimen.globalPadding,
        ),
        if (!TextUtil.isEmpty(MeetingUtil.getMobilePhone())) ...buildMobile(),
        if (canModifyPwd()) buildModifyPwd(),
        Container(
          color: AppColors.globalBg,
          height: Dimen.globalPadding,
        ),
        if (!TextUtil.isEmpty(MeetingUtil.getShortMeetingId())) ...buildShortMeetingId(),
        buildMeetingId(),
        Container(
          color: AppColors.globalBg,
          height: Dimen.globalPadding,
        ),
        buildLogout(),
        Expanded(
          flex: 1,
          child: Container(
            color: AppColors.globalBg,
          ),
        )
      ],
    );
  }

  Container buildEmail() {
    return Container(
      height: Dimen.primaryItemHeight,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
      child: Row(
        children: <Widget>[
          Text(
            Strings.email,
            style: TextStyle(fontSize: 16, color: AppColors.black_222222),
          ),
          Spacer(),
          // Text(
          //   AuthManager().userOpenId ?? "",
          //   style: TextStyle(fontSize: 14, color: AppColors.color_999999),
          // ),
        ],
      ),
    );
  }

  GestureDetector buildLogout() {
    return GestureDetector(
      child: Container(
        height: Dimen.primaryItemHeight,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
        alignment: Alignment.center,
        child: Text(
          Strings.logout,
          style: TextStyle(fontSize: 17, color: AppColors.colorFE3B30),
        ),
      ),
      onTap: () => showLogoutActionSheet(),
    );
  }

  Container buildMeetingId() {
    return Container(
      height: Dimen.primaryItemHeight,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
      child: Row(
        children: <Widget>[
          Text(
            Strings.personalMeetingId,
            style: TextStyle(fontSize: 16, color: AppColors.black_222222),
          ),
          Spacer(),
          GestureDetector(
            child: Text(
              TextUtil.applyMask(
                  NEMeetingSDK.instance
                          .getAccountService()
                          .getAccountInfo()
                          ?.roomId ??
                      '',
                  '000-000-0000'),
              style: TextStyle(fontSize: 14, color: AppColors.color_999999),
            ),
            onTap: () {
              NavUtils.toDeveloper(context);
            },
          ),
        ],
      ),
    );
  }

  List<Widget> buildShortMeetingId() {
    return [
      Container(
        height: Dimen.primaryItemHeight,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
        child: Row(
          children: <Widget>[
            Text(
              Strings.personalShortMeetingId,
              style: TextStyle(fontSize: 16, color: AppColors.black_222222),
            ),
             Container(
              margin: EdgeInsets.only(left: 6),
              padding: EdgeInsets.only(left: 6, right: 6, bottom: 2),
              decoration:  BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: AppColors.color_1a337eff,
                  border:  Border.all(color: AppColors.color_33337eff)),
              child: Text(
                Strings.internalSpecial,
                style: TextStyle(fontSize: 12, color: AppColors.color_337eff),
              ),
            ),
            Spacer(),
            GestureDetector(
              child: Text(
                MeetingUtil.getShortMeetingId(),
                style: TextStyle(fontSize: 14, color: AppColors.color_999999),
              ),
              onTap: () {
                NavUtils.toDeveloper(context);
              },
            ),
          ],
        ),
      ),
      _buildSplit(),
    ];
  }

  GestureDetector buildModifyPwd() {
    return GestureDetector(
      child: Container(
        height: Dimen.primaryItemHeight,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
        child: Row(
          children: <Widget>[
            Text(
              Strings.modifyPassword,
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
      onTap: () => NavUtils.pushNamed(context, RouterName.passwordVerify,
          arguments: AuthArguments()),
    );
  }

  List<Widget> buildMobile() {
    return [
      Container(
        height: Dimen.primaryItemHeight,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
        child: Row(
          children: <Widget>[
            Text(
              Strings.mobile,
              style: TextStyle(fontSize: 16, color: AppColors.black_222222),
            ),
            Spacer(),
            Text(
              AuthManager().mobilePhone ?? '',
              style: TextStyle(fontSize: 14, color: AppColors.color_999999),
            ),
          ],
        ),
      ),
      _buildSplit(),
    ];
  }

  GestureDetector buildPersonItem({required String title, required String arrowTip, bool isShowArrow = true, VoidCallback? onTap}) {
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
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  arrowTip,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: AppColors.color_999999),
                ),
              ),
            ),
            SizedBox(
              width: 8,
            ),
            if (isShowArrow)
              Icon(
                IconFont.iconyx_allowx,
                size: 14,
                color: AppColors.greyCCCCCC,
              )
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  Container buildHead() {
    return Container(
      height: Dimen.primaryItemHeight,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
      child: Row(
        children: <Widget>[
          Text(
            Strings.head,
            style: TextStyle(fontSize: 16, color: AppColors.black_222222),
          ),
          Spacer(),
          ClipOval(
              child: Container(
            height: 32,
            width: 32,
            decoration: ShapeDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[AppColors.blue_5996FF, AppColors.blue_2575FF],
                ),
                shape: Border()),
            alignment: Alignment.center,
            child: Text(
              MeetingUtil.getCurrentNickLeading(),
              style: TextStyle(fontSize: 21, color: Colors.white),
            ),
          )),
        ],
      ),
    );
  }

  void showLogoutActionSheet() {
    showCupertinoModalPopup<String>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              title: Text(
                Strings.confirmLogout,
                style: TextStyle(color: AppColors.grey_8F8F8F, fontSize: 13),
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                    child: Text(Strings.logout,
                        style: TextStyle(color: AppColors.colorFE3B30)),
                    onPressed: () {
                      AuthManager().logout();
                      NavUtils.pushNamedAndRemoveUntil(
                          context, RouterName.entrance);
                    }),
              ],
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text(Strings.cancel,
                    style: TextStyle(color: AppColors.color_007AFF)),
                onPressed: () {
                  Navigator.pop(context, Strings.cancel);
                },
              ),
            ));
  }

  void showLogoutDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(Strings.confirmLogout),
//            content: Text(Strings.confirmLogout),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(Strings.cancel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text(Strings.logout),
                onPressed: () {
                  AuthManager().logout();
                  NavUtils.pushNamedAndRemoveUntil(
                      context, RouterName.entrance);
                },
              ),
            ],
          );
        });
  }

  Container _buildSplit() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(left: 20),
      height: 1,
      child: Divider(height: 1),
    );
  }

  @override
  String getTitle() {
    return Strings.personalCenter;
  }

  bool canModifyNick() {
    return AppConfig().isPublicFlavor &&
        (AuthManager().loginType != LoginType.sso.index);
  }

  bool canModifyPwd() {
    return AppConfig().isPublicFlavor &&
        (AuthManager().loginType != LoginType.sso.index);
  }

  bool canSwitchCompany() {
    return AppConfig().isPublicFlavor &&
        (AuthManager().loginType != LoginType.sso.index);
  }
}
