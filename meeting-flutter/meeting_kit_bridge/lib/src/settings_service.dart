// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:fluttermodule/meeting_kit_bridge.dart';
import 'package:fluttermodule/src/service.dart';
import 'package:netease_meeting_kit/meeting_core.dart';

class SettingsServiceBridge implements Service {
  final MeetingKitBridge meetingKitBridge;

  SettingsServiceBridge.asService(this.meetingKitBridge);

  bool _listenerSet = false;

  void _notifySettingsChanged() {
    final settingsMap = meetingKitBridge.settingsService.value;
    meetingKitBridge.channel
        .invokeMethod('$name.onSettingsChanged', settingsMap);
  }

  @override
  String get name => 'settings';

  @override
  Future handleCall(String method, arguments) {
    final settingService = meetingKitBridge.settingsService;
    Future? result;
    switch (method) {
      case Keys.keyLoadSettings:
        _notifySettingsChanged();
        if (!_listenerSet) {
          _listenerSet = true;
          meetingKitBridge.settingsService.addListener(_notifySettingsChanged);
        }
        break;
      case Keys.enableShowMyMeetingElapseTime:
        assert(arguments is bool);
        settingService.enableShowMyMeetingElapseTime(arguments as bool);
        break;
      case Keys.enableTurnOnMyVideoWhenJoinMeeting:
        assert(arguments is bool);
        settingService.enableTurnOnMyVideoWhenJoinMeeting(arguments as bool);
        break;
      case Keys.enableTurnOnMyAudioWhenJoinMeeting:
        assert(arguments is bool);
        settingService.enableTurnOnMyAudioWhenJoinMeeting(arguments as bool);
        break;
      case Keys.enableAudioAINS:
        assert(arguments is bool);
        settingService.enableAudioAINS(arguments as bool);
        break;
      case Keys.enableVirtualBackground:
        assert(arguments is bool);
        settingService.enableVirtualBackground(arguments as bool);
        break;
      case Keys.setBuiltinVirtualBackgroundList:
        assert(arguments is List);
        settingService.setBuiltinVirtualBackgroundList(
            (arguments as List).map((element) => element.toString()).toList());
        break;
      case Keys.setExternalVirtualBackgroundList:
        assert(arguments is List);
        settingService.setExternalVirtualBackgroundList(
            (arguments as List).map((element) => element.toString()).toList());
        break;
      case Keys.setCurrentVirtualBackground:
        assert(arguments is String?);
        settingService.setCurrentVirtualBackground(arguments as String?);
        break;
      case Keys.enableSpeakerSpotlight:
        assert(arguments is bool);
        settingService.enableSpeakerSpotlight(arguments as bool);
        break;
      case Keys.enableFrontCameraMirror:
        assert(arguments is bool);
        settingService.enableFrontCameraMirror(arguments as bool);
        break;
      case Keys.enableTransparentWhiteboard:
        assert(arguments is bool);
        settingService.enableTransparentWhiteboard(arguments as bool);
        break;
      case Keys.setBeautyFaceValue:
        assert(arguments is int);
        settingService.setBeautyFaceValue(arguments as int);
        break;
      case Keys.setCloudRecordConfig:
        assert(arguments is Map);
        settingService.setCloudRecordConfig(
            NECloudRecordConfig.fromJson(arguments as Map));
        break;
      default:
        throw UnimplementedError('$method not implemented');
    }
    return result ?? Future.value();
  }
}

class Keys {
  static const String keyLoadSettings = 'loadSettings';

  static const String enableShowMyMeetingElapseTime =
      'enableShowMyMeetingElapseTime';

  static const String enableTurnOnMyVideoWhenJoinMeeting =
      'enableTurnOnMyVideoWhenJoinMeeting';

  static const String enableTurnOnMyAudioWhenJoinMeeting =
      'enableTurnOnMyAudioWhenJoinMeeting';

  static const String enableAudioAINS = 'enableAudioAINS';

  static const String enableVirtualBackground = 'enableVirtualBackground';

  static const String setBuiltinVirtualBackgroundList =
      'setBuiltinVirtualBackgroundList';

  static const String setExternalVirtualBackgroundList =
      'setExternalVirtualBackgroundList';

  static const String setCurrentVirtualBackground =
      'setCurrentVirtualBackground';

  static const String enableSpeakerSpotlight = "enableSpeakerSpotlight";

  static const String enableFrontCameraMirror = "enableFrontCameraMirror";

  static const String enableTransparentWhiteboard =
      "enableTransparentWhiteboard";

  static const String setBeautyFaceValue = "setBeautyFaceValue";

  static const String setCloudRecordConfig = "setCloudRecordConfig";
}
