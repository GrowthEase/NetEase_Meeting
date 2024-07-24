// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class NEMeetingUIKitLocalizationsScope extends StatelessWidget {
  final Widget? child;
  final ValueWidgetBuilder<NEMeetingUIKitLocalizations>? builder;

  const NEMeetingUIKitLocalizationsScope({
    Key? key,
    this.child,
    this.builder,
  })  : assert(child != null || builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: NEMeetingUIKit.instance.localeListenable,
      child: child,
      builder: (BuildContext context, Locale value, Widget? child) {
        return Localizations(
          locale: value,
          delegates: [...NEMeetingUIKitLocalizations.localizationsDelegates],
          child: Builder(
            builder: (ctx) {
              return builder != null
                  ? builder!(ctx, NEMeetingUIKitLocalizations.of(ctx)!, child)
                  : child!;
            },
          ),
        );
      },
    );
  }
}

mixin MeetingKitLocalizationsMixin<T extends StatefulWidget> on State<T> {
  late NEMeetingUIKitLocalizations meetingUiLocalizations;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    meetingUiLocalizations = NEMeetingUIKitLocalizations.of(context)!;
  }
}

extension MeetingKitLocalizationsExtension on BuildContext {
  NEMeetingUIKitLocalizations get meetingUiLocalizations =>
      NEMeetingUIKitLocalizations.of(this)!;
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
              builder: (ctx, _, __) => builder(ctx),
            );
          },
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
        );
}
