// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/utils/integration_test.dart';

class SwitchItem extends StatelessWidget {
  final String title;
  final String? summary;
  final Color? summaryColor;
  final bool value;
  final ValueChanged<bool>? onChange;

  const SwitchItem({
    ValueKey? key,
    required this.title,
    this.summary,
    this.summaryColor,
    required this.value,
    this.onChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: AppColors.white,
      padding: EdgeInsets.only(left: 20, right: 16),
      child: Row(
        children: <Widget>[
          Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: AppColors.black_222222, fontSize: 16)),
                  if (summary != null)
                    Text(summary!,
                        style: TextStyle(
                            color: summaryColor ?? AppColors.color_999999,
                            fontSize: 12)),
                ],
              )),
          if (key != null)
            MeetingValueKey.addTextWidgetTest(
                valueKey: key as ValueKey, value: value),
          CupertinoSwitch(
            key: key,
            value: value,
            onChanged: onChange,
            activeColor: AppColors.blue_337eff,
          )
        ],
      ),
    );
  }
}
