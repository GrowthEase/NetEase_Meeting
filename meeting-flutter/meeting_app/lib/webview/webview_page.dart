// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/uikit/values/colors.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../uikit/state/meeting_base_state.dart';

class WebViewArguments {
  final String url;

  final String title;

  WebViewArguments(this.url, this.title);
}

class WebViewPage extends StatefulWidget {
  final WebViewArguments? arguments;

  WebViewPage([this.arguments]);

  @override
  State<StatefulWidget> createState() {
    return _WebViewState();
  }
}

class _WebViewState extends MeetingBaseState<WebViewPage> {
  static const _tag = 'WebViewPage';

  WebViewArguments? _arguments;
  WebViewArguments get arguments {
    _arguments ??= (widget.arguments ??
        ModalRoute.of(context)!.settings.arguments as WebViewArguments);
    return _arguments!;
  }

  @override
  Color get backgroundColor => AppColors.white;

  @override
  Widget buildBody() {
    return WebView(
      initialUrl: arguments.url,
      javascriptMode: JavascriptMode.unrestricted,
      onPageStarted: (url) {
        Alog.d(tag: _tag, content: 'onPageStarted $url');
      },
      onPageFinished: (url) {
        Alog.d(tag: _tag, content: 'onPageFinished $url');
      },
    );
  }

  @override
  String getTitle() {
    return arguments.title;
  }
}
