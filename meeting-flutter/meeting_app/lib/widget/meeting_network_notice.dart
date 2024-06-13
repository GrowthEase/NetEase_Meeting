// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:nemeeting/language/localizations.dart';
import 'package:nemeeting/widget/ne_widget.dart';

import '../uikit/utils/nav_utils.dart';
import '../uikit/utils/router_name.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/fonts.dart';

class MeetingNetworkNotificationBar extends StatefulWidget {
  MeetingNetworkNotificationBar({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MeetingNetworkNotificationBarState();
  }
}

class _MeetingNetworkNotificationBarState
    extends State<MeetingNetworkNotificationBar> {
  @override
  Widget build(BuildContext context) {
    return NEGestureDetector(
      onTap: () => NavUtils.pushNamed(context, RouterName.networkNotAvailable),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        color: AppColors.color_FF3C30.withOpacity(0.2),
        child: Row(
          children: [
            Icon(
              IconFont.icon_yx_warning,
              color: AppColors.color_FB594F,
              size: 16,
            ),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                getAppLocalizations().globalNetworkNotAvailable,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.color_ED2E24,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(
              IconFont.iconyx_allowx,
              color: AppColors.color_FB594F,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}
