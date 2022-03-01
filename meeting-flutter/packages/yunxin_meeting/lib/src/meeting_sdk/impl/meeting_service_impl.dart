// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_sdk;

class _NEMeetingServiceImpl extends NEMeetingService with EventTrackMixin {
  static const _tag = '_NEMeetingServiceImpl';
  NEMeetingStatus _meetingStatus = NEMeetingStatus(NEMeetingEvent.idle);
  NEMeetingOnInjectedMenuItemClickListener? _onInjectedMenuItemClickListener;
  final Set<NERoomStatusListener> _meetingListenerSet =
  <NERoomStatusListener>{};
  static final _NEMeetingServiceImpl _instance = _NEMeetingServiceImpl._();

  factory _NEMeetingServiceImpl() => _instance;

 final _roomService =  NERoomKit.instance.getRoomService();

  _NEMeetingServiceImpl._() {
    MeetingCore().meetingStatusStream.listen((status) {
      Alog.d(
          tag: _tag,
          moduleName: _moduleName,
          content: 'meeting sdk meetingStatusStream status = ${status.event}');
      _meetingStatus = NEMeetingStatus(status.event, arg: status.arg);
      _notifyMeetingStatusChange(_meetingStatus);
    });

    MeetingUIService().injectedMenuItemClickHandler =
        (BuildContext context,NEMenuClickInfo clickInfo) {
      Alog.d(
          tag: _tag,
          moduleName: _moduleName,
          content: 'On injected menu item click: $clickInfo');
      return _onInjectedMenuItemClickListener?.call(
          context,clickInfo, getCurrentMeetingInfo()) ??
          Future.value(true);
    };
  }

  @override
  Future<void> startMeeting(BuildContext context, NEStartMeetingParams param,
      NEStartMeetingOptions opts, NECompleteListener listener) async {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'startMeeting, param$param, opts$opts');
    if (!checkParameters(param, opts, listener)) return;
    if (MeetingControl().isAlreadyOpenControl) {
      listener(
          errorCode: NEMeetingErrorCode.alreadyOpenControl,
          errorMessage: 'current alreadyOpenControl');
      return;
    }
    var data = await _roomService.startRoom(
      param,
      NEStartRoomOptions(
        noAudio: opts.noAudio,
        noVideo: opts.noVideo,
        noCloudRecord: opts.noCloudRecord,
        noChat: opts.noChat,
      ),
    );
    if (data.code == RoomErrorCode.success && data.data != null) {
      listener(errorCode: NEMeetingErrorCode.success);
      trackPeriodicEvent(TrackEventName.roomCreateSuccess);
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MeetingPageProxy(MeetingArguments(
                  joinmeetingInfo: data.data!,
                  options: opts2options(opts)))));
    } else {
      trackPeriodicEvent(TrackEventName.roomCreateFailed,
          extra: {'value': data.code});
      _handleMeetingResultCode(data.code, data.msg, listener);
    }
  }

  void _handleMeetingResultCode(
      int code, String? msg, NECompleteListener listener) {
    if (code == RoomErrorCode.success) {
      listener(errorCode: NEMeetingErrorCode.success);
      return;
    }

    if (code == RoomErrorCode.roomAlreadyExist) {
      listener(
          errorCode: NEMeetingErrorCode.meetingAlreadyExist,
          errorMessage: msg ?? 'meeting already exist');
    } if (code == RoomErrorCode.alreadyInRoom) {
      listener(errorCode: NEMeetingErrorCode.alreadyInMeeting);
    } else if (code == RoomErrorCode.notLogin ||
        code == RoomErrorCode.loginErrorIMNotLogin ||
        code == RoomErrorCode.loginErrorIMAccountNotMatch) {
      listener(
          errorCode: NEMeetingErrorCode.loginError,
          errorMessage: msg ?? 'login error');
    } else if (code == RoomErrorCode.paramsError || code == RoomErrorCode.paramError) {
      listener(
          errorCode: NEMeetingErrorCode.paramError,
          errorMessage: msg ?? 'param error');
    } else if (code == RoomErrorCode.loginErrorAnonymousLoginNotSupport) {
      listener(
          errorCode: NEMeetingErrorCode.failed,
          errorMessage:
              NEMeetingSDKStrings.imLoginErrorAnonymousLoginUnSupported);
    } else if (code == RoomErrorCode.networkError) {
      listener(
          errorCode: NEMeetingErrorCode.noNetwork, errorMessage: msg ?? 'no network');
    } else if (code == RoomErrorCode.roomPasswordError) {
      listener(
          errorCode: NEMeetingErrorCode.meetingPasswordError,
          errorMessage: msg ?? 'meeting password error');
    } else if (code == RoomErrorCode.cancelled) {
      listener(
          errorCode: NEMeetingErrorCode.cancelled,
          errorMessage: msg ?? NEMeetingSDKStrings.cancelled);
    } else if (code == RoomErrorCode.unauthorized) {
      listener(
          errorCode: NEMeetingErrorCode.noAuth,
          errorMessage: msg ?? NEMeetingSDKStrings.unauthorized);
    } else {
      listener(errorCode: code, errorMessage: msg);
    }
  }

  @override
  Future<void> joinMeeting(BuildContext context, NEJoinMeetingParams param,
      NEJoinMeetingOptions opts, NECompleteListener listener) async {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'joinMeeting, param$param, opts$opts');
    if (!checkParameters(param, opts, listener)) return;
    if (MeetingControl().isAlreadyOpenControl) {
      listener(
          errorCode: NEMeetingErrorCode.alreadyOpenControl,
          errorMessage: 'current alreadyOpenControl');
      return;
    }
    var result = await _roomService.joinRoom(
      param,
      NEJoinRoomOptions(
        noAudio: opts.noAudio,
        noVideo: opts.noVideo,
      ),
    );
   await _normalJoinMeeting(context,result,param,opts,listener);
  }

  Future<void> _normalJoinMeeting(BuildContext context,NEResult<JoinRoomInfo> data, NEJoinMeetingParams param,
      NEJoinMeetingOptions opts, NECompleteListener listener) async {
      if (data.code == RoomErrorCode.success && data.data != null) {
        trackPeriodicEvent(TrackEventName.meetingJoinSuccess);
        //这里需要提前拿到navigatorState，防止context被pop，导致navigator异常
        NavigatorState? navigatorState;
        try {
          navigatorState = Navigator.of(context, rootNavigator: true);
        } catch (e) {
          Alog.d(
              tag: _tag,
              moduleName: _moduleName,
              content: 'exception = ${e.toString()}');
        }
        if (navigatorState == null) {
          listener(
              errorCode: NEMeetingErrorCode.failed, errorMessage: 'Navigator error!');
        } else {
          listener(errorCode: NEMeetingErrorCode.success);
          await navigatorState.push(MaterialPageRoute(
              builder: (context) => MeetingPageProxy(MeetingArguments(
                  joinmeetingInfo: data.data!,
                  options: opts2options(opts)))));
        }
      } else if (data.code == RoomErrorCode.roomPasswordNotPresent) {
        /// 需要输入密码的情况下，data.data为空
        NavigatorState? navigatorState;
        try {
          navigatorState = Navigator.of(context, rootNavigator: true);
        } catch (e) {
          Alog.d(
              tag: _tag,
              moduleName: _moduleName,
              content: 'exception = ${e.toString()}');
        }
        if (navigatorState == null) {
          listener(
              errorCode: NEMeetingErrorCode.failed, errorMessage: 'Navigator error!');
        } else {
          listener(errorCode: NEMeetingErrorCode.meetingPasswordRequired);
          await navigatorState
              .push(MaterialPageRoute(
                  builder: (BuildContext context) => MeetingPageProxy(
                      MeetingWaitingArguments.verifyPassword(data.code,
                          initWaitMsg: data.msg,
                          meetingId: param.roomId!,
                          displayName: param.displayName,
                          options: opts2options(opts)))))
              .then((value) {
            if (value is MeetingArguments) {
              listener(errorCode: NEMeetingErrorCode.success);
              navigatorState?.push(MaterialPageRoute(
                  builder: (context) => MeetingPageProxy(value)));
            } else if (value is NEResult) {
              _handleMeetingResultCode(value.code, value.msg, listener);
            }
          });
        }
      } else {
        trackPeriodicEvent(TrackEventName.meetingJoinFailed,
            extra: {'value': data.code});
        _handleMeetingResultCode(data.code, data.msg, listener);
      }
    }

  MeetingOptions opts2options(NEMeetingOptions opts, {bool anonymous = false}) {
    return MeetingOptions(
      meetingTitle: NEMeetingSDK.instance.config?.appName,
      iosBroadcastAppGroup: NEMeetingSDK.instance.config?.iosBroadcastAppGroup,
      videoMute: opts.noVideo,
      audioMute: opts.noAudio,
      showMeetingTime: opts.showMeetingTime,
      noInvite: opts.noInvite,
      noChat: opts.noChat,
      noMinimize: opts.noMinimize,
      noGallery: opts.noGallery,
      noWhiteBoard: opts.noWhiteBoard,
      noSwitchCamera: opts.noSwitchCamera,
      noSwitchAudioMode: opts.noSwitchAudioMode,
      defaultWindowMode: opts.defaultWindowMode,
      noRename: opts.noRename,
      noCloudRecord: opts.noCloudRecord,
      meetingIdDisplayOption: opts.meetingIdDisplayOption,
      anonymous: anonymous,
      joinTimeout: opts.joinTimeout,
      injectedToolbarMenuItems: opts.injectedToolbarMenuItems,
      injectedMoreMenuItems: opts.injectedMoreMenuItems,
      restorePreferredOrientations: opts.restorePreferredOrientations,
      extras: opts.extras,
    );
  }

  @override
  void addListener(NERoomStatusListener listener) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'addListener');
    _meetingListenerSet.add(listener);
  }

  @override
  void removeListener(NERoomStatusListener listener) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'removeListener');
    _meetingListenerSet.remove(listener);
  }

  @override
  NEMeetingStatus getMeetingStatus() {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'getMeetingStatus status');
    return _meetingStatus;
  }

  @override
  void setOnInjectedMenuItemClickListener(
      NEMeetingOnInjectedMenuItemClickListener listener) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'getMeetingStatus');
    _onInjectedMenuItemClickListener = listener;
  }

  @override
  NEMeetingInfo? getCurrentMeetingInfo() {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'getCurrentMeetingInfo');
    return InMeetingService().currentMeetingInfo;
  }

  /// 离开当前会议
  @override
  Future<NEResult<void>> leaveCurrentMeeting(bool closeIfHost) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'leaveCurrentMeeting: $closeIfHost',
    );
    return _roomService.leaveCurrentRoom(closeIfHost);
  }

  @override
  Future<NEResult<void>> subscribeRemoteAudioStream(
      String accountId, bool subscribe) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content:
            'subscribeRemoteAudioStream ,accountId: $accountId,subscribe: $subscribe');
    if (InMeetingService().audioManager == null) {
      return Future.value(
          NEResult(code: RoomErrorCode.roomNotInProgress, msg: '会议不在进行中'));
    }
    if (TextUtils.isEmpty(accountId)) {
      return Future.value(
          NEResult(code: RoomErrorCode.paramsError, msg: 'accountId为空'));
    }
    return InMeetingService()
        .audioManager!
        .subscribeRemoteAudioStream(accountId, subscribe);
  }

  @override
  Future<NEResult<List<String>>> subscribeRemoteAudioStreams(
      List<String> accountIds, bool subscribe) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content:
            'subscribeRemoteAudioStreams ,accountIds: $accountIds,subscribe: $subscribe');
    if (InMeetingService().audioManager == null) {
      return Future.value(
          NEResult(code: RoomErrorCode.roomNotInProgress, msg: '会议不在进行中'));
    }
    if (accountIds.isEmpty) {
      return Future.value(
          NEResult(code: RoomErrorCode.paramsError, msg: 'accountId列表为空'));
    }
    return InMeetingService().audioManager!
        .subscribeRemoteAudioStreams(accountIds, subscribe);
  }

  @override
  Future<NEResult<void>> subscribeAllRemoteAudioStreams(bool subscribe) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'subscribeAllRemoteAudioStreams ,subscribe: $subscribe');
    if (InMeetingService().audioManager == null) {
      return Future.value(
          NEResult(code: RoomErrorCode.roomNotInProgress, msg: '会议不在进行中'));
    }
    return InMeetingService().audioManager!
        .subscribeAllRemoteAudioStreams(subscribe);
  }

  /// 统一参数校验
  bool checkParameters(NERoomParams param, NEMeetingOptions opts,
      NECompleteListener listener) {
    // if (param.displayName.isEmpty) {
    //   listener(
    //       errorCode: NEMeetingErrorCode.paramError,
    //       errorMessage: NEMeetingSDKStrings.displayNameShouldNotBeEmpty);
    //   return false;
    // }
    if (param is NEStartMeetingParams &&
        (param.password != null &&
            (param.password!.length >
                    NEMeetingConstants.meetingPasswordMaxLen ||
                param.password!.length <
                    NEMeetingConstants.meetingPasswordMinLen
                    || !TextUtils.isLetterOrDigital(param.password!)))) {
      listener(
          errorCode: NEMeetingErrorCode.paramError,
          errorMessage: NEMeetingSDKStrings.meetingPasswordNotValid);
      return false;
    }
    if (param is NEJoinMeetingParams && (param.roomId?.isEmpty ?? true)) {
      listener(
          errorCode: NEMeetingErrorCode.paramError,
          errorMessage: NEMeetingSDKStrings.meetingIdShouldNotBeEmpty);
      return false;
    }

    if (_exceedMaxVisibleCount(opts.injectedToolbarMenuItems, 4)) {
      listener(
          errorCode: NEMeetingErrorCode.paramError,
          errorMessage: '\'Toolbar\'菜单列表最多允许同时显示4个菜单项');
      return false;
    }
    if (_exceedMaxVisibleCount(opts.injectedMoreMenuItems, 10)) {
      listener(
          errorCode: NEMeetingErrorCode.paramError,
          errorMessage: '\'更多\'菜单列表最多允许同时显示10个菜单项');
      return false;
    }

    final allMenuItems =
        opts.injectedToolbarMenuItems.followedBy(opts.injectedMoreMenuItems);
    final ids = <int>{};
    for (var element in allMenuItems) {
      if (element.itemId < firstInjectableMenuId &&
          !NEMenuIDs.all.contains(element.itemId)) {
        listener(
            errorCode: NEMeetingErrorCode.paramError,
            errorMessage: '不允许添加非预置或非自定义的菜单项: id=${element.itemId}');
        return false;
      }
      if (!ids.add(element.itemId)) {
        listener(
            errorCode: NEMeetingErrorCode.paramError,
            errorMessage: '不允许添加相同Id的菜单项: id=${element.itemId}');
        return false;
      }
    }

    for (var element in opts.injectedToolbarMenuItems) {
      if (element.itemId < firstInjectableMenuId &&
          NEMenuIDs.toolbarExcludes.contains(element.itemId)) {
        listener(
            errorCode: NEMeetingErrorCode.paramError,
            errorMessage: '该菜单项不允许添加至Toolbar菜单中: id=${element.itemId}');
        return false;
      }
    }

    for (var element in opts.injectedMoreMenuItems) {
      if (element.itemId < firstInjectableMenuId &&
          NEMenuIDs.moreExcludes.contains(element.itemId)) {
        listener(
            errorCode: NEMeetingErrorCode.paramError,
            errorMessage: '该菜单项不允许添加到\'更多\'菜单中: id=${element.itemId}');
        return false;
      }
    }
    return true;
  }

  bool _exceedMaxVisibleCount(List<NEMeetingMenuItem> items, int max) {
    var hostVisibleCount = 0;
    var normalVisibleCount = 0;
    items.forEach((element) {
      if (element.visibility == NEMenuVisibility.visibleAlways ||
          element.visibility == NEMenuVisibility.visibleToHostOnly) {
        hostVisibleCount++;
      }
      if (element.visibility == NEMenuVisibility.visibleAlways ||
          element.visibility == NEMenuVisibility.visibleExcludeHost) {
        normalVisibleCount++;
      }
    });
    return hostVisibleCount > max || normalVisibleCount > max;
  }

  @override
  Future<NEResult<void>> startAudioDump() {
    if (InMeetingService().audioManager == null) {
      return Future.value(
          NEResult(code: RoomErrorCode.roomNotInProgress, msg: '会议不在进行中'));
    }
    return InMeetingService().audioManager!.startAudioDump();
  }

  @override
  Future<NEResult<void>> stopAudioDump() {
    if (InMeetingService().audioManager == null) {
      return Future.value(
          NEResult(code: RoomErrorCode.roomNotInProgress, msg: '会议不在进行中'));
    }
    return InMeetingService().audioManager!.stopAudioDump();
  }

  void _notifyMeetingStatusChange(NEMeetingStatus status) {
    Alog.d(
        tag: _tag,
        moduleName: _moduleName,
        content: '_notifyMeetingStatusChange status = ${status.event}');
    _meetingListenerSet.toList().forEach((element) {
      element(status);
    });
  }
}
