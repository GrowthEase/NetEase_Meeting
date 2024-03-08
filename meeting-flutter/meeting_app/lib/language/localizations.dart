// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

import 'meeting_localization/meeting_app_localizations.dart';

class MeetingAppLocalizationsScope extends StatelessWidget {
  final Widget? child;
  final WidgetBuilder? builder;

  const MeetingAppLocalizationsScope({
    Key? key,
    this.child,
    this.builder,
  })  : assert(child != null || builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: NEMeetingUIKit().localeListenable,
      child: child,
      builder: (BuildContext context, Locale value, Widget? child) {
        return Localizations(
          locale: value,
          delegates: [
            MeetingAppLocalizations.delegate,
            ...MeetingAppLocalizations.localizationsDelegates
          ],
          child: Builder(
            builder: (ctx) {
              return builder != null ? builder!(ctx) : child!;
            },
          ),
        );
      },
    );
  }
}

class MaterialMeetingAppPageRoute<T> extends MaterialPageRoute<T> {
  MaterialMeetingAppPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
          builder: (BuildContext context) {
            return MeetingAppLocalizationsScope(
              builder: builder,
            );
          },
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
        );
}

MeetingAppLocalizations getAppLocalizations([BuildContext? context]) {
  MeetingAppLocalizations? localizations;
  if (context != null) {
    localizations = MeetingAppLocalizations.of(context);
  }
  if (localizations == null) {
    localizations =
        lookupMeetingAppLocalizations(NEMeetingUIKit().localeListenable.value);
  }
  return localizations;
}

mixin MeetingAppLocalizationsMixin<T extends StatefulWidget> on State<T> {
  late MeetingAppLocalizations meetingAppLocalizations;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    meetingAppLocalizations = MeetingAppLocalizations.of(context)!;
  }
}
