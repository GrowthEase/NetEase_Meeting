// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class PointerEventAware extends StatefulWidget {
  const PointerEventAware({
    Key? key,
    required this.child,
    this.timeout = const Duration(seconds: 3),
  }) : super(key: key);

  final Widget child;
  final Duration timeout;

  @override
  State<PointerEventAware> createState() => _PointerEventAwareState();
}

class _PointerEventAwareState extends State<PointerEventAware> {
  Timer? _timeout;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    scheduleTimeoutTask(null);
  }

  @override
  void dispose() {
    _timeout?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    scheduleTimeoutTask(null);
  }

  void scheduleTimeoutTask(PointerEvent? event) {
    _timeout?.cancel();
    _timeout = Timer(widget.timeout, () {
      updateState(false);
    });
    updateState(true);
  }

  void updateState(bool visible) {
    if (mounted) {
      setState(() {
        _visible = visible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Listener(
        onPointerDown: scheduleTimeoutTask,
        onPointerMove: scheduleTimeoutTask,
        onPointerUp: scheduleTimeoutTask,
        onPointerCancel: scheduleTimeoutTask,
        behavior: HitTestBehavior.translucent,
        child: Visibility(
          visible: _visible,
          child: widget.child,
        ),
      ),
    );
  }
}
