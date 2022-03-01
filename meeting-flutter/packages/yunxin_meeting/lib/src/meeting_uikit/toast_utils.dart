// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_uikit;

class ToastUtils {
  static var style =
  TextStyle(color: Colors.white, fontSize: 14.0, decoration: TextDecoration.none, fontWeight: FontWeight.w400);

  static var decoration = ShapeDecoration(
      color: Color(0xBF1E1E1E),
      shape: RoundedRectangleBorder(
          /**side: BorderSide(color: Color(0xBF1E1E1E)),*/ borderRadius: BorderRadius.all(Radius.circular(4))));

  static var edgeInsets = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0);

  static void showToast(BuildContext context, String? text,{Key? key}) {
    if (text == null) return;
    bool inProduction = bool.fromEnvironment("dart.vm.product");
    if(key == null || inProduction){
      _showToast(context, text);
    }else{
      /// 非pro版本，根据需求使用；
      _showTestToast(context, text,key: key);
    }
  }

  static void _showToast(BuildContext context, String text) {
    Widget widget = Center(
      child: Container(
        padding: edgeInsets,
        decoration: decoration,
        child: Text(
          text,
          style: style,
        ),
      ),
    );
    var entry = OverlayEntry(
      builder: (_) => widget,
    );

    OverlayState? overlayState = Overlay.of(context);
    if (overlayState != null) {
      overlayState.insert(entry);
      Timer(const Duration(seconds: 2), () {
        entry.remove();
      });
    }
  }
  static void _showTestToast(BuildContext context, String text,{Key? key}) {
    Widget widget = Center(
      child: Container(
        padding: edgeInsets,
        decoration: decoration,
        child: Text(
          text,
          key: key,
          style: style,
        ),
      ),
    );
    var entry = OverlayEntry(
      builder: (_) => widget,
    );

    OverlayState? overlayState = Overlay.of(context);
    if (overlayState != null) {
      overlayState.insert(entry);
      Timer(const Duration(seconds: 3), () {
        entry.remove();
      });
    }
  }
}
