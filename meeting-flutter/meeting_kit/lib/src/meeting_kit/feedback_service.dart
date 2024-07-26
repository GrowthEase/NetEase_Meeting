// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

/// 意见反馈服务提供了意见反馈能力。通过这个服务可以提供意见反馈界面入口和意见反馈接口。可通过 [NEFeedbackService] 获取对应的服务实例。
abstract class NEFeedbackService {
  /// 意见反馈接口
  ///
  /// [feedback] 意见反馈的内容
  ///
  /// 结果回调
  Future<NEResult<void>> feedback(NEFeedback feedback);

  /// 展示意见反馈界面
  ///
  Widget loadFeedbackView();
}
