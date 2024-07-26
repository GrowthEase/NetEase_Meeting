// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingWebAppPage extends StatefulWidget {
  static const String routeName = "/meetingWebApp";
  final String roomArchiveId;
  final String homeUrl;
  final String title;
  final String? sessionId;
  final NERoomContext? roomContext;
  final ClearAllMessage? clearAllMessage;

  const MeetingWebAppPage({
    super.key,
    required this.roomArchiveId,
    required this.homeUrl,
    required this.title,
    this.sessionId,
    this.roomContext,
    this.clearAllMessage,
  });

  @override
  State<MeetingWebAppPage> createState() => _MeetingWebAppPageState();
}

class _MeetingWebAppPageState extends State<MeetingWebAppPage> {
  late NEMeetingJSBridge bridge;
  bool _toClose = true;

  @override
  void initState() {
    super.initState();
    // 设置屏幕方向为竖屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    bridge = NEMeetingJSBridge(
        widget.roomArchiveId, widget.homeUrl, widget.roomContext);
    bridge.controller
        .setNavigationDelegate(NavigationDelegate(onPageStarted: (url) {
      bridge.controller.canGoBack().then((value) {
        if (!mounted) return;
        setState(() {
          _toClose = !value;
        });
      });
    }, onPageFinished: (url) {
      bridge.controller.canGoBack().then((value) {
        if (!mounted) return;
        setState(() {
          _toClose = !value;
        });
      });
    }));
    bridge.load();
  }

  @override
  Widget build(BuildContext context) {
    bridge.buildContext = context;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        var canBack = await bridge.controller.canGoBack();
        if (canBack) {
          // 当网页还有历史记录时，返回webview上一页
          await bridge.controller.goBack();
        } else {
          // 返回原生页面上一页
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: TitleBar(
          title: TitleBarTitle(widget.title),
          showBottomDivider: true,
          leading: !_toClose
              ? GestureDetector(
                  child: Container(
                    width: 48,
                    height: 48,
                    child: Icon(
                      NEMeetingIconFont.icon_yx_returnx,
                      size: 18,
                      color: _UIColors.color_666666,
                    ),
                  ),
                  onTap: () {
                    bridge.controller.goBack();
                  },
                )
              : null,
        ),
        body: WebViewWidget(
          controller: bridge.controller,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
            new Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          ].toSet(),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  @override
  dispose() {
    // 恢复屏幕方向设置
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    widget.clearAllMessage?.call(widget.sessionId);
    super.dispose();
    bridge.dispose();
  }
}
