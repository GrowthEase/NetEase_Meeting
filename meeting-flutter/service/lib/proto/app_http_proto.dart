// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:yunxin_alog/yunxin_alog.dart';
import 'package:dio/dio.dart';
import 'package:service/client/app_http_client.dart';
import 'package:service/client/http_code.dart';
import 'package:service/proto/base_proto.dart';
import 'package:service/response/result.dart';

import '../module_name.dart';

const String _tag = 'HTTP';

abstract class AppHttpProto<T> extends BaseProto {
  AppHttpClient client = AppHttpClient();

  /// custom options
  Options? get options {
    return header() != null
        ? Options(headers: header(), contentType: 'application/json')
        : null;
  }

  @override
  Future<Result<T>> execute() async {
    Response? response;
    var url = path();
    if (url.startsWith('http')) {
      response = await client.postUri(Uri.parse(url), data(), options: options);
    } else {
      response = await client.post(url, data(), options: options);
    }
    if (response == null) {
      Alog.e(
          moduleName: moduleName,
          tag: _tag,
          content: 'resp path=$url result is null');
      return Result(code: HttpCode.netWorkError);
    } else {
      if (response.statusCode == HttpCode.success) {
        Alog.d(
            moduleName: moduleName,
            tag: _tag,
            content: 'resp path=$url code = 200 , result ${response.data}');
        if (response.data == null || response.data is! Map) {
          return Result(code: HttpCode.success);
        } else {
          final map = response.data as Map;
          final code = (map['code'] ?? HttpCode.serverError) as int;
          try {
            if (code == HttpCode.success) {
              var ret = map['ret']; // protect may be ret is null
              return Result(
                  code: HttpCode.success,
                  data: (ret is! Map ? null : result(ret)) as T?);
            }
          } catch (e, s) {
            Alog.e(
                moduleName: moduleName,
                tag: _tag,
                content:
                    'parse response error: path=$url, exception=$e, stacktrace=\n$s');
          }
          return Result(code: code, msg: map['msg'] as String?);
        }
      } else {
        Alog.e(
            moduleName: moduleName,
            tag: _tag,
            content: 'resp path=$path code${response.statusCode}');
        return Result(code: response.statusCode as int);
      }
    }
  }
}
