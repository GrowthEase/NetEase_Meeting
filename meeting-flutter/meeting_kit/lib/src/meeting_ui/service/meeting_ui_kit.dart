// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 会议服务监听器
mixin class NEMeetingStatusListener {
  void onMeetingStatusChanged(NEMeetingEvent event) {}
}

///
/// 密码页面Push前回调
///
typedef PasswordPageRouteWillPushCallback = Future Function();

///
/// 会议页面Push前回调
///
typedef MeetingPageRouteWillPushCallback = Future Function();

///
/// 会议页面Push后回调
///
typedef MeetingPageRouteDidPushCallback = void Function(Future<Object?> popped);

/// 提供会议相关的服务接口，诸如创建会议、加入会议、添加会议状态监听等。
abstract class NEMeetingUIKit {
  static final NEMeetingUIKit _instance = _NEMeetingUIKitImpl();

  /// 获取会议UI SDK实例
  static NEMeetingUIKit get instance => _instance;

  /// 获取UI SDK配置
  NEMeetingKitConfig? uiConfig;

  ///
  /// 多语言切换监听
  ///
  ValueListenable<Locale> get localeListenable;

  NEMeetingUIKitLocalizations getUIKitLocalizations([BuildContext? context]);

  ///
  /// 获取用于拒绝或加入会议的邀请服务，如果未完成初始化，则返回为空
  ///
  NEMeetingUIKitInviteService getMeetingInviteService();

  ///
  /// 获取用于共享屏幕开始和结束服务，如果未完成初始化，则返回为空
  ///
  NEMeetingUIKitScreenSharingService getScreenSharingService();

  /// 开始一个新的会议，只有完成SDK的登录鉴权操作才允许创建会议。创建会议成功后，SDK会拉起会议页面，调用方不用做其他操作
  ///
  /// [param] 会议参数对象，不能为空
  /// [opts]  会议选项对象，可空；当未指定时，会使用默认的选项
  ///
  Future<NEResult<void>> startMeeting(
    BuildContext context,
    NEStartMeetingParams param,
    NEMeetingOptions opts, {
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
    Widget? backgroundWidget,
  });

  /// 加入一个当前正在进行中的会议，只有完成SDK的登录鉴权操作才允许加入会议。
  /// 加入会议成功后，SDK会拉起会议页面，调用方不用做其他操作
  ///
  /// [param] 会议参数对象，不能为空
  /// [opts]  会议选项对象，可空；当未指定时，会使用默认的选项
  ///
  Future<NEResult<void>> joinMeeting(
    BuildContext context,
    NEJoinMeetingParams param,
    NEMeetingOptions opts, {
    PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
    Widget? backgroundWidget,
  });

  ///  加入一个当前正在进行中的会议，已登录或未登录均可加入会议。
  ///  <p>加入会议成功后，SDK会拉起会议页面，调用方不用做其他操作。
  ///
  /// [param] 会议参数对象，不能为空
  /// [opts]  会议选项对象，可空；当未指定时，会使用默认的选项
  Future<NEResult<void>> anonymousJoinMeeting(
    BuildContext context,
    NEJoinMeetingParams param,
    NEMeetingOptions opts, {
    PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
  });

  /// 以访客身份加入一个当前正在进行中的会议。
  /// 加入会议成功后，SDK会拉起会议页面，调用方不用做其他操作。
  ///
  /// [param] 会议参数对象，不能为空
  /// [opts]  会议选项对象，可空；当未指定时，会使用默认的选项
  ///
  Future<NEResult<void>> guestJoinMeeting(
    BuildContext context,
    NEGuestJoinMeetingParams param,
    NEMeetingOptions opts, {
    PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
    Widget? backgroundWidget,
  });

  ///
  ///  离开当前进行中的会议，并通过参数控制是否同时结束当前会议；
  /// 只有主持人才能结束会议，其他用户设置结束会议无效；
  /// 如果退出当前会议后，会议中再无其他成员，则该会议也会结束；
  /// [closeIfHost] true：结束会议；false：不结束会议；
  ///
  Future<NEResult<void>> leaveCurrentMeeting(bool closeIfHost);

  ///
  /// 将当前正在进行中的会议页面关闭。不会退出或结束会议，会议继续在后台运行。 如果当前无进行中的会议，则调用无效。
  ///
  Future<NEResult<void>> minimizeCurrentMeeting();

  ///
  /// 从画中画模式恢复会议。如果当前无进行中的会议，则调用无效。
  ///
  Future<NEResult<void>> fullscreenCurrentMeeting();

  ///
  /// 更新当前存在的自定义菜单项的状态 注意：该接口更新菜单项的文本(最长为10，超过不生效)
  /// [item] 当前已存在的菜单项
  ///
  Future<NEResult<void>> updateInjectedMenuItem(NEMeetingMenuItem? item);

  ///
  /// 设置菜单项点击事件回调
  ///
  void setOnInjectedMenuItemClickListener(
      NEMeetingOnInjectedMenuItemClickListener listener);

  ///
  /// 通知注入菜单项点击事件
  ///
  Future<bool> notifyOnInjectedMenuItemClick(
      BuildContext context, NEMenuClickInfo clickInfo);

  ///
  /// 获取当前会议上下文。如果当前无正在进行中的会议，则回调数据对象为空
  ///
  NERoomContext? getCurrentRoomContext();

  ///
  /// 获取当前会议详情。如果当前无正在进行中的会议，则回调数据对象为空
  ///
  NEMeetingInfo? getCurrentMeetingInfo();

  ///
  /// 添加会议状态监听实例，用于接收会议状态变更通知
  ///
  /// [listener] 要添加的监听实例
  ///
  void addMeetingStatusListener(NEMeetingStatusListener listener);

  ///
  /// 移除对应的会议状态的监听实例
  ///
  /// [listener] 要移除的监听实例
  ///
  void removeMeetingStatusListener(NEMeetingStatusListener listener);

  ///
  /// 获取当前会议状态
  ///
  int getMeetingStatus();

  ///
  /// 打开美颜接口
  /// [context] 上下文
  ///
  Future<NEResult<void>> openBeautyUI(BuildContext context);

  ///
  /// 打开虚拟背景美颜接口
  ///
  Future<NEResult<void>> openVirtualBackgroundBeautyUI(BuildContext context);

  /// 获取当前语言环境下的邀请信息
  /// [meetingInfo] 会议信息
  Future<String> getInviteInfo(NEMeetingItem item);
}

class _NEMeetingUIKitImpl extends NEMeetingUIKit with _AloggerMixin {
  NEMeetingEvent _meetingStatus = NEMeetingEvent(NEMeetingStatus.idle);
  final Set<NEMeetingStatusListener> _meetingListenerSet =
      <NEMeetingStatusListener>{};

  NEMeetingOnInjectedMenuItemClickListener? _onInjectedMenuItemClickListener;

  _NEMeetingUIKitImpl() {
    MeetingCore().meetingStatusStream.listen((status) {
      commonLogger.i('on meeting status changed: status = ${status.status}');
      _meetingStatus = NEMeetingEvent(status.status, arg: status.arg);
      _meetingListenerSet.toList().forEach((element) {
        element.onMeetingStatusChanged(status);
      });
    });
    InMeetingService()
        .localHistoryMeetingStream
        .listen(LocalHistoryMeetingManager().addLocalHistoryMeeting);
  }

  @override
  Future<String> getInviteInfo(NEMeetingItem item) async {
    final timezone = await TimezonesUtil.getTimezoneById(item.timezoneId);
    final localizations = getUIKitLocalizations();
    var info = '${localizations.meetingInviteTitle}\n\n';

    info += '${localizations.meetingSubject} ${item.subject}\n';
    if (item.meetingType == NEMeetingType.kReservation) {
      final convertStartTime =
          TimezonesUtil.convertTimezoneDateTime(item.startTime, timezone);
      final convertEndTime =
          TimezonesUtil.convertTimezoneDateTime(item.endTime, timezone);
      info +=
          '${localizations.meetingTime} ${convertStartTime.formatToTimeString('yyyy/MM/dd HH:mm')} '
          '- ${convertEndTime.formatToTimeString('yyyy/MM/dd HH:mm')} ';
      info += '${timezone.time}';
      info += '\n';
    }

    info += '\n';
    if (TextUtils.isNotEmpty(item.shortMeetingNum)) {
      info += '${localizations.meetingShortNum} ${item.shortMeetingNum}\n';
    }
    if (TextUtils.isNotEmpty(item.meetingNum)) {
      info +=
          '${localizations.meetingNum} ${item.meetingNum!.toMeetingNumFormat()}\n';
    }
    if (item.enableGuestJoin) {
      info += '${localizations.meetingGuestJoinSupported}\n';
    }
    if (TextUtils.isNotEmpty(item.password)) {
      info += '${localizations.meetingPassword} ${item.password}\n';
    }
    if (TextUtils.isNotEmpty(item.sipCid)) {
      info += '\n';
      info += '${localizations.meetingSipNumber} ${item.sipCid}\n';
    }
    if (TextUtils.isNotEmpty(item.inviteUrl)) {
      info += '\n';
      info += '${localizations.meetingInviteUrl} ${item.inviteUrl}\n';
    }
    return info;
  }

  ///
  /// 设置菜单项点击事件回调
  ///
  void setOnInjectedMenuItemClickListener(
      NEMeetingOnInjectedMenuItemClickListener listener) {
    _onInjectedMenuItemClickListener = listener;
  }

  Future<bool> notifyOnInjectedMenuItemClick(
      BuildContext context, NEMenuClickInfo clickInfo) {
    commonLogger.i('on injected menu item click: id=${clickInfo.itemId}');
    return _onInjectedMenuItemClickListener?.call(
            context, clickInfo, getCurrentMeetingInfo()) ??
        Future.value(true);
  }

  ///
  /// 获取当前会议详情。如果当前无正在进行中的会议，则回调数据对象为空
  ///
  NEMeetingInfo? getCurrentMeetingInfo() {
    return InMeetingService().currentMeetingInfo();
  }

  ///
  /// 获取当前会议上下文。如果当前无正在进行中的会议，则回调数据对象为空
  ///
  NERoomContext? getCurrentRoomContext() {
    return InMeetingService().currentRoomContext();
  }

  ///
  /// 添加会议状态监听实例，用于接收会议状态变更通知
  ///
  /// * [listener] 要添加的监听实例
  ///
  void addMeetingStatusListener(NEMeetingStatusListener listener) {
    apiLogger.i('addMeetingStatusListener: $listener');
    _meetingListenerSet.add(listener);
  }

  ///
  /// 移除对应的会议状态的监听实例
  ///
  /// * [listener] 要移除的监听实例
  ///
  void removeMeetingStatusListener(NEMeetingStatusListener listener) {
    apiLogger.i('removeMeetingStatusListener: $listener');
    _meetingListenerSet.remove(listener);
  }

  ///
  /// 获取当前会议状态
  ///
  int getMeetingStatus() {
    apiLogger.i('getMeetingStatus: ${_meetingStatus.status}');
    return _meetingStatus.status;
  }

  @override
  ValueNotifier<Locale> get localeListenable {
    return CoreRepository().localeListenable;
  }

  NEMeetingUIKitLocalizations ofLocalizations([BuildContext? context]) {
    NEMeetingUIKitLocalizations? localizations;
    if (context != null) {
      localizations = NEMeetingUIKitLocalizations.of(context);
    }
    if (localizations == null) {
      localizations = lookupNEMeetingUIKitLocalizations(localeListenable.value);
    }
    return localizations;
  }

  @override
  Future<NEResult<void>> startMeeting(
    BuildContext context,
    NEStartMeetingParams param,
    NEMeetingOptions opts, {
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
    Widget? backgroundWidget,
  }) async {
    apiLogger.i('startMeetingUI');
    final event = IntervalEvent(kEventStartMeeting)
      ..addParam(kEventParamMeetingNum, param.meetingNum ?? '')
      ..addParam(kEventParamType,
          (param.meetingNum?.isEmpty ?? true) ? 'random' : 'personal');
    param.trackingEvent = event;

    MeetingUIServiceHelper().preload(context);

    final checkParamsResult = MeetingUIServiceHelper()._checkParameters(opts);
    if (checkParamsResult != null) {
      return checkParamsResult;
    }

    final checkIdleResult = MeetingUIServiceHelper()._isMeetingStatusIdle();
    if (checkIdleResult != null) {
      return checkIdleResult;
    }

    //这里需要提前拿到navigatorState，防止context被pop，导致navigator异常
    final navigatorState = Navigator.of(context, rootNavigator: true);

    return MeetingUIServiceHelper()
        .startMeeting(
      param,
      NEStartMeetingBaseOptions(
        noChat: opts.noChat,
        cloudRecordConfig: opts.cloudRecordConfig,
        noSip: opts.noSip,
        enableWaitingRoom: opts.enableWaitingRoom,
        enableMyAudioDeviceOnJoinRtc: opts.detectMutedMic,
        enableGuestJoin: opts.enableGuestJoin,
      ),
    )
        .map<NERoomContext>((roomContext) async {
      if (onMeetingPageRouteWillPush != null) {
        await onMeetingPageRouteWillPush();
      }
      try {
        final meetingArguments = MeetingArguments(
          roomContext: roomContext,
          meetingInfo: roomContext.meetingInfo,
          options: opts,
          encryptionConfig: param.encryptionConfig,
          backgroundWidget: backgroundWidget,
          watermarkConfig: param.watermarkConfig,
        )..trackingEvent = event;
        final popped = MeetingUIServiceHelper().navigatorToMeetingUI(
            navigatorState, roomContext, meetingArguments);
        onMeetingPageRouteDidPush?.call(popped);
      } catch (e) {
        commonLogger.e('push meeting page error: $e');
        return const NEResult<void>(
            code: NEMeetingErrorCode.failed, msg: 'push meeting page error}');
      }
      return NEResult<NERoomContext>(
          code: NEMeetingErrorCode.success, data: roomContext);
    }).thenReport(event, onlyFailure: true);
  }

  Future<NEResult<void>> joinMeeting(
    BuildContext context,
    NEJoinMeetingParams param,
    NEMeetingOptions opts, {
    PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
    Widget? backgroundWidget,
  }) async {
    apiLogger.i('joinMeetingUI');
    if (param.trackingEvent == null) {
      param.trackingEvent = IntervalEvent(kEventJoinMeeting)
        ..addParam(kEventParamMeetingNum, param.meetingNum)
        ..addParam(kEventParamType, 'normal');
    }
    final event = param.trackingEvent!;

    final joinOpts = NEJoinMeetingBaseOptions(
      enableMyAudioDeviceOnJoinRtc: opts.detectMutedMic,
    );
    return MeetingUIServiceHelper()
        .joinMeetingUIInner(
          context,
          param,
          joinOpts,
          opts,
          onPasswordPageRouteWillPush: onPasswordPageRouteWillPush,
          onMeetingPageRouteWillPush: onMeetingPageRouteWillPush,
          onMeetingPageRouteDidPush: onMeetingPageRouteDidPush,
          backgroundWidget: backgroundWidget,
        )
        .thenReport(event, onlyFailure: true);
  }

  Future<NEResult<void>> anonymousJoinMeeting(
    BuildContext context,
    NEJoinMeetingParams param,
    NEMeetingOptions opts, {
    PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
  }) async {
    bool isAnonymous = false;
    apiLogger.i('anonymousJoinMeetingUI');
    if (!AccountRepository().isLoggedIn) {
      final event = IntervalEvent(kEventJoinMeeting)
        ..addParam(kEventParamType, 'anonymous')
        ..addParam(kEventParamMeetingNum, param.meetingNum)
        ..beginStep(kMeetingStepAnonymousLogin);
      param.trackingEvent = event;
      var loginResult = await AccountRepository().anonymousLogin();
      if (loginResult.code ==
          NEMeetingErrorCode.reuseIMNotSupportAnonymousLogin) {
        loginResult = NEResult(
          code: loginResult.code,
          msg: NEMeetingUIKitLocalizations.of(context)!
              .meetingReuseIMNotSupportAnonymousJoinMeeting,
        );
      } else if (!loginResult.isSuccess()) {
        loginResult = NEResult(
          code: loginResult.code,
          msg: loginResult.msg ?? 'anonymous login error',
        );
      }
      event.endStepWithResult(loginResult);
      if (!loginResult.isSuccess()) {
        ReportRepository().reportEvent(event);
        return loginResult;
      }
      isAnonymous = true;
    }
    void logoutAnonymous(String reason) {
      if (isAnonymous) {
        commonLogger.i('logoutAnonymous: $reason');
        if (NEMeetingKit.instance.getAccountService().isAnonymous) {
          NEMeetingKit.instance.getAccountService().logout();
        }
      }
    }

    return joinMeeting(
      context,
      param,
      opts,
      onPasswordPageRouteWillPush: onPasswordPageRouteWillPush,
      onMeetingPageRouteWillPush: onMeetingPageRouteWillPush,
      onMeetingPageRouteDidPush: (popped) {
        final f = popped.whenComplete(() {
          logoutAnonymous('page popped');
        });
        onMeetingPageRouteDidPush?.call(f);
      },
    ).onFailure((_, __) => logoutAnonymous('join error'));
  }

  @override
  Future<NEResult<void>> guestJoinMeeting(
    BuildContext context,
    NEGuestJoinMeetingParams param,
    NEMeetingOptions opts, {
    PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
    Widget? backgroundWidget,
  }) async {
    bool isAnonymous = false;
    apiLogger.i('guestJoinMeetingUI');
    if (!AccountRepository().isLoggedIn) {
      final event = IntervalEvent(kEventJoinMeeting)
        ..addParam(kEventParamType, 'guest')
        ..addParam(kEventParamMeetingNum, param.meetingNum)
        ..beginStep(kMeetingStepMeetingInfo);
      param.trackingEvent = event;

      final meetingInfoResult =
          await GuestRepository().getMeetingInfoForGuestJoin(
        param.meetingNum!,
        phoneNum: param.phoneNumber,
        smsCode: param.smsCode,
      );
      event.endStepWithResult(meetingInfoResult);
      final authorization = meetingInfoResult.data?.authorization;
      if (!meetingInfoResult.isSuccess() || authorization == null) {
        ReportRepository().reportEvent(event);
        return meetingInfoResult.cast();
      }

      event.beginStep(kMeetingStepGuestLogin);
      assert(CoreRepository().isInitialized);
      final config =
          CoreRepository().initedConfig!.copyWith(appKey: authorization.appKey);
      var loginResult = await CoreRepository().initialize(config).map(() {
        return AccountRepository().guestLogin(
          authorization.user,
          authorization.token,
          authorization.authType,
        );
      });
      if (loginResult.code ==
          NEMeetingErrorCode.reuseIMNotSupportAnonymousLogin) {
        loginResult = NEResult(
          code: loginResult.code,
          msg: NEMeetingUIKitLocalizations.of(context)!
              .meetingReuseIMNotSupportAnonymousJoinMeeting,
        );
      } else if (!loginResult.isSuccess()) {
        loginResult = NEResult(
          code: loginResult.code,
          msg: loginResult.msg ?? 'guest login error',
        );
      }
      event.endStepWithResult(loginResult);
      if (!loginResult.isSuccess()) {
        ReportRepository().reportEvent(event);
        return loginResult;
      }
      isAnonymous = true;
    }
    void logoutAnonymous(String reason) {
      if (isAnonymous) {
        commonLogger.i('logoutGuest: $reason');
        if (NEMeetingKit.instance.getAccountService().isAnonymous) {
          NEMeetingKit.instance.getAccountService().logout();
        }
      }
    }

    return joinMeeting(
      context,
      param,
      opts,
      onPasswordPageRouteWillPush: onPasswordPageRouteWillPush,
      onMeetingPageRouteWillPush: onMeetingPageRouteWillPush,
      onMeetingPageRouteDidPush: (popped) {
        final f = popped.whenComplete(() {
          logoutAnonymous('page popped');
        });
        onMeetingPageRouteDidPush?.call(f);
      },
      backgroundWidget: backgroundWidget,
    ).onFailure((_, __) => logoutAnonymous('join error'));
  }

  ///
  /// 离开当前会议
  ///
  Future<NEResult<void>> leaveCurrentMeeting(bool closeIfHost) async {
    apiLogger.i('leaveCurrentMeeting: $closeIfHost');
    return InMeetingService().leaveCurrentMeeting(closeIfHost);
  }

  Future<NEResult<void>> fullscreenCurrentMeeting() =>
      checkInMeeting(InMeetingService().minimizeDelegate) ??
      InMeetingService().minimizeDelegate!.fullCurrentMeeting();

  Future<NEResult<void>> minimizeCurrentMeeting() =>
      checkInMeeting(InMeetingService().minimizeDelegate) ??
      InMeetingService().minimizeDelegate!.minimizeCurrentMeeting();

  Future<NEResult<void>> updateInjectedMenuItem(NEMeetingMenuItem? item) {
    if (item == null) {
      return Future.value(const NEResult(
          code: NEMeetingErrorCode.paramError, msg: 'item is null'));
    }
    if (item.isBuiltInMenuItem) {
      return Future.value(const NEResult(
          code: NEMeetingErrorCode.paramError, msg: 'item is built-in item'));
    }
    return checkInMeeting(InMeetingService().menuItemDelegate) ??
        InMeetingService().menuItemDelegate!.updateInjectedMenuItem(item);
  }

  Future<NEResult<void>>? checkInMeeting(dynamic manager) {
    if (manager == null) {
      return Future.value(const NEResult(
          code: NEMeetingErrorCode.failed, msg: 'meeting not exists.'));
    }
    return null;
  }

  Future<NEResult<void>> openBeautyUI(BuildContext context) async {
    final checkIdleResult = MeetingUIServiceHelper()._isMeetingStatusIdle();
    if (checkIdleResult != null) {
      return checkIdleResult;
    }

    Navigator.push(context,
        NEMeetingPageRoute(builder: (context) => PreBeautySettingPage()));
    return Future.value(const NEResult(code: NEMeetingErrorCode.success));
  }

  Future<NEResult<void>> openVirtualBackgroundBeautyUI(
      BuildContext context) async {
    final checkIdleResult = MeetingUIServiceHelper()._isMeetingStatusIdle();
    if (checkIdleResult != null) {
      return checkIdleResult;
    }

    Navigator.push(context,
        NEMeetingPageRoute(builder: (context) => NEPreVirtualBackgroundPage()));
    return Future.value(const NEResult(code: NEMeetingErrorCode.success));
  }

  Locale? _locale;

  NEMeetingUIKitLocalizations getUIKitLocalizations([BuildContext? context]) {
    NEMeetingUIKitLocalizations? localizations;
    if (context != null) {
      localizations = NEMeetingUIKitLocalizations.of(context);
    }
    if (localizations == null) {
      /// 初始化并监听语言变化
      if (_locale == null) {
        _locale = NEMeetingUIKit.instance.localeListenable.value;
        NEMeetingUIKit.instance.localeListenable.addListener(() {
          _locale = NEMeetingUIKit.instance.localeListenable.value;
        });
      }
      localizations = lookupNEMeetingUIKitLocalizations(_locale!);
    }
    return localizations;
  }

  @override
  NEMeetingUIKitInviteService getMeetingInviteService() {
    return NEMeetingUIKitInviteService.instance;
  }

  @override
  NEMeetingUIKitScreenSharingService getScreenSharingService() {
    return NEMeetingUIKitScreenSharingService.instance;
  }
}

/// 自定义菜单按钮点击事件回调，通过 [NEMeetingService.setOnInjectedMenuItemClickListener] 设置回调监听
///
/// [NEMeetingMenuItem] 为当前点击的菜单项
///
/// [NEMeetingInfo] 为当前会议信息
typedef NEMeetingOnInjectedMenuItemClickListener = Future<bool> Function(
    BuildContext context,
    NEMenuClickInfo clickInfo,
    NEMeetingInfo? meetingInfo);
