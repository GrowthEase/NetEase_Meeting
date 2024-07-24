// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/model/client_upgrade_info.dart';
import 'package:nemeeting/service/proto/app_http_proto/client_update_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/download_file_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/report_yidun_token.dart';
import 'package:nemeeting/service/service/base_service.dart';
import 'package:netease_common/netease_common.dart';

/// http service
class AppService extends BaseService {
  AppService._internal();

  static final AppService _singleton = AppService._internal();

  factory AppService() => _singleton;

  /// 客户端升级
  Future<NEResult<UpgradeInfo>> getClientUpdateInfo(String? accountId,
      String versionName, int versionCode, int clientAppCode) async {
    return execute(
        ClientUpdateProto(accountId, versionName, versionCode, clientAppCode));
  }

  /// 下载文件进度
  Future<NEResult<void>> downloadFile(
      String url, File file, ProgressCallback progress) {
    return execute(DownloadFileProto(url, file, progress));
  }

  Future<NEResult<void>> reportYiDunToken(String token) async {
    final appKey = AuthManager().appKey;
    final user = AuthManager().accountId;
    if (appKey != null && user != null && token.isNotEmpty) {
      return execute(ReportYiDunTokenProto(appKey, user, token));
    }
    return NEResult(code: -1, msg: 'Empty appKey or userId');
  }
}
