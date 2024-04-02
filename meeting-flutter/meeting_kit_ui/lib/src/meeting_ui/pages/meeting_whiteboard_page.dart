// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

typedef WhiteBoardPageStatusCallback = void Function(bool isEditStatus);

class WhiteBoardWebPage extends StatefulWidget {
  final WhiteBoardPageStatusCallback whiteBoardPageStatusCallback;
  final ValueNotifier<bool> valueNotifier;
  final NERoomContext roomContext;
  final Color? backgroundColor;
  final bool? isMinimized;

  WhiteBoardWebPage({
    Key? key,
    required this.whiteBoardPageStatusCallback,
    required this.valueNotifier,
    required this.roomContext,
    this.backgroundColor,
    this.isMinimized,
  }) : super(key: key);

  @override
  _WhiteBoardWebPageState createState() {
    return _WhiteBoardWebPageState();
  }
}

class _WhiteBoardWebPageState extends BaseState<WhiteBoardWebPage>
    with AutomaticKeepAliveClientMixin {
  bool isEditing = false;
  late NERoomWhiteboardController whiteBoardController;
  late NERoomEventCallback callback;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    whiteBoardController = widget.roomContext.whiteboardController;
    widget.valueNotifier.addListener(() {
      ///没有权限则无法编辑
      if (mounted) {
        setState(() {
          isEditing = widget.valueNotifier.value;
        });
      }
    });
    callback = NERoomEventCallback(
      whiteboardError: (code, msg) {
        if (code == MeetingErrorCode.forbidden && widget.isMinimized != true) {
          showLogoutDialog();
        }
      },
      whiteboardShowFileChooser: (types) async {
        return await pickWhiteBoardFiles(context, types);
      },
    );
    // 添加白板加载出错监听
    widget.roomContext.addEventCallback(callback);

    ///有权限默认开启
    updateEditWhiteBoardStatus(
        whiteBoardController.isDrawWhiteboardEnabled(), false);
    whiteBoardController.applyWhiteboardConfig();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildBody();
  }

  /// 白板视图手势识别。编辑状态下，使用 EagerGestureRecognizer，否则使用默认的 recognizer。
  late final _whiteboardViewGestureRecognizer =
      _ConditionalEagerGestureRecognizer(condition: () => isEditing);

  Widget _buildBody() {
    return SafeArea(
      child: Stack(
        ///扩展到stack大小
        children: <Widget>[
          Positioned(
            child: Container(
              alignment: Alignment.center,
              child: whiteBoardController.createWhiteboardView(
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                  new Factory<OneSequenceGestureRecognizer>(
                    () => _whiteboardViewGestureRecognizer,
                  ),
                ].toSet(),
                backgroundColor: widget.backgroundColor,
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 150,
            width: 80,
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Visibility(
                  visible: whiteBoardController.isDrawWhiteboardEnabled(),
                  child: Center(
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<
                              Color>((states) {
                            if (states.contains(MaterialState.disabled)) {
                              return _UIColors.color_337eff;
                            }
                            return _UIColors.color_337eff;
                          }),
                          padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(vertical: 4)),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  side:
                                      BorderSide(color: _UIColors.color_337eff),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25))))),
                      onPressed: () => updateEditWhiteBoardStatus(!isEditing),
                      child: Text(
                        isEditing
                            ? NEMeetingUIKitLocalizations.of(context)!
                                .whiteBoardPackUp
                            : NEMeetingUIKitLocalizations.of(context)!
                                .globalEdit,
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
    widget.roomContext.removeEventCallback(callback);
    super.dispose();
  }

  void updateEditWhiteBoardStatus(bool drawable, [bool update = true]) {
    Alog.i(tag: 'WhiteBoardWebPageState', content: 'switch drawable=$drawable');
    isEditing = drawable;
    whiteBoardController.showWhiteboardTools(drawable);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.whiteBoardPageStatusCallback.call(drawable);
    });
    if (update) {
      setState(() {});
    }
  }

  void showLogoutDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return NEMeetingUIKitLocalizationsScope(
            builder: (context) {
              return CupertinoAlertDialog(
                content: Text(NEMeetingUIKitLocalizations.of(context)!
                    .whiteBoardNoAuthority),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(
                        NEMeetingUIKitLocalizations.of(context)!.globalGotIt),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        });
  }

  Future<String?> pickWhiteBoardFiles(
      BuildContext context, List<String?> types) async {
    String? path;
    var fileType = FileType.any;
    if (types.contains('image/*')) {
      fileType = FileType.image;
    } else if (types.contains('video/*')) {
      fileType = FileType.media;
    }
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: fileType,
    );
    if (result != null) {
      String originPath = result.files.single.path!;
      // String originName = result.files.single.name;
      final extension = result.files.single.extension;

      File originFile = File(originPath);
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }
      path =
          '${directory!.path}/whiteboard/${originPath.md5}${extension != null ? ".$extension" : ""}';
      var file = File('$path');
      if (!(await file.exists())) {
        // final contents = await originFile.readAsBytes();
        // file.createSync(recursive: true);
        // await file.writeAsBytes(contents);
        file.createSync(recursive: true);
        await file.openWrite().addStream(originFile.openRead());
      }
    } else {
      Alog.i(
          tag: _tag,
          moduleName: _moduleName,
          content: 'User canceled the picker');
      // User canceled the picker
    }
    Alog.i(tag: _tag, moduleName: _moduleName, content: '>>>>>path: $path');
    return path;
  }
}

class _ConditionalEagerGestureRecognizer extends EagerGestureRecognizer {
  final ValueGetter<bool>? condition;

  _ConditionalEagerGestureRecognizer({
    this.condition,
  });

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (condition?.call() ?? true) {
      super.addAllowedPointer(event);
    }
  }
}
