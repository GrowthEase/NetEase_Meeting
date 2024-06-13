// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:nemeeting/language/meeting_localization/meeting_app_localizations_en.dart';
import 'package:nemeeting/language/meeting_localization/meeting_app_localizations_ja.dart';
import 'package:nemeeting/language/meeting_localization/meeting_app_localizations_zh.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import 'package:nemeeting/widget/ne_widget.dart';
import '../language/localizations.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/dimem.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

class LanguageSetting extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LanguageSettingState();
  }
}

class _LanguageSettingState extends AppBaseState<LanguageSetting> {
  VoidCallback? onLanguageChanged;

  @override
  void initState() {
    super.initState();
    onLanguageChanged = () {
      setState(() {});
    };
    NEMeetingUIKit.instance.localeListenable.addListener(onLanguageChanged!);
  }

  @override
  Widget buildBody() {
    return Container(
      padding: EdgeInsets.only(left: 16.w, right: 16.w),
      child: Column(
        children: <Widget>[
          Container(
            color: AppColors.globalBg,
            height: Dimen.globalPadding,
          ),
          ValueListenableBuilder(
              valueListenable: NEMeetingUIKit.instance.localeListenable,
              builder: (context, locale, child) {
                var isSelected =
                    (tip) => tip == getAppLocalizations().settingLanguageTip;
                return NESettingItemGroup(
                  children: [
                    _buildLanguageItem(
                      title: MeetingAppLocalizationsZh().settingLanguageTip,
                      isSelected: isSelected(
                          MeetingAppLocalizationsZh().settingLanguageTip),
                      onTap: () => switchLanguage(NEMeetingLanguage.chinese,
                          NEMeetingLanguage.chinese.locale.languageCode),
                    ),
                    _buildLanguageItem(
                      title: MeetingAppLocalizationsEn().settingLanguageTip,
                      isSelected: isSelected(
                          MeetingAppLocalizationsEn().settingLanguageTip),
                      onTap: () => switchLanguage(NEMeetingLanguage.english,
                          NEMeetingLanguage.english.locale.languageCode),
                    ),
                    _buildLanguageItem(
                      title: MeetingAppLocalizationsJa().settingLanguageTip,
                      isSelected: isSelected(
                          MeetingAppLocalizationsJa().settingLanguageTip),
                      onTap: () => switchLanguage(NEMeetingLanguage.japanese,
                          NEMeetingLanguage.japanese.locale.languageCode),
                    ),
                  ],
                );
              }),
          Expanded(
            flex: 1,
            child: Container(
              color: AppColors.globalBg,
            ),
          )
        ],
      ),
    );
  }

  /// 切换语言，如果选择的是系统默认语言，则切换为自动
  void switchLanguage(NEMeetingLanguage language, String languageCode) {
    var isSystemDefault = (languageCode) =>
        WidgetsBinding.instance.platformDispatcher.locale.languageCode ==
        languageCode;
    NEMeetingUIKit.instance.switchLanguage(
        isSystemDefault(languageCode) ? NEMeetingLanguage.automatic : language);
    GlobalPreferences().setLanguageCode(isSystemDefault(languageCode)
        ? NEMeetingLanguage.automatic.locale.languageCode
        : languageCode);
  }

  Widget _buildLanguageItem(
      {required String title,
      required bool isSelected,
      required VoidCallback onTap}) {
    return NEGestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(left: 20.w, right: 16.w),
        height: 48.h,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.spMin,
                  color: AppColors.color_222222,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            isSelected
                ? Icon(
                    IconFont.icon_yx_gouxuan,
                    size: 16.spMin,
                    color: AppColors.color_337eff,
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  @override
  String getTitle() {
    return getAppLocalizations().settingSetLanguage;
  }

  @override
  void dispose() {
    super.dispose();
    NEMeetingUIKit.instance.localeListenable.removeListener(onLanguageChanged!);
  }
}
