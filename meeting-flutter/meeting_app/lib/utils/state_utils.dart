// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/widgets.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

import '../language/meeting_localization/meeting_app_localizations.dart';

extension StateExt on State {
  Future<T?> doIfNetworkAvailable<T>(FutureOr<T> Function() callback) async {
    final result = await Connectivity().checkConnectivity();
    if (!mounted) return null;
    if (result == ConnectivityResult.none) {
      ToastUtils.showToast(context,
          MeetingAppLocalizations.of(context)!.globalNetworkUnavailableCheck);
      return null;
    }
    return callback();
  }
}
