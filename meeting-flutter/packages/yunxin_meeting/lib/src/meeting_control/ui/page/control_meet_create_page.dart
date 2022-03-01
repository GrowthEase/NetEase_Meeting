// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class ControlMeetCreatePage extends StatefulWidget {
  final ControlArguments arguments;

  ControlMeetCreatePage(this.arguments);

  @override
  State<StatefulWidget> createState() {
    return _ControlMeetCreatePageState(arguments);
  }
}

class _ControlMeetCreatePageState extends ControlBaseState<ControlMeetCreatePage> {
  bool userSelfMeetingId = false;

  bool openCamera = true;

  bool openMicrophone = true;

  StreamSubscription<MeetingAction>? subscription;

  ControlArguments controlArguments;

  _ControlMeetCreatePageState(this.controlArguments);

  @override
  void initState() {
    super.initState();
    _registerTVControlListener();
  }

  Container buildSplit() {
    return Container(
      padding: EdgeInsets.only(left: 20),
      height: 1,
    );
  }

  Container buildCameraItem() {
    return Container(
      height: 56,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              _Strings.openCameraEnterMeeting,
              style: TextStyle(color: UIColors.black_222222, fontSize: 16),
            ),
          ),
          ControllerMeetingCoreValueKey.addTextWidgetTest(
              valueKey: ControllerMeetingCoreValueKey.openCameraCreateMeeting, value: openCamera),
          CupertinoSwitch(
              key: ControllerMeetingCoreValueKey.openCameraCreateMeeting,
              value: openCamera,
              onChanged: (bool value) {
                setState(() {
                  openCamera = value;
                });
              },
              activeColor: UIColors.blue_337eff)
        ],
      ),
    );
  }

  Container buildMicrophoneItem() {
    return Container(
      height: 56,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              _Strings.openMicroEnterMeeting,
              style: TextStyle(color: UIColors.black_222222, fontSize: 16),
            ),
          ),
          ControllerMeetingCoreValueKey.addTextWidgetTest(
              valueKey: ControllerMeetingCoreValueKey.openMicrophoneCreateMeeting, value: openMicrophone),
          CupertinoSwitch(
              key: ControllerMeetingCoreValueKey.openMicrophoneCreateMeeting,
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

  Container buildCreate() {
    return Container(
      padding: EdgeInsets.all(30),
      child: ElevatedButton(
        key: ControllerMeetingCoreValueKey.createMeetingBtn,
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(UIColors.blue_337eff),
            padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 13)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                side: BorderSide(color: UIColors.blue_337eff), borderRadius: BorderRadius.all(Radius.circular(25))))),
        onPressed: onCreateMeeting,
        child: Text(
          _Strings.createMeeting,
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void onCreateMeeting() {
    ControlInMeetingRepository.createMeeting(CreateMeetingData(
            ControlProfile.nickName!, !openCamera, !openMicrophone, userSelfMeetingId ? UserProfile.meetingId! : ''))
        .then((result) {
      if (result.code == RoomErrorCode.networkError) {
        ToastUtils.showToast(context, _Strings.networkUnavailable);
      }
    });
  }

  @override
  Widget buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: 10),
        buildSplit(),
        buildCameraItem(),
        buildSplit(),
        buildMicrophoneItem(),
        buildCreate()
      ],
    );
  }

  @override
  String getTitle() {
    return _Strings.createMeeting;
  }

  void _registerTVControlListener() {
    var stream = ControlInMeetingRepository.controlMessageStream();
    subscription = stream.listen((MeetingAction action) {
      if (action is TCControlCreateOrJoinAction) {
        ///校验tv权限
        if (action.code == -1) {
          ToastUtils.showToast(context, action.msg);
          return;
        }

        if (action.code == RoomErrorCode.success) {
          var meetingInfo = ControlJoinMeetingInfo(
            meetingId: action.meetingId,
            avRoomUid: action.avRoomUid,
          );

          _NavUtils.toControlMeetingPage(
              context,
              ControlMeetingArguments(
                  meetingInfo: meetingInfo,
                  options: ControllerMeetingOptions(
                    restorePreferredOrientations: [DeviceOrientation.portraitUp],
                    injectedToolbarMenuItems: controlArguments.opts?.injectedToolbarMenuItems,
                    injectedMoreMenuItems: controlArguments.opts?.injectedMoreMenuItems,
                    videoMute: !openCamera,
                    audioMute: !openMicrophone,
                  ),
                  tvStatus: controlArguments.tvStatus,
                  pairId: controlArguments.pairCode));
        }
        MeetingControl().notifyStartMeetingResult(ControlResult(action.code, action.msg));
      }
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }
}
