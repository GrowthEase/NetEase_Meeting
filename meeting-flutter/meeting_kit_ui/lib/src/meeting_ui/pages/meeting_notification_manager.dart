// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingNotificationManager extends StatefulWidget {
  static GlobalKey<MeetingNotificationManagerState>? globalKey;

  const MeetingNotificationManager({
    super.key,
    required this.child,
    this.enable = true,
  });

  final Widget child;
  final bool enable;

  @override
  State<MeetingNotificationManager> createState() =>
      MeetingNotificationManagerState();

  static NotificationBarController? showNotificationBar(
      NotificationBar notification) {
    return globalKey?.currentState?.showNotificationBar(
      notification,
    );
  }

  static MeetingNotificationManagerState? of([BuildContext? context]) {
    if (context != null) {
      final scope = context.dependOnInheritedWidgetOfExactType<
          _MeetingNotificationManagerScope>();
      return scope?._notificationManagerState;
    }
    return globalKey?.currentState;
  }
}

class MeetingNotificationManagerState extends State<MeetingNotificationManager>
    with TickerProviderStateMixin, _AloggerMixin {
  final _notificationBars = Queue<NotificationBarController>();
  AnimationController? _notificationBarController;
  Timer? _notificationBarTimer;
  final _noMoreReminderChannels = <Object>{};

  @override
  void didUpdateWidget(covariant MeetingNotificationManager oldWidget) {
    if (!widget.enable) {
      removeCurrentNotificationBar();
    } else if (_notificationBars.isNotEmpty) {
      _notificationBarController!.forward();
    }
    super.didUpdateWidget(oldWidget);
  }

  void enableReminderForChannel(Object notificationChannel, bool enable) {
    commonLogger
        .i('enableReminderForChannel: $notificationChannel, enable: $enable');
    if (enable)
      _noMoreReminderChannels.remove(notificationChannel);
    else
      _noMoreReminderChannels.add(notificationChannel);
  }

  bool isReminderEnabledForChannel(Object? notificationChannel) {
    return !_noMoreReminderChannels.contains(notificationChannel);
  }

  NotificationBarController? showNotificationBar(
      NotificationBar notificationBar) {
    if (!widget.enable) return null;
    if (!isReminderEnabledForChannel(notificationBar.notificationChannel)) {
      commonLogger.i(
          'Notification is disabled for channel: ${notificationBar.notificationChannel}');
      return null;
    }
    commonLogger.i('showNotificationBar');
    _notificationBarController ??= AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    )..addStatusListener(_handleNotificationBarStatusChanged);
    if (_notificationBars.isEmpty) {
      assert(_notificationBarController!.isDismissed);
      _notificationBarController!.forward();
    }
    late NotificationBarController controller;
    controller = NotificationBarController._(
      notificationBar,
      Completer<NotificationBarClosedReason>(),
      () {
        if (_notificationBars.first == controller) {
          hideCurrentNotificationBar();
        }
      },
      null, // SnackBar doesn't use a builder function so setState() wouldn't rebuild it
    );
    setState(() {
      _notificationBars.addLast(controller);
    });
    return controller;
  }

  void _handleNotificationBarStatusChanged(AnimationStatus status) {
    debugPrint('handleNotificationBarStatusChanged: $status');
    switch (status) {
      case AnimationStatus.dismissed:
        assert(_notificationBars.isNotEmpty);
        setState(() {
          _notificationBars.removeFirst();
        });
        if (_notificationBars.isNotEmpty && widget.enable) {
          _notificationBarController!.forward();
        }
        break;
      case AnimationStatus.completed:
        setState(() {
          assert(_notificationBarTimer == null);
          // build will create a new timer if necessary to dismiss the snackBar.
        });
        break;
      case AnimationStatus.forward:
        break;
      case AnimationStatus.reverse:
        break;
    }
  }

  void removeCurrentNotificationBar(
      {NotificationBarClosedReason reason =
          NotificationBarClosedReason.remove}) {
    commonLogger.i('removeCurrentNotificationBar');
    if (_notificationBars.isEmpty) {
      return;
    }
    final Completer<NotificationBarClosedReason> completer =
        _notificationBars.first._completer;
    if (!completer.isCompleted) {
      completer.complete(reason);
    }
    _notificationBarTimer?.cancel();
    _notificationBarTimer = null;
    // This will trigger the animation's status callback.
    _notificationBarController!.value = 0.0;
  }

  void hideCurrentNotificationBar({
    NotificationBarClosedReason reason = NotificationBarClosedReason.hide,
  }) {
    commonLogger.i('hideCurrentNotificationBar');
    if (_notificationBars.isEmpty ||
        _notificationBarController!.status == AnimationStatus.dismissed) {
      return;
    }
    final Completer<NotificationBarClosedReason> completer =
        _notificationBars.first._completer;

    _notificationBarController!.reverse().then<void>((void value) {
      assert(mounted);
      if (!completer.isCompleted) {
        completer.complete(reason);
      }
    });
    _notificationBarTimer?.cancel();
    _notificationBarTimer = null;
  }

  void clearNotificationBars() {
    commonLogger.i('clearSnackBars');
    if (_notificationBars.isEmpty ||
        _notificationBarController!.status == AnimationStatus.dismissed) {
      return;
    }
    final current = _notificationBars.first;
    _notificationBars.clear();
    _notificationBars.add(current);
    hideCurrentNotificationBar();
  }

  void clearNotificationBarsBy(
      bool Function(NotificationBarController controller) predicate) {
    if (_notificationBars.isEmpty ||
        _notificationBarController!.status == AnimationStatus.dismissed) {
      return;
    }
    final current = _notificationBars.first;
    _notificationBars.removeWhere((controller) {
      return predicate(controller);
    });
    if (_notificationBars.firstOrNull != current) {
      _notificationBars.addFirst(current);
      hideCurrentNotificationBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool willShowing = _notificationBars.isNotEmpty && widget.enable;
    if (willShowing) {
      final ModalRoute<dynamic>? route = ModalRoute.of(context);
      if (route?.isActive == true) {
        if (_notificationBarController!.isCompleted &&
            _notificationBarTimer == null) {
          final notificationBar = _notificationBars.first._widget;
          _notificationBarTimer = Timer(notificationBar.duration, () {
            assert(
              _notificationBarController!.status == AnimationStatus.forward ||
                  _notificationBarController!.status ==
                      AnimationStatus.completed,
            );
            hideCurrentNotificationBar(
                reason: NotificationBarClosedReason.timeout);
          });
        }
      }
    }

    return _MeetingNotificationManagerScope(
      notificationManagerState: this,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (willShowing)
            Align(
              alignment: Alignment.bottomCenter,
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _notificationBarController!,
                  curve: Interval(0.4, 1.0),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _notificationBarController!,
                      curve: Curves.fastOutSlowIn,
                      reverseCurve: Threshold(0.0),
                    ),
                  ),
                  child: _notificationBars.first._widget,
                ),
                // child: _notificationBars.first._widget,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notificationBarController?.dispose();
    _notificationBarTimer?.cancel();
    _notificationBarTimer = null;
    _noMoreReminderChannels.clear();
    super.dispose();
  }
}

class _MeetingNotificationManagerScope extends InheritedWidget {
  const _MeetingNotificationManagerScope({
    required super.child,
    required MeetingNotificationManagerState notificationManagerState,
  }) : _notificationManagerState = notificationManagerState;

  final MeetingNotificationManagerState _notificationManagerState;

  @override
  bool updateShouldNotify(_MeetingNotificationManagerScope old) =>
      _notificationManagerState != old._notificationManagerState;
}

class NotificationBar extends StatelessWidget {
  final Object? notificationChannel;
  final Color backgroundColor;
  final Duration duration;
  final bool showCloseIcon;
  final bool showNoMoreReminder;
  final Widget? icon;
  final Widget? title;
  final TextStyle titleTextStyle;
  final TextStyle contentTextStyle;
  final Widget? content;
  final EdgeInsetsGeometry? margin;
  final List<Widget> actions;

  const NotificationBar({
    super.key,
    this.notificationChannel,
    this.backgroundColor = Colors.white,
    this.duration = const Duration(seconds: 5),
    this.showCloseIcon = true,
    this.showNoMoreReminder = false,
    this.icon,
    this.title,
    this.titleTextStyle = const TextStyle(
      color: _UIColors.color_666666,
      fontSize: 12,
      decoration: TextDecoration.none,
    ),
    this.content,
    this.contentTextStyle = const TextStyle(
      color: _UIColors.black_333333,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.none,
    ),
    this.margin,
    this.actions = const [],
  }) : assert(!showNoMoreReminder || notificationChannel != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _UIColors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      constraints: BoxConstraints(maxWidth: 344),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) icon!,
              if (icon != null) SizedBox(width: 8),
              if (title != null)
                DefaultTextStyle(
                  style: titleTextStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: title!,
                ),
              Spacer(),
              if (showCloseIcon)
                Container(
                  height: 24,
                  alignment: Alignment.topRight,
                  child: NotificationBarAction(
                    reason: NotificationBarClosedReason.hide,
                    child: Icon(
                      NEMeetingIconFont.icon_yx_tv_duankaix,
                      color: _UIColors.color_666666,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 6),
          if (content != null)
            DefaultTextStyle(
              style: contentTextStyle,
              child: content!,
            ),
          SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              children: [
                if (showNoMoreReminder)
                  NotificationBarNoMoreReminderAction(
                      channel: notificationChannel!),
                ...actions,
              ],
              spacing: 16,
              runSpacing: 6.0,
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// 不再提醒
class NotificationBarNoMoreReminderAction extends StatelessWidget {
  final Object channel;

  const NotificationBarNoMoreReminderAction({
    super.key,
    required this.channel,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationBarAction(
      reason: NotificationBarClosedReason.noMoreReminder,
      child: NEMeetingUIKitLocalizationsScope(
        builder: (context, localizations, child) {
          return Text(
            localizations.globalNoLongerRemind,
            style: TextStyle(
              color: _UIColors.color_666666,
              fontSize: 12,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.normal,
            ),
          );
        },
      ),
      onPressed: () {
        MeetingNotificationManager.of(context)!
            .enableReminderForChannel(channel, false);
      },
    );
  }
}

class NotificationBarTextAction extends StatelessWidget {
  final Widget text;
  final Object? value;

  const NotificationBarTextAction({
    super.key,
    required this.text,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationBarAction(
      reason: NotificationBarClosedReason.action(value),
      child: DefaultTextStyle(
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          decoration: TextDecoration.none,
        ),
        maxLines: 1,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          decoration: ShapeDecoration(
            color: _UIColors.color_337eff,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: text,
        ),
      ),
    );
  }
}

/// 文本按钮
class NotificationBarAction extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final NotificationBarClosedReason reason;

  const NotificationBarAction({
    super.key,
    required this.child,
    this.onPressed,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        MeetingNotificationManager.of(context)!.hideCurrentNotificationBar(
          reason: reason,
        );
        onPressed?.call();
      },
      child: child,
    );
  }
}

class NotificationBarController {
  const NotificationBarController._(
      this._widget, this._completer, this.close, this.setState);

  final NotificationBar _widget;
  final Completer<NotificationBarClosedReason> _completer;

  Future<NotificationBarClosedReason> get closed => _completer.future;

  final VoidCallback close;

  final StateSetter? setState;

  Object? get notificationChannel => _widget.notificationChannel;
}

enum NotificationBarClosedType { action, remove, timeout, noMoreReminder, hide }

class NotificationBarClosedReason {
  static const remove =
      NotificationBarClosedReason._(NotificationBarClosedType.remove);

  static const timeout =
      NotificationBarClosedReason._(NotificationBarClosedType.timeout);

  static const noMoreReminder =
      NotificationBarClosedReason._(NotificationBarClosedType.noMoreReminder);

  static const hide =
      NotificationBarClosedReason._(NotificationBarClosedType.hide);

  final NotificationBarClosedType reason;
  final Object? value;

  const NotificationBarClosedReason._(this.reason, [this.value]);

  NotificationBarClosedReason.action([Object? value])
      : this._(NotificationBarClosedType.action, value);

  bool get isAction => reason == NotificationBarClosedType.action;

  bool get isRemove => reason == NotificationBarClosedType.remove;

  bool get isTimeout => reason == NotificationBarClosedType.timeout;

  bool get isNoMoreReminder =>
      reason == NotificationBarClosedType.noMoreReminder;

  bool get isHide => reason == NotificationBarClosedType.hide;
}
