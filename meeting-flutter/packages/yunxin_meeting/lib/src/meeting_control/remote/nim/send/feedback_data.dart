// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class FeedbackData extends BaseData{
  String phone;
  String category;
  String description;
  int time;
  String deviceId;

  FeedbackData(this.phone, this.category, this.description, this.time, this.deviceId) : super(TCProtocol.feedback2TV, 0);

  @override
  Map toData() {
    return {
      'phone': phone,
      'category': category,
      'description': description,
      'time': time,
      'deviceId': deviceId,
    };
  }

}