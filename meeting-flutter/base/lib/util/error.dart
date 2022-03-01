// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

class ErrorUtil {
  static var style = TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.w400,decoration: TextDecoration.none);

  static var decoration = ShapeDecoration(
      color: Color(0xE5F24957), shape: RoundedRectangleBorder(side: BorderSide(color: Color(0xE5F24957))));

  static var edgeInsets = const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0);

  static void showError(BuildContext context, String text) {
    Widget widget = SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              height: 44,
              decoration: decoration,
              alignment: Alignment.center,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: style,
              ),
            ),
          )
        ],
      ),
    );
    var entry = OverlayEntry(
      builder: (_) => widget,
    );
    ///这里要延时加载  否则会抱The widget on which setState() or markNeedsBuild() was called was:错误
    Future.delayed(Duration(milliseconds: 0)).then((e) {
      Overlay.of(context)?.insert(entry);
    });

    Timer(const Duration(seconds: 2), () {
      entry.remove();
    });
  }
}
