// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

enum InviteType {
  /// 无
  none,

  /// app 邀请
  app,

  /// sip邀请
  sip,
}

class MeetingInviteWrapper extends StatefulWidget {
  final Widget? child;

  /// 显示邀请中的覆盖，
  final bool isCalling;

  final InviteType inviteType;

  final VoidCallback? onCall;

  MeetingInviteWrapper({
    required this.child,
    required this.isCalling,
    required this.inviteType,
    this.onCall,
  });

  @override
  State<StatefulWidget> createState() {
    return _InviteGIFState();
  }
}

class _InviteGIFState extends State<MeetingInviteWrapper> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.child ?? Container(),
        if (widget.inviteType != InviteType.none) _buildOverlay(),
        if (!widget.isCalling) _buildCall(),
      ],
    );
  }

  /// 邀请状态蒙板
  Widget _buildOverlay() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.center,
        child: ClipOval(
          child: Container(
            color: _UIColors.black.withOpacity(0.5),
            child: Align(
              alignment: Alignment.center,
              child: _buildText(),
            ),
          ),
        ),
      ),
    );
  }

  /// 呼叫按钮
  Widget _buildCall() {
    return Positioned(
      top: 0,
      right: 0,
      child: GestureDetector(
        onTap: widget.onCall,
        behavior: HitTestBehavior.opaque,
        child: ClipOval(
          child: Container(
            color: _UIColors.color1BB650,
            width: 20,
            height: 20,
            child: Icon(
              NEMeetingIconFont.icon_call,
              color: _UIColors.white,
              size: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildText() {
    return Text(
      widget.isCalling
          ? NEMeetingUIKit.instance.getUIKitLocalizations().callStatusCalling
          : NEMeetingUIKit.instance.getUIKitLocalizations().sipCallingNumber,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: _UIColors.white,
        fontSize: 14,
        decoration: TextDecoration.none,
        fontWeight: FontWeight.w400,
      ),
      strutStyle: StrutStyle(
        forceStrutHeight: true,
        height: 1,
      ),
    );
  }
}
