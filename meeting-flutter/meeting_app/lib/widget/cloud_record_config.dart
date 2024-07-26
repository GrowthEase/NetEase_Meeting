// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:netease_meeting_kit/meeting_core.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';

import '../language/localizations.dart';
import '../utils/integration_test.dart';

class CloudRecordConfig extends StatefulWidget {
  final NECloudRecordConfig cloudRecordConfig;
  final void Function(NECloudRecordConfig)? onConfigChanged;

  const CloudRecordConfig(
      {super.key, required this.cloudRecordConfig, this.onConfigChanged});

  @override
  State<CloudRecordConfig> createState() => _CloudRecordConfigState();
}

class _CloudRecordConfigState extends State<CloudRecordConfig> {
  final ValueNotifier<bool> cloudRecordSwitch = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    cloudRecordSwitch.value = widget.cloudRecordConfig.enable;
  }

  @override
  void didUpdateWidget(covariant CloudRecordConfig oldWidget) {
    super.didUpdateWidget(oldWidget);
    cloudRecordSwitch.value = widget.cloudRecordConfig.enable;
  }

  @override
  Widget build(BuildContext context) {
    return buildCloudRecord();
  }

  /// 云录制配置
  Widget buildCloudRecord() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MeetingSwitchItem(
          switchKey: MeetingValueKey.scheduleCloudRecord,
          title: getAppLocalizations().meetingCloudRecord,
          valueNotifier: cloudRecordSwitch,
          onChanged: (value) {
            cloudRecordSwitch.value = value;
            widget.cloudRecordConfig.enable = value;
            widget.onConfigChanged?.call(widget.cloudRecordConfig);
          },
        ),
        ValueListenableBuilder(
            valueListenable: cloudRecordSwitch,
            builder: (context, value, child) {
              if (value) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MeetingRadioItem(
                        value: true,
                        padding: EdgeInsets.only(left: 32, right: 16),
                        title: getAppLocalizations()
                            .meetingEnableCloudRecordWhenHostJoin,
                        groupValue: widget.cloudRecordConfig.recordStrategy ==
                            NERecordStrategyType.hostJoin,
                        onChanged: (_) {
                          widget.cloudRecordConfig.recordStrategy =
                              NERecordStrategyType.hostJoin;
                          widget.onConfigChanged
                              ?.call(widget.cloudRecordConfig);
                          setState(() {});
                        }),
                    MeetingRadioItem(
                        value: true,
                        padding: EdgeInsets.only(
                            left: 32, right: 16, top: 9, bottom: 9),
                        title: getAppLocalizations()
                            .meetingEnableCloudRecordWhenMemberJoin,
                        groupValue: widget.cloudRecordConfig.recordStrategy ==
                            NERecordStrategyType.memberJoin,
                        onChanged: (_) {
                          widget.cloudRecordConfig.recordStrategy =
                              NERecordStrategyType.memberJoin;
                          widget.onConfigChanged
                              ?.call(widget.cloudRecordConfig);
                          setState(() {});
                        }),
                  ],
                );
              }
              return SizedBox.shrink();
            }),
      ],
    );
  }
}
