// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

import 'meeting_localization/meeting_app_localizations.dart';

Locale? _locale;
MeetingAppLocalizations getAppLocalizations([BuildContext? context]) {
  MeetingAppLocalizations? localizations;
  if (context != null) {
    localizations = MeetingAppLocalizations.of(context);
  }
  if (localizations == null) {
    /// 初始化并监听语言变化
    if (_locale == null) {
      _locale = NEMeetingUIKit.instance.localeListenable.value;
      NEMeetingUIKit.instance.localeListenable.addListener(() {
        _locale = NEMeetingUIKit.instance.localeListenable.value;
      });
    }
    localizations = lookupMeetingAppLocalizations(_locale!);
  }
  return localizations;
}
