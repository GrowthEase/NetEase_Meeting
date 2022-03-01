// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

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

  late ScrollController _scrollController;

  bool showToBottom = false, sending = false;

  /// 控制菜单出现时，消息不自动滚动到底部
  bool actionMenuShowing = false;

  double offset = 0, threshold = 50;

  int delayDuration = 200;

  final FocusNode _focusNode = FocusNode();

  final List<String> actions = [
    Strings.copy,
  ];

  late NEInRoomChatController chatController;
  @override
  void initState() {
    super.initState();
    chatController =
        NERoomKit.instance.getInRoomService()!.getInRoomChatController();
    _contentController = TextEditingController();
    _scrollController =
        ScrollController(initialScrollOffset: _arguments.initialScrollOffset);
    _scrollController.addListener(() {
      var bottom = isBottom();
      if (bottom == null) {
        return;
      }
      offset = _scrollController.offset;
      if (bottom) {
        setState(() {
          showToBottom = false;
        });
      }
    });
    lifecycleListen(_arguments.messageSource.messageStream,
        (dynamic dataSource) {
      var bottom = isBottom();
      if (bottom == null) {
        return;
      }
      if (!actionMenuShowing && (bottom || scrollToBottom())) {
        setState(() {
          showToBottom = false;
        });
        delayTask(() {
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: delayDuration),
              curve: Curves.decelerate);
        }, milliseconds: delayDuration);
      } else {
        setState(() {
          showToBottom = true;
        });
      }
    });
    delayTask(() {
      var bottom = isBottom();
      if (bottom != null && !bottom) {
        setState(() {
          showToBottom = true;
        });
      }
    }, milliseconds: delayDuration);
  }

  bool? isBottom() {
    if (!_scrollController.hasClients) {
      return null;
    }
    return ((_scrollController.offset - _scrollController.position.maxScrollExtent).abs()) < threshold;
  }

  bool scrollToBottom() {
    var message = _arguments.getMessage(_arguments.size - 1);
    if (message == null) {
      return false;
    }
    return message.chatRoomUserInfo.isSelf;
  }

  @override
  Widget build(BuildContext context) {
    var topPadding = MediaQuery.of(context).padding.top;
    var bottomPadding = MediaQuery.of(context).padding.bottom;
    _screenHeight = MediaQuery.of(context).size.height;
    _taskBarHeight = topPadding;
    _bottomNavigationBarHeight = bottomPadding;
    // Alog.i(tag: _tag,moduleName: moduleName,content:"MenuPopWidget topPadding = $topPadding, bottomPadding = $bottomPadding");
    // Alog.i(tag: _tag,moduleName: moduleName,content:"MeetingChatRoomPage showToBottom = $showToBottom, unread = ${_arguments.messageSource.unread}");
    return WillPopScope(
      child: Scaffold(
        backgroundColor: UIColors.colorF6F6F6,
        appBar: buildAppBar(context),
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
          Strings.chat,
          style: TextStyle(color: UIColors.color_222222, fontSize: 17),
        ),
        centerTitle: true,
        backgroundColor: UIColors.colorF6F6F6,
        elevation: 0.0,
        brightness: Brightness.light,
        leading: GestureDetector(
          child: Container(
            alignment: Alignment.center,
            key: MeetingCoreValueKey.chatRoomClose,
            child: Text(
              Strings.close,
              style: TextStyle(color: UIColors.blue_337eff, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          onTap: () {
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
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
            SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            });
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 62),
            height: 28,
            width: 74,
            decoration: BoxDecoration(
                color: UIColors.blue_337eff,
                borderRadius: BorderRadius.all(Radius.circular(14.0)),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 2),
                      blurRadius: 2,
                      color: UIColors.blue_50_337eff)
                ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.arrow_downward, size: 16, color: Colors.white),
                Text(
                  Strings.newMessage,
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
        children: <Widget>[buildListView(), shadow(), buildInput()],
      )),
    );
  }

  Widget shadow() {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: UIColors.white,
        boxShadow: [
          BoxShadow(
            color: UIColors.colorE1E3E6,
          ),
        ],
      ),
    );
  }

  Widget buildListView() {
    return Expanded(
        key: MeetingCoreValueKey.chatRoomListView,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_focusNode.hasFocus) {
              _focusNode.unfocus();
            }
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            itemBuilder: (context, index) {
              var message = _arguments.getMessage(index);
              if (message == null) {
                return Container();
              }
              if (message.content == null) {
                return buildTimeTips(message);
              } else {
                return buildTextItem(message);
              }
            },
            itemCount: _arguments.size,
          ),
        ));
  }

  Widget buildTimeTips(NEChatRoomMessage message) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      alignment: Alignment.center,
      child: Text(
        message.time!.formatToTimeString('kk:mm'),
        style: TextStyle(color: UIColors.color_999999, fontSize: 12),
      ),
    );
  }

  Widget buildInput() {
    return Container(
      padding: EdgeInsets.only(left: 10, top: 8, bottom: 8, right: 10),
      color: Colors.white,
      child: Row(
        children: <Widget>[buildInputBox(), buildSend()],
      ),
    );
  }

  Widget buildInputBox() {
    return Expanded(
        child: Container(
      decoration: BoxDecoration(
          color: UIColors.colorF7F8FA,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          border: Border.all(width: 1, color: UIColors.colorF2F3F5)),
      height: 40,
      alignment: Alignment.center,
      child: TextField(
          key: MeetingCoreValueKey.inputMessageKey,
          focusNode: _focusNode,
          controller: _contentController,
          cursorColor: UIColors.blue_337eff,
          keyboardAppearance: Brightness.light,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            filled: true,
            isDense: true,
            fillColor: Colors.transparent,
            hintText: Strings.inputMessageHint,
            hintStyle: TextStyle(
                fontSize: 14,
                color: UIColors.color_999999,
                decoration: TextDecoration.none),
            border: InputBorder.none,
          )),
    ));
  }

  Widget buildSend() {
    return Container(
      margin: EdgeInsets.only(left: 8),
      height: 28,
      width: 52,
      child: ElevatedButton(
        key: MeetingCoreValueKey.chatRoomSendBtn,
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.disabled)) {
                return UIColors.blue_50_337eff;
              }
              return UIColors.blue_337eff;
            }),
            padding:
                MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 0)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                side: BorderSide(color: UIColors.blue_337eff),
                borderRadius: BorderRadius.all(Radius.circular(14))))),
        onPressed: onSendMessage,
        child: Text(
          Strings.send,
          style: TextStyle(color: Colors.white, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
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
        ToastUtils.showToast(context, Strings.networkUnavailableCheck);
      } else {
        var content = _contentController.text.trim();
        if (TextUtils.isEmpty(content)) {
          ToastUtils.showToast(context, Strings.cannotSendBlankLetter);
          sending = false;
          return;
        }
        var message = NEChatRoomTextMessage(content: content);
        var result = await chatController.sendChatRoomMessage(message);
        sending = false;
        if (result.code == RoomErrorCode.success) {
          _arguments.messageSource.append(message, incUnread: false);
          _contentController.clear();
        } else {
          ToastUtils.showToast(context, RoomErrorCode.getMsg(result.msg));
        }
      }
    });
  }

  Widget buildTextItem(NEChatRoomMessage message) {
    var isRight = message.chatRoomUserInfo.isSelf;
    var nick = message.chatRoomUserInfo.nick!;
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment:
            isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!isRight) buildHead(nick),
          if (!isRight) SizedBox(width: 4),
          Expanded(
              child: Column(
            crossAxisAlignment:
                isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[buildName(nick), buildContent(message, isRight)],
          )),
          if (isRight) SizedBox(width: 4),
          if (isRight) buildHead(nick),
        ],
      ),
    );
  }

  Widget buildName(String nick) {
    return Text(nick,
        style: TextStyle(color: UIColors.color_333333, fontSize: 12));
  }

  Widget buildHead(String nick) {
    return ClipOval(
        child: Container(
      height: 24,
      width: 24,
      decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[UIColors.blue_5996FF, UIColors.blue_2575FF],
          ),
          shape: Border()),
      alignment: Alignment.center,
      child: Text(
        nick.substring(0, 1),
        style: TextStyle(fontSize: 14, color: Colors.white),
      ),
    ));
  }

  Widget buildContent(NEChatRoomMessage message, bool isRight) {
    return Container(
        margin: EdgeInsets.only(
            top: 4, left: isRight ? 24 : 0, right: isRight ? 0 : 24),
        child: PopupMenuWidget(
          onValueChanged: (int value) {
            if (value == 0) {
              Clipboard.setData(ClipboardData(text: message.content ?? ''));
            }
          },
          onShow: () => actionMenuShowing = true,
          onDismiss: () => actionMenuShowing = false,
          pressType: PressType.longPress,
          actions: actions,
          child: Container(
            padding: EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: isRight ? UIColors.colorCCE1FF : UIColors.colorF2F3F5,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Text(
              message.content ?? '',
              softWrap: true,
              style: TextStyle(color: UIColors.color_333333, fontSize: 14),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _arguments.messageSource.updateOffset(offset);
    _arguments.messageSource.resetUnread();
    _scrollController.dispose();
    _contentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
