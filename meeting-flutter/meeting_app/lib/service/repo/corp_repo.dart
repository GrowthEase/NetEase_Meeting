// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:async/async.dart' as async;
import 'package:flutter/foundation.dart';
import 'package:nemeeting/constants.dart';
import 'package:nemeeting/service/model/login_info.dart';
import 'package:netease_common/netease_common.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../config/servers.dart';
import '../proto/app_http_proto/corp_proto.dart';
import '../response/result.dart';

class CorpRepo {
  static const int accountPasswordNeedReset = 3426;

  static final _corpInfoCache =
      <String, async.AsyncCache<Result<NECorpInfo>>>{};

  static Future<Result<NECorpInfo>> getCorpInfo({
    String? corpCode,
    String? corpEmail,
  }) {
    assert(corpCode != null || corpEmail != null);
    final asyncCache = _corpInfoCache.putIfAbsent(
        corpCode ?? corpEmail!, () => async.AsyncCache(Duration(minutes: 30)));
    return asyncCache.fetch(() =>
        GetCorpInfoProto(corpCode: corpCode, corpEmail: corpEmail).execute());
  }

  static Future<Result<LoginInfo>> getCorpAccountInfo(
    String appKey,
    String key,
    String param,
  ) {
    return GetCorpAccountInfoProto(appKey, key, param).execute();
  }

  /// 支持通过账号/账号ID 重置密码
  static Future<Result<LoginInfo>> resetPassword(
      String appKey, String oldPassword, String newPassword,
      {String? account, String? accountId}) {
    return ResetPasswordProto(appKey, oldPassword, newPassword,
            account: account, accountId: accountId)
        .execute();
  }
}

final class NECorpInfo {
  final String appKey;
  final String corpName;
  final String? corpCode;
  final List<NEIdpInfo> idpList;

  NECorpInfo(this.appKey, this.corpName, this.idpList, {this.corpCode});

  NECorpInfo.fromJson(Map map, {this.corpCode})
      : appKey = map['appKey'],
        corpName = map['appName'],
        idpList = (map['idpList'] as List? ?? [])
            .map((e) => NEIdpInfo.fromJson(e))
            .toList();
}

final class NEIdpInfo {
  static const int typeOAuth2 = 1;

  final int id;
  final int type;
  final String? name;

  NEIdpInfo(this.id, this.type, this.name);

  NEIdpInfo.fromJson(Map map)
      : id = map['id'],
        type = map['type'],
        name = map['name'];
}

final class NESSOLoginController with AppLogger {
  static const int success = 0;
  static const int fail = -1;
  static const int ignore = -2;
  static const int corpNotFound = -3;
  static const int corpNotSupportSSO = -4;

  final String? callback;
  final int authType;

  String _uuid = '';
  bool _disposed = false;
  String _appKey = '';

  NESSOLoginController({
    this.callback,
    this.authType = NEIdpInfo.typeOAuth2,
  });

  String get appKey => _appKey;

  Future<int> launchAuthPage({
    String? corpCode,
    String? corpEmail,
  }) async {
    assert(corpCode != null || corpEmail != null);
    if (_disposed) return ignore;
    // 获取企业信息
    final corpInfoResult = await CorpRepo.getCorpInfo(
      corpCode: corpCode,
      corpEmail: corpEmail,
    );
    logger.e(
        'launchAuthPage corp info result: ${corpInfoResult.toShortString()}');
    if (_disposed) return ignore;
    final corpInfo = corpInfoResult.data;
    if (corpInfo == null) {
      logger.e('launchAuthPage corp not found');
      return corpNotFound;
    }
    // 获取企业信息中的认证信息
    final oauthIdp = corpInfo.idpList
        .where((element) => element.type == authType)
        .firstOrNull;
    if (oauthIdp == null) {
      logger.e('launchAuthPage corp not support sso');
      return corpNotSupportSSO;
    }
    // 打开认证页面
    var launchResult = false;
    try {
      final uri = _buildAuthUri(corpInfo.appKey, oauthIdp.id);
      logger.i('launchAuthPage uri: $uri');
      launchResult = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e, s) {
      debugPrintStack(label: 'launchAuthPage error', stackTrace: s);
      logger.e('launchAuthPage error: $e');
    }
    return launchResult ? success : fail;
  }

  Uri _buildAuthUri(String appKey, int idp) {
    _appKey = appKey;
    _uuid = Uuid().v4();
    final uri = Uri.parse(Servers().baseUrl + 'scene/meeting/v2/sso-authorize');
    return uri.replace(
      queryParameters: {
        if (callback != null && callback!.isNotEmpty) 'callback': callback!,
        'appKey': appKey,
        'idp': idp.toString(),
        'key': _uuid,
        'clientType': Platform.isAndroid ? 'android' : 'ios',
      },
    );
  }

  Future<Result<LoginInfo>> parseAuthResult(String uri) async {
    if (_disposed) return Result(code: ignore);
    final uriData = Uri.parse(uri);
    final param = uriData.queryParameters['param'];
    if (param != null && param.isNotEmpty) {
      if (_appKey.isEmpty) return Result(code: fail);
      return CorpRepo.getCorpAccountInfo(_appKey, _uuid, param);
    }
    return Result(code: ignore);
  }

  void dispose() {
    _disposed = true;
  }
}
