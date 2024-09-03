// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:yunxin_alog/yunxin_alog.dart';
import 'package:flutter/services.dart';

abstract class BaseChannel {
  void dispose();
}

typedef NEMeetingChannelCallback = Function(String value);

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

  final List<NEMeetingChannelCallback> _list = [];

  late final StreamSubscription streamSubscription;

  void listen(NEMeetingChannelCallback callback) {
    _list.add(callback);
    startUri().then(_onRedirected);
  }

  void unListen(NEMeetingChannelCallback callback) {
    _list.remove(callback);
  }

  /// native  --  dart
  Future<dynamic> _handler(MethodCall call) => Future.value();

  void notify(String uri) {
    _list.forEach((NEMeetingChannelCallback callback) {
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
      return await platform
              .invokeMethod('apkDownloadOk', {'filePath': filePath}) as int? ??
          -1;
    } on PlatformException catch (e) {
      Alog.e(tag: _tag, content: 'download error ${e.message}');
      return -1;
    }
  }

  Future<String> notifyMeetingStatusChanged(int meetingStatus) async {
    try {
      return await platform.invokeMethod('notifyMeetingStatusChanged', {
        'meetingStatus': meetingStatus,
      }) as String;
    } on PlatformException catch (e) {
      Alog.e(
          tag: _tag,
          content: 'notifyMeetingStatusChanged exception: ${e.message}');
      return '';
    }
  }

  Future<String> notifyInMeetingPermissionRequest(String permissionName) async {
    Alog.i(
        tag: _tag,
        content: 'notifyInMeetingPermissionRequest: $permissionName');
    try {
      return await platform.invokeMethod('notifyInMeetingPermissionRequest', {
        'permissionName': permissionName,
      }) as String;
    } on PlatformException catch (e) {
      Alog.e(
          tag: _tag,
          content: 'notifyInMeetingPermissionRequest exception: ${e.message}');
      return '';
    }
  }
}
