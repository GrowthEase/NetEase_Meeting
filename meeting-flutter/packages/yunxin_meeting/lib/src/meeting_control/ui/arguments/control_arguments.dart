// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class ControlArguments {
  String? pairCode;
  TVStatus? tvStatus;
  bool? openCamera;
  bool? openMicrophone;
  String? meetingId;
  ControlOptions? opts;
  String? fromRoute;

  ControlArguments(
      {this.pairCode, this.tvStatus, this.openCamera, this.openMicrophone,
      this.meetingId,
      this.opts,
      this.fromRoute});
}
