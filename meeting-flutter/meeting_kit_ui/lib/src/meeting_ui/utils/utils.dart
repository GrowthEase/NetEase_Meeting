// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

const defaultAnimationDuration = Duration(milliseconds: 200);

Future<void> isSupportPIP() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    debugPrint('Android 版本号: ${androidInfo.version.release}');
  }
}

void dismissKeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

final watermarkConfiguration = ValueNotifier<TextWatermarkConfiguration?>(null);

Widget wrapWithWatermark({required Widget child, bool onForeground = true}) {
  return ValueListenableBuilder<TextWatermarkConfiguration?>(
    valueListenable: watermarkConfiguration,
    builder: (context, configuration, child) {
      return TextWaterMark(
        child: child!,
        onForeground: onForeground,
        configuration: configuration,
      );
    },
    child: child,
  );
}
