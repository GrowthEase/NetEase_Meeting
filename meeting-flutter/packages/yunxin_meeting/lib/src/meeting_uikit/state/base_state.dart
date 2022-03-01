// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_uikit;

abstract class BaseState<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  late String tag;

  @override
  @mustCallSuper
  void initState() {
    tag = "${this.runtimeType}@$hashCode";
    Alog.i(tag: tag, moduleName: _moduleName, content: "$tag init state");
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  @mustCallSuper
  void dispose() {
    Alog.i(tag: tag, moduleName: _moduleName, content: "$tag dispose");
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  @mustCallSuper
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    Alog.i(
        tag: tag, moduleName: _moduleName, content: "$tag ${state.toString()}");
    onAppLifecycleState(state);
  }

  void onAppLifecycleState(AppLifecycleState state) {}
}
