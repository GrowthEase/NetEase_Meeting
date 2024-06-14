// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingUIServiceHelper {
  static final MeetingUIServiceHelper _instance = MeetingUIServiceHelper._();

  factory MeetingUIServiceHelper() => _instance;

  MeetingUIServiceHelper._();

  bool _preload = false;

  Future<NEResult<NERoomContext>> joinMeetingUIInner(
    BuildContext context,
    NEJoinMeetingUIParams param,
    NEJoinMeetingOptions opts,
    NEMeetingUIOptions uiOpts,
    Future<NEResult<NERoomContext>> Function() joinAction, {
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
          .push(MaterialPageRoute(
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

  NEResult<NERoomContext>? _checkParameters(NEMeetingUIOptions opts) {
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

    for (var element in opts.injectedToolbarMenuItems) {
      if (element.itemId < firstInjectableMenuId &&
          NEMenuIDs.toolbarExcludes.contains(element.itemId)) {
        return NEResult<NERoomContext>(
            code: NEMeetingErrorCode.paramError,
            msg: '该菜单项不允许添加至Toolbar菜单中: id=${element.itemId}');
      }
    }

    for (var element in opts.injectedMoreMenuItems) {
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
    final status = MeetingCore().meetingStatus.event;
    if (status == NEMeetingEvent.inMeetingMinimized ||
        status == NEMeetingEvent.inMeeting ||
        status == NEMeetingEvent.inWaitingRoom) {
      return const NEResult(
        code: NEMeetingErrorCode.alreadyInMeeting,
        msg: 'already in meeting',
      );
    }
    return null;
  }

  Future<Object?> navigatorToMeetingUI(NavigatorState navigatorState,
          NERoomContext roomContext, MeetingArguments meetingArguments) =>
      navigatorState.push(MaterialPageRoute(
        builder: (context) => MeetingUIRouter(
          roomContext: roomContext,
          arguments: meetingArguments,
        ),
      ));
}
