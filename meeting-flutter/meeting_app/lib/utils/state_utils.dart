// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

import '../language/localizations.dart';

extension StateExt on State {
  Future<T?> doIfNetworkAvailable<T>(FutureOr<T> Function() callback) async {
    final connected = await ConnectivityManager().isConnected();
    if (!mounted) return null;
    if (!connected) {
      ToastUtils.showToast(
          context, getAppLocalizations().globalNetworkUnavailableCheck);
      return null;
    }
    return callback();
  }
}
