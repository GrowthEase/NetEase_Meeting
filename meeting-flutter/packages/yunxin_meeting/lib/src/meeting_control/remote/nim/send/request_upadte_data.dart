// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class RequestUpdateData extends BaseData {
  bool onlyCheckForce;

  RequestUpdateData(int requestId, this.onlyCheckForce) : super(TCProtocol.checkUpgrade2TV, requestId);

  @override
  Map toData() {
    return {
      'requestId': requestId,
      'onlyCheckForce': onlyCheckForce,
    };
  }
}