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

class _MeetingSipCallPageState
    extends _MeetingSipCallPageBaseState<MeetingSipCallPage> {
  /// 1: 拨号 2: 通讯录
  int _selectedIndex = 1;
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _mobileController;
  late MaskTextInputFormatter _mobileFormatter;
  bool _mobileFocus = false;
  bool _phoneNumberError = false;

  /// 当前搜索到的通讯录成员
  NEContact? _selectedContact;

  /// 通讯录页面相关
  final FocusNode _searchFocusNode = FocusNode();

  List<NEContact> _selectedContacts = [];

  _MeetingSipCallPageState(super.arguments);

  /// 电话呼叫按钮是否可点击，只有当有选中成员的时候才可点击
  bool get sipBatchCallBtnEnabled => _selectedContacts.isNotEmpty;

  /// 拨号入会按钮是否可点
  bool _isCallBtnEnabled = false;

  /// 通话记录
  NESipCallRecordsSQLManager _sipCallRecordsSQLManager =
      NESipCallRecordsSQLManager();
  List<NESipCallRecord> _callRecords = [];

  @override
  String get title => meetingUiLocalizations.sipCallOutPhone;

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
          ContactsRepository.searchContacts(null, number, 20, 1).then((value) {
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

    /// 加载本地呼叫记录
    _loadCallRecords();
  }

  @override
  Widget buildBody() {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          children: [
            _buildSegment(),
            if (_selectedIndex == 1) Expanded(child: _buildCall()),
            if (_selectedIndex == 2) Expanded(child: _buildContacts()),
          ],
        ));
  }

  /// 加载本地呼叫记录
  _loadCallRecords() async {
    await _sipCallRecordsSQLManager
        .initializeDatabase(arguments.roomContext.myUuid);
    final list = await _sipCallRecordsSQLManager.getAllCallRecords();
    _callRecords = list.reversed.toList();
    setState(() {
      /// 只取最新100次
      if (_callRecords.length > 100) {
        _callRecords = _callRecords.sublist(0, 99);
      }
    });
  }

  /// 保存本地呼叫记录
  _addCallRecord(String name, String number) {
    /// 过滤name为number的情况
    if (name == number) {
      name = '';
    }
    final record = NESipCallRecord(name: name, number: number);
    _sipCallRecordsSQLManager.addCallRecord(record);
    setState(() {
      _callRecords.insert(0, record);
      if (_callRecords.length > 100) {
        _callRecords.removeLast();
      }
    });
  }

  /// 清空本地呼叫记录
  _clearCallRecords() {
    _sipCallRecordsSQLManager.clearCallRecords();
    _callRecords.clear();
  }

  /// 删除某条呼叫记录
  _deleteCallRecord(NESipCallRecord record) {
    _sipCallRecordsSQLManager.deleteCallRecord(record.id);
    _callRecords.remove(record);
    if (_callRecords.isEmpty) {
      Navigator.of(context).pop();
    }
  }

  /// 选择某条呼叫记录
  _selectCallRecord(NESipCallRecord record) {
    _nameController.text = record.name;
    if (record.number.isNotEmpty) {
      _mobileController.text = _mobileFormatter.maskText(record.number);
    }
    _nameController.text = StringUtil.truncateEx(record.name);
    Navigator.of(context).pop();
  }

  _showCallRecords() {
    StreamController controller = StreamController.broadcast();
    final dialogController = BottomSheetUtils.showMeetingBottomDialog(
      buildContext: context,
      actionText: meetingUiLocalizations.globalClearAll,
      actionCallback: _clearCallRecords,
      actionColor: _UIColors.color8D90A0,
      isSubpage: true,
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Container(
          constraints: BoxConstraints(maxHeight: 240),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: MediaQuery.removePadding(
              removeBottom: true,
              context: context,
              child: StreamBuilder(
                stream: controller.stream,
                builder: (_, data) {
                  return buildRecordList(controller);
                },
              ),
            ),
          ),
        ),
      ]),
    );
    dialogController.result.then((_) {
      controller.close();
    });
  }

  Widget buildRecordList(StreamController listDeleteStream) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _callRecords.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _selectCallRecord(_callRecords[index]),
          child: Container(
            height: 48,
            child: Row(
              children: [
                SizedBox(width: 24),
                Text(
                  _mobileFormatter.maskText(_callRecords[index].number),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: _UIColors.color1E1F27,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _callRecords[index].name,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: _UIColors.color1E1F27,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 6),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _deleteCallRecord(_callRecords[index]);
                    listDeleteStream.add(null);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Icon(
                      NEMeetingIconFont.icon_yx_input_clearx,
                      color: _UIColors.colorCDCFD7,
                      size: 14,
                    ),
                  ),
                ),
                SizedBox(width: 13),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCall() {
    if (_currentCall != null) {
      return buildCalling();
    } else {
      return buildCallInput();
    }
  }

  /// 拨号页面
  Widget buildCallInput() {
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_focusNode.hasFocus) {
              _focusNode.unfocus();
            }
            if (_searchFocusNode.hasFocus) {
              _searchFocusNode.unfocus();
            }
          },
        ),
        Column(
          children: [
            MeetingCard(
                title: meetingUiLocalizations.sipKeypad,
                iconData: NEMeetingIconFont.icon_call,
                iconColor: _UIColors.color1BB650,
                children: [
                  buildInputPhone(),
                  _phoneNumberError
                      ? Container(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Text(meetingUiLocalizations.sipNumberError,
                              style: TextStyle(
                                  color: _UIColors.colorF24957, fontSize: 14)))
                      : SizedBox.shrink(),
                  buildInputName(),
                ]),
            Spacer(),
            buildCallButton(_isCallBtnEnabled ? _onCall : null),
            Text(
                '${meetingUiLocalizations.sipCallNumber} ${arguments.outboundPhoneNumber ?? ''}',
                style: TextStyle(fontSize: 16, color: _UIColors.colorB4B8BF)),
            SizedBox(height: 16),
          ],
        ),
        if (_selectedContact != null)
          Positioned(
            left: 0,
            right: 0,
            top: 84,
            child: GestureDetector(
                onTap: () {
                  setState(() {
                    _currentContact = _selectedContact;
                    _nameController.text = _selectedContact?.name ?? '';
                    _selectedContact = null;
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                            offset: Offset(-2, 2),
                            blurRadius: 4)
                      ]),
                  height: 48,
                  child: Row(
                    children: [
                      SizedBox(width: 12),
                      ValueListenableBuilder(
                        valueListenable: arguments.hideAvatar,
                        builder: (context, hideAvatar, child) {
                          return NEMeetingAvatar.medium(
                            name: _selectedContact?.name,
                            url: _selectedContact?.avatar,
                            hideImageAvatar: hideAvatar,
                          );
                        },
                      ),
                      SizedBox(width: 8),
                      Expanded(
                          child: Text(
                        _selectedContact?.name ?? '',
                        style: TextStyle(
                            fontSize: 17, color: _UIColors.color_333333),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                      Text(_selectedContact?.phoneNumber ?? '',
                          style: TextStyle(
                              fontSize: 17, color: _UIColors.color_333333)),
                      SizedBox(width: 12),
                    ],
                  ),
                )),
          ),
      ],
    );
  }

  Widget buildInputPhone() {
    return buildItem(
      title: '+86',
      content: Row(children: [
        Expanded(
          child: TextField(
            style: TextStyle(
                fontSize: 16,
                color: _phoneNumberError
                    ? _UIColors.colorF24957
                    : _UIColors.color1E1F27),
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
              hintText: meetingUiLocalizations.sipNumberPlaceholder,
              border: InputBorder.none,
              hintStyle: TextStyle(color: _UIColors.colorCDCFD7, fontSize: 16),
            ),
          ),
        ),
        if (_focusNode.hasFocus && _mobileController.text.isNotEmpty)
          ClearIconButton(
            onPressed: () {
              _mobileController.clear();
              setState(() {
                _isCallBtnEnabled = false;
              });
            },
          ),
        Visibility(
            visible: _callRecords.isNotEmpty,
            child: IconButton(
              onPressed: _showCallRecords,
              icon: Icon(Icons.keyboard_arrow_down),
            )),
        SizedBox(width: 4),
        GestureDetector(
            onTap: _showLocalContacts,
            child: Icon(
              NEMeetingIconFont.icon_contacts,
              size: 16,
              color: _UIColors.color_337eff,
            )),
      ]),
    );
  }

  /// 超出会议最大人数
  bool _memberOverMaxCount() {
    return _selectedContacts.length +
            arguments.roomContext.remoteMembers.length +
            arguments.roomContext.inAppInvitingMembers.length +
            arguments.roomContext.inSIPInvitingMembers.length >=
        arguments.roomContext.maxMembers - 1;
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
    _addCallRecord(name, number);
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

  /// 通讯录页面
  Widget _buildContacts() {
    return Column(
      children: [
        Expanded(
          child: MeetingCard(
            title: meetingUiLocalizations.sipBatchCall,
            iconData: NEMeetingIconFont.icon_call_batch,
            iconColor: _UIColors.color1BB650,
            children: [
              Expanded(
                  child: ContactList(
                selectedContactsCache: _selectedContacts,
                hideAvatar: arguments.hideAvatar,
                itemClickCallback: (contact, selectedSize, maxSelectedSizeTip) {
                  if (TextUtils.isEmpty(contact.phoneNumber)) {
                    /// 没有号码用户的不允许选中
                    ToastUtils.showToast(
                        context, meetingUiLocalizations.sipContactNoNumber);
                  } else if (isMemberAlreadyInRoom(contact.userUuid)) {
                    /// 已经在房间中的用户不允许再次呼叫
                    ToastUtils.showToast(
                        context, meetingUiLocalizations.sipCallIsInMeeting);
                  } else if (isMemberAlreadyInCalling(contact.userUuid)) {
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
        ),
        buildCallButton(sipBatchCallBtnEnabled ? _onSipCall : null),
        Text(
            '${meetingUiLocalizations.sipCallNumber} ${arguments.outboundPhoneNumber ?? ''}',
            style: TextStyle(fontSize: 16, color: _UIColors.colorB4B8BF)),
        SizedBox(height: 16),
      ],
    );
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
    var userUuids = <String>[];
    _selectedContacts.forEach((contact) {
      userUuids.add(contact.userUuid);
      _addCallRecord(contact.name ?? '', contact.phoneNumber ?? '');
    });
    if (userUuids.isNotEmpty) {
      arguments.roomContext.sipController
          .callByUserUuids(userUuids)
          .then((value) {
        if (value.isSuccess()) {
          if (mounted) Navigator.of(context).pop();
        } else {
          handleInviteCodeError(context, value.code, meetingUiLocalizations);
        }
      });
    }
  }

  Widget _buildSegment() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: _UIColors.white,
      ),
      child: CupertinoSegmentedControl(
        padding: EdgeInsets.zero,
        borderColor: Colors.transparent,
        selectedColor: Colors.transparent,
        unselectedColor: Colors.transparent,
        pressedColor: Colors.transparent,
        children: {
          1: buildTitleSelector(1, meetingUiLocalizations.sipKeypad),
          2: buildTitleSelector(2, meetingUiLocalizations.sipBatchCall),
        },
        groupValue: _selectedIndex,
        onValueChanged: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
      ),
    );
  }

  Widget buildTitleSelector(int index, String title) {
    return Container(
        width: 120,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: _selectedIndex == index
              ? _UIColors.color_337eff
              : Colors.transparent,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color:
                _selectedIndex == index ? Colors.white : _UIColors.color1E1F27,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  /// 弹出本地通讯录
  _showLocalContacts() async {
    var granted =
        (await Permission.contacts.status) == PermissionStatus.granted;
    if (!granted) {
      granted = await PermissionHelper.requestContactsPermission(context);
    }
    if (granted) {
      var Size(:longestSide, :shortestSide) = MediaQuery.sizeOf(context);
      var maxHeight = longestSide * (1.0 - 66.0 / 812);
      BottomSheetUtils.showMeetingBottomDialog(
        buildContext: context,
        physics: NeverScrollableScrollPhysics(),
        isSubpage: true,
        constraints:
            BoxConstraints.tightFor(height: max(shortestSide, maxHeight)),
        child: MeetingWatermark(
          child: MeetingLocalContactsPage(
            onContactItemClick: (contact) {
              setState(() {
                if (contact.phones != null && contact.phones!.isNotEmpty) {
                  _mobileController.text =
                      _mobileFormatter.maskText(contact.phones!.first.number);
                } else {
                  _mobileController.clear();
                }
                _nameController.text =
                    StringUtil.truncateEx(contact.displayName);
              });
            },
            isMySelfManagerListenable: arguments.isMySelfManagerListenable,
            hideAvatar: arguments.hideAvatar,
          ),
        ),
        routeSettings: RouteSettings(name: 'MeetLocalContactsPage'),
      );
    } else {
      ToastUtils.showToast(context, meetingUiLocalizations.globalNoPermission);
    }
  }

  @override
  void call() async {
    if (_currentCall?.phoneNumber != null && _currentCall?.name != null) {
      _callByNumber(_currentCall!.phoneNumber, _currentCall!.name);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _searchFocusNode.dispose();
    _mobileController.dispose();
    _sipCallRecordsSQLManager.close();
  }
}

abstract class _MeetingSipCallPageBaseState<T extends StatefulWidget>
    extends LifecycleBaseState<T>
    with MeetingKitLocalizationsMixin, _AloggerMixin {
  final SipCallArguments arguments;

  late NERoomEventCallback _roomEventCallback;

  _MeetingSipCallPageBaseState(this.arguments);

  @override
  void initState() {
    super.initState();
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
    _nameController.dispose();
    super.dispose();
  }

  Widget buildBody();

  String get title;

  @override
  Widget build(BuildContext context) {
    final child = Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: _UIColors.globalBg,
      appBar: TitleBar(
        title: TitleBarTitle(title),
        showBottomDivider: true,
      ),
      body: SafeArea(left: false, child: MeetingWatermark(child: buildBody())),
    );
    return AutoPopScope(
        listenable: arguments.isMySelfManagerListenable,
        onWillAutoPop: (_) {
          return !arguments.isMySelfManagerListenable.value;
        },
        child: child);
  }

  /* --- 拨号呼叫页面相关 --- */

  /// 当前通话的信息
  CurrentCallInfo? _currentCall;

  late TextEditingController _nameController;

  /// 当前选中的通讯录成员，在点击搜索到成员的时候赋值，当号码变更的时候重置
  NEContact? _currentContact;

  /// 通话时长计时
  late StreamController<DateTime> _timerStreamController;
  late Timer _connectedTimer;

  /// 呼叫中展示号码与正在呼叫
  _buildCallingHeader() {
    return Column(
      children: [
        Text(_currentCall?.name ?? (_currentCall?.phoneNumber ?? ''),
            style: TextStyle(fontSize: 28, color: _UIColors.color1E1F27)),
        SizedBox(height: 16),
        if (_currentCall?.state == CurrentCallState.calling)
          Text(meetingUiLocalizations.sipCalling,
              style: TextStyle(fontSize: 16, color: _UIColors.color53576A)),
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
          ValueListenableBuilder(
            valueListenable: arguments.hideAvatar,
            builder: (context, hideAvatar, child) {
              return NEMeetingAvatar.xxxlarge(
                name: _currentCall?.name ?? (_currentCall?.phoneNumber ?? ''),
                url: _currentCall?.avatar,
                hideImageAvatar: hideAvatar,
              );
            },
          ),
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

  Widget buildInputName() {
    return buildItem(
        title: meetingUiLocalizations.sipDisplayName,
        content: TextField(
          style: TextStyle(fontSize: 16, color: _UIColors.color1E1F27),
          controller: _nameController,
          inputFormatters: [
            //限制输入长度不超过20字符
            MeetingLengthLimitingTextInputFormatter(20),
          ],
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: meetingUiLocalizations.sipNamePlaceholder,
            hintStyle: TextStyle(color: _UIColors.colorCDCFD7, fontSize: 16),
          ),
        ));
  }

  Widget buildCallButton(VoidCallback? onPressed) {
    return Container(
      margin: EdgeInsets.all(16),
      width: double.infinity,
      child: MeetingTextButton.fill(
        text: meetingUiLocalizations.sipCall,
        onPressed: onPressed,
      ),
    );
  }

  Widget buildItem({required String title, required Widget content}) {
    return Container(
      height: 48,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Row(children: [
        Container(
          width: 82,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: _UIColors.color1E1F27,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: content),
      ]),
    );
  }

  /// 呼叫中页面
  Widget buildCalling() {
    return MeetingCard(
        margin: EdgeInsets.all(16),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 32),
          if (_currentCall?.state == CurrentCallState.calling ||
              _currentCall?.state == CurrentCallState.callFailed)
            _buildCallingHeader(),
          if (_currentCall?.state == CurrentCallState.connected)
            _buildConnectedHeader(),
          Spacer(),
          Column(
            children: [
              IconButton(
                  iconSize: 60,
                  onPressed: onCallBtnClicked,
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
              SizedBox(height: 64),
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
                  style: TextStyle(fontSize: 16, color: _UIColors.colorCDCFD7)),
              SizedBox(height: 40),
            ],
          ),
        ]);
  }

  /// 点击呼叫其他成员
  _onCallOthers() {
    setState(() {
      _currentCall = null;
    });
  }

  /// 点击呼叫中的图标按钮
  Future onCallBtnClicked() async {
    final value = await ConnectivityManager().isConnected();
    if (!value) {
      ToastUtils.showToast(context,
          meetingUiLocalizations.networkAbnormalityPleaseCheckYourNetwork,
          isError: true);
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
      call();
    }
  }

  /// 呼叫
  void call();

  /// 成员是否正在被呼叫
  bool isMemberAlreadyInCalling(String uuid) {
    return arguments.roomContext.inSIPInvitingMembers.any((member) =>
        member.uuid == uuid &&
        member.inviteState == NERoomMemberInviteState.calling);
  }

  /// 成员是否已经在房间里
  bool isMemberAlreadyInRoom(String uuid) {
    if (arguments.roomContext.localMember.uuid == uuid) {
      return true;
    }
    return arguments.roomContext.remoteMembers
        .any((member) => member.uuid == uuid);
  }
}
