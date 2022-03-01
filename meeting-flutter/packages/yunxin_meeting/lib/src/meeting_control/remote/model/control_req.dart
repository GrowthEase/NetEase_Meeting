// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class _ControlRequest {
  /// 要发送的账号
  String toAccountId;

  BaseData param;

  _ControlRequest({required this.toAccountId, required this.param});

  Map get data => {'toAccountId': toAccountId, 'data': param.toMap()};
}
