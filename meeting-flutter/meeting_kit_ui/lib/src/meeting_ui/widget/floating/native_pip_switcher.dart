// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// Widget switching utility.
///
/// Depending on current PiP status will render [childWhenEnabled]
/// or [childWhenDisabled] widget.
class PiPSwitcher extends StatefulWidget {
  /// Floating instance that the listener will connect to.
  ///
  /// It may be provided by the instance user. If not, the widget
  /// will create it's own Floating instance.
  final NEFloatingService? floating;

  /// Child to render when PiP is enabled
  final Widget childWhenEnabled;

  /// Child to render when PiP is disabled or unavailable.
  final Widget childWhenDisabled;

  PiPSwitcher({
    Key? key,
    required this.childWhenEnabled,
    required this.childWhenDisabled,
    this.floating,
  }) : super(key: key);

  @override
  State<PiPSwitcher> createState() => _PipAwareState();
}

class _PipAwareState extends State<PiPSwitcher> {
  late final NEFloatingService _floating =
      widget.floating ?? NEMeetingPlugin().getFloatingServiceService();

  @override
  void dispose() {
    /// Dispose the floating instance only if it was created
    /// by this widget.
    ///
    /// Floating instance can be also provided by the user of this
    /// widget. If so, it's the user's responsibility to dispose
    /// it when necessary.
    if (widget.floating == null) {
      _floating.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: _floating.pipStatus$,
        initialData: PiPStatus.disabled,
        builder: (context, snapshot) => snapshot.data == PiPStatus.enabled
            ? widget.childWhenEnabled
            : widget.childWhenDisabled,
      );
}
