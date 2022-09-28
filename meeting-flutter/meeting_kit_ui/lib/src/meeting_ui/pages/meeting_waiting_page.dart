// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingWaitingPage extends StatefulWidget {
  final MeetingWaitingArguments waitingArguments;

  MeetingWaitingPage(this.waitingArguments);

  @override
  State<StatefulWidget> createState() => MeetingWaitingPageState();
}

class MeetingWaitingPageState extends BaseState<MeetingWaitingPage> {
  static const String _tag = 'MeetingWaitingPage';

  final TextEditingController _textFieldController = TextEditingController();

  int? errorCode;
  String? errorMsg;
  bool retrying = false;
  String? lastInputText;
  bool cancelled = false;

  @override
  void initState() {
    super.initState();
    assert(widget.waitingArguments.waitingType ==
        _MeetingWaitingType.verifyPassword);

    /// 忽略"密码未输入"错误
    if (widget.waitingArguments.joinParams.password.isNotEmpty) {
      errorCode = widget.waitingArguments.initWaitCode;
      errorMsg = widget.waitingArguments.initWaitMsg;
    }
    notifyStatusChangeWait();
  }

  void notifyStatusChangeWait() {
    MeetingCore().notifyStatusChange(NEMeetingStatus(NEMeetingEvent.waiting,
        arg: NEMeetingCode.verifyPassword));
  }

  @override
  void dispose() {
    if (errorCode != NEErrorCode.success && flutterEngineCanRecycle()) {
      EventBus().emit(NEMeetingUIEvents.flutterPageDisposed);
    }
    super.dispose();
  }

  bool flutterEngineCanRecycle() {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _UIColors.color_292933,
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
                  key: MeetingUIValueKeys.inputMeetingPassword,
                  autofocus: true,
                  controller: _textFieldController,
                  placeholder: _Strings.inputMeetingPassword,
                  placeholderStyle: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.placeholderText,
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  onChanged: _onTextChanged,
                  onEditingComplete: canRetryJoining() ? _verifyPassword : null,
                  textInputAction: TextInputAction.go,
                  clearButtonMode: OverlayVisibilityMode.editing,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                        NEMeetingConstants.meetingPasswordMaxLen),
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
            key: MeetingUIValueKeys.inputMeetingPasswordJoinMeeting,
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
      final error =
          errorCode == NEErrorCode.badPassword ? _Strings.wrongPassword : '';
      return error.isNotEmpty
          ? Padding(
              padding: EdgeInsets.only(right: 6),
              child: Text(
                error,
                style:
                    const TextStyle(fontSize: 13, color: _UIColors.colorF24957),
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
      _textFieldController.text.length >=
          NEMeetingConstants.meetingPasswordMinLen &&
      _textFieldController.text.length <=
          NEMeetingConstants.meetingPasswordMaxLen &&
      errorCode == null;

  void cancel([int code = NEMeetingErrorCode.cancelled, String? msg]) {
    cancelled = true;
    errorCode = code;
    errorMsg = msg;
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: ' cancel joining: $errorCode $errorMsg');
    Navigator.of(context).pop(NEResult(code: errorCode!, msg: errorMsg));
  }

  void _verifyPassword() {
    setState(() {
      retrying = true;
      retryJoinMeeting();
    });
  }

  void retryJoinMeeting() {
    Connectivity().checkConnectivity().then((result) async {
      if (result == ConnectivityResult.none) {
        cancel(MeetingErrorCode.networkError);
        return;
      }

      // MeetingCore()
      //     .notifyStatusChange(NEMeetingStatus(NEMeetingEvent.connecting));
      final arguments = widget.waitingArguments;
      final joinResult =
          await NEMeetingKit.instance.getMeetingService().joinMeeting(
                arguments.joinParams.copy(password: _textFieldController.text),
                arguments.joinOpts,
              );
      onRetryResult(joinResult.code, joinResult.msg, joinResult.data);
    });
  }

  void onRetryResult([int? code, String? msg, NERoomContext? data]) {
    if (cancelled) return;
    errorCode = code;
    errorMsg = msg;
    if (code == NEErrorCode.success) {
      //Navigator.of(context).pushReplacementNamed('meeting_page', arguments: argument);
      Navigator.of(context).pop(data);
    } else if (code == NEErrorCode.badPassword) {
      setState(() {
        retrying = false;
      });
    } else {
      cancel(code!, msg);
    }
  }

  // @override
  // void onAuthInfoExpired() {
  //   Alog.i(
  //       tag: _tag,
  //       moduleName: _moduleName,
  //       content: 'auth info expired on waiting page');
  //   cancel(MeetingErrorCode.unauthorized);
  // }
  //
  // @override
  // void onKickOut() {
  //   Alog.i(
  //       tag: _tag,
  //       moduleName: _moduleName,
  //       content: 'im kicked out on waiting page');
  //   cancel(MeetingErrorCode.unauthorized);
  // }
}
