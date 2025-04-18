// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

/// JS可调用的接口
enum JSAPIType {
  /// 获取 App 信息
  getAppInfo,

  /// 判断是否在客户端环境
  neteaseMeeting,

  /// 获取用户基础信息
  getUserInfo,

  /// 获取当前会议信息
  getCurrentMeetingInfo,

  /// 获取免登授权码
  requestAuthCode,

  /// 企业自建应用 JSAPI 鉴权
  config,

  /// 检查当前应用的 JSAPI 鉴权状态
  checkJsApiConfig,

  /// 关闭当前 webview
  closeWebView,

  /// 添加监听事件
  addEventListener,

  /// 取消监听事件
  removeEventListener,
}

/// JSAPI可监听的事件
enum JSAPIEventType {
  /// 侧边栏应用位置发生变化
  webAppPosition,

  /// 会中自身信息发生变化
  inmeetingUserInfo,

  /// 小应用自定义事件
  customEvent,
}

/// JSAPI参数对象
class JSAPIParams {
  JSAPIParams({
    required this.method,
    this.params,
    required this.methodId,
  });

  final String method;
  final Map<String, dynamic>? params;
  final String methodId;

  static fromMap(Map<String, dynamic> map) {
    return JSAPIParams(
      method: map['method'] as String? ?? 'NoMethod',
      params: map['params'] as Map<String, dynamic>?,
      methodId: map['methodId'] as String? ?? 'NoMethodId',
    );
  }

  static fromJSONString(String jsonString) {
    return fromMap(json.decode(jsonString) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'JSAPIParams{method: $method, params: $params, methodId: $methodId}';
  }
}

/// JSAPI返回结果对象
class JSAPIResult {
  JSAPIResult({
    required this.method,
    required this.code,
    this.message,
    this.data,
    required this.methodId,
  });

  final String method;
  final Map<String, dynamic>? data;
  final String methodId;
  final String? message;
  final int code;

  @override
  String toString() {
    return json.encode({
      'method': method,
      'data': data,
      'methodId': methodId,
      'message': message,
      'code': code,
    });
  }
}

/// JSAPI事件对象
class JSAPIEvent {
  JSAPIEvent({
    required this.data,
    required this.eventType,
  });

  final Map<String, dynamic> data;
  final JSAPIEventType eventType;

  @override
  String toString() {
    return json.encode({
      'eventType': eventType.name,
      'data': data,
    });
  }
}

class NEMeetingJSBridge {
  final _tag = 'NEMeetingJSBridge';
  final _spaceName = "meeting";
  final InAppWebViewController controller;
  final String roomArchiveId;
  final String homeUrl;
  final NERoomContext? roomContext;
  late NERoomEventCallback _eventCallback;
  late NEMessageChannelCallback _messageCallback;
  String? _currentPluginId = null;
  final BuildContext buildContext;

  /// 是否已经通过鉴权
  bool _hasPermitted = false;

  NEMeetingJSBridge(this.buildContext, this.roomArchiveId, this.homeUrl,
      this.roomContext, this.controller) {
    controller.addWebMessageListener(WebMessageListener(
        jsObjectName: _spaceName,
        onPostMessage: (WebMessage? message, WebUri? sourceOrigin,
            bool isMainFrame, PlatformJavaScriptReplyProxy replyProxy) {
          if (message?.data != null) onMessageReceived(message?.data);
        }));
    controller.loadUrl(
        urlRequest: URLRequest(url: WebUri(homeUrl), headers: getHeaders()));

    _eventCallback = NERoomEventCallback(
      memberNameChanged: ((member, name, operateBy) {
        if (member.uuid == roomContext?.localMember.uuid) {
          _postUserInfoEvent();
        }
      }),
      memberRoleChanged: ((member, oldRole, newRole) {
        if (member.uuid == roomContext?.localMember.uuid) {
          _postUserInfoEvent();
        }
      }),
      chatroomMessagesReceived: ((messages) {
        messages.forEach((element) {
          Alog.i(
              tag: _tag,
              content: 'chatroomMessagesReceived: ${element.messageType}');
          if (element is NERoomChatCustomMessage) {
            Alog.i(
                tag: _tag, content: 'custom message: ${(element).attachStr}');
          }
        });
      }),
    );

    /// 监听NERoom事件
    roomContext?.addEventCallback(_eventCallback);

    _messageCallback = NEMessageChannelCallback(
      onCustomMessageReceiveCallback: handlePassThroughMessage,
    );

    NERoomKit.instance.messageChannelService
        .addMessageChannelCallback(_messageCallback);
  }

  Map<String, String> getHeaders() {
    if (DebugOptions().isDebugMode) {
      return {
        'Pragma': 'no-cache',
        'Cache-Control': 'no-cache',
      };
    }
    return {};
  }

  void onMessageReceived(String message) {
    Alog.i(
        tag: _tag,
        content:
            '----------- Meeting onMessageReceived: ${message} -----------');
    JSAPIParams params = JSAPIParams.fromJSONString(message);

    /// 不需要授权的接口
    if (params.method == JSAPIType.config.name) {
      _config(params);
    } else if (params.method == JSAPIType.checkJsApiConfig.name) {
      _checkJsApiConfig(params);
    } else if (params.method == JSAPIType.requestAuthCode.name) {
      _requestAuthCode(params);
    } else if (params.method == JSAPIType.closeWebView.name) {
      _closeWebView(params);
    } else if (params.method == JSAPIType.addEventListener.name) {
      _addEventListener(params);
    } else if (params.method == JSAPIType.removeEventListener.name) {
      _removeEventListener(params);
    } else {
      if (!_hasPermitted) {
        /// 没有授权，直接失败
        final result = JSAPIResult(
          method: params.method,
          code: -1,
          message: 'No Permission',
          methodId: params.methodId,
        ).toString();
        _onResult(result);
        return;
      }

      /// 需要授权的接口
      if (params.method == JSAPIType.getAppInfo.name) {
        _getAppInfo(params);
      } else if (params.method == JSAPIType.neteaseMeeting.name) {
        _neteaseMeeting(params);
      } else if (params.method == JSAPIType.getUserInfo.name) {
        _getUserInfo(params);
      } else if (params.method == JSAPIType.getCurrentMeetingInfo.name) {
        _getCurrentMeetingInfo(params);
      } else {
        /// 没有找到对应方法
        final result = JSAPIResult(
          method: params.method,
          code: -1,
          message: 'No Such Method',
          methodId: params.methodId,
        ).toString();
        _onResult(result);
      }
    }
  }

  void handlePassThroughMessage(NECustomMessage message) {
    if (roomContext == null || message.roomUuid != roomContext?.roomUuid) {
      return;
    }
    Alog.i(tag: _tag, content: 'handlePassThroughMessage: ${message.data}');

    final pluginMessage = json.decode(message.data);
    if (pluginMessage is! Map) return;
    var pluginId = pluginMessage['pluginId'];

    if (_currentPluginId == pluginId) {
      Map<String, dynamic> data = {
        'content': pluginMessage['message'],
      };
      postEvent(JSAPIEvent(data: data, eventType: JSAPIEventType.customEvent));
    }
  }

  dispose() {
    _currentPluginId = null;
    roomContext?.removeEventCallback(_eventCallback);
    NERoomKit.instance.messageChannelService
        .removeMessageChannelCallback(_messageCallback);
  }

  /// 个人信息变更通知
  _postUserInfoEvent() {
    final info = {
      'uuid': roomContext?.localMember.uuid,
      'nickname': roomContext?.localMember.name,
      'avatarUrl': roomContext?.localMember.avatar,
      'roleType': roomContext?.localMember.role.name,
    };
    postEvent(
        JSAPIEvent(data: info, eventType: JSAPIEventType.inmeetingUserInfo));
  }

  /// 通知事件
  postEvent(JSAPIEvent event) {
    if (_isListeningEvent && _hasPermitted) {
      Alog.i(tag: _tag, content: 'postEvent: ${event.toString()}');
      controller.evaluateJavascript(
          source: '$_spaceName.onEvent(${event.toString()})');
    }
  }

  _getAppInfo(JSAPIParams params) {
    final info = {
      'appVersion': SDKConfig.sdkVersionCode,
      'clientLanguage': CoreRepository().currentLanguage.roomLang.languageCode,
    };
    final result = JSAPIResult(
      method: params.method,
      data: info,
      methodId: params.methodId,
      code: 0,
    ).toString();
    _onResult(result);
  }

  _neteaseMeeting(JSAPIParams params) {
    final result = JSAPIResult(
      method: params.method,
      code: 0,
      methodId: params.methodId,
    ).toString();
    _onResult(result);
  }

  _getUserInfo(JSAPIParams params) {
    final info = {
      'uuid': roomContext?.localMember.uuid,
      'nickname': roomContext?.localMember.name,
      'avatarUrl': roomContext?.localMember.avatar,
      'roleType': roomContext?.localMember.role.name,
    };

    final result = JSAPIResult(
      method: params.method,
      data: info,
      code: 0,
      methodId: params.methodId,
    ).toString();
    _onResult(result);
  }

  _requestAuthCode(JSAPIParams params) {
    final param = params.params;
    final pluginId = param?['pluginId']?.toString();
    if (pluginId != null) {
      WebAppRepository.getAuthCode(roomContext?.crossAppAuthorization, pluginId)
          .then((value) {
        final result = JSAPIResult(
          method: params.method,
          code: value.code,
          message: value.msg,
          data: {
            'authCode': value.data?.authCode ?? '',
            'roomArchiveId': roomArchiveId,
          },
          methodId: params.methodId,
        ).toString();
        _onResult(result);
      });
    } else {
      final result = JSAPIResult(
        method: params.method,
        code: -1,
        message: 'Params Error',
        methodId: params.methodId,
      ).toString();
      _onResult(result);
    }
  }

  _config(JSAPIParams params) {
    final param = params.params;
    final openId = param?['openId'] as String?;
    final nonce = param?['nonce'] as String?;
    final curTime = param?['curTime'] as String?;
    final checkSum = param?['checkSum'] as String?;
    final pluginId = param?['pluginId'] as String?;
    _currentPluginId = pluginId;
    if (nonce != null &&
        curTime != null &&
        checkSum != null &&
        pluginId != null) {
      JSApiPermissionRequest request = JSApiPermissionRequest(
          authorization: roomContext?.crossAppAuthorization,
          pluginId: pluginId,
          openId: openId,
          nonce: nonce,
          curTime: int.parse(curTime),
          checksum: checkSum,
          url: homeUrl);
      WebAppRepository.jsAPIPermission(request).then((value) {
        _hasPermitted = value.isSuccess();
        final result = JSAPIResult(
          method: params.method,
          code: value.code,
          message: value.msg,
          methodId: params.methodId,
        ).toString();
        _onResult(result);
      });
    } else {
      final result = JSAPIResult(
        method: params.method,
        code: -1,
        message: 'Params Error',
        methodId: params.methodId,
      ).toString();
      _onResult(result);
    }
  }

  _checkJsApiConfig(JSAPIParams params) {
    final result = JSAPIResult(
      method: params.method,
      code: -1,
      message: 'Not Supported',
      methodId: params.methodId,
    ).toString();
    _onResult(result);
  }

  _closeWebView(JSAPIParams params) {
    final result = JSAPIResult(
      method: params.method,
      code: -1,
      message: 'No BuildContext',
      methodId: params.methodId,
    ).toString();
    _onResult(result);
    Navigator.pop(buildContext);
  }

  _getCurrentMeetingInfo(JSAPIParams params) {
    _onResult(JSAPIResult(
      method: params.method,
      code: 0,
      data: {
        'isInMeeting': roomContext?.localMember.isInRtcChannel ?? false,
        'meetingNum': roomContext?.meetingInfo.meetingNum,
        'meetingId': roomContext?.meetingInfo.meetingId,
        'roomArchiveId': roomArchiveId,
        'meetingSubject': roomContext?.meetingInfo.subject,
        'role': roomContext?.localMember.role.name,
      },
      methodId: params.methodId,
    ));
  }

  /// 是否要将事件上报，详见[JSAPIEventType]
  var _isListeningEvent = false;

  _addEventListener(JSAPIParams params) {
    _isListeningEvent = true;
    final result = JSAPIResult(
      method: params.method,
      code: 0,
      methodId: params.methodId,
    ).toString();
    _onResult(result);
  }

  _removeEventListener(JSAPIParams params) {
    _isListeningEvent = false;
    final result = JSAPIResult(
      method: params.method,
      code: 0,
      methodId: params.methodId,
    ).toString();
    _onResult(result);
  }

  _onResult(dynamic result) {
    Alog.i(tag: _tag, content: "api result = $result");
    controller.evaluateJavascript(source: '$_spaceName.onResult($result)');
  }
}
