// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

typedef TextToastBuilder = Widget Function(
    BuildContext context, String text, Key? key);

class ToastUtils {
  static var style = const TextStyle(
    color: Colors.white,
    fontSize: 14.0,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.w400,
  );

  static var decoration = const ShapeDecoration(
    color: Color(0xBF1E1E1E),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
    ),
  );

  static var edgeInsets =
      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0);

  static Widget _textToastBuilder(BuildContext context, String text, Key? key) {
    return Center(
      child: Container(
        padding: edgeInsets,
        decoration: decoration,
        child: Text(
          text,
          key: key,
          style: style,
        ),
      ),
    );
  }

  static var defaultTextToastBuilder = _textToastBuilder;

  static final _requests = ListQueue<_ToastRequest>();
  static bool _scheduled = false;

  static void showToast(
    BuildContext context,
    String? text, {
    Duration duration = const Duration(seconds: 2),
    bool dismissOthers = false,
    bool atFrontOfQueue = false,
    Key? key,
  }) {
    if (text == null) return;

    _showToastInner(
      context,
      text,
      duration,
      dismissOthers,
      atFrontOfQueue,
      key,
    );
  }

  static void showToast2(
    BuildContext context,
    WidgetBuilder builder, {
    Duration duration = const Duration(seconds: 2),
    bool dismissOthers = false,
    bool atFrontOfQueue = false,
  }) {
    _showToastInner(
        context, builder, duration, dismissOthers, atFrontOfQueue, null);
  }

  static void _showToastInner(
    BuildContext context,
    Object arg,
    Duration duration,
    bool dismissOthers,
    bool atFrontOfQueue,
    Key? key,
  ) {
    if (dismissOthers) {
      _requests.clear();
    }
    if (atFrontOfQueue) {
      _requests.addFirst(_ToastRequest(key, context, arg, duration));
    } else {
      _requests.addLast(_ToastRequest(key, context, arg, duration));
    }

    if (!_scheduled) {
      _scheduled = true;
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        _showNextToast();
      });
      SchedulerBinding.instance!.ensureVisualUpdate();
    }
  }

  static void _showNextToast() {
    if (_requests.isEmpty) {
      _scheduled = false;
      return;
    }
    final request = _requests.removeFirst();
    final key = request.key;
    final context = request.context;
    final arg = request.arg;
    final duration = request.duration;
    _showToast(key, context, arg, duration);
  }

  static void _showToast(
      Key? key, BuildContext context, Object arg, Duration duration) async {
    OverlayState? overlayState;
    try {
      overlayState = Overlay.of(context, rootOverlay: true);
    } catch (e) {
      overlayState = null;
    }
    if (overlayState != null && overlayState.mounted) {
      final entry = OverlayEntry(builder: (context) {
        if (arg is WidgetBuilder) {
          return arg(context);
        } else {
          return defaultTextToastBuilder(context, arg.toString(), key);
        }
      });
      overlayState.insert(entry);
      await Future.delayed(duration);
      entry.remove();
    }
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      _showNextToast();
    });
    SchedulerBinding.instance!.ensureVisualUpdate();
  }
}

class _ToastRequest {
  Key? key;

  BuildContext context;

  final Object arg;

  final Duration duration;

  _ToastRequest(this.key, this.context, this.arg, this.duration);
}
