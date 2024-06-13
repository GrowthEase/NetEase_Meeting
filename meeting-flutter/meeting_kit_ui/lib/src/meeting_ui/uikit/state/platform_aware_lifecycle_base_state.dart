// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

abstract class PlatformAwareLifecycleBaseState<T extends StatefulWidget>
    extends LifecycleBaseState<T> {
  @override
  Widget build(BuildContext context) {
    return PlatformWidget(child: buildWithPlatform(context));
  }

  Widget buildWithPlatform(BuildContext context) {
    return Container();
  }
}
