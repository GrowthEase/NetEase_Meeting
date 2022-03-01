// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:yunxin_alog/yunxin_alog.dart';
import 'package:flutter/services.dart';

abstract class BaseChannel {
  void dispose();
}

typedef Callback = Function(String value);

class NEPlatformChannel extends BaseChannel {
  static const _tag = 'NEPlatformChannel';

  //Event Channel creation
  static const stream = EventChannel('meeting.meeting.netease.im/events');

  //Method channel creation
  static const platform = MethodChannel('meeting.meeting.netease.im/cnannel');

  static final NEPlatformChannel _singleton = NEPlatformChannel._internal();

  factory NEPlatformChannel() => _singleton;

  NEPlatformChannel._internal() {
    platform.setMethodCallHandler(_handler);
    streamSubscription = stream.receiveBroadcastStream().listen((d) {
      _onRedirected(d as String);
    });
  }

  //String uri;

  //Callback callback;

  final List<Callback> _list = [];

  late final StreamSubscription streamSubscription;

  void listen(Callback callback) {
    _list.add(callback);
    startUri().then(_onRedirected);
  }

  void unListen(Callback callback) {
    _list.remove(callback);
  }

  /// native  --  dart
  Future<dynamic> _handler(MethodCall call) => Future.value();

  void notify(String uri) {
    _list.forEach((Callback callback) {
      callback(uri);
    });
  }

  void _onRedirected(String uri) {
    // Here can be any uri analysis, checking tokens etc, if it’s necessary
    // Throw deep link URI into the BloC's stream
    if (uri.isEmpty) {
      return;
    }
    notify(uri);
  }

  Future<String> startUri() async {
    try {
      return await platform.invokeMethod('initialLink') as String;
    } on PlatformException catch (e) {
      Alog.e(tag: _tag, content: 'start uri exception: ${e.message}');
      return '';
    }
  }

  @override
  void dispose() {
    streamSubscription.cancel();
  }

  Future<int> downloadOk(String filePath) async {
    try {
      return platform.invokeMethod('apkDownloadOk', {'filePath': filePath})
          as int;
    } on PlatformException catch (e) {
      Alog.e(tag: _tag,  content: 'download error ${e.message}');
      return -1;
    }
  }
}
