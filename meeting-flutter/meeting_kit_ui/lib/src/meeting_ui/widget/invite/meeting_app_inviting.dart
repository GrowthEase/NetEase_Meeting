// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 应用内邀请弹窗
class MeetingAppInviting extends StatefulWidget {
  static const appInviteTag = 'appInviteTag';

  final String? title;
  final int? popupDuration;
  final String? userName;
  final String? userAvatar;
  final String meetingSubject;
  final InviteAction onAction;
  final bool isFullScreen;
  final bool ring;
  final showInviter;
  final bool isInMinimizedMode;

  const MeetingAppInviting({
    super.key,
    this.title,
    this.popupDuration,
    this.userName,
    this.userAvatar,
    required this.onAction,
    required this.meetingSubject,
    this.isFullScreen = false,
    this.ring = true,
    this.showInviter = true,
    required this.isInMinimizedMode,
  });

  @override
  State<MeetingAppInviting> createState() => _MeetingAppInvitingState();
}

class _MeetingAppInvitingState extends State<MeetingAppInviting>
    with MeetingKitLocalizationsMixin, TickerProviderStateMixin {
  late final AnimationController _scaleAnimation;
  final isFull = ValueNotifier(false);
  Timer? _inviteTimer;
  Offset? _startDragOffset;
  Offset? _dragOffset;

  @override
  void initState() {
    super.initState();
    _scaleAnimation = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    if (widget.isFullScreen && !isFull.value) {
      switchMode();
    }

    if (widget.ring) {
      play(
        fromAsset: NEMeetingSounds.appInviteRing,
      );

      /// 倒计时60秒
      _inviteTimer = Timer(Duration(seconds: widget.popupDuration ?? 60), () {
        if (widget.ring) {
          _player.stop();
        }
        _inviteTimer?.cancel();
        _inviteTimer = null;
      });
    }
  }

  AudioPlayer _player = AudioPlayer();

  /// 播放音频
  /// [fromAsset] 音频文件路径
  /// [looping] 是否循环播放
  void play({
    required String fromAsset,
    bool looping = true,
  }) async {
    _player.setReleaseMode(looping ? ReleaseMode.loop : ReleaseMode.release);
    final data = await rootBundle.load(fromAsset);
    final bytes = data.buffer.asUint8List();
    final source = BytesSource(bytes, mimeType: 'audio/mpeg');
    _player.play(source, volume: 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return widget.isInMinimizedMode
        ? buildMinimizedMode(widget.userName!, widget.userAvatar)
        : Container(
            width: screenSize.width,
            height: screenSize.height,
            child: Stack(
              children: <Widget>[
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    final animationCurve = CurveTween(
                      curve: Curves.easeInOutQuad,
                    );
                    final scaleAnimationValue = animationCurve.transform(
                      _scaleAnimation.value,
                    );
                    final width = Tween<double>(
                      begin: 351,
                      end: screenSize.width,
                    ).transform(scaleAnimationValue);
                    final height = Tween<double>(
                      begin: 210,
                      end: screenSize.height,
                    ).transform(scaleAnimationValue);
                    return Positioned(
                      left: 0,
                      right: 0,
                      top: _dragOffset?.dy ?? 0,
                      child: Container(
                        width: width,
                        height: height,
                        child: child,
                      ),
                    );
                  },
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isFull,
                    builder: (context, value, child) {
                      return value ? buildFull() : buildNormal();
                    },
                  ),
                ),
              ],
            ),
          );
  }

  /// 开始拖拽
  void _onPanStart(DragStartDetails details) {
    _startDragOffset = details.globalPosition;
  }

  /// 拖拽中
  void _onPanUpdate(DragUpdateDetails details) {
    if (_startDragOffset == null) {
      return;
    }
    final dy = details.globalPosition.dy - _startDragOffset!.dy;
    if (dy > 0) {
      return;
    }
    setState(() {
      _dragOffset = Offset(0, dy);
    });
  }

  /// 拖拽结束
  void _onPanEnd(DragEndDetails details) {
    if (_dragOffset != null) {
      if (_dragOffset!.dy < -50) {
        widget.onAction(InviteJoinActionType.reject);
      } else {
        setState(() {
          _startDragOffset = null;
          _dragOffset = null;
        });
      }
    }
  }

  /// 切换为全屏模式/非全屏模式,
  /// 全屏模式: 从点击位置放大到全屏
  /// 非全屏模式: 从全屏缩小到指定位置
  void switchMode() {
    if (isFull.value) {
      _scaleAnimation.reverse();
    } else {
      _scaleAnimation.forward();
    }
    isFull.value = !isFull.value;
  }

  /// 构建非全屏模式
  Widget buildNormal() {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: switchMode,
      child: Container(
        margin: EdgeInsets.only(top: 50, left: 12, right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _UIColors.black.withOpacity(0.8),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showInviter)
              buildTitleWithUser(widget.userName!, widget.userAvatar)
            else
              buildTitle(widget.title!),
            SizedBox(height: 18),
            buildActions(),
          ],
        ),
      ),
    );
  }

  /// 构建即将开始标题
  Widget buildTitle(String title) {
    return Row(
      children: [
        Expanded(
            child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: _UIColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6),
            Text(
              widget.meetingSubject,
              style: TextStyle(
                color: _UIColors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        )),
      ],
    );
  }

  /// 构建带邀请者的标题
  Widget buildTitleWithUser(String userName, String? userAvatar) {
    return Row(
      children: [
        NEMeetingAvatar.xlarge(url: userAvatar, name: userName),
        SizedBox(width: 12),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meetingUiLocalizations.meetingAppInvite(userName),
              style: TextStyle(
                color: _UIColors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6),
            Text(
              widget.meetingSubject,
              style: TextStyle(
                color: _UIColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        )),
      ],
    );
  }

  /// 构建底部按钮
  Widget buildActions() {
    return Row(
      children: [
        _buildActionItem(
          icon: NEMeetingIconFont.icon_hand_up,
          type: InviteJoinActionType.reject,
          background: _UIColors.colorFE3B30,
        ),
        Expanded(child: SizedBox()),
        _buildActionItem(
          icon: NEMeetingIconFont.icon_yx_tv_voice_onx,
          type: InviteJoinActionType.audioAccept,
          background: _UIColors.white.withOpacity(0.4),
        ),
        SizedBox(width: 20),
        _buildActionItem(
          icon: NEMeetingIconFont.icon_yx_tv_video_onx,
          type: InviteJoinActionType.videoAccept,
          background: _UIColors.color2ACB42,
        ),
      ],
    );
  }

  /// 构建底部按钮项
  Widget _buildActionItem(
      {required IconData icon,
      required Color background,
      required InviteJoinActionType type}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        widget.onAction(type);
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: _UIColors.white,
        ),
      ),
    );
  }

  Widget buildFull() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image(
          image: NEMeetingImages.assetImageProvider(
              NEMeetingImages.waitingRoomBackground),
          fit: BoxFit.cover,
        ),
        Positioned(
            top: 57,
            left: 20,
            child: GestureDetector(
              onTap: switchMode,
              child: const Icon(NEMeetingIconFont.icon_narrow,
                  size: 24, color: _UIColors.white),
            )),
        if (widget.showInviter)
          Positioned(
            top: 110,
            left: 0,
            right: 0,
            child: buildInviteInfoFullWithUser(
                widget.userName!, widget.userAvatar),
          )
        else
          Positioned(
            top: 160,
            left: 0,
            right: 0,
            child: buildInviteInfoFull(widget.title!),
          ),
        Positioned(bottom: 63, left: 0, right: 0, child: buildActionsFull())
      ],
    );
  }

  /// 构建带邀请者信息
  Widget buildInviteInfoFullWithUser(String userName, String? userAvatar) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RippleAnimation(
              size: 136,
              centerSize: 96,
              child: NEMeetingAvatar(
                  url: userAvatar,
                  name: userName,
                  size: 96,
                  textStyle: AvatarTextStyle(
                    fontSizeOneChinese: 40,
                    fontSizeTwoChinese: 36,
                    fontSizeLetter: 32,
                  )),
            ),
            SizedBox(height: 16),
            Text(
              meetingUiLocalizations.meetingAppInvite(userName),
              style: TextStyle(
                color: _UIColors.white.withOpacity(0.8),
                fontSize: 16,
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(height: 12),
            Text(
              widget.meetingSubject,
              style: TextStyle(
                color: _UIColors.white,
                fontSize: 20,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ));
  }

  /// 构建即将开始邀请
  Widget buildInviteInfoFull(String title) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: _UIColors.white,
                fontSize: 28,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 24),
            Text(
              widget.meetingSubject,
              style: TextStyle(
                color: _UIColors.white.withOpacity(0.8),
                fontSize: 20,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ));
  }

  /// 构建操作项
  Widget buildActionsFull() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionItemFull(
              icon: NEMeetingIconFont.icon_hand_up,
              type: InviteJoinActionType.reject,
              background: _UIColors.colorFE3B30,
              text: meetingUiLocalizations.globalReject,
            ),
            _buildActionItemFull(
              icon: NEMeetingIconFont.icon_yx_tv_voice_onx,
              type: InviteJoinActionType.audioAccept,
              background: _UIColors.white.withOpacity(0.2),
              text: meetingUiLocalizations.meetingAudioJoinAction,
            ),
            _buildActionItemFull(
              icon: NEMeetingIconFont.icon_yx_tv_video_onx,
              type: InviteJoinActionType.videoAccept,
              background: _UIColors.color2ACB42,
              text: meetingUiLocalizations.meetingVideoJoinAction,
            ),
          ],
        ));
  }

  /// 构建底部按钮项
  Widget _buildActionItemFull(
      {required IconData icon,
      required String text,
      required Color background,
      required InviteJoinActionType type}) {
    return Column(children: [
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.onAction(type);
        },
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 28,
            color: _UIColors.white,
          ),
        ),
      ),
      SizedBox(height: 8),
      Text(
        text,
        style: TextStyle(
          color: _UIColors.white,
          fontSize: 16,
          decoration: TextDecoration.none,
        ),
      ),
    ]);
  }

  /// 小窗模式下呼叫的布局
  Widget buildMinimizedMode(String userName, String? userAvatar) {
    return Stack(fit: StackFit.expand, children: [
      Image(
        image: NEMeetingImages.assetImageProvider(
            NEMeetingImages.waitingRoomBackground),
        fit: BoxFit.cover,
      ),
      Center(
        child: RippleAnimation(
          size: 80,
          centerSize: 48,
          child: NEMeetingAvatar.xlarge(name: userName, url: userAvatar),
        ),
      )
    ]);
  }

  @override
  void dispose() {
    if (widget.ring) {
      _player.stop();
    }
    _player.release();
    _inviteTimer?.cancel();
    _scaleAnimation.dispose();
    super.dispose();
  }
}
