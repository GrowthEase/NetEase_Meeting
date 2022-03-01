// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class Store {

//  初始化
  static Widget init({BuildContext? context, Widget? child}) {
    /// 返回多个状态
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => ShowTypeModel()),
    ], child: child);
  }

  //  通过Provider.value<T>(context)获取状态数据
  static T value<T>(BuildContext context, {bool isListen = true}) {
    return Provider.of(context, listen: isListen);
  }

  //  通过Consumer获取状态数据
  static Consumer connect<T>({required Widget Function(BuildContext context, T value, Widget? child) builder,
    Widget? child}) {
    return Consumer<T>(builder: builder, child: child);
  }

}