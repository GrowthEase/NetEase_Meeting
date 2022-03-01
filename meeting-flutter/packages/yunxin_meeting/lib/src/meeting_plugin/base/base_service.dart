// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_plugin;

abstract class _Service extends _Handler {

  final MethodChannel _methodChannel;

  static const String receiptIdKey = "receiptId";

  _Service(this._methodChannel, Map<String, _Handler> handlerMap) :super(handlerMap);

  static int initId = 0;

  /// native 2 flutter callback
  Future<dynamic> _handlerMethod(String method, int code, Map arg, dynamic callback);

  // inner use 
  String _generateReceiptId() {
    initId++;
    return _getModule() + initId.toString();
  }

  Map<String, dynamic> callbacks = Map<String, dynamic>();

  Map<String, dynamic> buildArguments<T>({Map? arg, NEPluginCallback<T>? callback}) {
    var map = <String, dynamic>{'module': _getModule()};
    if (callback != null) {
      var receiptId = _generateReceiptId();
      callbacks[receiptId] = callback;
      map[receiptIdKey] = receiptId;
    }
    if (arg != null && arg.isNotEmpty) {
      map.addAll(arg as Map<String, dynamic>);
    }
    return map;
  }

  dynamic _queryCallback({required Map map, bool oneShot = true}) {
    String receiptId = map[receiptIdKey] as String;
    print("_queryCallback key=" + receiptId);
    if (callbacks.containsKey(receiptId)) {
      return oneShot ? callbacks.remove(receiptId) : callbacks[receiptId];
    }
    return null;
  }

  @override
  Future<dynamic> _handler(MethodCall call) {
    final arg = call.arguments as Map?;
    if (arg != null) {
      dynamic callback = _queryCallback(map: arg);
      if (callback != null) {
        return _handlerMethod(
            call.method, (arg['code'] as int? ?? 0), arg, callback);
      }
    }
    return Future<dynamic>.value();
  }

}
