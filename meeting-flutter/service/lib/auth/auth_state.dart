// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

/// auth state
class AuthState {
  /// 无账号
  static const int init = 0;

  /// 有账号密码，可以自动登录
  static const int unauth = 1;

  /// 已登录
  static const int authed = 2;

  /// 退出
  static const int logout = 3;

  static const int tokenIllegal = 4;

  static final AuthState _singleton = AuthState._internal();

  factory AuthState() => _singleton;

  int _state = init;

  StreamController<AuthEvent> broadcast = StreamController.broadcast();

  AuthState._internal();

  Stream<AuthEvent> authState() {
    return broadcast.stream;
  }

  void updateState({required int state, String errorTip = ''}) {
    _state = state;
    broadcast.add(AuthEvent(_state, errorTip));
  }
}

class AuthEvent {
  final int state;
  final String errorTip;

  AuthEvent(this.state, this.errorTip);

  @override
  String toString() {
    return 'state=${state},errorTip=${errorTip}';
  }
}
