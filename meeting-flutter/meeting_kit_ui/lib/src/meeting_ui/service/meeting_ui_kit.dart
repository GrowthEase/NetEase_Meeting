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

/// 提供会议相关的服务接口，诸如创建会议、加入会议、添加会议状态监听等。
abstract class NEMeetingUIKit {
  static final NEMeetingUIKit _instance = _NEMeetingUIKitImpl();

  /// 获取会议UI SDK实例
  static NEMeetingUIKit get instance => _instance;

  /// 获取UI SDK配置
  NEMeetingUIKitConfig? uiConfig;

  ///
  /// 多语言切换监听
  ///
  ValueListenable<Locale> get localeListenable;

  NEMeetingUIKitLocalizations getUIKitLocalizations([BuildContext? context]);

  ///
  /// 初始化
  ///
  Future<NEResult<NEMeetingCorpInfo?>> initialize(NEMeetingUIKitConfig config);

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
    NEStartMeetingUIParams param,
    NEMeetingUIOptions opts, {
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
    int? startTime,
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
    NEJoinMeetingUIParams param,
    NEMeetingUIOptions opts, {
    PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
    int? startTime,
    Widget? backgroundWidget,
  });

  ///  加入一个当前正在进行中的会议，已登录或未登录均可加入会议。
  ///  <p>加入会议成功后，SDK会拉起会议页面，调用方不用做其他操作。
  ///
  /// [param] 会议参数对象，不能为空
  /// [opts]  会议选项对象，可空；当未指定时，会使用默认的选项
  Future<NEResult<void>> anonymousJoinMeeting(
    BuildContext context,
    NEJoinMeetingUIParams param,
    NEMeetingUIOptions opts, {
    PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
    int? startTime,
  });

  ///
  ///  离开当前进行中的会议，并通过参数控制是否同时结束当前会议；
  /// 只有主持人才能结束会议，其他用户设置结束会议无效；
  /// 如果退出当前会议后，会议中再无其他成员，则该会议也会结束；
  /// [closeIfHost] true：结束会议；false：不结束会议；
  ///
  Future<NEResult<void>> leaveCurrentMeeting(bool closeIfHost);

  ///
  /// 切换语言
  ///
  Future<NEResult<void>> switchLanguage(NEMeetingLanguage? language);

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
  /// 获取本地历史会议记录列表，不支持漫游保存，默认保存最近10条记录
  /// 结果，数据类型为[NELocalHistoryMeeting]列表
  ///
  List<NELocalHistoryMeeting> getLocalHistoryMeetingList();

  ///
  /// 获取当前会议状态
  ///
  NEMeetingStatus getMeetingStatus();

  ///
  /// 开启音频dump
  ///
  Future<NEResult<void>> startAudioDump();

  ///
  /// 关闭音频dump
  ///
  Future<NEResult<void>> stopAudioDump();

  ///
  /// 打开美颜接口
  /// [context] 上下文
  ///
  Future<NEResult<void>> openBeautyUI(BuildContext context);

  ///
  /// 打开虚拟背景美颜接口
  ///
  Future<NEResult<void>> openVirtualBackgroundBeautyUI(BuildContext context);
}

class _NEMeetingUIKitImpl extends NEMeetingUIKit
    with _AloggerMixin, WidgetsBindingObserver {
  NEMeetingStatus _meetingStatus = NEMeetingStatus(NEMeetingEvent.idle);
  final Set<NEMeetingStatusListener> _meetingListenerSet =
      <NEMeetingStatusListener>{};

  NEMeetingOnInjectedMenuItemClickListener? _onInjectedMenuItemClickListener;

  _NEMeetingUIKitImpl() {
    MeetingCore().meetingStatusStream.listen((status) {
      commonLogger.i('on meeting status changed: status = ${status.event}');
      _meetingStatus = NEMeetingStatus(status.event, arg: status.arg);
      _meetingListenerSet.toList().forEach((element) {
        element(status);
      });
    });
    InMeetingService()
        .localHistoryMeetingStream
        .listen(LocalHistoryMeetingManager().addLocalHistoryMeeting);
  }

  ///
  /// 开启音频dump
  ///
  Future<NEResult<void>> startAudioDump() =>
      checkInMeeting(InMeetingService().audioManager) ??
      InMeetingService().audioManager!.startAudioDump();

  ///
  /// 关闭音频dump
  ///
  Future<NEResult<void>> stopAudioDump() =>
      checkInMeeting(InMeetingService().audioManager) ??
      InMeetingService().audioManager!.stopAudioDump();

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
  NEMeetingStatus getMeetingStatus() {
    apiLogger.i('getMeetingStatus: ${_meetingStatus.event}');
    return _meetingStatus;
  }

  ///
  /// 初始化
  ///
  Future<NEResult<NEMeetingCorpInfo?>> initialize(
      NEMeetingUIKitConfig config) async {
    apiLogger.i(
        'initializeUI useAssetServerConfig = ${config.useAssetServerConfig}');
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
          config = config.copyWith(
              serverConfig:
                  NEMeetingKitServerConfig.fromJson(serverConfigJson));
        }
      } catch (e, s) {
        commonLogger.e('parse server config error: $e\n$s');
      }
    }
    final result = await NEMeetingKit.instance.initialize(config);
    if (result.isSuccess()) {
      uiConfig = config;
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

  @override
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

  @override
  Future<NEResult<void>> startMeeting(
    BuildContext context,
    NEStartMeetingUIParams param,
    NEMeetingUIOptions opts, {
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
    int? startTime,
    Widget? backgroundWidget,
  }) async {
    apiLogger.i('startMeetingUI');
    final event = IntervalEvent(kEventStartMeeting, startTime: startTime)
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

    return NEMeetingKit.instance
        .getMeetingService()
        .startMeeting(
          param,
          NEStartMeetingOptions(
            noChat: opts.noChat,
            noCloudRecord: opts.noCloudRecord,
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
    NEJoinMeetingUIParams param,
    NEMeetingUIOptions opts, {
    PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
    int? startTime,
    Widget? backgroundWidget,
  }) async {
    apiLogger.i('joinMeetingUI');
    if (param.trackingEvent == null) {
      param.trackingEvent =
          IntervalEvent(kEventJoinMeeting, startTime: startTime)
            ..addParam(kEventParamMeetingNum, param.meetingNum)
            ..addParam(kEventParamType, 'normal');
    }
    final event = param.trackingEvent!;

    final joinOpts = NEJoinMeetingOptions(
      enableMyAudioDeviceOnJoinRtc: opts.detectMutedMic,
    );
    return MeetingUIServiceHelper().joinMeetingUIInner(
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
      backgroundWidget: backgroundWidget,
    ).thenReport(event, onlyFailure: true);
  }

  Future<NEResult<void>> anonymousJoinMeeting(
    BuildContext context,
    NEJoinMeetingUIParams param,
    NEMeetingUIOptions opts, {
    PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
    int? startTime,
  }) async {
    bool isAnonymous = false;
    if (NEMeetingKit.instance.getAccountService().getAccountInfo() == null) {
      apiLogger.i('anonymousJoinMeetingUI');
      final event = IntervalEvent(kEventJoinMeeting, startTime: startTime)
        ..addParam(kEventParamType, 'anonymous')
        ..addParam(kEventParamMeetingNum, param.meetingNum)
        ..beginStep(kMeetingStepAnonymousLogin);
      param.trackingEvent = event;
      var loginResult = await NEMeetingKit.instance.anonymousLogin();
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
        NEMeetingKit.instance.reportEvent(event);
        return loginResult;
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
      startTime: startTime,
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

    final level =
        await NEMeetingKit.instance.getSettingsService().getBeautyFaceValue();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BeautySettingPage(beautyLevel: level)));
    return Future.value(const NEResult(code: NEMeetingErrorCode.success));
  }

  Future<NEResult<void>> openVirtualBackgroundBeautyUI(
      BuildContext context) async {
    final checkIdleResult = MeetingUIServiceHelper()._isMeetingStatusIdle();
    if (checkIdleResult != null) {
      return checkIdleResult;
    }

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => NEPreVirtualBackgroundPage()));
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
  List<NELocalHistoryMeeting> getLocalHistoryMeetingList() {
    return NEMeetingKit.instance
        .getMeetingService()
        .getLocalHistoryMeetingList();
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
    super.appKey,
    super.corpCode,
    super.corpEmail,
    this.appName,
    this.useAssetServerConfig = false,
    this.iosBroadcastAppGroup,
    this.foregroundServiceConfig,
    super.language,
    super.serverConfig,
    super.serverUrl,
    super.extras,
  });

  NEMeetingUIKitConfig copyWith({
    String? appName,
    String? iosBroadcastAppGroup,
    bool? useAssetServerConfig,
    NEForegroundServiceConfig? foregroundServiceConfig,
    NEMeetingKitServerConfig? serverConfig,
    String? serverUrl,
    NEMeetingLanguage? language,
    Map<String, dynamic>? extras,
  }) {
    return NEMeetingUIKitConfig(
      appKey: appKey,
      corpCode: corpCode,
      corpEmail: corpEmail,
      appName: appName ?? this.appName,
      useAssetServerConfig: useAssetServerConfig ?? this.useAssetServerConfig,
      iosBroadcastAppGroup: iosBroadcastAppGroup ?? this.iosBroadcastAppGroup,
      foregroundServiceConfig:
          foregroundServiceConfig ?? this.foregroundServiceConfig,
      serverConfig: serverConfig ?? this.serverConfig,
      serverUrl: serverUrl ?? this.serverUrl,
      language: language ?? this.language,
      extras: extras ?? this.extras,
    );
  }

  @override
  int get hashCode => Object.hash(
        appName,
        iosBroadcastAppGroup,
        useAssetServerConfig,
        super.hashCode,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NEMeetingUIKitConfig &&
        appName == other.appName &&
        iosBroadcastAppGroup == other.iosBroadcastAppGroup &&
        useAssetServerConfig == other.useAssetServerConfig &&
        super == other;
  }
}

class NEStartMeetingUIParams extends NEStartMeetingParams {
  NEWatermarkConfig? watermarkConfig;

  NEStartMeetingUIParams({
    required String displayName,
    String? subject,
    String? meetingNum,
    String? password,
    String? tag,
    String? avatar,
    String? extraData,
    List<NEMeetingControl>? controls,
    Map<String, NEMeetingRoleType>? roleBinds,
    NEEncryptionConfig? encryptionConfig,
    this.watermarkConfig,
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
          encryptionConfig: encryptionConfig,
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
              ?.map((e) => NEMeetingControl.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList(),
          roleBinds:
              ((map['roleBinds']) as Map<String, dynamic>?)?.map((key, value) {
            var roleType = MeetingRoles.mapIntRoleToEnum(value);
            return MapEntry(key, roleType);
          }),
          encryptionConfig: map['encryptionConfig'] == null
              ? null
              : NEEncryptionConfig.fromJson(
                  Map<String, dynamic>.from(map['encryptionConfig'] as Map)),
          watermarkConfig: map['watermarkConfig'] == null
              ? null
              : NEWatermarkConfig.fromJson(
                  Map<String, dynamic>.from(map['watermarkConfig'] as Map)),
        );
}

class NEJoinMeetingUIParams extends NEJoinMeetingParams {
  NEWatermarkConfig? watermarkConfig;

  NEJoinMeetingUIParams({
    required String meetingNum,
    required String displayName,
    String? password,
    String? tag,
    String? avatar,
    NEEncryptionConfig? encryptionConfig,
    this.watermarkConfig,
  }) : super(
          meetingNum: meetingNum,
          displayName: displayName,
          password: password,
          tag: tag,
          avatar: avatar,
          encryptionConfig: encryptionConfig,
        );

  NEJoinMeetingUIParams.fromMap(Map map)
      : this(
          meetingNum: map['meetingNum'] as String? ?? '',
          displayName: (map['displayName'] ?? '') as String,
          password: map['password'] as String?,
          tag: map['tag'] as String?,
          avatar: map['avatar'] as String?,
          encryptionConfig: map['encryptionConfig'] == null
              ? null
              : NEEncryptionConfig.fromJson(
                  Map<String, dynamic>.from(map['encryptionConfig'] as Map)),
          watermarkConfig: map['watermarkConfig'] == null
              ? null
              : NEWatermarkConfig.fromJson(
                  Map<String, dynamic>.from(map['watermarkConfig'] as Map)),
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
