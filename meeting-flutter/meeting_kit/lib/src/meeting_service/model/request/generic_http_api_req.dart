// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class NEHttpApiRequest {
  final String path;
  final Map<String, dynamic>? headers;
  final Map? body;
  final String method;

  NEHttpApiRequest({
    required this.path,
    this.headers,
    this.body,
    this.method = 'POST',
  });
}

class _GenericHttpApiRequest extends HttpApi<Map> {
  final NEHttpApiRequest request;

  _GenericHttpApiRequest(this.request);

  @override
  Map data() => request.body ?? Map();

  @override
  String path() => request.path;

  @override
  String get method => request.method;

  @override
  Map<String, dynamic>? header() => request.headers;

  @override
  result(Map<dynamic, dynamic> map) => map;
}
