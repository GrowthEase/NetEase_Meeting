// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class _StartAISummaryApi extends HttpApi<void> {
  final int meetingId;

  _StartAISummaryApi(this.meetingId);

  @override
  Object? data() => {};

  @override
  void result(Map map) {}

  @override
  String path() {
    return "/scene/meeting/v1/ai-summary-task/start?meetingId=${meetingId}";
  }
}
