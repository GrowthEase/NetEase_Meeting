// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

abstract class ControlBaseState <T extends StatefulWidget> extends LifecycleBaseState<T> {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
          backgroundColor: UIColors.globalBg,
          appBar: AppBar(
            title: Text(
              getTitle() ?? '',
              style: TextStyle(color: UIColors.color_222222, fontSize: 17),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0.0,
            brightness: Brightness.light,
            leading: isShowBackBtn()
                ? IconButton(
              key: ControllerMeetingCoreValueKey.back,
              icon: const Icon(
                NEMeetingIconFont.icon_yx_returnx,
                size: 18,
                color: UIColors.black_333333,
              ),
              onPressed: () {
                onNavigationBack();
              },
            )
                : null,
            actions: buildActions(),
          ),
          body: SafeArea(top: false, left: false, right: false, child: buildBody()!)),
      onWillPop: () async {
        return onWillPop();
      },
    );
  }

  String? getTitle();

  Widget? buildBody();

  bool isShowBackBtn() {
    return true;
  }

  List<Widget>? buildActions() {
    return null;
  }

  void onNavigationBack(){
    Navigator.maybePop(context);
  }

  bool onWillPop() {
    return true;
  }

}