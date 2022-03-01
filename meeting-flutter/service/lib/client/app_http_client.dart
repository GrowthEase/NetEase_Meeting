// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:service/config/app_config.dart';
import 'package:service/config/servers.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import 'package:service/profile/app_profile.dart';
import 'package:base/manager/device_manager.dart';

import '../module_name.dart';

class AppHttpClient {
  static AppHttpClient? _instance;

  factory AppHttpClient() {
    return _instance ??= AppHttpClient._internal();
  }

  late final Dio dio;

  AppHttpClient._internal() {
    var options = BaseOptions(
        baseUrl: servers.baseUrl,
        connectTimeout: servers.connectTimeout,
        receiveTimeout: servers.receiveTimeout);

    dio = Dio(options);
  }

  /// common header
  Map<String, dynamic> get headers => {
        'accountToken': AppProfile.accountToken,
        'accountId': AppProfile.accountId,
        'appKey': AppProfile.appKey,
        'clientType': DeviceManager().clientType,
        'sdkVersion': AppConfig().nertcVersionName,
        'appVersionName': AppConfig().versionName,
        'appVersionCode': AppConfig().versionCode,
        'deviceId': DeviceManager().deviceId,
      };

  /// post request data data -- json
  Future<Response?> post(String path, data, {Options? options}) async {
    Response? response;
    try {
      options ??= Options();
      options.headers = mergeHeaders(options.headers, headers);
      Alog.d(
          moduleName: moduleName,
          tag: 'HTTP',
          content:
              'req url=${servers.baseUrl}$path, header=${kReleaseMode ? '' : options.headers.toString()} params=${data?.toString()}');
      response = await dio.post(path, data: data, options: options);
    } on DioError catch (e) {
      Alog.e(moduleName: moduleName, tag: 'HTTP', content: '$path error=$e');
    }
    return response;
  }

  /// post request data data -- json
  Future<Response?> postUri(Uri uri, data, {Options? options}) async {
    Response? response;
    try {
      options ??= Options();
      options.headers = mergeHeaders(options.headers, headers);
      Alog.d(
          moduleName: moduleName,
          tag: 'HTTP',
          content:
              'req path=$uri header=${kReleaseMode ? '' : options.headers.toString()} params=${data?.toString()}');
      response = await dio.postUri(uri, data: data, options: options);
    } on DioError catch (e) {
      Alog.e(moduleName: moduleName, tag: 'HTTP', content: '$uri error=$e');
    }
    return response;
  }

  Future<Response?> downloadFile(String url, ProgressCallback onReceiveProgress,
      {Options? options}) async {
    Response? response;
    try {
      options ??= Options();
      options.headers = mergeHeaders(options.headers, headers);
      options.responseType = ResponseType.bytes;
      options.receiveTimeout = 0;
      Alog.d(
          moduleName: moduleName, tag: 'HTTP', content: 'down load file $url');
      response = await dio.get(url,
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
