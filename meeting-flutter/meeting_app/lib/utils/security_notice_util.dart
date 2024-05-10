// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/model/security_notice_info.dart';

import 'package:nemeeting/service/repo/user_repo.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

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
    ConnectivityManager().onReconnected.listen((event) {
      _doFetch();
    });
  }

  void reset() {
    debugPrint('$_tag: reset');
    _state = _stateInitial;
    _currentNotification = null;
  }

  void hideNotification() {
    debugPrint('$_tag: hide');
    _currentNotification = null;
    _appNotificationStream.add(null);
  }

  void _doFetch() async {
    debugPrint('$_tag: doFetch, state=$_state');
    final appKey = AuthManager().appKey;
    if (_state == _stateInitial && appKey != null && appKey.length > 0) {
      _state = _stateFetching;
      final result = await UserRepo().getSecurityNoticeConfigs(
          appKey, DateTime.now().millisecondsSinceEpoch.toString());
      if (result.code == 0) {
        _state = _stateDone;
        final appNotifications = result.data;
        if (appNotifications != null &&
            appNotifications.notifications.isNotEmpty) {
          _currentNotification = appNotifications.notifications.first;
        }
      } else {
        _state = _stateInitial;
      }
    }
    if (_currentNotification != null) {
      Timer.run(() {
        _appNotificationStream.add(_currentNotification);
      });
    }
  }
}
