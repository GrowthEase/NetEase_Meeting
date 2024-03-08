// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingChatRoomPage extends StatefulWidget {
  static const String routeName = "/meetingChatRoom";
  final ChatRoomArguments arguments;
  final bool isMinimized;
  final String? roomArchiveId;

  final NEChatroomType initialChatroomType;

  MeetingChatRoomPage(
      {required this.arguments,
      this.isMinimized = false,
      this.roomArchiveId,
      this.initialChatroomType = NEChatroomType.common});

  @override
  State<StatefulWidget> createState() {
    return MeetingChatRoomState(
        arguments, isMinimized, roomArchiveId, initialChatroomType);
  }
}

class MeetingChatRoomState extends LifecycleBaseState<MeetingChatRoomPage>
    with MeetingUIStateScope {
  final ChatRoomArguments _arguments;
  final bool _isMinimized;
  String? _roomArchiveId;

  late TextEditingController _contentController;
  final NEChatroomType initialChatroomType;

  MeetingChatRoomState(this._arguments, this._isMinimized, this._roomArchiveId,
      this.initialChatroomType);

  late int _initialScrollIndex;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  bool showToBottom = false, sending = false;

  /// 控制菜单出现时，消息不自动滚动到底部
  bool actionMenuShowing = false;

  bool canScrollToBottom = false;

  int delayDuration = 150;

  final _waitingRoomChatEnabled = ValueNotifier(false);
  void updateWaitingRoomChatEnabled() {
    final enabled = _isMySelfHostOrCoHost() &&
        _arguments.waitingRoomManager?.userList.isNotEmpty == true;
    if (!enabled) {
      _selectedChatroomType.value = NEChatroomType.common;
    }
    _waitingRoomChatEnabled.value = enabled;
  }

  final _selectedChatroomType = ValueNotifier(NEChatroomType.common);

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
    return _arguments.roomContext?.localMember.name ??
        NEMeetingKit.instance.getAccountService().getAccountInfo()?.nickname ??
        '';
  }

  String? get _myAvatar {
    return _arguments.roomContext?.localMember.avatar ??
        NEMeetingKit.instance.getAccountService().getAccountInfo()?.avatar;
  }

  bool disableScrollToBottom = false;
  ValueNotifier<bool> isAlwaysScrollable = ValueNotifier(true);
  late EventCallback _eventCallback;
  int nextPullMessageTime = 0;
  bool isShowLoading = false;
  @override
  void initState() {
    super.initState();
    _arguments.messageSource.unread = 0;
    assert(() {
      debugInvertOversizedImages = true;
      debugImageOverheadAllowance = 10 * 1024 * 1024; // 10M
      return true;
    }());
    if (_arguments.roomContext != null) {
      chatController = _arguments.roomContext!.chatController;
    }
    _contentController = TextEditingController();
    _roomArchiveId = widget.roomArchiveId;
    lifecycleListen(_arguments.messageSource.messageStream,
        (dynamic dataSource) {
      setState(() {
        final lastMsg = _arguments.lastMessage;
        if (!isMessageListviewAtBottom(_arguments.msgSize - 1) &&
            lastMsg is InMessageState) {
          showToBottom = true;
          canScrollToBottom = false;
        } else {
          _arguments.messageSource.unread = 0;
          showToBottom = false;
          canScrollToBottom = !actionMenuShowing;
        }
      });
    });
    _initialScrollIndex = max(_arguments.msgSize - 1, 0);
    itemPositionsListener.itemPositions
        .addListener(_handleItemPositionsChanged);
    _arguments.roomContext?.addEventCallback(NERoomEventCallback(
      memberRoleChanged: memberRoleChanged,
    ));

    /// 等候室人数为0时，聊天发送对象自动切回会议中所有人
    final waitingRoomManager = _arguments.waitingRoomManager;
    if (waitingRoomManager != null) {
      lifecycleListen(waitingRoomManager.userListChanged, (value) {
        updateWaitingRoomChatEnabled();
      });
    }
    updateWaitingRoomChatEnabled();

    _eventCallback = (arg) {
      disableScrollToBottom = true;
      if ((arg as ChatRecallMessage).operateBy !=
              _arguments.roomContext?.localMember.uuid ||
          NEMeetingKit.instance
                  .getAccountService()
                  .getAccountInfo()
                  ?.userUuid ==
              (arg).operateBy) {
        if (arg.fileCancelDownload) {
          chatController.cancelDownloadAttachment(arg.messageId);
          showRecallDialog();
        }
      }
    };
    assert(() {
      print('ScrollablePositionedList initial index: $_initialScrollIndex');
      return true;
    }());
    if (_roomArchiveId != null) {
      pullMessagesNotInMeeting(isFirst: true);
    } else {
      EventBus().subscribe(RecallMessageNotify, _eventCallback);
    }
  }

  void memberRoleChanged(
      NERoomMember member, NERoomRole before, NERoomRole after) {
    if (isSelf(member.uuid)) {
      updateWaitingRoomChatEnabled();
    }
  }

  bool isSelf(String? userId) {
    return userId != null && _arguments.roomContext?.isMySelf(userId) == true;
  }

  void showRecallDialog() {
    DialogUtils.showOneButtonCommonDialog(context,
        NEMeetingUIKitLocalizations.of(context)!.chatMessageRecalled, null, () {
      if (!mounted) return;
      // _arguments.messageSource.replaceToRecallMessage(message);
      Navigator.of(context).pop();
    }, acceptText: NEMeetingUIKitLocalizations.of(context)!.globalSure);
  }

  void _scrollToIndex(int index, [double alignment = 0]) async {
    assert(() {
      print('ScrollablePositionedList scrollToIndex: $index');
      return true;
    }());
    if (index < 0 || index >= _arguments.msgSize) {
      return;
    }
    if (!mounted) return;
    isAlwaysScrollable.value = false;
    await itemScrollController.scrollTo(
      index: index,
      alignment: alignment,
      duration: Duration(milliseconds: delayDuration),
      curve: Curves.decelerate,
    );
    isAlwaysScrollable.value = true;
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
      if (disableScrollToBottom) {
        disableScrollToBottom = false;
      } else {
        _scrollToIndex(_arguments.msgSize - 1);
      }
    }
    if (messageListviewAtBottom && showToBottom) {
      setState(() {
        showToBottom = false;
        _arguments.messageSource.unread = 0;
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
    final double appBarHeight = AppBar().preferredSize.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return WillPopScope(
      child: Scaffold(
        backgroundColor: _UIColors.colorF6F6F6,
        appBar: buildAppBar(context),
        resizeToAvoidBottomInset: true,
        //body: SafeArea(top: false, left: false, right: false, child: buildBody()),
        body:
            _roomArchiveId != null && !isShowLoading && _arguments.msgSize <= 0
                ? Center(child: LayoutBuilder(builder: (context, constraints) {
                    return Container(
                      margin: EdgeInsets.only(
                          top: (constraints.maxHeight -
                                      appBarHeight -
                                      statusBarHeight) /
                                  2 -
                              appBarHeight -
                              statusBarHeight),
                      child: Column(
                        children: [
                          Image.asset(NEMeetingImages.noMessageHistory,
                              package: NEMeetingImages.package),
                          Text(
                            NEMeetingUIKitLocalizations.of(context)!
                                .chatNoChatHistory,
                            style: TextStyle(
                                fontSize: 14,
                                color: _UIColors.color_999999,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.none),
                          ),
                        ],
                      ),
                    );
                  }))
                : buildBody(),
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
          _roomArchiveId != null
              ? NEMeetingUIKitLocalizations.of(context)!.chatHistory
              : NEMeetingUIKitLocalizations.of(context)!.chat,
          style: TextStyle(color: _UIColors.color_222222, fontSize: 17),
        ),
        centerTitle: true,
        backgroundColor: _UIColors.colorF6F6F6,
        elevation: 0.0,
        systemOverlayStyle: AppStyle.systemUiOverlayStyleDark,
        leading: GestureDetector(
          child: _roomArchiveId != null
              ? IconButton(
                  key: MeetingUIValueKeys.back,
                  icon: const Icon(
                    NEMeetingIconFont.icon_yx_returnx,
                    color: _UIColors.black_333333,
                    size: 18,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              : Container(
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
            child: ValueListenableBuilder(
                valueListenable: _waitingRoomChatEnabled,
                builder: (BuildContext context, bool enabled, Widget? child) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 62 + (enabled ? 30 : 0)),
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    height: 28,
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
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.arrow_downward,
                            size: 16, color: Colors.white),
                        Text(
                          NEMeetingUIKitLocalizations.of(context)!
                              .chatNewMessage,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        )
                      ],
                    ),
                  );
                })));
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
        children: <Widget>[
          buildListView(),
          if (inputPanelEnabled) buildInputPanel()
        ],
      )),
    );
  }

  bool get inputPanelEnabled {
    return _arguments.roomContext != null &&
        (_isMySelfHostOrCoHost() ||
            initialChatroomType != NEChatroomType.waitingRoom);
  }

  MessageState? convertMessage(NERoomChatMessage msg,
      {bool isRoomOutHistory = false}) {
    var valid = false;
    InMessageState? message;
    if (msg is NERoomChatTextMessage && msg.text.isNotEmpty) {
      message = InTextMessage(msg.messageUuid, msg.time, msg.fromNick,
          msg.fromAvatar, msg.text, msg.messageUuid, msg.chatroomType);
    } else if (msg is NERoomChatImageMessage) {
      valid = (isRoomOutHistory
              ? true
              : msg.path.isNotEmpty && msg.thumbPath.isNotEmpty) &&
          msg.width > 0 &&
          msg.height > 0;
      if (valid) {
        message = InImageMessage(
          msg.messageUuid,
          msg.time,
          msg.fromNick,
          msg.fromAvatar,
          (msg.thumbPath ?? ''),
          (msg.path ?? ''),
          msg.extension,
          msg.size,
          msg.width,
          msg.height,
          msg.messageUuid,
          msg.url,
          msg.chatroomType,
        );
        if (_roomArchiveId == null) {
          message.startDownloadAttachment(
              chatController.downloadAttachment(msg.messageUuid));
        } else {
          // NEMeetingKit.instance
          //     .getMeetingService()
          //     .downloadAttachment(msg.messageUuid);
        }
      }
    } else if (msg is NERoomChatFileMessage) {
      valid = msg.url.isNotEmpty &&
          msg.displayName != null &&
          (isRoomOutHistory ? true : msg.path != null);
      if (valid) {
        message = InFileMessage(
          msg.messageUuid,
          msg.time,
          msg.fromNick,
          msg.fromAvatar,
          msg.displayName as String,
          (msg.path ?? ''),
          msg.size,
          msg.extension,
          msg.messageUuid,
          msg.chatroomType,
        );
      }
    } else if (msg is NERoomChatNotificationMessage) {
      message = InNotificationMessage(
          '',
          msg.fromAvatar,
          msg.messageUuid,
          msg.time,
          msg.eventType,
          msg.operateBy,
          msg.recalledMessageId,
          msg.chatroomType);
    }
    if (msg.fromUserUuid == _arguments.roomContext?.localMember.uuid ||
        NEMeetingKit.instance.getAccountService().getAccountInfo()?.userUuid ==
            msg.fromUserUuid) {
      message?.isSend = true;
    }
    message?.isHistory = true;
    return message;
  }

  int firstMessageTime({bool isSort = false, bool isRoomOutHistory = false}) {
    int time =
        isSort || isRoomOutHistory ? DateTime.now().millisecondsSinceEpoch : 0;
    final firstMessage = _arguments.messageSource.messages
        .where((element) =>
            element is MessageState && !(element is NotificationMessageState))
        .firstOrNull;
    if (firstMessage != null && firstMessage is MessageState) {
      time = isSort
          ? firstMessage.time
          : (Platform.isIOS
              ? (firstMessage.time / 1000).floor()
              : firstMessage.time);

      /// 按照tag拉取消息，存在会获取当前消息重复的问题，-1策略是去掉已经拉取的重复信息
      return time - 1;
    }
    return time;
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
              child: RefreshIndicator.adaptive(
                  color: _UIColors.color_666666,
                  onRefresh: () async => _roomArchiveId != null
                      ? pullMessagesNotInMeeting()
                      : pullMessages(),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isAlwaysScrollable,
                    builder: (BuildContext context, bool value, _) {
                      return _roomArchiveId != null && _initialScrollIndex == 0
                          ? Container()
                          : ScrollablePositionedList.builder(
                              key: Key('MessageList'),
                              physics: value
                                  ? AlwaysScrollableScrollPhysics()
                                  : ClampingScrollPhysics(),
                              itemScrollController: itemScrollController,
                              itemPositionsListener: itemPositionsListener,
                              initialScrollIndex: _initialScrollIndex,
                              padding: EdgeInsets.only(
                                  left: 16, right: 16, bottom: 16),
                              itemBuilder: (context, index) {
                                assert(() {
                                  print(
                                      'ScrollablePositionedList build: $index');
                                  return true;
                                }());
                                var message = _arguments.getMessage(index);
                                if (message is TimeMessage) {
                                  return buildTimeTips(message.time);
                                }
                                if (message is NotificationMessageState) {
                                  return buildNotifyContent(message);
                                }
                                if (message is HistorySegment &&
                                    _roomArchiveId == null) {
                                  return buildHistorySegment();
                                }
                                if (message is AnchorMessage) {
                                  return SizedBox(width: 1, height: 1);
                                }
                                return buildMessageItem(message) ?? Container();
                              },
                              itemCount: _arguments.msgSize,
                            );
                    },
                  ))),
        ));
  }

  Widget buildHistorySegment() {
    return Container(
        height: 16,
        margin: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: Container(
              color: _UIColors.colorDADBDB,
              height: 1,
              margin: EdgeInsets.only(left: 16),
            )),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  NEMeetingUIKitLocalizations.of(context)!
                      .chatAboveIsHistoryMessage,
                  style: TextStyle(
                    color: _UIColors.color_999999,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                )),
            Expanded(
                child: Container(
              color: _UIColors.colorDADBDB,
              height: 1,
              margin: EdgeInsets.only(right: 16),
            )),
          ],
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
      padding: EdgeInsets.only(top: 10, bottom: 12, left: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              offset: Offset(0, -0.5),
              blurRadius: 0.5,
              color: _UIColors.colorE1E3E6)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder(
              valueListenable: _waitingRoomChatEnabled,
              builder: (BuildContext context, bool enabled, Widget? child) {
                if (!enabled) return SizedBox.shrink();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          NEMeetingUIKitLocalizations.of(context)!.chatSendTo,
                          style: TextStyle(
                            color: _UIColors.color_666666,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: _showSelectTargetSheet,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ValueListenableBuilder<NEChatroomType>(
                                  valueListenable: _selectedChatroomType,
                                  builder: (context, value, child) {
                                    return Text(
                                      value == NEChatroomType.common
                                          ? NEMeetingUIKitLocalizations.of(
                                                  context)!
                                              .chatAllMembersInMeeting
                                          : NEMeetingUIKitLocalizations.of(
                                                  context)!
                                              .chatAllMembersInWaitingRoom,
                                      style: TextStyle(
                                        color: _UIColors.color_333333,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        decoration: TextDecoration.none,
                                      ),
                                    );
                                  }),
                              Container(
                                width: 20,
                                height: 20,
                                alignment: Alignment.center,
                                child: Icon(
                                  NEMeetingIconFont.icon_triangle_down,
                                  size: 8,
                                  color: _UIColors.color_999999,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                );
              }),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              buildInputBox(),
              if (!_arguments.isImageMessageEnabled &&
                  !_arguments.isFileMessageEnabled)
                SizedBox(width: 10),
              if (_arguments.isImageMessageEnabled)
                buildIcon(Icons.image_outlined, 10,
                    _arguments.isFileMessageEnabled ? 5 : 10, _onSelectImage),
              if (_arguments.isFileMessageEnabled)
                buildIcon(
                    Icons.folder_open_outlined,
                    _arguments.isImageMessageEnabled ? 5 : 10,
                    10,
                    _onSelectFile)
            ],
          )
        ],
      ),
    );
  }

  void _showSelectTargetSheet() {
    final localizations = NEMeetingUIKitLocalizations.of(context)!;
    DialogUtils.showChildNavigatorPopup<_ChatTargetSheetIDs>(
        context,
        (context) => CupertinoActionSheet(
              actions: <Widget>[
                _buildActionSheetItem(
                    context,
                    false,
                    localizations.chatAllMembersInMeeting,
                    _ChatTargetSheetIDs.allMembersInMeeting),
                _buildActionSheetItem(
                    context,
                    false,
                    localizations.chatAllMembersInWaitingRoom,
                    _ChatTargetSheetIDs.allMembersInWaitingRoom),
              ],
              cancelButton: _buildActionSheetItem(context, true,
                  localizations.globalCancel, _ChatTargetSheetIDs.cancel),
            )).then<void>((_ChatTargetSheetIDs? itemId) async {
      if (itemId == null || itemId == _ChatTargetSheetIDs.cancel) return;
      _selectedChatroomType.value =
          itemId == _ChatTargetSheetIDs.allMembersInWaitingRoom &&
                  _waitingRoomChatEnabled.value
              ? NEChatroomType.waitingRoom
              : NEChatroomType.common;
    });
  }

  Widget _buildActionSheetItem(BuildContext context, bool defaultAction,
      String title, _ChatTargetSheetIDs itemId,
      {Color textColor = _UIColors.color_007AFF}) {
    return CupertinoActionSheetAction(
        isDefaultAction: defaultAction,
        child: Text(title, style: TextStyle(color: textColor)),
        onPressed: () => Navigator.pop(context, itemId));
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
            hintText:
                NEMeetingUIKitLocalizations.of(context)!.chatInputMessageHint,
            hintStyle: TextStyle(
                fontSize: 14,
                color: _UIColors.color_999999,
                decoration: TextDecoration.none),
            border: InputBorder.none,
          )),
    ));
  }

  /// send message
  void onSendMessage() async {
    if (sending) {
      // avoid duplicate send may be show loading
      return;
    }
    sending = true;
    final content = _contentController.text;
    if (content.isBlank) {
      showToast(
          NEMeetingUIKitLocalizations.of(context)!.chatCannotSendBlankLetter);
    } else if (await _realSendMessage(OutTextMessage(
        _myNickname, _myAvatar, content, _selectedChatroomType.value))) {
      _contentController.clear();
    }
    sending = false;
  }

  void recallMessage(MessageState message) async {
    if (await _hasNetworkOrToast() == false) return;
    chatController
        .recallChatroomMessage(message.msgId ?? "", message.time,
            chatroomType: message.chatroomType)
        .then((value) {
      if (!value.isSuccess() && value.msg != null) {
        showToast(value.msg!);
      }
    });
  }

  bool _isMySelfHostOrCoHost() {
    return _arguments.roomContext?.isMySelfHost() == true ||
        _arguments.roomContext?.isMySelfCoHost() == true;
  }

  void pullMessages() async {
    if (await _hasNetworkOrToast() == false) return;

    final messages = <MessageState>[];
    final commonMessagesFuture =
        widget.initialChatroomType != NEChatroomType.waitingRoom
            ? fetchChatroomHistoryMessages(NEChatroomType.common)
            : Future.value(<MessageState>[]);
    final waitingRoomMessagesFuture =
        widget.initialChatroomType == NEChatroomType.waitingRoom ||
                _isMySelfHostOrCoHost()
            ? fetchChatroomHistoryMessages(NEChatroomType.waitingRoom)
            : Future.value(<MessageState>[]);
    await Future.wait<List<MessageState>>([
      commonMessagesFuture,
      waitingRoomMessagesFuture,
    ]).then((value) {
      messages.addAll(_combineMessage(value[0], value[1]));
    });
    if (messages.isEmpty) return;
    int time = firstMessageTime(isSort: true);
    disableScrollToBottom = true;
    _arguments.messageSource.insert(messages, time,
        isFirstInsert: _arguments.messageSource.isFirstFetchHistory);
    _arguments.messageSource.isFirstFetchHistory = false;
  }

  Future<List<MessageState>> fetchChatroomHistoryMessages(
      NEChatroomType chatroomType) async {
    final option = NEChatroomHistoryMessageSearchOption(
      startTime: firstMessageTime(),
      limit: 20,
      chatroomType: chatroomType,
    );
    final result = await chatController.fetchChatroomHistoryMessages(option);
    if (result.isSuccess()) {
      return result.data!
          .map((e) => convertMessage(e))
          .whereType<MessageState>()
          .toList();
    } else {
      showToast(result.msg!);
      return [];
    }
  }

  /// 传入两个有序的消息数组，按时间戳排序，返回最新的20条消息，
  List<MessageState> _combineMessage(List<MessageState> commonMessages,
      List<MessageState> waitingRoomMessages) {
    if (commonMessages.isEmpty) {
      return waitingRoomMessages;
    }
    if (waitingRoomMessages.isEmpty) {
      return commonMessages;
    }
    List<MessageState> result = [];
    int i = 0, j = 0;
    while (i < commonMessages.length && j < waitingRoomMessages.length) {
      if (commonMessages[i].time > waitingRoomMessages[j].time) {
        result.add(commonMessages[i]);
        i++;
      } else {
        result.add(waitingRoomMessages[j]);
        j++;
      }
    }
    if (i < commonMessages.length) {
      result.addAll(commonMessages.sublist(i));
    }
    if (j < waitingRoomMessages.length) {
      result.addAll(waitingRoomMessages.sublist(j));
    }
    return result.take(20).toList();
  }

  void pullMessagesNotInMeeting({isFirst = false}) async {
    if (isFirst) {
      LoadingUtil.showLoading();
      isShowLoading = true;
    }

    if (await _hasNetworkOrToast() == false) {
      setState(() {
        LoadingUtil.cancelLoading();
        isShowLoading = false;
      });
      return;
    }

    final option = NEChatroomHistoryMessageSearchOption(
      startTime: firstMessageTime(isRoomOutHistory: true),
      limit: 20,
    );

    final result = await NEMeetingKit.instance
        .getMeetingService()
        .fetchChatroomHistoryMessages(widget.roomArchiveId!, option);

    if (result.isSuccess()) {
      final messages = result.data!
          .map((e) => convertMessage(e, isRoomOutHistory: true))
          .whereType<MessageState>()
          .toList();
      int time = firstMessageTime(isSort: true, isRoomOutHistory: true);
      disableScrollToBottom = true;
      _arguments.messageSource.insert(messages, time,
          isFirstInsert: _arguments.messageSource.isFirstFetchHistory);
      _arguments.messageSource.isFirstFetchHistory = false;
    } else if (result.msg != null) {
      showToast(result.msg!);
    }
    if (isFirst) {
      setState(() {
        LoadingUtil.cancelLoading();
        isShowLoading = false;
        _initialScrollIndex = max(_arguments.msgSize - 1, 0);
      });
    }
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
            return buildTextContent(
                context, message.text, message.isSend, message);
          } else if (message is ImageMessageState) {
            int height = message.height ?? 100;
            int width = message.width ?? 100;
            ChatImageSize _size =
                calculateImageSampleSize(context, width, height);
            return _roomArchiveId != null
                ? MeetingCachedNetworkImage.CachedNetworkImage(
                    width: _size.width,
                    height: _size.height,
                    imageUrl: message.url!,
                    fit: BoxFit.cover,
                  )
                : buildImageContent(message, message.isSend);
          } else if (message is FileMessageState) {
            return buildFileContent(message, message.isSend);
          }
          return Container();
        },
        sendTo: (message.chatroomType == NEChatroomType.waitingRoom &&
                _isMySelfHostOrCoHost())
            ? Text(
                '（${NEMeetingUIKitLocalizations.of(context)!.chatMessageSendToWaitingRoom}）',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: _UIColors.color_999999, fontSize: 12),
              )
            : null,
      );
    }
    return null;
  }

  Widget buildImageContent(ImageMessageState message, bool isRight) {
    final child = _ImageContent(
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
            onRecalledDismiss: () => showRecallDialog(),
          );
        }));
      },
      onImageError: (msg) {
        // remove origin file
        File(msg.thumbPath).delete();
      },
    );
    return ChatMenuWidget(
        onValueChanged: (value) {
          switch (value) {
            case 1:
              recallMessage(message);
              break;
          }
        },
        child: child,
        isRight: isRight,
        canShow: () => isRight && message.msgId != null,
        onShow: () => actionMenuShowing = true,
        willShow: () {
          if (_focusNode.hasFocus) {
            _focusNode.unfocus();
          }
        },
        onDismiss: () => actionMenuShowing = false,
        actions: [NEMeetingUIKitLocalizations.of(context)!.chatRecall]);
  }

  Widget buildFileContent(FileMessageState message, bool isRight) {
    final fileContent = _FileContent(
      message: message,
      onTap: (msg) => _handleFileMessageClick(message),
    );
    return _roomArchiveId != null
        ? fileContent
        : ChatMenuWidget(
            onValueChanged: (value) {
              switch (value) {
                case 1:
                  recallMessage(message);
                  break;
              }
            },
            child: fileContent,
            isRight: isRight,
            willShow: () {
              if (_focusNode.hasFocus) {
                _focusNode.unfocus();
              }
            },
            canShow: () => isRight && message.msgId != null,
            actions: [NEMeetingUIKitLocalizations.of(context)!.chatRecall]);
  }

  Widget buildNotifyContent(NotificationMessageState message) {
    String name = "";
    if (_arguments.roomContext?.localMember.uuid == message.operator ||
        NEMeetingKit.instance.getAccountService().getAccountInfo()?.userUuid ==
            message.operator) {
      name = NEMeetingUIKitLocalizations.of(context)!.chatYou;
    } else {
      final member = _arguments.roomContext?.getMember(message.operator);
      name = "\u201C${member?.name ?? message.nickname}\u201D";
    }

    return Container(
      height: 18,
      margin: EdgeInsets.symmetric(vertical: 15),
      padding: EdgeInsets.symmetric(horizontal: 46),
      child: Text(
        "$name${NEMeetingUIKitLocalizations.of(context)!.chatRecallAMessage}",
        style: TextStyle(color: _UIColors.color_999999, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _handleFileMessageClick(FileMessageState message) async {
    if (_roomArchiveId != null) return;
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

  void _realOpenFile(String filePath, String name) async {
    OpenResult? result;
    ResultType? resultType;
    String? error;
    try {
      /// 如果path文件是个不带后缀名的文件，且name带文件后缀，则拼接上name的后缀名
      final extension = path.extension(name);
      if (path.extension(filePath).isEmpty && extension.isNotEmpty) {
        final filePathWithExtension = '$filePath$extension';
        if (await File(filePath).exists() &&
            !(await File(filePathWithExtension).exists())) {
          await File(filePath).rename(filePathWithExtension);
        }
        filePath = filePathWithExtension;
      }
      String? mime;
      // cannot determine mime type from path, try to get from name
      if (FileTypeUtils.getMimeType(filePath) == '*/*') {
        mime = FileTypeUtils.getMimeType(name);
      }
      result = await OpenFilex.open(filePath, type: mime);
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
      content: "open file result: $filePath $resultType $error",
    );
    if (!mounted) return;
    if (resultType == ResultType.noAppToOpen) {
      showToast(
          NEMeetingUIKitLocalizations.of(context)!.chatOpenFileFailAppNotFound);
    } else if (resultType == ResultType.fileNotFound) {
      showToast(
        NEMeetingUIKitLocalizations.of(context)!.chatOpenFileFailFileNotFound,
      );
    } else if (resultType == ResultType.permissionDenied) {
      showToast(NEMeetingUIKitLocalizations.of(context)!
          .chatOpenFileFailNoPermission);
    } else if (resultType == ResultType.error) {
      showToast(NEMeetingUIKitLocalizations.of(context)!.chatOpenFileFail);
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

  Widget buildTextContent(BuildContext context, String content, bool isRight,
      TextMessageState message) {
    final child = Container(
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
    );
    return Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: _roomArchiveId != null
            ? child
            : ChatMenuWidget(
                onValueChanged: (value) {
                  switch (value) {
                    case 1:
                      Clipboard.setData(ClipboardData(text: content));
                      break;
                    case 2:
                      recallMessage(message);
                      break;
                  }
                },
                child: child,
                isRight: isRight,
                canShow: () => message.msgId != null,
                willShow: () {
                  if (_focusNode.hasFocus) {
                    _focusNode.unfocus();
                  }
                },
                onShow: () => actionMenuShowing = true,
                onDismiss: () => actionMenuShowing = false,
                actions: [
                    NEMeetingUIKitLocalizations.of(context)!.globalCopy,
                    if (isRight)
                      NEMeetingUIKitLocalizations.of(context)!.chatRecall
                  ]));
  }

  void _onSelectImage() {
    _selectFile(SelectType.image, _kSupportedImageFileExtensions,
        _kSupportedImageFileMaxSize);
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }

  void _onSelectFile() {
    _selectFile(SelectType.file, _kSupportedRawFileExtensions,
        _kSupportedRawFileMaxSize);
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }

  void _selectFile(
      SelectType type, Set<String> supportedExtensions, int maxFileSize) {
    if (_selectingType != SelectType.none) {
      return;
    }
    _selectingType = type;

    final beforeType = _selectedChatroomType.value;
    FilePicker.platform
        .pickFiles(
      type:
          _selectingType == SelectType.image ? FileType.image : FileType.custom,
      allowedExtensions: _selectingType == SelectType.image
          ? null
          : supportedExtensions.toList(growable: false),
    )
        .then((value) {
      /// 如果在选择文件的过程中，取消了联席主持人
      if (beforeType != _selectedChatroomType.value) {
        return;
      }

      /// 选择文件过程中，被移到等候室不发送
      if (_arguments.roomContext?.isInWaitingRoom() == true) {
        return;
      }

      _onFileSelected(
        value?.files.first,
        supportedExtensions,
        maxFileSize,
        type == SelectType.image
            ? NEMeetingUIKitLocalizations.of(context)!
                .chatImageSizeExceedTheLimit
            : NEMeetingUIKitLocalizations.of(context)!
                .chatFileSizeExceedTheLimit,
      );
    }).whenComplete(() => _selectingType = SelectType.none);
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
          errorMsg = NEMeetingUIKitLocalizations.of(context)!
              .chatUnsupportedFileExtension;
        } else if (size > maxFileSize) {
          errorMsg = sizeExceedErrorMsg;
        }
        if (errorMsg != null && !_isMinimized) {
          ToastUtils.showToast(context, errorMsg);
          file.delete();
          return;
        }

        Object? message;
        if (_selectingType == SelectType.image) {
          message = OutImageMessage(
              _myNickname, _myAvatar, path, size, _selectedChatroomType.value);
        } else if (_selectingType == SelectType.file) {
          message = OutFileMessage(_myNickname, _myAvatar, name, path, size,
              extension, _selectedChatroomType.value);
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
        await _arguments.messageSource.ensureChatroomJoined();
        if (message is OutImageMessage) {
          message.startSend(chatController.sendImageMessage(
            message.uuid,
            message.path,
            null,
            chatroomType: message.chatroomType,
          ));
        } else if (message is OutFileMessage) {
          message.startSend(chatController.sendFileMessage(
            message.uuid,
            message.path,
            null,
            chatroomType: message.chatroomType,
          ));
        } else if (message is OutTextMessage) {
          message.startSend(chatController.sendBroadcastTextMessage(
            message.text,
            chatroomType: message.chatroomType,
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
      showToast(NEMeetingKitLocalizations.of(context)!.networkUnavailableCheck);
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
    EventBus().unsubscribe(RecallMessageNotify, _eventCallback);
    super.dispose();
  }
}

class _MessageItem extends StatelessWidget {
  final bool incoming;
  final MessageState message;
  final void Function(MessageState)? onRetry;
  final bool shouldShowRetry;
  final Widget? sendTo;
  final WidgetBuilder contentBuilder;

  bool get outgoing => !incoming;

  const _MessageItem({
    Key? key,
    required this.incoming,
    required this.message,
    required this.contentBuilder,
    this.shouldShowRetry = true,
    this.onRetry,
    this.sendTo,
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
    final head = NEMeetingAvatar.small(
      name: message.nickname,
      url: message.avatar,
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (sendTo != null && outgoing) sendTo!,
                        nickname,
                        if (sendTo != null && incoming) sendTo!,
                      ],
                    ),
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
    final _size = calculateImageSampleSize(
        context, widget.message.width ?? 100, widget.message.height ?? 100);
    final child = ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: Hero(
          tag: widget.message.uuid,
          child: widget.message.url == null
              ? Image.file(
                  File(widget.message.thumbPath),
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
                  frameBuilder: (BuildContext context, Widget? child,
                      int? frame, bool? wasSynchronouslyLoaded) {
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
                )
              : MeetingCachedNetworkImage.CachedNetworkImage(
                  imageUrl: widget.message.url!,
                  height: _size.height,
                  width: _size.width,
                  placeholder: (context, url) => buildPreviewImage(
                      context,
                      widget.message.width ?? 100,
                      widget.message.height ?? 100),
                  errorWidget: (context, url, error) => Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 30,
                          color: const Color(0xFF656A72),
                        ),
                      ),
                  imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  fit: BoxFit.cover),
        ));
    return GestureDetector(
        onTap: () => widget.onTap?.call(widget.message),
        child: _size.height == null
            ? IntrinsicHeight(
                child: child,
              )
            : child);
  }

  Widget buildPreviewImage(BuildContext context, int width, int height) {
    final _size = calculateImageSampleSize(context, width, height);
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      child: SizedBox(
        width: _size.width,
        height: _size.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 占位
            Container(
              width: _size.width,
              height: _size.height,
              color: _UIColors.colorF2F3F5,
            ),
            // ),
            if (widget.message.isHistory)
              ValueListenableBuilder(
                valueListenable: (widget.message as InImageMessage)
                    .attachmentDownloadProgress,
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
              )
          ],
        ),
      ),
    );
  }
}

ChatImageSize calculateImageSampleSize(
    BuildContext context, int width, int height) {
  final w = MediaQuery.of(context).size.width;
  final h = MediaQuery.of(context).size.height;
  double maxWidth = min(w, h) / 2;
  double maxHeight = max(w, h) / 3;
  final ChatImageSize output;
  if (width > 0 && height > 0) {
    if (maxWidth >= width && maxHeight >= height) {
      output = ChatImageSize(width.toDouble(), height.toDouble());
    } else {
      final double ratio = min(maxWidth / width, maxHeight / height);
      output = ChatImageSize(width * ratio, height * ratio);
    }
  } else {
    output = ChatImageSize(maxWidth, null);
  }
  assert(() {
    print(
        'calculateImageSampleSize: input=($width, $height), constraint=($w, $h, $maxWidth, $maxHeight), output=$output');
    return true;
  }());
  return output;
}

class ChatImageSize {
  final double width;
  final double? height;

  const ChatImageSize(this.width, this.height);

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
  const _FileContent({Key? key, required this.message, this.onTap})
      : super(key: key);

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

Widget _buildCircularProgressIndicator(double viewSize, double? value) {
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

enum _ChatTargetSheetIDs {
  allMembersInMeeting,
  allMembersInWaitingRoom,
  cancel,
}
