// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/model/account_app_info.dart';
import 'package:nemeeting/service/model/account_apps.dart';
import 'package:nemeeting/service/model/client_upgrade_info.dart';
import 'package:nemeeting/service/model/history_meeting.dart';
import 'package:nemeeting/service/model/history_meeting_detail.dart';
import 'package:nemeeting/service/model/login_info.dart';
import 'package:nemeeting/service/model/parse_sso_token.dart';
import 'package:nemeeting/service/proto/app_http_proto/auth_code_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/client_update_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/download_file_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/get_account_appinfo_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/get_account_apps_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/history_meeting_details_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/history_meeting_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/favourited_meeting_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/login_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/meeting_cancle_favourite_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/meeting_favourite_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/parse_ssotoken_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/password_modify_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/password_reset_by_exchange_code_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/password_reset_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/register_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/report_yidun_token.dart';
import 'package:nemeeting/service/proto/app_http_proto/switch_app_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/update_nickname_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/security_notice_proto.dart';
import 'package:nemeeting/service/proto/app_http_proto/update_avatar_proto.dart';
import 'package:nemeeting/service/model/security_notice_info.dart';
import 'package:nemeeting/service/proto/get_meeting_info_proto.dart';
import 'package:nemeeting/service/repo/corp_repo.dart';
import 'package:nemeeting/service/response/result.dart';
import 'package:nemeeting/service/service/base_service.dart';

/// http service
class AppService extends BaseService {
  AppService._internal();

  static final AppService _singleton = AppService._internal();

  factory AppService() => _singleton;

  NECorpInfo? _corpInfo = null;

  /// 安全提示接口
  Future<Result<AppNotifications>> getSecurityNoticeConfigs(
      String appKey, String time) {
    return execute(SecurityNoticeProto(appKey, time));
  }

  /// 请求发送短信验证码
  Future<Result<void>> getMobileCheckCode(String appKey, String mobile) {
    return execute(GetMobileCheckCodeProto(appKey, mobile));
  }

  /// 注册
  Future<Result<LoginInfo>> register(String mobile, String verifyExchangeCode,
      String nickName, String passWord) {
    return execute(
        RegisterProto(mobile, verifyExchangeCode, nickName, passWord));
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
  Future<Result<void>> passwordResetByMobileCode(
      String mobile, String newPassWord, String verifyExchangeCode) {
    return execute(
        PasswordResetByCodeProto(mobile, newPassWord, verifyExchangeCode));
  }

  /// 昵称修改
  Future<Result<void>> updateNickname(String nickName) {
    return execute(UpdateNicknameProto(nickName));
  }

  /// 更新头像
  Future<Result<void>> updateAvatar(String url) {
    return execute(UpdateAvatarProto(url));
  }

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

  /// 获取用户当前绑定公司列表
  Future<Result<AccountApps>> getAccountApps() {
    return execute(GetAccountAppsInfoProto());
  }

  /// 切换公司
  Future<Result<LoginInfo>> switchApp() {
    return execute(SwitchAppProto());
  }

  Future<Result<void>> reportYiDunToken(String token) async {
    final appKey = AuthManager().appKey;
    final user = AuthManager().accountId;
    if (appKey != null && user != null && token.isNotEmpty) {
      return execute(ReportYiDunTokenProto(appKey, user, token));
    }
    return Result(code: -1, msg: 'Empty appKey or userId');
  }

  // 获取所有历史会议信息
  Future<Result<List<HistoryMeeting>>> getAllHistoryMeetings(
      [int? startId, int limit = 20]) async {
    final appKey = AuthManager().appKey;
    if (appKey != null) {
      return execute(HistoryAllMeetingProto(appKey, startId, limit));
    }
    return Result(code: -1, msg: 'Empty appKey or userId');
  }

  // 获取历史会议某个具体会议详细信息
  Future<Result<HistoryMeeting>> getHistoryMeetingDetailsByMeetingId(
      int meetingId) async {
    final appKey = AuthManager().appKey;
    if (appKey != null) {
      return execute(HistoryMeetingDetailsInfoProto(appKey, meetingId));
    }
    return Result(code: -1, msg: 'Empty appKey or userId');
  }

  // 获取会议收藏列表
  Future<Result<List<HistoryMeeting>>> getFavoriteMeetings(
      [int? startId, int limit = 20]) async {
    final appKey = AuthManager().appKey;
    if (appKey != null) {
      return execute(FavoriteMeetingProto(appKey, startId, limit));
    }
    return Result(code: -1, msg: 'Empty appKey or userId');
  }

  // 收藏会议
  Future<Result<int?>> favouriteMeeting(int roomArchiveId) async {
    final appKey = AuthManager().appKey;
    if (appKey != null) {
      return execute(FavouriteMeetingProto(appKey, roomArchiveId));
    }
    return Result(code: -1, msg: 'Empty appKey or userId');
  }

  //  使用roomArchiveId取消收藏参会记录
  Future<Result<void>> cancelFavoriteMeetingByRoomArchiveId(
      int roomArchiveId) async {
    final appKey = AuthManager().appKey;
    if (appKey != null) {
      return execute(CancelFavoriteByRoomArchiveIdProto(appKey, roomArchiveId));
    }
    return Result(code: -1, msg: 'Empty appKey or userId');
  }

  // 使用favoriteId取消收藏参会记录
  Future<Result<void>> cancelFavoriteMeetingByFavoriteId(int favoriteId) async {
    final appKey = AuthManager().appKey;
    if (appKey != null) {
      return execute(CancelFavoriteByFavoriteIdProto(appKey, favoriteId));
    }
    return Result(code: -1, msg: 'Empty appKey or userId');
  }

  // 获取历史会议详细信息、聊天室信息
  Future<Result<HistoryMeetingDetail>> getHistoryMeetingDetails(
      int roomArchiveId) async {
    final appKey = AuthManager().appKey;
    if (appKey != null) {
      return execute(HistoryMeetingDetailsProto(appKey, roomArchiveId));
    }
    return Result(code: -1, msg: 'Empty appKey or userId');
  }

  void saveCorpInfo(NECorpInfo corpInfo) {
    GlobalPreferences().setCorpInfo(jsonEncode(corpInfo));
  }

  Future<NECorpInfo?> getCorpInfo() async {
    if (_corpInfo != null) {
      return _corpInfo;
    }
    String? corpInfo = await GlobalPreferences().corpInfo;
    if (corpInfo != null) {
      _corpInfo = NECorpInfo.fromJson(jsonDecode(corpInfo) as Map);
      return _corpInfo;
    } else {
      return null;
    }
  }
}
