// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:service/model/client_upgrade_info.dart';
import 'package:service/repo/i_repo.dart';
import 'package:service/response/result.dart';

/// 不知道放哪儿的， 都放这儿
class MiscRepo extends IRepo {
  MiscRepo._internal();

  static final MiscRepo _singleton = MiscRepo._internal();

  factory MiscRepo() => _singleton;

  Future<Result<UpgradeInfo>> getClientUpdateInfo(String? accountId, String versionName, int versionCode, int clientAppCode) async {
    return appService.getClientUpdateInfo(accountId, versionName, versionCode, clientAppCode);
  }

  Future<Result<void>> downloadFile(String url, File file, void Function(int count, int total) progress) {
    return appService.downloadFile(url, file, progress);
  }
}
