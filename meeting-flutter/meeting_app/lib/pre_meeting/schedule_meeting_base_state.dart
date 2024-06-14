// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/pre_meeting/schedule_meeting_repeat.dart';
import 'package:nemeeting/pre_meeting/schedule_meeting_repeat_end.dart';
import 'package:nemeeting/routes/timezone_page.dart';
import 'package:nemeeting/widget/ne_widget.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

import '../base/util/text_util.dart';
import '../language/localizations.dart';
import '../service/auth/auth_manager.dart';
import '../uikit/const/consts.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/fonts.dart';
import '../utils/const_config.dart';
import '../utils/integration_test.dart';

abstract class ScheduleMeetingBaseState<T extends StatefulWidget>
    extends AppBaseState<T> {
  final meetingPwdSwitch = ValueNotifier(false);
  final enableWaitingRoom = ValueNotifier(false);

  final enableJoinBeforeHost = ValueNotifier(true);

  final attendeeAudioAutoOff = ValueNotifier(false);
  bool attendeeAudioAutoOffNotAllowSelfOn = false;

  final liveSwitch = ValueNotifier(false);
  final liveLevelSwitch = ValueNotifier(false);

  bool scheduling = false;

  static const int passwordRange = 900000,
      basePassword = 100000,
      oneDay = 24 * 60 * 60 * 1000;

  late NEMeetingItem meetingItem;

  late DateTime startTime, endTime;

  ValueNotifier<NETimezone?> timezoneNotifier = ValueNotifier(null);

  /// 周期性会议规则
  late NEMeetingRecurringRule recurringRule;

  late TextEditingController meetingSubjectController,
      meetingPasswordController;
  final FocusNode subjectFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  bool isLiveEnabled = false;

  bool attendeeRecordOn = !kNoCloudRecord;

  final enableGuestJoin = ValueNotifier(false);

  final enableInterpretation = ValueNotifier(false);
  InterpreterListController? interpreterListController;

  BoxDecoration _boxDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(
      Radius.circular(7.r),
    ),
  );

  List<NEContact> get contactList => scheduledMemberList
      .where((element) => element.contact != null)
      .map((e) => e.contact!)
      .toList();

  /// userUuid to role
  List<NEScheduledMember> scheduledMemberList = [];

  /// 滑动控制器
  ScrollController _scrollController = ScrollController();
  int _pageSize = 20;

  ScheduleMeetingBaseState({NEMeetingItem? item}) {
    if (item == null) {
      meetingItem = NEMeetingItem();
      meetingItem.ownerUserUuid = AuthManager().accountId;
      meetingItem.scheduledMemberList = [];
    } else {
      meetingItem = item;
    }
    meetingItem.scheduledMemberList!.sort((lhs, rhs) =>
        NEScheduledMemberExt.compareMember(
            lhs, rhs, AuthManager().accountId, meetingItem.ownerUserUuid));
    scheduledMemberList.clear();
    scheduledMemberList
        .addAll(meetingItem.scheduledMemberList!.map((e) => e.copy()));
  }

  late final int _maxMembers;

  @override
  void initState() {
    super.initState();
    subjectFocusNode.addListener(() {
      setState(() {});
    });
    passwordFocusNode.addListener(() {
      setState(() {});
    });
    meetingPasswordController = TextEditingController();
    var settingsService = NEMeetingKit.instance.getSettingsService();
    Future.wait([
      settingsService.isMeetingLiveSupported(),
      settingsService.isMeetingCloudRecordSupported(),
    ]).then((values) {
      setState(() {
        isLiveEnabled = values[0];
        // showMeetingRecord = values[1];
      });
    });

    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          loadMoreContacts().then((value) => setState(() {}));
        }
      });
    _maxMembers = SDKConfig.current.scheduleMemberMax;
  }

  @override
  Widget buildBody() {
    return NEMeetingKitFeatureConfig(
        // 使用最近的 sdk config，如果在会议中，可以查询到会议中使用的实例
        config: context.sdkConfig,
        builder: (context, child) => NEGestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                /// 构建会议信息模块
                buildSubject(
                    focusNode: subjectFocusNode,
                    controller: meetingSubjectController),
                buildMeetingInfoPart(context),

                /// 单次周期性会议修改要有提示
                if (recurringRule.type != NEMeetingRecurringRuleType.no &&
                    isEditAll() == false)
                  buildEditRepeatMeetingTips(),
                if (SDKConfig.current.isScheduledMembersEnabled) ...[
                  buildScheduleAttendees(),
                ],
                buildSecurityPart(context),
                buildSettingPart(context),
                SizedBox(height: 30),
              ],
            ))));
  }

  Widget buildMeetingInfoPart(BuildContext context) {
    return MeetingSettingGroup(
      title: getAppLocalizations().meetingTime,
      iconColor: AppColors.color_337eff,
      iconData: IconFont.icon_time,
      children: [
        buildStartTime(
            startTime: startTime,
            endTime: endTime,
            selectTimeCallback: (dateTime) {
              setState(() {
                startTime = dateTime;
                recurringRule.startTime = dateTime;
                if (startTime.millisecondsSinceEpoch >=
                    endTime.millisecondsSinceEpoch) {
                  endTime = startTime.add(Duration(minutes: 30));
                } else if (endTime.millisecondsSinceEpoch -
                        startTime.millisecondsSinceEpoch >
                    oneDay) {
                  endTime = startTime.add(Duration(minutes: 30));
                }
              });
            }),
        buildEndTime(
            startTime: startTime,
            endTime: endTime,
            selectTimeCallback: (dateTime) {
              setState(() {
                endTime = dateTime;
              });
            }),
        buildTimezone(),
        if (isEditAll() != false) buildRepeat(),
        if (recurringRule.type != NEMeetingRecurringRuleType.no &&
            isEditAll() != false)
          buildRepeatEndDate(),
      ],
    );
  }

  /// 构建安全模块
  Widget buildSecurityPart(BuildContext context) {
    return MeetingSettingGroup(
      title: getAppLocalizations().meetingSecurity,
      iconData: IconFont.icon_security,
      iconColor: AppColors.color_1BB650,
      children: [
        buildPwd(),
        ValueListenableBuilder(
            valueListenable: meetingPwdSwitch,
            builder: (context, value, child) =>
                Visibility(child: buildPwdInput(), visible: value)),
        if (context.isWaitingRoomEnabled)
          MeetingSwitchItem(
              key: MeetingValueKey.scheduleWaitingRoom,
              title: NEMeetingUIKit.instance
                  .getUIKitLocalizations()
                  .waitingRoomEnable,
              content: getAppLocalizations().meetingWaitingRoomHint,
              valueNotifier: enableWaitingRoom,
              onChanged: (value) {
                enableWaitingRoom.value = value;
              }),
        if (context.isGuestJoinEnabled)
          MeetingSwitchItem(
              key: MeetingValueKey.scheduleEnableGuestJoin,
              title: getAppLocalizations().meetingGuestJoin,
              valueNotifier: enableGuestJoin,
              contentBuilder: (enable) => Text(
                    enable
                        ? getAppLocalizations().meetingGuestJoinSecurityNotice
                        : getAppLocalizations().meetingGuestJoinEnableTip,
                    style: TextStyle(
                      fontSize: 12,
                      color: enable
                          ? AppColors.color_f29900
                          : AppColors.color_8D90A0,
                    ),
                  ),
              onChanged: (value) => enableGuestJoin.value = value),
      ],
    );
  }

  /// 构建设置模块
  Widget buildSettingPart(BuildContext context) {
    return MeetingSettingGroup(
      title: NEMeetingUIKit.instance.getUIKitLocalizations().settings,
      iconColor: AppColors.color_8D90A0,
      iconData: IconFont.icon_setting,
      children: [
        MeetingSwitchItem(
          key: MeetingValueKey.scheduleAttendeeAudio,
          title: getAppLocalizations().meetingAttendeeAudioOff,
          valueNotifier: attendeeAudioAutoOff,
          onChanged: (value) => attendeeAudioAutoOff.value = value,
        ),
        ValueListenableBuilder(
            valueListenable: attendeeAudioAutoOff,
            builder: (context, value, child) {
              if (value) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildRadio(
                        value: false,
                        padding: EdgeInsets.only(left: 32, right: 16),
                        title: getAppLocalizations()
                            .meetingAttendeeAudioOffAllowOn,
                        groupValue: attendeeAudioAutoOffNotAllowSelfOn,
                        onChanged: (_) {
                          attendeeAudioAutoOffNotAllowSelfOn = false;
                          setState(() {});
                        }),
                    buildRadio(
                        value: true,
                        padding: EdgeInsets.only(
                            left: 32, right: 16, top: 9, bottom: 9),
                        title: getAppLocalizations()
                            .meetingAttendeeAudioOffNotAllowOn,
                        groupValue: attendeeAudioAutoOffNotAllowSelfOn,
                        onChanged: (_) {
                          attendeeAudioAutoOffNotAllowSelfOn = true;
                          setState(() {});
                        }),
                  ],
                );
              }
              return SizedBox.shrink();
            }),
        MeetingSwitchItem(
          key: MeetingValueKey.scheduleEnableJoinBeforeHost,
          title: getAppLocalizations().meetingJoinBeforeHost,
          valueNotifier: enableJoinBeforeHost,
          onChanged: (value) => enableJoinBeforeHost.value = value,
        ),
        if (isLiveEnabled)
          MeetingSwitchItem(
            key: MeetingValueKey.scheduleLiveSwitch,
            title: getAppLocalizations().meetingLiveOn,
            valueNotifier: liveSwitch,
            onChanged: (value) => liveSwitch.value = value,
          ),
        ValueListenableBuilder(
            valueListenable: liveSwitch,
            builder: (context, value, child) {
              if (value) {
                return buildLiveLevel();
              }
              return SizedBox.shrink();
            }),
        if (context.interpretationConfig.enable)
          MeetingSwitchItem(
            key: MeetingValueKey.scheduleEnableInterpretation,
            title:
                NEMeetingUIKit.instance.getUIKitLocalizations().interpretation,
            valueNotifier: enableInterpretation,
            onChanged: (value) => enableInterpretation.value = value,
          ),
        ValueListenableBuilder(
            valueListenable: enableInterpretation,
            builder: (context, value, child) {
              if (value) {
                return buildInterpreters();
              }
              return SizedBox.shrink();
            }),
      ],
    );
  }

  /// 是不是自己
  bool isMySelf(String? uuid) => uuid == AuthManager().accountId;

  Widget buildRadio({
    required String title,
    required bool value,
    required bool groupValue,
    required Function(bool?)? onChanged,
    double height = 40,
    EdgeInsetsGeometry? padding,
  }) {
    return NEGestureDetector(
      child: Container(
        padding: padding,
        height: height,
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
                    return AppColors.color_337EFF.withOpacity(
                      states.contains(MaterialState.disabled) ? 0.5 : 1.0,
                    );
                  }
                  return AppColors.colorE6E7EB;
                }),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColors.color_53576A,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none))),
          ],
        ),
      ),
      onTap: () => onChanged?.call(value),
    );
  }

  /// 会议标题
  Widget buildSubject(
      {required FocusNode focusNode, TextEditingController? controller}) {
    return MeetingSettingGroup(children: [
      Row(
        children: [
          SizedBox(width: 16),
          Text(
            getAppLocalizations().meetingName,
            style: TextStyle(
                color: AppColors.color_1E1E27,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 26.w),
          Expanded(
              child: TextField(
            key: MeetingValueKey.scheduleSubject,
            autofocus: false,
            focusNode: focusNode,
            controller: controller,
            keyboardAppearance: Brightness.light,
            textAlign: TextAlign.left,
            inputFormatters: [
              LengthLimitingTextInputFormatter(meetingSubjectLengthMax),
            ],
            onChanged: (value) {
              setState(() {});
            },
            decoration: InputDecoration(
                hintText: '${getAppLocalizations().meetingEnterTopic}',
                hintStyle:
                    TextStyle(fontSize: 14, color: AppColors.color_53576A),
                border: InputBorder.none,
                suffixIcon: focusNode.hasFocus == true &&
                        !TextUtil.isEmpty(controller?.text)
                    ? ClearIconButton(
                        key: MeetingValueKey.clearInputMeetingSubject,
                        onPressed: () {
                          controller?.clear();
                          setState(() {});
                        })
                    : SizedBox.shrink()),
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(color: AppColors.color_53576A, fontSize: 14),
          )),
        ],
      )
    ]);
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
            '${getAppLocalizations().meetingAttendees}（$size）',
        scheduledMemberList: scheduledMemberList,
        myUserUuid: myUserUuid,
        ownerUuid: meetingItem.ownerUserUuid,
        addActionClick: () => DialogUtils.showContactsAddPopup(
          context: context,
          titleBuilder: (int size) =>
              '${getAppLocalizations().meetingAddAttendee}${size > 0 ? '（$size）' : ''}',
          scheduledMemberList: scheduledMemberList,
          myUserUuid: myUserUuid,
          itemClickCallback: handleClickCallback,
        ),
        loadMoreContacts: loadMoreContacts,
        getMemberSubTitles: (NEScheduledMember member) {
          if (enableInterpretation.value &&
              interpreterListController?.hasInterpreter(member.userUuid) ==
                  true) {
            return [
              NEMeetingUIKit.instance.getUIKitLocalizations().interpInterpreter,
            ];
          }
          return [];
        },
        onWillRemoveAttendee: handleOnWillRemoveAttendee,
      ).then((value) {
        if (mounted) setState(() {});
      }),
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16, top: 16),
        decoration: _boxDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MeetingArrowItem(
                padding: EdgeInsets.only(left: 16, right: 16),
                title: getAppLocalizations().meetingAttendees,
                content: getAppLocalizations()
                    .meetingAttendeeCount('${scheduledMemberList.length}')),
            buildAttendeesList(),
          ],
        ),
      ),
    );
  }

  /// 删除成员时，检查是否为译员，如果是译员，需要二次确认
  Future<bool> handleOnWillRemoveAttendee(String userId) async {
    if (enableInterpretation.value &&
        interpreterListController?.hasInterpreter(userId) == true) {
      final willRemove = await showConfirmDialog2(
            message: (context) =>
                context.meetingUiLocalizations.interpRemoveMemberInInterpreters,
            cancelLabel: (context) =>
                context.meetingUiLocalizations.globalCancel,
            okLabel: (context) => context.meetingUiLocalizations.globalDelete,
            okLabelColor: AppColors.colorFE3B30,
          ) ==
          true;
      if (willRemove) {
        interpreterListController?.removeInterpreterByUserId(userId);
      }
      return willRemove;
    }
    return true;
  }

  /// 构建参会者列表widget
  Widget buildAttendeesList() {
    return Container(
      height: 48,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Row(
        children: [
          NEGestureDetector(
            onTap: () => DialogUtils.showContactsAddPopup(
              context: context,
              titleBuilder: (int size) =>
                  '${getAppLocalizations().meetingAddAttendee}${size > 0 ? '（$size）' : ''}',
              scheduledMemberList: scheduledMemberList,
              myUserUuid: NEMeetingKit.instance
                      .getAccountService()
                      .getAccountInfo()
                      ?.userUuid ??
                  '',
              itemClickCallback: handleClickCallback,
            ).then((value) {
              if (mounted) setState(() {});
            }),
            child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.colorF2F2F5,
                ),
                child:
                    Icon(Icons.add, size: 16, color: AppColors.color_999999)),
          ),
          const SizedBox(width: 14),
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
                  showRoleIcon: isMySelf(contactList[index].userUuid),
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

  Widget buildStartTime(
      {required DateTime startTime,
      required DateTime endTime,
      required Function(DateTime dateTime) selectTimeCallback}) {
    var now = DateTime.now();
    var initDate = DateTime(now.year, now.month, now.day,
        now.minute > 30 ? now.hour + 1 : now.hour, now.minute <= 30 ? 30 : 0);
    return buildTime(getAppLocalizations().meetingStartTime, startTime,
        initDate, null, MeetingValueKey.scheduleStartTime, selectTimeCallback);
  }

  Widget buildEndTime(
      {required DateTime startTime,
      required DateTime endTime,
      required Function(DateTime dateTime) selectTimeCallback}) {
    return buildTime(
        getAppLocalizations().meetingEndTime,
        endTime,
        startTime.add(Duration(minutes: _minuteInterval)),
        startTime.add(Duration(days: 1)),
        MeetingValueKey.scheduleEndTime,
        selectTimeCallback);
  }

  Widget buildTime(
      String itemTitle,
      DateTime showTime,
      DateTime minTime,
      DateTime? maxTime,
      ValueKey key,
      Function(DateTime dateTime) selectTimeCallback) {
    return ValueListenableBuilder(
        valueListenable: timezoneNotifier,
        builder: (context, timezone, child) {
          final transferDate = convertTimezoneDateTime(showTime, timezone);
          final transferMinTime = convertTimezoneDateTime(minTime, timezone);
          DateTime? transferMaxTime;
          if (maxTime != null) {
            transferMaxTime = convertTimezoneDateTime(maxTime, timezone);
          }
          return MeetingArrowItem(
            key: key,
            title: itemTitle,
            content: MeetingTimeUtil.timeFormatWithMinute(transferDate),
            onTap: () {
              _showCupertinoDatePicker(
                  transferMinTime,
                  transferMaxTime,
                  transferDate,
                  (dateTime) => selectTimeCallback
                      .call(convertToCurrentDateTime(dateTime, timezone)));
            },
          );
        });
  }

  /// 将本地时间转化为时区时间
  DateTime convertTimezoneDateTime(DateTime dateTime, NETimezone? timezone) {
    final transferTime = TimezonesUtil.convertTimezoneDateTime(
        dateTime.millisecondsSinceEpoch, timezone);
    return DateTime.fromMillisecondsSinceEpoch(transferTime);
  }

  /// 将时区时间转化为本地时间
  DateTime convertToCurrentDateTime(DateTime dateTime, NETimezone? timezone) {
    final transferTime = TimezonesUtil.convertToLocalDateTime(
        dateTime.millisecondsSinceEpoch, timezone);
    return DateTime.fromMillisecondsSinceEpoch(transferTime);
  }

  /// 构建时区选择
  Widget buildTimezone() {
    return ValueListenableBuilder(
        valueListenable: timezoneNotifier,
        builder: (context, NETimezone? timezone, child) {
          return MeetingArrowItem(
            title: getAppLocalizations().meetingTimezone,
            content: '${timezone?.time ?? ''} ${timezone?.zone ?? ''}',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return TimezonePage(timezoneNotifier: timezoneNotifier);
              }));
            },
          );
        });
  }

  Widget buildRepeat() {
    return MeetingArrowItem(
      title: getAppLocalizations().meetingRepeat,
      content: getRepeatText(),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ScheduleMeetingRepeatRoute(recurringRule,
              startTime.millisecondsSinceEpoch, isEditAll() != null);
        })).then((value) => setState(() {}));
      },
    );
  }

  String getRepeatText() {
    switch (recurringRule.type) {
      case NEMeetingRecurringRuleType.no:
        return getAppLocalizations().meetingNoRepeat;
      case NEMeetingRecurringRuleType.day:
        return getAppLocalizations().meetingRepeatEveryday;
      case NEMeetingRecurringRuleType.weekday:
        return getAppLocalizations().meetingRepeatEveryWeekday;
      case NEMeetingRecurringRuleType.week:
        return getAppLocalizations().meetingRepeatEveryWeek;
      case NEMeetingRecurringRuleType.twoWeeks:
        return getAppLocalizations().meetingRepeatEveryTwoWeek;
      case NEMeetingRecurringRuleType.dayOfMonth:
        return getAppLocalizations().meetingRepeatEveryMonth;
      case NEMeetingRecurringRuleType.undefine:
        return getAppLocalizations().meetingNoRepeat;
      case NEMeetingRecurringRuleType.custom:
        return getAppLocalizations().meetingRepeatCustom;
    }
  }

  Widget buildEditRepeatMeetingTips() {
    return Container(
      padding: EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Flexible(
            child: Container(
              margin: EdgeInsets.only(left: 24, right: 8),
              height: 1,
              color: AppColors.color_f29900,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              getAppLocalizations().meetingRepeatEditTips,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.color_f29900),
            ),
          ),
          Flexible(
            child: Container(
              margin: EdgeInsets.only(left: 8, right: 24),
              height: 1,
              color: AppColors.color_f29900,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRepeatEndDate() {
    return MeetingArrowItem(
      title: getAppLocalizations().meetingRepeatEndAt,
      content: getRepeatEndText(),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ScheduleMeetingRepeatEndRoute(recurringRule);
        })).then((value) => setState(() {}));
      },
    );
  }

  String getRepeatEndText() {
    switch (recurringRule.endRule?.type) {
      case NEMeetingRecurringEndRuleType.date:
        return (recurringRule.endRule?.date ?? '').replaceAll('/', '-');
      case NEMeetingRecurringEndRuleType.times:
        return getAppLocalizations()
            .meetingRepeatLimitTimes(recurringRule.endRule?.times ?? 0);
      case NEMeetingRecurringEndRuleType.undefine:
        return '';
      case null:
        return '';
    }
  }

  /// null为非编辑模式
  /// true为编辑所有
  /// false为编辑单次
  bool? isEditAll() {
    return null;
  }

  /// 时间选择最小跨度，测试的时候调低
  final _minuteInterval = 30;

  void _showCupertinoDatePicker(
    final DateTime minTime,
    DateTime? maxTime,
    DateTime? initialDateTime,
    Function(DateTime dateTime) selectTimeCallback,
  ) {
    if (initialDateTime != null) {
      if (initialDateTime.isBefore(minTime)) {
        initialDateTime = minTime;
      } else if (maxTime != null && initialDateTime.isAfter(maxTime)) {
        initialDateTime = maxTime;
      }
    }
    var selectTime = minTime;
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            _timeSelectTitle(),
            Container(
                color: AppColors.white,
                height: MediaQuery.of(context).copyWith().size.height / 3,
                child: CupertinoDatePicker(
                  minimumDate: minTime,
                  maximumDate: maxTime,
                  minuteInterval: _minuteInterval,
                  use24hFormat: true,
                  initialDateTime: initialDateTime ?? minTime,
                  backgroundColor: AppColors.white,
                  onDateTimeChanged: (DateTime time) {
                    selectTime = time;
                  },
                )),
          ]);
        }).then((value) {
      if (value == 'done') {
        selectTimeCallback.call(selectTime);
      }
    });
  }

  Widget _timeSelectTitle() {
    return Container(
      height: 44,
      decoration: ShapeDecoration(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
              side: BorderSide(
                color: AppColors.colorF2F2F5,
              ),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(getAppLocalizations().globalCancel,
                  style:
                      TextStyle(fontSize: 14, color: AppColors.color_1f2329))),
          Text(getAppLocalizations().meetingChooseDate,
              style: TextStyle(fontSize: 17, color: AppColors.color_1f2329)),
          TextButton(
              onPressed: () {
                Navigator.pop(context, 'done');
              },
              child: Text(getAppLocalizations().globalComplete,
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.blue_337eff,
                      fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  void _generatePassword() {
    meetingPasswordController.text =
        (Random().nextInt(passwordRange) + basePassword).toString();
  }

  Widget buildPwd() {
    return MeetingSwitchItem(
        key: MeetingValueKey.schedulePwdSwitch,
        title: getAppLocalizations().meetingPassword,
        valueNotifier: meetingPwdSwitch,
        onChanged: (bool value) {
          setState(() {
            meetingPwdSwitch.value = value;
            if (meetingPwdSwitch.value &&
                TextUtil.isEmpty(meetingPasswordController.text)) {
              _generatePassword();
            }
          });
        });
  }

  Widget buildPwdInput() {
    return Container(
      height: 36,
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
            color: passwordFocusNode.hasFocus
                ? AppColors.blue_337eff
                : AppColors.colorE6E7EB,
            width: 1),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            key: MeetingValueKey.schedulePwdInput,
            autofocus: false,
            keyboardAppearance: Brightness.light,
            controller: meetingPasswordController,
            keyboardType: TextInputType.number,
            focusNode: passwordFocusNode,
            inputFormatters: [
              LengthLimitingTextInputFormatter(meetingPasswordLengthMax),
              FilteringTextInputFormatter.allow(RegExp(r'\d+')),
            ],
            onChanged: (value) {
              setState(() {});
            },
            decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                hintText:
                    '${getAppLocalizations().meetingEnterSixDigitPassword}',
                hintStyle:
                    TextStyle(fontSize: 14, color: AppColors.color_999999),
                // 文字垂直居中
                isCollapsed: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                )),
            style: TextStyle(
              color: AppColors.color_1E1F27,
              fontSize: 14,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        !passwordFocusNode.hasFocus ||
                TextUtil.isEmpty(meetingPasswordController.text)
            ? SizedBox.shrink()
            : ClearIconButton(
                key: MeetingValueKey.clearInputMeetingPassword,
                padding: EdgeInsets.only(right: 16, top: 6, bottom: 6, left: 6),
                onPressed: () {
                  meetingPasswordController.clear();
                })
      ]),
    );
  }

  Widget buildLiveLevel() {
    return MeetingSwitchItem(
        key: MeetingValueKey.scheduleLiveLevel,
        title: getAppLocalizations().meetingLiveLevelTip,
        valueNotifier: liveLevelSwitch,
        padding: EdgeInsets.only(
          left: 32,
          right: 10,
        ),
        minHeight: 40,
        titleTextStyle: TextStyle(
            fontSize: 14,
            color: AppColors.color_53576A,
            fontWeight: FontWeight.w400),
        onChanged: (bool value) {
          liveLevelSwitch.value = value;
        });
  }

  Widget buildInterpreters() {
    interpreterListController ??= InterpreterListController();
    return ListenableBuilder(
        listenable: interpreterListController!,
        builder: (context, _) {
          return MeetingArrowItem(
            minHeight: 40,
            padding: EdgeInsets.only(left: 32, right: 16),
            title: NEMeetingUIKit.instance
                .getUIKitLocalizations()
                .interpInterpreter,
            titleTextStyle: TextStyle(
                fontSize: 14,
                color: AppColors.color_53576A,
                fontWeight: FontWeight.w400),
            content: getAppLocalizations()
                .meetingAttendeeCount('${interpreterListController!.size}'),
            onTap: () {
              if (interpreterListController!.capacity == 0) {
                interpreterListController!.addInterpreter(InterpreterInfo());
              }
              PreMeetingInterpreterListPage.show(
                context,
                interpreterListController!,
                onWillRemoveInterpreter: handleOnWillRemoveInterpreter,
              );
            },
          );
        });
  }

  /// 删除译员时，如果参会者列表存在该用户，弹窗询问是否一并移除
  Future<bool> handleOnWillRemoveInterpreter(
      InterpreterInfo interpreter) async {
    const _kRemoveOnce = 0, _kRemoveTwice = 1;
    final userId = interpreter.userId;
    int? type = _kRemoveOnce;
    if (userId != null &&
        scheduledMemberList.any((element) => element.userUuid == userId)) {
      type = await showCupertinoModalPopup<int>(
        context: context,
        routeSettings: RouteSettings(name: 'RemoveInterpreterAsMember'),
        builder: (context) {
          return NEMeetingUIKitLocalizationsScope(
              builder: (context, localizations, _) {
            return CupertinoActionSheet(
              actions: [
                CupertinoActionSheetAction(
                  child: Text(
                    localizations.interpRemoveInterpreterOnly,
                    style: TextStyle(color: AppColors.color_337eff),
                  ),
                  onPressed: () {
                    Navigator.pop(context, _kRemoveOnce);
                  },
                ),
                CupertinoActionSheetAction(
                  child: Text(localizations.interpRemoveInterpreterInMembers,
                      style: TextStyle(color: AppColors.colorFE3B30)),
                  onPressed: () {
                    Navigator.pop(context, _kRemoveTwice);
                  },
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text(
                  localizations.globalCancel,
                  style: TextStyle(color: AppColors.color_337eff),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            );
          });
        },
      );
    }
    if (type == _kRemoveTwice && mounted) {
      setState(() {
        scheduledMemberList
            .removeWhere((element) => element.userUuid == userId);
      });
    }
    return type != null;
  }

  @override
  Future<bool?> shouldPop() {
    return showCupertinoDialog<bool>(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(getAppLocalizations().meetingLeaveEditTips),
            content: Text(getAppLocalizations().meetingLeaveEditTips2),
            actions: [
              CupertinoDialogAction(
                child: Text(getAppLocalizations().meetingEditContinue,
                    style: TextStyle(color: AppColors.black_333333)),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              CupertinoDialogAction(
                child: Text(getAppLocalizations().meetingEditLeave,
                    style: TextStyle(color: AppColors.blue_337eff)),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              )
            ],
          );
        });
  }

  /// 默认添加当前用户为参会主持人
  void addMyselfToDefaultAttendee() {
    final accountInfo =
        NEMeetingKit.instance.getAccountService().getAccountInfo();
    final userUuid = accountInfo?.userUuid ?? '';
    scheduledMemberList.add(NEScheduledMember(
        role: MeetingRoles.kHost,
        userUuid: userUuid,
        contact: NEContact(
            name: accountInfo?.nickname ?? '',
            avatar: accountInfo?.avatar,
            userUuid: userUuid)));
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

    /// 移除找不到通讯录信息的用户
    scheduledMemberList.removeWhere(
        (uuid) => result.data?.notFoundList.contains(uuid) == true);

    /// 更新通讯录信息
    result.data?.foundList.forEach((contact) {
      final scheduleMember = scheduledMemberList
          .where((element) => element.userUuid == contact.userUuid)
          .firstOrNull;
      scheduleMember?.contact = contact;
    });
  }

  @override
  void dispose() {
    meetingPasswordController.dispose();
    meetingSubjectController.dispose();
    interpreterListController?.dispose();
    subjectFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  /// 选择人员回调
  /// [contact] 选择的联系人
  /// [currentSelectedSize] 当前已选择的人数
  /// 返回值为是否允许选择
  bool handleClickCallback(
      NEContact contact, int currentSelectedSize, String? maxSelectedTip) {
    /// 选择人数超限
    if (scheduledMemberList.length + currentSelectedSize >= _maxMembers) {
      ToastUtils.showToast(context, maxSelectedTip!);
      return false;
    }
    return true;
  }
}
