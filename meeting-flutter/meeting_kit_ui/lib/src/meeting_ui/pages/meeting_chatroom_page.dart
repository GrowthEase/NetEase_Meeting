// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingChatRoomPage extends StatefulWidget {
  final ChatRoomArguments _arguments;

  MeetingChatRoomPage(this._arguments);

  @override
  State<StatefulWidget> createState() {
    return MeetingChatRoomState(_arguments);
  }
}

class MeetingChatRoomState extends LifecycleBaseState<MeetingChatRoomPage> {
  final ChatRoomArguments _arguments;

  late TextEditingController _contentController;

  MeetingChatRoomState(this._arguments);

  late final int _initialScrollIndex;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  bool showToBottom = false, sending = false;

  /// 控制菜单出现时，消息不自动滚动到底部
  bool actionMenuShowing = false;

  bool canScrollToBottom = false;

  int delayDuration = 150;

  final FocusNode _focusNode = FocusNode();

  static const _kSupportedImageFileExtensions = {
    'png', 'jpg', 'jpeg', 'bmp', //'gif', 'webp', 'tiff', 'ico'
  };
  static const _kSupportedImageFileMaxSize = 20 * 1024 * 1024; // 20MB

  static const _kSupportedRawFileExtensions = {
    'png',
    'jpg',
    'jpeg',
    'bmp',
    'mp3',
    'aac',
    'wav',
    'pcm',
    'mp4',
    'flv',
    'mov',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'pdf',
    'zip',
    '7z',
    'tar',
    'txt',
    'apk',
    'ipa',
    'html',
  };
  static const _kSupportedRawFileMaxSize = 200 * 1024 * 1024; // 200MB

  SelectType _selectingType = SelectType.none;

  late NERoomChatController chatController;

  String get _myNickname {
    return _arguments.roomContext.localMember.name;
  }

  @override
  void initState() {
    super.initState();
    assert(() {
      debugInvertOversizedImages = true;
      debugImageOverheadAllowance = 10 * 1024 * 1024; // 10M
      return true;
    }());
    chatController = _arguments.roomContext.chatController;
    _contentController = TextEditingController();
    lifecycleListen(_arguments.messageSource.messageStream,
        (dynamic dataSource) {
      setState(() {
        final lastMsg = _arguments.lastMessage;
        if (!isMessageListviewAtBottom(_arguments.msgSize - 1) &&
            lastMsg is InMessageState) {
          showToBottom = true;
          canScrollToBottom = false;
        } else {
          showToBottom = false;
          canScrollToBottom = !actionMenuShowing;
        }
      });
    });
    _initialScrollIndex = max(_arguments.msgSize - 1, 0);
    itemPositionsListener.itemPositions
        .addListener(_handleItemPositionsChanged);
    assert(() {
      print('ScrollablePositionedList initial index: $_initialScrollIndex');
      return true;
    }());
  }

  void _scrollToIndex(int index, [double alignment = 0]) {
    assert(() {
      print('ScrollablePositionedList scrollToIndex: $index');
      return true;
    }());
    if (index < 0 || index >= _arguments.msgSize) {
      return;
    }
    itemScrollController.scrollTo(
      index: index,
      alignment: alignment,
      duration: Duration(milliseconds: delayDuration),
      curve: Curves.decelerate,
    );
  }

  void _handleItemPositionsChanged() {
    final positions = itemPositionsListener.itemPositions.value;
    final messageListviewAtBottom = isMessageListviewAtBottom();
    assert(() {
      print(
          'ScrollablePositionedList positions changed: isBottom=$messageListviewAtBottom, canScrollToBottom=$canScrollToBottom, pos=$positions');
      return true;
    }());
    if (canScrollToBottom && !messageListviewAtBottom) {
      canScrollToBottom = false;
      _scrollToIndex(_arguments.msgSize - 1);
    }
    if (messageListviewAtBottom && showToBottom) {
      setState(() {
        showToBottom = false;
      });
    }
  }

  bool isMessageListviewAtBottom([int? curMsgSize]) {
    final items = itemPositionsListener.itemPositions.value;
    final msgSize = curMsgSize ?? _arguments.msgSize;
    final len = items.length;
    ItemPosition? last;
    bool result = true;
    if (len > 0) {
      last = items.reduce((pre, cur) {
        return cur.index > pre.index ? cur : pre;
      });
      if (last.itemTrailingEdge > 1.0) {
        result = false;
      } else if (last.index < msgSize - 1) {
        result = false;
      }
    }
    assert(() {
      print(
          'ScrollablePositionedList check position: size=$msgSize, visible=$len, last=$last, result=$result');
      return true;
    }());
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: _UIColors.colorF6F6F6,
        appBar: buildAppBar(context),
        resizeToAvoidBottomInset: true,
        //body: SafeArea(top: false, left: false, right: false, child: buildBody()),
        body: buildBody(),
        floatingActionButton:
            showToBottom && _arguments.messageSource.unread > 0
                ? newMessageTips()
                : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
      onWillPop: () async {
        return onWillPop();
      },
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        title: Text(
          NEMeetingUIKitLocalizations.of(context)!.chat,
          style: TextStyle(color: _UIColors.color_222222, fontSize: 17),
        ),
        centerTitle: true,
        backgroundColor: _UIColors.colorF6F6F6,
        elevation: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: GestureDetector(
          child: Container(
            alignment: Alignment.center,
            key: MeetingUIValueKeys.chatRoomClose,
            child: Text(
              NEMeetingUIKitLocalizations.of(context)!.close,
              style: TextStyle(color: _UIColors.blue_337eff, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          onTap: () {
            if (_focusNode.hasFocus) {
              _focusNode.unfocus();
            }
            Navigator.pop(context);
          },
        ));
  }

  Widget newMessageTips() {
    return SafeArea(
        left: false,
        top: false,
        right: false,
        child: GestureDetector(
          onTap: () {
            _scrollToIndex(_arguments.msgSize - 1);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 62),
            height: 28,
            width: 74,
            decoration: BoxDecoration(
                color: _UIColors.blue_337eff,
                borderRadius: BorderRadius.all(Radius.circular(14.0)),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 2),
                      blurRadius: 2,
                      color: _UIColors.blue_50_337eff)
                ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.arrow_downward, size: 16, color: Colors.white),
                Text(
                  NEMeetingUIKitLocalizations.of(context)!.newMessage,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                )
              ],
            ),
          ),
        ));
  }

  bool onWillPop() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
      return false;
    }
    return true;
  }

  Widget buildBody() {
    return Container(
      color: Colors.white,
      child: SafeArea(
          child: Column(
        children: <Widget>[buildListView(), shadow(), buildInputPanel()],
      )),
    );
  }

  Widget shadow() {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: _UIColors.white,
        boxShadow: [
          BoxShadow(
            color: _UIColors.colorE1E3E6,
          ),
        ],
      ),
    );
  }

  Widget buildListView() {
    return Expanded(
        key: MeetingUIValueKeys.chatRoomListView,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_focusNode.hasFocus) {
              _focusNode.unfocus();
            }
          },
          child: ScrollConfiguration(
            behavior: _DisableOverScrollBehavior(),
            child: ScrollablePositionedList.builder(
              key: Key('MessageList'),
              physics: ClampingScrollPhysics(),
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
              initialScrollIndex: _initialScrollIndex,
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              itemBuilder: (context, index) {
                assert(() {
                  print('ScrollablePositionedList build: $index');
                  return true;
                }());
                var message = _arguments.getMessage(index);
                if (message is TimeMessage) {
                  return buildTimeTips(message.time);
                }
                if (message is AnchorMessage) {
                  return SizedBox(width: 1, height: 1);
                }
                return buildMessageItem(message) ?? Container();
              },
              itemCount: _arguments.msgSize,
            ),
          ),
        ));
  }

  Widget buildTimeTips(int time) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      alignment: Alignment.center,
      child: Text(
        time.formatToTimeString('kk:mm'),
        style: TextStyle(color: _UIColors.color_999999, fontSize: 12),
      ),
    );
  }

  Widget buildInputPanel() {
    return Container(
      padding: EdgeInsets.only(top: 8, bottom: 8),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: 10),
          buildInputBox(),
          if (!_arguments.isImageMessageEnabled &&
              !_arguments.isFileMessageEnabled)
            SizedBox(width: 10),
          if (_arguments.isImageMessageEnabled)
            buildIcon(Icons.image_outlined, 10,
                _arguments.isFileMessageEnabled ? 5 : 10, _onSelectImage),
          if (_arguments.isFileMessageEnabled)
            buildIcon(Icons.folder_open_outlined,
                _arguments.isImageMessageEnabled ? 5 : 10, 10, _onSelectFile)
        ],
      ),
    );
  }

  Widget buildIcon(IconData icon, double leftPadding, double rightPadding,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
            left: leftPadding, right: rightPadding, top: 10, bottom: 10),
        child: Icon(
          icon,
          size: 20,
          color: const Color(0xFF656A72),
        ),
      ),
    );
  }

  Widget buildInputBox() {
    return Expanded(
        child: Container(
      decoration: BoxDecoration(
          color: _UIColors.colorF7F8FA,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          border: Border.all(width: 1, color: _UIColors.colorF2F3F5)),
      height: 40,
      alignment: Alignment.center,
      child: TextField(
          key: MeetingUIValueKeys.inputMessageKey,
          focusNode: _focusNode,
          controller: _contentController,
          cursorColor: _UIColors.blue_337eff,
          keyboardAppearance: Brightness.light,
          textAlignVertical: TextAlignVertical.center,
          textInputAction: TextInputAction.send,
          onEditingComplete: () {
            _contentController.clearComposing();
          }, //this forbid the keyboard to dismiss
          onSubmitted: (_) => onSendMessage(),
          decoration: InputDecoration(
            filled: true,
            isDense: true,
            fillColor: Colors.transparent,
            hintText: NEMeetingUIKitLocalizations.of(context)!.inputMessageHint,
            hintStyle: TextStyle(
                fontSize: 14,
                color: _UIColors.color_999999,
                decoration: TextDecoration.none),
            border: InputBorder.none,
          )),
    ));
  }

  /// send message
  void onSendMessage() {
    if (sending) {
      // avoid duplicate send may be show loading
      return;
    }
    sending = true;
    Connectivity().checkConnectivity().then((value) async {
      if (value == ConnectivityResult.none) {
        sending = false;
        ToastUtils.showToast(context,
            NEMeetingKitLocalizations.of(context)!.networkUnavailableCheck);
      } else {
        var content = _contentController.text.trim();
        if (TextUtils.isEmpty(content)) {
          ToastUtils.showToast(context,
              NEMeetingUIKitLocalizations.of(context)!.cannotSendBlankLetter);
          sending = false;
          return;
        }
        final message = OutTextMessage(_myNickname, content);
        var result = await chatController.sendBroadcastTextMessage(content);
        sending = false;
        if (result.code == MeetingErrorCode.success) {
          _arguments.messageSource
              .append(message, message.time, incUnread: false);
          _contentController.clear();
        } else {
          ToastUtils.showToast(
              context,
              result.msg ??
                  NEMeetingKit.instance.localizations.networkUnavailableCheck);
        }
      }
    });
  }

  Widget? buildMessageItem(Object? message) {
    if (message is MessageState) {
      return _MessageItem(
        key: Key(message.uuid),
        incoming: !message.isSend,
        message: message,
        shouldShowRetry: message is OutMessageState || message is InFileMessage,
        onRetry: message.isSend
            ? (msg) => _realSendMessage(msg)
            : (msg) => _retryDownloadAttachment(msg),
        contentBuilder: (context) {
          if (message is TextMessageState) {
            return buildTextContent(context, message.text, message.isSend);
          } else if (message is ImageMessageState) {
            return buildImageContent(message);
          } else if (message is FileMessageState) {
            return buildFileContent(message);
          }
          return Container();
        },
      );
    }
    return null;
  }

  Widget buildImageContent(ImageMessageState message) {
    return _ImageContent(
      message: message,
      key: Key(message.uuid),
      onTap: (msg) {
        Navigator.of(context).push(MaterialMeetingPageRoute(builder: (context) {
          return MeetingImageMessageViewer(
            message: msg,
            downloadAttachmentCallback: (msg) {
              if (msg is InMessageState) {
                final downloadJob = chatController.downloadAttachment(msg.uuid);
                (msg as InMessageState).startDownloadAttachment(downloadJob);
              }
              return null;
            },
          );
        }));
      },
      onImageError: (msg) {
        // remove origin file
        File(msg.thumbPath).delete();
      },
    );
  }

  Widget buildFileContent(FileMessageState message) {
    return _FileContent(
      message: message,
      onTap: (msg) => _handleFileMessageClick(message),
    );
  }

  void _handleFileMessageClick(FileMessageState message) async {
    if (message is OutFileMessage) {
      _realOpenFile(message.path, message.name);
    } else if (message is InFileMessage) {
      if (message.isAttachmentDownloading) {
        message.resetAttachmentDownloadProgress();
        chatController.cancelDownloadAttachment(message.uuid);
      } else if (!message.isAttachmentDownloaded) {
        message.startDownloadAttachment(
            chatController.downloadAttachment(message.uuid));
      } else if (message.isAttachmentDownloaded) {
        _realOpenFile(message.path, message.name);
      }
    }
  }

  void _realOpenFile(String path, String name) async {
    OpenResult? result;
    ResultType? resultType;
    String? error;
    try {
      String? mime;
      // cannot determine mime type from path, try to get from name
      if (FileTypeUtils.getMimeType(path) == '*/*') {
        mime = FileTypeUtils.getMimeType(name);
      }
      result = await OpenFilex.open(path, type: mime);
    } catch (e) {
      resultType = ResultType.error;
      error = e.toString();
    }
    if (result != null) {
      resultType = result.type;
      error = result.message;
    }
    Alog.e(
      tag: _tag,
      moduleName: _moduleName,
      content: "open file result: $path $resultType $error",
    );
    if (!mounted) return;
    if (resultType == ResultType.noAppToOpen) {
      showToast(
          NEMeetingUIKitLocalizations.of(context)!.openFileFailAppNotFound);
    } else if (resultType == ResultType.fileNotFound) {
      showToast(
          NEMeetingUIKitLocalizations.of(context)!.openFileFailFileNotFound);
    } else if (resultType == ResultType.permissionDenied) {
      showToast(
          NEMeetingUIKitLocalizations.of(context)!.openFileFailNoPermission);
    } else if (resultType == ResultType.error) {
      showToast(NEMeetingUIKitLocalizations.of(context)!.openFileFail);
    }
  }

  Widget buildStatus() {
    return const Align(
      alignment: Alignment.center,
      child: Icon(
        Icons.error,
        size: 21,
        color: Color(0xFFFC596A),
      ),
    );
  }

  Widget buildName(String nick) {
    return Text(nick,
        style: TextStyle(color: _UIColors.color_333333, fontSize: 12));
  }

  Widget buildTextContent(BuildContext context, String content, bool isRight) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      margin: EdgeInsets.only(
          top: 4, left: isRight ? 24 : 0, right: isRight ? 0 : 24),
      child: PopupMenuWidget(
        onValueChanged: (int value) {
          if (value == 0) {
            Clipboard.setData(ClipboardData(text: content));
          }
        },
        onShow: () => actionMenuShowing = true,
        onDismiss: () => actionMenuShowing = false,
        pressType: PressType.longPress,
        actions: [
          NEMeetingUIKitLocalizations.of(context)!.copy,
        ],
        child: Container(
          padding: EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: isRight ? _UIColors.colorCCE1FF : _UIColors.colorF2F3F5,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Text(
            content,
            softWrap: true,
            style: TextStyle(color: _UIColors.color_333333, fontSize: 14),
          ),
        ),
      ),
    );
  }

  void _onSelectImage() {
    _selectFile(SelectType.image, _kSupportedImageFileExtensions,
        _kSupportedImageFileMaxSize);
  }

  void _onSelectFile() {
    _selectFile(SelectType.file, _kSupportedRawFileExtensions,
        _kSupportedRawFileMaxSize);
  }

  void _selectFile(
      SelectType type, Set<String> supportedExtensions, int maxFileSize) {
    if (_selectingType != SelectType.none) {
      return;
    }
    _selectingType = type;

    FilePicker.platform
        .pickFiles(
          type: _selectingType == SelectType.image
              ? FileType.image
              : FileType.custom,
          allowedExtensions: _selectingType == SelectType.image
              ? null
              : supportedExtensions.toList(growable: false),
        )
        .then((value) => _onFileSelected(
              value?.files.first,
              supportedExtensions,
              maxFileSize,
              type == SelectType.image
                  ? NEMeetingUIKitLocalizations.of(context)!
                      .imageSizeExceedTheLimit
                  : NEMeetingUIKitLocalizations.of(context)!
                      .fileSizeExceedTheLimit,
            ))
        .whenComplete(() => _selectingType = SelectType.none);
  }

  void _onFileSelected(
      PlatformFile? platformFile,
      Set<String> supportedExtensions,
      int maxFileSize,
      String sizeExceedErrorMsg) async {
    if (!mounted || platformFile == null) return;
    final name = platformFile.name;
    final path = platformFile.path;
    final size = platformFile.size;
    final extension = platformFile.name.split('.').lastOrNull;
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) {
        String? errorMsg;
        if (!supportedExtensions.contains(extension?.toLowerCase())) {
          errorMsg =
              NEMeetingUIKitLocalizations.of(context)!.unsupportedFileExtension;
        } else if (size > maxFileSize) {
          errorMsg = sizeExceedErrorMsg;
        }
        if (errorMsg != null) {
          ToastUtils.showToast(context, errorMsg);
          file.delete();
          return;
        }

        Object? message;
        if (_selectingType == SelectType.image) {
          message = OutImageMessage(_myNickname, path, size);
        } else if (_selectingType == SelectType.file) {
          message = OutFileMessage(_myNickname, name, path, size, extension);
        }
        if (message != null) {
          _realSendMessage(message);
        }
      }
    }
  }

  Future<bool> _realSendMessage(Object message) async {
    if (await _hasNetworkOrToast() == true) {
      if (message is OutMessageState) {
        if (message.isFailed) {
          _arguments.messageSource.removeMessage(message);
          message = message.copy();
        }
        if (message is OutImageMessage) {
          message.startSend(chatController.sendImageMessage(
            message.uuid,
            message.path,
            null,
          ));
        } else if (message is OutFileMessage) {
          message.startSend(chatController.sendFileMessage(
            message.uuid,
            message.path,
            null,
          ));
        }
        _arguments.messageSource
            .append(message, message.time, incUnread: false);
        return true;
      }
    }
    return false;
  }

  void _retryDownloadAttachment(MessageState message) {
    assert(message is InMessageState);
    if (message is InMessageState) {
      message.startDownloadAttachment(
          chatController.downloadAttachment(message.uuid));
    }
  }

  Future<bool> _hasNetworkOrToast() async {
    final value = await Connectivity().checkConnectivity();
    if (value == ConnectivityResult.none) {
      if (mounted) {
        ToastUtils.showToast(context,
            NEMeetingKitLocalizations.of(context)!.networkUnavailableCheck);
      }
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    assert(() {
      debugInvertOversizedImages = false;
      return true;
    }());
    _arguments.messageSource.resetUnread();
    _contentController.dispose();
    _focusNode.dispose();
    itemPositionsListener.itemPositions
        .removeListener(_handleItemPositionsChanged);
    super.dispose();
  }
}

class _MessageItem extends StatelessWidget {
  final bool incoming;
  final MessageState message;
  final void Function(MessageState)? onRetry;
  final bool shouldShowRetry;
  final WidgetBuilder contentBuilder;

  bool get outgoing => !incoming;

  const _MessageItem({
    Key? key,
    required this.incoming,
    required this.message,
    required this.contentBuilder,
    this.shouldShowRetry = true,
    this.onRetry,
  }) : super(key: key);

  static const _failureIconSize = 21.0;

  Widget _buildFailureIcon(bool left) {
    return Align(
      alignment: left ? Alignment.centerLeft : Alignment.centerRight,
      child: GestureDetector(
        onTap: () => onRetry?.call(message),
        child: Icon(
          Icons.error,
          size: _failureIconSize,
          color: Color(0xFFFC596A),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final head = ClipOval(
      child: Container(
        height: 24,
        width: 24,
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[_UIColors.blue_5996FF, _UIColors.blue_2575FF],
          ),
          shape: Border(),
        ),
        alignment: Alignment.center,
        child: Text(
          message.nickname.isNotEmpty ? message.nickname.substring(0, 1) : '',
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
      ),
    );
    final nickname = Text(
      message.nickname,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: _UIColors.color_333333, fontSize: 12),
    );
    final child = ValueListenableBuilder(
      valueListenable: message.failStatusListenable,
      builder: (BuildContext context, bool fail, Widget? child) {
        final bool leftFailIcon = fail && outgoing && shouldShowRetry;
        final bool rightFailIcon = fail && incoming && shouldShowRetry;
        final failureIcon = _buildFailureIcon(leftFailIcon);
        return Container(
          margin: EdgeInsets.only(top: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (incoming) head,
              SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: outgoing
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: <Widget>[
                    nickname,
                    SizedBox(height: 4),
                    Stack(
                      children: [
                        if (leftFailIcon)
                          Positioned.fill(
                            child: failureIcon,
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (leftFailIcon)
                              SizedBox(width: _failureIconSize + 4),
                            contentBuilder(context),
                            if (rightFailIcon)
                              SizedBox(width: _failureIconSize + 4),
                          ],
                        ),
                        if (rightFailIcon)
                          Positioned.fill(
                            child: failureIcon,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4),
              if (outgoing) head,
            ],
          ),
        );
      },
    );
    return Align(
      alignment: incoming ? Alignment.topLeft : Alignment.topRight,
      child: child,
    );
  }
}

class _ImageContent extends StatefulWidget {
  final ImageMessageState message;
  final void Function(ImageMessageState)? onTap;
  // final void Function(ImageMessageState)? onImageLoaded;
  final void Function(ImageMessageState)? onImageError;

  const _ImageContent({
    Key? key,
    required this.message,
    this.onTap,
    // this.onImageLoaded,
    this.onImageError,
  }) : super(key: key);

  @override
  State<_ImageContent> createState() => _ImageContentState();
}

class _ImageContentState extends State<_ImageContent>
    with AutomaticKeepAliveClientMixin {
  bool _loadedEventNotified = false;
  bool _errorEventNotified = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      key: Key(widget.message.uuid),
      future: widget.message.thumbImageInfo,
      // initialData: _ImageInfo(message.thumbPath, 100, 100),
      builder: (BuildContext context, AsyncSnapshot<_ImageInfo> snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.requireData;
          return buildMyImage(context, data.path, data.width, data.height);
        }
        return Container(
          width: 20,
          height: 20,
          color: _UIColors.colorF2F3F5,
        );
      },
    );
  }

  Widget buildMyImage(
      BuildContext context, String path, int width, int height) {
    final _size = _calculateImageSampleSize(context, width, height);
    Widget child = ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      child: SizedBox(
        width: _size.width,
        height: _size.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: widget.message.uuid,
              child: Image.file(
                File(path),
                errorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  print('Build image error: $error');
                  if (!_errorEventNotified) {
                    _errorEventNotified = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      widget.onImageError?.call(widget.message);
                    });
                  }
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 30,
                      color: const Color(0xFF656A72),
                    ),
                  );
                },
                frameBuilder: (BuildContext context, Widget? child, int? frame,
                    bool? wasSynchronouslyLoaded) {
                  if (frame == 0 && !_loadedEventNotified) {
                    _loadedEventNotified = true;
                    // WidgetsBinding.instance.addPostFrameCallback((_) {
                    //   widget.onImageLoaded?.call(widget.message);
                    // });
                  }
                  return child!;
                },
                fit: BoxFit.cover,
                cacheWidth: _size.width.ceil(),
              ),
            ),
            // ),
            if (widget.message is OutImageMessage)
              ValueListenableBuilder(
                valueListenable: (widget.message as OutImageMessage)
                    .attachmentUploadProgressListenable,
                builder: (BuildContext context, double value, Widget? child) {
                  return Visibility(
                    visible: value < 1.0 && !widget.message.isFailed,
                    child: Container(
                      color: Color(0x66000000),
                      alignment: Alignment.center,
                      child: _buildCircularProgressIndicator(42, value),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
    if (_size.height == null) {
      child = IntrinsicHeight(
        child: child,
      );
    }
    return GestureDetector(
      onTap: () => widget.onTap?.call(widget.message),
      child: child,
    );
  }

  _Size _calculateImageSampleSize(BuildContext context, int width, int height) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    double maxWidth = min(w, h) / 2;
    double maxHeight = max(w, h) / 3;
    final _Size output;
    if (width > 0 && height > 0) {
      if (maxWidth >= width && maxHeight >= height) {
        output = _Size(width.toDouble(), height.toDouble());
      } else {
        final double ratio = min(maxWidth / width, maxHeight / height);
        output = _Size(width * ratio, height * ratio);
      }
    } else {
      output = _Size(maxWidth, null);
    }
    assert(() {
      print(
          'calculateImageSampleSize: input=($width, $height), constraint=($w, $h, $maxWidth, $maxHeight), output=$output');
      return true;
    }());
    return output;
  }
}

class _Size {
  final double width;
  final double? height;

  const _Size(this.width, this.height);

  @override
  String toString() {
    return '{width: $width, height: $height}';
  }
}

class _FileContent extends StatelessWidget {
  static const fileIconWidth = 32.0;
  static const fileIconHeight = 40.0;

  final FileMessageState message;
  final void Function(FileMessageState)? onTap;

  const _FileContent({
    Key? key,
    required this.message,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    Widget child = Container(
      width: min(size.width, size.height) * 0.68,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(0xFFDEE0E2),
          width: 1.0,
        ),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Image.asset(
                FileTypeUtils.getIcon(message.extension),
                package: NEMeetingImages.package,
                width: fileIconHeight,
                height: fileIconHeight,
              ),
              if (message is OutMessageState)
                Positioned.fill(
                  child: ValueListenableBuilder(
                    key: Key(message.uuid),
                    valueListenable: (message as OutMessageState)
                        .attachmentUploadProgressListenable,
                    builder:
                        (BuildContext context, double value, Widget? child) {
                      return Visibility(
                        visible: value < 1.0 && !message.isFailed,
                        child: Center(
                          child: Container(
                            color: Color(0x66000000),
                            width: fileIconWidth,
                            height: fileIconHeight,
                            alignment: Alignment.center,
                            child: _buildCircularProgressIndicator(21, value),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (message is InMessageState)
                Positioned.fill(
                  child: ValueListenableBuilder(
                    key: Key(message.uuid),
                    valueListenable:
                        (message as InMessageState).attachmentDownloadProgress,
                    builder:
                        (BuildContext context, double value, Widget? child) {
                      return Visibility(
                        visible:
                            (message as InMessageState).isAttachmentDownloading,
                        child: Center(
                          child: Container(
                            width: fileIconWidth,
                            height: fileIconHeight,
                            color: Color(0x66000000),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                _buildCircularProgressIndicator(21, value),
                                Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        message.basename,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (message.extension != null)
                      Text(
                        '.${message.extension}',
                        maxLines: 1,
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  message.sizeInfo,
                  style: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return GestureDetector(
      onTap: () => onTap?.call(message),
      child: child,
    );
  }
}

Widget _buildCircularProgressIndicator(double viewSize, double value) {
  return SizedBox(
    width: viewSize,
    height: viewSize,
    child: CircularProgressIndicator(
      value: value,
      strokeWidth: 2.0,
      backgroundColor: Color(0x80FFFFFF),
      valueColor: AlwaysStoppedAnimation(Colors.white),
    ),
  );
}

enum SelectType {
  none,
  image,
  file,
}

class FileTypeUtils {
  FileTypeUtils._();

  static bool isImage(String extension) {
    return const {
      'png',
      'jpg',
      'jpeg',
      'bmp',
      'gif',
      'webp',
      'tiff',
      'ico',
    }.contains(extension);
  }

  static bool isAudio(String extension) {
    return const {'mp3', 'wav', 'aac', 'pcm'}.contains(extension);
  }

  static bool isVideo(String extension) {
    return const {'mp4', 'flv', 'mov'}.contains(extension);
  }

  static bool isZip(String extension) {
    return const {'7z', 'zip', 'tar', 'rar'}.contains(extension);
  }

  static bool isTxt(String extension) {
    return const {
      'txt',
      'text',
      'html',
      'xml',
      'java',
      'c',
      'cpp',
      'h',
      'hpp',
      'json',
      'md',
      'kt',
    }.contains(extension);
  }

  // get from open_file package
  static String getMimeType(String filePath) {
    final extension = filePath.split(".").lastOrNull?.toLowerCase();
    if (extension == null) {
      return '*/*';
    }
    switch (extension) {
      case "3gp":
        return "video/3gpp";
      case "torrent":
        return "application/x-bittorrent";
      case "kml":
        return "application/vnd.google-earth.kml+xml";
      case "gpx":
        return "application/gpx+xml";
      case "apk":
        return 'application/vnd.android.package-archive';
      case "asf":
        return "video/x-ms-asf";
      case "avi":
        return "video/x-msvideo";
      case "bin":
      case "class":
      case "exe":
        return "application/octet-stream";
      case "bmp":
        return "image/bmp";
      case "c":
        return "text/plain";
      case "conf":
        return "text/plain";
      case "cpp":
        return "text/plain";
      case "doc":
        return "application/msword";
      case "docx":
        return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
      case "xls":
      case "csv":
        return "application/vnd.ms-excel";
      case "xlsx":
        return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
      case "gif":
        return "image/gif";
      case "gtar":
        return "application/x-gtar";
      case "gz":
        return "application/x-gzip";
      case "h":
        return "text/plain";
      case "htm":
        return "text/html";
      case "html":
        return "text/html";
      case "jar":
        return "application/java-archive";
      case "java":
        return "text/plain";
      case "jpeg":
        return "image/jpeg";
      case "jpg":
        return "image/jpeg";
      case "js":
        return "application/x-javascript";
      case "log":
        return "text/plain";
      case "m3u":
        return "audio/x-mpegurl";
      case "m4a":
        return "audio/mp4a-latm";
      case "m4b":
        return "audio/mp4a-latm";
      case "m4p":
        return "audio/mp4a-latm";
      case "m4u":
        return "video/vnd.mpegurl";
      case "m4v":
        return "video/x-m4v";
      case "mov":
        return "video/quicktime";
      case "mp2":
        return "audio/x-mpeg";
      case "mp3":
        return "audio/x-mpeg";
      case "mp4":
        return "video/mp4";
      case "mpc":
        return "application/vnd.mpohun.certificate";
      case "mpe":
        return "video/mpeg";
      case "mpeg":
        return "video/mpeg";
      case "mpg":
        return "video/mpeg";
      case "mpg4":
        return "video/mp4";
      case "mpga":
        return "audio/mpeg";
      case "msg":
        return "application/vnd.ms-outlook";
      case "ogg":
        return "audio/ogg";
      case "pdf":
        return "application/pdf";
      case "png":
        return "image/png";
      case "pps":
        return "application/vnd.ms-powerpoint";
      case "ppt":
        return "application/vnd.ms-powerpoint";
      case "pptx":
        return "application/vnd.openxmlformats-officedocument.presentationml.presentation";
      case "prop":
        return "text/plain";
      case "rc":
        return "text/plain";
      case "rmvb":
        return "audio/x-pn-realaudio";
      case "rtf":
        return "application/rtf";
      case "sh":
        return "text/plain";
      case "tar":
        return "application/x-tar";
      case "tgz":
        return "application/x-compressed";
      case "txt":
        return "text/plain";
      case "wav":
        return "audio/x-wav";
      case "wma":
        return "audio/x-ms-wma";
      case "wmv":
        return "audio/x-ms-wmv";
      case "wps":
        return "application/vnd.ms-works";
      case "xml":
        return "text/plain";
      case "z":
        return "application/x-compress";
      case "zip":
        return "application/x-zip-compressed";
      default:
        return "*/*";
    }
  }

  static String getIcon(String? extension) {
    if (extension == null) return NEMeetingImages.fileTypeUnknown;
    if (isImage(extension)) {
      return NEMeetingImages.fileTypePicture;
    } else if (isAudio(extension)) {
      return NEMeetingImages.fileTypeAudio;
    } else if (isVideo(extension)) {
      return NEMeetingImages.fileTypeVideo;
    } else if (isZip(extension)) {
      return NEMeetingImages.fileTypeZip;
    } else if (isTxt(extension)) {
      return NEMeetingImages.fileTypeTxt;
    } else if (const {'doc', 'docx'}.contains(extension)) {
      return NEMeetingImages.fileTypeWord;
    } else if (const {'xls', 'xlsx'}.contains(extension)) {
      return NEMeetingImages.fileTypeExcel;
    } else if (const {'ppt', 'pptx'}.contains(extension)) {
      return NEMeetingImages.fileTypePpt;
    } else if (const {'pdf'}.contains(extension)) {
      return NEMeetingImages.fileTypePdf;
    } else {
      return NEMeetingImages.fileTypeUnknown;
    }
  }
}

class _DisableOverScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
