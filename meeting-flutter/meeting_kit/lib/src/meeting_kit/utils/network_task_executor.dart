// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_kit;

class NetworkTaskExecutor {
  final _globalType = Object();

  bool _disposed = false;
  final _taskRegistry = <Object, List<_NetworkTask>>{};
  late final StreamSubscription _subscription;

  var _latestConnectivityResult = ConnectivityResult.none;

  NetworkTaskExecutor() {
    _subscription =
        Connectivity().onConnectivityChanged.listen(_onNetworkChanged);
    Connectivity()
        .checkConnectivity()
        .then((value) => _onNetworkChanged(value));
  }

  Future<T?> execute<T>(
    Future<T> Function() task, {
    String? debugName,
    Object? type,
    bool cancelOthers = false,
  }) async {
    assert(!_disposed);

    if (type != null && cancelOthers) {
      final waitingTasks = _taskRegistry.remove(type) ?? [];
      waitingTasks.forEach((task) {
        task.completer.completeError('Cancelled');
      });
      assert(() {
        debugPrint('NetworkTaskExecutor cancel: ${waitingTasks.join('-')}');
        return true;
      }());
    }

    final taskWrapper =
        _NetworkTask<T>(task, debugName ?? (type?.toString() ?? 'Global'));
    _taskRegistry
        .putIfAbsent(type ?? _globalType, () => <_NetworkTask>[])
        .add(taskWrapper);

    Future.value().then((_) => _scheduleTasks());

    assert(() {
      debugPrint('NetworkTaskExecutor add: $taskWrapper');
      return true;
    }());

    return taskWrapper.completer.future;
  }

  void dispose() {
    _disposed = true;
    _taskRegistry.clear();
    _subscription.cancel();
  }

  bool _isNetworkConnected() {
    return _latestConnectivityResult != ConnectivityResult.none;
  }

  void _onNetworkChanged(ConnectivityResult value) {
    _latestConnectivityResult = value;
    _scheduleTasks();
  }

  void _scheduleTasks() {
    if (_disposed || !_isNetworkConnected()) return;
    final registry = Map.of(_taskRegistry);
    _taskRegistry.clear();
    registry.forEach((key, tasks) {
      _executeTaskInParallel(tasks);
    });
  }

  void _executeTaskInParallel(List<_NetworkTask> tasks) {
    final executed = <_NetworkTask>[];
    while (tasks.isNotEmpty && _isNetworkConnected()) {
      final task = tasks.removeAt(0);
      executed.add(task);
      try {
        task.completer.complete(task.task());
      } catch (e, s) {
        task.completer.completeError(e, s);
      }
    }
    assert(() {
      debugPrint('NetworkTaskExecutor execute: ${executed.join('-')}');
      return true;
    }());
  }
}

class _NetworkTask<T> {
  static int counter = 0;

  final int _index = counter++;
  final String debugName;
  final Future<T> Function() task;
  final Completer<T> completer;

  _NetworkTask(this.task, this.debugName) : completer = Completer<T>();

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write(debugName);
    buffer.write('#');
    buffer.write(_index);
    return buffer.toString();
  }
}
