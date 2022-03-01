// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class ControlMeetingWaitingPage  extends StatefulWidget{
  final ControlMeetingWaitingArguments waitingArguments;

  ControlMeetingWaitingPage(this.waitingArguments);

  @override
  State<StatefulWidget> createState() => ControlMeetingWaitingPageState(
      waitingArguments);
}

class ControlMeetingWaitingPageState extends BaseState<ControlMeetingWaitingPage> {
  StreamSubscription<MeetingAction>? subscription;

  final ControlMeetingWaitingArguments waitingArguments;

  ControlMeetingWaitingPageState(this.waitingArguments);

  static const int meetingPasswordMinLen = 4;
  static const int meetingPasswordMaxLen = 20;

  final TextEditingController _textFieldController = TextEditingController();

  int? errorCode;
  String? errorMsg;
  bool retrying = false;
  String? lastInputText;
  bool cancelled = false;


  @override
  void initState() {
    super.initState();
    _registerTVControlListener();
  }

  void retryJoinMeeting() {
    final param = widget.waitingArguments;
    ControlInMeetingRepository.joinMeeting(JoinMeetingData(
        requestIdJoinMeetingPassword,
        ControlProfile.nickName!,
        param.videoMute,
        param.audioMute,
        param.meetingId,
        password: param.password)).then((result) {
      if(result.code == RoomErrorCode.networkError) {
        ToastUtils.showToast(context, _Strings.networkUnavailable);
      }
    });
  }

  void _registerTVControlListener() {
    var stream = ControlInMeetingRepository.controlMessageStream();
    subscription = stream.listen((MeetingAction action) {

      if (action.type == TCProtocol.joinMeetingResult2Controller &&
          (action as TCControlCreateOrJoinAction).requestId ==
              requestIdJoinMeetingPassword) {
        ///校验tv权限
        var errorCode = action.code;
        var msg = action.msg;
        var avRoomUid = action.avRoomUid;
        var meetingId = action.meetingId;
        var audioAllMute = action.audioAllMute;
        var meetingInfo = ControlJoinMeetingInfo(
            avRoomUid: avRoomUid,
            meetingId: meetingId,
            audioAllMute: audioAllMute,
        );
        onRetryResult(errorCode, msg, meetingInfo);
      }
    });
  }

  void onRetryResult([int? code, String? msg, dynamic meetingInfoObject]) {
    if(cancelled) return;
    errorCode = code;
    errorMsg = msg;
    if (code == RoomErrorCode.success) {
      _NavUtils.toControlMeetingPage(context, ControlMeetingArguments(
              meetingInfo: meetingInfoObject as ControlJoinMeetingInfo,
              tvStatus: waitingArguments.tvStatus,
              pairId: waitingArguments.pairId,
              options: waitingArguments.options,));
    } else if (code == RoomErrorCode.roomPasswordNotPresent || code == RoomErrorCode.roomPasswordError) {
      setState(() {
        retrying = false;
      });
    } else {
      cancel(code!);
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  void cancel([int code = RoomErrorCode.cancelled, String? msg]) {
    cancelled = true;
    errorCode = code;
    errorMsg = msg;
    Alog.i(
        tag: runtimeType.toString(),
        moduleName: _moduleName,
        content:
        ' cancel joining: $errorCode $errorMsg');
    Navigator.of(context).pop(NEResult(code: errorCode!, msg: errorMsg));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: UIColors.color_292933,
      child: Center(
        child: buildEnterPasswordUI(),
      ),
    );
  }


  Widget buildEnterPasswordUI() {
    return CupertinoAlertDialog(
      title: Text(_Strings.meetingPassword),
      content: Container(
          margin: EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CupertinoTextField(
                  key: ControllerMeetingCoreValueKey.inputMeetingPassword,
                  autofocus: true,
                  controller: _textFieldController,
                  placeholder: _Strings.inputMeetingPassword,
                  placeholderStyle: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.placeholderText,
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  maxLength: meetingPasswordMaxLen,
                  onChanged: _onTextChanged,
                  onEditingComplete: canRetryJoining() ? _verifyPassword : null,
                  textInputAction: TextInputAction.go,
                  clearButtonMode: OverlayVisibilityMode.editing,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(meetingPasswordMaxLen),
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z]')),
                  ],
                  suffix: buildSuffix()),
            ],
          )),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text(_Strings.cancel),
          onPressed: cancel,
        ),
        CupertinoDialogAction(
            key: ControllerMeetingCoreValueKey.inputMeetingPasswordJoinMeeting,
            child: Text(_Strings.joinMeeting),
            onPressed: canRetryJoining() ? _verifyPassword : null),
      ],
    );
  }

  Widget buildSuffix() {
    if (retrying) {
      return Padding(
          padding: EdgeInsets.only(right: 6),
          child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              )));
    } else {
      final error = errorCode == RoomErrorCode.roomPasswordError
          ? _Strings.wrongPassword
          : '';
      return error.isNotEmpty
          ? Padding(
        padding: EdgeInsets.only(right: 6),
        child: Text(
          error,
          style:
          const TextStyle(fontSize: 13, color: UIColors.colorF24957),
        ),
      )
          : Container();
    }
  }

  void _onTextChanged(String value) {
    if (value != lastInputText) {
      setState(() {
        lastInputText = value;
        errorCode = null;
        errorMsg = null;
      });
    }
  }

  bool canRetryJoining() =>
      !retrying &&
          !cancelled &&
          _textFieldController.text.length >= meetingPasswordMinLen &&
          _textFieldController.text.length <= meetingPasswordMaxLen &&
          errorCode == null;

  void _verifyPassword() {
    setState(() {
      retrying = true;
      widget.waitingArguments.password = _textFieldController.text;
      retryJoinMeeting();
    });
  }

}
