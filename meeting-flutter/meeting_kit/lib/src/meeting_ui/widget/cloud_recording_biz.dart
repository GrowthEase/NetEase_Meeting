// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class StartCloudRecordingResult {
  final bool enableAISummary;

  StartCloudRecordingResult(this.enableAISummary);
}

class _ConfirmToStartCloudRecordingContent extends StatefulWidget {
  final String message;
  final AISummaryController summaryController;
  final ValueNotifier<bool> enableAISummary;

  const _ConfirmToStartCloudRecordingContent({
    super.key,
    required this.message,
    required this.enableAISummary,
    required this.summaryController,
  });

  @override
  State<_ConfirmToStartCloudRecordingContent> createState() =>
      _ConfirmToStartCloudRecordingContentState();
}

class _ConfirmToStartCloudRecordingContentState
    extends State<_ConfirmToStartCloudRecordingContent>
    with MeetingKitLocalizationsMixin {
  @override
  Widget build(BuildContext context) {
    final aiSummaryStarted = widget.summaryController.isAISummaryStarted();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: _UIColors.color3D3D3D,
          ),
        ),
        if (widget.summaryController.isAISummarySupported()) ...[
          if (!aiSummaryStarted) SizedBox(height: 10),
          if (!aiSummaryStarted)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.enableAISummary.value = !widget.enableAISummary.value;
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValueListenableBuilder(
                      valueListenable: widget.enableAISummary,
                      builder: (context, checked, _) {
                        return Icon(
                          checked
                              ? NEMeetingIconFont.icon_checked
                              : NEMeetingIconFont.icon_unchecked,
                          color: checked
                              ? _UIColors.color_337eff
                              : _UIColors.color_999999,
                          size: 16,
                        );
                      }),
                  SizedBox(width: 6),
                  Flexible(
                      child: Text(
                    meetingUiLocalizations.cloudRecordingEnableAISummary,
                    style: TextStyle(
                      fontSize: 16,
                      color: _UIColors.color53576A,
                    ),
                    strutStyle: StrutStyle(
                      forceStrutHeight: true,
                      height: 1.5,
                    ),
                  )),
                ],
              ),
            ),
          SizedBox(height: 10),
          Text(
            aiSummaryStarted
                ? meetingUiLocalizations.cloudRecordingAISummaryStarted
                : meetingUiLocalizations.cloudRecordingEnableAISummaryTip,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: _UIColors.color8D90A0,
            ),
          ),
        ],
      ],
    );
  }
}

Future<StartCloudRecordingResult?> _showStartCloudRecordingConfirmDialog(
  BuildContext context,
  AISummaryController summaryController,
  bool showCloudRecordingUI,
) {
  final enableAISummaryChecked = ValueNotifier(false);
  return showDialog<StartCloudRecordingResult>(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      barrierColor: _UIColors.black.withOpacity(0.4),
      routeSettings: RouteSettings(name: 'StartCloudRecordingConfirmDialog'),
      builder: (BuildContext buildContext) {
        return NEMeetingUIKitLocalizationsScope(
            builder: (BuildContext context, localizations, _) {
          return CupertinoAlertDialog(
            title: Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  localizations.cloudRecordingEnabledTitle,
                  style: TextStyle(
                    color: _UIColors.color1E1F27,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                )),
            content: _ConfirmToStartCloudRecordingContent(
              message: showCloudRecordingUI
                  ? localizations.cloudRecordingEnabledMessage
                  : localizations.cloudRecordingEnabledMessageWithoutNotice,
              summaryController: summaryController,
              enableAISummary: enableAISummaryChecked,
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(localizations.globalCancel),
                onPressed: () => Navigator.pop(context),
                textStyle: TextStyle(color: _UIColors.color_666666),
              ),
              CupertinoDialogAction(
                child: Text(localizations.globalStart),
                onPressed: () => Navigator.pop(context,
                    StartCloudRecordingResult(enableAISummaryChecked.value)),
                textStyle: TextStyle(color: _UIColors.color_337eff),
              ),
            ],
          );
        });
      });
}
