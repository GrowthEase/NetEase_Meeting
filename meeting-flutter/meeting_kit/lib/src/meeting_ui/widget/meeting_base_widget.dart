// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class PlatformWidget extends StatelessWidget {
  final Widget child;

  PlatformWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    double scaleFactor = Platform.isIOS ? 1.12 : 1.0;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(scaleFactor),
      ),
      child: child,
    );
  }
}
