// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class NEMeetingUIKitLocalizationsScope extends StatelessWidget {
  final Widget? child;
  final WidgetBuilder? builder;

  const NEMeetingUIKitLocalizationsScope({
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
            NEMeetingKitLocalizations.delegate,
            ...NEMeetingUIKitLocalizations.localizationsDelegates
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

class MaterialMeetingPageRoute<T> extends MaterialPageRoute<T> {
  MaterialMeetingPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
          builder: (BuildContext context) {
            return NEMeetingUIKitLocalizationsScope(
              builder: builder,
            );
          },
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
        );
}
