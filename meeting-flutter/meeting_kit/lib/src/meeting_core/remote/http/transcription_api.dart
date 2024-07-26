// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 检查字幕权限
class _CheckCaptionPermissionApi extends HttpApi<void> {
  final String meetingNum;

  _CheckCaptionPermissionApi(this.meetingNum);

  @override
  String path() {
    return '/scene/apps/v1/${meetingNum}/check-caption-permission';
  }

  @override
  String get method => 'GET';

  @override
  void result(Map map) {
    return null;
  }

  @override
  Map data() => {};
}

class _GetHistoryMeetingTranscriptionInfoApi
    extends HttpApi<List<NEMeetingTranscriptionInfo>> {
  final int meetingId;

  _GetHistoryMeetingTranscriptionInfoApi(this.meetingId);

  @override
  String path() {
    return '/scene/meeting/v1/$meetingId/transcript-record';
  }

  @override
  String get method => 'GET';

  @override
  List<NEMeetingTranscriptionInfo> parseResult(data) {
    assert(data is List);
    final result = <NEMeetingTranscriptionInfo>[];
    for (final item in data) {
      assert(item is Map);
      try {
        result.add(NEMeetingTranscriptionInfo.fromJson(item as Map));
      } catch (e) {
        debugPrint('parse error: $e');
      }
    }
    return result;
  }

  @override
  Map data() => {};
}

class _GetHistoryMeetingTranscriptionFileUrlApi extends HttpApi<String> {
  final int meetingId;
  final String fileKey;

  _GetHistoryMeetingTranscriptionFileUrlApi(this.meetingId, this.fileKey);

  @override
  String path() {
    return '/scene/meeting/v1/$meetingId/transcript-file/download-url?nosFileKey=$fileKey';
  }

  @override
  String get method => 'GET';

  @override
  String parseResult(dynamic data) {
    return data as String;
  }

  @override
  Map data() => {};
}
