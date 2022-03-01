// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 会议信息界面
class MeetingInfoPage extends StatefulWidget {

  final MeetingOptions options;

  MeetingInfoPage(this.options);

  @override
  State<StatefulWidget> createState() {
    return MeetingInfoPageState();
  }
}

class MeetingInfoPageState extends LifecycleBaseState<MeetingInfoPage> with EventTrackMixin {

  MeetingInfoPageState();

  late Radius _radius;
  late NEInRoomService inRoomService;
  late NERoomInfo roomInfo;

  @override
  void initState() {
    super.initState();
    inRoomService = NERoomKit.instance.getInRoomService() as NEInRoomService;
    roomInfo = inRoomService.getCurrentRoomInfo() as NERoomInfo;
    _radius = Radius.circular(20);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 260,
        decoration:
            BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: _radius, topRight: _radius)),
        child: SafeArea(
          top: false,
          child: buildContent(),
        ));
  }

  Widget buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _title(),
        _desc(),
        _buildSplit(),
        SizedBox(height: 9,),
        ..._buildMeetingId(),
        if(!TextUtils.isEmpty(roomInfo.password)) _buildPwd(),
        _buildHost(),
        if(!TextUtils.isEmpty(roomInfo.sipCid))_buildSip(),
      ],
    );
  }

  Widget _buildSplit() {
    return Container(
      color: UIColors.white,
      padding: EdgeInsets.only(left: 20, right: 20),
      height: 1,
      child: Divider(height: 1),
    );
  }

  Widget _title() {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20),
      decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
              side: BorderSide(
                color: UIColors.white,
              ),
              borderRadius: BorderRadius.only(topLeft: _radius, topRight: _radius))),
      child: Text(
        roomInfo.subject,
        style: TextStyle(
            color: UIColors.black_333333, fontWeight: FontWeight.w500, fontSize: 20.0, decoration: TextDecoration.none),
      ),
    );
  }

  Widget _desc() {
    return Container(
        padding: EdgeInsets.only(top:2,left: 20, right: 20, bottom: 16),
        child: Text.rich(TextSpan(children: [
          WidgetSpan(
              child: Icon(
                NEMeetingIconFont.icon_certification1x,
                color: UIColors.color_26BD71,
                size: 13,
              ),
              style: TextStyle(
                  color: UIColors.color_26BD71,
                  fontSize: 12.0,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400),
              alignment: PlaceholderAlignment.middle),
          TextSpan(
              text: Strings.meetingInfoDesc,
              style: TextStyle(
                  color: UIColors.color_94979A,
                  fontWeight: FontWeight.w400,
                  fontSize: 12.0,
                  decoration: TextDecoration.none))
        ])));
  }

  List<Widget> _buildMeetingId() {
    if (!widget.options.isShortMeetingIdEnabled || TextUtils.isEmpty(roomInfo.shortRoomId)) {
      //do not show short meeting id ,or short meeting id is empty, show only full meeting id
      return [buildCopyItem(Strings.meetingId, roomInfo.roomId.toMeetingIdFormat())];
    } else if (!widget.options.isLongMeetingIdEnabled) {
      //show only short meeting id
      return [buildCopyItem(Strings.meetingId, roomInfo.shortRoomId)];
    } else {
      //show both
      return [
        buildCopyItem(Strings.shortMeetingId, roomInfo.shortRoomId, itemLabel: UIStrings.internalSpecial),
        buildCopyItem(Strings.meetingId, roomInfo.roomId.toMeetingIdFormat()),
      ];
    }
  }

  Widget _buildSip() {
    return buildCopyItem(Strings.sip, roomInfo.sipCid);
  }

  Widget _buildPwd() {
    return buildCopyItem(Strings.meetingPassword, roomInfo.password);
  }

  Widget buildCopyItem(String itemTitle, String? itemDetail, {String? itemLabel}) {
    return Container(
      height: 32,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 130,
            child: Text(itemTitle,
                style: TextStyle(
                    fontSize: 14,
                    color: UIColors.color_94979A,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400)),
          ),
          Text('${itemDetail ?? ""}',
              style: TextStyle(
                  fontSize: 14,
                  color: UIColors.black_222222,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400)),
          if (TextUtils.isNotEmpty(itemLabel))
            Container(
              height: 20,
              margin: EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                color: UIColors.blue_337eff.withOpacity(0.1),
                border: Border.all(color: UIColors.blue_337eff.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 8
                ),
                child: Text(
                    itemLabel??'',
                    style: TextStyle(
                        fontSize: 12,
                        color: UIColors.blue_337eff,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w200)
                ),
              ),
            ),
          GestureDetector(
            key: MeetingCoreValueKey.copy,
            child: Container(
              width: 40,
              height: 32,
              alignment: Alignment.center,
              child: Icon(NEMeetingIconFont.icon_copy1x, color: UIColors.blue_337eff, size: 12),
            ),
            onTap: () {
              var value = itemDetail?.replaceAll(RegExp(r'-'), '') ?? '';
              Clipboard.setData(ClipboardData(text: value));
              ToastUtils.showToast(context, Strings.copySuccess);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHost() {
    return Container(
      height: 32,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              width: 130,
              child: Text(Strings.host,
                  style: TextStyle(
                      fontSize: 14,
                      color: UIColors.color_94979A,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w400))),
          Expanded(
            child: Text(getHostName(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14,
                    color: UIColors.black_222222,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400)),
          ),
          // Spacer(),
        ],
      ),
    );
  }

  String getHostName() {
    return inRoomService.getUserInfoById(roomInfo.hostUserId)?.displayName ?? '';
  }

  Widget shadow() {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: UIColors.white,
        boxShadow: [
          BoxShadow(
            color: UIColors.color_19242744,
            offset: Offset(4, 0),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }
}
