// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingBarrage extends StatefulWidget {
  final VoidCallback onChat;
  final MeetingBarrageHelper helper;
  final NERoomContext roomContext;

  MeetingBarrage(
      {super.key,
      required this.onChat,
      required this.roomContext,
      required this.helper});

  @override
  State<MeetingBarrage> createState() => _MeetingBarrageState();
}

class _MeetingBarrageState extends State<MeetingBarrage> with _AloggerMixin {
  final _emailSpanBuilder =
      MeetingTextSpanBuilder(emojiSize: 16, showNickname: true);

  NEMeetingUIKitLocalizations get localizations =>
      NEMeetingUIKit.instance.getUIKitLocalizations();

  /// 收到新消息，显示消息来源
  String getLeadingText(MessageState message) {
    String text = message.nickname;
    if (message.isPrivateMessage) {
      if (message is OutMessageState) {
        if (message.toUserNicknameList?.isNotEmpty == true) {
          text = localizations.chatISaidTo(message.toUserNicknameList![0]);
        } else {
          final member =
              widget.roomContext.getMember(message.toUserUuidList!.first);
          text = localizations.chatISaidTo(member?.name ?? '');
        }
      }
      if (message is InMessageState) {
        text = localizations.chatSaidToMe(message.nickname);
      }
    } else if (message.chatroomType == NEChatroomType.waitingRoom) {
      text = message is OutMessageState
          ? localizations.chatISaidToWaitingRoom
          : localizations.chatSaidToWaitingRoom(message.nickname);
    }
    if (message.isPrivateMessage) {
      final type = message.chatroomType == NEChatroomType.waitingRoom
          ? localizations.chatPrivateInWaitingRoom
          : localizations.chatPrivate;
      text = '($type)$text';
    }
    return '$text: ';
  }

  String? getMessage(MessageState chatRoomMessage) {
    String? content;
    if (chatRoomMessage is TextMessageState) {
      content = chatRoomMessage.text;
    } else if (chatRoomMessage is ImageMessageState) {
      content = NEMeetingUIKitLocalizations.of(context)!.chatImageMessageTip;
    } else if (chatRoomMessage is FileMessageState) {
      content = NEMeetingUIKitLocalizations.of(context)!.chatFileMessageTip;
    }
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return StreamBuilder(
            stream: widget.helper.stream,
            builder: (context, snapshot) {
              if (snapshot.data?.isNotEmpty != true) return SizedBox.shrink();
              return ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.white],
                    stops: [
                      0.0,
                      snapshot.data!.length >= 3 ? 0.15 : 0
                    ], // 指定渐变的位置，顶部有淡出效果
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: 276,
                    maxHeight: orientation == Orientation.portrait ? 160 : 100,
                  ),
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    removeBottom: true,
                    child: ListView.separated(
                      shrinkWrap: true,
                      reverse: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final message = snapshot.data![index];
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: widget.onChat,
                            child: AnimationMessageItem(
                              leading: getLeadingText(message),
                              text: getMessage(message)!,
                              emailSpanBuilder: _emailSpanBuilder,
                              opacity: widget.helper.getMessageOpacity(message),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 4),
                    ),
                  ),
                ),
              );
            });
      },
    );
  }
}

class AnimationMessageItem extends StatefulWidget {
  final String leading;
  final String text;
  final MeetingTextSpanBuilder emailSpanBuilder;
  final ValueNotifier<double> opacity;

  AnimationMessageItem({
    required this.leading,
    required this.text,
    required this.emailSpanBuilder,
    required this.opacity,
  });

  @override
  _AnimationMessageItemState createState() => _AnimationMessageItemState();
}

class _AnimationMessageItemState extends State<AnimationMessageItem> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.opacity,
        builder: (context, value, _) {
          var opacity = value;
          opacity = opacity >= 1.0 ? 1.0 : opacity;
          opacity = opacity <= 0.0 ? 0.0 : opacity;
          return Opacity(
            opacity: opacity,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExtendedText(
                '${widget.leading}${LeadingText.leadingEndFlag}${widget.text}',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                specialTextSpanBuilder: widget.emailSpanBuilder,
                style: TextStyle(
                  color: _UIColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none,
                ),
                strutStyle: StrutStyle(
                  forceStrutHeight: true,
                  height: 1.2,
                ),
              ),
            ),
          );
        });
  }
}

class MeetingBarrageButton extends StatefulWidget {
  final ChatRoomManager chatRoomManager;

  MeetingBarrageButton({super.key, required this.chatRoomManager});

  @override
  State<MeetingBarrageButton> createState() => _MeetingBarrageButtonState();
}

class _MeetingBarrageButtonState extends State<MeetingBarrageButton> {
  late VoidCallback sendTargetListener;

  @override
  void initState() {
    super.initState();
    sendTargetListener = () {
      if (mounted) setState(() {});
    };
    widget.chatRoomManager.sendToTarget.addListener(sendTargetListener);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: _LocalSettings().getIsBarrageShowStream(),
        builder: (context, value) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child:
                value.data ?? true ? buildEnabledState() : buildDisabledState(),
          );
        });
  }

  bool get isSilence => widget.chatRoomManager.sendToTarget.value == null;

  NEMeetingUIKitLocalizations get localizations =>
      NEMeetingUIKit.instance.getUIKitLocalizations();

  /// 开启状态
  Widget buildEnabledState() {
    return Container(
        height: 40,
        padding: const EdgeInsets.only(left: 8, right: 12),
        decoration: BoxDecoration(
          color: _UIColors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              child: NEMeetingImages.assetImage(
                NEMeetingImages.iconBulletScreenEnabled,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
              onTap: () {
                _LocalSettings().setBarrageShow(false);
              },
            ),
            Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
              width: 1,
              height: 12,
              color: _UIColors.white.withOpacity(0.5),
            ),
            Text(
              !isSilence
                  ? localizations.meetingSaySomeThing
                  : localizations.meetingKeepSilence,
              style: TextStyle(
                color: _UIColors.white.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ));
  }

  /// 关闭状态
  Widget buildDisabledState() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _LocalSettings().setBarrageShow(true);
      },
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: _UIColors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: NEMeetingImages.assetImage(
          NEMeetingImages.iconBulletScreenDisabled,
          width: 24,
          height: 24,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.chatRoomManager.sendToTarget.removeListener(sendTargetListener);
    super.dispose();
  }
}

/// 聊天弹幕帮助类，记住消息顺序和透明度，跟随meeting_page生命周期
class MeetingBarrageHelper {
  List<MessageState> _messages = [];
  Map<MessageState, ValueNotifier<double>> _messageOpacityMap = {};
  Timer? timer;
  StreamSubscription<MessageState>? _messageSubscription;
  final _messageStream = StreamController<List<MessageState>>.broadcast();
  Stream<List<MessageState>> get stream =>
      _messageStream.stream.addInitial(_messages);

  void init(Stream<MessageState> messageStream) {
    _messageSubscription?.cancel();
    _messageSubscription = messageStream.listen((event) {
      if (_messages.length > 10) {
        _messageOpacityMap.remove(_messages.removeLast());
      }
      _messages.insert(0, event);
      _messageOpacityMap[event] = ValueNotifier(2.0);
      _startTimer();
      _messageStream.add(_messages);
    });
  }

  ValueNotifier<double> getMessageOpacity(MessageState message) =>
      _messageOpacityMap[message] ?? ValueNotifier(0.0);

  /// 总时长显示8秒，最后4秒渐隐
  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      List<MessageState> messagesToRemove = [];
      _messageOpacityMap.forEach((message, opacity) {
        opacity.value -= 0.0075;
        if (opacity.value <= 0) {
          messagesToRemove.add(message);
        }
      });

      messagesToRemove.forEach((message) {
        _messages.remove(message);
        _messageOpacityMap.remove(message);
      });

      if (_messages.isEmpty) {
        _stopTimer();
      }
      _messageStream.add(_messages);
    });
  }

  void _stopTimer() {
    timer?.cancel();
    timer = null;
  }

  void dispose() {
    _stopTimer();
    _messageSubscription?.cancel();
    _messageSubscription = null;
  }
}
