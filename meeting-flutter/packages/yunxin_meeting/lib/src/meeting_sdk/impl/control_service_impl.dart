// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_sdk;

class _NEControlServiceImpl extends NEControlService {
  static const _tag = '_NEControlServiceImpl';
  NEControlMenuItemClickListener? settingMenuItemClickListener;
  NEControlMenuItemClickListener? shareMenuItemClickListener;
  final Set<ControlListener> _controlListenerSet = <ControlListener>{};
  StreamSubscription? _startMeetingSubscription;
  StreamSubscription? _joinMeetingSubscription;
  StreamSubscription? _unbindSubscription;
  StreamSubscription? _tvProtocolUpdateSubscription;
  NEMeetingOnInjectedMenuItemClickListener? _onInjectedMenuItemClickListener;

  static final _NEControlServiceImpl _instance = _NEControlServiceImpl._();
  factory _NEControlServiceImpl() => _instance;

  _NEControlServiceImpl._() {
    MeetingControl().controlSettingStream.listen((ControlMenuItem event) {
      settingMenuItemClickListener?.call(
          NEControlMenuItem(event.title), getCurrentMeetingInfo());
    });

    MeetingControlUIService().injectedMenuItemClickHandler =
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
  Future<NEResult<void>> openControl(
      BuildContext context, NEControlParams params, NEControlOptions opts) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'openControl params: $params,opts: $opts');
    var result = checkParameters(params, opts);
    if (result != null) {
      return Future.value(result);
    }
    ControlProfile.controlName = NEMeetingSDK.instance.config?.appName;
    ControlProfile.nickName = params.displayName;
    if (getMeetingStatus().event != NEMeetingEvent.idle) {
      return Future.value(NEResult(
          code: NEMeetingErrorCode.alreadyInMeeting,
          msg: 'if meeting status is not idle,you can`t use open control'));
    }

    _startMeetingSubscription?.cancel();
    _startMeetingSubscription = MeetingControl()
        .controlStartMeetingStream
        .listen((ControlResult status) {
      var code = status.code;
      if (status.code == ControlCode.success) {
        code = NEMeetingErrorCode.success;
      }
      notifyStartMeetingResult(NEControlResult(code, status.message));
    });

    _joinMeetingSubscription?.cancel();
    _joinMeetingSubscription = MeetingControl()
        .controlJoinMeetingStream
        .listen((ControlResult status) {
      var code = status.code;
      if (status.code == ControlCode.success) {
        code = NEMeetingErrorCode.success;
      }
      notifyJoinMeetingResult(NEControlResult(code, status.message));
    });
    _unbindSubscription?.cancel();
    _unbindSubscription =
        MeetingControl().controlUnbindStream.listen((int unBindType) {
      notifyUnbind(unBindType);
    });

    _tvProtocolUpdateSubscription?.cancel();
    _tvProtocolUpdateSubscription =
        MeetingControl().tvProtocolUpgradeStream.listen((tcProtocolUpdate) {
      notifyTCProtocolUpgrade(NETCProtocolUpgrade(
          tcProtocolUpdate.controllerProtocolVersion,
          tcProtocolUpdate.tvProtocolVersion,
          tcProtocolUpdate.isCompatible));
    });

    var arguments = ControlArguments(opts: opts2options(opts));
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ControlPairPageProxy(arguments)));
    return Future.value(NEResult(code: NEMeetingErrorCode.success));
  }

  @override
  void setOnSettingMenuItemClickListener(
      NEControlMenuItemClickListener listener) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'setOnSettingMenuItemClickListener');
    settingMenuItemClickListener = listener;
  }

  @override
  NEMeetingInfo? getCurrentMeetingInfo() {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'getCurrentMeetingInfo');
    return ControlInMeetingService().currentMeetingInfo;
  }

  @override
  NEMeetingStatus getMeetingStatus() {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'getMeetingStatus');
    return NEMeetingSDK.instance.getMeetingService().getMeetingStatus();
  }

  // ControlMenuItem _neMenuItem2MenuItems(NEControlMenuItem items) => ControlMenuItem(items.title);

  void notifyStartMeetingResult(NEControlResult result) {
    _controlListenerSet.toList().forEach((listener) {
      listener.onStartMeetingResult(result);
    });
  }

  void notifyJoinMeetingResult(NEControlResult result) {
    _controlListenerSet.toList().forEach((listener) {
      listener.onJoinMeetingResult(result);
    });
  }

  void notifyUnbind(int unBindType) {
    _controlListenerSet.toList().forEach((listener) {
      listener.onUnbind(unBindType);
    });
  }

  void notifyTCProtocolUpgrade(NETCProtocolUpgrade protocolUpgrade) {
    _controlListenerSet.toList().forEach((listener) {
      listener.onTCProtocolUpgrade(protocolUpgrade);
    });
  }

  @override
  void setOnInjectedMenuItemClickListener(
      NEMeetingOnInjectedMenuItemClickListener listener) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'setOnInjectedMenuItemClickListener');
    _onInjectedMenuItemClickListener = listener;
  }

  @override
  void registerControlListener(ControlListener listener) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'registerControlListener');
    _controlListenerSet.add(listener);
  }

  @override
  void unRegisterControlListener(ControlListener listener) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'unRegisterControlListener');
    _controlListenerSet.remove(listener);
  }

  ControlOptions opts2options(NEControlOptions opts) {
    final settingMenuTitle = opts.settingMenu?.title;
    final shareMenuTitle = opts.shareMenu?.title;
    return ControlOptions(
      settingMenu:
          settingMenuTitle != null ? ControlMenuItem(settingMenuTitle) : null,
      shareMenu:
          shareMenuTitle != null ? ControlMenuItem(shareMenuTitle) : null,
      injectedToolbarMenuItems: opts.injectedToolbarMenuItems,
      injectedMoreMenuItems: opts.injectedMoreMenuItems,
    );
  }

  /// 统一参数校验
  NEResult<void>? checkParameters(
      NEControlParams param, NEControlOptions opts) {
    if (_exceedMaxVisibleCount(opts.injectedToolbarMenuItems, 5)) {
      return NEResult(
          code: NEMeetingErrorCode.paramError, msg: '\'Toolbar\'菜单列表最多允许同时显示5个菜单项');
    }
    if (_exceedMaxVisibleCount(opts.injectedMoreMenuItems, 10)) {
      return NEResult(
          code: NEMeetingErrorCode.paramError, msg: '\'更多\'菜单列表最多允许同时显示10个菜单项');
    }

    final allMenuItems =
        opts.injectedToolbarMenuItems.followedBy(opts.injectedMoreMenuItems);
    final ids = <int>{};
    for (var element in allMenuItems) {
      if (element.itemId < firstInjectableMenuId &&
          !NEControlMenuIDs.all.contains(element.itemId)) {
        return NEResult(
            code: NEMeetingErrorCode.paramError,
            msg: '不允许添加非预置或非自定义的菜单项: ${element.itemId}');
      }
      if (!ids.add(element.itemId)) {
        return NEResult(
            code: NEMeetingErrorCode.paramError,
            msg: '不允许添加相同Id的菜单项: ${element.itemId}');
      }
    }

    for (var element in opts.injectedToolbarMenuItems) {
      if (element.itemId < firstInjectableMenuId &&
          NEControlMenuIDs.toolbarExcludes.contains(element.itemId)) {
        return NEResult(
            code: NEMeetingErrorCode.paramError,
            msg: '该菜单项不允许添加至Toolbar菜单中: ${element.itemId}');
      }
    }

    for (var element in opts.injectedMoreMenuItems) {
      if (element.itemId < firstInjectableMenuId &&
          NEControlMenuIDs.moreExcludes.contains(element.itemId)) {
        return NEResult(
            code: NEMeetingErrorCode.paramError,
            msg: '该菜单项不允许添加到\'更多\'菜单中: ${element.itemId}');
      }
    }

    return null;
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
}
