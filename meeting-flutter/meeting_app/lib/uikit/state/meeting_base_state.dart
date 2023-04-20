// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../values/colors.dart';
import '../values/fonts.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

abstract class MeetingBaseState<T extends StatefulWidget>
    extends LifecycleBaseState<T> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.globalBg,
        appBar: AppBar(
          title: Text(
            getTitle(),
            style: TextStyle(color: AppColors.color_222222, fontSize: 17),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: isShowBackBtn()
              ? IconButton(
                  key: ValueKey('back'),
                  icon: const Icon(
                    IconFont.iconyx_returnx,
                    size: 18,
                    color: AppColors.black_333333,
                  ),
                  onPressed: () {
                    Navigator.maybePop(context);
                  },
                )
              : null,
          actions: buildActions(),
          // systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: SafeArea(
            top: false, left: false, right: false, child: buildBody()));
  }

  String getTitle();

  Widget buildBody();

  bool isShowBackBtn() {
    return true;
  }

  List<Widget> buildActions() {
    return [];
  }
}
