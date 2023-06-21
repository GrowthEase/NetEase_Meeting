// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 会议页面参数
class MeetingArguments extends MeetingBaseArguments {
  final MeetingInfo meetingInfo;

  final NERoomContext roomContext;

  late int requestTimeStamp;

  MeetingArguments(
      {required this.roomContext,
      required this.meetingInfo,
      String? displayName,
      String? password,
      required NEMeetingUIOptions options})
      : super(
            meetingNum: roomContext.roomUuid,
            displayName: displayName,
            password: password,
            options: options) {
    requestTimeStamp = DateTime.now().millisecondsSinceEpoch;
    _isWhiteboardTransparent =
        ValueNotifier(options.enableTransparentWhiteboard);
  }

  @override
  String get meetingNum => roomContext.roomUuid;

  String? getOptionExtraValue(String key) {
    return options.extras[key] as String?;
  }

  late final ValueNotifier<bool> _isWhiteboardTransparent;
  bool get isWhiteboardTransparent => _isWhiteboardTransparent.value;
  set isWhiteboardTransparent(value) => _isWhiteboardTransparent.value = value;
}
