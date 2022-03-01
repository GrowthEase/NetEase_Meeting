// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_uikit;

class StateLifecycleExecutor {
  static const _tag = 'StateLifecycleExecutor';
  Map<UniqueKey, CancelableOperation> _futures = new Map();

  Map<UniqueKey, StreamSubscription> _subscriptions = new Map();

  bool _enable = true;

  Future<T?> execUi<T>(Future<T> future) {
    LoadingUtil.showLoading();
    return exec(future).whenComplete(() {
      LoadingUtil.cancelLoading();
    });
  }

  Future<T?> exec<T>(Future<T> future) {
    if (!_enable) {
      return Future<T>.error('This Executor is disable');
    }

    UniqueKey key = UniqueKey();
    CancelableOperation<T> operation =
        CancelableOperation.fromFuture(future, onCancel: () {
      if (_enable) {
        _futures.remove(key);
      }
    });
    _futures.putIfAbsent(key, () => operation);

    operation.value.whenComplete(() {
      if (_enable) {
        _futures.remove(key);
      }
    });
    return operation.valueOrCancellation();
  }

  UniqueKey? listen<T>(Stream<T> stream, void onData(T event)) {
    if (!_enable) {
      return null;
    }

    UniqueKey key = UniqueKey();
    _subscriptions.putIfAbsent(key, () => stream.listen(onData));
    return key;
  }

  void unListen(UniqueKey key) {
    StreamSubscription? subscription = _subscriptions.remove(key);
    if (_enable) {
      subscription?.cancel();
    }
  }

  void cancel() {
    _disable();

    var iterable = _futures.values;
    for (var element in iterable) {
      element.cancel();
      Alog.d(
          tag: _tag, moduleName: _moduleName, content: 'drop future: $element');
    }
    _futures.clear();
    for (var element in _subscriptions.values) {
      element.cancel();
      Alog.d(
          tag: _tag,
          moduleName: _moduleName,
          content: 'drop subscriptions: $element');
    }
    _subscriptions.clear();
  }

  void _disable() {
    _enable = false;
  }
}
