// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class ControlMeetJoinPage extends StatefulWidget {
  final ControlArguments arguments;

  ControlMeetJoinPage(this.arguments);

  @override
  State<StatefulWidget> createState() {
    return _ControlMeetJoinPageState(arguments);
  }
}

class _ControlMeetJoinPageState extends ControlBaseState<ControlMeetJoinPage> {
  static const  _tag = 'ControlMeetJoinPage';
  bool openCamera = true;

  bool openMicrophone = true;

  late TextEditingController _meetingIdController;

  bool joinEnable = false;

  late StreamSubscription<MeetingAction> subscription;

  final ControlArguments controlArguments;

  late String _meetingId;

  _ControlMeetJoinPageState(this.controlArguments);

  @override
  void initState() {
    super.initState();
    _meetingIdController = TextEditingController(text: '');
    joinEnable = false;
    _registerTVControlListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.white,
      appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                key: ControllerMeetingCoreValueKey.back,
                icon: const Icon(
                  NEMeetingIconFont.icon_yx_returnx,
                  size: 18,
                  color: UIColors.black_333333,
                ),
                onPressed: () {
                  Navigator.maybePop(context);
                },
              );
            },
          ),
          brightness: Brightness.light,
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text('')),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 16),
            buildJoinTitle(),
            buildMeetingIdInput(),
            SizedBox(
              height: 12,
            ),
            buildCameraItem(),
            buildMicrophoneItem(),
            buildJoin()
          ],
        ),
      ),
    );
  }

  Container buildJoinTitle() {
    return Container(
      padding: EdgeInsets.only(left: 30),
      child: Text(
        _Strings.joinMeeting,
        style: TextStyle(fontSize: 28, color: UIColors.black_222222, fontWeight: FontWeight.w500),
      ),
    );
  }

  Container buildMeetingIdInput() {
    return Container(
      padding: EdgeInsets.only(left: 30, right: 30, top: 24),
      child: Theme(
        data: ThemeData(hintColor: UIColors.greyDCDFE5),
        child: TextField(
          autofocus: true,
          inputFormatters: [
            LengthLimitingTextInputFormatter(meetingIdMaxLength),
            FilteringTextInputFormatter.allow(RegExp(r'\d+')),
          ],
          keyboardType: TextInputType.number,
          keyboardAppearance: Brightness.light,
          controller: _meetingIdController,
          textAlign: TextAlign.left,
          onChanged: (value) {
            _onMeetingIdChanged();
            setState(() {});
          },
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.only(top: 11, bottom: 11),
              hintText: _Strings.inputMeetingId,
              hintStyle: TextStyle(fontSize: 17, color: UIColors.greyB0B6BE),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: UIColors.blue_337eff),
              ),
              suffixIcon: TextUtils.isEmpty(_meetingIdController.text)
                  ? null
                  : ClearIconButton(
                      onPressed: () {
                        _meetingIdController.clear();
                        _onMeetingIdChanged();
                        setState(() {});
                      },
                    )),
        ),
      ),
    );
  }

  Container buildCameraItem() {
    return Container(
      height: 56,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              _Strings.openCameraEnterMeeting,
              style: TextStyle(color: UIColors.black_222222, fontSize: 14),
            ),
          ),
          ControllerMeetingCoreValueKey.addTextWidgetTest(valueKey: ControllerMeetingCoreValueKey.openCameraJoinMeeting, value: openCamera),
          CupertinoSwitch(
            key: ControllerMeetingCoreValueKey.openCameraJoinMeeting,
            value: openCamera,
            onChanged: (bool value) {
              setState(() {
                openCamera = value;
              });
            },
            activeColor: UIColors.blue_337eff,
          )
        ],
      ),
    );
  }

  Container buildMicrophoneItem() {
    return Container(
      height: 56,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              _Strings.openMicroEnterMeeting,
              style: TextStyle(color: UIColors.black_222222, fontSize: 14),
            ),
          ),
          ControllerMeetingCoreValueKey.addTextWidgetTest(
              valueKey: ControllerMeetingCoreValueKey.openMicrophoneJoinMeeting, value: openMicrophone),
          CupertinoSwitch(
              key: ControllerMeetingCoreValueKey.openMicrophoneJoinMeeting,
              value: openMicrophone,
              onChanged: (bool value) {
                setState(() {
                  openMicrophone = value;
                });
              },
              activeColor: UIColors.blue_337eff)
        ],
      ),
    );
  }

  Container buildJoin() {
    return Container(
      padding: EdgeInsets.all(30),
      child: ElevatedButton(
        key: ControllerMeetingCoreValueKey.joinMeetingBtn,
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(UIColors.blue_337eff),
            padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 13)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                side: BorderSide(color: UIColors.blue_337eff), borderRadius: BorderRadius.all(Radius.circular(25))))),
        onPressed: joinEnable ? _onJoinMeeting : null,
        child: Text(
          _Strings.joinMeeting,
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),

      ),
    );
  }

  void _onJoinMeeting() {
    _meetingId = _meetingIdController.text.replaceAll(RegExp(r'-'), '');

    Alog.d(tag: _tag,moduleName: _moduleName, content: 'join meeting meetingId = $_meetingId');
    ControlInMeetingRepository.joinMeeting(JoinMeetingData(
        requestIdJoinMeetingCommon, ControlProfile.nickName!, !openCamera,
        !openMicrophone, _meetingId)).then((result) {
      if (result.code == RoomErrorCode.networkError) {
        ToastUtils.showToast(context, _Strings.networkUnavailable);
      }
    });
  }

  @override
  Widget? buildBody() {
    return null;
  }

  @override
  String? getTitle() {
    return null;
  }

  void _onMeetingIdChanged() {
    var meetingId = _meetingIdController.text;
    joinEnable = meetingId.length >= meetingIdMinLength;
  }

  void _registerTVControlListener() {
    var stream = ControlInMeetingRepository.controlMessageStream();
    subscription = stream.listen((MeetingAction action) {

      if (action is TCControlCreateOrJoinAction && action.requestId == requestIdJoinMeetingCommon) {
        ///校验tv权限
        var errorCode = action.code;
        var msg = action.msg;
        if (errorCode == -1) {
          ToastUtils.showToast(context, msg!);
          return;
        }

        var avRoomUid = action.avRoomUid;
        var audioAllMute = action.audioAllMute;
        var meetingId = action.meetingId;

        if (errorCode == RoomErrorCode.success) {
          Alog.d(tag: _tag,moduleName: _moduleName, content: 'meetId =  + $meetingId');

          var meetingInfo = ControlJoinMeetingInfo(
              avRoomUid: avRoomUid,
              audioAllMute: audioAllMute,
              meetingId: meetingId,
          );

          _NavUtils.toControlMeetingPage(context, ControlMeetingArguments(
            meetingInfo: meetingInfo,
            tvStatus: controlArguments.tvStatus,
            options: ControllerMeetingOptions(injectedToolbarMenuItems: controlArguments.opts?.injectedToolbarMenuItems,
              injectedMoreMenuItems: controlArguments.opts?.injectedMoreMenuItems,
              videoMute: !openCamera,
              audioMute: !openMicrophone,),
            pairId: controlArguments.pairCode,
          ));
        } else if (errorCode == RoomErrorCode.roomPasswordError ||
            errorCode == RoomErrorCode.roomPasswordNotPresent) {
          _NavUtils.toControlMeetingWaitingPage(context,
              ControlMeetingWaitingArguments.verifyPassword(
                0,
                tvStatus: controlArguments.tvStatus,
                meetingId: _meetingId,
                displayName: ControlProfile.nickName,
                audioAllMute: audioAllMute,
                options: ControllerMeetingOptions(
                  anonymous: false,
                  videoMute: !openCamera,
                  audioMute: !openMicrophone,
                  restorePreferredOrientations: [DeviceOrientation.portraitUp],
                  injectedToolbarMenuItems: controlArguments.opts?.injectedToolbarMenuItems,
                  injectedMoreMenuItems: controlArguments.opts?.injectedMoreMenuItems,
                ),

              ));
        }
        MeetingControl().notifyJoinMeetingResult(ControlResult(action.code, action.msg));
      }
    });
  }

  @override
  void dispose() {
    _meetingIdController.dispose();
    subscription.cancel();
    super.dispose();
  }
}
