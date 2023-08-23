// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nemeeting/channel/ne_platform_channel.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/uikit/utils/nav_utils.dart';
import 'package:nemeeting/uikit/utils/router_name.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/uikit/values/strings.dart';
import 'package:nemeeting/utils/const_config.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import 'package:netease_meeting_core/meeting_service.dart';
import 'package:intl/intl.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

class DeepLinkManager with WidgetsBindingObserver {
  static final _instance = DeepLinkManager._internal();

  factory DeepLinkManager() => _instance;

  DeepLinkManager._internal() {
    NEPlatformChannel().listen(_handleDeepLinkUri);
    WidgetsBinding.instance.addObserver(this);
  }

  static const _TAG = "DeepLinkManager";
  // https://meeting.163.com/invite/#/?meeting=xekJAxcNYG39Dn4XIT6sAA==
  static final inviteUrlPattern = RegExp(r'https://meeting\.163\.com/invite.*');
  static final meetingIdPattern = RegExp(r'[0-9\-]+');
  static const meetingIdMinLen = 4;
  static const _kTypeMeetingId = 0;
  static const _kTypeMeetingCode = 1;
  static const _kKeyMeetingId = 'meetingId';
  static const _kKeyMeetingCode = 'meeting';

  _CheckRequest? _pendingCheckRequest;

  bool _privacyAgreed = false;
  set privacyAgreed(bool value) {
    if (_privacyAgreed == value) return;
    _privacyAgreed = value;
    _handlePendingRequest();
  }

  bool _isEnabled = true;
  set isEnabled(bool value) {
    if (_isEnabled == value) return;
    _isEnabled = value;
    _handlePendingRequest();
  }

  bool get isEnabled => _isEnabled && _privacyAgreed;

  void attach(BuildContext context) {
    if (_context == context) return;
    _context = context;
    _handlePendingRequest();
  }

  void detach(BuildContext context) {
    if (_context == context) {
      _context = null;
    }
  }

  void _handlePendingRequest() {
    if (!isEnabled ||
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    assert(() {
      debugPrintSynchronously(
          '$_TAG: _handlePendingRequest \n ${StackTrace.current}');
      return true;
    }());
    final pending = _pendingCheckRequest;
    if (pending != null) {
      _checkMeeting(pending.meetingKey,
          needConfirm: pending.needConfirm, type: pending.type);
    } else {
      tryParseDeepLinkFromClipBoard();
    }
  }

  BuildContext? _context;
  String? _lastCheckedMeetingKey;
  _CheckRequest? _checkingMeetingKey;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    assert(() {
      debugPrintSynchronously(
          '$_TAG: didChangeAppLifecycleState, $_pendingCheckRequest');
      return true;
    }());
    if (state == AppLifecycleState.resumed && _pendingCheckRequest == null) {
      _handlePendingRequest();
    }
  }

  void tryParseDeepLinkFromClipBoard() async {
    // get meeting id from clipboard
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData == null) return;
    final clipboardText = clipboardData.text;
    if (clipboardText == null) return;

    for (var uri
        in inviteUrlPattern.allMatches(clipboardText).map((e) => e.group(0))) {
      if (await _checkMeeting(tryParseMeetingKey(uri, _kKeyMeetingCode),
          needConfirm: true, type: _kTypeMeetingCode)) {
        return;
      }
    }

    for (var id in meetingIdPattern
        .allMatches(clipboardText)
        .map((e) => e.group(0)?.replaceAll(RegExp(r'-'), ''))
        .whereType<String>()
        .where((element) => element.length >= meetingIdMinLen)) {
      if (await _checkMeeting(id, needConfirm: true, type: _kTypeMeetingId)) {
        return;
      }
    }
  }

  static String? tryParseMeetingKey(String? uri, String queryKey) {
    if (uri == null || uri.isEmpty) return null;
    final deepLink = Uri.tryParse(uri);
    return deepLink != null ? deepLink.queryParameters[queryKey] : null;
  }

  void _handleDeepLinkUri(String uri) async {
    _checkMeeting(tryParseMeetingKey(uri, _kKeyMeetingId),
        needConfirm: false, type: _kTypeMeetingId);
  }

  Future<bool> _checkMeeting(String? meetingKey,
      {required bool needConfirm, required int type}) async {
    assert(() {
      debugPrintSynchronously('$_TAG: _checkMeeting \n ${StackTrace.current}');
      return true;
    }());
    Alog.i(
        tag: _TAG,
        content:
            'checkMeeting: meetingKey=$meetingKey, needConfirm=$needConfirm, type=$type, checking=$_checkingMeetingKey');
    if (meetingKey == null ||
        meetingKey.isEmpty ||
        (needConfirm && _checkingMeetingKey != null)) {
      return false;
    }
    final request = _CheckRequest(meetingKey, needConfirm, type);
    if (request == _checkingMeetingKey) {
      return false;
    }
    if (_pendingCheckRequest != request &&
        _pendingCheckRequest?.needConfirm == false) {
      return false;
    }

    if (needConfirm && meetingKey == _lastCheckedMeetingKey) {
      assert(() {
        print('$_TAG: $meetingKey has checked');
        return true;
      }());
      return false;
    }
    if (!isEnabled || _context == null) {
      assert(() {
        print('$_TAG: disabled or context is null');
        return true;
      }());
      _pendingCheckRequest = request;
      return true;
    }
    if (!_isMeetingIdle) {
      assert(() {
        print('$_TAG: in meeting');
        return true;
      }());
      if (!needConfirm) {
        final currentMeeting = NEMeetingUIKit().getCurrentMeetingInfo();
        if (currentMeeting?.meetingNum == meetingKey ||
            currentMeeting?.inviteCode == meetingKey) {
          ToastUtils.showToast(
              _context!, Strings.deepLinkTipAlreadyInRightMeeting);
        } else {
          ToastUtils.showToast(
              _context!, Strings.deepLinkTipAlreadyInDifferentMeeting);
        }
      }
      _lastCheckedMeetingKey = meetingKey;
      return true;
    }
    if (!NEMeetingKit.instance.getAccountService().isLoggedIn) {
      assert(() {
        print('$_TAG: not login');
        return true;
      }());
      if (!needConfirm) {
        ToastUtils.showToast(_context!, Strings.pleaseLoginFirst);
      }
      _pendingCheckRequest = request;
      return true;
    }

    _pendingCheckRequest = null;
    _checkingMeetingKey = request;

    MeetingInfo? meetingInfo;
    if (needConfirm) {
      meetingInfo = (await MeetingRepository.getMeetingInfoEx(
        meetingId: type == _kTypeMeetingId ? meetingKey : null,
        meetingCode: type == _kTypeMeetingCode ? meetingKey : null,
      ))
          .data;
      assert(() {
        print(
            '$_TAG: meeting info: ${meetingInfo?.meetingNum} ${meetingInfo?.type.name} ${meetingInfo?.state.name}');
        return true;
      }());
      if (meetingInfo == null ||
          meetingInfo.state == NEMeetingState.cancel ||
          meetingInfo.state == NEMeetingState.recycled) {
        _checkingMeetingKey = null;
        return true;
      }
    }
    if (_checkingMeetingKey != request) {
      return true;
    }

    _lastCheckedMeetingKey = meetingKey;

    if (_isMeetingIdle &&
        _context != null &&
        (!needConfirm ||
            await _showJoinMeetingConfirmDialog(_context!, meetingInfo!) ==
                true) &&
        _context != null) {
      await _joinMeetingWithDefaultSettings(
          _context!, meetingInfo?.meetingNum ?? meetingKey);
    }

    _checkingMeetingKey = null;
    return true;
  }

  bool get _isMeetingIdle =>
      NEMeetingUIKit().getMeetingStatus().event == NEMeetingEvent.idle;

  Future<bool?> _showJoinMeetingConfirmDialog(
      BuildContext context, MeetingInfo meetingInfo) async {
    return showDialog<bool>(
        context: context,
        builder: (ctx) {
          return _MeetingInfo(
            meetingInfo: meetingInfo,
          );
        });
  }

  Future _joinMeetingWithDefaultSettings(
      BuildContext context, String meetingNum) async {
    LoadingUtil.showLoading();
    final result = await NEMeetingUIKit().joinMeetingUI(
      context,
      NEJoinMeetingUIParams(
        meetingNum: meetingNum,
        displayName: MeetingUtil.getNickName(),
      ),
      await buildMeetingUIOptions(
        noVideo: true,
        noAudio: true,
      ),
      onPasswordPageRouteWillPush: () async {
        LoadingUtil.cancelLoading();
      },
      onMeetingPageRouteWillPush: () async {
        LoadingUtil.cancelLoading();
      },
    );
    final errorCode = result.code;
    final errorMessage = result.msg;
    LoadingUtil.cancelLoading();
    if (errorCode == NEMeetingErrorCode.success) {
    } else if (errorCode == NEMeetingErrorCode.noNetwork) {
      ToastUtils.showToast(context, Strings.networkUnavailableCheck);
    } else if (errorCode == NEMeetingErrorCode.noAuth) {
      ToastUtils.showToast(context, Strings.loginOnOtherDevice);
      AuthManager().logout();
      NavUtils.pushNamedAndRemoveUntil(context, RouterName.entrance);
    } else if (errorCode == NEMeetingErrorCode.alreadyInMeeting ||
        errorCode == NEMeetingErrorCode.cancelled) {
      //不作处理
    } else {
      var errorTips = HttpCode.getMsg(errorMessage, Strings.joinMeetingFail);
      ToastUtils.showToast(context, errorTips);
    }
  }
}

class _CheckRequest {
  final String meetingKey;
  final bool needConfirm;
  final int type;

  _CheckRequest(this.meetingKey, this.needConfirm, this.type);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CheckRequest &&
          runtimeType == other.runtimeType &&
          meetingKey == other.meetingKey &&
          needConfirm == other.needConfirm &&
          type == other.type;

  @override
  int get hashCode => Object.hash(meetingKey, needConfirm, type);
}

class _MeetingInfo extends StatelessWidget {
  final MeetingInfo meetingInfo;

  const _MeetingInfo({Key? key, required this.meetingInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startTime =
        DateTime.fromMillisecondsSinceEpoch(meetingInfo.startTime);
    final endTime = DateTime.fromMillisecondsSinceEpoch(
        meetingInfo.type == NEMeetingType.kReservation
            ? meetingInfo.endTime
            : meetingInfo.startTime + const Duration(hours: 1).inMilliseconds);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Table(
                  columnWidths: {
                    0: IntrinsicColumnWidth(),
                    1: FixedColumnWidth(8),
                    2: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(
                      children: [
                        Text(
                          '${Strings.meetingInfoDialogMeetingSubject}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.color_333333,
                          ),
                        ),
                        Container(),
                        Text(
                          meetingInfo.subject,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.color_333333,
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        SizedBox(
                          height: 16,
                        ),
                        Container(),
                        Container(),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text(
                          Strings.meetingInfoDialogMeetingId,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.color_333333,
                          ),
                        ),
                        Container(),
                        Text(
                          meetingInfo.meetingNum.toMeetingNumFormat(),
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.color_333333,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  height: 109,
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F9FB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('HH:mm').format(startTime),
                            style: TextStyle(
                              fontSize: 24,
                              color: AppColors.color_333333,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            DateFormat(
                                    Strings.meetingInfoDialogMeetingDateFormat)
                                .format(startTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.color_666666,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 17,
                        height: 1,
                        color: Color(0xFFCDD1D4),
                        padding: EdgeInsets.symmetric(horizontal: 9),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('HH:mm').format(endTime),
                            style: TextStyle(
                              fontSize: 24,
                              color: AppColors.color_333333,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            DateFormat(
                                    Strings.meetingInfoDialogMeetingDateFormat)
                                .format(endTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.color_666666,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(AppColors.color_337eff),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    )),
                  ),
                  child: Text(
                    Strings.joinMeeting,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop(false);
          },
          child: Icon(Icons.cancel_outlined, color: Colors.white, size: 36),
        ),
      ],
    );
  }
}
