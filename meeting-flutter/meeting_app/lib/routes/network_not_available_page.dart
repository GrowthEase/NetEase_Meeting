// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:nemeeting/language/localizations.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/values/colors.dart';

class NetworkNotAvailableRoute extends StatefulWidget {
  NetworkNotAvailableRoute();

  @override
  State<StatefulWidget> createState() {
    return _NetworkNotAvailableRouteState();
  }
}

class _NetworkNotAvailableRouteState
    extends AppBaseState<NetworkNotAvailableRoute> {
  _NetworkNotAvailableRouteState();

  @override
  String getTitle() {
    return getAppLocalizations().globalNetworkNotAvailableTitle;
  }

  @override
  Widget buildBody() {
    final titleTextStyle = TextStyle(
      fontSize: 16,
      color: AppColors.color_222222,
      fontWeight: FontWeight.w500,
    );
    final tipTextStyle = TextStyle(
      fontSize: 12,
      color: AppColors.color_333333,
      fontWeight: FontWeight.w400,
    );
    final partBetween = const SizedBox(height: 20);
    final tipBetween = const SizedBox(height: 8);
    return Container(
      margin: EdgeInsets.only(top: 1),
      height: double.infinity,
      color: AppColors.white,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(getAppLocalizations().globalNetworkNotAvailablePart1,
                  style: titleTextStyle),
              tipBetween,
              Text(getAppLocalizations().globalNetworkNotAvailableTip1,
                  style: tipTextStyle),
              partBetween,
              Text(getAppLocalizations().globalNetworkNotAvailablePart2,
                  style: titleTextStyle),
              tipBetween,
              Text(getAppLocalizations().globalNetworkNotAvailableTip2,
                  style: tipTextStyle),
              tipBetween,
              Text(getAppLocalizations().globalNetworkNotAvailableTip3,
                  style: tipTextStyle),
              partBetween,
              Text(getAppLocalizations().globalNetworkNotAvailablePart3,
                  style: titleTextStyle),
              tipBetween,
              Text(getAppLocalizations().globalNetworkNotAvailableTip4,
                  style: tipTextStyle),
            ],
          ),
        ),
      ),
    );
  }
}
