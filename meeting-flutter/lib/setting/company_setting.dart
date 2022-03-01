
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yunxin_meeting/meeting_uikit.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:service/auth/auth_manager.dart';
import 'package:service/client/http_code.dart';
import 'package:service/repo/accountinfo_repo.dart';
import 'package:uikit/state/meeting_base_state.dart';
import 'package:uikit/utils/nav_utils.dart';
import 'package:uikit/utils/router_name.dart';
import 'package:uikit/values/colors.dart';
import 'package:uikit/values/fonts.dart';
import 'package:uikit/values/strings.dart';
import 'package:service/model/account_apps.dart';

class CompanySetting extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _CompanySettingState();
  }
}

class _CompanySettingState extends MeetingBaseState<CompanySetting> {
   var  currentAppKey = MeetingUtil.getAppKey();

   List<Apps> items = <Apps>[];

  @override
  void initState() {
    super.initState();

    /// 获取公司列表
    lifecycleExecuteUI(AccountInfoRepo().getAccountApps()).then((result) {
      if (result == null) return;
      if (result.code == HttpCode.success) {
        items = result.data!.apps;
        setState(() {});
      } else {
        ToastUtils.showToast(context, result.msg ?? Strings.networkUnavailableCheck);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget buildBody() {
    return Container(
        padding: EdgeInsets.only(top: 24),
        child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, itemIndex) {
              return itemIndex == 0 ? Container() : line();
            },
            itemBuilder: (context, index) {
              return buildItem(item: items[index], index: index);
            }));
  }

  @override
  String getTitle() {
    return Strings.company;
  }

  Widget buildItem({required Apps item, required int index}) {
    return Container(
        color: AppColors.white,
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: <Widget>[
        Expanded(
            child:Container(
              alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 24),
                child: Text(
                  item.appName,
                  style: TextStyle(fontSize: 16, color: AppColors.color_222222),
                  textAlign: TextAlign.center,
                ))),
            Spacer(),
            Container(padding: EdgeInsets.only(right: 20), child: roundCheckBox(item.appKey)),
          ],
        ));
  }

  Widget line() {
    return Container(
      color: Colors.white,
      child: Container(
        margin: EdgeInsets.only(left: 24),
        color: AppColors.colorE8E9EB,
        height: 0.5,
      ),
    );
  }

  Widget roundCheckBox(String appKey) {
    return InkWell(
      onTap: () {
        loadLoginInfo(appKey);
      },
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border.all(color: currentAppKey == appKey ? Colors.white : Colors.grey, width: 0.5), // 边色与边宽度
          color: Colors.white, // 底色
          shape: BoxShape.circle,
        ), // 圆角度
        child: currentAppKey == appKey
            ? Icon(
                IconFont.iconyx_pc_successx,
                size: 20.0,
                color: Colors.blue,
              )
            : Container(),
      ),
    );
  }

  void loadLoginInfo(String appKey) {
    AuthManager().updateAppKey(appKey);
    if (appKey == currentAppKey) {
      return;
    }
    lifecycleExecuteUI(AccountInfoRepo().switchApp()).then((result) {
      if (result == null) return;
      switch (result.code) {
        case HttpCode.success:
          AuthManager().logout();
          NavUtils.pushNamedAndRemoveUntil(context, RouterName.entrance);
          break;
        default:
          ToastUtils.showToast(context, Strings.switchCompanyFail);
          break;
      }
    });
  }
}
