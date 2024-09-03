// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import 'package:nemeeting/utils/integration_test.dart';
import '../language/localizations.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/values/colors.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';

class CaptionsSetting extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CaptionsSettingState();
  }
}

class _CaptionsSettingState extends AppBaseState<CaptionsSetting> {
  static final enableOnJoinNotifier = ValueNotifier<bool>(false);

  late final settingsService = NEMeetingKit.instance.getSettingsService();
  final translationLanguage =
      ValueNotifier(NEMeetingASRTranslationLanguage.none);
  final captionSupported = ValueNotifier(false);
  final transcriptionSupported = ValueNotifier(false);
  final captionBilingualEnabled = ValueNotifier(false);
  final transcriptionBilingualEnabled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    GlobalPreferences().isEnableCaptionsOnJoin().then((value) {
      enableOnJoinNotifier.value = value;
    });
    settingsService.addListener(updateSettings);
    updateSettings();
  }

  @override
  void dispose() {
    settingsService.removeListener(updateSettings);
    super.dispose();
  }

  void updateSettings() {
    captionSupported.value = settingsService.isCaptionsSupported();
    transcriptionSupported.value = settingsService.isTranscriptionSupported();

    translationLanguage.value = settingsService.getASRTranslationLanguage();
    captionBilingualEnabled.value = settingsService.isCaptionBilingualEnabled();
    transcriptionBilingualEnabled.value =
        settingsService.isTranscriptionBilingualEnabled();
  }

  @override
  Widget buildBody() {
    return Column(
      children: <Widget>[
        ValueListenableBuilder(
            valueListenable: captionSupported,
            builder: (context, supported, _) {
              if (!supported) return SizedBox.shrink();
              return MeetingCard(
                title: getAppLocalizations().transcriptionCaptionSettings,
                iconData: IconFont.icon_settings,
                iconColor: AppColors.color_8D90A0,
                children: [
                  MeetingSwitchItem(
                    switchKey: MeetingValueKey.enableCaptionOnJoin,
                    title:
                        getAppLocalizations().transcriptionEnableCaptionOnJoin,
                    valueNotifier: enableOnJoinNotifier,
                    onChanged: (value) async {
                      await GlobalPreferences().seEnableCaptionsOnJoin(value);
                      enableOnJoinNotifier.value = value;
                    },
                  )
                ],
              );
            }),
        MeetingCard(
          title: getAppLocalizations().transcriptionTranslateSettings,
          summary: getAppLocalizations().transcriptionTranslationSettingsTip,
          iconData: IconFont.icon_settings,
          iconColor: AppColors.color_8D90A0,
          children: [
            ValueListenableBuilder(
                valueListenable: translationLanguage,
                builder: (context, language, _) {
                  return MeetingArrowItem(
                    title:
                        context.meetingUiLocalizations.transcriptionTargetLang,
                    content: switch (language) {
                      NEMeetingASRTranslationLanguage.chinese =>
                        context.meetingUiLocalizations.langChinese,
                      NEMeetingASRTranslationLanguage.english =>
                        context.meetingUiLocalizations.langEnglish,
                      NEMeetingASRTranslationLanguage.japanese =>
                        context.meetingUiLocalizations.langJapanese,
                      _ => context
                          .meetingUiLocalizations.transcriptionNotTranslated,
                    },
                    onTap: () async {
                      final lang =
                          await PreMeetingSelectTranslationLanguagePopup.show(
                              context, language);
                      if (mounted && lang != null && lang != language) {
                        settingsService.setASRTranslationLanguage(lang);
                      }
                    },
                  );
                }),
            ValueListenableBuilder(
                valueListenable: captionSupported,
                builder: (context, supported, _) {
                  if (!supported) return SizedBox.shrink();
                  return MeetingSwitchItem(
                    title:
                        getAppLocalizations().transcriptionCaptionShowBilingual,
                    valueNotifier: captionBilingualEnabled,
                    onChanged: (value) {
                      settingsService.enableCaptionBilingual(value);
                    },
                  );
                }),
            ValueListenableBuilder(
              valueListenable: transcriptionSupported,
              builder: (context, supported, _) {
                if (!supported) return SizedBox.shrink();
                return MeetingSwitchItem(
                  title:
                      getAppLocalizations().transcriptionSettingShowBilingual,
                  valueNotifier: transcriptionBilingualEnabled,
                  onChanged: (value) {
                    settingsService.enableTranscriptionBilingual(value);
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  String getTitle() {
    return getAppLocalizations().transcriptionCaptionAndTranslate;
  }
}

class PreMeetingSelectTranslationLanguagePopup extends StatelessWidget {
  static Future<NEMeetingASRTranslationLanguage?> show(
    BuildContext context,
    NEMeetingASRTranslationLanguage? selected,
  ) async {
    return showModalBottomSheet<NEMeetingASRTranslationLanguage>(
      context: context,
      useSafeArea: true,
      backgroundColor: AppColors.color_F0F1F5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(8.0),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      routeSettings: RouteSettings(name: 'SelectTranslationLanguagePopup'),
      builder: (context) {
        return PreMeetingSelectTranslationLanguagePopup(selected: selected);
      },
    );
  }

  final NEMeetingASRTranslationLanguage? selected;

  const PreMeetingSelectTranslationLanguagePopup({super.key, this.selected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 44,
            color: Colors.white,
            alignment: Alignment.center,
            child: Text(
              context.meetingUiLocalizations.transcriptionTargetLang,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.color_1E1F27,
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          ...NEMeetingASRTranslationLanguage.values.map((e) {
            return _buildItem(e);
          }).toList(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: 56,
              alignment: Alignment.center,
              child: Text(
                getAppLocalizations().globalCancel,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.color_1E1F27,
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.viewPaddingOf(context).bottom,
          )
        ],
      ),
    );
  }

  Widget _buildItem(NEMeetingASRTranslationLanguage language) {
    final isSelected = language == selected;
    final isFirst = language == NEMeetingASRTranslationLanguage.none;
    final isLast = language == NEMeetingASRTranslationLanguage.japanese;
    final color = isSelected ? AppColors.color_337eff : AppColors.color_333333;
    return Builder(builder: (context) {
      final localizations = context.meetingUiLocalizations;
      return GestureDetector(
        onTap: () async {
          Navigator.pop(context, isSelected ? null : language);
        },
        child: Container(
          height: 48,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: isFirst ? const Radius.circular(8) : Radius.zero,
                bottom: isLast ? const Radius.circular(8) : Radius.zero,
              ),
            ),
            color: Colors.white,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16),
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  switch (language) {
                    NEMeetingASRTranslationLanguage.chinese =>
                      localizations.langChinese,
                    NEMeetingASRTranslationLanguage.english =>
                      localizations.langEnglish,
                    NEMeetingASRTranslationLanguage.japanese =>
                      localizations.langJapanese,
                    _ => localizations.transcriptionNotTranslated,
                  },
                  style: TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w500,
                    color: AppColors.color_1E1F27,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  NEMeetingIconFont.icon_check_line,
                  size: 16,
                  color: color,
                ),
            ],
          ),
        ),
      );
    });
  }
}
