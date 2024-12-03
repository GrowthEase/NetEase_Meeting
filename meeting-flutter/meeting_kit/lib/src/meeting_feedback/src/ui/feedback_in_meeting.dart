// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of feedback;

class InMeetingFeedBack extends StatefulWidget {
  final Function(
    _FeedbackResult result,
  ) onCommit;
  final NEMeetingInfo meetingInfo;

  InMeetingFeedBack({
    required this.onCommit,
    required this.meetingInfo,
  });

  static void showFeedbackDialog(BuildContext buildContext) {
    var meetingInfo =
        NEMeetingKit.instance.getMeetingService().getCurrentMeetingInfo();
    if (meetingInfo == null) return;
    showMeetingPopupPageRoute(
      context: buildContext,
      builder: (BuildContext context) {
        return InMeetingFeedBack(
          meetingInfo: meetingInfo,
          onCommit: (_FeedbackResult result) async {
            FeedbackRepository().addFeedbackTask(result.convertToFeedback(
                needAudioDump: result.audioProblems.isNotEmpty));
          },
        );
      },
    );
  }

  @override
  State<StatefulWidget> createState() => _InMeetingFeedBackState();
}

class _InMeetingFeedBackState extends State<InMeetingFeedBack> {
  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(8),
      topRight: const Radius.circular(8),
    );
    return Scaffold(
      appBar: TitleBar(
        title: TitleBarTitle(
          localizations.feedbackInRoom,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: _UIColors.globalBg,
          borderRadius: borderRadius,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: FeedbackContent(
            onFeedback: _onSubmit,
          ),
        ),
      ),
    );
  }

  NEMeetingUIKitLocalizations get localizations =>
      NEMeetingUIKit.instance.getUIKitLocalizations();

  String get reporterNickname => widget.meetingInfo.userList
      .firstWhere((element) => element.isSelf)
      .userName;

  Future<void> _onSubmit(_FeedbackResult feedbackResult) async {
    widget.onCommit(feedbackResult);
    ToastUtils.showToast(context, localizations.feedbackSuccess);

    ///提交后就关闭，，不阻塞用户会中其他操作
    Navigator.of(context).pop();
  }
}
