// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 回调接口，用于监听会议状态变更事件
/// * [status] 会议状态事件对象
typedef NEMeetingStatusListener = void Function(NEMeetingStatus status);

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

class NEMeetingUIKit with _AloggerMixin, WidgetsBindingObserver {
  static final NEMeetingUIKit _instance = NEMeetingUIKit._();

  factory NEMeetingUIKit() => _instance;

  NEMeetingStatus _meetingStatus = NEMeetingStatus(NEMeetingEvent.idle);
  final Set<NEMeetingStatusListener> _meetingListenerSet =
      <NEMeetingStatusListener>{};

  NEMeetingOnInjectedMenuItemClickListener? _onInjectedMenuItemClickListener;

  bool _preload = false;
  NEMeetingUIKitConfig? _config;

  NEMeetingUIKit._() {
    MeetingCore().meetingStatusStream.listen((status) {
      commonLogger.i('on meeting status changed: status = ${status.event}');
      _meetingStatus = NEMeetingStatus(status.event, arg: status.arg);
      _meetingListenerSet.toList().forEach((element) {
        element(status);
      });
    });
    InMeetingService().historyMeetingItemStream.listen(
        NEMeetingKit.instance.getSettingsService().updateHistoryMeetingItem);
  }

  /// ui 初始化
  /// 预加载图片资源
  void preload(BuildContext context) {
    if (!_preload) {
      _preload = true;
      try {
        precacheImage(
          const AssetImage(NEMeetingImages.meetingJoin,
              package: NEMeetingImages.package),
          context,
        );
      } catch (e) {
        // Nothing to do
      }
    }
  }

  ///
  /// 开启音频dump
  ///
  Future<NEResult<void>> startAudioDump() {
    if (InMeetingService().audioManager == null) {
      return Future.value(
          const NEResult(code: NEMeetingErrorCode.failed, msg: '会议不在进行中'));
    }
    return InMeetingService().audioManager!.startAudioDump();
  }

  ///
  /// 关闭音频dump
  ///
  Future<NEResult<void>> stopAudioDump() {
    if (InMeetingService().audioManager == null) {
      return Future.value(
          const NEResult(code: NEMeetingErrorCode.failed, msg: '会议不在进行中'));
    }
    return InMeetingService().audioManager!.stopAudioDump();
  }

  ///
  /// 设置菜单项点击事件回调
  ///
  void setOnInjectedMenuItemClickListener(
      NEMeetingOnInjectedMenuItemClickListener listener) {
    _onInjectedMenuItemClickListener = listener;
  }

  Future<bool> _notifyOnInjectedMenuItemClick(
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
    return InMeetingService().currentMeetingInfo;
  }

  ///
  /// 添加会议状态监听实例，用于接收会议状态变更通知
  ///
  /// * [listener] 要添加的监听实例
  ///
  void addListener(NEMeetingStatusListener listener) {
    apiLogger.i('addListener: $listener');
    _meetingListenerSet.add(listener);
  }

  ///
  /// 移除对应的会议状态的监听实例
  ///
  /// * [listener] 要移除的监听实例
  ///
  void removeListener(NEMeetingStatusListener listener) {
    apiLogger.i('removeListener: $listener');
    _meetingListenerSet.remove(listener);
  }

  ///
  /// 获取当前会议状态
  ///
  NEMeetingStatus getMeetingStatus() {
    apiLogger.i('getMeetingStatus: $_meetingStatus');
    return _meetingStatus;
  }

  ///
  /// 初始化
  ///
  Future<NEResult<void>> initialize(NEMeetingUIKitConfig config) async {
    apiLogger.i('initializeUI');
    if (config.useAssetServerConfig && config.serverConfig == null) {
      try {
        final serverConfigJsonString = await NEMeetingPlugin()
            .getAssetService()
            .loadAssetAsString('xkit_server.config');
        if (serverConfigJsonString?.isEmpty ?? true) {
          commonLogger.e(
              '`useAssetServerConfig` is true, but `xkit_server.config` asset file is not exists or empty');
        } else {
          final serverConfigJson =
              jsonDecode(serverConfigJsonString as String) as Map;
          config.serverConfig =
              NEMeetingKitServerConfig.fromJson(serverConfigJson);
        }
      } catch (e, s) {
        commonLogger.e('parse server config error: $e\n$s');
      }
    }
    final result = await NEMeetingKit.instance.initialize(config);
    if (result.isSuccess()) {
      _config = config;
      MeetingCore().foregroundConfig = config.foregroundServiceConfig;
    }
    return result;
  }

  ///
  /// 切换语言
  ///
  Future<NEResult<void>> switchLanguage(NEMeetingLanguage? language) {
    return NEMeetingKit.instance
        .switchLanguage(language ?? NEMeetingLanguage.automatic);
  }

  ValueListenable<Locale> get localeListenable =>
      NEMeetingKit.instance.localeListenable;

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

  Future<NEResult<void>> startMeetingUI(
    BuildContext context,
    NEStartMeetingUIParams param,
    NEMeetingUIOptions opts, {
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
  }) async {
    apiLogger.i('startMeetingUI');
    NEMeetingUIKit().preload(context);

    final checkParamsResult = _checkParameters(opts);
    if (checkParamsResult != null) {
      return checkParamsResult;
    }

    final checkIdleResult = _isMeetingStatusIdle();
    if (checkIdleResult != null) {
      return checkIdleResult;
    }

    //这里需要提前拿到navigatorState，防止context被pop，导致navigator异常
    final navigatorState = Navigator.of(context, rootNavigator: true);

    return NEMeetingKit.instance
        .getMeetingService()
        .startMeeting(
          param,
          NEStartMeetingOptions(
            noChat: opts.noChat,
            noCloudRecord: opts.noCloudRecord,
            noSip: opts.noSip,
            enableMyAudioDeviceOnJoinRtc: opts.detectMutedMic,
          ),
        )
        .map<void>((roomContext) async {
      if (onMeetingPageRouteWillPush != null) {
        await onMeetingPageRouteWillPush();
      }
      try {
        final meetingArguments = MeetingArguments(
          roomContext: roomContext,
          meetingInfo: roomContext.meetingInfo,
          options: opts,
        );
        final popped = navigatorState.push(
          MaterialPageRoute(
            builder: (context) => MeetingPageProxy(meetingArguments),
          ),
        );
        onMeetingPageRouteDidPush?.call(popped);
      } catch (e) {
        commonLogger.e('push meeting page error: $e');
        return const NEResult<void>(
            code: NEMeetingErrorCode.failed, msg: 'push meeting page error}');
      }
      return const NEResult<void>(code: NEMeetingErrorCode.success);
    });
  }

  Future<NEResult<void>> joinMeetingUI(
    BuildContext context,
    NEJoinMeetingUIParams param,
    NEMeetingUIOptions opts, {
    PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
  }) async {
    apiLogger.i('joinMeetingUI');
    final joinOpts = NEJoinMeetingOptions(
      enableMyAudioDeviceOnJoinRtc: opts.detectMutedMic,
    );
    return _joinMeetingUIInner(
      context,
      param,
      joinOpts,
      opts,
      () {
        return NEMeetingKit.instance
            .getMeetingService()
            .joinMeeting(param, joinOpts);
      },
      onPasswordPageRouteWillPush: onPasswordPageRouteWillPush,
      onMeetingPageRouteWillPush: onMeetingPageRouteWillPush,
      onMeetingPageRouteDidPush: onMeetingPageRouteDidPush,
    );
  }

  Future<NEResult<void>> anonymousJoinMeetingUI(
    BuildContext context,
    NEJoinMeetingUIParams param,
    NEMeetingUIOptions opts, {
    PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
  }) async {
    bool isAnonymous = false;
    if (!NEMeetingKit.instance.getAccountService().isLoggedIn) {
      apiLogger.i('anonymousJoinMeetingUI');
      var loginResult = await NEMeetingKit.instance.anonymousLogin();
      if (loginResult.code ==
          NEMeetingErrorCode.reuseIMNotSupportAnonymousLogin) {
        return NEResult(
          code: loginResult.code,
          msg: NEMeetingUIKitLocalizations.of(context)!
              .reuseIMNotSupportAnonymousJoinMeeting,
        );
      } else if (!loginResult.isSuccess()) {
        return NEResult(
          code: loginResult.code,
          msg: loginResult.msg ?? 'anonymous login error',
        );
      }
      isAnonymous = true;
    }
    void logoutAnonymous(String reason) {
      if (isAnonymous) {
        commonLogger.i('logoutAnonymous: $reason');
        if (NEMeetingKit.instance.getAccountService().isAnonymous) {
          NEMeetingKit.instance.logout();
        }
      }
    }

    return joinMeetingUI(
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

  Future<NEResult<void>> _joinMeetingUIInner(
    BuildContext context,
    NEJoinMeetingUIParams param,
    NEJoinMeetingOptions opts,
    NEMeetingUIOptions uiOpts,
    Future<NEResult<NERoomContext>> Function() joinAction, {
    PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
  }) async {
    NEMeetingUIKit().preload(context);

    final checkParamsResult = _checkParameters(uiOpts);
    if (checkParamsResult != null) {
      return checkParamsResult;
    }
    final checkIdleResult = _isMeetingStatusIdle();
    if (checkIdleResult != null) {
      return checkIdleResult;
    }

    final navigatorState = Navigator.of(context, rootNavigator: true);

    var joinResult = await joinAction();
    if (joinResult.code == NEMeetingErrorCode.success &&
        joinResult.data != null) {
      final roomContext = joinResult.nonNullData;
      if (onMeetingPageRouteWillPush != null) {
        await onMeetingPageRouteWillPush();
      }
      final meetingArguments = MeetingArguments(
          roomContext: roomContext,
          meetingInfo: roomContext.meetingInfo,
          options: uiOpts);
      final popped = navigatorState.push(MaterialPageRoute(
          builder: (context) => MeetingPageProxy(meetingArguments)));
      onMeetingPageRouteDidPush?.call(popped);
      return joinResult.cast();
    } else if (joinResult.code == NEErrorCode.badPassword) {
      if (onPasswordPageRouteWillPush != null) {
        await onPasswordPageRouteWillPush();
      }
      final meetingWaitingArguments = MeetingWaitingArguments.verifyPassword(
        joinResult.code,
        joinResult.msg,
        param,
        opts,
      );
      return navigatorState
          .push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  MeetingPageProxy(meetingWaitingArguments)))
          .then((value) async {
        if (value is NERoomContext) {
          if (onMeetingPageRouteWillPush != null) {
            await onMeetingPageRouteWillPush();
          }
          final meetingArguments = MeetingArguments(
            roomContext: value,
            meetingInfo: value.meetingInfo,
            options: uiOpts,
          );
          final popped = navigatorState.push(MaterialPageRoute(
            builder: (context) => MeetingPageProxy(meetingArguments),
          ));
          onMeetingPageRouteDidPush?.call(popped);
          return const NEResult(code: NEMeetingErrorCode.success);
        } else {
          final code =
              value is NEResult ? value.code : NEMeetingErrorCode.failed;
          final msg = value is NEResult ? value.msg : 'unknown error';
          return NEResult(code: code, msg: msg);
        }
      });
    } else {
      return joinResult.cast();
    }
  }

  ///
  /// 离开当前会议
  ///
  Future<NEResult<void>> leaveCurrentMeeting(bool closeIfHost) async {
    apiLogger.i('leaveCurrentMeeting: $closeIfHost');
    return InMeetingService().leaveCurrentMeeting(closeIfHost);
  }

  Future<NEResult<void>> minimizeCurrentMeeting() {
    if (InMeetingService().minimizeDelegate == null) {
      return Future.value(const NEResult(
          code: NEMeetingErrorCode.failed, msg: 'meeting not exists.'));
    }
    return InMeetingService().minimizeDelegate!.minimizeCurrentMeeting();
  }

  Future<NEResult<void>> openBeautyUI(BuildContext context) async {
    final checkIdleResult = _isMeetingStatusIdle();
    if (checkIdleResult != null) {
      return checkIdleResult;
    }

    final level =
        await NEMeetingKit.instance.getSettingsService().getBeautyFaceValue();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BeautyPageProxy(beautyLevel: level)));
    return Future.value(const NEResult(code: NEMeetingErrorCode.success));
  }

  Future<NEResult<void>> openVirtualBackgroundBeautyUI(
      BuildContext context) async {
    final checkIdleResult = _isMeetingStatusIdle();
    if (checkIdleResult != null) {
      return checkIdleResult;
    }

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => VirtualBackgroundPageProxy()));
    return Future.value(const NEResult(code: NEMeetingErrorCode.success));
  }

  NEResult<void>? _checkParameters(NEMeetingUIOptions opts) {
    // if (_exceedMaxVisibleCount(opts.injectedToolbarMenuItems, 4)) {
    //   return const NEResult<void>(
    //       code: NEMeetingErrorCode.paramError,
    //       msg: '\'Toolbar\'菜单列表最多允许同时显示4个菜单项');
    // }
    // if (_exceedMaxVisibleCount(opts.injectedMoreMenuItems, 10)) {
    //   return const NEResult<void>(
    //       code: NEMeetingErrorCode.paramError, msg: '\'更多\'菜单列表最多允许同时显示10个菜单项');
    // }

    final allMenuItems =
        opts.injectedToolbarMenuItems.followedBy(opts.injectedMoreMenuItems);
    final ids = <int>{};
    for (var element in allMenuItems) {
      if (element.itemId < firstInjectableMenuId &&
          !NEMenuIDs.all.contains(element.itemId)) {
        return NEResult<void>(
            code: NEMeetingErrorCode.paramError,
            msg: '不允许添加非预置或非自定义的菜单项: id=${element.itemId}');
      }
      if (!ids.add(element.itemId)) {
        return NEResult<void>(
            code: NEMeetingErrorCode.paramError,
            msg: '不允许添加相同Id的菜单项: id=${element.itemId}');
      }
    }

    for (var element in opts.injectedToolbarMenuItems) {
      if (element.itemId < firstInjectableMenuId &&
          NEMenuIDs.toolbarExcludes.contains(element.itemId)) {
        return NEResult<void>(
            code: NEMeetingErrorCode.paramError,
            msg: '该菜单项不允许添加至Toolbar菜单中: id=${element.itemId}');
      }
    }

    for (var element in opts.injectedMoreMenuItems) {
      if (element.itemId < firstInjectableMenuId &&
          NEMenuIDs.moreExcludes.contains(element.itemId)) {
        return NEResult<void>(
            code: NEMeetingErrorCode.paramError,
            msg: '该菜单项不允许添加到\'更多\'菜单中: id=${element.itemId}');
      }
    }
    return null;
  }

  NEResult<void>? _isMeetingStatusIdle() {
    final status = MeetingCore().meetingStatus.event;
    if (status == NEMeetingEvent.inMeetingMinimized ||
        status == NEMeetingEvent.inMeeting) {
      return const NEResult(
        code: NEMeetingErrorCode.alreadyInMeeting,
        msg: 'already in meeting',
      );
    }
    return null;
  }
}

class NEMeetingUIKitConfig extends NEMeetingKitConfig {
  /// 应用名称，显示在会议页面的标题栏中
  final String? appName;

  /// Broadcast Upload Extension的App Group名称，iOS屏幕共享时使用
  final String? iosBroadcastAppGroup;

  /// 是否检查并使用asset资源目录下的私有化服务器配置文件，默认为false。
  final bool useAssetServerConfig;

  /// 前台服务配置
  final NEForegroundServiceConfig? foregroundServiceConfig;

  NEMeetingUIKitConfig({
    required String appKey,
    this.appName,
    this.useAssetServerConfig = false,
    this.iosBroadcastAppGroup,
    this.foregroundServiceConfig,
    NEMeetingKitServerConfig? serverConfig,
    String? serverUrl,
    Map<String, dynamic>? extras,
    ALoggerConfig? aLoggerConfig,
  }) : super(
          appKey: appKey,
          serverConfig: serverConfig,
          serverUrl: serverUrl,
          aLoggerConfig: aLoggerConfig,
          extras: extras,
        );
}

class NEStartMeetingUIParams extends NEStartMeetingParams {
  NEStartMeetingUIParams({
    required String displayName,
    String? subject,
    String? meetingNum,
    String? password,
    String? tag,
    String? avatar,
    String? extraData,
    List<NERoomControl>? controls,
    Map<String, NEMeetingRoleType>? roleBinds,
  }) : super(
          displayName: displayName,
          subject: subject,
          meetingNum: meetingNum,
          password: password,
          tag: tag,
          avatar: avatar,
          extraData: extraData,
          controls: controls,
          roleBinds: roleBinds,
        );

  NEStartMeetingUIParams.fromMap(Map map)
      : this(
          subject: map['subject'] as String?,
          meetingNum: map['meetingNum'] as String?,
          displayName: (map['displayName'] ?? '') as String,
          password: map['password'] as String?,
          tag: map['tag'] as String?,
          avatar: map['avatar'] as String?,
          extraData: map['extraData'] as String?,
          controls: (map['controls'] as List?)
              ?.map((e) =>
                  NERoomControl.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(),
          roleBinds:
              ((map['roleBinds']) as Map<String, dynamic>?)?.map((key, value) {
            var roleType = MeetingRoles.mapIntRoleToEnum(value);
            return MapEntry(key, roleType);
          }),
        );
}

class NEJoinMeetingUIParams extends NEJoinMeetingParams {
  NEJoinMeetingUIParams({
    required String meetingNum,
    required String displayName,
    String? password,
    String? tag,
    String? avatar,
  }) : super(
          meetingNum: meetingNum,
          displayName: displayName,
          password: password,
          tag: tag,
          avatar: avatar,
        );

  NEJoinMeetingUIParams.fromMap(Map map)
      : this(
          meetingNum: map['meetingNum'] as String,
          displayName: (map['displayName'] ?? '') as String,
          password: map['password'] as String?,
          tag: map['tag'] as String?,
          avatar: map['avatar'] as String?,
        );
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
