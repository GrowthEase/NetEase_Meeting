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

  @override
  void initState() {
    super.initState();
    GlobalPreferences().isEnableCaptionsOnJoin().then((value) {
      enableOnJoinNotifier.value = value;
    });
  }

  @override
  Widget buildBody() {
    return Column(
      children: <Widget>[
        MeetingCard(
          title: getAppLocalizations().transcriptionCaptionSettings,
          iconData: IconFont.icon_settings,
          iconColor: AppColors.color_8D90A0,
          children: [
            MeetingSwitchItem(
              switchKey: MeetingValueKey.enableCaptionOnJoin,
              title: getAppLocalizations().transcriptionEnableCaptionOnJoin,
              valueNotifier: enableOnJoinNotifier,
              onChanged: (value) async {
                await GlobalPreferences().seEnableCaptionsOnJoin(value);
                enableOnJoinNotifier.value = value;
              },
            )
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
