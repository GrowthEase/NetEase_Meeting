// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class AutoHideKeyboard extends StatelessWidget {
  final Widget? child;
  final TransitionBuilder? builder;

  const AutoHideKeyboard({
    super.key,
    this.child,
    this.builder,
  }) : assert(child != null || builder != null);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: builder != null ? builder!(context, child) : child,
    );
  }
}
