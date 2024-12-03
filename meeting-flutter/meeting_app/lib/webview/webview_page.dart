// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../uikit/state/meeting_base_state.dart';

class WebViewArguments {
  final String? url;

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

class _WebViewState extends AppBaseState<WebViewPage> {
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
    return InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(arguments.url ?? '')),
        initialSettings: InAppWebViewSettings(
          mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
        ),
        onLoadStart: (InAppWebViewController controller, Uri? url) {
          Alog.d(tag: _tag, content: 'onLoadStart $url');
          LoadingUtil.showLoading(allowClick: true);
        },
        onLoadStop: (InAppWebViewController controller, Uri? url) {
          Alog.d(tag: _tag, content: 'onLoadStop $url');
          LoadingUtil.cancelLoading();
        },
        onReceivedError: (InAppWebViewController controller,
            WebResourceRequest request, WebResourceError error) {
          Alog.d(tag: _tag, content: 'onLoadError ${request.url} $error');
          LoadingUtil.cancelLoading();
        });
  }

  @override
  String getTitle() {
    return arguments.title;
  }

  @override
  void dispose() {
    super.dispose();
    LoadingUtil.cancelLoading();
  }
}
