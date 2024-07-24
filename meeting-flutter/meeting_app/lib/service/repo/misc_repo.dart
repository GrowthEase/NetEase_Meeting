// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:netease_common/netease_common.dart';

import '../model/client_upgrade_info.dart';
import '../repo/i_repo.dart';

/// 不知道放哪儿的， 都放这儿
class MiscRepo extends IRepo {
  MiscRepo._internal();

  static final MiscRepo _singleton = MiscRepo._internal();

  factory MiscRepo() => _singleton;

  Future<NEResult<UpgradeInfo>> getClientUpdateInfo(String? accountId,
      String versionName, int versionCode, int clientAppCode) async {
    return appService.getClientUpdateInfo(
        accountId, versionName, versionCode, clientAppCode);
  }

  Future<NEResult<void>> downloadFile(
      String url, File file, void Function(int count, int total) progress) {
    return appService.downloadFile(url, file, progress);
  }
}
