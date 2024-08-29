// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/auth/reset_initial_password.dart';
import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:nemeeting/channel/deep_link_manager.dart';
import 'package:nemeeting/global_state.dart';
import 'package:nemeeting/service/util/user_preferences.dart';
import 'package:nemeeting/utils/const_config.dart';
import 'package:nemeeting/utils/dialog_utils.dart';
import 'package:nemeeting/base/util/text_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/utils/meeting_string_util.dart';
import 'package:nemeeting/widget/meeting_network_notice.dart';
import 'package:nemeeting/widget/meeting_security_notice.dart';
import 'package:nemeeting/widget/ne_widget.dart';
import 'package:netease_common/netease_common.dart';
import 'package:netease_meeting_kit/meeting_core.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';
import 'package:nemeeting/pre_meeting/schedule_meeting_detail.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:nemeeting/utils/privacy_util.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/uikit/utils/nav_utils.dart';
import 'package:nemeeting/uikit/utils/router_name.dart';
import 'package:nemeeting/uikit/values/asset_name.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/uikit/values/dimem.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import '../channel/ne_platform_channel.dart';
import '../language/localizations.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../notify_message/notify_message.dart';

class HomePageRouteArguments {
  final ResetPasswordRequest? resetPasswordRequest;

  HomePageRouteArguments({this.resetPasswordRequest});
}

///会议中心
class HomePageRoute extends StatefulWidget {
  /// 是否为会中悬浮窗的背景，默认为 true
  final bool isPipMode;

  HomePageRoute({
    this.isPipMode = true,
  });

  @override
  State<StatefulWidget> createState() {
    return _HomePageRouteState();
  }
}

class _HomePageRouteState extends PlatformAwareLifecycleBaseState<HomePageRoute>
    with
        NEMeetingStatusListener,
        NEMeetingMessageChannelListener,
        NEAccountServiceListener,
        NEPreMeetingListener {
  List<NEMeetingItem> meetingList = <NEMeetingItem>[];

  List<MeetingItemGroup> meetingGroupList = <MeetingItemGroup>[];

  DateTime meetingStartDate = DateTime.now();

  ///默认是idle状态，会中内存会记录缓存中。当会议最小化是需要根据版本，不能放入SP，因为会被杀进程。会议需要重新进入。
  int meetingStatus = NEMeetingStatus.idle;

  /// 是否已经展示结束会议的dialog
  static bool isShowEndDialog = false;

  final streamSubscriptions = <StreamSubscription>[];

  late final meetingAccountService = NEMeetingKit.instance.getAccountService();
  final settingsService = NEMeetingKit.instance.getSettingsService();

  late final InMeetingPermissionRequestListener permissionRequestListener;

  @override
  void initState() {
    super.initState();
    NEMeetingKit.instance
        .getMeetingMessageChannelService()
        .addMeetingMessageChannelListener(this);

    handleMeetingSdk();
    getMeetingList();
    NEMeetingKit.instance.getPreMeetingService().addListener(this);

    permissionRequestListener = (String permissionName) {
      NEPlatformChannel().notifyInMeetingPermissionRequest(permissionName);
    };
    InMeetingPermissionUtils.addPermissionRequestListener(
        permissionRequestListener);

    /// 会议如果还未结束，只是等候室和房间切换状态，则正常进入会议不显示会议恢复弹框
    if (widget.isPipMode) return;

    UserPreferences().meetingInfo.then((meetingInfo) {
      if (TextUtil.isEmpty(meetingInfo) ||
          (NEMeetingKit.instance.getMeetingService().getCurrentMeetingInfo() !=
                  null &&
              (NEMeetingKit.instance.getMeetingService().getMeetingStatus() ==
                      NEMeetingStatus.inMeetingMinimized ||
                  NEMeetingKit.instance
                          .getMeetingService()
                          .getMeetingStatus() ==
                      NEMeetingStatus.inMeeting))) return;
      var info = jsonDecode(meetingInfo!) as Map?;
      if (info == null) return;
      var meetingNum = info['meetingNum'] as String?;
      if (meetingNum == null) return;
      var currentTime = info['currentTime'] as int;
      var startDate = DateTime.fromMillisecondsSinceEpoch(currentTime);
      var endDate = DateTime.now();
      var minutes = endDate.difference(startDate).inMinutes;
      if (minutes < 15) {
        showRecoverJoinMeetingDialog(meetingNum);
      } else {
        Alog.d(tag: tag, content: 'minutes >15 meeting info clean');
        UserPreferences().setMeetingInfo('');
      }
    });

    GlobalPreferences().isShakeAndOpenQrScanEnabled.then((value) {
      if (value) {
        Alog.d(tag: tag, content: 'isShakeAndOpenQrScanEnabled = $value');
        initAccelerometer();
      }
    });

    // prepareLottie();
    NEMeetingKit.instance
        .getMeetingMessageChannelService()
        .queryUnreadMessageList(settingsService.getAppNotifySessionId())
        .then((value) {
      if (value.data != null && value.data!.length > 0) {
        MeetingUtil.setUnreadNotifyMessageListenable(value.data!.length);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!resetInitialPasswordRequestHandled) {
      resetInitialPasswordRequestHandled = true;
      final arguments =
          ModalRoute.of(context)!.settings.arguments as HomePageRouteArguments?;
      if (arguments?.resetPasswordRequest != null) {
        postOnFrame(() {
          showResetInitialPasswordDialog(arguments!.resetPasswordRequest!);
        });
      }
    }
  }

  void handleMeetingSdk() {
    if (widget.isPipMode) return;
    NEMeetingKit.instance.getMeetingService().addMeetingStatusListener(this);
    NEMeetingKit.instance.getAccountService().addListener(this);
  }

  @override
  void onMeetingStatusChanged(NEMeetingEvent event) {
    meetingStatus = event.status;
    NEPlatformChannel().notifyMeetingStatusChanged(meetingStatus);
    setState(() {});
    switch (meetingStatus) {
      case NEMeetingStatus.disconnecting:
        switch (event.arg) {
          case NEMeetingCode.closeByHost:

            /// 主持人关闭会议
            showEndDialog(getAppLocalizations().meetingCloseByHost);
            break;

          case NEMeetingCode.authInfoExpired:

            /// 认证过期
            showAuthInfoExpiredDialog();
            break;

          case NEMeetingCode.endOfLife:

            /// 会议时长超限
            showEndDialog(getAppLocalizations().meetingEndOfLife);
            break;

          case NEMeetingCode.loginOnOtherDevice:

            /// 账号再其他设备入会
            showEndDialog(getAppLocalizations().meetingSwitchOtherDevice);
            break;

          case NEMeetingCode.syncDataError:

            /// 同步数据失败
            showEndDialog(getAppLocalizations().meetingSyncDataError);
            break;

          // case NEMeetingCode.removedByHost: /// 被主持人移除会议
          //   ToastUtils.showToast(context, getAppLocalizations().removedByHost);
          //   break;
        }
        UserPreferences().setMeetingInfo('');
        break;
      case NEMeetingStatus.inWaitingRoom:
      case NEMeetingStatus.inMeeting:
        var meetingInfo =
            NEMeetingKit.instance.getMeetingService().getCurrentMeetingInfo();
        saveMeetingInfo(meetingInfo);
        break;
      case NEMeetingStatus.connecting:
        break;
      default:
    }
  }

  @override
  void onMeetingItemInfoChanged(List<NEMeetingItem> data) {
    data.forEach((element) {
      if (element.status == NEMeetingItemStatus.init ||
          element.status == NEMeetingItemStatus.started ||
          element.status == NEMeetingItemStatus.ended) {
        final existIndex =
            meetingList.firstIndexOf((e) => e.meetingId == element.meetingId);
        if (existIndex >= 0) {
          meetingList[existIndex] = element;
        } else {
          /// 会议状态变更，且当前列表不存在该会议，则重新获取会议列表
          getMeetingList();
        }
      } else if (element.status.index >= NEMeetingItemStatus.cancel.index) {
        meetingList.removeWhere((e) =>
            e.meetingNum == element.meetingNum ||
            e.meetingId == element.meetingId);
      }
    });
    sortAndGroupData();
  }

  void getMeetingList() {
    NEMeetingKit.instance.getPreMeetingService().getMeetingList([
      NEMeetingItemStatus.init,
      NEMeetingItemStatus.started,
      NEMeetingItemStatus.ended,
    ]).then((NEResult<List<NEMeetingItem>> result) {
      if (result.code != HttpCode.success && result.data == null) {
        return;
      }
      meetingList.clear();
      meetingList.addAll(result.data!);
      sortAndGroupData();
    });
  }

  void showEndDialog(String content) {
    if (isShowEndDialog) return;
    isShowEndDialog = true;
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(getAppLocalizations().globalNotify),
              content: Text(content),
              actions: <Widget>[
                CupertinoDialogAction(
                    child: Text(getAppLocalizations().globalSure),
                    onPressed: () {
                      Navigator.of(context).pop();
                      isShowEndDialog = false;
                    })
              ],
            ));
  }

  void showRecoverJoinMeetingDialog(String meetingNum) {
    AppDialogUtils.showCommonDialog(
        context, '', getAppLocalizations().meetingRecover, () {
      NavUtils.closeCurrentState('cancel');
      UserPreferences().setMeetingInfo('');
    }, () async {
      NavUtils.closeCurrentState('ok');
      LoadingUtil.showLoading();
      String? lastUsedNickname =
          LocalHistoryMeetingManager().getLatestNickname(meetingNum);
      final result =
          await NEMeetingKit.instance.getMeetingService().joinMeeting(
        context,
        NEJoinMeetingParams(
          meetingNum: meetingNum,
          displayName: lastUsedNickname ?? MeetingUtil.getNickName(),
          watermarkConfig: buildNEWatermarkConfig(),
        ),
        await buildMeetingUIOptions(context: context),
        onPasswordPageRouteWillPush: () async {
          LoadingUtil.cancelLoading();
        },
        backgroundWidget: HomePageRoute(),
      );
      LoadingUtil.cancelLoading();
      if (!result.isSuccess()) {
        UserPreferences().setMeetingInfo('');
        ToastUtils.showToast(context, result.msg);
      }
    },
        acceptText: getAppLocalizations().globalResume,
        canBack: true,
        isContentCenter: true);
  }

  /// 排序和分组
  void sortAndGroupData() {
    var temp = <NEMeetingItem>[];
    temp.addAll(meetingList);

    /// step 1, filter meetingUniqueId is null, self insert data
    temp.removeWhere((value) => value.meetingId == null);

    /// step 2, sort
    temp.sort((value1, value2) {
      var t = value1.startTime - value2.startTime;
      // if (t == 0) {
      //   return value1.createTime - value2.createTime;
      // }
      return t;
    });

    /// step 3, group, high efficiency
    meetingList.clear();
    meetingGroupList.clear();
    if (temp.isNotEmpty) {
      var last = 0;
      temp.forEach((element) {
        var time = DateTime.fromMillisecondsSinceEpoch(element.startTime);
        var itemDay =
            DateTime(time.year, time.month, time.day).millisecondsSinceEpoch;
        if (itemDay == last) {
          meetingList.add(element);
          meetingGroupList.last.meetings.add(element);
        } else {
          last = itemDay;

          meetingGroupList.add(MeetingItemGroup(itemDay, [element]));

          meetingList.add(NEMeetingItem()..startTime = last);
          meetingList.add(element);
        }
      });
    }
    if (!mounted) return;
    setState(() {});
  }

  bool _initUpgradeAndDeepLink = false;

  void initUpgradeAndDeepLink() {
    if (_initUpgradeAndDeepLink) return;
    _initUpgradeAndDeepLink = true;
    DeepLinkManager().attach(context);
  }

  @override
  Widget buildWithPlatform(BuildContext context) {
    initUpgradeAndDeepLink();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: buildHomePage(),
      ),
    );
  }

  Widget buildHomePage() {
    return Column(
      children: <Widget>[
        buildUserProfileAndNotificationBtn(),
        buildNotificationBar(
            meetingAccountService.getAccountInfo()?.serviceBundle),
        Container(color: AppColors.globalBg, height: 1.h),
        SizedBox(height: 24.h),
        buildMainEntrance(),
        SizedBox(height: 24.h),
        buildMeetingListAndHistoryBtn(),
      ],
    );
  }

  Widget buildMainEntrance() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        buildItem(AssetName.createMeeting, getAppLocalizations().meetingHold,
            _onCreateMeeting),
        buildItem(AssetName.joinMeeting, getAppLocalizations().meetingJoin,
            _onJoinMeeting),
        buildItem(AssetName.scheduleMeeting,
            getAppLocalizations().meetingSchedule, _onSchedule),
      ],
    );
  }

  Widget buildMeetingListAndHistoryBtn() {
    return Expanded(
      child: Container(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            buildMeetingList(),
            buildHistoryBtn(),
          ],
        ),
      ),
      //buildMeetingList(),
    );
  }

  Widget buildHistoryBtn() {
    return Positioned(
      top: 0.h,
      right: 20.0.w,
      child: NEGestureDetector(
        child: Container(
          height: 32.h,
          child: Center(
            child: Container(
              height: 23.h,
              // alignment: Alignment.center,
              padding: EdgeInsets.only(left: 8.w, right: 8.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                color: meetingList.length > 0
                    ? AppColors.white
                    : AppColors.color_F5F6FA,
                border: Border.all(color: AppColors.globalBg, width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // 设置 Row 的大小适应其子元素的大小
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Text(
                      getAppLocalizations().historyMeeting,
                      style: TextStyle(
                          fontSize: 14.spMin,
                          height: 1,
                          color: AppColors.color_337EFF,
                          fontWeight: FontWeight.w500),
                      strutStyle: StrutStyle(
                        forceStrutHeight: true,
                        height: 1,
                        fontSize: 14.spMin,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Container(
                    margin:
                        EdgeInsets.only(bottom: Platform.isIOS ? 1.5.h : 0.5.h),
                    child: Icon(IconFont.iconyx_home_allowx_bold,
                        weight: 2,
                        size: 12.spMin,
                        color: AppColors.color_337EFF),
                  )
                ],
              ),
            ),
          ),
        ),
        onTap: _onHistoryMeeting,
      ),
    );
  }

  Widget buildUserProfileAndNotificationBtn() {
    return Container(
      key: MeetingValueKey.personalSetting,
      height: 64.h,
      alignment: Alignment.center,
      child: Row(
        children: <Widget>[
          SizedBox(width: 24),
          NEGestureDetector(
            child: NEAccountInfoBuilder(builder: (context, accountInfo, _) {
              return _buildUserProfile(accountInfo);
            }),
            onTap: () {
              _onSetting();
            },
          ),
          Spacer(),
          _buildNotificationBtn(),
          SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildUserProfile(NEAccountInfo accountInfo) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          NEMeetingAvatar.xlarge(
            key: MeetingValueKey.avatar,
            name: accountInfo.nickname,
            url: accountInfo.avatar,
          ),
          Container(
            margin: EdgeInsets.only(left: 16.w),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: Text(
                        StringUtil.truncate(accountInfo.nickname),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.spMin,
                          color: AppColors.black_222222,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.ltr,
                        key: MeetingValueKey.nickName,
                      )),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: (MediaQuery.of(context).size.width * 2 / 3)
                          .w, // 设置最大宽度为 300
                    ),
                    child: Container(
                      child: Text(
                        accountInfo.corpName ??
                            getAppLocalizations().settingDefaultCompanyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.spMin,
                          color: AppColors.color_8D90A0,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBtn() {
    return Stack(children: <Widget>[
      Container(
        key: MeetingValueKey.notifyCenter,
        padding: EdgeInsets.all(8),
        child: NEGestureDetector(
          onTap: () {
            Navigator.push(
                context,
                NEMeetingPageRoute(
                  builder: (context) => NEMeetingUIKitLocalizationsScope(
                    child: MeetingAppNotifyCenter(
                        sessionId: settingsService.getAppNotifySessionId(),
                        onClearAllMessage: () {
                          MeetingUtil.setUnreadNotifyMessageListenable(0);
                        }),
                  ),
                ));
          },
          child: Icon(
            IconFont.icon_alarm,
            size: 24,
            color: AppColors.color_53576A,
          ),
        ),
      ),
      Positioned(
          right: 0,
          top: 0,
          child: SafeValueListenableBuilder(
            valueListenable: MeetingUtil.getUnreadNotifyMessageListenable(),
            builder: (_, int value, __) => value > 0
                ? ClipOval(
                    child: Container(
                        height: 16,
                        constraints: BoxConstraints(
                          minWidth: 16,
                        ),
                        padding: EdgeInsets.only(left: 2, right: 2),
                        decoration: ShapeDecoration(
                            color: AppColors.color_F51D45, shape: Border()),
                        alignment: Alignment.center,
                        child: Text(
                          value > 99 ? '99+' : '$value',
                          strutStyle: StrutStyle(
                            forceStrutHeight: true,
                            height: 1,
                          ),
                          style: TextStyle(
                            fontSize: value > 99
                                ? 8
                                : value > 9
                                    ? 10
                                    : 11,
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w400,
                          ),
                        )))
                : Container(),
          )),
    ]);
  }

  void _onCreateMeeting() {
    // InMeetingMoreMenuUtil.showInMeetingDialog(NavUtils.navigatorKey.currentState!.context);
    NavUtils.pushNamed(context, RouterName.meetCreate);
  }

  void _onJoinMeeting() {
    NavUtils.pushNamed(context, RouterName.meetJoin);
  }

  void _onSetting() {
    NavUtils.pushNamed(context, RouterName.appSetting);
  }

  void _onHistoryMeeting() {
    NavUtils.pushNamed(context, RouterName.historyMeet);
  }

  void _onSchedule() {
    NavUtils.pushNamed(context, RouterName.scheduleMeeting).then((value) {
      if (value is NEMeetingItem) {
        meetingList
            .removeWhere((element) => element.meetingId == value.meetingId);
        meetingList.add(value);
        sortAndGroupData();
      }
    });
  }

  Widget buildMeetingList() {
    if (meetingList.isEmpty) {
      return Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: EdgeInsets.only(top: 64.h),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image(
                    image: AssetImage(
                      AssetName.emptyMeetingList,
                      // package: AssetName.package
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 24.h),
                    child: Text(
                      getAppLocalizations().meetingScheduleListEmpty,
                      style: TextStyle(
                          fontSize: 14.spMin,
                          color: AppColors.color_53576A,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none),
                    ),
                  ),
                ],
              ),
            ),
          ));
    } else {
      return ListView.builder(
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.only(left: 0, bottom: 20),
        itemCount: meetingGroupList.length,
        itemBuilder: (context, index) {
          var item = meetingGroupList[index];
          return StickyHeader(
            header: buildTimeTitle(item.time),
            content: buildMeetingItems(item.meetings),
          );
        },
      );
    }
  }

  Widget buildTimeTitle(int time) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    return Container(
      height: 32.h,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 20),
      color: AppColors.color_F5F6FA,
      child: Text.rich(TextSpan(children: [
        TextSpan(
            text:
                '${getTimeSuffix(dateTime)} ${MeetingStringUtil.getMonth(dateTime.month)}${dateTime.day < 10 ? '0' : ''}${dateTime.day}${getAppLocalizations().globalDay}',
            style: TextStyle(
                fontSize: 14.spMin, height: 1, color: AppColors.color_53576A))
      ])),
    );
  }

  String getTimeSuffix(DateTime dateTime) {
    var now = DateTime.now();
    var tomorrow = now.add(Duration(days: 1));
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return getAppLocalizations().meetingToday;
    } else if (dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day) {
      return getAppLocalizations().meetingTomorrow;
    }
    return '';
  }

  Widget buildMeetingItems(List<NEMeetingItem> items) {
    return Column(
      children: items
          .map((e) => Column(
                children: [
                  buildMeetingItem(e),
                  items.last != e ? line() : Container(),
                ],
              ))
          .toList(),
    );
  }

  Widget line() {
    return Container(
        height: 0.5,
        margin: EdgeInsets.only(left: 20.w),
        color: AppColors.color_F0F1F5);
  }

  Widget buildMeetingItem(NEMeetingItem item) {
    var valueKey = '${item.meetingId}&${item.meetingNum}';
    return NEGestureDetector(
      key: MeetingValueKey.dynamicValueKey(valueKey),
      child: Container(
          height: 84.h,
          padding: EdgeInsets.only(left: 20),
          color: AppColors.white,
          child: Stack(children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 230, // 设置最大宽度为 300
                                ),
                                child: Container(
                                  child: NEText(item.subject ?? '',
                                      style: TextStyle(
                                        fontSize: 18.spMin,
                                        color: AppColors.color_1E1F27,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.w500,
                                      )),
                                ),
                              ),
                              if (item.recurringRule.type !=
                                  NEMeetingRecurringRuleType.no)
                                SizedBox(width: 8.w),
                              if (item.recurringRule.type !=
                                  NEMeetingRecurringRuleType.no)
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 2.w,
                                      top: 4.h,
                                      right: 2.w,
                                      bottom: 2.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2.0),
                                    color: Color.fromRGBO(51, 126, 255, 0.1),
                                    border: Border.all(
                                        color:
                                            Color.fromRGBO(51, 126, 255, 0.2),
                                        width: 1.0.w),
                                  ),
                                  alignment: Alignment.center,
                                  child: NEText(
                                    ' ${getAppLocalizations().meetingRepeat} ',
                                    style: TextStyle(
                                        color: AppColors.color_337eff,
                                        height: 1,
                                        fontSize: 12.spMin),
                                  ),
                                ),
                            ]),
                      ),
                      SizedBox(height: 10.h),
                      Row(children: [
                        Text.rich(
                            key: MeetingValueKey.scheduleMeetingItemTitle,
                            TextSpan(children: [
                              TextSpan(
                                  text:
                                      '${MeetingTimeUtil.timeFormatHourMinute(DateTime.fromMillisecondsSinceEpoch(item.startTime))}',
                                  style: TextStyle(
                                      color: AppColors.color_3D3D3D,
                                      fontSize: 14.spMin)),
                              TextSpan(
                                  text:
                                      '-${MeetingTimeUtil.timeFormatHourMinute(DateTime.fromMillisecondsSinceEpoch(item.endTime))}',
                                  style: TextStyle(
                                      color: AppColors.color_3D3D3D,
                                      fontSize: 14.spMin)),
                              TextSpan(
                                  text: " | ",
                                  style: TextStyle(
                                      color: AppColors.color_CDCFD7,
                                      fontSize: 14.spMin)),
                              TextSpan(
                                  text:
                                      "${TextUtil.applyMask(item.meetingNum ?? "", "000-000-0000")}",
                                  style: TextStyle(
                                      color: AppColors.color_3D3D3D,
                                      fontSize: 14.spMin)),
                            ])),
                        Text(' | ',
                            style: TextStyle(
                                color: AppColors.color_CDCFD7,
                                fontSize: 14.spMin)),
                        Text('${MeetingStringUtil.getItemStatus(item.status)}',
                            style: TextStyle(
                                color: getItemStatusColor(item.status),
                                fontSize: 14.spMin))
                      ]),
                      MeetingValueKey.addTextWidgetValueKey(text: valueKey),
                    ],
                  ),
                ),
              ],
            ),
            Align(
                alignment: Alignment.centerRight,
                child: Container(
                    margin: EdgeInsets.only(right: 20),
                    child: Icon(IconFont.iconyx_allowx_2,
                        size: 14, color: AppColors.color_8D90A0))),
          ])),
      onTap: () {
        Navigator.of(context).push(NEMeetingPageRoute(
            settings: RouteSettings(name: ScheduleMeetingDetailRoute.routeName),
            builder: (context) {
              return ScheduleMeetingDetailRoute(item);
            }));
        //NavUtils.pushNamed(context, RouterName.scheduleMeetingDetail);
      },
    );
  }

  Color getItemStatusColor(NEMeetingItemStatus status) {
    if (status == NEMeetingItemStatus.started) {
      return AppColors.color_337eff;
    } else if (status == NEMeetingItemStatus.init) {
      return AppColors.color_FF7903;
    }
    return AppColors.color_999999;
  }

  Widget buildItem(String assetStr, String text, VoidCallback voidCallback) {
    return NEGestureDetector(
      onTap: voidCallback,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: Dimen.homeIconSize,
            height: Dimen.homeIconSize,
            child: Image(image: AssetImage(assetStr)),
          ),
          SizedBox(height: Dimen.homeIconGap),
          Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: AppColors.black_222222,
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w400))
        ],
      ),
    );
  }

  @override
  void onKickOut() {
    if (!mounted) return;
    ToastUtils.showToast(context, getAppLocalizations().authLoginOnOtherDevice,
        onDismiss: () {
      AuthManager().logout();
      NavUtils.toEntrance(context);
    });
  }

  @override
  void onAuthInfoExpired() {
    /// 当前处于会议中，会议会自动断开，原因是登录态过期，这里不需要弹框
    if (NEMeetingKit.instance.getMeetingService().getMeetingStatus() !=
        NEMeetingStatus.idle) return;
    showAuthInfoExpiredDialog();
  }

  @override
  void onReconnected() {
    getMeetingList();
  }

  bool isAuthInfoExpiredDialogShowing = false;

  void showAuthInfoExpiredDialog() {
    if (isAuthInfoExpiredDialogShowing) return;
    isAuthInfoExpiredDialogShowing = true;
    AuthManager().logout();
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(getAppLocalizations().globalNotify),
          content: Text(getAppLocalizations().authLoginTokenExpired),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(getAppLocalizations().globalSure),
              onPressed: () {
                NavUtils.toEntrance(context, rootNavigator: true);
              },
            )
          ],
        );
      },
    ).whenComplete(() => isAuthInfoExpiredDialogShowing = false);
  }

  @override
  void dispose() {
    PrivacyUtil.dispose();
    NEMeetingKit.instance.getMeetingService().removeMeetingStatusListener(this);
    NEMeetingKit.instance.getPreMeetingService().removeListener(this);
    NEMeetingKit.instance.getAccountService().removeListener(this);
    DeepLinkManager().detach(context);
    streamSubscriptions.forEach((element) {
      element.cancel();
    });
    InMeetingPermissionUtils.removePermissionRequestListener(
        permissionRequestListener);
    super.dispose();
  }

  void _setGlobalMeetingInfo(NEMeetingInfo? currentMeetingInfo) {
    var map = <String, dynamic>{
      'meetingNum': currentMeetingInfo?.meetingNum,
      'currentTime': MeetingTimeUtil.getCurrentTimeMilliseconds()
    };
    UserPreferences().setMeetingInfo(jsonEncode(map));
  }

  void saveMeetingInfo(NEMeetingInfo? meetingInfo) {
    _setGlobalMeetingInfo(meetingInfo);

    /// 记录在会 开始时间
    meetingStartDate = DateTime.now();
  }

  bool resetInitialPasswordRequestHandled = false;

  void showResetInitialPasswordDialog(ResetPasswordRequest request) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 24.h,
              ),
              Text(
                getAppLocalizations().authResetInitialPasswordDialogTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.spMin,
                  color: AppColors.black_222222,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 6.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Text(
                  getAppLocalizations().authResetInitialPasswordDialogMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.spMin,
                    color: AppColors.color_333333,
                  ),
                ),
              ),
              SizedBox(
                height: 22.h,
              ),
              Divider(
                height: 1.w,
                thickness: 1.w,
                color: AppColors.color_EDEEF0,
              ),
              IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          getAppLocalizations()
                              .authResetInitialPasswordDialogCancelLabel,
                          style: TextStyle(
                            fontSize: 15.spMin,
                            color: AppColors.color_333333,
                          ),
                        ),
                      ),
                    ),
                    VerticalDivider(
                      width: 1.w,
                      thickness: 1.w,
                      color: AppColors.color_EDEEF0,
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed(
                              RouterName.resetInitialPassword,
                              arguments: request);
                        },
                        child: Text(
                          getAppLocalizations()
                              .authResetInitialPasswordDialogOKLabel,
                          style: TextStyle(
                            fontSize: 15.spMin,
                            color: AppColors.blue_337eff,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void onSessionMessageRecentChanged(List<NEMeetingRecentSession> messages) {
    int? _unreadCount = messages
        .takeWhile((value) =>
            value.sessionId == settingsService.getAppNotifySessionId())
        .lastOrNull
        ?.unreadCount;
    if (_unreadCount != null) {
      MeetingUtil.setUnreadNotifyMessageListenable(_unreadCount);
    }
  }

  void initAccelerometer() {
    //加速度 受重力影响
    int value = 10;
    streamSubscriptions.add(userAccelerometerEventStream().listen((event) {
      if (event.x.abs() > value || event.y.abs() > value) {
        Alog.d(
            tag: tag,
            content: 'accelerometer trigger x = ${event.x}, '
                'y = ${event.y}, z = ${event.z}, value = $value, '
                'isQrScanPagePushed = ${GlobalState.isQrScanPagePushed}');
        if (!GlobalState.isQrScanPagePushed) {
          NavUtils.pushNamed(context, RouterName.qrScan).then((value) {
            GlobalState.isQrScanPagePushed = true;
          });
        }
      }
    }));
  }

  /// 通知栏
  /// [serviceBundle] 服务包信息
  /// [connected] 网络是否连接
  /// [child] 子组件
  ///
  Widget buildNotificationBar(NEServiceBundle? serviceBundle) {
    if (serviceBundle?.isExpired == true) {
      return MeetingAppNotificationBar(
        notification: NEMeetingAppNoticeTip(
          content: serviceBundle?.expireTip,
          time: serviceBundle?.expireTimestamp ?? 0,
        ),
      );
    } else {
      return ConnectivityChangedBuilder(builder: (context, connected, child) {
        return connected
            ? MeetingAppNotificationBar()
            : MeetingNetworkNotificationBar();
      });
    }
  }
}

class MeetingItemGroup {
  final int time;
  final List<NEMeetingItem> meetings;

  MeetingItemGroup(this.time, this.meetings);
}
