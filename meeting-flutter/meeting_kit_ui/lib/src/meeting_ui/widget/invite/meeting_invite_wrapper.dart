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

  MeetingInviteWrapper({
    required this.child,
    required this.isCalling,
    required this.inviteType,
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
      ],
    );
  }

  /// 邀请中的GIF动画
  Widget _buildOverlay() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.center,
        child: ClipOval(
          child: Container(
            color: _UIColors.black.withOpacity(0.5),
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 32,
                height: 32,
                child: _buildImage(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.isCalling) {
      return Image.asset(
        NEMeetingImages.callLoadingGif,
        package: NEMeetingImages.package,
      );
    } else {
      return Icon(NEMeetingIconFont.icon_call_out,
          size: 24, color: _UIColors.white);
    }
  }
}
