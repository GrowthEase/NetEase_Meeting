// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/base/util/text_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/routes/home_page.dart';
import 'package:nemeeting/utils/meeting_string_util.dart';
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
import '../uikit/values/borders.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/dimem.dart';
import '../uikit/values/fonts.dart';

class ScheduleMeetingDetailRoute extends StatefulWidget {
  static final routeName = '/scheduleMeetingDetail';
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

  final preMetingService = NEMeetingKit.instance.getPreMeetingService();

  List<NEScheduledMember>? _scheduledMemberList;
  List<NEScheduledMember> get scheduledMemberList {
    if (_scheduledMemberList == null) {
      if (item.scheduledMemberList?.isNotEmpty == true) {
        _scheduledMemberList = item.scheduledMemberList;
      } else {
        _scheduledMemberList = [defaultScheduleMySelf];
      }
      item.scheduledMemberList = _scheduledMemberList;
      _scheduledMemberList!.sort((lhs, rhs) =>
          NEScheduledMemberExt.compareMember(
              lhs, rhs, AuthManager().accountId, item.ownerUserUuid));
    }
    return _scheduledMemberList!;
  }

  /// 默认添加自己为参会者
  NEScheduledMember get defaultScheduleMySelf {
    final accountInfo =
        NEMeetingKit.instance.getAccountService().getAccountInfo();
    final userUuid = accountInfo?.userUuid ?? '';
    return NEScheduledMember(
        role: MeetingRoles.kHost,
        userUuid: userUuid,
        contact: NEContact(
            name: accountInfo?.nickname ?? '',
            avatar: accountInfo?.avatar,
            userUuid: userUuid));
  }

  List<NEContact> get contactList => scheduledMemberList
      .where((element) => element.contact != null)
      .map((e) => e.contact!)
      .toList();

  /// 滑动控制器
  ScrollController _scrollController = ScrollController();
  int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    scheduleCallback = (List<NEMeetingItem> data, bool incremental) {
      if (!mounted) return;
      data.forEach((element) {
        if (element.meetingId == item.meetingId) {
          if (element.state.index >= NEMeetingState.init.index &&
              element.state.index <= NEMeetingState.ended.index) {
            setState(() {
              _scheduledMemberList = null;
              item = element;
              if (item.scheduledMemberList?.isNotEmpty != true) {
                _updateMeetingInfo(item);
              }
            });
          } else {
            if (element.state == NEMeetingState.cancel) {
              /// 会议被创建者取消了
              if (item.ownerUserUuid != AuthManager().accountId) {
                ToastUtils.showToast(context,
                    meetingAppLocalizations.meetingHasBeenCanceledByOwner);
              }

              /// 会议被其他端销毁，会议取消
              else if (!cancelByMySelf) {
                ToastUtils.showToast(
                    context, meetingAppLocalizations.meetingHasBeenCanceled);
              }
            }

            /// 会议无效时，返回首页
            else if (element.state == NEMeetingState.invalid ||
                element.state == NEMeetingState.recycled) {
              ToastUtils.showToast(context, meetingAppLocalizations.meetingEnd);
            }

            /// 退回首页
            if (Navigator.canPop(context)) {
              Navigator.popUntil(context,
                  ModalRoute.withName(ScheduleMeetingDetailRoute.routeName));
              Navigator.maybePop(context);
            }
          }
        }
      });
    };
    preMetingService.registerScheduleMeetingStatusChange(scheduleCallback);

    if (item.scheduledMemberList?.isNotEmpty != true) {
      _updateMeetingInfo(item);
    }
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          loadMoreContacts().then((value) => setState(() {}));
        }
      });
  }

  @override
  String getTitle() {
    return meetingAppLocalizations.meetingDetail;
  }

  /// 是不是我的会议
  bool get isMyMeeting => item.ownerUserUuid == AuthManager().accountId;

  /// 是不是会议创建者
  bool isMeetingOwner(String? uuid) => uuid == item.ownerUserUuid;

  @override
  List<Widget> buildActions() {
    return <Widget>[
      if (item.state == NEMeetingState.init && isMyMeeting)
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
          buildSpace(height: 1),
          buildMeetingTheme(),
          if (item.recurringRule.type != NEMeetingRecurringRuleType.no)
            buildRecurringRule(),
          buildSpace(),
          buildOwner(),
          _buildSplit(),
          buildScheduleAttendees(),
          buildSpace(),
          buildMeetingNum(),
          if (item.inviteUrl?.isNotEmpty ?? false) _buildSplit(),
          if (item.inviteUrl?.isNotEmpty ?? false) buildInviteUrl(),
          buildSpace(),
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
          if (item.isEnableGuestJoin()) ...[
            buildSpace(),
            SwitchItem(
              key: MeetingValueKey.scheduleEnableGuestJoin,
              value: true,
              title: meetingAppLocalizations.meetingGuestJoin,
              summary: meetingAppLocalizations.meetingGuestJoinSecurityNotice,
              summaryColor: AppColors.color_f29900,
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

  /// 构建周期性会议规则
  Widget buildRecurringRule() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCommonItem(
            meetingAppLocalizations.meetingFrequency,
            MeetingStringUtil.getRepeatTypeString(item.recurringRule.type,
                item.startTime, meetingAppLocalizations)),
        if (item.recurringRule.type == NEMeetingRecurringRuleType.custom) ...[
          _buildSplit(),
          _buildCommonItem(
              meetingAppLocalizations.meetingRepeatEndAt,
              MeetingStringUtil.getCustomRepeatDesc(
                  item.recurringRule, item.startTime, meetingAppLocalizations)),
        ],
      ],
    );
  }

  Widget buildMeetingTheme() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.subject ?? '',
            style: TextStyle(
                fontSize: 20,
                color: AppColors.black_333333,
                fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 24),
          Row(
            children: [
              buildStartTime(),
              buildDuration(),
              buildEndTime(),
            ],
          )
        ],
      ),
    );
  }

  Widget buildMeetingNum() {
    return buildCopyItem(meetingAppLocalizations.meetingNum,
        TextUtil.applyMask(item.meetingNum!, '000-000-0000'),
        transform: true);
  }

  Widget buildInviteUrl() {
    final inviteUrl = item.inviteUrl;
    if (inviteUrl == null || inviteUrl.isEmpty) {
      return Container();
    }
    return buildCopyItem(
      meetingAppLocalizations.meetingInviteUrl,
      inviteUrl,
    );
  }

  Widget buildLiveUrl() {
    return buildCopyItem(
        meetingAppLocalizations.meetingLiveUrl, item.live?.liveUrl ?? '');
  }

  Widget buildLiveAuthLevel() {
    return _buildCommonItem(meetingAppLocalizations.meetingLiveLevel,
        meetingAppLocalizations.meetingLiveLevelTip);
  }

  Widget _buildCommonItem(String itemTitle, String des) {
    return Container(
      height: Dimen.primaryItemHeight,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
      child: Row(
        children: <Widget>[
          Text(itemTitle,
              style: TextStyle(fontSize: 16, color: AppColors.black_222222)),
          SizedBox(width: 10),
          Expanded(
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    des,
                    style:
                        TextStyle(fontSize: 14, color: AppColors.black_333333),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ))),
        ],
      ),
    );
  }

  Widget buildCopyItem(String? itemTitle, String? itemDetail,
      {bool transform = false, bool enableCopy = true}) {
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
          if (enableCopy)
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
                ToastUtils.showBotToast(
                    meetingAppLocalizations.globalCopySuccess);
              },
            ),
        ],
      ),
    );
  }

  Widget buildStartTime() {
    return buildTime(DateTime.fromMillisecondsSinceEpoch(item.startTime));
  }

  Widget buildEndTime() {
    return buildTime(DateTime.fromMillisecondsSinceEpoch(item.endTime));
  }

  Widget buildTime(DateTime showTime) {
    final date = MeetingTimeUtil.getTimeFormat(
        showTime, meetingAppLocalizations.globalDateFormat);
    final time = MeetingTimeUtil.getTimeFormat(showTime, 'HH:mm');
    return Expanded(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(time,
            style: TextStyle(
                fontSize: 32,
                color: AppColors.black_222222,
                fontWeight: FontWeight.w500)),
        SizedBox(height: 6),
        Text(date,
            style: TextStyle(
                fontSize: 12,
                color: AppColors.color_3D3D3D,
                fontWeight: FontWeight.w400)),
      ],
    ));
  }

  Color getItemStateColor(NEMeetingState status) {
    switch (status) {
      case NEMeetingState.init:
        return AppColors.color_FF7903;
      case NEMeetingState.started:
        return AppColors.color_337eff;
      case NEMeetingState.ended:
        return AppColors.color_999999;
      default:
        return AppColors.color_337eff;
    }
  }

  Widget buildDuration() {
    final duration = item.endTime - item.startTime;
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            MeetingStringUtil.getItemStatus(
                item.state, meetingAppLocalizations),
            style: TextStyle(
              fontSize: 12,
              color: getItemStateColor(item.state),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 20,
                height: 1,
                color: AppColors.color_D8D8D8,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                margin: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: AppColors.color_F2F2F5,
                  borderRadius: BorderRadius.all(Radius.circular(2.0)),
                ),
                child: Text(
                  getDurationString(duration),
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.color_3D3D3D,
                      fontWeight: FontWeight.w400),
                ),
              ),
              Container(
                width: 20,
                height: 1,
                color: AppColors.color_D8D8D8,
              ),
            ],
          )
        ],
      ),
    );
  }

  /// 会议时间字符串
  String getDurationString(int duration) {
    int hour = duration ~/ 3600000;
    int minute = (duration % 3600000) ~/ 60000;
    var result = '';
    if (hour > 0) {
      result += '$hour${meetingAppLocalizations.globalHours}';
    }

    /// 英文文案中间需要间隔
    if (hour > 0 && minute > 0 && meetingAppLocalizations.localeName == 'en') {
      result += ' ';
    }
    if (minute > 0) {
      result += '$minute${meetingAppLocalizations.globalMinutes}';
    }
    return result;
  }

  /// 构建会议参会者
  Widget buildScheduleAttendees() {
    final myUserUuid =
        NEMeetingKit.instance.getAccountService().getAccountInfo()?.userUuid ??
            '';
    return GestureDetector(
      onTap: () => DialogUtils.showContactsPopup(
        context: context,
        titleBuilder: (int size) =>
            '${meetingAppLocalizations.meetingAttendees}（$size）',
        scheduledMemberList: scheduledMemberList,
        myUserUuid: myUserUuid,
        ownerUuid: item.ownerUserUuid,
        editable: false,
        loadMoreContacts: loadMoreContacts,
      ).then((value) {
        setState(() {});
      }),
      child: Container(
        color: Colors.white,
        padding:
            EdgeInsets.symmetric(horizontal: Dimen.globalPadding, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  meetingAppLocalizations.meetingAttendees,
                  style: TextStyle(
                      color: AppColors.color_222222,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
                Expanded(child: SizedBox.shrink()),
                Text(
                    meetingAppLocalizations
                        .meetingAttendeeCount('${scheduledMemberList.length}'),
                    style: TextStyle(
                        color: AppColors.color_999999,
                        fontSize: 14,
                        fontWeight: FontWeight.w400)),
                SizedBox(width: 8),
                Icon(IconFont.iconyx_allowx,
                    size: 14, color: AppColors.greyCCCCCC)
              ],
            ),
            SizedBox(height: 16),
            buildAttendeesList(),
          ],
        ),
      ),
    );
  }

  /// 构建参会者列表widget
  Widget buildAttendeesList() {
    return Row(
      children: [
        Expanded(
            child: Container(
          height: 32,
          child: ListView.separated(
            itemCount: contactList.length,
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            itemBuilder: (context, index) {
              return NEMeetingAvatar.medium(
                name: contactList[index].name,
                url: contactList[index].avatar,
                showRoleIcon: isMeetingOwner(contactList[index].userUuid),
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(width: 10);
            },
          ),
        ))
      ],
    );
  }

  /// 构建会议创建人
  Widget buildOwner() {
    return buildCopyItem(
        meetingAppLocalizations.historyMeetingOwner, item.ownerNickname,
        enableCopy: false);
  }

  /// 本地分页加载通讯录成员
  Future loadMoreContacts() async {
    if (scheduledMemberList.length <= contactList.length) return;
    int end = min(contactList.length + _pageSize, scheduledMemberList.length);
    final userUuids = scheduledMemberList
        .sublist(contactList.length, end)
        .map((e) => e.userUuid)
        .toList();

    /// 加载更多
    final result = await NEMeetingKit.instance
        .getAccountService()
        .getContactsInfo(userUuids);

    scheduledMemberList.removeWhere((element) =>
        result.data?.notFindUserUuids.contains(element.userUuid) == true);
    result.data?.meetingAccountListResp.forEach((contact) {
      scheduledMemberList.forEach((element) {
        if (element.userUuid == contact.userUuid) {
          element.contact = contact;
        }
      });
    });
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
    } else if (item.state == NEMeetingState.init && isMyMeeting) {
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
    /// 解决加入会议和取消会议的状态监听并发问题
    preMetingService.unRegisterScheduleMeetingStatusChange(scheduleCallback);
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
        if (mounted) Navigator.maybePop(context);
      },
      onPasswordPageRouteWillPush: () async {
        LoadingUtil.cancelLoading();
      },
      backgroundWidget: MeetingAppLocalizationsScope(child: HomePageRoute()),
    );
    final errorCode = result.code;
    final errorMessage = result.msg;
    LoadingUtil.cancelLoading();
    if (errorCode == NEMeetingErrorCode.success) {
      return;
    } else if (errorCode == NEMeetingErrorCode.noNetwork) {
      ToastUtils.showBotToast(
          meetingAppLocalizations.globalNetworkUnavailableCheck);
    } else if (errorCode == NEMeetingErrorCode.noAuth) {
      ToastUtils.showBotToast(meetingAppLocalizations.authLoginOnOtherDevice);
      AuthManager().logout();
      NavUtils.toEntrance(context);
      return;
    } else if (errorCode == NEMeetingErrorCode.alreadyInMeeting) {
      ToastUtils.showBotToast(
          meetingAppLocalizations.meetingOperationNotSupportedInMeeting);
    } else if (errorCode == NEMeetingErrorCode.cancelled) {
      /// 暂不处理
    } else {
      var errorTips = HttpCode.getMsg(
          errorMessage, meetingAppLocalizations.meetingJoinFail);
      ToastUtils.showBotToast(errorTips);
    }
    preMetingService.registerScheduleMeetingStatusChange(scheduleCallback);
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
          useRootNavigator: false,
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
    preMetingService.cancelMeeting(item.meetingId!, cancelAll).then(((result) {
      LoadingUtil.cancelLoading();

      /// 自己取消了本场会议，走cancel监听pop，这里直接不做处理
      if (result.code != HttpCode.success) {
        cancelByMySelf = false;
        var errorMsg = result.msg;
        errorMsg = HttpCode.getMsg(errorMsg);
        ToastUtils.showBotToast(errorMsg);
      }
    }));
  }

  Widget buildSpace({double height = 10}) {
    return Container(
      color: AppColors.globalBg,
      height: height,
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

  /// 更新参会者列表至会议信息中
  void _updateMeetingInfo(NEMeetingItem meetingItem) {
    if (meetingItem.meetingNum == null) return;
    preMetingService
        .getScheduledMembers(meetingItem.meetingNum!)
        .then((value) async {
      if (value.code == HttpCode.success) {
        meetingItem.scheduledMemberList = value.data;
        if (meetingItem.scheduledMemberList?.isNotEmpty != true) {
          meetingItem.scheduledMemberList = [defaultScheduleMySelf];
        }
        _scheduledMemberList = null;
        await loadMoreContacts();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    preMetingService.unRegisterScheduleMeetingStatusChange(scheduleCallback);
    super.dispose();
  }
}
