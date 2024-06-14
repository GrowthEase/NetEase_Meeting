// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 邀请页面
class MeetingInvitePage extends StatefulWidget {
  final String roomUuid;
  const MeetingInvitePage({Key? key, required this.roomUuid}) : super(key: key);

  @override
  _MeetingInvitePageState createState() => _MeetingInvitePageState();
}

class _MeetingInvitePageState extends State<MeetingInvitePage> {
  final TextEditingController sipNumber = TextEditingController(),
      sipHost = TextEditingController();

  final invitations = <NERoomInvitation>[];
  final sipNumberFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    updateInviteList();
    sipNumberFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    sipNumberFocusNode.dispose();
  }

  void updateInviteList() {
    InRoomRepository.getInviteList(widget.roomUuid).then((value) {
      if (mounted && value.isSuccess()) {
        setState(() {
          invitations
            ..clear()
            ..addAll(value.nonNullData);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xffF2F3F5),
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.only(left: 30),
              child: Text(
                NEMeetingUIKitLocalizations.of(context)!.meetingInvitePageTitle,
                style: TextStyle(
                  fontSize: 28,
                  color: _UIColors.black_222222,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 25),
            buildInput(
                NEMeetingUIKitLocalizations.of(context)!.meetingSipNumber,
                sipNumber),
            SizedBox(height: 20),
            buildInput(NEMeetingUIKitLocalizations.of(context)!.meetingSipHost,
                sipHost),
            buildInviteButton(),
            Expanded(
              child: inviteList(),
            ),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(''),
      centerTitle: true,
      backgroundColor: _UIColors.white,
      elevation: 0.0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: const Icon(
          NEMeetingIconFont.icon_yx_returnx,
          color: _UIColors.black_333333,
          size: 18,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget buildInput(String hint, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30),
      child: Theme(
        data: ThemeData(hintColor: _UIColors.greyDCDFE5),
        child: TextField(
          key: hint == NEMeetingUIKitLocalizations.of(context)!.meetingSipNumber
              ? MeetingUIValueKeys.sipNumber
              : MeetingUIValueKeys.sipHost,
          autofocus: true,
          style: TextStyle(color: _UIColors.color_333333, fontSize: 17),
          focusNode: sipNumberFocusNode,
          cursorColor: _UIColors.blue_337eff,
          controller: controller,
          textAlign: TextAlign.left,
          onChanged: (value) {
            setState(() {});
          },
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.only(top: 11, bottom: 11),
              hintText: hint,
              hintStyle: TextStyle(fontSize: 17, color: _UIColors.greyB0B6BE),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: _UIColors.color_337eff,
                    width: 1,
                    style: BorderStyle.solid),
              ),
              suffixIcon: !sipNumberFocusNode.hasFocus ||
                      TextUtils.isEmpty(controller.text)
                  ? null
                  : ClearIconButton(
                      onPressed: () {
                        controller.clear();
                        setState(() {});
                      },
                    )),
        ),
      ),
    );
  }

  Container buildInviteButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(30, 25, 30, 38),
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.disabled)) {
                return _UIColors.blue_50_337eff;
              }
              return _UIColors.blue_337eff;
            }),
            padding:
                MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 13)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                side: BorderSide(
                    color: inviteEnable
                        ? _UIColors.blue_337eff
                        : _UIColors.blue_50_337eff,
                    width: 0),
                borderRadius: BorderRadius.all(Radius.circular(25))))),
        onPressed: inviteEnable ? invite : null,
        child: Text(
          NEMeetingUIKitLocalizations.of(context)!.globalAdd,
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget inviteList() {
    if (invitations.isEmpty) {
      return Container();
    }
    final items = invitations.toSet().toList();
    return Padding(
      padding: EdgeInsets.only(left: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 50,
            alignment: Alignment.centerLeft,
            child: Text(
              NEMeetingUIKitLocalizations.of(context)!.meetingInviteListTitle,
              style: TextStyle(
                color: _UIColors.color_999999,
                fontSize: 16,
              ),
            ),
          ),
          Divider(
            height: 1,
            color: _UIColors.globalBg,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: invitations.length * 2,
              itemBuilder: (context, index) {
                if (index.isOdd) {
                  return Divider(
                    height: 1,
                    color: _UIColors.globalBg,
                  );
                }
                return Container(
                  height: 50,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    items[index ~/ 2].sipNum,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _UIColors.color_333333,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool get inviteEnable {
    return !TextUtils.isEmpty(sipNumber.text.trim()) &&
        !TextUtils.isEmpty(sipHost.text.trim());
  }

  void invite() {
    InRoomRepository.invite(
        widget.roomUuid,
        NERoomInvitation(
          sipNum: sipNumber.text.trim(),
          sipHost: sipHost.text.trim(),
        )).then((result) {
      if (!mounted) return;
      if (result.isSuccess()) {
        sipNumber.clear();
        sipHost.clear();
        FocusScope.of(context).unfocus();
        updateInviteList();
      }
      ToastUtils.showToast(
          context,
          result.isSuccess()
              ? NEMeetingUIKitLocalizations.of(context)!
                  .meetingInvitationSendSuccess
              : (result.msg ??
                  NEMeetingUIKitLocalizations.of(context)!
                      .meetingInvitationSendFail));
    });
  }
}
