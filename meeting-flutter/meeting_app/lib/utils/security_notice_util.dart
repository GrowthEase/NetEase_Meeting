// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/widgets.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/model/security_notice_info.dart';

import 'package:nemeeting/service/repo/user_repo.dart';

class AppNotificationManager {
  static const _tag = 'AppNotificationManager';

  static final _singleton = AppNotificationManager._internal();

  factory AppNotificationManager() => _singleton;

  static const _stateInitial = 0;
  static const _stateFetching = 1;
  static const _stateDone = 2;

  int _state = _stateInitial;

  AppNotification? _currentNotification;

  final _appNotificationStream = StreamController<AppNotification?>.broadcast();

  Stream<AppNotification?> get appNotification {
    _doFetch();
    return _appNotificationStream.stream;
  }

  AppNotificationManager._internal() {
    Connectivity().onConnectivityChanged.listen((event) {
      if (event != ConnectivityResult.none) {
        _doFetch();
      }
    });
  }

  void reset() {
    debugPrint('$_tag: reset');
  }

  void hideNotification() {
    debugPrint('$_tag: hide');
    _currentNotification = null;
    _appNotificationStream.add(null);
  }

  void _doFetch() async {
    debugPrint('$_tag: doFetch');
  }
}
