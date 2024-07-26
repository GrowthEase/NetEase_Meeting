// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nemeeting/base/util/text_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:nemeeting/widget/ne_widget.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';
import '../language/localizations.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/utils/nav_utils.dart';
import '../uikit/utils/router_name.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/dimem.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';

import '../utils/integration_test.dart';
import 'dart:io';

class PersonalSetting extends StatefulWidget {
  final String companyName;

  PersonalSetting(this.companyName);

  @override
  State<StatefulWidget> createState() {
    return _PersonalSettingState();
  }
}

class _PersonalSettingState extends AppBaseState<PersonalSetting> {
  final settingsService = NEMeetingKit.instance.getSettingsService();

  @override
  Widget buildBody() {
    return Column(children: <Widget>[
      Expanded(
          child: SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.only(left: 16.w, right: 16.w),
                  child: Column(
                    children: <Widget>[
                      NESettingItemGap(),
                      NESettingItemGroup(children: [
                        buildHead(),
                        NEAccountInfoBuilder(
                          builder: (context, accountInfo, _) {
                            return NESettingItem(
                                getAppLocalizations().settingNick,
                                arrowTip: accountInfo.nickname,
                                showArrow: canModifyNick(), onTap: () {
                              if (canModifyNick()) {
                                NavUtils.pushNamed(
                                    context, RouterName.nickSetting);
                              }
                            });
                          },
                        ),
                      ]),
                      NESettingItemGap(),
                      NESettingItemGroup(children: [
                        if (!TextUtil.isEmpty(MeetingUtil.getShortMeetingNum()))
                          NESettingItem(
                              getAppLocalizations()
                                  .meetingPersonalShortMeetingID,
                              tag: getAppLocalizations()
                                  .settingInternalDedicated,
                              arrowTip: MeetingUtil.getShortMeetingNum(),
                              showArrow: false),
                        NESettingItem(
                          getAppLocalizations().meetingPersonalMeetingID,
                          arrowTip: TextUtil.applyMask(
                              NEMeetingKit.instance
                                      .getAccountService()
                                      .getAccountInfo()
                                      ?.privateMeetingNum ??
                                  '',
                              '000-000-0000'),
                          showArrow: false,
                          onTap: () {},
                        ),
                      ]),
                      NESettingItemGap(),
                      NESettingItemGroup(children: [
                        NESettingItem(
                            getAppLocalizations().settingAccountAndSafety,
                            showArrow: true, onTap: () {
                          NavUtils.pushNamed(
                            context,
                            RouterName.accountAndSafety,
                          );
                        }),
                      ]),
                    ],
                  )))),
      buildLogout(),
    ]);
  }

  Container buildEmail() {
    return Container(
      height: Dimen.primaryItemHeight,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
      child: Row(
        children: <Widget>[
          Text(
            getAppLocalizations().settingEmail,
            style: TextStyle(
                fontSize: 16.spMin,
                color: AppColors.black_222222,
                fontWeight: FontWeight.w500),
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

  Widget buildLogout() {
    return SafeArea(
        child: NEGestureDetector(
      child: Container(
        height: 48.h,
        margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
        decoration: ShapeDecoration(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.w),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: Dimen.globalWidthPadding),
        alignment: Alignment.center,
        child: Text(
          getAppLocalizations().settingLogout,
          style: TextStyle(
              fontSize: 16.spMin,
              color: AppColors.color_F51D45,
              fontWeight: FontWeight.w400),
        ),
      ),
      onTap: () => showLogoutActionSheet(),
    ));
  }

  Widget buildHead() {
    return NEGestureDetector(
        onTap: showCropImageActionSheet,
        child: Container(
          height: Dimen.primaryItemHeight,
          padding: EdgeInsets.symmetric(horizontal: Dimen.globalWidthPadding),
          child: Row(
            children: <Widget>[
              NESettingItemTitle(getAppLocalizations().settingAvatar),
              Spacer(),
              NEAccountInfoBuilder(
                builder: (context, accountInfo, _) {
                  return NEMeetingAvatar.medium(
                    name: accountInfo.nickname,
                    url: accountInfo.avatar,
                  );
                },
              ),
            ],
          ),
        ));
  }

  final _imagePicker = ImagePicker();

  void _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (!mounted || pickedFile == null) {
        return;
      }
      NavUtils.pushNamed(context, RouterName.avatarSetting,
          arguments: FileImage(File(pickedFile.path)));
    } catch (e) {
      debugPrint('Pick image error: $e');
    }
  }

  void showCropImageActionSheet() {
    if (!canModifyAvatar()) {
      return;
    }
    final isInMeeting =
        NEMeetingKit.instance.getMeetingService().getMeetingStatus() ==
                NEMeetingStatus.inMeetingMinimized ||
            NEMeetingKit.instance.getMeetingService().getMeetingStatus() ==
                NEMeetingStatus.inMeeting;
    if (isInMeeting) {
      ToastUtils.showToast(
          context, getAppLocalizations().meetingOperationNotSupportedInMeeting);
      return;
    }
    showCupertinoModalPopup<String>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              title: Text(
                getAppLocalizations().settingAvatarTitle,
                style:
                    TextStyle(color: AppColors.grey_8F8F8F, fontSize: 13.spMin),
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                    child: Text(getAppLocalizations().settingTakePicture,
                        style: TextStyle(color: AppColors.color_007AFF)),
                    onPressed: () {
                      Navigator.pop(
                          context, getAppLocalizations().globalCancel);
                      _pickImage(ImageSource.camera);
                    }),
                CupertinoActionSheetAction(
                    child: Text(getAppLocalizations().settingChoosePicture,
                        style: TextStyle(color: AppColors.color_007AFF)),
                    onPressed: () {
                      Navigator.pop(
                          context, getAppLocalizations().globalCancel);
                      _pickImage(ImageSource.gallery);
                    }),
              ],
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text(getAppLocalizations().globalCancel,
                    style: TextStyle(color: AppColors.color_007AFF)),
                onPressed: () {
                  Navigator.pop(context, getAppLocalizations().globalCancel);
                },
              ),
            ));
  }

  void showLogoutActionSheet() {
    if (NEMeetingKit.instance.getMeetingService().getCurrentMeetingInfo() !=
        null) {
      ToastUtils.showToast(
          context, getAppLocalizations().meetingOperationNotSupportedInMeeting);
      return;
    }
    showCupertinoModalPopup<String>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              title: Text(
                getAppLocalizations().settingLogoutConfirm,
                style:
                    TextStyle(color: AppColors.grey_8F8F8F, fontSize: 13.spMin),
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                    child: Text(getAppLocalizations().settingLogout,
                        key: MeetingValueKey.logoutByDialog,
                        style: TextStyle(color: AppColors.colorFE3B30)),
                    onPressed: () {
                      _logout();
                    }),
              ],
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text(getAppLocalizations().globalCancel,
                    style: TextStyle(color: AppColors.color_007AFF)),
                onPressed: () {
                  Navigator.pop(context, getAppLocalizations().globalCancel);
                },
              ),
            ));
  }

  void showLogoutDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(getAppLocalizations().settingLogoutConfirm),
//            content: Text(getAppLocalizations().confirmLogout),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(getAppLocalizations().globalCancel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text(getAppLocalizations().settingLogout),
                onPressed: () {
                  _logout();
                },
              ),
            ],
          );
        });
  }

  _logout() {
    AuthManager().logout();
    NavUtils.toEntrance(context);
  }

  @override
  String getTitle() {
    return getAppLocalizations().settingPersonalCenter;
  }

  bool canModifyNick() {
    return settingsService.isNicknameUpdateSupported();
  }

  bool canModifyAvatar() {
    return settingsService.isAvatarUpdateSupported();
  }
}
