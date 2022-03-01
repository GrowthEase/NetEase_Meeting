// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class ValueNotifierAdapter<T, R> extends ValueNotifier<R> {
  final ValueListenable<T> source;
  final R Function(T) mapper;

  ValueNotifierAdapter({required this.source, required this.mapper}) : super(mapper(source.value)) {
    source.addListener(_updateValue);
  }

  void refresh() => _updateValue();

  void _updateValue() => value = mapper(source.value);

  @override
  void dispose() {
    source.removeListener(_updateValue);
    super.dispose();
  }
}

/// This widget solves the following error:
/// 'setState() or markNeedsBuild() called when widget tree was locked.'
class SafeValueListenableBuilder<T> extends StatefulWidget {
  const SafeValueListenableBuilder({
    Key? key,
    required this.valueListenable,
    required this.builder,
    this.child,
  }) : super(key: key);

  final ValueListenable<T> valueListenable;

  final ValueWidgetBuilder<T> builder;

  final Widget? child;

  @override
  State<StatefulWidget> createState() => _ValueListenableBuilderState<T>();
}

class _ValueListenableBuilderState<T> extends State<SafeValueListenableBuilder<T>> {
  late T value;
  bool setStateScheduled = false;

  @override
  void initState() {
    super.initState();
    value = widget.valueListenable.value;
    widget.valueListenable.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(SafeValueListenableBuilder<T> oldWidget) {
    if (oldWidget.valueListenable != widget.valueListenable) {
      oldWidget.valueListenable.removeListener(_valueChanged);
      value = widget.valueListenable.value;
      widget.valueListenable.addListener(_valueChanged);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.valueListenable.removeListener(_valueChanged);
    super.dispose();
  }

  // this callback maybe happen at any time,
  // eg. when the last page's state.dispose() or finalizeTree
  // at wrong time, setState call will be ignored and the widget will not be rebuild
  // so it is necessary to delay the setState call to next frame
  void _valueChanged() {
    if (SchedulerBinding.instance!=null && SchedulerBinding.instance!.schedulerPhase != SchedulerPhase.idle &&
        SchedulerBinding.instance!.schedulerPhase != SchedulerPhase.postFrameCallbacks) {
      if (setStateScheduled) return;
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
        if (mounted) {
          setState(() {
            setStateScheduled = false;
            value = widget.valueListenable.value;
          });
        }
      });
      setStateScheduled = true;
      return;
    }
    setState(() {
      setStateScheduled = false;
      value = widget.valueListenable.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value, widget.child);
  }
}
