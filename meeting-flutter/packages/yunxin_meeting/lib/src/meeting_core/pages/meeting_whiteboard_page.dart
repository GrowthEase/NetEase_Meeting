// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

typedef WhiteBoardPageStatusCallback = void Function(bool isEditStatus);

class WhiteBoardWebPage extends StatefulWidget {
  final WhiteBoardPageStatusCallback whiteBoardPageStatusCallback;
  final ValueNotifier<bool> valueNotifier;

  WhiteBoardWebPage(
      {required this.whiteBoardPageStatusCallback,
      required this.valueNotifier});

  @override
  _WhiteBoardWebPageState createState() {
    return _WhiteBoardWebPageState();
  }
}

class _WhiteBoardWebPageState extends LifecycleBaseState<WhiteBoardWebPage> {
  bool isEditing = false;
  late NEInRoomWhiteboardController whiteBoardController;
  final _controller = Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    whiteBoardController =
        NERoomKit.instance.getInRoomService()!.getInRoomWhiteboardController();

    ///有权限默认开启
    isEditing = whiteBoardController.hasInteractPrivilege();
    widget.valueNotifier.addListener(() {
      ///没有权限则无法编辑
      if(mounted){
        setState(() {
          isEditing = widget.valueNotifier.value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    return SafeArea(
      child: Stack(
        ///扩展到stack大小
        children: <Widget>[
          Positioned(
            child: Container(
              color: UIColors.white,
              child: Center(
                child: WebView(
                  initialUrl: whiteBoardController.getWhiteboardUrl(),
                  scrollEnabled: false,
                  //JS执行模式 是否允许JS执行
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (controller) {
                    print('onWebViewCreated ->');
                    assert(!_controller.isCompleted);
                    _controller.complete(controller);
                  },
                  onPageFinished: (url) {
                    print('onPageFinished url： ${url}');
                  },
                  javascriptChannels: <JavascriptChannel>{
                    whiteBoardController.initWhiteboardJavascriptChannel(
                      _controller.future,
                      ({required code, msg}) {
                        print('WhiteBoardWebPage error: $code $msg');
                        ///白板权限未开通
                        if (code == RoomErrorCode.forbidden) {
                          showLogoutDialog();
                        }
                      },
                    )
                  },
                ),
              ),
            ),
          ),

          Positioned(
            right: 10,
            bottom: 110,
            width: 80,
            child: Padding(
                padding: EdgeInsets.all(10),
                child: Visibility(
                  visible: whiteBoardController.hasInteractPrivilege(),
                  child: Center(
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                            if (states.contains(MaterialState.disabled)) {
                              return UIColors.color_337eff;
                            }
                            return UIColors.color_337eff;
                          }),
                          padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(vertical: 4)),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  side:
                                      BorderSide(color: UIColors.color_337eff),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25))))),
                      onPressed: changeEditWhiteBoardStatus,
                      child: Text(
                        isEditing
                            ? Strings.packUpWhiteBoard
                            : Strings.editWhiteBoard,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    isEditing = false;
    super.dispose();
  }

  Future<void> changeEditWhiteBoardStatus() async {
    isEditing = !isEditing;
    await whiteBoardController.showWhiteboardTools(isEditing);
    widget.whiteBoardPageStatusCallback.call(isEditing);
    setState(() {});
  }

  void showLogoutDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: Text(Strings.noAuthorityWhiteBoard),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(Strings.ok),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
