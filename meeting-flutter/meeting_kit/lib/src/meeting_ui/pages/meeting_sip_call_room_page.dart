// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingSipCallRoomPage extends StatefulWidget {
  static const String routeName = "/meetingSipCallRoom";
  final SipCallArguments arguments;

  MeetingSipCallRoomPage(this.arguments);

  @override
  State<MeetingSipCallRoomPage> createState() =>
      _MeetingSipCallRoomPageState(arguments);
}

class _MeetingSipCallRoomPageState
    extends _MeetingSipCallPageBaseState<MeetingSipCallRoomPage> {
  _MeetingSipCallRoomPageState(super.arguments);

  final _focusNode = FocusNode();
  final _deviceAddressController = TextEditingController();
  var _protocolType = NERoomSipDeviceInviteProtocolType.IP;

  /// 拨号入会按钮是否可点
  bool _isCallBtnEnabled = false;
  List<_SipCallOutRoomRecord> callOutRoomRecords = [];

  /// 通话记录
  _SipCallOutRoomRecordsSQLManager _sipCallRecordsSQLManager =
      _SipCallOutRoomRecordsSQLManager();

  @override
  void initState() {
    super.initState();
    _deviceAddressController.addListener(() {
      final text = _deviceAddressController.text;
      _isCallBtnEnabled = text.isNotEmpty;
      setState(() {});
    });
    _loadCallRecords();
  }

  /// 加载本地呼叫记录
  _loadCallRecords() async {
    final list = await _sipCallRecordsSQLManager.getAllCallOutRoomRecords();
    setState(() {
      callOutRoomRecords = list.reversed.toList();
    });
  }

  @override
  Widget buildBody() {
    if (_currentCall != null) {
      return buildCalling();
    } else {
      return buildCallInput();
    }
  }

  Widget buildCallInput() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  MeetingCard(
                      title: meetingUiLocalizations.sipCallOutRoom,
                      titleFontSize: 16,
                      titleColor: _UIColors.color1E1F27,
                      children: [
                        Container(
                          height: 48,
                          padding: EdgeInsets.only(left: 16, right: 16),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Expanded(
                                  child: TextField(
                                focusNode: _focusNode,
                                controller: _deviceAddressController,
                                decoration: InputDecoration(
                                  hintText: _protocolType ==
                                          NERoomSipDeviceInviteProtocolType.IP
                                      ? meetingUiLocalizations
                                          .sipCallOutRoomInputTip
                                      : meetingUiLocalizations
                                          .sipCallOutRoomH323InputTip,
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    color: _UIColors.colorCDCFD7,
                                  ),
                                  border: InputBorder.none,
                                ),
                                inputFormatters: [
                                  /// 限制中文不允许输入
                                  FilteringTextInputFormatter.deny(
                                      RegExp(r'[\u4e00-\u9fa5]')),

                                  /// 限制长度255
                                  LengthLimitingTextInputFormatter(255)
                                ],
                              )),
                              if (_focusNode.hasFocus &&
                                  _deviceAddressController.text.isNotEmpty)
                                ClearIconButton(
                                  onPressed: () {
                                    _deviceAddressController.clear();
                                    setState(() {
                                      _isCallBtnEnabled = false;
                                    });
                                  },
                                ),
                              Visibility(
                                visible: callOutRoomRecords.isNotEmpty,
                                child: DropdownIconButton(
                                  padding: EdgeInsets.only(
                                      left: 12, top: 8, bottom: 8),
                                  size: 16,
                                  onPressed: () {
                                    _showCallOutDeviceHistory();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                  MeetingCard(
                    title: meetingUiLocalizations.sipProtocol,
                    titleFontSize: 16,
                    titleColor: _UIColors.color1E1F27,
                    children: [
                      buildProtocolItem(NERoomSipDeviceInviteProtocolType.IP),
                      buildProtocolItem(NERoomSipDeviceInviteProtocolType.H323),
                    ],
                  ),
                  MeetingCard(
                    children: [
                      buildInputName(),
                    ],
                  )
                ],
              )),
        ),
        buildCallButton(
          _isCallBtnEnabled
              ? () {
                  final deviceAddress = _deviceAddressController.text;
                  final displayName = _nameController.text;
                  final device = NERoomSystemDevice(
                      protocol: _protocolType,
                      deviceAddress: deviceAddress,
                      name: displayName);
                  _callOutRoom(device);
                }
              : null,
        ),
      ],
    );
  }

  Widget buildProtocolItem(NERoomSipDeviceInviteProtocolType type) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _protocolType = type;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          height: 48,
          child: Row(children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(right: 12),
              alignment: Alignment.centerRight,
              child: checkIcon(type),
            ),
            Expanded(
              child: Text(
                getProtocolTypeName(type),
                strutStyle: StrutStyle(forceStrutHeight: true, height: 1),
                style: TextStyle(
                    color: _UIColors.color53576A,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none),
              ),
            )
          ]),
        ));
  }

  String getProtocolTypeName(NERoomSipDeviceInviteProtocolType type) {
    switch (type) {
      case NERoomSipDeviceInviteProtocolType.IP:
        return meetingUiLocalizations.sip;
      case NERoomSipDeviceInviteProtocolType.H323:
        return meetingUiLocalizations.h323;
    }
  }

  Widget checkIcon(NERoomSipDeviceInviteProtocolType type) {
    return Container(
      width: 16,
      height: 16,
      child: Radio<NERoomSipDeviceInviteProtocolType>(
        value: type,
        groupValue: _protocolType,
        onChanged: (value) {
          setState(() {
            _protocolType = value ?? NERoomSipDeviceInviteProtocolType.IP;
          });
        },
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _UIColors.blue_337eff;
          }
          return _UIColors.colorCDCFD7;
        }),
      ),
    );
  }

  /// 弹窗呼叫会议室记录
  _showCallOutDeviceHistory() {
    StreamController controller = StreamController.broadcast();
    final dialogController = BottomSheetUtils.showMeetingBottomDialog(
      buildContext: context,
      actionText: meetingUiLocalizations.globalClearAll,
      actionCallback: () {
        _sipCallRecordsSQLManager.clearCallOutRoomRecords();
        callOutRoomRecords.clear();
      },
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
      itemCount: callOutRoomRecords.length,
      itemBuilder: (BuildContext context, int index) {
        final record = callOutRoomRecords[index];
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _selectCallRecord(record),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            child: Row(
              children: [
                SizedBox(width: 16),
                Expanded(
                    child: Row(
                  children: [
                    Container(
                      height: 24,
                      width: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _UIColors.colorF0F1F5,
                      ),
                      child: Text(
                        getProtocolTypeName(record.protocol),
                        style: TextStyle(
                          fontSize: 12,
                          color: _UIColors.color3D3D3D,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        record.deviceAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: _UIColors.color1E1F27,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      constraints: BoxConstraints(maxWidth: 48),
                      child: Text(
                        record.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: _UIColors.color1E1F27,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                )),
                SizedBox(width: 11),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _deleteCallRecord(record);
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
                SizedBox(width: 11),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectCallRecord(_SipCallOutRoomRecord record) {
    _deviceAddressController.text = record.deviceAddress;
    _nameController.text = record.name ?? '';
    _protocolType = record.protocol;
    _isCallBtnEnabled = true;
    Navigator.pop(context);
  }

  /// 删除某条呼叫记录
  _deleteCallRecord(_SipCallOutRoomRecord record) {
    _sipCallRecordsSQLManager.deleteCallOutRoomRecord(record.id);
    callOutRoomRecords.remove(record);
    if (callOutRoomRecords.isEmpty) {
      Navigator.of(context).pop();
    }
  }

  @override
  void call() {
    if (_currentCall?.device != null) {
      _callOutRoom(_currentCall!.device!);
    }
  }

  /// 会议室呼叫
  void _callOutRoom(NERoomSystemDevice device) async {
    final value = await ConnectivityManager().isConnected();
    if (!value) {
      ToastUtils.showToast(context,
          meetingUiLocalizations.networkAbnormalityPleaseCheckYourNetwork,
          isError: true);
      return;
    }
    final record = _SipCallOutRoomRecord.fromMap(device.toMap());
    callOutRoomRecords.insert(0, record);
    if (callOutRoomRecords.length > 10) {
      callOutRoomRecords.removeLast();
    }
    _sipCallRecordsSQLManager.addCallOutRoomRecord(record);
    arguments.roomContext.sipController.callOutRoomSystem(device).then((value) {
      if (value.isSuccess()) {
        if (value.data?.isRepeatedCall == true) {
          ToastUtils.showToast(
              context, meetingUiLocalizations.sipDeviceIsInCalling);
        } else {
          var name = value.data?.name;
          if (name?.isNotEmpty != true) {
            name = device.deviceAddress;
          }
          _currentCall = CurrentCallInfo(
              name: name,
              device: device,
              userUuid: value.data?.userUuid,
              avatar: _currentContact?.avatar)
            ..state = CurrentCallState.calling;
        }
        _deviceAddressController.clear();
        _nameController.clear();
        _isCallBtnEnabled = false;
        setState(() {});
      } else {
        handleInviteCodeError(
            context, value.code, meetingUiLocalizations, true);
        setState(() {
          /// 这几种情况不需要跳转到呼叫失败页面
          if (value.code != 1022 &&
              value.code != 3006 &&
              value.code != 601011) {
            _currentCall = CurrentCallInfo(
                device: device,
                name: value.data?.name ?? device.deviceAddress,
                userUuid: value.data?.userUuid,
                avatar: _currentContact?.avatar)
              ..state = CurrentCallState.callFailed;
          } else {
            _currentCall = null;
          }
        });
      }
    });
  }

  @override
  String get title => meetingUiLocalizations.sipCallOutRoom;

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _sipCallRecordsSQLManager.close();
  }
}
