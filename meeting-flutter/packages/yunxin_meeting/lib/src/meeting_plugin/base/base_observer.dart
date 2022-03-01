// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_plugin;

typedef NEPluginObserver<T> = void Function(T data);

typedef NEPluginCallback<T> = void Function(int code, T data);

abstract class _Observable extends _Handler {
  final MethodChannel _methodChannel;

  _Observable(this._methodChannel, Map<String, _Handler> handlerMap) : super(handlerMap);

  Future<dynamic> _handlerMethod(String method, Map? arg);

  @override
  Future _handler(MethodCall call) {
    return _handlerMethod(call.method, call.arguments as Map?);
  }

  /// register observer type
  void registerObserver<T>(NEPluginObserver<T> observer, List<NEPluginObserver<T>> list) {
    if (list.contains(observer)) {
      return;
    }
    list.add(observer);
  }

  /// unregister observer T type
  void unregisterObserver<T>(NEPluginObserver<T> observer, List<NEPluginObserver<T>> list) {
    if (list.contains(observer)) {
      list.remove(observer);
    }
  }

  /// notify
  void notifyObserver<T>(List<NEPluginObserver<T>> list, T data) {
    if (list.isEmpty || data == null) {
      return;
    }
    for (NEPluginObserver<T> observer in list) {
      observer(data);
    }
  }
}
