// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:image_picker/image_picker.dart';
import 'package:nemeeting/base/util/text_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import '../language/localizations.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/utils/nav_utils.dart';
import '../uikit/utils/router_name.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/dimem.dart';
import '../uikit/values/fonts.dart';
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

class _PersonalSettingState extends MeetingBaseState<PersonalSetting>
    with MeetingAppLocalizationsMixin {
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
        buildPersonItem(
            title: meetingAppLocalizations.settingNick,
            arrowTip: MeetingUtil.getNickName(),
            isShowArrow: canModifyNick(),
            onTap: () {
              if (canModifyNick()) {
                NavUtils.pushNamed(context, RouterName.nickSetting);
              }
            }),
        Container(
          color: AppColors.globalBg,
          height: Dimen.globalPadding,
        ),
        if (!TextUtil.isEmpty(MeetingUtil.getShortMeetingNum()))
          ...buildShortMeetingId(),
        buildMeetingId(),
        Container(
          color: AppColors.globalBg,
          height: Dimen.globalPadding,
        ),
        buildPersonItem(
            title: meetingAppLocalizations.settingAccountAndSafety,
            arrowTip: '',
            isShowArrow: true,
            onTap: () {
              NavUtils.pushNamed(
                context,
                RouterName.accountAndSafety,
              );
            }),
        Container(
          color: AppColors.globalBg,
          height: Dimen.globalPadding,
        ),
        buildLogout(),
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
            meetingAppLocalizations.settingEmail,
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
          meetingAppLocalizations.settingLogout,
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
            meetingAppLocalizations.meetingPersonalMeetingID,
            style: TextStyle(fontSize: 16, color: AppColors.black_222222),
          ),
          Spacer(),
          Text(
            TextUtil.applyMask(
                NEMeetingKit.instance
                        .getAccountService()
                        .getAccountInfo()
                        ?.privateMeetingNum ??
                    '',
                '000-000-0000'),
            style: TextStyle(fontSize: 14, color: AppColors.color_999999),
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
              meetingAppLocalizations.meetingPersonalShortMeetingID,
              style: TextStyle(fontSize: 16, color: AppColors.black_222222),
            ),
            Container(
              margin: EdgeInsets.only(left: 6),
              padding: EdgeInsets.only(left: 6, right: 6, bottom: 2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: AppColors.color_1a337eff,
                  border: Border.all(color: AppColors.color_33337eff)),
              child: Text(
                meetingAppLocalizations.settingInternalDedicated,
                style: TextStyle(fontSize: 12, color: AppColors.color_337eff),
              ),
            ),
            Spacer(),
            Text(
              MeetingUtil.getShortMeetingNum(),
              style: TextStyle(fontSize: 14, color: AppColors.color_999999),
            ),
          ],
        ),
      ),
      _buildSplit(),
    ];
  }

  GestureDetector buildPersonItem(
      {required String title,
      required String arrowTip,
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

  Widget buildHead() {
    return GestureDetector(
        onTap: showCropImageActionSheet,
        child: Container(
          height: Dimen.primaryItemHeight,
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
          child: Row(
            children: <Widget>[
              Text(
                meetingAppLocalizations.settingAvatar,
                style: TextStyle(fontSize: 16, color: AppColors.black_222222),
              ),
              Spacer(),
              ListenableBuilder(
                listenable: NEMeetingKit.instance.getAccountService(),
                builder: (context, child) {
                  final accountInfo = NEMeetingKit.instance
                      .getAccountService()
                      .getAccountInfo();
                  return NEMeetingAvatar.medium(
                    name: accountInfo?.nickname,
                    url: accountInfo?.avatar,
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
    final isInMeeting = NEMeetingUIKit().getMeetingStatus().event ==
            NEMeetingEvent.inMeetingMinimized ||
        NEMeetingUIKit().getMeetingStatus().event == NEMeetingEvent.inMeeting;
    if (isInMeeting) {
      ToastUtils.showToast(context,
          meetingAppLocalizations.meetingOperationNotSupportedInMeeting);
      return;
    }
    showCupertinoModalPopup<String>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              title: Text(
                meetingAppLocalizations.settingAvatarTitle,
                style: TextStyle(color: AppColors.grey_8F8F8F, fontSize: 13),
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                    child: Text(meetingAppLocalizations.settingTakePicture,
                        style: TextStyle(color: AppColors.color_007AFF)),
                    onPressed: () {
                      Navigator.pop(
                          context, meetingAppLocalizations.globalCancel);
                      _pickImage(ImageSource.camera);
                    }),
                CupertinoActionSheetAction(
                    child: Text(meetingAppLocalizations.settingChoosePicture,
                        style: TextStyle(color: AppColors.color_007AFF)),
                    onPressed: () {
                      Navigator.pop(
                          context, meetingAppLocalizations.globalCancel);
                      _pickImage(ImageSource.gallery);
                    }),
              ],
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text(meetingAppLocalizations.globalCancel,
                    style: TextStyle(color: AppColors.color_007AFF)),
                onPressed: () {
                  Navigator.pop(context, meetingAppLocalizations.globalCancel);
                },
              ),
            ));
  }

  void showLogoutActionSheet() {
    if (NEMeetingUIKit().getCurrentMeetingInfo() != null) {
      ToastUtils.showToast(context,
          meetingAppLocalizations.meetingOperationNotSupportedInMeeting);
      return;
    }
    showCupertinoModalPopup<String>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              title: Text(
                meetingAppLocalizations.settingLogoutConfirm,
                style: TextStyle(color: AppColors.grey_8F8F8F, fontSize: 13),
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                    child: Text(meetingAppLocalizations.settingLogout,
                        key: MeetingValueKey.logoutByDialog,
                        style: TextStyle(color: AppColors.colorFE3B30)),
                    onPressed: () {
                      _logout();
                    }),
              ],
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text(meetingAppLocalizations.globalCancel,
                    style: TextStyle(color: AppColors.color_007AFF)),
                onPressed: () {
                  Navigator.pop(context, meetingAppLocalizations.globalCancel);
                },
              ),
            ));
  }

  void showLogoutDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(meetingAppLocalizations.settingLogoutConfirm),
//            content: Text(meetingAppLocalizations.confirmLogout),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(meetingAppLocalizations.globalCancel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text(meetingAppLocalizations.settingLogout),
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

  Container _buildSplit() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(left: 20),
      height: 0.5,
      child: Divider(height: 0.5),
    );
  }

  @override
  String getTitle() {
    return meetingAppLocalizations.settingPersonalCenter;
  }

  bool canModifyNick() {
    return !SDKConfig.current.nicknameUpdateDisabled;
  }

  bool canModifyAvatar() {
    return !SDKConfig.current.avatarUpdateDisabled;
  }
}
