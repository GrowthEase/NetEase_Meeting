// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttermodule/meeting_kit_bridge.dart';
import 'package:fluttermodule/src/callback.dart';
import 'package:fluttermodule/src/service.dart';
import 'package:netease_meeting_kit/meeting_kit.dart';

class PreMeetingServiceBridge extends Service with NEPreMeetingListener {
  final MeetingKitBridge meetingKitBridge;

  PreMeetingServiceBridge.asService(this.meetingKitBridge) {
    meetingKitBridge.premeetingService.addListener(this);
  }

  @override
  Future handleCall(String method, arguments) {
    switch (method) {
      case 'scheduleMeeting':
        return _handleScheduleMeeting(arguments);
      case 'editMeeting':
        return _handleEditMeeting(arguments);
      case 'cancelMeeting':
        return _handleCancelMeeting(arguments);
      case 'getMeetingItemById':
        return _getMeetingItemById(arguments);
      case 'getMeetingItemByNum':
        return _getMeetingItemByNum(arguments);
      case 'getScheduledMeetingMemberList':
        return _getScheduledMeetingMemberList(arguments);
      case 'getMeetingList':
        return _getMeetingItemListByStatus(arguments);
      case 'getFavoriteMeetingList':
        return _getFavoriteMeetingList(arguments);
      case 'addFavoriteMeeting':
        return _addFavoriteMeeting(arguments);
      case 'removeFavoriteMeeting':
        return _removeFavoriteMeeting(arguments);
      case 'getHistoryMeetingList':
        return _getHistoryMeetingList(arguments);
      case 'getHistoryMeetingDetail':
        return _getHistoryMeetingDetail(arguments);
      case 'getHistoryMeeting':
        return _getHistoryMeeting(arguments);
      case 'getMeetingItemByInviteCode':
        return _getMeetingItemByInviteCode(arguments);
      case 'getInviteInfo':
        return _getInviteInfo(arguments);
      case 'getHistoryMeetingTranscriptionInfo':
        return _handleGetHistoryMeetingTranscriptionInfo(arguments);
      case 'getHistoryMeetingTranscriptionFileUrl':
        return _handleGetHistoryMeetingTranscriptionFileUrl(arguments);
      case 'getHistoryMeetingTranscriptionMessageList':
        return _handleGetHistoryMeetingTranscriptionMessageList(arguments);
      case 'getLocalHistoryMeetingList':
        return _handleGetLocalHistoryMeetingList();
      case 'getMeetingCloudRecordList':
        return _handleGetMeetingCloudRecordList(arguments);
      case 'loadWebAppView':
        return _handleLoadWebAppView(arguments);
      case 'fetchChatroomHistoryMessageList':
        return _handleFetchChatroomHistoryMessageList(arguments);
      case 'clearLocalHistoryMeetingList':
        return _handleClearLocalHistoryMeetingList();
    }
    return super.handleCall(method, arguments);
  }

  String mapRPCName(String method) => '$name.$method';

  @override
  String get name => 'premeeting';

  @override
  void onMeetingItemInfoChanged(List<NEMeetingItem> meetingItemList) {
    if (meetingItemList.isEmpty) return;
    meetingKitBridge.channel.invokeMethod(
      mapRPCName('onMeetingItemInfoChanged'),
      {
        'itemList': meetingItemList.map((e) => e.toJson()).toList(),
      },
    ).catchError((err) {});
  }

  Future _handleScheduleMeeting(arguments) async {
    assert(arguments is Map);
    return meetingKitBridge.premeetingService
        .scheduleMeeting(NEMeetingItem.fromNativeJson(arguments as Map))
        .then((NEResult<NEMeetingItem> result) {
      return Callback.wrap('scheduleMeeting', result.code,
              msg: result.msg, data: result.data?.toJson())
          .result;
    });
  }

  Future _handleEditMeeting(arguments) async {
    assert(arguments is Map);
    return meetingKitBridge.premeetingService
        .editMeeting(NEMeetingItem.fromNativeJson(arguments['item'] as Map),
            arguments['editRecurringMeeting'] as bool)
        .then((NEResult<NEMeetingItem> result) {
      return Callback.wrap('editMeeting', result.code,
              msg: result.msg, data: result.data?.toJson())
          .result;
    });
  }

  Future _handleCancelMeeting(arguments) {
    assert(arguments is Map);
    return meetingKitBridge.premeetingService
        .cancelMeeting(arguments['meetingId'] as int,
            arguments['cancelRecurringMeeting'] as bool)
        .then((NEResult<void> result) {
      return Callback.wrap('cancelMeeting', result.code, msg: result.msg)
          .result;
    });
  }

  Future _getMeetingItemById(arguments) {
    return meetingKitBridge.premeetingService
        .getMeetingItemById(arguments as int? ?? 0)
        .then((NEResult<NEMeetingItem> result) {
      return Callback.wrap('getMeetingItemById', result.code,
              msg: result.msg, data: result.data?.toJson())
          .result;
    });
  }

  Future _getMeetingItemByNum(arguments) {
    return meetingKitBridge.premeetingService
        .getMeetingItemByNum(arguments as String? ?? '')
        .then((NEResult<NEMeetingItem> result) {
      return Callback.wrap('getMeetingItemByNum', result.code,
              msg: result.msg, data: result.data?.toJson())
          .result;
    });
  }

  Future _getScheduledMeetingMemberList(arguments) {
    return meetingKitBridge.premeetingService
        .getScheduledMeetingMemberList(arguments as String? ?? '')
        .then((NEResult<List<NEScheduledMember>> result) {
      return Callback.wrap('getScheduledMeetingMemberList', result.code,
              msg: result.msg,
              data: result.data?.map((e) => e.toJson()).toList())
          .result;
    });
  }

  Future _getMeetingItemListByStatus(arguments) {
    assert(arguments == null || arguments is List);
    List<NEMeetingItemStatus>? statusList;
    if (arguments is List) {
      statusList = arguments
          .map<NEMeetingItemStatus>(
              (index) => NEMeetingItemStatus.values[index as int])
          .toList();
    }
    if (statusList != null && statusList.isNotEmpty) {
      return meetingKitBridge.premeetingService
          .getMeetingList(statusList)
          .then((NEResult<List<NEMeetingItem>> result) {
        return Callback.wrap(
          'getMeetingList',
          result.code,
          msg: result.msg,
          data: result.data?.map((e) => e.toJson()).toList(),
        ).result;
      });
    } else {
      return Callback.success('getMeetingList').result;
    }
  }

  Future _getFavoriteMeetingList(arguments) {
    assert(arguments == null || arguments is Map);
    final startId = arguments?['anchorMeetingId'] as int? ?? 0;
    final limit = arguments?['limit'] as int?;
    return meetingKitBridge.premeetingService
        .getFavoriteMeetingList(startId, limit ?? 20)
        .then((NEResult<List<NERemoteHistoryMeeting>> result) {
      return Callback.wrap('getFavoriteMeetingList', result.code,
              msg: result.msg,
              data: result.data?.map((e) => e.toJson()).toList())
          .result;
    });
  }

  Future _addFavoriteMeeting(arguments) {
    return meetingKitBridge.premeetingService
        .addFavoriteMeeting(arguments as int? ?? 0)
        .then((NEResult<int> result) {
      return Callback.wrap('addFavoriteMeeting', result.code,
              msg: result.msg, data: result.data)
          .result;
    });
  }

  Future _removeFavoriteMeeting(arguments) {
    return meetingKitBridge.premeetingService
        .removeFavoriteMeeting(arguments as int? ?? 0)
        .then((NEResult<void> result) {
      return Callback.wrap('removeFavoriteMeeting', result.code,
              msg: result.msg)
          .result;
    });
  }

  Future _getHistoryMeetingList(arguments) {
    assert(arguments == null || arguments is Map);
    final startId = arguments?['anchorId'] as int? ?? 0;
    final limit = arguments?['limit'] as int?;
    return meetingKitBridge.premeetingService
        .getHistoryMeetingList(startId, limit ?? 20)
        .then((NEResult<List<NERemoteHistoryMeeting>> result) {
      return Callback.wrap('getHistoryMeetingList', result.code,
              msg: result.msg,
              data: result.data?.map((e) => e.toJson()).toList())
          .result;
    });
  }

  Future _getHistoryMeetingDetail(arguments) {
    return meetingKitBridge.premeetingService
        .getHistoryMeetingDetail(arguments as int? ?? 0)
        .then((NEResult<NERemoteHistoryMeetingDetail> result) {
      return Callback.wrap('getHistoryMeetingDetail', result.code,
              msg: result.msg, data: result.data?.toJson())
          .result;
    });
  }

  Future _getHistoryMeeting(arguments) {
    return meetingKitBridge.premeetingService
        .getHistoryMeeting(arguments as int? ?? 0)
        .then((NEResult<NERemoteHistoryMeeting> result) {
      return Callback.wrap('getHistoryMeeting', result.code,
              msg: result.msg, data: result.data?.toJson())
          .result;
    });
  }

  Future _getMeetingItemByInviteCode(arguments) {
    return meetingKitBridge.premeetingService
        .getMeetingItemByInviteCode(arguments as String? ?? '')
        .then((NEResult<NEMeetingItem> result) {
      return Callback.wrap('getMeetingItemByInviteCode', result.code,
              msg: result.msg, data: result.data?.toJson())
          .result;
    });
  }

  Future _getInviteInfo(arguments) {
    assert(arguments is Map);
    return meetingKitBridge.premeetingService
        .getInviteInfo(NEMeetingItem.fromNativeJson(arguments))
        .then((result) {
      return Callback.wrap('getInviteInfo', 0, msg: null, data: result).result;
    });
  }

  Future _handleGetLocalHistoryMeetingList() async {
    final list =
        meetingKitBridge.premeetingService.getLocalHistoryMeetingList();
    return Callback.wrap(
            'getLocalHistoryMeetingList', NEMeetingErrorCode.success,
            msg: 'getLocalHistoryMeetingList',
            data: list.map((e) => e.toJson()).toList())
        .result;
  }

  Future _handleClearLocalHistoryMeetingList() async {
    meetingKitBridge.premeetingService.clearLocalHistoryMeetingList();
    return Callback.wrap(
      'clearLocalHistoryMeetingList',
      NEMeetingErrorCode.success,
      msg: 'clearLocalHistoryMeetingList',
    ).result;
  }

  Future _handleGetMeetingCloudRecordList(arguments) {
    assert(arguments is Map);
    assert(arguments['meetingId'] is int);
    return meetingKitBridge.premeetingService
        .getMeetingCloudRecordList(arguments['meetingId'])
        .then((value) {
      return Callback.wrap('getMeetingCloudRecordList', value.code,
              msg: value.msg, data: value.data?.map((e) => e.toJson()).toList())
          .result;
    });
  }

  Future _handleLoadWebAppView(arguments) async {
    assert(arguments is Map);

    /// 当前已经在会议中，不允许打开webView
    if (NEMeetingKit.instance.getMeetingService().getCurrentMeetingInfo() !=
        null) {
      return Callback.wrap(
              'loadWebAppView', NEMeetingErrorCode.alreadyInMeeting)
          .result;
    }

    /// 不允许多个Flutter界面同时打开
    if (meetingKitBridge.inFlutterView) {
      return Callback.wrap('loadWebAppView', NEMeetingErrorCode.failed).result;
    }
    final page = meetingKitBridge.premeetingService.loadWebAppView(
      arguments['meetingId'] as int,
      NEMeetingWebAppItem.fromNativeMap(arguments['item'] as Map),
    );
    Navigator.push(meetingKitBridge.buildContext,
        MaterialPageRoute(builder: (context) => page)).then((value) {
      meetingKitBridge.inFlutterView = false;
      SystemNavigator.pop();
    });
    meetingKitBridge.inFlutterView = true;
    return Callback.wrap('loadWebAppView', NEMeetingErrorCode.success).result;
  }

  Future _handleFetchChatroomHistoryMessageList(arguments) {
    assert(arguments is Map);
    return meetingKitBridge.premeetingService
        .fetchChatroomHistoryMessageList(arguments['meetingId'],
            NEChatroomHistoryMessageSearchOption.fromJson(arguments['option']))
        .then((value) {
      return Callback.wrap('fetchChatroomHistoryMessageList', value.code,
              msg: value.msg, data: value.data?.map((e) => e.toJson()).toList())
          .result;
    });
  }

  Future _handleGetHistoryMeetingTranscriptionInfo(arguments) {
    assert(arguments is int);
    return meetingKitBridge.premeetingService
        .getHistoryMeetingTranscriptionInfo(arguments as int)
        .then((value) {
      return Callback.wrap('getHistoryMeetingTranscriptionInfo', value.code,
              msg: value.msg, data: value.data)
          .result;
    });
  }

  Future _handleGetHistoryMeetingTranscriptionFileUrl(arguments) {
    assert(arguments is Map);
    return meetingKitBridge.premeetingService
        .getHistoryMeetingTranscriptionFileUrl(
      arguments['meetingId'] as int,
      arguments['fileKey'] as String? ?? '',
    )
        .then((value) {
      return Callback.wrap('getHistoryMeetingTranscriptionFileUrl', value.code,
              msg: value.msg, data: value.data)
          .result;
    });
  }

  Future _handleGetHistoryMeetingTranscriptionMessageList(arguments) {
    assert(arguments is Map);
    return meetingKitBridge.premeetingService
        .getHistoryMeetingTranscriptionMessageList(
      arguments['meetingId'] as int,
      arguments['fileKey'] as String? ?? '',
    )
        .then((value) {
      return Callback.wrap(
              'getHistoryMeetingTranscriptionMessageList', value.code,
              msg: value.msg, data: value.data)
          .result;
    });
  }
}
