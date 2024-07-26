// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:nemeeting/constants.dart';
import 'package:netease_common/netease_common.dart';
import 'package:dio/dio.dart';
import 'package:nemeeting/service/client/app_http_client.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/proto/base_proto.dart';

Alogger _httpLogger = Alogger.normal('AppHttp', Constants.moduleName);

abstract class AppHttpProto<T> extends BaseProto {
  AppHttpClient client = AppHttpClient();

  /// custom options
  Options? get options {
    return header() != null
        ? Options(headers: header(), contentType: 'application/json')
        : null;
  }

  @override
  Future<NEResult<T>> execute() async {
    Response? response;
    var url = path();
    response = await client.execute(method, url, header(), data());
    if (response == null) {
      _httpLogger.e('resp path=$url result is null');
      return NEResult(code: HttpCode.netWorkError);
    } else {
      if (response.statusCode == HttpStatus.ok) {
        _httpLogger.d('resp path=$url code = 200 , result ${response.data}');
        if (response.data == null || response.data is! Map) {
          return NEResult(code: HttpCode.success);
        } else {
          final map = response.data as Map;
          final code = (map['code'] ?? HttpCode.serverError) as int;
          final msg = map['msg'] as String?;
          try {
            if (code == HttpCode.success) {
              final data = map['data']; // protect may be ret is null
              return NEResult(
                  code: HttpCode.success,
                  msg: msg,
                  data: (data is! Map ? null : result(data)) as T?);
            }
          } catch (e, s) {
            _httpLogger.e(
                'parse response error: path=$url, exception=$e, stacktrace=\n$s');
          }
          return NEResult(code: code, msg: msg);
        }
      } else {
        _httpLogger.e('resp path=$path code${response.statusCode}');
        return NEResult(code: response.statusCode as int);
      }
    }
  }
}

abstract class AppHttpProtoCompat<T> extends BaseProto<T> {
  AppHttpClient client = AppHttpClient();

  /// custom options
  Options? get options {
    return header() != null
        ? Options(headers: header(), contentType: 'application/json')
        : null;
  }

  @override
  Future<NEResult<T>> execute() async {
    Response? response;
    var url = path();
    response = await client.execute(method, url, header(), data());
    if (response == null) {
      _httpLogger.e('resp path=$url result is null');
      return NEResult(code: HttpCode.netWorkError);
    } else {
      if (response.statusCode == HttpStatus.ok) {
        _httpLogger.d('resp path=$url code = 200 , result ${response.data}');
        if (response.data == null || response.data is! Map) {
          return NEResult(code: HttpCode.success);
        } else {
          final map = response.data as Map;
          final code = (map['code'] ?? HttpCode.serverError) as int;
          final msg = map['msg'] as String?;
          try {
            if (code == HttpStatus.ok) {
              final data = map['ret']; // protect may be ret is null
              return NEResult(
                  code: HttpCode.success,
                  msg: msg,
                  data: data is! Map ? null : result(data));
            }
          } catch (e, s) {
            _httpLogger.e(
                'parse response error: path=$url, exception=$e, stacktrace=\n$s');
          }
          return NEResult(code: code, msg: msg);
        }
      } else {
        _httpLogger.e('resp path=$path code${response.statusCode}');
        return NEResult(code: response.statusCode as int);
      }
    }
  }
}
