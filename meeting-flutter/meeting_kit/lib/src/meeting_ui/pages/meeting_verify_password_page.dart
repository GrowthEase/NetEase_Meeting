// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingVerifyPasswordPage extends StatelessWidget {
  const MeetingVerifyPasswordPage({super.key, required this.arguments});

  final MeetingWaitingArguments arguments;

  @override
  Widget build(BuildContext context) {
    return NEMeetingUIKitLocalizationsScope(
      child: _VerifyPasswordPage(arguments),
    );
  }
}

class _VerifyPasswordPage extends StatefulWidget {
  final MeetingWaitingArguments waitingArguments;

  _VerifyPasswordPage(this.waitingArguments);

  @override
  State<StatefulWidget> createState() => _VerifyPasswordPageState();
}

class _VerifyPasswordPageState extends BaseState<_VerifyPasswordPage>
    with _AloggerMixin, FirstBuildScope {
  final _textFieldController = TextEditingController();
  final _focusNode = FocusNode();

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
    MeetingCore().notifyStatusChange(NEMeetingEvent(NEMeetingStatus.waiting,
        arg: NEMeetingCode.verifyPassword));
  }

  @override
  void onFirstBuild() {
    super.onFirstBuild();
    ModalRoute.of(context)!.animation?.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    _focusNode.dispose();
    if (errorCode != NEErrorCode.success && flutterEngineCanRecycle()) {
      MeetingCore().notifyStatusChange(NEMeetingEvent(NEMeetingStatus.idle));
      EventBus().emit(NEMeetingUIEvents.flutterPageDisposed);
    }
    super.dispose();
  }

  bool flutterEngineCanRecycle() {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      color: _UIColors.color_292933,
      child: Center(
        child: buildEnterPasswordUI(),
      ),
    );
    return Scaffold(
      body: child,
    );
  }

  Widget buildEnterPasswordUI() {
    return CupertinoAlertDialog(
      title: Text(NEMeetingUIKitLocalizations.of(context)!.meetingPassword),
      content: Container(
          margin: EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CupertinoTextField(
                  key: MeetingUIValueKeys.inputMeetingPassword,
                  focusNode: _focusNode,
                  controller: _textFieldController,
                  placeholder: NEMeetingUIKitLocalizations.of(context)!
                      .meetingEnterPassword,
                  placeholderStyle: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.placeholderText,
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  // obscureText: true,
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
          child: Text(NEMeetingUIKitLocalizations.of(context)!.globalCancel),
          onPressed: () {
            calculateWaitingElapsed();
            cancel();
          },
        ),
        CupertinoDialogAction(
            key: MeetingUIValueKeys.inputMeetingPasswordJoinMeeting,
            child: Text(NEMeetingUIKitLocalizations.of(context)!
                .waitingRoomJoinMeeting),
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
      final error = errorCode == NEErrorCode.badPassword
          ? NEMeetingUIKitLocalizations.of(context)!.meetingWrongPassword
          : '';
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
    commonLogger.i('cancel joining: $errorCode $errorMsg');
    Navigator.of(context).pop(NEResult(code: errorCode!, msg: errorMsg));
  }

  void _verifyPassword() async {
    final connected = await ConnectivityManager().isConnected();
    if (!mounted) return;
    if (!connected) {
      ToastUtils.showToast(context,
          NEMeetingUIKitLocalizations.of(context)!.networkUnavailableCheck);
      return;
    }

    setState(() {
      retrying = true;
      retryJoinMeeting();
    });
  }

  void retryJoinMeeting() async {
    calculateWaitingElapsed();
    final arguments = widget.waitingArguments;
    final trackingEvent = arguments.joinParams.trackingEvent;
    final joinResult = await MeetingUIServiceHelper().joinMeeting(
      arguments.joinParams.copy(password: _textFieldController.text)
        ..trackingEvent = trackingEvent,
      arguments.joinOpts,
    );
    onRetryResult(joinResult.code, joinResult.msg, joinResult.data);
  }

  void onRetryResult([int? code, String? msg, NERoomContext? data]) {
    if (cancelled || !mounted) return;
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

  void calculateWaitingElapsed() {
    // 这里需要修正一下时间的总耗时，因为输入密码页面的时间也算在内了
    final arguments = widget.waitingArguments;
    final elapsed = arguments.startStopwatch.elapsedMilliseconds;
    arguments.joinParams.trackingEvent?.setAdjustDuration(elapsed);
    arguments.joinParams.trackingEvent
        ?.addParam(kEventParamInputPasswordElapsed, elapsed);
    print('waiting page elapsed: $elapsed');
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
