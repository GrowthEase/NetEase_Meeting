// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/base/util/text_util.dart';
import 'package:nemeeting/language/localizations.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/config/app_config.dart';
import 'package:nemeeting/service/model/account_app_info.dart';
import 'package:nemeeting/service/repo/accountinfo_repo.dart';
import 'package:nemeeting/setting/personal_setting.dart';
import 'package:nemeeting/uikit/state/meeting_base_state.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/widget/ne_widget.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/uikit/utils/nav_utils.dart';
import 'package:nemeeting/uikit/utils/router_name.dart';
import 'package:nemeeting/uikit/values/colors.dart';

class AppSettingRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppSettingRouteState();
  }
}

class _AppSettingRouteState extends AppBaseState<AppSettingRoute> {
  bool bCanPress = true;
  bool vCanPress = true; //虚拟背景防暴击
  late final meetingAccountService = NEMeetingKit.instance.getAccountService();
  AccountAppInfo? _accountAppInfo;

  @override
  void initState() {
    super.initState();
    AccountInfoRepo().getAccountAppInfo().then((result) {
      if (mounted && result.code == HttpCode.success) {
        setState(() {
          _accountAppInfo = result.data;
        });
      }
    });
  }

  @override
  Widget buildBody() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(left: 16.w, right: 16.w),
        child: Column(
          children: <Widget>[
            buildUserProfile(),
            NESettingItemGroup(children: [
              buildServiceBundleInfo(),
            ]),
            NESettingItemGap(),
            NESettingItemGroup(children: [
              if (MeetingUtil.hasShortMeetingNum())
                NESettingItem(
                    getAppLocalizations().meetingPersonalShortMeetingID,
                    tag: getAppLocalizations().settingInternalDedicated,
                    arrowTip: MeetingUtil.getShortMeetingNum(),
                    showArrow: false),
              NESettingItem(getAppLocalizations().meetingPersonalMeetingID,
                  arrowTip: TextUtil.applyMask(
                      NEMeetingKit.instance
                              .getAccountService()
                              .getAccountInfo()
                              ?.privateMeetingNum ??
                          '',
                      '000-000-0000'),
                  showArrow: false),
            ]),
            NESettingItemGap(),
            NESettingItemGroup(
              children: [
                NESettingItem(getAppLocalizations().settingMeeting,
                    onTap: () =>
                        NavUtils.pushNamed(context, RouterName.meetingSetting)),
                NESettingItem(getAppLocalizations().settingSwitchLanguage,
                    onTap: () =>
                        NavUtils.pushNamed(context, RouterName.languageSetting),
                    arrowTip: getAppLocalizations().settingLanguageTip),
              ],
            ),
            Builder(builder: (context) {
              return Visibility(
                visible: context.isBeautyFaceEnabled ||
                    context.isVirtualBackgroundEnabled,
                child: SizedBox(
                  height: 20.h,
                ),
              );
            }),
            NESettingItemGroup(children: [
              Builder(
                builder: (context) {
                  return context.isBeautyFaceEnabled
                      ? Container(
                          child: NESettingItem(
                              getAppLocalizations().settingBeauty, onTap: () {
                            if (NEMeetingUIKit.instance
                                    .getCurrentMeetingInfo() !=
                                null) {
                              ToastUtils.showToast(
                                  context,
                                  getAppLocalizations()
                                      .meetingOperationNotSupportedInMeeting);
                              return;
                            }
                            if (bCanPress) {
                              bCanPress = false;
                              NEMeetingUIKit.instance.openBeautyUI(context);
                              Future.delayed(Duration(milliseconds: 500),
                                  () => bCanPress = true);
                            }
                          }),
                        )
                      : SizedBox.shrink();
                },
              ),
              Builder(
                builder: (context) {
                  return context.isVirtualBackgroundEnabled
                      ? Container(
                          child: NESettingItem(
                              getAppLocalizations().settingVirtualBackground,
                              onTap: () {
                            if (NEMeetingUIKit.instance
                                    .getCurrentMeetingInfo() !=
                                null) {
                              ToastUtils.showToast(
                                  context,
                                  getAppLocalizations()
                                      .meetingOperationNotSupportedInMeeting);
                              return;
                            }
                            if (vCanPress) {
                              vCanPress = false;
                              NEMeetingUIKit.instance
                                  .openVirtualBackgroundBeautyUI(context);
                              Future.delayed(Duration(milliseconds: 500),
                                  () => vCanPress = true);
                            }
                          }),
                        )
                      : SizedBox.shrink();
                },
              ),
            ]),
            NESettingItemGap(),
            NESettingItemGroup(children: [
              NESettingItem(getAppLocalizations().settingAbout,
                  onTap: () => NavUtils.pushNamed(context, RouterName.about)),
            ]),
            Container(
              height: 22.h,
              color: AppColors.globalBg,
            ),
          ],
        ),
      ),
    );
  }

  @override
  String getTitle() {
    return getAppLocalizations().settings;
  }

  Widget buildUserProfile() {
    return NEAccountInfoBuilder(builder: (context, accountInfo, _) {
      return NEGestureDetector(
          child: Container(
            key: MeetingValueKey.personalSetting,
            height: (48 + 20 + 18).h,
            padding: EdgeInsets.only(top: 20.h, bottom: 16.h),
            child: Row(
              children: <Widget>[
                NEMeetingAvatar.xlarge(
                  name: accountInfo.nickname,
                  url: accountInfo.avatar,
                ),
                Padding(padding: EdgeInsets.only(left: 12.w)),
                Expanded(
                  child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Spacer(),
                          Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(bottom: 2.h),
                              child: Text(
                                StringUtil.truncate(accountInfo.nickname),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.black_222222,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.ltr,
                                key: MeetingValueKey.nickName,
                              )),
                          Container(
                            width:
                                (MediaQuery.of(context).size.width * 2 / 3).w,
                            child: Text(
                              accountInfo.corpName ??
                                  getAppLocalizations()
                                      .settingDefaultCompanyName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.color_999999,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Spacer(),
                        ]),
                  ),
                ),
                NESettingItemArrow(),
                SizedBox(width: 15.w),
              ],
            ),
          ),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PersonalSetting(
                      _accountAppInfo?.appName ??
                          getAppLocalizations().settingDefaultCompanyName))));
    });
  }

  Widget buildServiceBundleInfo() {
    return NEAccountInfoBuilder(builder: (context, accountInfo, _) {
      final serviceBundle = accountInfo.serviceBundle;
      if (serviceBundle == null) {
        return SizedBox.shrink();
      }
      final serviceBundleDetail = serviceBundle.isUnlimited
          ? getAppLocalizations().settingServiceBundleDetailUnlimitedMinutes(
              serviceBundle.maxMembers)
          : getAppLocalizations().settingServiceBundleDetailLimitedMinutes(
              serviceBundle.maxMembers, serviceBundle.maxMinutes!);
      final serviceBundleExpireTime = getAppLocalizations()
          .settingServiceBundleExpireTime(
              MeetingTimeUtil.getTimeFormatYMD(serviceBundle.expireTimestamp));
      return Container(
        padding: EdgeInsets.all(16.w),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    getAppLocalizations().settingServiceBundleTitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.color_8D90A0,
                    ),
                  ),
                  if (!serviceBundle.isNeverExpired) Spacer(),
                  if (!serviceBundle.isNeverExpired)
                    Text(
                      serviceBundleExpireTime,
                      style: TextStyle(
                        fontSize: 14.w,
                        color: AppColors.color_999999,
                      ),
                    ),
                ],
              ),
              SizedBox(
                height: 8.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 2.w),
                  Container(
                    decoration: ShapeDecoration(
                      color: AppColors.color_8D90A0,
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    transform: Matrix4.rotationZ(pi / 4),
                    width: 4.w,
                    height: 4.h,
                  ),
                  SizedBox(
                    width: 4.w,
                  ),
                  Expanded(
                      child: Text(
                    serviceBundleDetail,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1,
                      color: AppColors.color_1E1F27,
                    ),
                  )),
                ],
              ),
              if (!serviceBundle.isNeverExpired)
                Container(
                  height: 1.h,
                  margin: EdgeInsets.only(top: 10.h, bottom: 10.h),
                  color: AppColors.colorE8E9EB,
                ),
              if (!serviceBundle.isNeverExpired)
                Text(
                  serviceBundle.expireTip,
                  style: TextStyle(
                    fontSize: 14.w,
                    color: AppColors.color_666666,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Color getAppBarBackgroundColor() {
    return AppColors.globalBg;
  }
}
