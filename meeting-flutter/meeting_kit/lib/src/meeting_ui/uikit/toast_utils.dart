// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

typedef TextToastBuilder = Widget Function(
    BuildContext context, String text, Key? key);

class ToastUtils {
  static final _root = ToastManager();

  static void showBotToast(String text, {bool isError = false}) {
    BotToast.showText(
        text: text,
        align: Alignment.center,
        textStyle: TextStyle(
          color: isError ? Color(0xffFF4742) : Colors.white,
          fontSize: 14.0,
          decoration: TextDecoration.none,
          fontWeight: FontWeight.w400,
        ));
  }

  static void showToast(
    BuildContext context,
    String? text, {
    Duration? duration,
    bool? dismissOthers,
    bool? atFrontOfQueue,
    Key? key,
    bool? isError,
    VoidCallback? onDismiss,
  }) {
    if (text == null || text.isEmpty) return;
    _root.showText(
      context,
      text,
      duration: duration,
      dismissOthers: dismissOthers,
      atFrontOfQueue: atFrontOfQueue,
      textKey: key,
      isError: isError,
      onDismiss: onDismiss,
    );
  }

  static void showToast2(
    BuildContext context,
    WidgetBuilder builder, {
    Duration? duration,
    bool? dismissOthers = false,
    bool? atFrontOfQueue = false,
    VoidCallback? onDismiss,
  }) {
    _root.showToast(
      context,
      builder: builder,
      duration: duration,
      dismissOthers: dismissOthers,
      atFrontOfQueue: atFrontOfQueue,
      onDismiss: onDismiss,
    );
  }
}

class ToastManager {
  final bool rootOverlay;
  final _requests = ListQueue<_ToastRequest>();
  final _textSet = <String>{};
  bool _scheduled = false;

  ToastManager({this.rootOverlay = true});

  void dispose() {
    _requests.clear();
  }

  void showText(
    BuildContext context,
    String text, {
    Key? textKey,
    Duration? duration,
    bool? dismissOthers,
    bool? atFrontOfQueue,
    bool? isError,
    VoidCallback? onDismiss,
  }) {
    if (_textSet.contains(text)) {
      return;
    }
    _textSet.add(text);
    showToast(
      context,
      builder: (context) {
        return textToastBuilder(text, textKey: textKey, isError: isError);
      },
      duration: duration,
      dismissOthers: dismissOthers,
      atFrontOfQueue: atFrontOfQueue,
      onDismiss: () {
        _textSet.remove(text);
        onDismiss?.call();
      },
    );
  }

  void showToast(
    BuildContext context, {
    required WidgetBuilder builder,
    Duration? duration,
    bool? dismissOthers,
    bool? atFrontOfQueue,
    VoidCallback? onDismiss,
  }) {
    duration ??= const Duration(seconds: 2);
    dismissOthers ??= false;
    atFrontOfQueue ??= false;

    if (dismissOthers) {
      _requests.forEach((element) {
        element.onDismiss?.call();
      });
      _requests.clear();
    }
    final request =
        _ToastRequest(context, builder, duration, onDismiss: onDismiss);
    if (atFrontOfQueue) {
      _requests.addFirst(request);
    } else {
      _requests.addLast(request);
    }

    if (!_scheduled) {
      _scheduled = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _showNextToast();
      });
      SchedulerBinding.instance.ensureVisualUpdate();
    }
  }

  void _showNextToast() {
    if (_requests.isEmpty) {
      _scheduled = false;
      return;
    }
    final request = _requests.removeFirst();
    final context = request.context;
    final builder = request.builder;
    final duration = request.duration;
    final onDismiss = request.onDismiss;
    _showToastImpl(context, builder, duration, onDismiss);
  }

  void _showToastImpl(BuildContext context, WidgetBuilder builder,
      Duration duration, VoidCallback? onDismiss) async {
    OverlayState? overlayState;
    try {
      overlayState = Overlay.of(context, rootOverlay: rootOverlay);
    } catch (e) {
      overlayState = null;
    }
    assert(overlayState != null, 'OverlayState is null');
    if (overlayState != null && overlayState.mounted) {
      final entry = OverlayEntry(builder: builder);
      overlayState.insert(entry);
      await Future.delayed(duration);
      entry.remove();
      onDismiss?.call();
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _showNextToast();
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  static Widget textToastBuilder(
    String text, {
    Key? textKey,
    bool? isError,
  }) {
    isError ??= false;
    return Center(
      child: Container(
        margin: EdgeInsets.all(20.0),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
        decoration: ShapeDecoration(
          color: isError ? Colors.white : Color(0xBF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ),
        child: Text(
          text,
          key: textKey,
          style: TextStyle(
            color: isError ? Color(0xffFF4742) : Colors.white,
            fontSize: 14.0,
            decoration: TextDecoration.none,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ToastRequest {
  final BuildContext context;

  final WidgetBuilder builder;

  final Duration duration;

  final VoidCallback? onDismiss;

  _ToastRequest(this.context, this.builder, this.duration, {this.onDismiss});
}
