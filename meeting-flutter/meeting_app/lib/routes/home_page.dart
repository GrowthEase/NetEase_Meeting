// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/application.dart';
import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:nemeeting/channel/deep_link_manager.dart';
import 'package:nemeeting/routes/auth/reset_initial_password.dart';
import 'package:nemeeting/service/config/app_config.dart';
import 'package:nemeeting/service/util/user_preferences.dart';
import 'package:nemeeting/setting/personal_setting.dart';
import 'package:nemeeting/utils/const_config.dart';
import 'package:nemeeting/utils/dialog_utils.dart';
import 'package:nemeeting/base/util/text_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/utils/meeting_string_util.dart';
import 'package:nemeeting/widget/meeting_network_notice.dart';
import 'package:nemeeting/widget/meeting_security_notice.dart';
import 'package:netease_common/netease_common.dart';
import 'package:netease_meeting_core/meeting_service.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import 'package:nemeeting/pre_meeting/schedule_meeting_detail.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:nemeeting/utils/privacy_util.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/model/account_app_info.dart';
import 'package:nemeeting/service/repo/accountinfo_repo.dart';
import 'package:nemeeting/uikit/utils/nav_utils.dart';
import 'package:nemeeting/uikit/utils/router_name.dart';
import 'package:nemeeting/uikit/values/asset_name.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/uikit/values/dimem.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import 'package:lottie/lottie.dart';

import '../channel/ne_platform_channel.dart';
import '../language/localizations.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../notify_message/notify_message.dart';
import '../service/model/security_notice_info.dart';

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

class _HomePageRouteState extends LifecycleBaseState<HomePageRoute>
    with MeetingAppLocalizationsMixin
    implements
        NEMeetingAuthListener,
        NEMeetingMessageSessionListener,
        NEMeetingInviteListener {
  late PageController _pageController;
  int _currentIndex = 0;

  NEMeetingStatusListener? _meetingStatusListener;

  List<NEMeetingItem> meetingList = <NEMeetingItem>[];

  late ScheduleCallback<List<NEMeetingItem>> scheduleCallback;
  AccountAppInfo? _accountAppInfo;
  bool bCanPress = true;
  bool vCanPress = true; //虚拟背景防暴击

  late ValueNotifier<int> _evaluationIndex;

  ValueListenable<int> get evaluationSelectedIndex => _evaluationIndex;
  late ValueNotifier<int> _evaluationInputLength;

  ValueListenable<int> get evaluationInputStringLength =>
      _evaluationInputLength;
  final FocusNode _focusNode = FocusNode();
  String _evaluationContent = "";
  DateTime meetingStartDate = DateTime.now();
  NEMeetingInfo? _evaluateMeetingInfo;

  ///默认是idle状态，会中内存会记录缓存中。当会议最小化是需要根据版本，不能放入SP，因为会被杀进程。会议需要重新进入。
  int meetingStatus = NEMeetingEvent.idle;

  /// NPS弹框是否展示
  static bool isShowNPS = false;

  /// 是否已经展示结束会议的dialog
  static bool isShowEndDialog = false;

  final streamSubscriptions = <StreamSubscription>[];

  late final meetingAccountService = NEMeetingKit.instance.getAccountService();

  @override
  void initState() {
    super.initState();
    NEMeetingKit.instance.addReceiveSessionMessageListener(this);
    _pageController = PageController(initialPage: _currentIndex);
    lifecycleListen(AuthManager().authInfoStream(), (event) {
      setState(() {});
    });
    AccountInfoRepo().getAccountAppInfo().then((result) {
      if (mounted && result.code == HttpCode.success) {
        setState(() {
          _accountAppInfo = result.data;
        });
      }
    });

    handleMeetingSdk();
    scheduleMeeting();

    /// 会议如果还未结束，只是等候室和房间切换状态，则正常进入会议不显示会议恢复弹框
    if (widget.isPipMode) return;

    UserPreferences().meetingInfo.then((meetingInfo) {
      if (TextUtil.isEmpty(meetingInfo) ||
          (NEMeetingUIKit().getCurrentMeetingInfo() != null &&
              (NEMeetingUIKit().getMeetingStatus().event ==
                      NEMeetingEvent.inMeetingMinimized ||
                  NEMeetingUIKit().getMeetingStatus().event ==
                      NEMeetingEvent.inMeeting))) return;
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

    _evaluationIndex = ValueNotifier(-1);
    _evaluationInputLength = ValueNotifier(0);
    // prepareLottie();
    NEMeetingKit.instance
        .queryUnreadMessageList(SDKConfig.current.appNotifySessionId)
        .then((value) {
      if (value.data != null && value.data!.length > 0) {
        MeetingUtil.setUnreadNotifyMessageListenable(value.data!.length);
      }
    });
    EventBus().subscribe(NEMeetingUIEvents.flutterInvitedChanged, (arg) {
      var meetingInfo = NEMeetingUIKit().getCurrentMeetingInfo();
      final CardData? cardData = arg.cardData;
      if (meetingInfo == null && arg.type != InviteJoinActionType.reject) {
        handleEvent(cardData, arg.type == InviteJoinActionType.audioAccept);
      }
    });

    /// 会议监听呼叫事件
    NEMeetingKit.instance.getMeetingInviteService().addEventListener(this);
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
    _meetingStatusListener ??= (status) {
      meetingStatus = status.event;
      NEPlatformChannel().notifyMeetingStatusChanged(meetingStatus);
      setState(() {});
      switch (meetingStatus) {
        case NEMeetingEvent.disconnecting:
          switch (status.arg) {
            case NEMeetingCode.closeByHost:

              /// 主持人关闭会议
              showEndDialog(meetingAppLocalizations.meetingCloseByHost);
              break;

            case NEMeetingCode.authInfoExpired:

              /// 认证过期
              showAuthInfoExpiredDialog();
              break;

            case NEMeetingCode.endOfLife:

              /// 会议时长超限
              showEndDialog(meetingAppLocalizations.meetingEndOfLife);
              break;

            case NEMeetingCode.loginOnOtherDevice:

              /// 账号再其他设备入会
              showEndDialog(meetingAppLocalizations.meetingSwitchOtherDevice);
              break;

            case NEMeetingCode.syncDataError:

              /// 同步数据失败
              showEndDialog(meetingAppLocalizations.meetingSyncDataError);
              break;

            // case NEMeetingCode.removedByHost: /// 被主持人移除会议
            //   ToastUtils.showToast(context, meetingAppLocalizations.removedByHost);
            //   break;
          }
          UserPreferences().setMeetingInfo('');
          break;
        case NEMeetingEvent.inWaitingRoom:
        case NEMeetingEvent.inMeeting:
          var meetingInfo = NEMeetingUIKit().getCurrentMeetingInfo();
          saveMeetingInfo(meetingInfo);
          break;
        case NEMeetingEvent.connecting:
          break;
        default:
      }
    };
    NEMeetingUIKit().addListener(_meetingStatusListener!);
    NEMeetingKit.instance.addAuthListener(this);
  }

  void scheduleMeeting() {
    getMeetingList();
    scheduleCallback = (List<NEMeetingItem> data, bool incremental) {
      if (incremental) {
        data.forEach((element) {
          if (element.state == NEMeetingState.init ||
              element.state == NEMeetingState.started ||
              element.state == NEMeetingState.ended) {
            final existIndex = meetingList
                .firstIndexOf((e) => e.meetingId == element.meetingId);
            if (existIndex >= 0) {
              meetingList[existIndex] = element;
            } else {
              /// 会议状态变更，且当前列表不存在该会议，则重新获取会议列表
              getMeetingList();
            }
          } else if (element.state.index >= NEMeetingState.cancel.index) {
            meetingList.removeWhere((e) =>
                e.meetingNum == element.meetingNum ||
                e.meetingId == element.meetingId);
          }
        });
      } else {
        meetingList.clear();
        meetingList.addAll(data);
      }
      sortAndGroupData();
    };
    NEMeetingKit.instance
        .getPreMeetingService()
        .registerScheduleMeetingStatusChange(scheduleCallback);
  }

  void getMeetingList() {
    NEMeetingKit.instance.getPreMeetingService().getMeetingList([
      NEMeetingState.init,
      NEMeetingState.started,
      NEMeetingState.ended,
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
              title: Text(meetingAppLocalizations.globalNotify),
              content: Text(content),
              actions: <Widget>[
                CupertinoDialogAction(
                    child: Text(meetingAppLocalizations.globalSure),
                    onPressed: () {
                      Navigator.of(context).pop();
                      isShowEndDialog = false;
                    })
              ],
            ));
  }

  void showRecoverJoinMeetingDialog(String meetingNum) {
    AppDialogUtils.showCommonDialog(
        context, '', meetingAppLocalizations.meetingRecover, () {
      NavUtils.closeCurrentState('cancel');
      UserPreferences().setMeetingInfo('');
    }, () async {
      NavUtils.closeCurrentState('ok');
      LoadingUtil.showLoading();
      var historyItem = await NEMeetingKit.instance
          .getSettingsService()
          .getHistoryMeetingItem();
      String? lastUsedNickname;
      if (historyItem != null &&
          historyItem.isNotEmpty &&
          (historyItem.first.meetingNum == meetingNum ||
              historyItem.first.shortMeetingNum == meetingNum)) {
        lastUsedNickname = historyItem.first.nickname;
      }
      final result = await NEMeetingUIKit().joinMeetingUI(
        context,
        NEJoinMeetingUIParams(
          meetingNum: meetingNum,
          displayName: lastUsedNickname ?? MeetingUtil.getNickName(),
          watermarkConfig: NEWatermarkConfig(
            name: MeetingUtil.getNickName(),
          ),
        ),
        await buildMeetingUIOptions(context: context),
        onPasswordPageRouteWillPush: () async {
          LoadingUtil.cancelLoading();
        },
        backgroundWidget: MeetingAppLocalizationsScope(child: HomePageRoute()),
      );
      LoadingUtil.cancelLoading();
      if (!result.isSuccess()) {
        UserPreferences().setMeetingInfo('');
        ToastUtils.showToast(context, result.msg);
      }
    },
        acceptText: meetingAppLocalizations.globalResume,
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
    if (temp.isNotEmpty) {
      var last = 0;
      temp.forEach((element) {
        var time = DateTime.fromMillisecondsSinceEpoch(element.startTime);
        var itemDay =
            DateTime(time.year, time.month, time.day).millisecondsSinceEpoch;
        if (itemDay == last) {
          meetingList.add(element);
        } else {
          last = itemDay;
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
  Widget build(BuildContext context) {
    initUpgradeAndDeepLink();

    return Stack(
      children: [
        Scaffold(
            backgroundColor: Colors.white,
            body: PageView(
              controller: _pageController,
              onPageChanged: onPageChange,
              allowImplicitScrolling: true,
              physics: AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                buildHomePage(),
                NEMeetingKitFeatureConfig(
                  child: buildSettingPage(),
                ),
              ],
            ),
            bottomNavigationBar: buildBottomAppBar()),
      ],
    );
  }

  BottomAppBar buildBottomAppBar() {
    return BottomAppBar(
        color: Colors.white,
        child: Container(
            height: 49,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: AppColors.color_19000000,
                    offset: Offset(0, -2),
                    blurRadius: 2)
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                buildTabItem(0, _currentIndex == 0, AssetName.tabHomeSelect,
                    AssetName.tabHome),
                buildTabItem(1, _currentIndex == 1, AssetName.tabSettingSelect,
                    AssetName.tabSetting),
              ],
            )));
  }

  Widget buildTabItem(
      int index, bool select, String selectAsset, String normalAsset) {
    return GestureDetector(
      key: index == 0
          ? MeetingValueKey.tabHomeSelect
          : MeetingValueKey.tabSettingSelect,
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _onTap(index);
      },
      child: Image.asset(select ? selectAsset : normalAsset,
          //package: AssetName.package,
          width: 130,
          height: 32),
    );
  }

  Widget buildHomePage() {
    return Column(
      children: <Widget>[
        SizedBox(height: 44),
        Stack(
          children: <Widget>[
            buildTitle(meetingAppLocalizations.globalAppName),
            Positioned(
              right: 12,
              child: Container(
                  color: Colors.white,
                  height: Dimen.titleHeight,
                  child: Stack(
                      alignment: Alignment.centerRight,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NEMeetingUIKitLocalizationsScope(
                                      child: MeetingAppNotifyCenter(
                                          sessionId: SDKConfig
                                              .current.appNotifySessionId,
                                          onClearAllMessage: () {
                                            MeetingUtil
                                                .setUnreadNotifyMessageListenable(
                                                    0);
                                          }),
                                    ),
                                  ));
                            },
                            child: Image(
                                image: AssetImage(
                                  AssetName.iconNotification,
                                ),
                                width: 24,
                                height: 24),
                          ),
                        ),
                        SafeValueListenableBuilder(
                            valueListenable:
                                MeetingUtil.getUnreadNotifyMessageListenable(),
                            builder: (_, int value, __) => value > 0
                                ? Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      margin:
                                          EdgeInsets.only(bottom: 24, left: 10),
                                      child: ClipOval(
                                          child: Container(
                                              height: 16,
                                              width: 16,
                                              decoration: ShapeDecoration(
                                                  color: Colors.red,
                                                  shape: Border()),
                                              alignment: Alignment.center,
                                              child: Text(
                                                value > 99 ? '99+' : '$value',
                                                style: const TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.white,
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ))),
                                    ),
                                  )
                                : Container()),
                      ])),
            )
          ],
        ),
        buildNotificationBar(
            meetingAccountService.getAccountInfo()?.serviceBundle),
        Container(color: AppColors.globalBg, height: 1),
        SizedBox(height: 24),
        Row(
          children: <Widget>[
            Container(width: 18),
            buildItem(AssetName.createMeeting,
                meetingAppLocalizations.meetingCreate, _onCreateMeeting),
            buildItem(AssetName.joinMeeting,
                meetingAppLocalizations.meetingJoin, _onJoinMeeting),
            buildItem(AssetName.scheduleMeeting,
                meetingAppLocalizations.meetingSchedule, _onSchedule),
            Container(width: 18),
          ],
        ),
        SizedBox(height: 24),
        Container(color: AppColors.globalBg, height: 1),
        Expanded(
            child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            buildMeetingList(),
            Positioned(
              top: 29.0,
              right: 0.0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Container(
                  alignment: Alignment.center,
                  padding:
                      EdgeInsets.only(left: 17, right: 12, top: 5, bottom: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(14),
                          bottomLeft: Radius.circular(14)),
                      color: AppColors.white,
                      border: Border.all(color: AppColors.globalBg, width: 0.5),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.shadow,
                            offset: Offset(0, 4),
                            blurRadius: 8,
                            spreadRadius: 1)
                      ]),
                  child: Text(
                    meetingAppLocalizations.historyMeeting,
                    style:
                        TextStyle(fontSize: 13, color: AppColors.black_222222),
                  ),
                ),
                onTap: _onHistoryMeeting,
              ),
            )
          ],
        )
            //buildMeetingList(),
            ),
      ],
    );
  }

  void _onCreateMeeting() {
    // InMeetingMoreMenuUtil.showInMeetingDialog(NavUtils.navigatorKey.currentState!.context);
    NavUtils.pushNamed(context, RouterName.meetCreate);
  }

  void _onJoinMeeting() {
    NavUtils.pushNamed(context, RouterName.meetJoin);
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
      return Center(
          child: SingleChildScrollView(
              child: Column(
        children: [
          Image(
            image: AssetImage(
              AssetName.emptyMeetingList,
              // package: AssetName.package
            ),
          ),
          Text(
            meetingAppLocalizations.meetingScheduleListEmpty,
            style: TextStyle(
                fontSize: 14,
                color: AppColors.black_222222,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none),
          ),
        ],
      )));
    } else {
      return ListView.builder(
        padding: EdgeInsets.only(left: 20, bottom: 20),
        itemCount: meetingList.length,
        itemBuilder: (context, index) {
          var item = meetingList[index];
          // if (item == null) {
          //   return null;
          // }
          if (item.meetingNum == null) {
            return buildTimeTitle(item.startTime);
          } else {
            return buildMeetingItem(item);
          }
        },
      );
    }
  }

  Widget buildTimeTitle(int time) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    return Container(
      height: 66,
      alignment: Alignment.bottomLeft,
      child: Text.rich(TextSpan(children: [
        TextSpan(
            text: "${dateTime.day < 10 ? '0' : ''}${dateTime.day}",
            style: TextStyle(fontSize: 36, color: AppColors.black_222222)),
        TextSpan(
            text:
                '   ${dateTime.month}${meetingAppLocalizations.globalMonth} ${getTimeSuffix(dateTime)}',
            style: TextStyle(fontSize: 14, color: AppColors.black_222222))
      ])),
    );
  }

  String getTimeSuffix(DateTime dateTime) {
    var now = DateTime.now();
    var tomorrow = now.add(Duration(days: 1));
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return meetingAppLocalizations.meetingToday;
    } else if (dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day) {
      return meetingAppLocalizations.meetingTomorrow;
    }
    return '';
  }

  Widget buildMeetingItem(NEMeetingItem item) {
    var valueKey = '${item.meetingId}&${item.meetingNum}';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      key: MeetingValueKey.dynamicValueKey(valueKey),
      child: Container(
          height: 72,
          child: Stack(children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image(
                    image: AssetImage(
                      AssetName.iconCalendar,
                      // package: AssetName.package,
                    ),
                    width: 24,
                    height: 24),
                SizedBox(width: 26),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text.rich(
                            key: MeetingValueKey.scheduleMeetingItemTitle,
                            TextSpan(children: [
                              TextSpan(
                                  text:
                                      '${MeetingTimeUtil.timeFormatHourMinute(DateTime.fromMillisecondsSinceEpoch(item.startTime))}',
                                  style: TextStyle(
                                      color: AppColors.black_222222,
                                      fontSize: 12)),
                              TextSpan(
                                  text:
                                      " | ${meetingAppLocalizations.meetingShortId}${TextUtil.applyMask(item.meetingNum ?? "", "000-000-0000")}",
                                  style: TextStyle(
                                      color: AppColors.color_999999,
                                      fontSize: 12)),
                            ])),
                        if (item.recurringRule.type !=
                            NEMeetingRecurringRuleType.no)
                          SizedBox(width: 8),
                        if (item.recurringRule.type !=
                            NEMeetingRecurringRuleType.no)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2.0),
                              color: Color.fromRGBO(51, 126, 255, 0.1),
                              border: Border.all(
                                  color: Color.fromRGBO(51, 126, 255, 0.2),
                                  width: 1.0),
                            ),
                            child: Text(
                                ' ${meetingAppLocalizations.meetingRepeat} ',
                                style: TextStyle(
                                    color: AppColors.color_337eff,
                                    fontSize: 10)),
                          ),
                        SizedBox(width: 8),
                        Text(
                            MeetingStringUtil.getItemStatus(
                                item.state, meetingAppLocalizations),
                            style: TextStyle(
                                color: getItemStatusColor(item.state),
                                fontSize: 12))
                      ]),
                      SizedBox(height: 4),
                      Container(
                        margin: EdgeInsets.only(right: 40),
                        child: Text(item.subject ?? '',
                            style: TextStyle(
                                fontSize: 16, color: AppColors.black_222222)),
                      ),
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
                    child: Icon(IconFont.iconyx_allowx,
                        size: 14, color: AppColors.greyCCCCCC))),
            Align(
                alignment: Alignment.bottomCenter,
                widthFactor: 1.0,
                child: Container(
                    margin: EdgeInsets.only(left: 52),
                    height: 0.5,
                    color: AppColors.colorE6E7EB))
          ])),
      onTap: () {
        Navigator.of(context).push(MaterialMeetingAppPageRoute(
            settings: RouteSettings(name: ScheduleMeetingDetailRoute.routeName),
            builder: (context) {
              return ScheduleMeetingDetailRoute(item);
            }));
        //NavUtils.pushNamed(context, RouterName.scheduleMeetingDetail);
      },
    );
  }

  Color getItemStatusColor(NEMeetingState status) {
    if (status == NEMeetingState.started) {
      return AppColors.color_337eff;
    } else if (status == NEMeetingState.init) {
      return AppColors.color_f29900;
    }
    return AppColors.color_999999;
  }

  Expanded buildItem(String assetStr, String text, VoidCallback voidCallback) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
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
            SizedBox(height: 10),
            Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: AppColors.black_222222,
                    fontSize: 14,
                    fontWeight: FontWeight.w400))
          ],
        ),
      ),
    );
  }

  Widget buildSettingPage() {
    return Container(
      color: AppColors.globalBg,
      child: Column(children: <Widget>[
        Container(color: Colors.white, height: 44),
        buildTitle(meetingAppLocalizations.settings),
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              buildSettingItemPadding(),
              buildUserInfo(),
              buildSettingItemPadding(),
              Visibility(
                  visible: MeetingUtil.hasShortMeetingNum(),
                  child: buildPersonItem(
                      meetingAppLocalizations.meetingPersonalShortMeetingID,
                      null,
                      titleTip:
                          meetingAppLocalizations.settingInternalDedicated,
                      arrowTip: MeetingUtil.getShortMeetingNum())),
              Visibility(
                  visible: MeetingUtil.hasShortMeetingNum(), child: line()),
              buildPersonItem(
                  meetingAppLocalizations.meetingPersonalMeetingID, null,
                  arrowTip: MeetingUtil.getMeetingNum()),
              // buildSettingItemPadding(),
              // buildSettingItem(
              //     meetingAppLocalizations.packageVersion,
              //     () => NavUtils.pushNamed(
              //         context, RouterName.packageVersionSetting,
              //         arguments: _accountAppInfo?.edition),
              //     iconTip: _accountAppInfo?.edition.name ?? ''),
              buildSettingItemPadding(),
              Visibility(
                  visible: MeetingUtil.hasShortMeetingNum(), child: line()),
              buildSettingItem(meetingAppLocalizations.settingMeeting,
                  () => NavUtils.pushNamed(context, RouterName.meetingSetting)),
              line(),
              buildSettingItem(
                meetingAppLocalizations.settingSwitchLanguage,
                () => NavUtils.pushNamed(context, RouterName.languageSetting),
                iconTip: meetingAppLocalizations.settingLanguageTip,
              ),
              Builder(
                builder: (context) {
                  return context.isBeautyFaceEnabled
                      ? Container(
                          color: AppColors.globalBg,
                          child: buildSettingItem(
                            meetingAppLocalizations.settingBeauty,
                            () {
                              if (NEMeetingUIKit().getCurrentMeetingInfo() !=
                                  null) {
                                ToastUtils.showToast(
                                    context,
                                    meetingAppLocalizations
                                        .meetingOperationNotSupportedInMeeting);
                                return;
                              }
                              if (bCanPress) {
                                bCanPress = false;
                                NEMeetingUIKit().openBeautyUI(context);
                                Future.delayed(Duration(milliseconds: 500),
                                    () => bCanPress = true);
                              }
                            },
                          ),
                        )
                      : SizedBox.shrink();
                },
              ),
              Builder(builder: (context) {
                return Visibility(
                  visible: context.isBeautyFaceEnabled &&
                      context.isVirtualBackgroundEnabled,
                  child: line(),
                );
              }),
              Builder(
                builder: (context) {
                  return context.isVirtualBackgroundEnabled
                      ? Container(
                          color: AppColors.globalBg,
                          child: buildSettingItem(
                            meetingAppLocalizations.settingVirtualBackground,
                            () {
                              if (NEMeetingUIKit().getCurrentMeetingInfo() !=
                                  null) {
                                ToastUtils.showToast(
                                    context,
                                    meetingAppLocalizations
                                        .meetingOperationNotSupportedInMeeting);
                                return;
                              }
                              if (vCanPress) {
                                vCanPress = false;
                                NEMeetingUIKit()
                                    .openVirtualBackgroundBeautyUI(context);
                                Future.delayed(Duration(milliseconds: 500),
                                    () => vCanPress = true);
                              }
                            },
                          ),
                        )
                      : SizedBox.shrink();
                },
              ),
              buildSettingItemPadding(),
              buildSettingItem(meetingAppLocalizations.settingAbout,
                  () => NavUtils.pushNamed(context, RouterName.about)),
              Container(
                height: 22,
                color: AppColors.globalBg,
              ),
            ],
          ),
        ))
      ]),
    );
  }

  Container buildTitle(String title) {
    return Container(
      color: Colors.white,
      height: Dimen.titleHeight,
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
            color: AppColors.black_222222,
            fontSize: TextSize.titleSize,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget buildUserInfo() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
      child: ListenableBuilder(
          listenable: meetingAccountService,
          builder: (context, _) {
            final accountInfo = meetingAccountService.getAccountInfo();
            if (accountInfo == null) {
              return SizedBox.shrink();
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildUserProfile(accountInfo),
                buildServiceBundleInfo(accountInfo),
              ],
            );
          }),
    );
  }

  Widget buildUserProfile(NEAccountInfo accountInfo) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Container(
          key: MeetingValueKey.personalSetting,
          height: 48 + 20 + 18,
          padding: EdgeInsets.only(top: 20, bottom: 16),
          child: Row(
            children: <Widget>[
              NEMeetingAvatar.xlarge(
                name: accountInfo.nickname,
                url: accountInfo.avatar,
              ),
              Padding(padding: EdgeInsets.only(left: 12)),
              Expanded(
                child: Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Spacer(),
                        Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(bottom: 2),
                            child: ListenableBuilder(
                                listenable: meetingAccountService,
                                builder: (context, child) {
                                  return Text(
                                    StringUtil.truncate(accountInfo.nickname),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: AppColors.black_222222,
                                    ),
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.ltr,
                                    key: MeetingValueKey.nickName,
                                  );
                                })),
                        Container(
                          width: MediaQuery.of(context).size.width * 2 / 3,
                          child: Text(
                            accountInfo.corpName ??
                                meetingAppLocalizations
                                    .settingDefaultCompanyName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.color_999999,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Spacer(),
                      ]),
                ),
              ),
              Icon(IconFont.iconyx_allowx,
                  size: 14, color: AppColors.greyCCCCCC)
            ],
          ),
        ),
        onTap: () => Navigator.push(
            context,
            MaterialMeetingAppPageRoute(
                builder: (context) => PersonalSetting(
                    _accountAppInfo?.appName ??
                        meetingAppLocalizations.settingDefaultCompanyName))));
  }

  Widget buildServiceBundleInfo(NEAccountInfo accountInfo) {
    final serviceBundle = accountInfo.serviceBundle;
    if (serviceBundle == null) {
      return SizedBox.shrink();
    }
    final serviceBundleDetail = serviceBundle.isUnlimited
        ? meetingAppLocalizations.settingServiceBundleDetailUnlimitedMinutes(
            serviceBundle.maxMembers)
        : meetingAppLocalizations.settingServiceBundleDetailLimitedMinutes(
            serviceBundle.maxMembers, serviceBundle.maxMinutes!);
    final serviceBundleExpireTime =
        meetingAppLocalizations.settingServiceBundleExpireTime(
            MeetingTimeUtil.getTimeFormatYMD(serviceBundle.expireTimestamp));
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      decoration: ShapeDecoration(
        color: AppColors.color_F8F9FB,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  meetingAppLocalizations.settingServiceBundleTitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.color_666666,
                  ),
                ),
                if (!serviceBundle.isNeverExpired) Spacer(),
                if (!serviceBundle.isNeverExpired)
                  Text(
                    serviceBundleExpireTime,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.color_999999,
                    ),
                  ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              children: [
                SizedBox(width: 2),
                Container(
                  decoration: ShapeDecoration(
                    color: AppColors.color_999999,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  transform: Matrix4.rotationZ(pi / 4),
                  width: 3,
                  height: 3,
                ),
                SizedBox(
                  width: 4,
                ),
                Expanded(
                    child: Text(
                  serviceBundleDetail,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.color_333333,
                  ),
                )),
              ],
            ),
            if (!serviceBundle.isNeverExpired)
              Container(
                height: 1,
                margin: EdgeInsets.only(top: 10, bottom: 10),
                color: AppColors.colorE8E9EB,
              ),
            if (!serviceBundle.isNeverExpired)
              Text(
                serviceBundle.expireTip,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.color_666666,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Container buildSettingItemPadding() {
    return Container(color: AppColors.globalBg, height: Dimen.globalPadding);
  }

  Widget buildSettingItem(String title, VoidCallback voidCallback,
      {String iconTip = ''}) {
    return GestureDetector(
      child: Container(
        height: Dimen.primaryItemHeight,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
        child: Row(
          children: <Widget>[
            Text(title,
                style: TextStyle(fontSize: 16, color: AppColors.black_222222)),
            Spacer(),
            iconTip == ''
                ? Container()
                : Text(iconTip,
                    style:
                        TextStyle(fontSize: 14, color: AppColors.color_999999)),
            Container(
              width: 10,
            ),
            Icon(IconFont.iconyx_allowx, size: 14, color: AppColors.greyCCCCCC)
          ],
        ),
      ),
      onTap: voidCallback,
    );
  }

  Widget buildPersonItem(String title, VoidCallback? voidCallback,
      {String titleTip = '', String arrowTip = ''}) {
    return GestureDetector(
      child: Container(
        height: Dimen.primaryItemHeight,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
        child: Row(
          children: <Widget>[
            Text(title,
                style: TextStyle(fontSize: 16, color: AppColors.black_222222)),
            titleTip == ''
                ? Container()
                : Container(
                    margin: EdgeInsets.only(left: 6),
                    padding:
                        EdgeInsets.only(left: 8, top: 3, right: 8, bottom: 3),
                    color: AppColors.color_1a337eff,
                    child: Text(titleTip,
                        style: TextStyle(
                            fontSize: 12, color: AppColors.color_337eff)),
                  ),
            Spacer(),
            arrowTip == ''
                ? Container()
                : Text(
                    arrowTip,
                    style:
                        TextStyle(fontSize: 14, color: AppColors.color_999999),
                  ),
            Container(
              width: 20,
            ),
          ],
        ),
      ),
      onTap: voidCallback,
    );
  }

  void onPageChange(int value) {
    if (_currentIndex != value) {
      setState(() {
        _currentIndex = value;
      });
    }
  }

  void _onTap(int value) {
    _pageController.jumpToPage(value);
  }

  @override
  void onKickOut() {
    if (!mounted) return;
    ToastUtils.showToast(
        context, meetingAppLocalizations.authLoginOnOtherDevice, onDismiss: () {
      AuthManager().logout();
      NavUtils.toEntrance(context);
    });
  }

  @override
  void onAuthInfoExpired() {
    /// 当前处于会议中，会议会自动断开，原因是登录态过期，这里不需要弹框
    if (NEMeetingUIKit().getMeetingStatus().event != NEMeetingEvent.idle)
      return;
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
          title: Text(meetingAppLocalizations.globalNotify),
          content: Text(meetingAppLocalizations.authLoginTokenExpired),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(meetingAppLocalizations.globalSure),
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
    _pageController.dispose();
    if (_meetingStatusListener != null)
      NEMeetingUIKit().removeListener(_meetingStatusListener!);
    NEMeetingKit.instance
        .getPreMeetingService()
        .unRegisterScheduleMeetingStatusChange(scheduleCallback);
    NEMeetingKit.instance.removeAuthListener(this);
    DeepLinkManager().detach(context);
    streamSubscriptions.forEach((element) {
      element.cancel();
    });
    super.dispose();
  }

  Widget line() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
      color: AppColors.colorE8E9EB,
      height: 0.5,
    );
  }

  void _setGlobalMeetingInfo(NEMeetingInfo? currentMeetingInfo) {
    var map = <String, dynamic>{
      'meetingNum': currentMeetingInfo?.meetingNum,
      'currentTime': MeetingTimeUtil.getCurrentTimeMilliseconds()
    };
    UserPreferences().setMeetingInfo(jsonEncode(map));
  }

  void _setGlobalMeetingEvaluation(DateTime date) {
    var map = <String, dynamic>{
      'version': SDKConfig.sdkVersionName,
      'lastTime': date.millisecondsSinceEpoch
    };
    GlobalPreferences().setMeetingEvaluation(jsonEncode(map));
  }

  void meetingEvaluationAction(DateTime startDate, DateTime endDate) async {
    if (!await ConnectivityManager().isConnected()) {
      return;
    }
    var evaluationInfo = await GlobalPreferences().meetingEvaluation;
    if (TextUtil.isEmpty(evaluationInfo)) {
      // 入会>=5分钟
      if (endDate.difference(startDate).inMinutes >= 5) {
        _setGlobalMeetingEvaluation(endDate);
        buildEvaluationView();
      }
    } else {
      Map map = jsonDecode(evaluationInfo!);
      var version = map["version"] as String;
      // 版本相同
      if (version == SDKConfig.sdkVersionName) {
        var lastTimestamp = map["lastTime"] as int;
        var lastTime = DateTime.fromMillisecondsSinceEpoch(lastTimestamp);
        var time = DateTime.now();
        // 每天0点之后弹框
        if (time.difference(lastTime).inDays >= 1) {
          // 弹框
          buildEvaluationView();
        }
      } else {
        if (endDate.difference(startDate).inMinutes >= 5) {
          _setGlobalMeetingEvaluation(endDate);
          buildEvaluationView();
        }
      }
    }
  }

  void buildEvaluationView() {
    if (isShowNPS) return;
    isShowNPS = true;
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        builder: (context) {
          return Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              // color: Colors.white,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  color: Colors.white),
              height: MediaQuery.of(context).size.height / 3 * 2,
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  SizedBox(height: 17),
                  buildEvaluationTitle(),
                  SizedBox(height: 22),
                  buildGridView(),
                  SizedBox(height: 20),
                  buildEvaluationCore(),
                  SizedBox(height: 20),
                  buildEvaluationInputView(),
                  SizedBox(height: 20),
                  buildEvaluationSubmitButton()
                ],
              )));
        });
  }

  Widget buildEvaluationTitle() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              child: Container(
            padding: EdgeInsets.only(top: 7, left: 20),
            child: Text(
              meetingAppLocalizations.evaluationTitle,
              softWrap: true,
              style: TextStyle(
                  fontSize: 20,
                  color: AppColors.color_333333,
                  fontWeight: FontWeight.w500),
            ),
          )),
          GestureDetector(
            onTap: () {
              _setGlobalMeetingEvaluation(DateTime.now());
              Navigator.pop(context);
              isShowNPS = false;
            },
            child: Container(
                key: MeetingValueKey.evaluationCloseBtn,
                padding: EdgeInsets.all(20),
                child: Image(
                    image: AssetImage(AssetName.iconEvaluationCloseSheet))),
          )
        ]);
  }

  Widget buildGridView() {
    var radius = (MediaQuery.of(context).size.width - 40 - 5 * 16) / 6 / 2;
    return SafeValueListenableBuilder(
        valueListenable: evaluationSelectedIndex,
        builder: (BuildContext context, int value, _) {
          return GridView.builder(
              padding: EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16),
              itemCount: 11,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                    onTap: () {
                      _evaluationIndex.value =
                          _evaluationIndex.value == index ? -1 : index;
                    },
                    child: index == value
                        ? Container(child: getLottie(index))
                        : Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(radius)),
                                color: AppColors.colorF2F2F5),
                            child: Text(
                              '$index',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14, color: AppColors.color394151),
                            ),
                          ));
              });
        });
  }

  Widget getLottie(int index) {
    var assetName = AssetName.iconEvaluationHeartEye;
    if (0 <= index && index <= 2) {
      assetName = AssetName.iconEvaluationAngry;
    } else if (3 <= index && index <= 6) {
      assetName = AssetName.iconEvaluationSad;
    } else if (7 <= index && index <= 8) {
      assetName = AssetName.iconEvaluationHappy;
    }
    return OverflowBox(
        alignment: Alignment.center,
        maxHeight: (MediaQuery.of(context).size.width - 40 - 5 * 16) / 6 + 15,
        maxWidth: (MediaQuery.of(context).size.width - 40 - 5 * 16) / 6 + 15,
        child: Lottie.asset(assetName, repeat: false));
  }

  Widget buildEvaluationCore() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
          padding: EdgeInsets.only(left: 20),
          child: Text(meetingAppLocalizations.evaluationCoreZero,
              style: TextStyle(fontSize: 13, color: AppColors.black_333333))),
      Container(
          padding: EdgeInsets.only(right: 20),
          child: Text(meetingAppLocalizations.evaluationCoreTen,
              style: TextStyle(fontSize: 13, color: AppColors.black_333333))),
    ]);
  }

  Widget buildEvaluationInputView() {
    return Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          color: Colors.white,
          border: Border.all(color: AppColors.colorE1E3E6, width: 1),
        ),
        child: Column(children: [
          Expanded(
              child: Container(
            padding: EdgeInsets.only(left: 12, right: 12),
            child: TextField(
              key: MeetingValueKey.evaluationTextFieldInput,
              autofocus: false,
              focusNode: _focusNode,
              onEditingComplete: hideKeyboard,
              minLines: 5,
              maxLines: 5,
              keyboardAppearance: Brightness.light,
              textInputAction: TextInputAction.done,
              inputFormatters: [LengthLimitingTextInputFormatter(500)],
              onChanged: (text) {
                _evaluationInputLength.value = text.characters.length;
                _evaluationContent = text;
              },
              // maxLength: 500,
              decoration: InputDecoration(
                  hintText: meetingAppLocalizations.evaluationHitTextOne +
                      '\n' +
                      meetingAppLocalizations.evaluationHitTextTwo +
                      '\n' +
                      meetingAppLocalizations.evaluationHitTextThree,
                  hintStyle:
                      TextStyle(fontSize: 14, color: AppColors.color_999999),
                  border: InputBorder.none),
              style: TextStyle(fontSize: 14, color: AppColors.black_333333),
            ),
          )),
          SafeValueListenableBuilder(
              valueListenable: evaluationInputStringLength,
              builder: (BuildContext context, int value, _) {
                return Container(
                    padding: EdgeInsets.only(right: 12, bottom: 5),
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$value/500',
                      textAlign: TextAlign.right,
                      style:
                          TextStyle(fontSize: 12, color: AppColors.colorAAAAAA),
                    ));
              }),
        ]));
  }

  Widget buildEvaluationSubmitButton() {
    return GestureDetector(
        child: Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            color: AppColors.blue_337eff,
          ),
          height: 50,
          alignment: Alignment.center,
          child: Text(meetingAppLocalizations.globalSubmit,
              style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
        onTap: () async {
          _setGlobalMeetingEvaluation(DateTime.now());
          int code = await uploadEvaluation();
          if (code == 200) {
            Navigator.pop(context);
            _evaluationIndex.value = -1;
            _evaluationInputLength.value = 0;
            _evaluationContent = "";
            buildEvaluationSuccessView();
          }
        });
  }

  Future<int> uploadEvaluation() async {
    return 200;
  }

  void buildEvaluationSuccessView() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        builder: (context) {
          return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  color: Colors.white),
              height: MediaQuery.of(context).size.height / 3 * 2,
              child: SingleChildScrollView(
                  child: Column(
                // crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(height: 17),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 17),
                        height: 16,
                        child: GestureDetector(
                            child: Image(
                                image: AssetImage(
                                    AssetName.iconEvaluationCloseSheet)),
                            onTap: () {
                              Navigator.pop(context);
                              isShowNPS = false;
                            }),
                      )
                    ],
                  ),
                  SizedBox(height: 124),
                  Container(
                      width: 80,
                      child: Lottie.asset(AssetName.iconEvaluationBlush)),
                  SizedBox(height: 4),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      meetingAppLocalizations.evaluationThankFeedback,
                      style: TextStyle(
                          fontSize: 20,
                          color: AppColors.black_333333,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(height: 135),
                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        color: AppColors.blue_337eff,
                      ),
                      height: 50,
                      alignment: Alignment.center,
                      child: Text(
                        meetingAppLocalizations.evaluationGoHome,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      isShowNPS = false;
                    },
                  )
                ],
              )));
        });
  }

  void hideKeyboard() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  void saveMeetingInfo(NEMeetingInfo? meetingInfo) {
    _evaluateMeetingInfo = meetingInfo;
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
                meetingAppLocalizations.authResetInitialPasswordDialogTitle,
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
                  meetingAppLocalizations.authResetInitialPasswordDialogMessage,
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
                          meetingAppLocalizations
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
                          meetingAppLocalizations
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
  void onChangeRecentSession(List<NEMeetingRecentSession> messages) {
    int? _unreadCount = messages
        .takeWhile(
            (value) => value.sessionId == SDKConfig.current.appNotifySessionId)
        .lastOrNull
        ?.unreadCount;
    if (_unreadCount != null) {
      MeetingUtil.setUnreadNotifyMessageListenable(_unreadCount);
    }
  }

  @override
  void onDeleteAllSessionMessage(
      String sessionId, NEMeetingSessionTypeEnum sessionType) {}

  @override
  void onDeleteSessionMessage(NEMeetingCustomSessionMessage message) {
    // 单条通知删除，需求未定，暂不实现
  }

  @override
  void onReceiveSessionMessage(NEMeetingCustomSessionMessage message) {}

  /// 电话或视频入会
  /// [inviteData] 邀请数据
  /// [videoMute] 是否视频关闭
  ///
  Future<void> handleEvent(CardData? inviteData, bool videoMute) async {
    if (inviteData?.meetingNum == null || !mounted) return;
    LoadingUtil.showLoading();
    NEMeetingUIKit().joinMeetingUI(
      context,
      NEJoinMeetingUIParams(
        meetingNum: inviteData!.meetingNum!,
        displayName: MeetingUtil.getNickName(),
        watermarkConfig: NEWatermarkConfig(
          name: MeetingUtil.getNickName(),
        ),
      ),
      await buildMeetingUIOptions(
        noVideo: videoMute,
        noAudio: false,
        context: context,
      ),
      onPasswordPageRouteWillPush: () async {
        LoadingUtil.cancelLoading();
      },
      onMeetingPageRouteWillPush: () async {
        LoadingUtil.cancelLoading();
      },
      backgroundWidget: MeetingAppLocalizationsScope(child: HomePageRoute()),
      isInvite: true,
    ).then((result) {
      LoadingUtil.cancelLoading();
      if (mounted && !result.isSuccess()) {
        ToastUtils.showToast(context, result.msg);
      }
    });
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
                'isQrScanPagePopped = ${Application.isQrScanPagePopped}');
        if (!Application.isQrScanPagePopped) {
          NavUtils.pushNamed(context, RouterName.qrScan).then((value) {
            Application.isQrScanPagePopped = true;
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
  Widget buildNotificationBar(ServiceBundle? serviceBundle) {
    if (serviceBundle?.isExpired == true) {
      return MeetingAppNotificationBar(
        notification: AppNotification.expireMessageTip(
            content: serviceBundle?.expireTip,
            time: serviceBundle?.expireTimestamp),
      );
    } else {
      return ConnectivityChangedBuilder(builder: (context, connected, child) {
        return connected
            ? MeetingAppNotificationBar()
            : MeetingNetworkNotificationBar();
      });
    }
  }

  @override
  void onMeetingInviteStatusChanged(NEMeetingInviteStatus status,
      String? meetingId, NEMeetingInviteInfo inviteInfo) {}
}
