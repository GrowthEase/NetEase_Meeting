// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

class _NEFeedbackServiceImpl extends NEFeedbackService {
  static final _NEFeedbackServiceImpl _instance = _NEFeedbackServiceImpl._();

  factory _NEFeedbackServiceImpl() => _instance;

  _NEFeedbackServiceImpl._();

  @override
  Future<NEResult<void>> feedback(NEFeedback feedback) {
    return FeedbackRepository().addFeedbackTask(feedback);
  }

  @override
  Widget loadFeedbackView() {
    return FeedbackPage();
  }
}
