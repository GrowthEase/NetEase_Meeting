// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/model/account_app_info.dart';
import 'package:nemeeting/service/model/client_upgrade_info.dart';
import 'package:nemeeting/service/proto/app_http_proto/client_update_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/download_file_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/get_account_appinfo_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/report_yidun_token.dart';
import 'package:nemeeting/service/response/result.dart';
import 'package:nemeeting/service/service/base_service.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

/// http service
class AppService extends BaseService {
  AppService._internal();

  static final AppService _singleton = AppService._internal();

  factory AppService() => _singleton;

  NEMeetingCorpInfo? _corpInfo = null;

  /// 客户端升级
  Future<Result<UpgradeInfo>> getClientUpdateInfo(String? accountId,
      String versionName, int versionCode, int clientAppCode) async {
    return execute(
        ClientUpdateProto(accountId, versionName, versionCode, clientAppCode));
  }

  /// 下载文件进度
  Future<Result<void>> downloadFile(
      String url, File file, ProgressCallback progress) {
    return execute(DownloadFileProto(url, file, progress));
  }

  /// 获取用户当前绑定公司信息
  Future<Result<AccountAppInfo>> getAccountAppInfo() {
    return execute(GetAccountAppInfoProto());
  }

  Future<Result<void>> reportYiDunToken(String token) async {
    final appKey = AuthManager().appKey;
    final user = AuthManager().accountId;
    if (appKey != null && user != null && token.isNotEmpty) {
      return execute(ReportYiDunTokenProto(appKey, user, token));
    }
    return Result(code: -1, msg: 'Empty appKey or userId');
  }

  void saveCorpInfo(NEMeetingCorpInfo corpInfo) {
    GlobalPreferences().setCorpInfo(jsonEncode(corpInfo));
  }

  Future<NEMeetingCorpInfo?> getCorpInfo() async {
    if (_corpInfo != null) {
      return _corpInfo;
    }
    String? corpInfo = await GlobalPreferences().corpInfo;
    if (corpInfo != null) {
      _corpInfo = NEMeetingCorpInfo.fromJson(jsonDecode(corpInfo) as Map);
      return _corpInfo;
    } else {
      return null;
    }
  }
}
