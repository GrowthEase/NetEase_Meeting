// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/base/util/text_util.dart';
import 'package:nemeeting/base/util/timeutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import 'package:nemeeting/pre_meeting/schedule_meeting_edit.dart';
import 'package:nemeeting/utils/const_config.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/utils/nav_utils.dart';
import '../uikit/utils/router_name.dart';
import '../uikit/values/borders.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/dimem.dart';
import '../uikit/values/strings.dart';

class ScheduleMeetingDetailRoute extends StatefulWidget {
  final NEMeetingItem item;

  ScheduleMeetingDetailRoute(this.item);

  @override
  State<StatefulWidget> createState() {
    return _ScheduleMeetingDetailRouteState(item);
  }
}

class _ScheduleMeetingDetailRouteState
    extends MeetingBaseState<ScheduleMeetingDetailRoute> {
  NEMeetingItem item;

  _ScheduleMeetingDetailRouteState(this.item);

  late ScheduleCallback<List<NEMeetingItem>> scheduleCallback;

  @override
  void initState() {
    super.initState();
    scheduleCallback = (List<NEMeetingItem> data, bool incremental) {
      data.forEach((element) {
        if (element.meetingId == item.meetingId) {
          setState(() {
            item = element;
          });
        }
      });
    };
    NEMeetingKit.instance
        .getPreMeetingService()
        .registerScheduleMeetingStatusChange(scheduleCallback);
  }

  @override
  String getTitle() {
    return Strings.meetingDetail;
  }

  @override
  List<Widget> buildActions() {
    return <Widget>[
      if (item.state == NEMeetingState.init)
        TextButton(
          child: Text(
            Strings.edit,
            style: TextStyle(
              color: AppColors.color_337eff,
              fontSize: 16.0,
            ),
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return ScheduleMeetingEditRoute(item);
            }));
          },
        )
    ];
  }

  @override
  Widget buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          buildSpace(),
          buildSubject(),
          buildSpace(),
          buildMeetingId(),
          buildSpace(),
          buildStartTime(),
          _buildSplit(),
          buildEndTime(),
          if (!TextUtil.isEmpty(item.password)) buildSpace(),
          if (!TextUtil.isEmpty(item.password)) buildPwd(),
          buildSpace(),
          if (item.live?.liveUrl != null && item.live?.enable == true)
            buildLiveUrl(),
          if (item.live?.liveWebAccessControlLevel ==
                  NELiveAuthLevel.appToken.index &&
              item.live?.enable == true) ...[
            _buildSplit(),
            buildLiveAuthLevel()
          ],
          buildBtn(),
        ],
      ),
    );
  }

  Widget buildSubject() {
    return Container(
      height: Dimen.primaryItemHeight,
      color: Colors.white,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
      child: Text(
        item.subject ?? '',
        style: TextStyle(fontSize: 16, color: AppColors.black_222222),
      ),
    );
  }

  Widget buildMeetingId() {
    return buildCopyItem(MeetingValueKey.scheduleCopyPwd, Strings.meetingId,
        TextUtil.applyMask(item.meetingNum!, '000-000-0000'));
  }

  Widget buildLiveUrl() {
    return buildCopyItem(MeetingValueKey.scheduleCopyLiveUrl, Strings.liveUrl,
        item.live?.liveUrl ?? '');
  }

  Widget buildLiveAuthLevel() {
    return _buildLiveAuthLevel(Strings.liveLevel, Strings.liveLevelTip);
  }

  Widget _buildLiveAuthLevel(String itemTitle, String des) {
    return Container(
      height: Dimen.primaryItemHeight,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
      child: Row(
        children: <Widget>[
          Text(itemTitle,
              style: TextStyle(fontSize: 16, color: AppColors.black_222222)),
          Spacer(),
          Text(des,
              style: TextStyle(fontSize: 14, color: AppColors.black_333333)),
        ],
      ),
    );
  }

  Widget buildCopyItem(Key key, String? itemTitle, String? itemDetail) {
    return Container(
      height: Dimen.primaryItemHeight,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
              child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                        text: itemTitle ?? '',
                        style: TextStyle(
                            fontSize: 16, color: AppColors.black_222222)),
                    TextSpan(
                        text: '   ${itemDetail ?? ''}',
                        style: TextStyle(
                            fontSize: 16, color: AppColors.color_999999))
                  ]),
                  softWrap: false,
                  overflow: TextOverflow.fade)),
          GestureDetector(
            key: key,
            child: Text(' ${Strings.copy}',
                style: TextStyle(fontSize: 14, color: AppColors.blue_337eff)),
            onTap: () {
              if (itemDetail == null) return;
              var value = TextUtil.replace(itemDetail, RegExp(r'-'), '');
              Clipboard.setData(ClipboardData(text: value));
              ToastUtils.showToast(context, Strings.copySuccess);
            },
          ),
        ],
      ),
    );
  }

  Widget buildStartTime() {
    return buildTime(Strings.meetingStartTime,
        DateTime.fromMillisecondsSinceEpoch(item.startTime));
  }

  Widget buildEndTime() {
    return buildTime(Strings.meetingEndTime,
        DateTime.fromMillisecondsSinceEpoch(item.endTime));
  }

  Widget buildTime(String itemTitle, DateTime showTime) {
    return Container(
      height: Dimen.primaryItemHeight,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
      child: Row(
        children: <Widget>[
          Text(itemTitle,
              style: TextStyle(fontSize: 16, color: AppColors.black_222222)),
          Spacer(),
          Text(TimeUtil.timeFormatWithMinute(showTime),
              style: TextStyle(fontSize: 14, color: AppColors.black_333333)),
        ],
      ),
    );
  }

  Widget buildPwd() {
    return buildCopyItem(
        MeetingValueKey.scheduleCopyID, Strings.meetingPassword, item.password);
  }

  Widget buildBtn() {
    if (item.state == NEMeetingState.invalid ||
        item.state == NEMeetingState.cancel ||
        item.state == NEMeetingState.recycled) {
      return Container();
    } else if (item.state == NEMeetingState.init) {
      return Row(
        children: [
          Expanded(child: buildCancel(right: 5)),
          Expanded(child: buildJoin(left: 5))
        ],
      );
    } else {
      return buildJoin();
    }
  }

  Widget buildJoin(
      {double left = 20,
      double right = 20,
      double top = 20,
      double bottom = 20}) {
    return GestureDetector(
      key: MeetingValueKey.scheduleJoin,
      child: Container(
        height: 50,
        margin:
            EdgeInsets.only(left: left, right: right, top: top, bottom: bottom),
        decoration: BoxDecoration(
          color: AppColors.accentElement,
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
        alignment: Alignment.center,
        child: Text(Strings.joinMeeting,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w400,
                fontSize: 16,
                decoration: TextDecoration.none)),
      ),
      onTap: joinMeeting,
    );
  }

  Widget buildCancel(
      {double left = 20,
      double right = 20,
      double top = 20,
      double bottom = 20}) {
    return GestureDetector(
      key: MeetingValueKey.scheduleCancel,
      child: Container(
        height: 50,
        margin:
            EdgeInsets.only(left: left, right: right, top: top, bottom: bottom),
        decoration: BoxDecoration(
          border: Border.fromBorderSide(Borders.secondaryBorder),
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
        alignment: Alignment.center,
        child: Text(
          Strings.cancelMeeting,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.blue_337eff,
              fontWeight: FontWeight.w400,
              fontSize: 16,
              decoration: TextDecoration.none),
        ),
      ),
      onTap: _cancelMeeting,
    );
  }

  Future<void> joinMeeting() async {
    var historyItem = await NEMeetingKit.instance
        .getSettingsService()
        .getHistoryMeetingItem();
    String? lastUsedNickname;
    if (historyItem != null &&
        historyItem.isNotEmpty &&
        (historyItem.first.meetingId == item.meetingNum ||
            historyItem.first.shortMeetingId == item.meetingNum)) {
      lastUsedNickname = historyItem.first.nickname;
    }
    _onJoinMeeting(nickname: lastUsedNickname);
  }

  /// 加入会议
  void _onJoinMeeting({String? nickname}) async {
    LoadingUtil.showLoading();
    final settingsService = NEMeetingKit.instance.getSettingsService();
    final openVideo =
        await settingsService.isTurnOnMyVideoWhenJoinMeetingEnabled();
    final openAudio =
        await settingsService.isTurnOnMyAudioWhenJoinMeetingEnabled();
    final showMeetingTime =
        await settingsService.isShowMyMeetingElapseTimeEnabled();
    final result = await NEMeetingUIKit().joinMeetingUI(
      context,
      NEJoinMeetingUIParams(
          meetingId: item.meetingNum!,
          displayName: nickname ?? MeetingUtil.getNickName()),
      NEMeetingUIOptions(
        noVideo: !openVideo,
        noAudio: !openAudio,
        noWhiteBoard: !openWhiteBoard,
        noMuteAllVideo: noMuteAllVideo,
        showMeetingTime: showMeetingTime,
        audioAINSEnabled: await settingsService.isAudioAINSEnabled(),
        restorePreferredOrientations: [DeviceOrientation.portraitUp],
        extras: {'shareScreenTips': Strings.shareScreenTips},
        noSip: kNoSip,
        showMeetingRemainingTip: kShowMeetingRemainingTip,
      ),
      onMeetingPageRouteWillPush: () async {
        LoadingUtil.cancelLoading();
        NavUtils.pop(context);
      },
    );
    final errorCode = result.code;
    final errorMessage = result.msg;
    LoadingUtil.cancelLoading();
    if (errorCode == NEMeetingErrorCode.success) {
      // do nothing
    } else if (errorCode == NEMeetingErrorCode.noNetwork) {
      ToastUtils.showToast(context, Strings.networkUnavailableCheck);
    } else if (errorCode == NEMeetingErrorCode.noAuth) {
      ToastUtils.showToast(context, Strings.loginOnOtherDevice);
      AuthManager().logout();
      NavUtils.pushNamedAndRemoveUntil(context, RouterName.entrance);
    } else if (errorCode == NEMeetingErrorCode.alreadyInMeeting) {
      //不作处理
    } else {
      var errorTips = HttpCode.getMsg(errorMessage, Strings.joinMeetingFail);
      ToastUtils.showToast(context, errorTips);
    }
  }

  void _cancelMeeting() {
    showCupertinoModalPopup<String>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              title: Text(
                Strings.confirmCancelMeeting,
                style: TextStyle(color: AppColors.grey_8F8F8F, fontSize: 13),
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                    child: Text(Strings.cancelMeeting,
                        style: TextStyle(color: AppColors.colorFE3B30)),
                    onPressed: () {
                      Navigator.pop(context);
                      _onCancel();
                    }),
              ],
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text(Strings.notCancel,
                    style: TextStyle(color: AppColors.color_007AFF)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ));
  }

  void _onCancel() {
    LoadingUtil.showLoading();
    NEMeetingKit.instance
        .getPreMeetingService()
        .cancelMeeting(item.meetingId!)
        .then(((result) {
      LoadingUtil.cancelLoading();
      if (result.code == HttpCode.success) {
        Navigator.pop(context);
      } else {
        var errorMsg = result.msg;
        errorMsg = HttpCode.getMsg(errorMsg);
        ToastUtils.showToast(context, errorMsg);
      }
    }));
  }

  Widget buildSpace() {
    return Container(
      color: AppColors.globalBg,
      height: Dimen.globalPadding,
    );
  }

  Widget _buildSplit() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(left: 20),
      height: 1,
      child: Divider(height: 1),
    );
  }

  @override
  void dispose() {
    NEMeetingKit.instance
        .getPreMeetingService()
        .unRegisterScheduleMeetingStatusChange(scheduleCallback);
    super.dispose();
  }
}
