// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttermodule/src/account_service.dart';
import 'package:fluttermodule/src/callback.dart';
import 'package:fluttermodule/src/contacts_sercice.dart';
import 'package:fluttermodule/src/feedback_sercice.dart';
import 'package:fluttermodule/src/meeting_invite_service.dart';
import 'package:fluttermodule/src/meeting_message_channel_service.dart';
import 'package:fluttermodule/src/meeting_service.dart';
import 'package:fluttermodule/src/premeeting_service.dart';
import 'package:fluttermodule/src/screen_sharing_service.dart';
import 'package:fluttermodule/src/service.dart';
import 'package:fluttermodule/src/module_name.dart';
import 'package:fluttermodule/src/settings_service.dart';
import 'package:netease_common/netease_common.dart';
import 'package:netease_meeting_kit/meeting_core.dart';
import 'package:netease_meeting_kit/meeting_kit.dart';

class MeetingKitBridge {
  static const _tag = 'MeetingKitBridge';
  late BuildContext buildContext;

  // Platform API channel.
  final channel = MethodChannel(
      'com.netease.meeting/platform_bridge', const JSONMethodCodec());

  final Map<String, Service> _services = {};
  final appNameNotifier = ValueNotifier<String?>(null);

  bool _isFirstInitialize = true;

  MeetingKitBridge() {
    channel.setMethodCallHandler(_handlePlatformApiCall);
  }

  NEMeetingKit get meetingKit => NEMeetingKit.instance;

  NEMeetingService get meetingService => meetingKit.getMeetingService();

  NEContactsService get contactsService => meetingKit.getContactsService();

  NEMeetingInviteService get meetingInviteService =>
      meetingKit.getMeetingInviteService();

  NEMeetingMessageChannelService get meetingMessageChannelService =>
      meetingKit.getMeetingMessageChannelService();

  NEScreenSharingService get screenSharingService =>
      meetingKit.getScreenSharingService();

  NEAccountService get accountService => meetingKit.getAccountService();

  NESettingsService get settingsService => meetingKit.getSettingsService();

  NEFeedbackService get feedbackService => meetingKit.getFeedbackService();

  NEPreMeetingService get premeetingService =>
      meetingKit.getPreMeetingService();

  /// 当前是否存在flutter容器实例，原生不支持同时展示多个flutter页面
  bool inFlutterView = false;

  void _onInitialized(NEMeetingKitConfig config) {
    Alog.i(tag: _tag, moduleName: moduleName, content: 'onInitialized');
    appNameNotifier.value = config.appName;
    if (_isFirstInitialize) {
      _isFirstInitialize = false;
      _registerServices();
    }
  }

  void _registerServices() {
    Alog.i(tag: _tag, moduleName: moduleName, content: 'registerServices');
    _registerService(MeetingServiceBridge.asService(this));
    _registerService(AccountServiceBridge.asService(this));
    _registerService(SettingsServiceBridge.asService(this));
    _registerService(PreMeetingServiceBridge.asService(this));
    _registerService(ScreenSharingServiceBridge.asService(this));
    _registerService(MeetingInviteServiceBridge.asService(this));
    _registerService(ContactsServiceBridge.asService(this));
    _registerService(FeedbackServiceBridge.asService(this));
    _registerService(MeetingMessageChannelServiceBridge.asService(this));
  }

  void _registerService(Service service) {
    _services[service.name] = service;
  }

  // 原生平台API调用处理
  Future<dynamic> _handlePlatformApiCall(MethodCall call) async {
    try {
      String methodName;
      String? serviceName;
      var regExp = RegExp(r'(\w+)\.(\w+)');
      var match = regExp.matchAsPrefix(call.method);
      if (match == null) {
        methodName = call.method;
      } else {
        serviceName = match.group(1);
        methodName = match.group(2) as String;
        assert(serviceName != null && serviceName.isNotEmpty);
        assert(methodName.isNotEmpty);
      }

      final service = _services[serviceName];
      if (service != null) {
        return service.handleCall(methodName, call.arguments);
      }

      switch (methodName) {
        case 'initialize':
          return _handleInitialize(call);
        case 'switchLanguage':
          return _handleSwitchLanguage(call);
        case 'getSDKLogPath':
          return _handleGetSDKLogPath(call);
        case 'getAppNoticeTips':
          return _handleGetAppNoticeTips(call);
        case 'updateApnsToken':
          return _handleUpdateApnsToken(call);
      }
    } catch (e, s) {
      Alog.e(
          tag: _tag,
          moduleName: moduleName,
          content: 'PlatformApiCall exception: $e, stack: \n$s');
      return Callback.wrap(call.method, -1, msg: '${call.method} exception: $e')
          .result;
    }
    return Callback.wrap(call.method, -1, msg: '${call.method} not implemented')
        .result;
  }

  Future<Map> _handleInitialize(MethodCall call) async {
    final args = call.arguments as Map;
    final extras = args['extras'] as Map<String, dynamic>? ?? {};
    // 添加渠道为原生组件
    extras['_eventChannel'] = 'native_kit';
    var config = NEMeetingKitConfig(
      appKey: args['appKey'] as String?,
      corpCode: args['corpCode'] as String?,
      corpEmail: args['corpEmail'] as String?,
      appName: args['appName'] as String?,
      iosBroadcastAppGroup: args['broadcastAppGroup'] as String?,
      useAssetServerConfig: (args['useAssetServerConfig'] ?? false) as bool,
      serverUrl: args['serverUrl'] as String?,
      foregroundServiceConfig:
          NEForegroundServiceConfig.fromMap(args['foregroundConfig'] as Map?),
      extras: extras,
      language: _parseLanguageCode(args['language'] as String?),
      apnsCerName: args['apnsCerName'] as String?,
      mixPushConfig: args['mixPushConfig'] != null
          ? NEMeetingMixPushConfig.fromJson(args['mixPushConfig'] as Map)
          : null,
    );
    return meetingKit.initialize(config).then((value) {
      if (value.isSuccess()) {
        _onInitialized(config);
      }
      var _callback = Callback.wrap(call.method, value.code,
          msg: value.msg, data: value.data?.toJson());
      return _callback.result;
    });
  }

  Future<Map> _handleSwitchLanguage(MethodCall call) {
    final args = call.arguments as Map?;
    final name = args?['language'] as String?;
    return meetingKit.switchLanguage(_parseLanguageCode(name)).then((value) {
      var _callback = Callback.wrap(call.method, value.code, msg: value.msg);
      return _callback.result;
    });
  }

  Future<Map> _handleGetSDKLogPath(MethodCall call) {
    assert(call.arguments == null);
    return meetingKit.getSDKLogPath().then((value) {
      var _callback = Callback.wrap(call.method, 0, msg: null, data: value);
      return _callback.result;
    });
  }

  Future<Map> _handleGetAppNoticeTips(MethodCall call) {
    assert(call.arguments == null);
    return meetingKit.getAppNoticeTips().then((value) {
      var _callback = Callback.wrap(call.method, value.code,
          msg: value.msg, data: value.data?.toJson());
      return _callback.result;
    });
  }

  _handleUpdateApnsToken(MethodCall call) {
    assert(call.arguments == null);
    final data = call.arguments?['data'] as String;
    final key = call.arguments?['key'] as String?;
    return meetingKit.updateApnsToken(data, key).then((value) {
      var _callback = Callback.wrap(call.method, value.code, msg: value.msg);
      return _callback.result;
    });
  }

  NEMeetingLanguage? _parseLanguageCode(String? languageCode) {
    NEMeetingLanguage? language;
    languageCode = languageCode?.toLowerCase();
    if (languageCode == 'zh') {
      language = NEMeetingLanguage.chinese;
    } else if (languageCode == 'en') {
      language = NEMeetingLanguage.english;
    } else if (languageCode == 'ja') {
      language = NEMeetingLanguage.japanese;
    }
    return language;
  }
}
