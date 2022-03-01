// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class TurnPageData extends BaseData{
  int action;

  TurnPageData(this.action) : super(TCProtocol.turnPage2TV, 0);

  @override
  Map toData() {
    return {
      'action': action,
    };
  }

}