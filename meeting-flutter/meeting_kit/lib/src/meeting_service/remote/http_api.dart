// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

abstract class HttpApi<T> extends BaseApi {
  static const _tag = 'HttpApi';

  String get method => 'POST';

  @override
  Future<NEResult<T>> execute() async {
    var response =
        await _Executors().executeOverHttp(method, path(), header(), data());
    if (response == null) {
      Alog.e(
          tag: _tag,
          moduleName: _moduleName,
          content: 'HttpApi: path=${path()}, result is null');
      return NEResult(code: MeetingErrorCode.networkError);
    } else {
      if (response.statusCode == HttpStatus.ok) {
        Alog.i(
            tag: _tag,
            moduleName: _moduleName,
            content:
                'HttpApi:resp path=${path()}, result: ${enableLog() ? response.data : response.statusCode}');
        if (response.data == null || !(response.data is Map)) {
          return NEResult(
              code: MeetingErrorCode.failed,
              msg: 'Null response data or incorrect data structure');
        } else {
          try {
            final map = response.data as Map;
            final code = map['code'] as int;
            final msg = map['msg'] as String?;
            final requestId = map['requestId'] as String?;
            final cost = map['cost'] as String?;
            final costMillis =
                cost == null ? 0 : int.tryParse(cost.removeSuffix('ms')) ?? 0;
            final NEResult<T> ret;
            if (code == MeetingErrorCode.success) {
              var result = map['data'];
              ret = NEResult(
                code: code,
                msg: msg,
                data: result == null ? null : parseResult(result) as T?,
                requestId: requestId,
                cost: costMillis,
              );
            } else {
              ret = NEResult(
                  code: code, msg: msg, requestId: requestId, cost: costMillis);
            }
            HttpErrorRepository().reportResult(ret);
            return ret;
          } catch (e, s) {
            Alog.e(
                tag: _tag,
                moduleName: _moduleName,
                content:
                    'HttpApi: parse result data error: path=${path()}, exception=$e, stacktrace=\n$s');
            return NEResult(code: MeetingErrorCode.serverError);
          }
        }
      } else {
        Alog.e(
            tag: _tag,
            moduleName: _moduleName,
            content: 'HttpApi: path=$path code${response.statusCode}');
        final resultCode = response.statusCode ?? MeetingErrorCode.failed;
        return NEResult(code: resultCode, msg: response.statusMessage);
      }
    }
  }
}
