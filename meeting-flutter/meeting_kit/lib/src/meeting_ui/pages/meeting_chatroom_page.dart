// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingChatRoomPage extends StatefulWidget {
  static const String routeName = "/meetingChatRoom";
  final ChatRoomArguments arguments;
  final String? roomArchiveId;
  final TextEditingController? editController;

  MeetingChatRoomPage(
      {required this.arguments, this.roomArchiveId, this.editController});

  @override
  State<StatefulWidget> createState() {
    return MeetingChatRoomState(arguments, roomArchiveId);
  }
}

class MeetingChatRoomState extends LifecycleBaseState<MeetingChatRoomPage>
    with
        MeetingStateScope,
        MeetingKitLocalizationsMixin,
        EventTrackMixin,
        FirstBuildScope {
  final ChatRoomArguments _arguments;
  bool _isInHistoryPage = false;

  final _emailSpanBuilder = MeetingTextSpanBuilder();

  double _keyboardHeight = 0;
  double _preKeyboardHeight = 0;
  double _currentViewInsetsBottom = 0;
  final activeEmojiGird = ValueNotifier(false);
  double emojisPanelPaddingBottom = 0;

  final GlobalKey<ExtendedTextFieldState> _textFieldKey =
      GlobalKey<ExtendedTextFieldState>();
  final StreamController<void> _emojiPanelBuilderController =
      StreamController<void>.broadcast();

  MeetingChatRoomState(this._arguments, String? roomArchiveId) {
    _isInHistoryPage = roomArchiveId != null;
  }

  late int _initialScrollIndex;
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
    return roomContext?.localMember.name ??
        AccountRepository().getAccountInfo()?.nickname ??
        '';
  }

  String? get _myAvatar {
    return roomContext?.localMember.avatar ??
        AccountRepository().getAccountInfo()?.avatar;
  }

  bool disableScrollToBottom = false;
  ValueNotifier<bool> isAlwaysScrollable = ValueNotifier(true);
  late EventCallback _eventCallback;
  int nextPullMessageTime = 0;
  bool isShowLoading = false;
  late final roomContext = _arguments.roomContext;
  late final chatRoomManager = _arguments.chatRoomManager;
  late final NERoomEventCallback roomEventCallback;
  String? avatarClickActionShowUuid;

  @override
  void initState() {
    super.initState();
    _arguments.messageSource.unread = 0;
    assert(() {
      debugInvertOversizedImages = true;
      debugImageOverheadAllowance = 10 * 1024 * 1024; // 10M
      return true;
    }());
    if (roomContext != null) {
      chatController = roomContext!.chatController;
      roomContext!.addEventCallback(roomEventCallback = NERoomEventCallback(
        memberRoleChanged: memberRoleChanged,
        memberLeaveRoom: memberLeaveRoom,
      ));
    }
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

    _eventCallback = (arg) {
      disableScrollToBottom = true;
      if ((arg as ChatRecallMessage).operateBy !=
              roomContext?.localMember.uuid ||
          AccountRepository().getAccountInfo()?.userUuid == (arg).operateBy) {
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
    if (_isInHistoryPage) {
      pullMessagesNotInMeeting(isFirst: true);
    } else {
      EventBus().subscribe(RecallMessageNotify, _eventCallback);
    }
  }

  void memberRoleChanged(
      NERoomMember member, NERoomRole oldRole, NERoomRole newRole) {
    /// 如果自己的身份变更，刷新界面
    if (roomContext!.isMySelf(member.uuid)) {
      setState(() {});
    }
  }

  void memberLeaveRoom(List<NERoomMember> members) {
    /// 如果点击头像弹窗时，该用户离开房间，则关闭弹窗
    if (members.any((element) => avatarClickActionShowUuid == element.uuid)) {
      Navigator.of(context)
          .popUntil(ModalRoute.withName(MeetingChatRoomPage.routeName));
    }
  }

  void showRecallDialog() {
    DialogUtils.showOneButtonCommonDialog(
        context, meetingUiLocalizations.chatMessageRecalled,
        acceptText: meetingUiLocalizations.globalSure);
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
    _currentViewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    final bool showingKeyboard = _currentViewInsetsBottom > _preKeyboardHeight;
    _preKeyboardHeight = _currentViewInsetsBottom;
    if ((_currentViewInsetsBottom > 0 &&
            _currentViewInsetsBottom >= _keyboardHeight) ||
        showingKeyboard) {
      activeEmojiGird.value = false;
      _emojiPanelBuilderController.add(null);
    }

    _keyboardHeight = max(_keyboardHeight, _currentViewInsetsBottom);

    final double appBarHeight = AppBar().preferredSize.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return PopScopeBuilder<FocusNode>(
      listenable: _focusNode,
      canPopGetter: (focusNode) => !focusNode.hasFocus,
      onInterceptPop: () => _focusNode.unfocus(),
      onDidPop: () {
        if (_focusNode.hasFocus) _focusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: _UIColors.colorF6F6F6,
        appBar: buildAppBar(context),
        resizeToAvoidBottomInset: false,
        //body: SafeArea(top: false, left: false, right: false, child: buildBody()),
        body: _isInHistoryPage && !isShowLoading && _arguments.msgSize <= 0
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
                        meetingUiLocalizations.chatNoChatHistory,
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
    );
  }

  PreferredSizeWidget buildAppBar(BuildContext context) {
    return TitleBar(
      title: TitleBarTitle(
        _isInHistoryPage
            ? meetingUiLocalizations.chatHistory
            : meetingUiLocalizations.chat,
      ),
      showBottomDivider: true,
      // systemOverlayStyle: AppStyle.systemUiOverlayStyleDark,
      leading: roomContext?.isMySelfHostOrCoHost() == true &&
              _arguments.waitingRoomManager != null
          ? GestureDetector(
              onTap: () {
                if (_focusNode.hasFocus) {
                  _focusNode.unfocus();
                }
                showMeetingPopupPageRoute(
                    context: context,
                    routeSettings: RouteSettings(
                        name: MeetingChatPermissionPage.routeName),
                    builder: (context) {
                      return MeetingChatPermissionPage(
                        roomContext!,
                        _arguments.waitingRoomManager!,
                      );
                    });
              },
              child: Container(
                width: 48,
                height: 48,
                child: Icon(
                  NEMeetingIconFont.icon_chat_setting,
                  size: 24,
                  color: _UIColors.color656A72,
                ),
              ),
            )
          : null,
    );
  }

  Widget newMessageTips() {
    var bottom = 90.0;
    if (activeEmojiGird.value) {
      bottom += emojisPanelHeight;
    }
    return SafeArea(
        left: false,
        top: false,
        right: false,
        child: GestureDetector(
            onTap: () {
              _scrollToIndex(_arguments.msgSize - 1);
            },
            child: Container(
                margin: EdgeInsets.only(bottom: bottom),
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
                    Icon(Icons.arrow_downward, size: 16, color: Colors.white),
                    Text(
                      meetingUiLocalizations.chatNewMessage,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    )
                  ],
                ))));
  }

  Widget buildBody() {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          buildListView(),
          if (!_isInHistoryPage)
            buildInputPanel()
          else
            SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  MessageState? convertMessage(NERoomChatMessage msg,
      {bool isRoomOutHistory = false}) {
    var valid = false;
    InMessageState? message;
    if (msg is NERoomChatTextMessage && msg.text.isNotEmpty) {
      message = InTextMessage(
          msg.messageUuid,
          msg.time,
          msg.fromNick,
          msg.fromAvatar,
          msg.text,
          msg.messageUuid,
          msg.toUserUuidList,
          msg.fromUserUuid,
          msg.chatroomType);
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
          msg.toUserUuidList,
          msg.fromUserUuid,
          msg.chatroomType,
        );
        if (!_isInHistoryPage) {
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
          msg.toUserUuidList,
          msg.fromUserUuid,
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
          msg.operateBy?.uuid,
          msg.recalledMessageId,
          msg.toUserUuidList,
          msg.fromUserUuid,
          msg.chatroomType);
    }
    if (msg.fromUserUuid == roomContext?.localMember.uuid ||
        AccountRepository().getAccountInfo()?.userUuid == msg.fromUserUuid) {
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
                  onRefresh: () async => _isInHistoryPage
                      ? pullMessagesNotInMeeting()
                      : pullMessages(),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isAlwaysScrollable,
                    builder: (BuildContext context, bool value, _) {
                      return _isInHistoryPage && _initialScrollIndex == 0
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
                                    !_isInHistoryPage) {
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
                  meetingUiLocalizations.chatAboveIsHistoryMessage,
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

  Widget buildSendTo() {
    if (chatRoomManager == null) return SizedBox();
    final sendToTarget = _arguments.chatRoomManager!.sendToTarget;
    String header = meetingUiLocalizations.chatSendTo;
    String targetName = '';
    String? targetRole;
    Widget? icon;
    Widget allMembersIcon = Icon(
      NEMeetingIconFont.icon_all_members_16,
      size: 16,
      color: _UIColors.color656A72,
    );
    if (sendToTarget.value != null) {
      switch (sendToTarget.value) {
        case NEChatroomType.common:
          targetName = meetingUiLocalizations.chatAllMembersInMeeting;
          icon = allMembersIcon;
          break;
        case NEChatroomType.waitingRoom:
          targetName = meetingUiLocalizations.chatAllMembersInWaitingRoom;
          icon = allMembersIcon;
          break;
        default:
          final targetMember = sendToTarget.value as NEBaseRoomMember;
          targetName = targetMember.name;
          targetRole = getTargetRole(targetMember);
          header = meetingUiLocalizations.chatPrivate;

          /// 主持人私聊等候室成员
          if (roomContext?.isMySelfHostOrCoHost() == true &&
              chatRoomType == NEChatroomType.waitingRoom) {
            header = meetingUiLocalizations.chatPrivateInWaitingRoom;
          }
          icon = ValueListenableBuilder(
            valueListenable: _arguments.hideAvatar ?? ValueNotifier(false),
            builder: (context, hideAvatar, child) {
              return NEMeetingAvatar.xSmall(
                name: targetMember.name,
                url: targetMember.avatar,
                hideImageAvatar: hideAvatar,
              );
            },
          );
          break;
      }
    }
    final tipTextStyle = TextStyle(
      color: _UIColors.color_999999,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.none,
    );
    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
              child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _showSelectTargetDialog,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$header:',
                  style: TextStyle(
                    color: _UIColors.color_666666,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) icon,
                    SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 136),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                              child: Text(
                            targetName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _UIColors.color_333333,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.none,
                            ),
                          )),
                          if (targetRole != null)
                            Text(
                              targetRole,
                              style: tipTextStyle,
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      NEMeetingIconFont.icon_arrow_down,
                      size: 14,
                      color: _UIColors.color_999999,
                    ),
                  ],
                )
              ],
            ),
          )),
          StreamBuilder(
              stream: chatRoomManager?.chatPermissionChanged,
              builder: (context, snapshot) {
                return Text(
                  getChatPermissionTip(),
                  style: tipTextStyle,
                );
              }),
        ],
      ),
    );
  }

  String? getTargetRole(NEBaseRoomMember user) {
    if (roomContext == null) return null;
    var roles = <String>[];
    String? role;
    if (user is NERoomMember) {
      role = user.role.name;
    } else if (user is NEWaitingRoomHost) {
      role = user.role;
    }
    switch (role) {
      case MeetingRoles.kHost:
        roles.add(meetingUiLocalizations.participantHost);
      case MeetingRoles.kCohost:
        roles.add(meetingUiLocalizations.participantCoHost);
    }
    return roles.isNotEmpty ? '(${roles.join(',')})' : null;
  }

  String getChatPermissionTip() {
    if (roomContext == null ||
        roomContext!.isInWaitingRoom() ||
        roomContext!.isMySelfHostOrCoHost()) return '';
    switch (roomContext!.chatPermission) {
      case NEChatPermission.publicChatOnly:
        return meetingUiLocalizations.chatPublicOnly;
      case NEChatPermission.privateChatHostOnly:
        return meetingUiLocalizations.chatPrivateHostOnly;
      default:
        return '';
    }
  }

  Widget buildInputPanel() {
    return ValueListenableBuilder(
        valueListenable: _arguments.chatRoomManager!.sendToTarget,
        builder: (context, value, child) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    offset: Offset(0, -0.5),
                    blurRadius: 0.5,
                    color: _UIColors.colorE1E3E6)
              ],
            ),
            child: buildChatRoomBottom(value),
          );
        });
  }

  double get emojisPanelHeight {
    final isPortrait =
        MediaQuery.of(context).size.width < MediaQuery.of(context).size.height;
    return isPortrait ? 205.0 : 115.0;
  }

  void initEmojisPanelPaddingBottom() {
    var paddingBottom = MediaQuery.of(context).padding.bottom;
    final isPortrait =
        MediaQuery.of(context).size.width < MediaQuery.of(context).size.height;
    final defaultPaddingBottom = isPortrait ? 32.0 : 18.0;
    emojisPanelPaddingBottom = paddingBottom > defaultPaddingBottom
        ? paddingBottom
        : defaultPaddingBottom;
  }

  @override
  void onFirstBuild() {
    super.onFirstBuild();
    initEmojisPanelPaddingBottom();
  }

  void onEmojiActiveChanged() {
    activeEmojiGird.value = !activeEmojiGird.value;
    if (activeEmojiGird.value) {
      // make sure grid height = keyboardHeight
      _keyboardHeight = _currentViewInsetsBottom;
      SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    } else {
      _keyboardHeight = 0;
      SystemChannels.textInput.invokeMethod<void>('TextInput.show');
      _focusNode.requestFocus();
    }
    _emojiPanelBuilderController.add(null);
  }

  Widget buildChatRoomBottom(dynamic sendTarget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        /// 如果有发送目标，则显示`发送至`
        if (sendTarget != null) ...[
          SizedBox(height: 4),
          buildSendTo(),
          SizedBox(height: 4),
        ],
        if (sendTarget == null)
          buildMutedTips()
        else
          Padding(
            padding: EdgeInsets.only(left: 12, right: 12, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (_arguments.isImageMessageEnabled)
                  buildIcon(NEMeetingIconFont.icon_image_open, _onSelectImage),
                if (_arguments.isImageMessageEnabled) SizedBox(width: 12),
                if (_arguments.isFileMessageEnabled)
                  buildIcon(NEMeetingIconFont.icon_folder_open, _onSelectFile),
                if (_arguments.isFileMessageEnabled) SizedBox(width: 12),
                buildInputBox(),
                SizedBox(width: 12),
                ValueListenableBuilder(
                    valueListenable: activeEmojiGird,
                    builder: (context, value, child) {
                      return buildIcon(
                          value
                              ? NEMeetingIconFont.icon_keyboard_open
                              : NEMeetingIconFont.icon_emoji_open,
                          onEmojiActiveChanged);
                    }),
              ],
            ),
          ),

        if (sendTarget != null)
          StreamBuilder<void>(
            stream: _emojiPanelBuilderController.stream,
            builder: (BuildContext b, AsyncSnapshot<void> d) {
              double? height =
                  _keyboardHeight - MediaQuery.of(context).padding.bottom;
              if (height <= 0) height = null;
              return SizedBox(
                  height: activeEmojiGird.value
                      ? null
                      : MediaQuery.of(context).padding.bottom,
                  child: activeEmojiGird.value
                      ? EmojisPanel(
                          textFieldKey: _textFieldKey,
                          controller: widget.editController!,
                          sendAction: onSendMessage,
                          height: emojisPanelHeight,
                          paddingBottom: emojisPanelPaddingBottom,
                        )
                      : SizedBox(
                          height: MediaQuery.of(context).padding.bottom));
            },
          ),

        if (sendTarget != null)
          StreamBuilder<void>(
            stream: _emojiPanelBuilderController.stream,
            builder: (BuildContext b, AsyncSnapshot<void> d) {
              return Container(
                height: activeEmojiGird.value ? 0 : _currentViewInsetsBottom,
              );
            },
          ),
      ],
    );
  }

  /// 输入框禁止状态
  Widget buildMutedTips() {
    bool isInWaitingRoom = roomContext?.isInWaitingRoom() == true;

    /// 主持人禁言所有人
    String tips = isInWaitingRoom
        ? meetingUiLocalizations.chatWaitingRoomMuted
        : meetingUiLocalizations.chatHostMutedEveryone;

    /// 仅私聊主持人，且主持人全部离开
    if ((isInWaitingRoom &&
            roomContext?.waitingRoomChatPermission ==
                NEWaitingRoomChatPermission.privateChatHostOnly) ||
        (!isInWaitingRoom &&
            roomContext?.chatPermission ==
                NEChatPermission.privateChatHostOnly)) {
      tips = meetingUiLocalizations.chatHostLeft;
    }
    final paddingBottom = MediaQuery.of(context).padding.bottom;
    return Container(
      height: 60 + paddingBottom,
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 12, right: 12, bottom: paddingBottom),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            NEMeetingIconFont.icon_chat_muted,
            size: 20,
            color: _UIColors.color_999999,
          ),
          SizedBox(width: 4),
          Flexible(
              child: Text(
            tips,
            style: TextStyle(
              color: _UIColors.color_999999,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none,
            ),
          )),
        ],
      ),
    );
  }

  /// 是否已经显示选择发送目标的弹窗
  bool _isShowSelectTargetDialog = false;

  Future<void> _showSelectTargetDialog() async {
    if (roomContext == null || _isShowSelectTargetDialog) return;
    _isShowSelectTargetDialog = true;

    /// 点击刷新主持人信息
    _arguments.waitingRoomManager?.tryLoadHostAndCoHost();
    await showMeetingPopupPageRoute(
      context: context,
      builder: (context) => MeetingChatRoomMemberPage(
        roomContext!,
        _arguments.waitingRoomManager,
        _arguments.chatRoomManager!,
        _arguments.roomInfoUpdatedEventStream,
        _arguments.hideAvatar ?? ValueNotifier(false),
      ),
      routeSettings: RouteSettings(name: 'MeetingSelectChatMemberPage'),
    );
    _isShowSelectTargetDialog = false;
  }

  Widget buildIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: 24,
        color: const Color(0xFF656A72),
      ),
    );
  }

  Widget buildInputBox() {
    return Expanded(
        child: Container(
      decoration: BoxDecoration(
          color: _UIColors.colorF7F8FA,
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border.all(width: 1, color: _UIColors.colorF2F3F5)),
      constraints: BoxConstraints(minHeight: 40),
      alignment: Alignment.center,
      child: ExtendedTextField(
          key: _textFieldKey,
          minLines: 1,
          maxLines: 3,
          focusNode: _focusNode,
          controller: widget.editController,
          specialTextSpanBuilder: _emailSpanBuilder,
          cursorColor: _UIColors.blue_337eff,
          keyboardAppearance: Brightness.light,
          textAlignVertical: TextAlignVertical.center,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.send,
          onEditingComplete: () {
            widget.editController?.clearComposing();
          },
          //this forbid the keyboard to dismiss
          onSubmitted: (_) => onSendMessage(),
          decoration: InputDecoration(
            filled: true,
            isDense: true,
            fillColor: Colors.transparent,
            hintText: meetingUiLocalizations.chatInputMessageHint,
            hintStyle: TextStyle(
                fontSize: 14,
                color: _UIColors.color_999999,
                decoration: TextDecoration.none),
            border: InputBorder.none,
          )),
    ));
  }

  /// 获取当前发消息所处的房间类型
  NEChatroomType get chatRoomType {
    if (chatRoomManager == null) return NEChatroomType.common;
    if (chatRoomManager!.sendToTarget.value is NEBaseRoomMember) {
      return roomContext?.isInWaitingRoom() == true ||
              chatRoomManager!.sendToTarget.value is NEWaitingRoomMember
          ? NEChatroomType.waitingRoom
          : NEChatroomType.common;
    }
    return chatRoomManager!.sendToTarget.value;
  }

  List<String>? get toUserUuidList {
    if (chatRoomManager == null) return null;
    if (chatRoomManager!.sendToTarget.value is NEBaseRoomMember) {
      final targetMember =
          chatRoomManager!.sendToTarget.value as NEBaseRoomMember;
      return [targetMember.uuid];
    }
    return null;
  }

  List<String>? get toUserNicknameList {
    if (chatRoomManager == null) return null;
    if (chatRoomManager!.sendToTarget.value is NEBaseRoomMember) {
      final targetMember =
          chatRoomManager!.sendToTarget.value as NEBaseRoomMember;
      return [targetMember.name];
    }
    return null;
  }

  /// send message
  void onSendMessage() async {
    if (sending) {
      // avoid duplicate send may be show loading
      return;
    }
    sending = true;
    final content = widget.editController!.text;
    if (content.isBlank) {
      showToast(meetingUiLocalizations.chatCannotSendBlankLetter);
    } else if (await _realSendMessage(OutTextMessage(_myNickname, _myAvatar,
        content, toUserUuidList, toUserNicknameList, chatRoomType))) {
      widget.editController!.clear();
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
    return roomContext?.isMySelfHost() == true ||
        roomContext?.isMySelfCoHost() == true;
  }

  void pullMessages() async {
    if (await _hasNetworkOrToast() == false) return;

    final messages = <MessageState>[];
    final commonMessagesFuture = roomContext?.isInWaitingRoom() == false
        ? fetchChatroomHistoryMessages(NEChatroomType.common)
        : Future.value(<MessageState>[]);
    final waitingRoomMessagesFuture =
        roomContext?.isInWaitingRoom() == true || _isMySelfHostOrCoHost()
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
      var msg = result.msg;

      /// 聊天室历史记录历史功能未开启
      if (result.code == 403) {
        msg = meetingUiLocalizations.chatHistoryNotEnabled;
      }
      if (msg != null) showToast(msg);
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

    final result = await MeetingRepository()
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
        hideAvatar: _arguments.hideAvatar ?? ValueNotifier(false),
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
            return _isInHistoryPage
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
        messageFrom: buildMessageFrom(message),
        messageType: buildMessageType(message),
        avatarOnTap: () =>
            message is InMessageState && message.fromUserUuid != null
                ? handleAvatarClick(message.fromUserUuid!, message.nickname)
                : null,
      );
    }
    return null;
  }

  void handleAvatarClick(String userUuid, String nickName) {
    if (getAvatarActions(userUuid, nickName).isEmpty) return;
    avatarClickActionShowUuid = userUuid;
    DialogUtils.showChildNavigatorPopup<_AvatarActionData>(
      context,
      (context) {
        return StreamBuilder(
          stream: _arguments.roomInfoUpdatedEventStream,
          builder: (context, _) {
            final actions = getAvatarActions(userUuid, nickName);
            final child = CupertinoActionSheet(
              title: Text(
                nickName,
                style: TextStyle(color: _UIColors.grey_8F8F8F, fontSize: 13),
              ),
              actions: actions,
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: buildSheetText(meetingUiLocalizations.globalCancel,
                    _UIColors.color_007AFF),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            );
            return AutoPopScope(
              child: child,
              listenable: ValueNotifier(actions.isEmpty),
            );
          },
        );
      },
    ).then<void>((_AvatarActionData? value) async {
      if (value != null && value.action.index != -1) {
        await handleAction(value.action, value.userUuid, value.nickName);
      }
      avatarClickActionShowUuid = null;
    });
  }

  Future<void> handleAction(
      _AvatarActionType action, String userUuid, String nickName) async {
    /// 参会者已离开会议
    if (_getMember(userUuid) == null) {
      showToast(meetingUiLocalizations.chatMemberLeft);
      return;
    }
    switch (action) {
      case _AvatarActionType.chatPrivate:
        switchToChatPrivate(userUuid);
        break;
      case _AvatarActionType.remove:
        if (_getMember(userUuid) is NERoomMember) {
          await removeMember(userUuid, nickName);
        } else {
          await expelMember(userUuid, nickName);
        }
        break;
    }
    avatarClickActionShowUuid = null;
  }

  /// 移除等候室成员
  Future<void> expelMember(String userUuid, String nickName) async {
    if (_arguments.waitingRoomManager == null) return;
    final isRoomBlackListEnabled =
        _arguments.waitingRoomManager!.roomContext.isRoomBlackListEnabled;
    final result = await showConfirmDialogWithCheckbox(
      title: meetingUiLocalizations.waitingRoomExpelWaitingMember,
      message: meetingUiLocalizations.participantRemoveConfirm + '$nickName?',
      checkboxMessage: isRoomBlackListEnabled
          ? meetingUiLocalizations.participantDisallowMemberRejoinMeeting
          : null,
      cancelLabel: meetingUiLocalizations.globalCancel,
      okLabel: meetingUiLocalizations.participantRemove,
    );
    if (!mounted || result == null) return;
    _arguments.waitingRoomManager
        ?.expelMember(userUuid, disallowRejoin: result.checked);
  }

  /// 移除会中成员
  Future<void> removeMember(String userUuid, String nickName) async {
    trackPeriodicEvent(TrackEventName.removeMember,
        extra: {'member_uid': userUuid});

    final result = await showConfirmDialogWithCheckbox(
      title: meetingUiLocalizations.participantRemoveConfirm + '$nickName?',
      checkboxMessage: roomContext?.isRoomBlackListEnabled == true
          ? meetingUiLocalizations.meetingNotAllowedToRejoin
          : null,
      initialChecked: false,
      cancelLabel: meetingUiLocalizations.globalCancel,
      okLabel: meetingUiLocalizations.globalSure,
    );
    if (!mounted || result == null) return;
    removeMember2Server(userUuid, result.checked);
  }

  void removeMember2Server(String userUuid, bool toBlacklist) {
    lifecycleExecute(roomContext!.kickMemberOut(userUuid, toBlacklist))
        .then((NEResult? result) {
      if (mounted && result != null && !result.isSuccess()) {
        showToast(
          result.msg ?? meetingUiLocalizations.participantFailedToRemove,
        );
      }
    });
  }

  void switchToChatPrivate(String userUuid) {
    final member = _getChatMember(userUuid);
    final waitingRoomMember = _arguments.waitingRoomManager?.userList
        .where((element) => element.uuid == userUuid)
        .firstOrNull;
    if (member != null) {
      _arguments.chatRoomManager
          ?.updateSendTarget(newTarget: member, userSelected: true);
    } else if (waitingRoomMember != null) {
      _arguments.chatRoomManager
          ?.updateSendTarget(newTarget: waitingRoomMember, userSelected: true);
    }
  }

  /// 获取点击头像的菜单项
  List<Widget> getAvatarActions(String userUuid, String nickName) {
    /// 等候室成员，点击管理员才显示私聊菜单
    if (roomContext!.isInWaitingRoom()) {
      if (chatRoomManager?.hostAndCoHost
                  .where((e) => e.uuid == userUuid)
                  .isNotEmpty ==
              true &&
          roomContext!.waitingRoomChatPermission ==
              NEWaitingRoomChatPermission.privateChatHostOnly) {
        return [
          buildActionSheet(meetingUiLocalizations.chatPrivate, userUuid,
              nickName, _AvatarActionType.chatPrivate),
        ];
      }
      return [];
    }

    final actionMember = _getMember(userUuid);
    if (roomContext == null) {
      return [];
    }

    final isUserHostOrCoHost = roomContext!.isHostOrCoHost(userUuid);
    final isSelfHostOrCoHost = roomContext!.isMySelfHostOrCoHost();
    final isUserHost = roomContext!.isHost(userUuid);

    /// 会中成员和管理员
    bool chatPrivate = false;
    switch (roomContext!.chatPermission) {
      case NEChatPermission.freeChat:
        chatPrivate = true;
        break;
      case NEChatPermission.publicChatOnly:
      case NEChatPermission.privateChatHostOnly:
        chatPrivate = isUserHostOrCoHost;
        break;
      case NEChatPermission.noChat:
        break;
    }
    if (isSelfHostOrCoHost) {
      chatPrivate = true;
    }

    return <Widget>[
      if (chatPrivate)
        buildActionSheet(
          meetingUiLocalizations.chatPrivate,
          userUuid,
          nickName,
          _AvatarActionType.chatPrivate,
          color: actionMember == null ? _UIColors.color_999999 : null,
        ),
      if (isSelfHostOrCoHost && !isUserHost && actionMember != null)
        buildActionSheet(
          meetingUiLocalizations.participantRemove,
          userUuid,
          nickName,
          _AvatarActionType.remove,
          color: _UIColors.colorF24957,
        ),
    ];
  }

  Widget buildActionSheet(String text, String userUuid, String nickName,
      _AvatarActionType avatarActionType,
      {Color? color}) {
    return CupertinoActionSheetAction(
      child: buildSheetText(text, color ?? _UIColors.color_007AFF),
      onPressed: () {
        Navigator.pop(
            context, _AvatarActionData(avatarActionType, userUuid, nickName));
      },
    );
  }

  Widget buildSheetText(String text, Color? color) {
    return Text(text, style: TextStyle(color: color, fontSize: 20));
  }

  Widget buildMessageFrom(MessageState message) {
    String text = message.nickname;
    if (message.isPrivateMessage) {
      if (message is OutMessageState) {
        if (message.toUserNicknameList?.isNotEmpty == true) {
          text = meetingUiLocalizations
              .chatISaidTo(message.toUserNicknameList![0]);
        } else {
          final member = roomContext?.getMember(message.toUserUuidList!.first);
          text = meetingUiLocalizations.chatISaidTo(member?.name ?? '');
        }
      }
      if (message is InMessageState) {
        text = meetingUiLocalizations.chatSaidToMe(message.nickname);
      }
    } else if (message.chatroomType == NEChatroomType.waitingRoom) {
      text = message is OutMessageState
          ? meetingUiLocalizations.chatISaidToWaitingRoom
          : meetingUiLocalizations.chatSaidToWaitingRoom(message.nickname);
    }
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: _UIColors.color_333333, fontSize: 12),
    );
  }

  /// 获取聊天对象，等候室获取管理员，会议室获取成员
  NEBaseRoomMember? _getChatMember(String? userUuid) {
    if (roomContext == null) return null;
    if (roomContext!.isInWaitingRoom()) {
      return chatRoomManager?.hostAndCoHost
          .where((member) => member.uuid == userUuid)
          .firstOrNull;
    } else {
      return roomContext?.getMember(userUuid);
    }
  }

  /// 获取等候室或会中成员
  NEBaseRoomMember? _getMember(String? userUuid) {
    if (roomContext == null) return null;
    return roomContext?.getMember(userUuid) ??
        _arguments.waitingRoomManager?.userList
            .where((member) => member.uuid == userUuid)
            .firstOrNull ??
        chatRoomManager?.hostAndCoHost
            .where((element) => element.uuid == userUuid)
            .firstOrNull;
  }

  Widget? buildMessageType(MessageState message) {
    if (message.isPrivateMessage) {
      final text = message.chatroomType == NEChatroomType.waitingRoom
          ? meetingUiLocalizations.chatPrivateInWaitingRoom
          : meetingUiLocalizations.chatPrivate;
      return Text(
        '($text)',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: _UIColors.color_337eff, fontSize: 12),
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
        actions: [meetingUiLocalizations.chatRecall]);
  }

  Widget buildFileContent(FileMessageState message, bool isRight) {
    final fileContent = _FileContent(
      message: message,
      onTap: (msg) => _handleFileMessageClick(message),
    );
    return _isInHistoryPage
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
            actions: [meetingUiLocalizations.chatRecall]);
  }

  Widget buildNotifyContent(NotificationMessageState message) {
    String name = "";
    if (roomContext?.localMember.uuid == message.operator ||
        AccountRepository().getAccountInfo()?.userUuid == message.operator) {
      name = meetingUiLocalizations.chatYou;
    } else {
      final member = _getMember(message.operator);
      name = "\u201C${member?.name ?? message.nickname}\u201D";
    }

    return Container(
      height: 18,
      margin: EdgeInsets.symmetric(vertical: 15),
      padding: EdgeInsets.symmetric(horizontal: 46),
      child: Text(
        "$name${meetingUiLocalizations.chatRecallAMessage}",
        style: TextStyle(color: _UIColors.color_999999, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _handleFileMessageClick(FileMessageState message) async {
    if (_isInHistoryPage) return;
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
      showToast(meetingUiLocalizations.chatOpenFileFailAppNotFound);
    } else if (resultType == ResultType.fileNotFound) {
      showToast(
        meetingUiLocalizations.chatOpenFileFailFileNotFound,
      );
    } else if (resultType == ResultType.permissionDenied) {
      showToast(meetingUiLocalizations.chatOpenFileFailNoPermission);
    } else if (resultType == ResultType.error) {
      showToast(meetingUiLocalizations.chatOpenFileFail);
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
      child: ExtendedText(
        content,
        softWrap: true,
        specialTextSpanBuilder: _emailSpanBuilder,
        style: TextStyle(color: _UIColors.color_333333, fontSize: 14),
      ),
    );
    return Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: _isInHistoryPage
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
                    meetingUiLocalizations.globalCopy,
                    if (isRight) meetingUiLocalizations.chatRecall
                  ]));
  }

  Future<bool> ensureStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) return true;
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final granted =
            await Permission.storage.request() == PermissionStatus.granted;
        if (mounted && !granted) {
          showToast(meetingUiLocalizations.globalNoPermission);
        }
        return granted;
      }
    }
    return true;
  }

  void _onSelectImage() async {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    }
    if (await ensureStoragePermission() && mounted) {
      _selectFile(SelectType.image, _kSupportedImageFileExtensions,
          _kSupportedImageFileMaxSize);
    }
  }

  void _onSelectFile() async {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    }
    if (await ensureStoragePermission() && mounted) {
      _selectFile(SelectType.file, _kSupportedRawFileExtensions,
          _kSupportedRawFileMaxSize);
    }
  }

  void _selectFile(
      SelectType type, Set<String> supportedExtensions, int maxFileSize) {
    if (_selectingType != SelectType.none) {
      return;
    }
    _selectingType = type;

    final beforeTarget = chatRoomManager?.sendToTarget.value;
    FilePicker.platform
        .pickFiles(
          type: _selectingType == SelectType.image
              ? FileType.image
              : FileType.custom,
          allowedExtensions: _selectingType == SelectType.image
              ? null
              : supportedExtensions.toList(growable: false),
        )
        .then((value) {
          /// 如果在选择文件的过程中，发送对象变更了,则提示发送失败
          if (beforeTarget != chatRoomManager?.sendToTarget.value) {
            showToast(meetingUiLocalizations.chatSendFailed);
            return;
          }

          _onFileSelected(
            value?.files.first,
            supportedExtensions,
            maxFileSize,
            type == SelectType.image
                ? meetingUiLocalizations.chatImageSizeExceedTheLimit
                : meetingUiLocalizations.chatFileSizeExceedTheLimit,
          );
        })
        .onError<PlatformException>((error, stackTrace) {
          if (mounted) showToast(meetingUiLocalizations.globalNoPermission);
        }, test: (error) => error.code == "read_external_storage_denied")
        .whenComplete(() => _selectingType = SelectType.none)
        .ignore();
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
          errorMsg = meetingUiLocalizations.chatUnsupportedFileExtension;
        } else if (size > maxFileSize) {
          errorMsg = sizeExceedErrorMsg;
        }
        if (errorMsg != null) {
          showToast(errorMsg);
          file.delete();
          return;
        }

        MessageState? message;
        if (_selectingType == SelectType.image) {
          message = OutImageMessage(_myNickname, _myAvatar, path, size,
              toUserUuidList, toUserNicknameList, chatRoomType);
        } else if (_selectingType == SelectType.file) {
          message = OutFileMessage(_myNickname, _myAvatar, name, path, size,
              extension, toUserUuidList, toUserNicknameList, chatRoomType);
        }
        if (message != null) {
          _realSendMessage(message);
        }
      }
    }
  }

  Future<bool> _realSendMessage(MessageState message) async {
    if (await _hasNetworkOrToast() == true) {
      if (message is OutMessageState) {
        if (message.isFailed) {
          _arguments.messageSource.removeMessage(message);
          message = message.copy();
        }
        await _arguments.messageSource
            .ensureChatroomJoined(message.chatroomType);
        if (message is OutImageMessage) {
          message.startSend(chatController.sendImageMessage(
            message.uuid,
            message.path,
            message.toUserUuidList,
            chatroomType: message.chatroomType,
          ));
        } else if (message is OutFileMessage) {
          message.startSend(chatController.sendFileMessage(
            message.uuid,
            message.path,
            message.toUserUuidList,
            chatroomType: message.chatroomType,
          ));
        } else if (message is OutTextMessage) {
          if (message.isPrivateMessage &&
              message.toUserUuidList?.first != null) {
            message.startSend(chatController.sendDirectTextMessage(
              message.toUserUuidList!.first,
              message.text,
              chatroomType: message.chatroomType,
            ));
          } else {
            message.startSend(chatController.sendBroadcastTextMessage(
              message.text,
              chatroomType: message.chatroomType,
            ));
          }
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
    if (!await ConnectivityManager().isConnected()) {
      showToast(
          NEMeetingUIKitLocalizations.of(context)!.networkUnavailableCheck);
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
    roomContext?.removeEventCallback(roomEventCallback);
    _arguments.messageSource.resetUnread();
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
  final Widget? messageFrom;
  final Widget? messageType;
  final WidgetBuilder contentBuilder;
  final VoidCallback? avatarOnTap;
  final ValueListenable<bool> hideAvatar;

  bool get outgoing => !incoming;

  const _MessageItem({
    Key? key,
    required this.incoming,
    required this.message,
    required this.contentBuilder,
    this.shouldShowRetry = true,
    this.onRetry,
    this.messageFrom,
    this.messageType,
    this.avatarOnTap,
    required this.hideAvatar,
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
    final head = GestureDetector(
      onTap: avatarOnTap,
      child: ValueListenableBuilder(
        valueListenable: hideAvatar,
        builder: (context, hideAvatar, child) {
          return NEMeetingAvatar.medium(
            name: message.nickname,
            url: message.avatar,
            hideImageAvatar: hideAvatar,
          );
        },
      ),
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
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: outgoing
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (messageType != null && outgoing) ...[
                          messageType!,
                          SizedBox(width: 4),
                        ],
                        if (messageFrom != null && outgoing)
                          Flexible(child: messageFrom!),
                        if (messageFrom != null && incoming)
                          Flexible(child: messageFrom!),
                        if (messageType != null && incoming) ...[
                          SizedBox(width: 4),
                          messageType!,
                        ],
                      ],
                    ),
                    SizedBox(height: 6),
                    Stack(
                      children: [
                        if (leftFailIcon)
                          Positioned.fill(
                            child: failureIcon,
                          ),
                        Row(
                          mainAxisAlignment: outgoing
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (leftFailIcon)
                              SizedBox(width: _failureIconSize + 4),
                            Flexible(child: contentBuilder(context)),
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
              SizedBox(width: 8),
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

class _AvatarActionData {
  final _AvatarActionType action;
  final String userUuid;
  final String nickName;

  _AvatarActionData(this.action, this.userUuid, this.nickName);
}

enum _AvatarActionType {
  chatPrivate,
  remove,
}
