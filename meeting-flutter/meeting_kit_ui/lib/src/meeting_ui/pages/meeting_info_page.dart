// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 会议信息界面
class MeetingInfoPage extends StatefulWidget {
  final NERoomContext roomContext;

  final MeetingInfo meetingInfo;

  final NEMeetingUIOptions options;

  final Stream roomInfoUpdatedEventStream;
  final ValueNotifier<int> maxMembersNotifier;

  MeetingInfoPage(this.roomContext, this.meetingInfo, this.options,
      this.roomInfoUpdatedEventStream, this.maxMembersNotifier);

  @override
  State<StatefulWidget> createState() {
    return MeetingInfoPageState(this.roomContext);
  }
}

class MeetingInfoPageState extends BaseState<MeetingInfoPage>
    with EventTrackMixin {
  MeetingInfoPageState(this.roomContext);

  static const _radius = const Radius.circular(20);

  final NERoomContext roomContext;

  final titleWidth = 100.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20.0,
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: _radius, topRight: _radius)),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.symmetric(
          vertical: 20.0,
        ),
        child: IntrinsicHeight(
          child: buildContent(),
        ),
      ),
    );
  }

  Widget buildContent() {
    return StreamBuilder(
      stream: widget.roomInfoUpdatedEventStream,
      builder: (context, snapshot) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _title(),
          _desc(),
          _buildSplit(),
          SizedBox(
            height: 9,
          ),
          ..._buildMeetingNum(),
          if (!TextUtils.isEmpty(roomContext.password)) _buildPwd(),
          if (!TextUtils.isEmpty(getHostName())) _buildHost(),
          if (!TextUtils.isEmpty(roomContext.sipCid)) _buildSip(),
          if (!TextUtils.isEmpty(widget.meetingInfo.inviteUrl))
            buildCopyItem(
                NEMeetingUIKitLocalizations.of(context)!.meetingInviteUrl,
                widget.meetingInfo.inviteUrl!),
          _buildMaxMembers(),
          ...buildDebugView(),
        ],
      ),
    );
  }

  Widget _buildSplit() {
    return Container(
      color: _UIColors.white,
      height: 1,
      child: Divider(height: 1),
    );
  }

  Widget _title() {
    return Container(
      child: Text(
        roomContext.roomName,
        style: TextStyle(
            color: _UIColors.black_333333,
            fontWeight: FontWeight.w500,
            fontSize: 20.0,
            decoration: TextDecoration.none),
      ),
    );
  }

  Widget _desc() {
    return Container(
        padding: EdgeInsets.only(top: 6, bottom: 16),
        child: Text.rich(TextSpan(children: [
          WidgetSpan(
              child: Icon(
                NEMeetingIconFont.icon_certification1x,
                color: _UIColors.color_26BD71,
                size: 13,
              ),
              style: TextStyle(
                  color: _UIColors.color_26BD71,
                  fontSize: 12.0,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400),
              alignment: PlaceholderAlignment.middle),
          TextSpan(
              text: NEMeetingUIKitLocalizations.of(context)!.meetingInfoDesc,
              style: TextStyle(
                  color: _UIColors.color_94979A,
                  fontWeight: FontWeight.w400,
                  fontSize: 12.0,
                  decoration: TextDecoration.none))
        ])));
  }

  List<Widget> _buildMeetingNum() {
    final meetingNum = roomContext.meetingNum;
    final shortMeetingNum = widget.meetingInfo.shortMeetingNum;
    String meetingIdCopyFormatter(String value) {
      return value.replaceAll(RegExp(r'-'), '');
    }

    if (!widget.options.isShortMeetingIdEnabled ||
        TextUtils.isEmpty(shortMeetingNum)) {
      //do not show short meeting id ,or short meeting id is empty, show only full meeting id
      return [
        buildCopyItem(
          NEMeetingUIKitLocalizations.of(context)!.meetingNum,
          meetingNum.toMeetingNumFormat(),
          itemDetailCopyFormatter: meetingIdCopyFormatter,
          itemDetailKey: MeetingUIValueKeys.meetingNum,
        )
      ];
    } else if (!widget.options.isLongMeetingIdEnabled) {
      //show only short meeting id
      return [
        buildCopyItem(
          NEMeetingUIKitLocalizations.of(context)!.meetingNum,
          shortMeetingNum,
          itemDetailKey: MeetingUIValueKeys.meetingNum,
        )
      ];
    } else {
      //show both
      return [
        buildCopyItem(
          NEMeetingUIKitLocalizations.of(context)!.meetingShortNum,
          shortMeetingNum,
          itemLabel:
              NEMeetingUIKitLocalizations.of(context)!.meetingInternalSpecial,
          itemDetailKey: MeetingUIValueKeys.meetingNum,
        ),
        buildCopyItem(
          NEMeetingUIKitLocalizations.of(context)!.meetingNum,
          meetingNum.toMeetingNumFormat(),
          itemDetailCopyFormatter: meetingIdCopyFormatter,
          itemDetailKey: MeetingUIValueKeys.meetingNum,
        ),
      ];
    }
  }

  Widget _buildSip() {
    return buildCopyItem(
        NEMeetingUIKitLocalizations.of(context)!.meetingSipNumber,
        roomContext.sipCid);
  }

  Widget _buildPwd() {
    return buildCopyItem(
      NEMeetingUIKitLocalizations.of(context)!.meetingPassword,
      roomContext.password,
      itemDetailKey: MeetingUIValueKeys.meetingPassword,
    );
  }

  Widget buildCopyItem(String itemTitle, String? itemDetail,
      {Key? itemDetailKey,
      String? itemLabel,
      String Function(String)? itemDetailCopyFormatter}) {
    return Container(
      height: 32,
      color: Colors.white,
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: titleWidth,
            child: Text(itemTitle,
                style: TextStyle(
                    fontSize: 14,
                    color: _UIColors.color_94979A,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400)),
          ),
          Flexible(
            child: Text(
              key: itemDetailKey,
              '${itemDetail ?? ""}',
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              maxLines: 1,
              style: TextStyle(
                fontSize: 14,
                color: _UIColors.black_222222,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (TextUtils.isNotEmpty(itemLabel))
            Container(
              height: 20,
              margin: EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                color: _UIColors.blue_337eff.withOpacity(0.1),
                border:
                    Border.all(color: _UIColors.blue_337eff.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(itemLabel ?? '',
                    style: TextStyle(
                        fontSize: 12,
                        color: _UIColors.blue_337eff,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w200)),
              ),
            ),
          SizedBox(width: 3),
          GestureDetector(
            key: MeetingUIValueKeys.copy,
            behavior: HitTestBehavior.translucent, // 点击区域设置到container大小
            child: Container(
              alignment: Alignment.center,
              child: Icon(NEMeetingIconFont.icon_copy1x,
                  color: _UIColors.blue_337eff, size: 16),
            ),
            onTap: () {
              if (TextUtils.isEmpty(itemDetail)) return;
              var value =
                  itemDetailCopyFormatter?.call(itemDetail!) ?? itemDetail;
              if (TextUtils.isNotEmpty(value)) {
                Clipboard.setData(ClipboardData(text: value!));
              }
              ToastUtils.showToast(context,
                  NEMeetingUIKitLocalizations.of(context)!.globalCopySuccess);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMaxMembers() {
    return SafeValueListenableBuilder(
        valueListenable: widget.maxMembersNotifier,
        builder: (context, maxMemberCount, _) {
          return Container(
            height: 32,
            color: Colors.white,
            alignment: Alignment.center,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    width: titleWidth,
                    child: Text(
                        NEMeetingUIKitLocalizations.of(context)!
                            .meetingMaxMembers,
                        style: TextStyle(
                            fontSize: 14,
                            color: _UIColors.color_94979A,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w400))),
                Expanded(
                  child: Text(maxMemberCount.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          color: _UIColors.black_222222,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w400)),
                ),
                // Spacer(),
              ],
            ),
          );
        });
  }

  Widget _buildHost() {
    return Container(
      height: 32,
      color: Colors.white,
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              width: titleWidth,
              child: Text(
                  NEMeetingUIKitLocalizations.of(context)!.participantHost,
                  style: TextStyle(
                      fontSize: 14,
                      color: _UIColors.color_94979A,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w400))),
          Expanded(
            child: Text(getHostName(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14,
                    color: _UIColors.black_222222,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400)),
          ),
          // Spacer(),
        ],
      ),
    );
  }

  String getHostName() {
    return widget.roomContext.getHostMember()?.name ?? '';
  }

  Widget shadow() {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: _UIColors.white,
        boxShadow: [
          BoxShadow(
            color: _UIColors.color_19242744,
            offset: Offset(4, 0),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }

  List<Widget> buildDebugView() {
    if (DebugOptions().isDebugMode) {
      return [
        if (roomContext.extraData?.isNotEmpty ?? false)
          _buildCommonItem('扩展字段', roomContext.extraData!),
      ];
    }
    return [];
  }

  Widget _buildCommonItem(String title, String desc) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.topLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 130,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: _UIColors.color_94979A,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xA0B71C1C),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(desc,
                // maxLines: 1,
                // overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14,
                    color: _UIColors.black_222222,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400)),
          ),
        ],
      ),
    );
  }
}
