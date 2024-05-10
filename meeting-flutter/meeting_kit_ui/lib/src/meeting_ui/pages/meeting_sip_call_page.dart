// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

enum CurrentCallState {
  /// 未呼叫
  none,

  /// 呼叫中
  calling,

  /// 呼叫失败
  callFailed,

  /// 已接通
  connected,
}

/// 当前页面在进行的呼叫
class CurrentCallInfo {
  final String phoneNumber;
  final String name;
  final String? userUuid;
  final String? avatar;
  CurrentCallState state = CurrentCallState.none;
  int time = 0;
  DateTime? connectedTime;

  CurrentCallInfo(this.phoneNumber, this.name, this.userUuid, this.avatar);
}

class MeetingSipCallPage extends StatefulWidget {
  static const String routeName = "/meetingSipCall";
  final SipCallArguments arguments;

  MeetingSipCallPage(this.arguments);

  @override
  State<MeetingSipCallPage> createState() =>
      _MeetingSipCallPageState(arguments);
}

class _MeetingSipCallPageState extends LifecycleBaseState<MeetingSipCallPage>
    with MeetingKitLocalizationsMixin, _AloggerMixin {
  final SipCallArguments arguments;

  /// 1: 拨号 2: 通讯录
  int _selectedIndex = 1;

  late NERoomEventCallback _roomEventCallback;

  _MeetingSipCallPageState(this.arguments);

  @override
  void initState() {
    super.initState();

    _mobileFormatter = MaskTextInputFormatter(
        mask: '### #### ####', filter: {"#": RegExp(r'[0-9]')});

    /// 拨号盘输入框
    _mobileController = TextEditingController()
      ..addListener(() {
        final value = _mobileController.text;
        if (value.isNotEmpty) {
          /// 如果不是一次性清空，说明是手动修改号码
          _currentContact = null;
        }
        setState(() {
          _selectedContact = null;
          _phoneNumberError = false;
          _isCallBtnEnabled = value.length >= 13;
        });
        if (value.length >= 13) {
          final number = value.replaceAll(' ', '');

          /// 手机号输完整之后进行通讯录搜索
          NEMeetingKit.instance
              .getAccountService()
              .searchContacts(phoneNumber: number)
              .then((value) {
            if (value.isSuccess() &&
                value.data != null &&
                value.data!.isNotEmpty) {
              setState(() {
                _selectedContact = value.data!.first;
              });
            } else if (value.code == 3408) {
              /// 特殊错误码才展示提示
              setState(() {
                _phoneNumberError = true;
                _isCallBtnEnabled = false;
              });
            }
          });
        }
      });
    _focusNode.addListener(() {
      setState(() {
        _mobileFocus = _focusNode.hasFocus;
        if (!_mobileFocus) {
          _selectedContact = null;
        }
      });
    });

    _nameController = TextEditingController()..addListener(() {});
    _roomEventCallback = NERoomEventCallback(
      /// SIP邀请状态变更，更新当前通话信息
      memberSipStateChanged: (NERoomMember member, NERoomMember? operateBy) {
        if (member.uuid == _currentCall?.userUuid) {
          if (member.inviteState == NERoomMemberInviteState.waitingCall ||
              member.inviteState == NERoomMemberInviteState.calling) {
            setState(() {
              _currentCall?.state = CurrentCallState.calling;
              _currentCall?.connectedTime = null;
            });
          } else if (member.inviteState == NERoomMemberInviteState.rejected ||
              member.inviteState == NERoomMemberInviteState.noAnswer ||
              member.inviteState == NERoomMemberInviteState.error) {
            setState(() {
              _currentCall?.state = CurrentCallState.callFailed;
              _currentCall?.connectedTime = null;
            });
          } else if (member.inviteState == NERoomMemberInviteState.canceled) {
            setState(() {
              _currentCall = null;
            });
          }
        }
      },

      /// 成员加入房间，说明通话接通了
      memberJoinRoom: (List<NERoomMember> members) {
        if (_currentCall != null) {
          for (var element in members) {
            if (element.uuid == _currentCall!.userUuid) {
              setState(() {
                _currentCall?.state = CurrentCallState.connected;
                _currentCall?.connectedTime = DateTime.now();
              });
            }
          }
        }
      },

      /// 成员离开房间，说明通话结束了
      memberLeaveRoom: (List<NERoomMember> members) {
        if (_currentCall != null) {
          for (var element in members) {
            if (element.uuid == _currentCall!.userUuid) {
              setState(() {
                _currentCall = null;
              });
              return;
            }
          }
        }
      },
    );
    arguments.roomContext.addEventCallback(_roomEventCallback);

    /// 计时器
    _timerStreamController = StreamController<DateTime>.broadcast();

    /// 每秒发送一个事件
    _connectedTimer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      _timerStreamController.add(DateTime.now());
    });
  }

  @override
  void dispose() {
    _connectedTimer.cancel();
    _timerStreamController.close();
    arguments.roomContext.removeEventCallback(_roomEventCallback);
    _mobileController.dispose();
    _nameController.dispose();
    _focusNode.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: _UIColors.globalBg,
      appBar: TitleBar(
        title: TitleBarTitle(meetingUiLocalizations.sipCall),
        showBottomDivider: true,
      ),
      body: wrapWithWatermark(child: _buildBody()),
    );
    return AutoPopScope(
        listenable: arguments.isMySelfManagerListenable,
        onWillAutoPop: (_) {
          return !arguments.isMySelfManagerListenable.value;
        },
        child: child);
  }

  Widget _buildBody() {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(height: 20),
              _buildSegment(),
              if (_selectedIndex == 1) Expanded(child: _buildCall()),
              if (_selectedIndex == 2) Expanded(child: _buildContacts()),
            ],
          ),
        ));
  }

  _buildSegment() {
    return CupertinoSegmentedControl(
      borderColor: Colors.white,
      children: {
        1: Container(
            width: 120,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: _selectedIndex == 1
                  ? _UIColors.color_337eff
                  : _UIColors.colorEEF0F3,
            ),
            alignment: Alignment.center,
            child: Text(
              meetingUiLocalizations.sipKeypad,
              style: TextStyle(
                  color: _selectedIndex == 1
                      ? Colors.white
                      : _UIColors.color_333333,
                  fontSize: 16),
            )),
        2: Container(
            width: 120,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: _selectedIndex == 2
                  ? _UIColors.color_337eff
                  : _UIColors.colorEEF0F3,
            ),
            alignment: Alignment.center,
            child: Text(
              meetingUiLocalizations.sipBatchCall,
              style: TextStyle(
                  color: _selectedIndex == 2
                      ? Colors.white
                      : _UIColors.color_333333,
                  fontSize: 16),
            )),
      },
      groupValue: _selectedIndex,
      onValueChanged: (value) {
        setState(() {
          _selectedIndex = value;
        });
      },
    );
  }

  /* --- 拨号呼叫页面相关 --- */

  /// 当前通话的信息
  CurrentCallInfo? _currentCall;

  /// 拨号入会按钮是否可点
  bool _isCallBtnEnabled = false;

  late TextEditingController _mobileController;
  late MaskTextInputFormatter _mobileFormatter;
  final FocusNode _focusNode = FocusNode();
  bool _mobileFocus = false;
  bool _phoneNumberError = false;

  /// 当前搜索到的通讯录成员
  NEContact? _selectedContact;
  late TextEditingController _nameController;

  /// 当前选中的通讯录成员，在点击搜索到成员的时候赋值，当号码变更的时候重置
  NEContact? _currentContact;

  /// 通话时长计时
  late StreamController<DateTime> _timerStreamController;
  late Timer _connectedTimer;

  _buildCall() {
    if (_currentCall != null) {
      return _buildCalling();
    } else {
      return _buildCallInput();
    }
  }

  /// 拨号页面
  _buildCallInput() {
    return Container(
      margin: EdgeInsets.only(left: 30, right: 30, bottom: 40, top: 0),
      child: Stack(
        children: [
          Listener(
            onPointerDown: (_) {
              if (_focusNode.hasFocus) {
                _focusNode.unfocus();
              }
              if (_searchFocusNode.hasFocus) {
                _searchFocusNode.unfocus();
              }
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SizedBox(height: 30),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                  child: Stack(clipBehavior: Clip.none, children: <Widget>[
                    Row(children: <Widget>[
                      Text(
                        '+86',
                        style: TextStyle(
                            fontSize: 17, color: _UIColors.color_333333),
                      ),
                      Container(
                        height: 20,
                        child: VerticalDivider(color: _UIColors.greyB0B6BE),
                      ),
                      Expanded(
                        child: TextField(
                          style: TextStyle(
                              fontSize: 17,
                              color: _phoneNumberError
                                  ? _UIColors.colorF24957
                                  : _mobileFocus
                                      ? _UIColors.color_337eff
                                      : _UIColors.black_222222),
                          focusNode: _focusNode,
                          controller: _mobileController,
                          keyboardType: TextInputType.number,
                          cursorColor: _UIColors.color_337eff,
                          keyboardAppearance: Brightness.light,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(13),
                            _mobileFormatter
                          ],
                          decoration: InputDecoration(
                              hintText:
                                  meetingUiLocalizations.sipNumberPlaceholder,
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  fontSize: 17, color: _UIColors.greyB0B6BE),
                              suffixIconConstraints: BoxConstraints(
                                  minWidth: 0, minHeight: 0, maxHeight: 20),
                              suffixIcon: _mobileController.text.isEmpty
                                  ? null
                                  : ClearIconButton(
                                      onPressed: () {
                                        _mobileController.clear();
                                        setState(() {
                                          _isCallBtnEnabled = false;
                                        });
                                      },
                                    )),
                        ),
                        flex: 1,
                      ),
                      IconButton(
                          onPressed: _showLocalContacts,
                          icon: Image.asset(NEMeetingImages.iconContacts,
                              package: NEMeetingImages.package)),
                    ]),
                    Container(
                      margin: EdgeInsets.only(top: 35),
                      child: Divider(
                        thickness: 1,
                        color: _phoneNumberError
                            ? _UIColors.colorF24957
                            : _mobileFocus
                                ? _UIColors.color_337eff
                                : _UIColors.greyDCDFE5,
                      ),
                    ),
                  ]),
                ),
                _phoneNumberError
                    ? Container(
                        child: Text(meetingUiLocalizations.sipNumberError,
                            style: TextStyle(
                                color: _UIColors.colorF24957, fontSize: 14)))
                    : SizedBox(height: 20),
                TextField(
                  style: TextStyle(fontSize: 17, color: _UIColors.black_222222),
                  controller: _nameController,
                  inputFormatters: [
                    //限制输入长度不超过20字符
                    MeetingLengthLimitingTextInputFormatter(20),
                  ],
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: _UIColors.greyDCDFE5, width: 1.0)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: _UIColors.color_337eff, width: 1.0)),
                    hintText: meetingUiLocalizations.sipNamePlaceholder,
                    hintStyle:
                        TextStyle(color: _UIColors.greyB0B6BE, fontSize: 17),
                  ),
                ),
                SizedBox(height: 50),
                ElevatedButton(
                    style: ButtonStyle(
                        splashFactory: NoSplash.splashFactory,
                        minimumSize: MaterialStateProperty.all(Size(0, 50)),
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>((states) {
                          final disabled =
                              states.contains(MaterialState.disabled);
                          return Color.fromRGBO(
                              51, 126, 255, disabled ? 0.6 : 1);
                        }),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(28))))),
                    onPressed: _isCallBtnEnabled ? _onCall : null,
                    child: Text(
                      meetingUiLocalizations.sipCall,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    )),
              ]),
              Text(
                  '${meetingUiLocalizations.sipCallNumber} ${arguments.outboundPhoneNumber ?? ''}',
                  style: TextStyle(fontSize: 16, color: _UIColors.colorB4B8BF))
            ],
          ),
          if (_selectedContact != null)
            Positioned(
              left: 0,
              right: 0,
              top: 78,
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentContact = _selectedContact;
                      _nameController.text = _selectedContact?.name ?? '';
                      _selectedContact = null;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.1),
                              offset: Offset(-2, 2),
                              blurRadius: 4)
                        ]),
                    height: 56,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 12),
                            NEMeetingAvatar.medium(
                                name: _selectedContact?.name,
                                url: _selectedContact?.avatar),
                            SizedBox(width: 8),
                            Text(_selectedContact?.name ?? '',
                                style: TextStyle(
                                    fontSize: 17,
                                    color: _UIColors.color_333333)),
                          ],
                        ),
                        Row(children: [
                          Text(_selectedContact?.phoneNumber ?? '',
                              style: TextStyle(
                                  fontSize: 17, color: _UIColors.color_333333)),
                          SizedBox(width: 12),
                        ]),
                      ],
                    ),
                  )),
            ),
        ],
      ),
    );
  }

  /// 呼叫中展示号码与正在呼叫
  _buildCallingHeader() {
    return Column(
      children: [
        Text(_currentCall?.name ?? (_currentCall?.phoneNumber ?? ''),
            style: TextStyle(fontSize: 32, color: _UIColors.color_333333)),
        SizedBox(height: 23),
        if (_currentCall?.state == CurrentCallState.calling)
          Text(meetingUiLocalizations.sipCalling,
              style: TextStyle(fontSize: 16, color: _UIColors.color676B73)),
        if (_currentCall?.state == CurrentCallState.callFailed)
          Text(meetingUiLocalizations.sipCallFailed,
              style: TextStyle(fontSize: 16, color: _UIColors.colorF24957)),
      ],
    );
  }

  /// 接通后展示头像、号码与通话时长
  _buildConnectedHeader() {
    return Column(
      children: [
        /// 只有来自通讯录匹配的成员才显示头像
        if (_currentContact != null)
          NEMeetingAvatar.xxlarge(
              name: _currentCall?.name ?? (_currentCall?.phoneNumber ?? ''),
              url: _currentCall?.avatar),
        if (_currentContact != null) SizedBox(height: 8),
        Text(_currentCall?.name ?? (_currentCall?.phoneNumber ?? ''),
            style: TextStyle(fontSize: 16, color: _UIColors.color_333333)),
        SizedBox(height: 12),
        StreamBuilder<DateTime>(
            stream: _timerStreamController.stream,
            builder: (context, snapshot) {
              final time = _currentCall?.connectedTime;
              final snapshotTime = snapshot.data;
              if (time != null && snapshotTime != null) {
                final duration = snapshotTime.difference(time);
                final minutes = duration.inMinutes.toString().padLeft(2, '0');
                final seconds =
                    (duration.inSeconds % 60).toString().padLeft(2, '0');
                return Text('$minutes:$seconds',
                    style:
                        TextStyle(fontSize: 32, color: _UIColors.black_333333));
              } else {
                return Container();
              }
            }),
      ],
    );
  }

  /// 呼叫中页面
  _buildCalling() {
    return Container(
      margin: EdgeInsets.only(left: 30, right: 30, bottom: 40, top: 47),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        if (_currentCall?.state == CurrentCallState.calling ||
            _currentCall?.state == CurrentCallState.callFailed)
          _buildCallingHeader(),
        if (_currentCall?.state == CurrentCallState.connected)
          _buildConnectedHeader(),
        Column(
          children: [
            IconButton(
                iconSize: 60,
                onPressed: _onCallBtnClicked,
                icon: Image.asset(
                    _currentCall?.state == CurrentCallState.callFailed
                        ? NEMeetingImages.call
                        : NEMeetingImages.hangup,
                    package: NEMeetingImages.package)),
            Text(
                _currentCall?.state == CurrentCallState.callFailed
                    ? meetingUiLocalizations.sipCallAgain
                    : (_currentCall?.state == CurrentCallState.calling
                        ? meetingUiLocalizations.sipCallCancel
                        : meetingUiLocalizations.sipCallTerm),
                style: TextStyle(fontSize: 16, color: _UIColors.color9DA0A6)),
            SizedBox(height: 63),
            Center(
                child: GestureDetector(
              onTap: _onCallOthers,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(meetingUiLocalizations.sipCallOthers,
                      style: TextStyle(
                          fontSize: 18, color: _UIColors.color_337eff)),
                  SizedBox(height: 8),
                  Icon(Icons.arrow_forward_ios,
                      size: 18, color: _UIColors.color_337eff),
                ],
              ),
            )),
            SizedBox(height: 16),
            Text(
                '${meetingUiLocalizations.sipCallNumber} ${arguments.outboundPhoneNumber ?? ''}',
                style: TextStyle(fontSize: 16, color: _UIColors.colorB4B8BF))
          ],
        ),
      ]),
    );
  }

  /// 弹出本地通讯录
  _showLocalContacts() async {
    var granted =
        (await Permission.contacts.status) == PermissionStatus.granted;
    if (!granted) {
      granted = await PermissionHelper.requestContactsPermission(context);
    }
    if (granted) {
      showMeetingPopupPageRoute(
        context: context,
        builder: (context) => wrapWithWatermark(
          child: MeetingLocalContactsPage(
              onContactItemClick: (contact) {
                setState(() {
                  if (contact.phones != null && contact.phones!.isNotEmpty) {
                    _mobileController.text =
                        _mobileFormatter.maskText(contact.phones!.first.number);
                    _mobileFormatter.updateMask(
                        mask: '### #### ####',
                        filter: {"#": RegExp(r'[0-9]')},
                        newValue: TextEditingValue(
                            text: contact.phones!.first.number));
                  } else {
                    _mobileController.clear();
                  }
                  _nameController.text =
                      StringUtil.truncateEx(contact.displayName);
                });
              },
              isMySelfManagerListenable: arguments.isMySelfManagerListenable),
        ),
        routeSettings: RouteSettings(name: 'MeetLocalContactsPage'),
      );
    } else {
      ToastUtils.showToast(context, meetingUiLocalizations.globalNoPermission);
    }
  }

  /// 点击发起呼叫
  _onCall() async {
    final value = await ConnectivityManager().isConnected();
    if (!value) {
      ToastUtils.showToast(context,
          meetingUiLocalizations.networkAbnormalityPleaseCheckYourNetwork,
          isError: true);
      return;
    }
    final number = _mobileController.text.replaceAll(' ', '');
    final name = _nameController.text;
    _callByNumber(number, name);
  }

  _callByNumber(String number, String name) {
    arguments.roomContext.sipController
        .callByNumber(number, "+86", name)
        .then((value) {
      {
        if (value.isSuccess()) {
          setState(() {
            if (value.data?.isRepeatedCall == true) {
              ToastUtils.showToast(
                  context, meetingUiLocalizations.sipCallIsCalling);
            } else {
              _currentCall = CurrentCallInfo(number, value.data?.name ?? number,
                  value.data?.userUuid, _currentContact?.avatar)
                ..state = CurrentCallState.calling;
            }
            _selectedContact = null;
            _nameController.clear();
            _mobileController.clear();
          });
        } else {
          handleInviteCodeError(context, value.code, meetingUiLocalizations);
          setState(() {
            /// 这几种情况不需要跳转到呼叫失败页面
            if (value.code != 1022 &&
                value.code != 3006 &&
                value.code != 601011) {
              _currentCall = CurrentCallInfo(number, value.data?.name ?? number,
                  value.data?.userUuid, _currentContact?.avatar)
                ..state = CurrentCallState.callFailed;
            } else {
              _currentCall = null;
            }
            _selectedContact = null;
            _nameController.clear();
            _mobileController.clear();
          });
        }
      }
    });
  }

  /// 点击呼叫其他成员
  _onCallOthers() {
    setState(() {
      _currentCall = null;
    });
  }

  /// 点击呼叫中的图标按钮
  _onCallBtnClicked() async {
    final value = await ConnectivityManager().isConnected();
    if (!value) {
      ToastUtils.showToast(context,
          meetingUiLocalizations.networkAbnormalityPleaseCheckYourNetwork,
          isError: true);
      return;
    }
    if (_currentCall?.state == CurrentCallState.calling) {
      if (_currentCall?.userUuid != null) {
        arguments.roomContext.sipController.cancelCall(_currentCall!.userUuid!);
      }
    } else if (_currentCall?.state == CurrentCallState.connected) {
      if (_currentCall?.userUuid != null) {
        arguments.roomContext.sipController.hangUpCall(_currentCall!.userUuid!);
      }
    } else {
      if (_currentCall?.phoneNumber != null && _currentCall?.name != null) {
        _callByNumber(_currentCall!.phoneNumber, _currentCall!.name);
      }
    }
  }

  /* --- 通讯录页面相关 --- */

  final FocusNode _searchFocusNode = FocusNode();

  List<NEContact> _selectedContacts = [];

  /// 电话呼叫按钮是否展示，只有当有选中成员的时候才会展示
  get _sipCallBtnVisible => _selectedContacts.isNotEmpty;

  final TextEditingController _searchController = TextEditingController();

  /// 通讯录页面
  Widget _buildContacts() {
    return Container(
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                  child: ContactList(
                searchTextEditingController: _searchController,
                selectedContactsCache: _selectedContacts,
                itemClickCallback: (contact, selectedSize, maxSelectedSizeTip) {
                  if (TextUtils.isEmpty(contact.phoneNumber)) {
                    /// 没有号码用户的不允许选中
                    ToastUtils.showToast(
                        context, meetingUiLocalizations.sipContactNoNumber);
                  } else if (_memberIsInRoom(contact.userUuid)) {
                    /// 已经在房间中的用户不允许再次呼叫
                    ToastUtils.showToast(
                        context, meetingUiLocalizations.sipCallIsInMeeting);
                  } else if (_memberIsInCalling(contact.userUuid)) {
                    /// 已经在呼叫中的用户不允许再次呼叫
                    ToastUtils.showToast(
                        context, meetingUiLocalizations.sipCallIsInInviting);
                  } else if (_selectedContacts.length >= 10) {
                    /// 选中用户超过10个
                    ToastUtils.showToast(
                        context, meetingUiLocalizations.sipCallMaxCount(10));
                  } else if (_memberOverMaxCount()) {
                    /// 人数超限
                    ToastUtils.showToast(
                        context, meetingUiLocalizations.memberCountOutOfRange);
                  } else {
                    return true;
                  }
                  return false;
                },
                onSelectedContactListChanged: (contactList) {
                  setState(() {
                    _selectedContacts = contactList;
                  });
                },
              )),
            ],
          ),
          Visibility(
              visible: _sipCallBtnVisible,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 20, left: 30, right: 30),
                  child: ElevatedButton(
                      style: ButtonStyle(
                          splashFactory: NoSplash.splashFactory,
                          minimumSize: MaterialStateProperty.all(Size(0, 50)),
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                            final disabled =
                                states.contains(MaterialState.disabled);
                            return Color.fromRGBO(
                                51, 126, 255, disabled ? 0.6 : 1);
                          }),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(28))))),
                      onPressed: _onSipCall,
                      child: Text(
                        meetingUiLocalizations.sipCallPhone,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      )),
                ),
              )),
        ],
      ),
    );
  }

  /// 成员是否正在被呼叫
  bool _memberIsInCalling(String uuid) {
    return arguments.roomContext.inSIPInvitingMembers.any((member) =>
        member.uuid == uuid &&
        member.inviteState == NERoomMemberInviteState.calling);
  }

  /// 成员是否已经在房间里
  bool _memberIsInRoom(String uuid) {
    if (arguments.roomContext.localMember.uuid == uuid) {
      return true;
    }
    return arguments.roomContext.remoteMembers
        .any((member) => member.uuid == uuid);
  }

  /// 超出会议最大人数
  bool _memberOverMaxCount() {
    return _selectedContacts.length +
            arguments.roomContext.remoteMembers.length +
            arguments.roomContext.inAppInvitingMembers.length +
            arguments.roomContext.inSIPInvitingMembers.length >=
        arguments.roomContext.maxMembers - 1;
  }

  /// 通讯录电话呼叫
  _onSipCall() async {
    final value = await ConnectivityManager().isConnected();
    if (!value) {
      ToastUtils.showToast(context,
          meetingUiLocalizations.networkAbnormalityPleaseCheckYourNetwork,
          isError: true);
      return;
    }
    final userUuids = _selectedContacts.map((e) => e.userUuid).toList();
    if (userUuids.isNotEmpty) {
      arguments.roomContext.sipController
          .callByUserUuids(userUuids)
          .onSuccess(() {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }
}
