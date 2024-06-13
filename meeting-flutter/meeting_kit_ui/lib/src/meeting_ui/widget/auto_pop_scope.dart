// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class AutoPopScope extends StatefulWidget {
  final Widget? child;
  final TransitionBuilder? builder;
  final Listenable? listenable;
  final bool Function(Listenable) onWillAutoPop;

  const AutoPopScope({
    super.key,
    this.listenable,
    this.onWillAutoPop = _defaultOnWillAutoPop,
    this.builder,
    this.child,
  }) : assert(child != null || builder != null);

  @override
  State<AutoPopScope> createState() => _AutoPopScopeState();

  static bool _defaultOnWillAutoPop(Listenable listenable) {
    if (listenable is ValueListenable) {
      return listenable.value == true;
    }
    return false;
  }
}

class _AutoPopScopeState extends State<AutoPopScope> {
  late Route myselfRoute;
  bool hasRequestPop = false;

  @override
  void initState() {
    super.initState();
    widget.listenable?.addListener(_checkWillAutoPop);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    myselfRoute = ModalRoute.of(context)!;
  }

  @override
  void dispose() {
    widget.listenable?.removeListener(_checkWillAutoPop);
    super.dispose();
  }

  @override
  void didUpdateWidget(AutoPopScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable?.removeListener(_checkWillAutoPop);
      widget.listenable?.addListener(_checkWillAutoPop);
    }
    _checkWillAutoPop();
  }

  void _checkWillAutoPop() {
    if (widget.listenable == null || hasRequestPop) return;
    final willAutoPop = widget.onWillAutoPop.call(widget.listenable!);
    if (willAutoPop) {
      hasRequestPop = true;
      widget.listenable?.removeListener(_checkWillAutoPop);
      postOnFrame(() {
        if (!mounted || !myselfRoute.isActive) return;
        if (myselfRoute.isCurrent) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).removeRoute(myselfRoute);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder?.call(context, widget.child) ?? widget.child!;
  }
}
