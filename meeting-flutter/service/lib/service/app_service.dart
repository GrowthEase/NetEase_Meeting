// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:service/config/scene_type.dart';
import 'package:service/model/account_app_info.dart';
import 'package:service/model/account_apps.dart';
import 'package:service/model/client_upgrade_info.dart';
import 'package:service/model/login_info.dart';
import 'package:service/model/parse_sso_token.dart';
import 'package:service/proto/app_http_proto/auth_code_proto.dart';
import 'package:service/proto/app_http_proto/client_update_proto.dart';
import 'package:service/proto/app_http_proto/download_file_proto.dart';
import 'package:service/proto/app_http_proto/get_account_appinfo_proto.dart';
import 'package:service/proto/app_http_proto/get_account_apps_proto.dart';
import 'package:service/proto/app_http_proto/login_proto.dart';
import 'package:service/proto/app_http_proto/parse_ssotoken_proto.dart';
import 'package:service/proto/app_http_proto/password_modify_proto.dart';
import 'package:service/proto/app_http_proto/password_reset_by_exchange_code_proto.dart';
import 'package:service/proto/app_http_proto/password_reset_proto.dart';
import 'package:service/proto/app_http_proto/switch_app_proto.dart';
import 'package:service/proto/app_http_proto/update_nickname_proto.dart';
import 'package:service/proto/app_http_proto/verify_auth_code_proto.dart';
import 'package:service/proto/app_http_proto/security_notice_proto.dart';
import 'package:service/model/security_notice_info.dart';
import 'package:service/response/result.dart';
import 'package:service/service/base_service.dart';

/// http service
class AppService extends BaseService {
  AppService._internal();

  static final AppService _singleton = AppService._internal();

  factory AppService() => _singleton;

  /// 安全提示接口
  Future<Result<SecurityNoticeInfo>> getSecurityNoticeConfigs(String time) {
    return execute(SecurityNoticeProto(time));
  }

  /// 请求发送短信验证码
  Future<Result<void>> getAuthCode(String mobile, SceneType scene) {
    return execute(AuthCodeProto(mobile, scene));
  }

  /// 验证验证码
  Future<Result<String>> verifyAuthCode(String mobile, String authCode, SceneType scene) {
    return execute(VerifyAuthCodeProto(mobile, authCode, scene));
  }

  /// 登录
  Future<Result<LoginInfo>> login(LoginProto loginProto) {
    return execute(loginProto);
  }

  /// 密码修改
  Future<Result<String>> passwordVerify(String userId, String oldPassword) {
    return execute(PasswordVerifyProto(userId, oldPassword));
  }

  /// ssoToken解析
  Future<Result<ParseSSOToken>> parseSSOToken(String ssoToken) {
    return execute(ParseSSOTokenProto(ssoToken));
  }

  /// 登录后密码重置
  Future<Result<void>> passwordReset(String newPassWord) {
    return execute(PasswordResetProto(newPassWord));
  }

  /// 登录前密码重置
  Future<Result<void>> passwordResetByMobileCode(String mobile, String newPassWord, String verifyExchangeCode) {
    return execute(PasswordResetByCodeProto(mobile,newPassWord, verifyExchangeCode));
  }

  /// 昵称修改
  Future<Result<void>> updateNickname(String nickName) {
    return execute(UpdateNicknameProto(nickName));
  }

  /// 客户端升级
  Future<Result<UpgradeInfo>> getClientUpdateInfo(String? accountId, String versionName, int versionCode, int clientAppCode) async {
    return execute(ClientUpdateProto(accountId, versionName, versionCode, clientAppCode));
  }

  /// 下载文件进度
  Future<Result<void>> downloadFile(String url, File file, ProgressCallback progress) {
    return execute(DownloadFileProto(url, file, progress));
  }

  /// 获取用户当前绑定公司信息
  Future<Result<AccountAppInfo>> getAccountAppInfo() {
    return execute(GetAccountAppInfoProto());
  }

  /// 获取用户当前绑定公司列表
  Future<Result<AccountApps>> getAccountApps() {
    return execute(GetAccountAppsInfoProto());
  }

  /// 切换公司
  Future<Result<LoginInfo>> switchApp() {
    return execute(SwitchAppProto());
  }
}

