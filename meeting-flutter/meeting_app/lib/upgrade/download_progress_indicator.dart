// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:nemeeting/upgrade/download_progress_notifier.dart';
import '../language/meeting_localization/meeting_app_localizations.dart';
import '../uikit/values/colors.dart';

class DownloadProgressIndicator extends AnimatedWidget {
  final DownloadProgressNotifier notifier;

  final bool cancellable;

  DownloadProgressIndicator(this.notifier, this.cancellable)
      : super(listenable: notifier);

  static int oneM = 1024 * 1024;

  @override
  Widget build(BuildContext context) {
    final meetingAppLocalizations = MeetingAppLocalizations.of(context)!;
    return WillPopScope(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
            width: 270,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.white, width: 0),
                  borderRadius: BorderRadius.all(Radius.circular(14))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  meetingAppLocalizations.settingVersionUpgrade,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      decoration: TextDecoration.none),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  '${(notifier.count / oneM).toStringAsFixed(1)}M/${(notifier.total / oneM).toStringAsFixed(1)}M',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 2,
                ),
                LinearProgressIndicator(
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation(AppColors.blue_337eff),
                  value: notifier.downloadProgress,
                ),
                SizedBox(
                  height: 15,
                ),
                if (cancellable)
                  Divider(
                    height: 1,
                    color: AppColors.color_0D000050,
                  ),
                if (cancellable)
                  RawMaterialButton(
                    onPressed: notifier.cancel,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(14),
                            bottomRight: Radius.circular(14))),
                    constraints: const BoxConstraints(minHeight: 44),
                    child: Text(
                      meetingAppLocalizations.globalCancel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          decoration: TextDecoration.none),
                    ),
                  ),
                if (!cancellable)
                  SizedBox(
                    height: 15,
                  ),
              ],
            ),
          )
        ]),
        onWillPop: () async {
          return false;
        });
  }
}
