// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class ControlNickSettingPage extends StatefulWidget {
  final ControlArguments arguments;

  ControlNickSettingPage(this.arguments);
  
  @override
  State<StatefulWidget> createState() {
    return _ControlNickSettingPageState(arguments);
  }
}

class _ControlNickSettingPageState extends ControlBaseState<ControlNickSettingPage> {
  static const _tag = 'ControlNickSettingPage';
  StreamSubscription<MeetingAction>? subscription;
  late TextEditingController _textController;
  VoidCallback? focusCallback;
  bool enable = false;

  final ControlArguments controlArguments;

  _ControlNickSettingPageState(this.controlArguments);

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: controlArguments.tvStatus?.tvNick ?? '');
    enable = _textController.text.isNotEmpty;
    registerTVControlListener();
  }

  @override
  Widget buildBody() {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: <Widget>[
            Container(
              color: UIColors.globalBg,
              height: _Dimen.globalPadding,
            ),
            Container(
              height: _Dimen.primaryItemHeight,
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: _Dimen.globalPadding),
              alignment: Alignment.center,
              child: TextField(
                autofocus: false,
                controller: _textController,
                keyboardAppearance: Brightness.light,
                textAlignVertical: TextAlignVertical.bottom,
                onChanged: (value) {
                  enable = _textController.text.isNotEmpty;
                  setState(() {});
                },
                decoration: InputDecoration(
                    fillColor: Colors.white,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    suffixIcon: TextUtils.isEmpty(_textController.text)
                        ? null
                        : ClearIconButton(
                            onPressed: () {
                              _textController.clear();
                              enable = _textController.text.isNotEmpty;
                              setState(() {});
                            },
                          )),
                style: TextStyle(color: UIColors.color_222222, fontSize: 16),

              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: UIColors.globalBg,
              ),
            )
          ],
        ));
  }

  @override
  String getTitle() {
    return _Strings.nickSetting;
  }

  @override
  List<Widget> buildActions() {
    return <Widget>[
      TextButton(
        child: Text(
          _Strings.done,
          style: TextStyle(
            color: enable ? UIColors.color_337eff : UIColors.blue_50_337eff,
            fontSize: 16.0,
          ),
        ),
        onPressed: enable ? modifyTVNick : null,
      )
    ];
  }

  void modifyTVNick(){
    ControlInMeetingRepository.modifyTVNick(_textController.text)
        .then((value) {
      if (value.code == ControlCode.success) {
        controlArguments.tvStatus?.tvNick = _textController.text;
        ToastUtils.showToast(
            MeetingControl.controlNavigatorKey.currentContext!,
            _Strings.nickSettingSuccess);
        _NavUtils.pop(context, arguments: _textController.text);

      } else if (value.code == RoomErrorCode.networkError) {
        ToastUtils.showToast(
            MeetingControl.controlNavigatorKey.currentContext!,
            _Strings.nickSettingFailed);
      }
    });
  }

  void registerTVControlListener() {
    var stream = ControlInMeetingRepository.controlMessageStream();
    subscription = stream.listen((MeetingAction action) {
      if (action.type == TCProtocol.modifyTVNickResult) {
        onModifyTVNickNameResult(action as TCResultAction);
      }
    });
  }

  void onModifyTVNickNameResult(TCResultAction resultAction){
    if(resultAction.code == RoomErrorCode.success){
      ToastUtils.showToast(
          MeetingControl.controlNavigatorKey.currentContext!,
          _Strings.nickSettingSuccess);
    }else{
      ToastUtils.showToast(
          MeetingControl.controlNavigatorKey.currentContext!,
          resultAction.msg ?? _Strings.nickSettingFailed);
    }
  }

  @override
  void dispose() {
    _unregisterListener();
    _textController.dispose();
    super.dispose();
  }

  void _unregisterListener() {
    subscription?.cancel();
    Alog.d(tag: _tag,moduleName: _moduleName, content: 'subscription is canceled');
  }
}
