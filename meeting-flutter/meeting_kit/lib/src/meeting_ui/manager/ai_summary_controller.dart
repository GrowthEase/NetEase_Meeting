// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

///
/// 智能会议纪要控制器
///
abstract base class AISummaryController {
  static const codeAlreadyStarted = 1044;

  factory AISummaryController(
    NERoomContext roomContext,
    ValueGetter<bool> isSmartSummarySupportedGetter,
  ) = _AISummaryControllerImpl;

  AISummaryController._();

  ///
  /// 智能会议纪要是否已经开启
  ///
  bool isAISummaryStarted();

  ///
  /// 当前应用是否支持开启智能会议纪要
  ///
  bool isAISummarySupported();

  ///
  /// 开启智能会议纪要
  ///
  Future<VoidResult> startAISummary();

  ///
  /// 关闭智能会议纪要
  ///
  Future<VoidResult> stopAISummary();

  ///
  /// 销毁控制器
  ///
  void dispose();
}

final class _AISummaryControllerImpl extends AISummaryController
    with _AloggerMixin {
  final NERoomContext roomContext;
  final ValueGetter<bool> isAISummarySupportedGetter;

  _AISummaryControllerImpl(this.roomContext, this.isAISummarySupportedGetter)
      : super._();

  @override
  bool isAISummaryStarted() {
    return roomContext.isSmartSummaryEnabled;
  }

  @override
  bool isAISummarySupported() {
    return isAISummarySupportedGetter();
  }

  @override
  Future<VoidResult> startAISummary() async {
    final result = await InMeetingRepository.startAISummary(
        roomContext.meetingInfo.meetingId);
    commonLogger.i('startAISummary result: $result');
    return result;
  }

  @override
  Future<VoidResult> stopAISummary() {
    throw UnimplementedError();
  }

  @override
  void dispose() {}
}
