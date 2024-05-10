// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

abstract class PopupBaseState<T extends StatefulWidget> extends State<T> {
  @override
  Widget build(BuildContext context) {
    final actions = buildActions();
    final hasActions = actions.isNotEmpty;
    return Scaffold(
      appBar: TitleBar(
        title: TitleBarTitle(title),
        showBottomDivider: showTitleBarDivider,
        leading: hasActions ? TitleBarCloseIcon() : null,
        trailing: hasActions
            ? SizedBox(
                height: 48,
                child: Row(
                  children: actions,
                  mainAxisSize: MainAxisSize.min,
                ),
              )
            : TitleBarCloseIcon(),
      ),
      body: buildBody(),
    );
  }

  bool get showTitleBarDivider => true;

  Widget buildSplit() {
    return Container(
      height: 1,
      color: _UIColors.colorEBEDF0,
    );
  }

  /// 标题文本
  String get title;

  /// 构建标题栏右侧操作按钮
  List<Widget> buildActions() {
    return [];
  }

  /// 构建内容区域
  Widget buildBody();
}
