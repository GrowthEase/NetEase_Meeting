// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingUIServiceHelper {
  static final MeetingUIServiceHelper _instance = MeetingUIServiceHelper._();

  factory MeetingUIServiceHelper() => _instance;

  MeetingUIServiceHelper._();

  bool _preload = false;

  /// 带了参数check与错误码转换的startMeeting
  Future<NEResult<NERoomContext>> startMeeting(
    NEStartMeetingParams param,
    NEStartMeetingBaseOptions opts,
  ) async {
    final checkParamsResult = checkInnerParameters(param);
    if (checkParamsResult != null) {
      return checkParamsResult.cast();
    }
    if (!await ConnectivityManager().isConnected()) {
      return handleMeetingResultCode(MeetingErrorCode.networkError).cast();
    }
    final ret = await MeetingRepository().startMeeting(param, opts);
    if (ret.isSuccess()) {
      return ret;
    } else {
      return handleMeetingResultCode(ret.code, ret.msg).cast();
    }
  }

  /// 带了参数check与错误码转换的joinMeeting
  Future<NEResult<NERoomContext>> joinMeeting(
      NEJoinMeetingParams param, NEJoinMeetingBaseOptions opts,
      {isInvite = false}) async {
    final checkParamsResult = checkInnerParameters(param);
    if (checkParamsResult != null) {
      return checkParamsResult.cast();
    }
    if (!await ConnectivityManager().isConnected()) {
      return handleMeetingResultCode(MeetingErrorCode.networkError).cast();
    }
    final ret =
        await MeetingRepository().joinMeeting(param, opts, isInvite: isInvite);
    if (ret.isSuccess()) {
      return ret;
    } else {
      return handleMeetingResultCode(ret.code, ret.msg).cast();
    }
  }

  Future<NEResult<NERoomContext>> joinMeetingUIInner(
    BuildContext context,
    NEJoinMeetingParams param,
    NEJoinMeetingBaseOptions opts,
    NEMeetingOptions uiOpts, {
    bool isInvite = false,
    PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
    Widget? backgroundWidget,
  }) async {
    preload(context);
    final checkParamsResult = _checkParameters(uiOpts);
    if (checkParamsResult != null) {
      return checkParamsResult;
    }
    final checkIdleResult = _isMeetingStatusIdle();
    if (checkIdleResult != null) {
      return checkIdleResult;
    }
    final navigatorState = Navigator.of(context, rootNavigator: true);
    var joinResult = await joinMeeting(param, opts, isInvite: isInvite);
    if (joinResult.code == NEMeetingErrorCode.success &&
        joinResult.data != null) {
      final roomContext = joinResult.nonNullData;
      if (onMeetingPageRouteWillPush != null) {
        await onMeetingPageRouteWillPush();
      }
      final meetingArguments = MeetingArguments(
        roomContext: roomContext,
        meetingInfo: roomContext.meetingInfo,
        options: uiOpts,
        encryptionConfig: param.encryptionConfig,
        backgroundWidget: backgroundWidget,
        watermarkConfig: param.watermarkConfig,
      )..trackingEvent = param.trackingEvent;
      final popped =
          navigatorToMeetingUI(navigatorState, roomContext, meetingArguments);
      onMeetingPageRouteDidPush?.call(popped);
      return joinResult;
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
          .push(NEMeetingPageRoute(
              builder: (BuildContext context) => MeetingVerifyPasswordPage(
                    arguments: meetingWaitingArguments,
                  )))
          .then((value) async {
        if (value is NERoomContext) {
          if (onMeetingPageRouteWillPush != null) {
            await onMeetingPageRouteWillPush();
          }
          final meetingArguments = MeetingArguments(
            roomContext: value,
            meetingInfo: value.meetingInfo,
            options: uiOpts,
            encryptionConfig: param.encryptionConfig,
            backgroundWidget: backgroundWidget,
            watermarkConfig: param.watermarkConfig,
          )..trackingEvent = param.trackingEvent;
          final popped =
              navigatorToMeetingUI(navigatorState, value, meetingArguments);
          onMeetingPageRouteDidPush?.call(popped);
          return NEResult(code: NEMeetingErrorCode.success, data: value);
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
        precacheImage(
          const AssetImage(NEMeetingImages.waitingRoomBackground,
              package: NEMeetingImages.package),
          context,
        );
      } catch (e) {
        // Nothing to do
      }
    }
  }

  /// repo统一参数校验
  static NEResult<void>? checkInnerParameters(Object param) {
    NEMeetingUIKitLocalizations _localizations =
        NEMeetingUIKit.instance.getUIKitLocalizations();

    if ((param is NEStartMeetingParams && param.displayName.isEmpty) ||
        (param is NEJoinMeetingParams && param.displayName.isEmpty)) {
      return NEResult<void>(
          code: NEMeetingErrorCode.paramError,
          msg: _localizations.displayNameShouldNotBeEmpty);
    }

    if (param is NEStartMeetingParams &&
        (param.password != null &&
            (param.password!.length >
                    NEMeetingConstants.meetingPasswordMaxLen ||
                param.password!.length <
                    NEMeetingConstants.meetingPasswordMinLen ||
                !TextUtils.isLetterOrDigital(param.password!)))) {
      return NEResult<void>(
          code: NEMeetingErrorCode.paramError,
          msg: _localizations.meetingPasswordNotValid);
    }

    if (param is NEJoinMeetingParams && param.meetingNum.isEmpty) {
      return NEResult<void>(
          code: NEMeetingErrorCode.paramError,
          msg: _localizations.meetingIdShouldNotBeEmpty);
    }

    return null;
  }

  NEResult<NERoomContext>? _checkParameters(NEMeetingOptions opts) {
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
        opts.fullToolbarMenuItems.followedBy(opts.fullMoreMenuItems);
    final ids = <int>{};
    for (var element in allMenuItems) {
      if (element.itemId < firstInjectableMenuId &&
          !NEMenuIDs.all.contains(element.itemId)) {
        return NEResult<NERoomContext>(
            code: NEMeetingErrorCode.paramError,
            msg: '不允许添加非预置或非自定义的菜单项: id=${element.itemId}');
      }
      if (!ids.add(element.itemId) && element.itemId >= firstInjectableMenuId) {
        return NEResult<NERoomContext>(
            code: NEMeetingErrorCode.paramError,
            msg: '不允许添加相同Id的菜单项: id=${element.itemId}');
      }
    }

    for (var element in opts.fullToolbarMenuItems) {
      if (element.itemId < firstInjectableMenuId &&
          NEMenuIDs.toolbarExcludes.contains(element.itemId)) {
        return NEResult<NERoomContext>(
            code: NEMeetingErrorCode.paramError,
            msg: '该菜单项不允许添加至Toolbar菜单中: id=${element.itemId}');
      }
    }

    for (var element in opts.fullMoreMenuItems) {
      if (element.itemId < firstInjectableMenuId &&
          NEMenuIDs.moreExcludes.contains(element.itemId)) {
        return NEResult<NERoomContext>(
            code: NEMeetingErrorCode.paramError,
            msg: '该菜单项不允许添加到\'更多\'菜单中: id=${element.itemId}');
      }
    }
    return null;
  }

  NEResult<NERoomContext>? _isMeetingStatusIdle() {
    final status = MeetingCore().meetingStatus.status;
    if (status == NEMeetingStatus.inMeetingMinimized ||
        status == NEMeetingStatus.inMeeting ||
        status == NEMeetingStatus.inWaitingRoom) {
      return const NEResult(
        code: NEMeetingErrorCode.alreadyInMeeting,
        msg: 'already in meeting',
      );
    }
    return null;
  }

  Future<Object?> navigatorToMeetingUI(NavigatorState navigatorState,
          NERoomContext roomContext, MeetingArguments meetingArguments) =>
      navigatorState.push(NEMeetingPageRoute(
        builder: (context) => MeetingUIRouter(
          roomContext: roomContext,
          arguments: meetingArguments,
        ),
      ));
}
