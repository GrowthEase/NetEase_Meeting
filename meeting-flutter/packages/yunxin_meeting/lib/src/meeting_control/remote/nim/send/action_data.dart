// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class ActionData extends BaseData{

  ActionData(int type, int requestId) : super(type, requestId);

  @override
  Map toData() {
    return {};
  }

}