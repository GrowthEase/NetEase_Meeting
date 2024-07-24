// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

typedef CanPopGetter<T> = bool Function(T);

///
/// PopScope 包装类
///
class PopScopeBuilder<T extends Listenable> extends StatelessWidget {
  const PopScopeBuilder({
    super.key,
    required this.listenable,
    this.canPopGetter,
    this.onDidPop,
    this.onInterceptPop,
    this.child,
    this.builder,
  }) : assert(child != null || builder != null);

  final T listenable;

  final CanPopGetter<T>? canPopGetter;

  final Widget? child;

  final ValueWidgetBuilder<T>? builder;

  final VoidCallback? onDidPop;

  final VoidCallback? onInterceptPop;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, child) {
        return PopScope(
          canPop: _canPop(canPopGetter, listenable),
          onPopInvoked: _onPopInvoked,
          child:
              builder != null ? builder!(context, listenable, child) : child!,
        );
      },
      child: child,
    );
  }

  void _onPopInvoked(bool didPop) {
    if (didPop) {
      onDidPop?.call();
    } else {
      onInterceptPop?.call();
    }
  }

  static bool _canPop<T extends Listenable>(
      CanPopGetter<T>? canPopGetter, T listenable) {
    if (canPopGetter != null) {
      return canPopGetter(listenable);
    }
    if (listenable is ValueListenable) {
      return listenable.value == true;
    }
    return true;
  }
}
