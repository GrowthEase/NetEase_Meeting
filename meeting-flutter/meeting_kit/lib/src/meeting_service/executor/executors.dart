// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

typedef Map HttpHeaderContributor();

class HttpHeaderRegistry {
  static final _instance = HttpHeaderRegistry._();

  HttpHeaderRegistry._();

  factory HttpHeaderRegistry() => _instance;

  final _contributors = <HttpHeaderContributor>{};

  void addContributor(HttpHeaderContributor contributor) {
    _contributors.add(contributor);
  }

  void removeContributor(HttpHeaderContributor contributor) {
    _contributors.remove(contributor);
  }

  Map _collectHeaders() {
    final headers = {};
    for (final contributor in _contributors) {
      final header = contributor();
      headers.addAll(header);
    }
    return headers;
  }
}

class _Executors {
  Map<String, dynamic> get baseHeaders => {
        'versionCode': SDKConfig.sdkVersionCode,
        'clientType': Platform.isAndroid ? 'android' : 'ios',
        ...HttpHeaderRegistry()._collectHeaders(),
      };

  static _Executors? _instance;

  final _HttpExecutor _httpExecutor = _HttpExecutor();

  factory _Executors() {
    return _instance ??= _Executors._internal();
  }

  _Executors._internal();

  Future<http.Response?> executeOverHttp(
      String method, String path, Map<String, dynamic>? headers, data) {
    return _httpExecutor._execute(
        method, path, mergeHeaders(baseHeaders, headers), data);
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
