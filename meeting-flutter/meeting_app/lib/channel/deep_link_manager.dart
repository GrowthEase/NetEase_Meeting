// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:nemeeting/channel/ne_platform_channel.dart';
import 'package:nemeeting/language/localizations.dart';
import 'package:nemeeting/routes/home_page.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/profile/app_profile.dart';
import 'package:nemeeting/uikit/utils/nav_utils.dart';
import 'package:nemeeting/uikit/utils/router_name.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/utils/const_config.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import 'package:netease_meeting_core/meeting_service.dart';
import 'package:intl/intl.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import 'package:netease_meeting_assets/netease_meeting_assets.dart';

import '../language/meeting_localization/meeting_app_localizations.dart';

class DeepLinkManager {
  static final _instance = DeepLinkManager._internal();
  String _deepLinkUri = '';
  bool paused = true;

  factory DeepLinkManager() => _instance;

  DeepLinkManager._internal() {
    NEPlatformChannel().listen(_handleDeepLinkUri);
    GlobalPreferences().ensurePrivacyAgree().then((value) {
      privacyAgreed = true;
    });
    AppLifecycleListener(
      onResume: () {
        if (paused) {
          paused = false;
          onAppRestart();
        }
      },
      onPause: () => paused = true,
    );
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

  bool _isEnabled = false;
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
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed ||
        NEMeetingUIKit().getMeetingStatus().event != NEMeetingEvent.idle) {
      return;
    }

    final pending = _pendingCheckRequest;
    if (pending != null) {
      _checkMeeting(pending.meetingKey,
          needConfirm: pending.needConfirm, type: pending.type);
      _deepLinkUri = '';
    } else {
      Future.delayed(Duration(seconds: 2), () {
        Alog.i(
            tag: _TAG,
            content:
                '_handlePendingRequest _deepLinkUri = $_deepLinkUri, _pendingCheckRequest = $_pendingCheckRequest');
        if (_deepLinkUri.isEmpty) {
          tryParseDeepLinkFromClipBoard();
        }
        _deepLinkUri = '';
      });
    }
  }

  BuildContext? _context;
  String? _lastCheckedMeetingKey;
  _CheckRequest? _checkingMeetingKey;

  void onAppRestart() async {
    assert(() {
      debugPrintSynchronously('$_TAG: onAppRestart $_pendingCheckRequest');
      return true;
    }());
    if (_pendingCheckRequest == null) {
      _handlePendingRequest();
    }
  }

  void tryParseDeepLinkFromClipBoard() async {
    debugPrint('tryParseDeepLinkFromClipBoard');
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
    Alog.i(
        tag: _TAG,
        content: 'handleDeepLinkUri: uri=$uri, checking=$_checkingMeetingKey');
    _deepLinkUri = uri;
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
    final meetingAppLocalizations = MeetingAppLocalizations.of(_context!)!;
    if (!_isMeetingIdle) {
      assert(() {
        print('$_TAG: in meeting');
        return true;
      }());
      if (!needConfirm) {
        final currentMeeting = NEMeetingUIKit().getCurrentMeetingInfo();
        if (currentMeeting?.meetingNum == meetingKey ||
            currentMeeting?.inviteCode == meetingKey) {
          ToastUtils.showToast(_context!,
              meetingAppLocalizations.meetingDeepLinkTipAlreadyInMeeting);
        } else {
          ToastUtils.showToast(
              _context!,
              meetingAppLocalizations
                  .meetingDeepLinkTipAlreadyInDifferentMeeting);
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
        ToastUtils.showToast(
            _context!, meetingAppLocalizations.authPleaseLoginFirst);
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

    if (_isMeetingIdle && _context != null) {
      // needConfirm：如果为true就是剪切板入会，如果为false就是链接入会
      if (!needConfirm) {
        // 新需求：如果是链接入会，需要跳到加入会议页面，手动加入会议
        AppProfile.deepLinkMeetingId = meetingInfo?.meetingNum ?? meetingKey;
        NavUtils.pushNamedAndRemoveUntil(_context!, RouterName.meetJoin,
            utilRouteName: RouterName.homePage);
        _checkingMeetingKey = null;
        return true;
      }
      bool isAudioOn = await NEMeetingKit.instance
          .getSettingsService()
          .isTurnOnMyAudioWhenJoinMeetingEnabled();
      bool isVideoOn = await NEMeetingKit.instance
          .getSettingsService()
          .isTurnOnMyVideoWhenJoinMeetingEnabled();
      MeetingSetting meetingSetting =
          MeetingSetting(isAudioOn: isAudioOn, isVideoOn: isVideoOn);
      DialogResult? dialogResult = await _showJoinMeetingConfirmDialog(
          _context!, meetingSetting, meetingInfo!);
      if (dialogResult?.isJoinMeeting == true) {
        await _joinMeetingWithDefaultSettings(
            _context!, meetingInfo.meetingNum, dialogResult);
      }
    }

    _checkingMeetingKey = null;
    return true;
  }

  bool get _isMeetingIdle =>
      NEMeetingUIKit().getMeetingStatus().event == NEMeetingEvent.idle;

  Future<DialogResult?> _showJoinMeetingConfirmDialog(BuildContext context,
      MeetingSetting meetingSetting, MeetingInfo meetingInfo) async {
    return showDialog<DialogResult>(
        context: context,
        builder: (ctx) {
          return MeetingAppLocalizationsScope(
            builder: (context) {
              return _MeetingInfoDialog(
                meetingSetting: meetingSetting,
                meetingInfo: meetingInfo,
              );
            },
          );
        });
  }

  Future _joinMeetingWithDefaultSettings(BuildContext context,
      String meetingNum, DialogResult? dialogResult) async {
    LoadingUtil.showLoading();
    final result = await NEMeetingUIKit().joinMeetingUI(
      context,
      NEJoinMeetingUIParams(
        meetingNum: meetingNum,
        displayName: MeetingUtil.getNickName(),
        watermarkConfig: NEWatermarkConfig(
          name: MeetingUtil.getNickName(),
        ),
      ),
      await buildMeetingUIOptions(
        noVideo: dialogResult?.noVideo ?? true,
        noAudio: dialogResult?.noAudio ?? true,
        context: context,
      ),
      onPasswordPageRouteWillPush: () async {
        LoadingUtil.cancelLoading();
      },
      onMeetingPageRouteWillPush: () async {
        LoadingUtil.cancelLoading();
      },
      backgroundWidget: MeetingAppLocalizationsScope(child: HomePageRoute()),
    );
    final errorCode = result.code;
    final errorMessage = result.msg;
    LoadingUtil.cancelLoading();
    final meetingAppLocalizations = MeetingAppLocalizations.of(context)!;
    if (errorCode == NEMeetingErrorCode.success) {
    } else if (errorCode == NEMeetingErrorCode.noNetwork) {
      ToastUtils.showToast(
          context, meetingAppLocalizations.globalNetworkUnavailableCheck);
    } else if (errorCode == NEMeetingErrorCode.noAuth) {
      ToastUtils.showToast(
          context, meetingAppLocalizations.authLoginOnOtherDevice);
      AuthManager().logout();
      NavUtils.pushNamedAndRemoveUntil(context, RouterName.entrance);
    } else if (errorCode == NEMeetingErrorCode.alreadyInMeeting) {
      ToastUtils.showToast(context,
          meetingAppLocalizations.meetingOperationNotSupportedInMeeting);
    } else if (errorCode == NEMeetingErrorCode.cancelled) {
      /// 暂不处理
    } else {
      var errorTips = HttpCode.getMsg(
          errorMessage, meetingAppLocalizations.meetingJoinFail);
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

class _MeetingInfoDialog extends StatefulWidget {
  final MeetingSetting meetingSetting;
  final MeetingInfo meetingInfo;
  _MeetingInfoDialog(
      {Key? key, required this.meetingSetting, required this.meetingInfo})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MeetingInfoDialogState();
  }
}

class _MeetingInfoDialogState extends State<_MeetingInfoDialog>
    with MeetingAppLocalizationsMixin {
  bool isAudioOn = false;
  bool isVideoOn = false;

  @override
  void initState() {
    super.initState();
    isAudioOn = widget.meetingSetting.isAudioOn;
    isVideoOn = widget.meetingSetting.isVideoOn;
  }

  @override
  Widget build(BuildContext context) {
    final startTime =
        DateTime.fromMillisecondsSinceEpoch(widget.meetingInfo.startTime);
    final endTime = DateTime.fromMillisecondsSinceEpoch(
        widget.meetingInfo.type == NEMeetingType.kReservation
            ? widget.meetingInfo.endTime
            : widget.meetingInfo.startTime +
                const Duration(hours: 1).inMilliseconds);
    final meetingAppLocalizations = MeetingAppLocalizations.of(context)!;
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
                          '${meetingAppLocalizations.meetingInfoDialogMeetingTitle}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.color_333333,
                          ),
                        ),
                        Container(),
                        Text(
                          widget.meetingInfo.subject,
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
                          meetingAppLocalizations.meetingId,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.color_333333,
                          ),
                        ),
                        Container(),
                        Row(
                          children: [
                            Text(
                              widget.meetingInfo.meetingNum
                                  .toMeetingNumFormat(),
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.color_333333,
                              ),
                            ),
                            SizedBox(width: 6),
                            GestureDetector(
                              behavior: HitTestBehavior
                                  .translucent, // 点击区域设置到container大小
                              child: Container(
                                alignment: Alignment.center,
                                child: Icon(NEMeetingIconFont.icon_copy1x,
                                    color: AppColors.blue_337eff, size: 16),
                              ),
                              onTap: () {
                                Clipboard.setData(ClipboardData(
                                    text: widget.meetingInfo.meetingNum));
                                ToastUtils.showToast(context,
                                    meetingAppLocalizations.globalCopySuccess);
                              },
                            ),
                          ],
                        )
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
                            DateFormat(meetingAppLocalizations
                                    .meetingInfoDialogMeetingDateFormat)
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
                            DateFormat(meetingAppLocalizations
                                    .meetingInfoDialogMeetingDateFormat)
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
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      behavior:
                          HitTestBehavior.translucent, // 点击区域设置到container大小
                      onTap: () {
                        setState(() {
                          isAudioOn = !isAudioOn;
                        });
                        NEMeetingKit.instance
                            .getSettingsService()
                            .setTurnOnMyAudioWhenJoinMeeting(isAudioOn);
                      },
                      child: Column(
                        children: [
                          Icon(
                              !isAudioOn
                                  ? NEMeetingIconFont.icon_yx_tv_voice_offx
                                  : NEMeetingIconFont.icon_yx_tv_voice_onx,
                              color:
                                  !isAudioOn ? Colors.red : Color(0xFF49494d),
                              size: 20),
                          SizedBox(height: 8),
                          Text(
                            meetingAppLocalizations.meetingMicrophone,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.color_333333,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 80),
                    GestureDetector(
                      behavior:
                          HitTestBehavior.translucent, // 点击区域设置到container大小
                      onTap: () {
                        setState(() {
                          isVideoOn = !isVideoOn;
                        });
                        NEMeetingKit.instance
                            .getSettingsService()
                            .setTurnOnMyVideoWhenJoinMeeting(isVideoOn);
                      },
                      child: Column(children: [
                        Icon(
                            !isVideoOn
                                ? NEMeetingIconFont.icon_yx_tv_video_offx
                                : NEMeetingIconFont.icon_yx_tv_video_onx,
                            color: !isVideoOn ? Colors.red : Color(0xFF49494d),
                            size: 20),
                        SizedBox(height: 8),
                        Text(
                          meetingAppLocalizations.meetingCamera,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.color_333333,
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(DialogResult(
                        isJoinMeeting: true,
                        noAudio: !isAudioOn,
                        noVideo: !isVideoOn));
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(AppColors.color_337eff),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    )),
                  ),
                  child: Text(
                    meetingAppLocalizations.meetingJoin,
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
            Navigator.of(context).pop(DialogResult(isJoinMeeting: false));
          },
          child: Icon(Icons.cancel_outlined, color: Colors.white, size: 36),
        ),
      ],
    );
  }
}

class MeetingSetting {
  bool isAudioOn = false;
  bool isVideoOn = false;

  MeetingSetting({required this.isAudioOn, required this.isVideoOn});
}

class DialogResult {
  final bool isJoinMeeting;
  bool? noAudio;
  bool? noVideo;

  DialogResult({required this.isJoinMeeting, this.noAudio, this.noVideo});
}
