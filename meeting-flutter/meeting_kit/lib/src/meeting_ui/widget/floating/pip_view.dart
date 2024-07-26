// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class PIPView extends StatefulWidget {
  final PIPViewCorner initialCorner;
  final double? floatingWidth;
  final double? floatingHeight;
  final bool avoidKeyboard;
  final Widget? backgroundWidget;

  final Widget Function(
    BuildContext context,
    bool isFloating,
  ) builder;
  final void Function(bool isFloating) onFloating;
  const PIPView({
    Key? key,
    required this.builder,
    this.initialCorner = PIPViewCorner.topRight,
    this.floatingWidth,
    this.floatingHeight,
    this.avoidKeyboard = true,
    this.backgroundWidget,
    required this.onFloating,
  }) : super(key: key);

  @override
  PIPViewState createState() => PIPViewState();

  static PIPViewState? of(BuildContext context) {
    if (!context.mounted) return null;
    return context.findAncestorStateOfType<PIPViewState>();
  }
}

class PIPViewState extends State<PIPView> with TickerProviderStateMixin {
  Widget? _bottomWidget;
  double? _floatingWidth;
  double? _floatingHeight;
  double _ratio = 9 / 16;

  @override
  void initState() {
    super.initState();
    _bottomWidget = widget.backgroundWidget;
  }

  void presentBelow(Widget widget, double? ratio) {
    dismissKeyboard(context);
    setState(() {
      _bottomWidget = widget;
      if (ratio != null) {
        _ratio = ratio;
      }
    });
  }

  void updatePipViewAspectRatio({double? ratio}) {
    // dismissKeyboard(context);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    if (ratio != null && ratio != _ratio) {
      setState(() {
        _ratio = ratio;
      });
    }
  }

  void stopFloating() {
    dismissKeyboard(context);
    setState(() {
      _bottomWidget = null;
      widget.onFloating(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFloating = _bottomWidget != null;
    return RawPIPView(
      avoidKeyboard: widget.avoidKeyboard,
      bottomWidget: isFloating
          ? Navigator(
              onGenerateInitialRoutes: (navigator, initialRoute) => [
                NEMeetingPageRoute(builder: (context) => _bottomWidget!),
              ],
            )
          : null,
      onTapTopWidget: isFloating ? stopFloating : null,
      topWidget: IgnorePointer(
        ignoring: isFloating,
        child: Builder(
          builder: (context) => widget.builder(context, isFloating),
        ),
      ),
      floatingHeight: _floatingHeight,
      floatingWidth: _floatingWidth,
      initialCorner: widget.initialCorner,
      ratio: _ratio,
    );
  }
}
