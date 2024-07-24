// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/base/util/text_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/routes/home_page.dart';
import 'package:nemeeting/utils/meeting_string_util.dart';
import 'package:nemeeting/widget/ne_widget.dart';
import 'package:netease_common/netease_common.dart';
import 'package:netease_meeting_kit/meeting_core.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';
import 'package:nemeeting/pre_meeting/schedule_meeting_edit.dart';
import 'package:nemeeting/utils/const_config.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import '../language/localizations.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/utils/nav_utils.dart';
import '../uikit/values/asset_name.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/dimem.dart';

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
    extends AppBaseState<ScheduleMeetingDetailRoute> with NEPreMeetingListener {
  NEMeetingItem item;

  _ScheduleMeetingDetailRouteState(this.item);

  bool cancelByMySelf = false;

  bool isLoading = false;

  final preMetingService = NEMeetingKit.instance.getPreMeetingService();

  List<NEScheduledMember>? _scheduledMemberList;

  List<NEScheduledMember> get scheduledMemberList {
    if (_scheduledMemberList == null) {
      _scheduledMemberList =
          item.scheduledMemberList ?? [defaultScheduleMySelf];
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
    );
  }

  final contactMap = <String, NEContact>{};

  List<NEContact> get contactList => scheduledMemberList
      .map((e) => contactMap[e.userUuid])
      .whereType<NEContact>()
      .toList();

  /// 滑动控制器
  ScrollController _scrollController = ScrollController();
  int _pageSize = 20;

  ValueNotifier<NETimezone?> timezoneNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    preMetingService.addListener(this);
    _updateMeetingInfo(item);
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          loadMoreContacts().then((value) => setState(() {}));
        }
      });
  }

  @override
  void onMeetingItemInfoChanged(List<NEMeetingItem> data) {
    if (!mounted) return;
    data.forEach((newItem) {
      if (newItem.meetingId == item.meetingId) {
        if (newItem.status.index >= NEMeetingItemStatus.init.index &&
            newItem.status.index <= NEMeetingItemStatus.ended.index) {
          _updateMeetingInfo(newItem);
        } else {
          if (newItem.status == NEMeetingItemStatus.cancel) {
            /// 会议被创建者取消了
            if (item.ownerUserUuid != AuthManager().accountId) {
              ToastUtils.showToast(
                  context, getAppLocalizations().meetingHasBeenCanceledByOwner);
            }

            /// 会议被其他端销毁，会议取消
            else if (!cancelByMySelf) {
              ToastUtils.showToast(
                  context, getAppLocalizations().meetingHasBeenCanceled);
            }
          }

          /// 会议无效时，返回首页
          else if (newItem.status == NEMeetingItemStatus.invalid ||
              newItem.status == NEMeetingItemStatus.recycled) {
            ToastUtils.showToast(context, getAppLocalizations().meetingEnd);
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
  }

  @override
  String getTitle() {
    return getAppLocalizations().meetingDetail;
  }

  @override
  Color getAppBarBackgroundColor() => Colors.transparent;

  @override
  Color get backgroundColor => AppColors.white;

  @override
  Widget? buildCustomAppBar() {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage(
          AssetName.headerBackground,
        ),
        fit: BoxFit.cover, // 图片适应容器尺寸
      )),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildAppBar(),
          buildMeetingTheme(),
        ],
      ),
    );
  }

  /// 是不是我的会议
  bool get isMyMeeting => item.ownerUserUuid == AuthManager().accountId;

  /// 是不是会议创建者
  bool isMeetingOwner(String? uuid) => uuid == item.ownerUserUuid;

  @override
  List<Widget> buildActions() {
    return <Widget>[
      if (item.status == NEMeetingItemStatus.init && isMyMeeting)
        TextButton(
          child: Icon(
            Icons.more_horiz,
            size: 24,
            color: AppColors.color_53576A,
          ),
          onPressed: () {
            if (isLoading) return;
            showNavActionSheet();
          },
        )
    ];
  }

  void showNavActionSheet() {
    showCupertinoModalPopup<String>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              actions: <Widget>[
                CupertinoActionSheetAction(
                    child: Text(getAppLocalizations().meetingEdit,
                        style: TextStyle(color: AppColors.color_007AFF)),
                    onPressed: () {
                      Navigator.pop(
                          context, getAppLocalizations().globalCancel);
                      if (item.recurringRule.type !=
                          NEMeetingRecurringRuleType.no) {
                        showEditActionSheet();
                      } else {
                        Navigator.of(context)
                            .push(NEMeetingPageRoute(builder: (context) {
                          return ScheduleMeetingEditRoute(item, contactMap,
                              isEditAll: true);
                        }));
                      }
                    }),
                CupertinoActionSheetAction(
                    child: Text(getAppLocalizations().meetingCancel,
                        style: TextStyle(color: AppColors.colorFE3B30)),
                    onPressed: () {
                      Navigator.pop(
                          context, getAppLocalizations().globalCancel);
                      _cancelMeeting();
                    }),
              ],
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text(getAppLocalizations().globalCancel,
                    style: TextStyle(color: AppColors.color_007AFF)),
                onPressed: () {
                  Navigator.pop(context, getAppLocalizations().globalCancel);
                },
              ),
            ));
  }

  void showEditActionSheet() {
    showCupertinoModalPopup<String>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              title: Text(
                getAppLocalizations().meetingRepeatEditing,
                style: TextStyle(color: AppColors.grey_8F8F8F, fontSize: 13),
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                    child: Text(getAppLocalizations().meetingRepeatEditCurrent,
                        style: TextStyle(color: AppColors.color_007AFF)),
                    onPressed: () {
                      Navigator.pop(
                          context, getAppLocalizations().globalCancel);
                      Navigator.of(context)
                          .push(NEMeetingPageRoute(builder: (context) {
                        return ScheduleMeetingEditRoute(item, contactMap,
                            isEditAll: false);
                      }));
                    }),
                CupertinoActionSheetAction(
                    child: Text(getAppLocalizations().meetingRepeatEditAll,
                        style: TextStyle(color: AppColors.color_007AFF)),
                    onPressed: () {
                      Navigator.pop(
                          context, getAppLocalizations().globalCancel);
                      Navigator.of(context)
                          .push(NEMeetingPageRoute(builder: (context) {
                        return ScheduleMeetingEditRoute(item, contactMap,
                            isEditAll: true);
                      }));
                    }),
              ],
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text(getAppLocalizations().globalCancel,
                    style: TextStyle(color: AppColors.color_007AFF)),
                onPressed: () {
                  Navigator.pop(context, getAppLocalizations().globalCancel);
                },
              ),
            ));
  }

  @override
  Widget buildBody() {
    final audioList = buildAudioList();
    final liveList = buildLiveList();
    return Column(
      children: [
        Expanded(
            child: Container(
          color: AppColors.globalBg,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (item.recurringRule.type != NEMeetingRecurringRuleType.no)
                  MeetingCard(children: [buildRecurringRule()]),
                MeetingCard(children: buildCreateMeetingInfoList()),
                MeetingCard(children: buildMeetingInfoList()),
                if (isMyMeeting) buildWaitingRoomEnabled(),
                if (isMyMeeting) buildGuestJoin(),
                if (isMyMeeting) buildCloudRecord(),
                if (isMyMeeting && audioList.isNotEmpty)
                  MeetingCard(children: audioList),
                if (liveList.isNotEmpty) MeetingCard(children: liveList),
                SizedBox(height: 24),
              ],
            ),
          ),
        )),
        Container(height: 0.5, color: AppColors.color_F0F1F5),
        buildBtn(),
      ],
    );
  }

  /// 构建周期性会议规则
  Widget buildRecurringRule() {
    bool hasCustom =
        item.recurringRule.type == NEMeetingRecurringRuleType.custom;
    return ValueListenableBuilder(
      valueListenable: timezoneNotifier,
      builder: (context, value, child) {
        final transferStartTime =
            TimezonesUtil.convertTimezoneDateTime(item.startTime, value);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MeetingListCopyable(
              justTopCorner: true,
              justBottomCorner: !hasCustom,
              title: getAppLocalizations().meetingFrequency,
              content: MeetingStringUtil.getRepeatTypeString(
                  item.recurringRule.type, transferStartTime),
              enableCopyNotifier: ValueNotifier(false),
            ),
            if (hasCustom)
              MeetingListCopyable.withBottomCorner(
                title: getAppLocalizations().meetingRepeatEndAt,
                content: MeetingStringUtil.getCustomRepeatDesc(
                    item.recurringRule, transferStartTime),
                enableCopyNotifier: ValueNotifier(false),
              ),
          ],
        );
      },
    );
  }

  Widget buildMeetingTheme() {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
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
              Expanded(child: buildDuration()),
              buildEndTime(),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMeetingNum(
    bool justTopCorner,
    bool justBottomCorner,
  ) {
    return MeetingListCopyable(
      justTopCorner: justTopCorner,
      justBottomCorner: justBottomCorner,
      title: getAppLocalizations().meetingNum,
      content: TextUtil.applyMask(item.meetingNum!, '000-000-0000'),
      transformNotifier: ValueNotifier(true),
    );
  }

  Widget buildInviteUrl(
    bool justTopCorner,
    bool justBottomCorner,
  ) {
    return MeetingListCopyable(
      justTopCorner: justTopCorner,
      justBottomCorner: justBottomCorner,
      title: getAppLocalizations().meetingInviteUrl,
      content: item.inviteUrl,
    );
  }

  Widget buildPwd() {
    return MeetingListCopyable.withBottomCorner(
      title: getAppLocalizations().meetingPassword,
      content: item.password,
    );
  }

  Widget buildLiveUrl(
    bool justTopCorner,
    bool justBottomCorner,
  ) {
    return MeetingListCopyable(
      title: getAppLocalizations().meetingLiveUrl,
      content: item.live?.liveUrl ?? '',
      justTopCorner: justTopCorner,
      justBottomCorner: justBottomCorner,
    );
  }

  Widget buildLiveAuthLevel(
    bool justTopCorner,
    bool justBottomCorner,
  ) {
    return MeetingListCopyable(
      title: getAppLocalizations().meetingLiveLevel,
      content: getAppLocalizations().meetingLiveLevelTip,
      enableCopyNotifier: ValueNotifier(false),
      justTopCorner: justTopCorner,
      justBottomCorner: justBottomCorner,
    );
  }

  /// 构建等候室
  ///
  Widget buildWaitingRoomEnabled() {
    if (item.waitingRoomEnabled) {
      return MeetingCard(children: [
        MeetingSwitchItem(
          switchKey: MeetingValueKey.scheduleWaitingRoom,
          valueNotifier: ValueNotifier(true),
          title:
              NEMeetingUIKit.instance.getUIKitLocalizations().waitingRoomEnable,
          content: getAppLocalizations().meetingWaitingRoomHint,
          onChanged: null,
        ),
      ]);
    } else {
      return Container();
    }
  }

  /// 构建访客加入开关
  Widget buildGuestJoin() {
    if (item.enableGuestJoin) {
      return MeetingCard(children: [
        MeetingSwitchItem(
          switchKey: MeetingValueKey.scheduleEnableGuestJoin,
          valueNotifier: ValueNotifier(true),
          title: getAppLocalizations().meetingGuestJoin,
          contentBuilder: (enable) => Text(
            getAppLocalizations().meetingGuestJoinSecurityNotice,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.color_f29900,
            ),
          ),
          onChanged: null,
        ),
      ]);
    } else {
      return Container();
    }
  }

  /// 构建自动云录制开关
  Widget buildCloudRecord() {
    if (item.cloudRecordConfig?.enable == true) {
      return MeetingCard(children: [
        MeetingSwitchItem(
          switchKey: MeetingValueKey.scheduleCloudRecord,
          valueNotifier: ValueNotifier(true),
          title: getAppLocalizations().meetingCloudRecord,
          content: item.cloudRecordConfig?.recordStrategy ==
                  NERecordStrategyType.hostJoin
              ? getAppLocalizations().meetingEnableCloudRecordWhenHostJoin
              : getAppLocalizations().meetingEnableCloudRecordWhenMemberJoin,
          onChanged: null,
        ),
      ]);
    } else {
      return Container();
    }
  }

  /// 构建直播相关信息
  List<Widget> buildLiveList() {
    List<Widget> widgets = [];
    bool hasLiveUrl = item.live?.liveUrl != null && item.live?.enable == true;
    bool hasLiveWebAccessControlLevel = item.live?.liveWebAccessControlLevel ==
            NEMeetingLiveAuthLevel.appToken &&
        item.live?.enable == true;
    if (hasLiveUrl) {
      widgets.add(buildLiveUrl(hasLiveUrl, !hasLiveWebAccessControlLevel));
    }
    if (hasLiveWebAccessControlLevel) {
      widgets
          .add(buildLiveAuthLevel(!hasLiveUrl, hasLiveWebAccessControlLevel));
    }
    return widgets;
  }

  /// 构建音频相关信息
  List<Widget> buildAudioList() {
    List<Widget> widgets = [];

    if (item.settings.isAudioOffAllowSelfOn ||
        item.settings.isAudioOffNotAllowSelfOn) {
      widgets.add(MeetingSwitchItem(
        switchKey: MeetingValueKey.scheduleAttendeeAudio,
        valueNotifier: ValueNotifier(true),
        title: getAppLocalizations().meetingAttendeeAudioOff,
        onChanged: null,
      ));
      widgets.add(buildRadio(
        value: item.settings.isAudioOffAllowSelfOn,
        title: getAppLocalizations().meetingAttendeeAudioOffAllowOn,
        groupValue: true,
        onChanged: null,
      ));
      widgets.add(buildRadio(
        value: item.settings.isAudioOffNotAllowSelfOn,
        title: getAppLocalizations().meetingAttendeeAudioOffNotAllowOn,
        groupValue: true,
        onChanged: null,
      ));
    }
    return widgets;
  }

  Widget buildCopyItem(String? itemTitle, String? itemDetail,
      {bool transform = false, bool enableCopy = true}) {
    return Container(
      height: Dimen.primaryItemHeight,
      color: Colors.white,
      padding: Dimen.horizontalPadding20,
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
            NEGestureDetector(
              key: MeetingValueKey.copy,
              child: Text(' ${getAppLocalizations().globalCopy}',
                  style: TextStyle(fontSize: 16, color: AppColors.blue_337eff)),
              onTap: () {
                if (itemDetail == null) return;
                final value = transform
                    ? TextUtil.replace(itemDetail, RegExp(r'-'), '')
                    : itemDetail;
                Clipboard.setData(ClipboardData(text: value));
                ToastUtils.showBotToast(
                    getAppLocalizations().globalCopySuccess);
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
    return ValueListenableBuilder(
        valueListenable: timezoneNotifier,
        builder: (context, value, child) {
          final transferTime = TimezonesUtil.convertTimezoneDateTime(
              showTime.millisecondsSinceEpoch, value);
          final transferDate =
              DateTime.fromMillisecondsSinceEpoch(transferTime);
          final date = MeetingTimeUtil.getTimeFormat(
              transferDate, getAppLocalizations().globalDateFormat);
          final time = MeetingTimeUtil.getTimeFormat(transferDate, 'HH:mm');
          return Container(
              width: 110,
              height: 68,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(time,
                      style: TextStyle(
                          fontSize: 36,
                          color: AppColors.color_1E1E27,
                          fontWeight: FontWeight.w600)),
                  Spacer(),
                  Text(date,
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.color_1E1E27,
                          fontWeight: FontWeight.w400)),
                ],
              ));
        });
  }

  Color getItemStateColor(NEMeetingItemStatus status) {
    switch (status) {
      case NEMeetingItemStatus.init:
        return AppColors.color_FF7903;
      case NEMeetingItemStatus.started:
        return AppColors.color_337eff;
      case NEMeetingItemStatus.ended:
        return AppColors.color_999999;
      default:
        return AppColors.color_337eff;
    }
  }

  Widget buildDuration() {
    final duration = item.endTime - item.startTime;
    return Container(
      height: 68,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            MeetingStringUtil.getItemStatus(item.status),
            style: TextStyle(
              fontSize: 12,
              color: getItemStateColor(item.status),
              fontWeight: FontWeight.w400,
            ),
          ),
          Spacer(),
          Row(
            children: [
              Expanded(
                  child: Container(height: 1, color: AppColors.color_D8D8D8)),
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
              Expanded(
                  child: Container(height: 1, color: AppColors.color_D8D8D8)),
            ],
          ),
          Spacer(),
          ValueListenableBuilder(
              valueListenable: timezoneNotifier,
              builder: (context, value, child) {
                return Text(
                  value?.time ?? '',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.color_53576A,
                      fontWeight: FontWeight.w400),
                );
              }),
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
      result += '$hour${getAppLocalizations().globalHours}';
    }

    /// 英文文案中间需要间隔
    if (hour > 0 && minute > 0 && getAppLocalizations().localeName == 'en') {
      result += ' ';
    }
    if (minute > 0) {
      result += '$minute${getAppLocalizations().globalMinutes}';
    }
    return result;
  }

  /// 构建会议参会者
  Widget buildScheduleAttendees() {
    final myUserUuid =
        NEMeetingKit.instance.getAccountService().getAccountInfo()?.userUuid ??
            '';
    return NEGestureDetector(
      onTap: () => DialogUtils.showContactsPopup(
        context: context,
        titleBuilder: (int size) =>
            '${getAppLocalizations().meetingAttendees}($size)',
        scheduledMemberList: scheduledMemberList,
        contactMap: contactMap,
        myUserUuid: myUserUuid,
        ownerUuid: item.ownerUserUuid,
        editable: false,
        loadMoreContacts: loadMoreContacts,
        getMemberSubTitles: (NEScheduledMember member) {
          if (item.interpretationSettings
                  ?.getInterpreterList()
                  .any((element) => element.userId == member.userUuid) ==
              true) {
            return [
              NEMeetingUIKit.instance.getUIKitLocalizations().interpInterpreter,
            ];
          }
          return [];
        },
      ).then((value) {
        if (mounted) setState(() {});
      }),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MeetingArrowItem(
            padding: const EdgeInsets.only(left: 16.0, right: 16),
            title: getAppLocalizations().meetingAttendees,
            content: getAppLocalizations()
                .meetingAttendeeCount('${scheduledMemberList.length}'),
          ),
          buildAttendeesList(),
        ],
      ),
    );
  }

  /// 构建参会者列表widget
  Widget buildAttendeesList() {
    return Container(
      height: 48,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Row(
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
                return const SizedBox(width: 14);
              },
            ),
          ))
        ],
      ),
    );
  }

  /// 构建会议创建人
  Widget buildOwner() {
    return MeetingListCopyable.withTopCorner(
      title: getAppLocalizations().historyMeetingOwner,
      content: item.ownerNickname,
      enableCopyNotifier: ValueNotifier(false),
    );
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
        .getContactsService()
        .getContactsInfo(userUuids);
    scheduledMemberList.removeWhere((element) =>
        result.data?.notFoundList.contains(element.userUuid) == true);
    result.data?.foundList.forEach((contact) {
      contactMap[contact.userUuid] = contact;
    });
  }

  Widget buildBtn() {
    Widget child = SizedBox.shrink();
    if (item.status == NEMeetingItemStatus.invalid ||
        item.status == NEMeetingItemStatus.cancel ||
        item.status == NEMeetingItemStatus.recycled) {
      return child;
    } else if (item.status == NEMeetingItemStatus.init && isMyMeeting) {
      child = Row(
        children: [
          Expanded(child: buildCopy()),
          SizedBox(width: 16),
          Expanded(child: buildJoin())
        ],
      );
    } else {
      child = buildJoin();
    }
    return SafeArea(
        top: false,
        child: Container(
            color: AppColors.white,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: child));
  }

  Widget buildJoin() {
    return NEGestureDetector(
      key: MeetingValueKey.scheduleJoin,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.blue_337eff,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        alignment: Alignment.center,
        child: Text(getAppLocalizations().meetingJoin,
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

  Widget buildCopy() {
    return NEGestureDetector(
      key: MeetingValueKey.scheduleCopy,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          border: Border.all(color: AppColors.blue_337eff, width: 1.0),
        ),
        alignment: Alignment.center,
        child: Text(
          getAppLocalizations().copyMeetingInvite,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.blue_337eff,
              fontWeight: FontWeight.w400,
              fontSize: 16,
              decoration: TextDecoration.none),
        ),
      ),
      onTap: () {
        NEMeetingKit.instance.getPreMeetingService().getInviteInfo(item).then(
          (result) {
            if (TextUtils.isNotEmpty(result)) {
              Clipboard.setData(ClipboardData(text: result));
              ToastUtils.showBotToast(getAppLocalizations().globalCopySuccess);
            }
          },
        );
      },
    );
  }

  Future<void> joinMeeting() async {
    final lastUsedNickname =
        LocalHistoryMeetingManager().getLatestNickname(item.meetingNum);
    _onJoinMeeting(nickname: lastUsedNickname);
  }

  /// 加入会议
  void _onJoinMeeting({String? nickname}) async {
    /// 解决加入会议和取消会议的状态监听并发问题
    preMetingService.removeListener(this);
    LoadingUtil.showLoading();
    final result = await NEMeetingKit.instance.getMeetingService().joinMeeting(
      context,
      NEJoinMeetingParams(
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
      backgroundWidget: HomePageRoute(),
    );
    final errorCode = result.code;
    final errorMessage = result.msg;
    LoadingUtil.cancelLoading();
    if (errorCode == NEMeetingErrorCode.success) {
    } else if (errorCode == NEMeetingErrorCode.noNetwork) {
      ToastUtils.showBotToast(
          getAppLocalizations().globalNetworkUnavailableCheck);
    } else if (errorCode == NEMeetingErrorCode.noAuth) {
      ToastUtils.showBotToast(getAppLocalizations().authLoginOnOtherDevice);
      AuthManager().logout();
      NavUtils.toEntrance(context);
      return;
    } else if (errorCode == NEMeetingErrorCode.alreadyInMeeting) {
      ToastUtils.showBotToast(
          getAppLocalizations().meetingOperationNotSupportedInMeeting);
    } else if (errorCode == NEMeetingErrorCode.cancelled) {
      /// 暂不处理
    } else {
      var errorTips =
          HttpCode.getMsg(errorMessage, getAppLocalizations().meetingJoinFail);
      ToastUtils.showBotToast(errorTips);
    }
    preMetingService.addListener(this);
  }

  void _cancelMeeting() {
    if (item.recurringRule.type != NEMeetingRecurringRuleType.no) {
      showConfirmDialogWithCheckbox(
        title: getAppLocalizations().meetingCancelConfirm,
        checkboxMessage: getAppLocalizations().meetingRepeatCancelAll,
        initialChecked: false,
        cancelLabel: getAppLocalizations().meetingNotCancel,
        okLabel: getAppLocalizations().meetingCancel,
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
                  getAppLocalizations().meetingCancelConfirm,
                  style: TextStyle(color: AppColors.grey_8F8F8F, fontSize: 13),
                ),
                actions: <Widget>[
                  CupertinoActionSheetAction(
                      child: Text(getAppLocalizations().meetingCancel,
                          style: TextStyle(color: AppColors.colorFE3B30)),
                      onPressed: () {
                        _onCancel(false);
                      }),
                ],
                cancelButton: CupertinoActionSheetAction(
                  isDefaultAction: true,
                  child: Text(getAppLocalizations().meetingNotCancel,
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

  Widget buildRadio({
    required String title,
    required bool value,
    required bool groupValue,
    required Function(bool?)? onChanged,
  }) {
    return NEGestureDetector(
      child: Container(
        padding: EdgeInsets.only(left: 32, top: 9, bottom: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
            bottomLeft: Radius.circular(7),
            bottomRight: Radius.circular(7),
          ),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              child: Radio<bool>(
                value: value,
                groupValue: groupValue,
                onChanged: onChanged,
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.blue_337eff.withOpacity(
                      states.contains(WidgetState.disabled) ? 0.5 : 1.0,
                    );
                  }
                  return AppColors.color_CDCFD7;
                }),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        color: AppColors.color_53576A,
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

    /// 解决快速编辑保存会议，预约成员列表未更新问题
    LoadingUtil.showLoading();
    isLoading = true;
    preMetingService
        .getScheduledMeetingMemberList(meetingItem.meetingNum!)
        .then((value) async {
          if (value.code == HttpCode.success) {
            meetingItem.scheduledMemberList = value.data;
            if (meetingItem.scheduledMemberList?.isNotEmpty != true) {
              meetingItem.scheduledMemberList = [defaultScheduleMySelf];
            }
            item = meetingItem;
            _scheduledMemberList = null;
            await loadMoreContacts();
            TimezonesUtil.getTimezoneById(meetingItem.timezoneId)
                .then((value) => timezoneNotifier.value = value);
            if (mounted) setState(() {});
          }
        })
        .timeout(Duration(seconds: 5))
        .whenComplete(() {
          isLoading = false;
          LoadingUtil.cancelLoading();
        });
  }

  @override
  void dispose() {
    preMetingService.removeListener(this);
    super.dispose();
  }

  /// 构建会议信息列表
  List<Widget> buildMeetingInfoList() {
    List<Widget> widgets = [];
    bool hasInviteUrl = item.inviteUrl?.isNotEmpty == true;
    bool hasPassword = !TextUtil.isEmpty(item.password);
    widgets.add(buildMeetingNum(true, !hasInviteUrl && !hasPassword));
    if (hasInviteUrl) {
      widgets.add(buildInviteUrl(false, !hasPassword));
    }
    if (hasPassword) {
      widgets.add(buildPwd());
    }
    return widgets;
  }

  /// 构建创建会议信息列表
  ///
  List<Widget> buildCreateMeetingInfoList() {
    List<Widget> widgets = [];
    widgets.add(buildOwner());
    widgets.add(buildScheduleAttendees());
    if (item.interpretationSettings?.isEmpty == false)
      widgets.add(MeetingListCopyable.withBottomCorner(
        title:
            NEMeetingUIKit.instance.getUIKitLocalizations().interpInterpreter,
        content: getAppLocalizations().meetingAttendeeCount(
            '${item.interpretationSettings!.getInterpreterList().length}'),
        enableCopyNotifier: ValueNotifier(false),
      ));
    return widgets;
  }
}
