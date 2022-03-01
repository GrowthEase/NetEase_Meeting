// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

/// tv配对码
class ControlPairPage extends StatefulWidget {
  final ControlArguments arguments;

  ControlPairPage(this.arguments);

  @override
  State<StatefulWidget> createState() {
    return _ControlPairState(arguments);
  }
}

class _ControlPairState extends ControlBaseState<ControlPairPage> {
  static const _tag = 'ControlPairPage';
  final int pinLength = 6;
  final TextEditingController _pinEditingController =
      TextEditingController(text: '');
  bool alreadyGetTVInfo = false;

  final ControlArguments arguments;

  _ControlPairState(this.arguments);

  @override
  void initState() {
    super.initState();
    _pinEditingController.selection = TextSelection.collapsed(
        offset: _pinEditingController.text.runes.length);
    ControlMessageListener().init();
  }

  @override
  void dispose() {
    _pinEditingController.dispose();
    EventBus().emit(UIEventName.flutterEngineCanRecycle);
    super.dispose();
  }

  @override
  Widget buildBody() {
    return Container(
      color: UIColors.white,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.only(top: 24),
              child: Text(
                _Strings.inputTVPair,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: UIColors.color_222222,
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 300,
                height: 40,
                margin: EdgeInsets.only(top: 30),
                child: Container(
                  height: 40,
                  child: PinInputTextField(
                    pinLength: pinLength,
                    decoration: BoxLooseDecoration(
                      strokeColorBuilder: PinListenColorBuilder(
                          UIColors.color_337eff, UIColors.colorC9CFE5),
                      bgColorBuilder: FixedColorBuilder(UIColors.white),
                      strokeWidth: 1,
                      gapSpace: 12,
                      obscureStyle: ObscureStyle(
                        isTextObscure: false,
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[a-z,A-Z]')),
                    ],
                    autoFocus: true,
                    controller: _pinEditingController,
                    textInputAction: TextInputAction.go,
                    enabled: true,
                    onSubmit: (pin) {
                      debugPrint('submit pin:$pin');
                    },
                    onChanged: (pin) {
                      final text = pin.toUpperCase();
                      _pinEditingController.value =
                          _pinEditingController.value.copyWith(
                        text: text,
                        selection: TextSelection(
                            baseOffset: text.length, extentOffset: text.length),
                        composing: TextRange.empty,
                      );
                      if (pin.length == pinLength) {
                        if (!alreadyGetTVInfo) {
                          getTVInfoServer();
                        }
                        alreadyGetTVInfo = true;
                      } else {
                        alreadyGetTVInfo = false;
                      }
                      debugPrint('onChanged execute. pin:$pin');
                    },
                  ),
                ),
              ),
            ),
          ]),
    );
  }

  void getTVInfoServer() {
    if (alreadyGetTVInfo) {
      return;
    }
    alreadyGetTVInfo = true;
    var pairId = _pinEditingController.text;
    _pair(pairId).then((result) {
      final data = result.data;
      if (result.code == ControlCode.success && data != null) {
        if (UserProfile.appKey != data.appKey) {
          _pinEditingController.text = '';
          ToastUtils.showToast(context, _Strings.notSupportPairOtherCompanyTV);
          return;
        }

        KeyboardUtils.dismissKeyboard(context);
        ControlProfile.pairedAccountId = data.accountId;

        var tvProtocolVersion = data.extra.tvProtocolVersion;

        /// 校验tvProtocol版本，http://doc.hz.netease.com/pages/viewpage.action?pageId=258421362
        var isProtocolFallBehind = isTCProtocolFallBehind(
            TCProtocol.controllerProtocolVersion, tvProtocolVersion);
        var isProtocolCompatible = isTCProtocolCompatible(
            TCProtocol.controllerProtocolVersion, tvProtocolVersion);
        Alog.d(
            tag: _tag,
            moduleName: _moduleName,
            content:
                'getTVInfoServer controllerProtocolVersion = ${TCProtocol.controllerProtocolVersion}, '
                'tvProtocolVersion = $tvProtocolVersion');
        Alog.d(
            tag: _tag,
            moduleName: _moduleName,
            content:
                'getTVInfoServer isProtocolFallBehind = $isProtocolFallBehind, '
                'isProtocolCompatible = $isProtocolCompatible');

        if (isProtocolFallBehind) {
          MeetingControl().notifyTCProtocolUpgrade(TCProtocolUpgrade(
              TCProtocol.controllerProtocolVersion,
              tvProtocolVersion,
              isProtocolCompatible));
        }
        if (isProtocolCompatible) {
          _NavUtils.push(
              context,
              _PageName.controlHome,
              ControlHomePage(ControlArguments(
                  opts: arguments.opts,
                  fromRoute: _PageName.controlPair,
                  pairCode: _pinEditingController.text)));
        } else {
          _pinEditingController.text = '';
        }
      } else if (result.code == RoomErrorCode.notLogin) {
        ToastUtils.showToast(context, _Strings.loginError);
      } else {
        ToastUtils.showToast(context, ControlCode.getMsg(result.msg)!);
        _pinEditingController.text = '';
      }
    });
  }

  bool isTCProtocolFallBehind(
      String controllerProtocolVersion, String? tvProtocolVersion) {
    if (TextUtils.isEmpty(tvProtocolVersion)) {
      return false;
    }
    var controllerProtocolVersions = controllerProtocolVersion.split('.');
    var tvProtocolVersions = tvProtocolVersion?.split('.');
    if (tvProtocolVersions == null || tvProtocolVersions.length < 2) {
      return false;
    }
    var controllerProtocolVersionPre = int.parse(controllerProtocolVersions[0]);
    var controllerProtocolVersionSuf = int.parse(controllerProtocolVersions[1]);
    var tvProtocolVersionPre = int.parse(tvProtocolVersions[0]);
    var tvProtocolVersionSuf = int.parse(tvProtocolVersions[1]);
    return controllerProtocolVersionPre < tvProtocolVersionPre ||
        ((controllerProtocolVersionPre == tvProtocolVersionPre) &&
            (controllerProtocolVersionSuf < tvProtocolVersionSuf));
  }

  bool isTCProtocolCompatible(
      String controllerProtocolVersion, String? tvProtocolVersion) {
    if (TextUtils.isEmpty(tvProtocolVersion)) {
      return true;
    }
    var controllerProtocolVersions = controllerProtocolVersion.split('.');
    var tvProtocolVersions = tvProtocolVersion?.split('.');
    if (tvProtocolVersions == null || tvProtocolVersions.length < 2) {
      return true;
    }
    var controllerProtocolVersionPre = int.parse(controllerProtocolVersions[0]);
    var tvProtocolVersionPre = int.parse(tvProtocolVersions[0]);
    return controllerProtocolVersionPre >= tvProtocolVersionPre;
  }

  Future<NEResult<TVInfo>> _pair(String pairId) async {
    //底层处理im是否登录的逻辑，这里不需要再check了
    return ControlPairRepo.getTVInfo(pairId);
  }

  @override
  String getTitle() {
    return '';
  }

  @override
  void onNavigationBack() {
    UINavUtils.pop(context, rootNavigator: true);
    MeetingControl().isAlreadyOpenControl = false;
  }
}
