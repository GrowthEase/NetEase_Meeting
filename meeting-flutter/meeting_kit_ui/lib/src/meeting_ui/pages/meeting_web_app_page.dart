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
  final ClearAllMessage clearAllMessage;

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
        appBar: buildAppBar(context),
        body: Column(
          children: [
            Expanded(
              child: WebViewWidget(controller: bridge.controller),
            ),
          ],
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: _UIColors.color_222222, fontSize: 17),
        ),
        centerTitle: true,
        backgroundColor: _UIColors.colorF6F6F6,
        elevation: 0.0,
        systemOverlayStyle: AppStyle.systemUiOverlayStyleDark,
        leading: _toClose
            ? GestureDetector(
                child: Container(
                  alignment: Alignment.center,
                  key: MeetingUIValueKeys.chatRoomClose,
                  child: Text(
                    NEMeetingUIKitLocalizations.of(context)!.globalClose,
                    style:
                        TextStyle(color: _UIColors.blue_337eff, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              )
            : GestureDetector(
                child: Container(
                  alignment: Alignment.center,
                  key: MeetingUIValueKeys.chatRoomClose,
                  child: Icon(
                    NEMeetingIconFont.icon_yx_returnx,
                    size: 18,
                    color: _UIColors.color_666666,
                  ),
                ),
                onTap: () {
                  bridge.controller.goBack();
                },
              ));
  }

  @override
  dispose() {
    widget.clearAllMessage?.call(widget.sessionId);
    super.dispose();
    bridge.dispose();
  }
}
