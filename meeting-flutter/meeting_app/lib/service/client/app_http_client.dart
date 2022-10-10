// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:nemeeting/base/client_type.dart';
import 'package:dio/dio.dart';
import 'package:nemeeting/service/config/servers.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import 'package:nemeeting/service/profile/app_profile.dart';
import 'package:nemeeting/base/manager/device_manager.dart';

import '../module_name.dart';

class AppHttpClient {
  static AppHttpClient? _instance;

  factory AppHttpClient() {
    return _instance ??= AppHttpClient._internal();
  }

  late final Dio dio;

  AppHttpClient._internal() {
    final options = BaseOptions(
      baseUrl: servers.baseUrl,
      connectTimeout: servers.connectTimeout,
      receiveTimeout: servers.receiveTimeout,
    );

    dio = Dio(options);
    dio.interceptors.add(LogInterceptor(
      requestHeader: kDebugMode,
      requestBody: kDebugMode,
      responseHeader: kDebugMode,
      responseBody: kDebugMode,
      request: true,
      error: true,
      logPrint: (log) {
        Alog.i(
          tag: 'HTTP',
          moduleName: moduleName,
          content: "$log",
        );
      },
    ));
  }

  /// common header
  Map<String, dynamic> get baseHeaders => {
        'token': AppProfile.accountToken,
        'user': AppProfile.accountId,
        'appKey': AppProfile.appKey,
        'clientType':
            DeviceManager().clientType == ClientType.aos ? 'android' : 'ios',
        // 'sdkVersion': AppConfig().nertcVersionName,
        // 'appVersionName': AppConfig().versionName,
        // 'appVersionCode': AppConfig().versionCode,
        'deviceId': DeviceManager().deviceId,
        if (_getLanguageTag() != null) 'Accept-Language': _getLanguageTag(),
      };

  String? _getLanguageTag() {
    final locale = WidgetsBinding.instance!.platformDispatcher.locale;
    return locale.languageCode != 'und' ? locale.toLanguageTag() : null;
  }

  Future<Response?> execute(
      String method, String path, Map<String, dynamic>? headers, data) async {
    Response? response;
    try {
      var options = Options();
      options.method = method;
      options.headers = mergeHeaders(baseHeaders, headers);
      Alog.i(
          tag: 'HTTP',
          moduleName: moduleName,
          content:
              'MeetingKit, HttpExecutor: req path=$path params=${data?.toString()}');
      final requestOptions = options.compose(
        dio.options,
        path,
        data: data,
      );
      response = await dio.fetch(requestOptions);
    } on DioError catch (e) {
      Alog.e(
          tag: 'HTTP',
          moduleName: moduleName,
          content: 'MeetingKit, HttpExecutor: res path=$path error=$e');
    }
    return response;
  }

  Future<Response?> downloadFile(
      String url, String filePath, ProgressCallback onReceiveProgress,
      {Options? options}) async {
    Response? response;
    try {
      options ??= Options();
      options.headers = mergeHeaders(baseHeaders, options.headers);
      options.responseType = ResponseType.bytes;
      options.receiveTimeout = 0;
      Alog.d(
          moduleName: moduleName, tag: 'HTTP', content: 'down load file $url');
      response = await dio.download(url, filePath,
          onReceiveProgress: onReceiveProgress, options: options);
    } on DioError catch (e) {
      Alog.e(moduleName: moduleName, tag: 'HTTP', content: '$url error=$e');
    }
    return response;
  }

  static Map<String, dynamic>? mergeHeaders(
      Map<String, dynamic>? lhs, Map<String, dynamic>? rhs) {
    if (lhs != null || rhs != null) {
      return {
        if (lhs != null) ...(lhs..removeWhere((key, value) => value == null)),
        if (rhs != null) ...(rhs..removeWhere((key, value) => value == null)),
      };
    }
    return null;
  }
}
