// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import '../model/client_upgrade_info.dart';
import '../repo/i_repo.dart';
import '../response/result.dart';

/// 不知道放哪儿的， 都放这儿
class MiscRepo extends IRepo {
  MiscRepo._internal();

  static final MiscRepo _singleton = MiscRepo._internal();

  factory MiscRepo() => _singleton;

  Future<Result<void>> downloadFile(
      String url, File file, void Function(int count, int total) progress) {
    return appService.downloadFile(url, file, progress);
  }
}
