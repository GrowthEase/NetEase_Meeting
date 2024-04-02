// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/base/util/text_util.dart';
import 'package:nemeeting/base/util/timeutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/routes/home_page.dart';
import 'package:nemeeting/widget/switch_item.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import 'package:nemeeting/pre_meeting/schedule_meeting_edit.dart';
import 'package:nemeeting/utils/const_config.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import '../language/localizations.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/utils/nav_utils.dart';
import '../uikit/utils/router_name.dart';
import '../uikit/values/borders.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/dimem.dart';

class ScheduleMeetingDetailRoute extends StatefulWidget {
  final NEMeetingItem item;

  ScheduleMeetingDetailRoute(this.item);

  @override
  State<StatefulWidget> createState() {
    return _ScheduleMeetingDetailRouteState(item);
  }
}

class _ScheduleMeetingDetailRouteState
    extends MeetingBaseState<ScheduleMeetingDetailRoute>
    with MeetingAppLocalizationsMixin {
  NEMeetingItem item;

  _ScheduleMeetingDetailRouteState(this.item);

  late ScheduleCallback<List<NEMeetingItem>> scheduleCallback;

  bool cancelByMySelf = false;

  @override
  void initState() {
    super.initState();
    scheduleCallback = (List<NEMeetingItem> data, bool incremental) {
      data.forEach((element) {
        if (element.meetingId == item.meetingId) {
          /// 会议被其他端销毁，会议取消，会议无效时，返回首页
          if (mounted &&
              !cancelByMySelf &&
              (element.state == NEMeetingState.invalid ||
                  element.state == NEMeetingState.cancel ||
                  element.state == NEMeetingState.recycled)) {
            ToastUtils.showToast(
                context, meetingAppLocalizations.meetingHasBeenCanceled);
            Navigator.maybePop(context);
          } else {
            setState(() {
              item = element;
            });
          }
        }
      });
    };
    NEMeetingKit.instance
        .getPreMeetingService()
        .registerScheduleMeetingStatusChange(scheduleCallback);
  }

  @override
  String getTitle() {
    return meetingAppLocalizations.meetingDetail;
  }

  @override
  List<Widget> buildActions() {
    return <Widget>[
      if (item.state == NEMeetingState.init)
        TextButton(
          child: Text(
            meetingAppLocalizations.globalEdit,
            style: TextStyle(
              color: AppColors.color_337eff,
              fontSize: 16.0,
            ),
          ),
          onPressed: () {
            if (item.recurringRule.type != NEMeetingRecurringRuleType.no) {
              showEditActionSheet();
            } else {
              Navigator.of(context)
                  .push(MaterialMeetingAppPageRoute(builder: (context) {
                return ScheduleMeetingEditRoute(item, isEditAll: true);
              }));
            }
          },
        )
    ];
  }

  void showEditActionSheet() {
    showCupertinoModalPopup<String>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              title: Text(
                meetingAppLocalizations.meetingRepeatEditing,
                style: TextStyle(color: AppColors.grey_8F8F8F, fontSize: 13),
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                    child: Text(
                        meetingAppLocalizations.meetingRepeatEditCurrent,
                        style: TextStyle(color: AppColors.color_007AFF)),
                    onPressed: () {
                      Navigator.pop(
                          context, meetingAppLocalizations.globalCancel);
                      Navigator.of(context)
                          .push(MaterialMeetingAppPageRoute(builder: (context) {
                        return ScheduleMeetingEditRoute(item, isEditAll: false);
                      }));
                    }),
                CupertinoActionSheetAction(
                    child: Text(meetingAppLocalizations.meetingRepeatEditAll,
                        style: TextStyle(color: AppColors.color_007AFF)),
                    onPressed: () {
                      Navigator.pop(
                          context, meetingAppLocalizations.globalCancel);
                      Navigator.of(context)
                          .push(MaterialMeetingAppPageRoute(builder: (context) {
                        return ScheduleMeetingEditRoute(item, isEditAll: true);
                      }));
                    }),
              ],
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text(meetingAppLocalizations.globalCancel,
                    style: TextStyle(color: AppColors.color_007AFF)),
                onPressed: () {
                  Navigator.pop(context, meetingAppLocalizations.globalCancel);
                },
              ),
            ));
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
          buildMeetingNum(),
          if (item.inviteUrl?.isNotEmpty ?? false) _buildSplit(),
          if (item.inviteUrl?.isNotEmpty ?? false) buildInviteUrl(),
          buildSpace(),
          buildStartTime(),
          _buildSplit(),
          buildEndTime(),
          if (!TextUtil.isEmpty(item.password)) buildSpace(),
          if (!TextUtil.isEmpty(item.password)) buildPwd(),
          if (item.isWaitingRoomEnabled) ...[
            buildSpace(),
            SwitchItem(
              key: MeetingValueKey.scheduleWaitingRoom,
              value: true,
              title: meetingAppLocalizations.meetingEnableWaitingRoom,
              summary: meetingAppLocalizations.meetingWaitingRoomHint,
              onChange: null,
            ),
          ],
          if (item.settings.isAudioOffAllowSelfOn ||
              item.settings.isAudioOffNotAllowSelfOn) ...[
            buildSpace(),
            SwitchItem(
              key: MeetingValueKey.scheduleAttendeeAudio,
              value: true,
              title: meetingAppLocalizations.meetingAttendeeAudioOff,
              onChange: null,
            ),
            _buildSplit(),
            buildRadio(
              value: item.settings.isAudioOffAllowSelfOn,
              padding:
                  EdgeInsets.only(left: 20, right: 16, top: 17, bottom: 12),
              title: meetingAppLocalizations.meetingAttendeeAudioOffAllowOn,
              groupValue: true,
              onChanged: null,
            ),
            buildRadio(
              value: item.settings.isAudioOffNotAllowSelfOn,
              padding: EdgeInsets.only(left: 20, right: 16, bottom: 17),
              title: meetingAppLocalizations.meetingAttendeeAudioOffNotAllowOn,
              groupValue: true,
              onChanged: null,
            ),
          ],
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

  Widget buildMeetingNum() {
    return buildCopyItem(meetingAppLocalizations.meetingNum,
        TextUtil.applyMask(item.meetingNum!, '000-000-0000'));
  }

  Widget buildInviteUrl() {
    final inviteUrl = item.inviteUrl;
    if (inviteUrl == null || inviteUrl.isEmpty) {
      return Container();
    }
    return buildCopyItem(
      meetingAppLocalizations.meetingInviteUrl,
      inviteUrl,
      transform: false,
    );
  }

  Widget buildLiveUrl() {
    return buildCopyItem(
        meetingAppLocalizations.meetingLiveUrl, item.live?.liveUrl ?? '');
  }

  Widget buildLiveAuthLevel() {
    return _buildLiveAuthLevel(meetingAppLocalizations.meetingLiveLevel,
        meetingAppLocalizations.meetingLiveLevelTip);
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

  Widget buildCopyItem(String? itemTitle, String? itemDetail,
      {bool transform = true}) {
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
            key: MeetingValueKey.copy,
            child: Text(' ${meetingAppLocalizations.globalCopy}',
                style: TextStyle(fontSize: 14, color: AppColors.blue_337eff)),
            onTap: () {
              if (itemDetail == null) return;
              final value = transform
                  ? TextUtil.replace(itemDetail, RegExp(r'-'), '')
                  : itemDetail;
              Clipboard.setData(ClipboardData(text: value));
              ToastUtils.showToast(
                  context, meetingAppLocalizations.globalCopySuccess);
            },
          ),
        ],
      ),
    );
  }

  Widget buildStartTime() {
    return buildTime(meetingAppLocalizations.meetingStartTime,
        DateTime.fromMillisecondsSinceEpoch(item.startTime));
  }

  Widget buildEndTime() {
    return buildTime(meetingAppLocalizations.meetingEndTime,
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
        meetingAppLocalizations.meetingPassword, item.password);
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
        child: Text(meetingAppLocalizations.meetingJoin,
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
          meetingAppLocalizations.meetingCancel,
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
        (historyItem.first.meetingNum == item.meetingNum ||
            historyItem.first.shortMeetingNum == item.meetingNum)) {
      lastUsedNickname = historyItem.first.nickname;
    }
    _onJoinMeeting(nickname: lastUsedNickname);
  }

  /// 加入会议
  void _onJoinMeeting({String? nickname}) async {
    LoadingUtil.showLoading();
    final result = await NEMeetingUIKit().joinMeetingUI(
      context,
      NEJoinMeetingUIParams(
        meetingNum: item.meetingNum!,
        displayName: nickname ?? MeetingUtil.getNickName(),
        watermarkConfig: NEWatermarkConfig(
          name: MeetingUtil.getNickName(),
        ),
      ),
      await buildMeetingUIOptions(context: context),
      onMeetingPageRouteWillPush: () async {
        LoadingUtil.cancelLoading();
        NavUtils.pop(context);
      },
      backgroundWidget: MeetingAppLocalizationsScope(child: HomePageRoute()),
    );
    final errorCode = result.code;
    final errorMessage = result.msg;
    LoadingUtil.cancelLoading();
    if (errorCode == NEMeetingErrorCode.success) {
      // do nothing
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

  void _cancelMeeting() {
    if (item.recurringRule.type != NEMeetingRecurringRuleType.no) {
      showConfirmDialogWithCheckbox(
        title: meetingAppLocalizations.meetingCancelConfirm,
        checkboxMessage: meetingAppLocalizations.meetingRepeatCancelAll,
        initialChecked: false,
        cancelLabel: meetingAppLocalizations.meetingNotCancel,
        okLabel: meetingAppLocalizations.meetingCancel,
        cancelTextColor: AppColors.color_337eff,
        okTextColor: AppColors.color_F24957,
      ).then((result) {
        if (!mounted || result == null) return;
        _onCancel(result.checked);
      });
    } else {
      showCupertinoModalPopup<String>(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
                title: Text(
                  meetingAppLocalizations.meetingCancelConfirm,
                  style: TextStyle(color: AppColors.grey_8F8F8F, fontSize: 13),
                ),
                actions: <Widget>[
                  CupertinoActionSheetAction(
                      child: Text(meetingAppLocalizations.meetingCancel,
                          style: TextStyle(color: AppColors.colorFE3B30)),
                      onPressed: () {
                        Navigator.pop(context);
                        _onCancel(false);
                      }),
                ],
                cancelButton: CupertinoActionSheetAction(
                  isDefaultAction: true,
                  child: Text(meetingAppLocalizations.meetingNotCancel,
                      style: TextStyle(color: AppColors.color_007AFF)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ));
    }
  }

  void _onCancel(bool cancelAll) {
    LoadingUtil.showLoading();
    cancelByMySelf = true;
    NEMeetingKit.instance
        .getPreMeetingService()
        .cancelMeeting(item.meetingId!, cancelAll)
        .then(((result) {
      LoadingUtil.cancelLoading();
      if (result.code == HttpCode.success) {
        Navigator.pop(context);
      } else {
        cancelByMySelf = false;
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
      height: 0.5,
      child: Divider(height: 0.5),
    );
  }

  Widget buildRadio({
    required String title,
    required bool value,
    required bool groupValue,
    required Function(bool?)? onChanged,
    EdgeInsetsGeometry? padding,
  }) {
    return GestureDetector(
      child: Container(
        padding: padding,
        color: Colors.white,
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              child: Radio<bool>(
                value: value,
                groupValue: groupValue,
                onChanged: onChanged,
                fillColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return AppColors.blue_337eff.withOpacity(
                      states.contains(MaterialState.disabled) ? 0.5 : 1.0,
                    );
                  }
                  return null;
                }),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColors.black_333333,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none))),
          ],
        ),
      ),
      onTap: () => onChanged?.call(value),
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
