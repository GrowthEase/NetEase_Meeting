// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_kit;

class NetworkTaskExecutor with _AloggerMixin {
  final _globalType = Object();

  bool _disposed = false;
  final _taskRegistry = <Object, List<_NetworkTask>>{};
  final _pendingCompleteTaskRegistry = <Object, Future>{};

  NetworkTaskExecutor() {
    ConnectivityManager().addListener(_onNetworkChanged);
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
      commonLogger.i('tasks cancelled: ${waitingTasks.join('-')}');
    }

    final taskWrapper =
        _NetworkTask<T>(task, debugName ?? (type?.toString() ?? 'Global'));
    _taskRegistry
        .putIfAbsent(type ?? _globalType, () => <_NetworkTask>[])
        .add(taskWrapper);

    Future.value().then((_) => _scheduleTasks());

    commonLogger.i('task added: $taskWrapper');

    return taskWrapper.completer.future.then((value) => value as T?);
  }

  void dispose() {
    _disposed = true;
    _taskRegistry.clear();
    ConnectivityManager().removeListener(_onNetworkChanged);
  }

  Future<bool> _isNetworkConnected() async {
    return ConnectivityManager().isConnected();
  }

  void _onNetworkChanged() {
    _scheduleTasks();
  }

  void _scheduleTasks() async {
    if (_disposed || !await _isNetworkConnected()) return;
    final registry = Map.of(_taskRegistry);
    _taskRegistry.clear();
    registry.forEach((key, tasks) {
      _executeTaskInParallel(key, tasks);
    });
  }

  void _executeTaskInParallel(Object key, List<_NetworkTask> tasks) async {
    final executed = <_NetworkTask>[];
    while (tasks.isNotEmpty && await _isNetworkConnected()) {
      final task = tasks.removeAt(0);
      executed.add(task);
      final _previousTaskFuture =
          _pendingCompleteTaskRegistry[key] ?? Future.value();
      final _thisTaskFuture = task.completer.future;
      _pendingCompleteTaskRegistry[key] = _thisTaskFuture;
      try {
        task.completer.complete(_previousTaskFuture.then((value) async {
          var taskResult;
          try {
            taskResult = await task.task();
          } catch (e) {
            taskResult = null;
          }
          commonLogger.i(
              'task executed: $task:${taskResult != null ? 'Success' : 'Failure'}');
        }));
      } catch (e, s) {
        task.completer.completeError(e, s);
      }
      _thisTaskFuture.whenComplete(() {
        if (_pendingCompleteTaskRegistry[key] == _thisTaskFuture) {
          _pendingCompleteTaskRegistry.remove(key);
        }
      });
    }
  }
}

class _NetworkTask<T> {
  static int counter = 0;

  final int _index = counter++;
  final String debugName;
  final Future<T> Function() task;
  final Completer completer;

  _NetworkTask(this.task, this.debugName) : completer = Completer();

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write(debugName);
    buffer.write('#');
    buffer.write(_index);
    return buffer.toString();
  }
}
