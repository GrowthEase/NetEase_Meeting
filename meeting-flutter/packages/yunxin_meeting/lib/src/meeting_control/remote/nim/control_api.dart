// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

/// 主持人控制协议
class _ControlApi extends NimPassthroughApi<void> {
  _ControlRequest request;

  _ControlApi(this.request);

  @override
  String path() => '/v1/sdk/controller/control';

  @override
  void result(Map map) => null;

  @override
  Map data() => request.data;
}
