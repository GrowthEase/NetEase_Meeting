// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

const _tag = '_HttpExecutor';

class _HttpExecutor {
  static _HttpExecutor? _instance;

  factory _HttpExecutor() {
    return _instance ??= _HttpExecutor._internal();
  }

  late http.Dio dio;
  final ServersConfig _serversConfig = ServersConfig();

  _HttpExecutor._internal() {
    var options = http.BaseOptions(
        connectTimeout: _serversConfig.connectTimeout,
        receiveTimeout: _serversConfig.receiveTimeout);

    dio = http.Dio(options);
    dio.interceptors.add(LogInterceptor(
      requestHeader: kDebugMode,
      requestBody: kDebugMode,
      responseHeader: kDebugMode,
      responseBody: kDebugMode,
      request: true,
      error: true,
      logPrint: (log) {
        Alog.i(
          tag: _tag,
          moduleName: _moduleName,
          content: "$log",
        );
      },
    ));
  }

  Future<http.Response?> _execute(
      String method, String path, Map<String, dynamic>? headers, data) async {
    http.Response? response;
    try {
      final isGet = method == 'GET';
      var options = http.Options();
      options.method = method;
      options.headers = headers;
      Alog.i(
          tag: _tag,
          moduleName: _moduleName,
          content:
              'MeetingSDK, HttpExecutor: req path=$path params=${data?.toString()}');
      final requestOptions = options.compose(
        dio.options..baseUrl = _serversConfig.baseUrl,
        path,
        data: isGet ? null : data,
        queryParameters: isGet && data is Map ? Map.from(data) : null,
      );
      response = await dio.fetch(requestOptions);
    } on http.DioError catch (e) {
      Alog.e(
          tag: _tag,
          moduleName: _moduleName,
          content: 'MeetingSDK, HttpExecutor: res path=$path error=$e');
    }
    return response;
  }

  Future<http.Response?> download(
      String url, ProgressCallback onReceiveProgress) async {
    http.Response? response;
    var options = http.Options(responseType: ResponseType.bytes);
    try {
      Alog.d(
          tag: _tag,
          moduleName: _moduleName,
          content: 'MeetingSDK, HttpExecutor:  download file $url');
      response = await dio.get(url,
          onReceiveProgress: onReceiveProgress, options: options);
    } on DioError catch (e) {
      Alog.d(
          tag: _tag,
          moduleName: _moduleName,
          content: 'MeetingSDK, HttpExecutor:  download file $url error=$e');
    }
    return response;
  }
}
