// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:nemeeting/base/util/stringutil.dart';
import 'package:nemeeting/channel/deep_link_manager.dart';
import 'package:nemeeting/service/config/app_config.dart';
import 'package:nemeeting/setting/personal_setting.dart';
import 'package:nemeeting/utils/const_config.dart';
import 'package:nemeeting/utils/dialog_utils.dart';
import 'package:nemeeting/widget/length_text_input_formatter.dart';
import 'package:nemeeting/service/repo/user_repo.dart';
import 'package:nemeeting/uikit/const/consts.dart';
import 'package:nemeeting/base/util/text_util.dart';
import 'package:nemeeting/base/util/timeutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:nemeeting/service/event_name.dart';
import 'package:nemeeting/service/model/account_app_info.dart';
import 'package:nemeeting/service/repo/accountinfo_repo.dart';
import 'package:nemeeting/uikit/utils/nav_utils.dart';
import 'package:nemeeting/uikit/utils/router_name.dart';
import 'package:nemeeting/uikit/values/asset_name.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/uikit/values/dimem.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import 'package:nemeeting/uikit/values/strings.dart';
import 'package:lottie/lottie.dart';

import '../channel/ne_platform_channel.dart';

///会议中心
class HomePageRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageRouteState();
  }
}

class _HomePageRouteState extends LifecycleBaseState<HomePageRoute>
    implements NEMeetingAuthListener {
  late PageController _pageController;
  late TextEditingController _textController;
  int _currentIndex = 0;

  late EventCallback _eventCallback;

  late NEMeetingStatusListener _meetingStatusListener;

  List<NEMeetingItem> meetingList = <NEMeetingItem>[];
  bool isBeautyFaceEnabled = false;
  bool isVirtualBackgroundEnabled = false;

  late ScheduleCallback<List<NEMeetingItem>> scheduleCallback;
  AccountAppInfo? _accountAppInfo;
  var timerRecord;
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

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: _currentIndex);
    _textController = TextEditingController();
    lifecycleListen(AuthManager().authInfoStream(), (event) {
      setState(() {});
    });
    lifecycleExecuteUI(AccountInfoRepo().getAccountAppInfo()).then((result) {
      if (result?.code == HttpCode.success) {
        setState(() {
          _accountAppInfo = result?.data;
        });
      } else {
        // ToastUtils.showToast(context, result.msg ?? Strings.modifyFailed);
      }
    });

    _eventCallback = (arg) {
      showCloseDialog();
    };
    EventBus().subscribe(EventName.meetingClose, _eventCallback);
    handleMeetingSdk();
    scheduleMeeting();
    NEMeetingKit.instance
        .getSettingsService()
        .isBeautyFaceEnabled()
        .then((value) {
      setState(() {
        isBeautyFaceEnabled = value;
      });
    });
    NEMeetingKit.instance
        .getSettingsService()
        .isVirtualBackgroundEnabled()
        .then((value) {
      setState(() {
        isVirtualBackgroundEnabled = value;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (MeetingUtil.getAutoRegistered()) {
        showSettingNickDialog(context);
      }
    });
    GlobalPreferences().meetingInfo.then((meetingInfo) {
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
        GlobalPreferences().setMeetingInfo('');
      }
    });

    DeepLinkManager().attach(context);

    _evaluationIndex = ValueNotifier(-1);
    _evaluationInputLength = ValueNotifier(0);
    // prepareLottie();
  }

  void handleMeetingSdk() {
    _meetingStatusListener = (status) {
      meetingStatus = status.event;
      NEPlatformChannel().notifyMeetingStatusChanged(meetingStatus);
      setState(() {});
      switch (meetingStatus) {
        case NEMeetingEvent.disconnecting:
          meetingEvaluationAction(meetingStartDate, DateTime.now());
          switch (status.arg) {
            case NEMeetingCode.closeByHost:

              /// 主持人关闭会议
              showCloseDialog();
              break;

            case NEMeetingCode.authInfoExpired:

              /// 认证过期
              ToastUtils.showToast(context, Strings.authInfoExpired);
              break;

            case NEMeetingCode.endOfLife:

              /// 会议时长超限
              ToastUtils.showToast(context, Strings.endOfLife);
              break;

            case NEMeetingCode.loginOnOtherDevice:

              /// 账号再其他设备入会
              ToastUtils.showToast(context, Strings.switchOtherDevice);
              break;

            case NEMeetingCode.syncDataError:

              /// 同步数据失败
              ToastUtils.showToast(context, Strings.syncDataError);
              break;

            // case NEMeetingCode.removedByHost: /// 被主持人移除会议
            //   ToastUtils.showToast(context, Strings.removedByHost);
            //   break;
          }
          GlobalPreferences().setMeetingInfo('');

          /// 清理本地存储
          timerRecord?.cancel(); // 取消定时器
          break;
        case NEMeetingEvent.inMeeting:
          var meetingInfo = NEMeetingUIKit().getCurrentMeetingInfo();
          _evaluateMeetingInfo = meetingInfo;
          _setGlobalMeetingInfo(meetingInfo);

          /// 定是写入当前时间,每30秒写入
          timerRecord = Timer.periodic(const Duration(seconds: 30), (timer) {
            //callback function
            _setGlobalMeetingInfo(meetingInfo);
          });

          // 记录在会 开始时间
          meetingStartDate = DateTime.now();
          break;
        default:
      }
    };
    NEMeetingUIKit().addListener(_meetingStatusListener);
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
              meetingList.add(element);
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

  void showCloseDialog() {
    if (isShowEndDialog) {
      return;
    }
    isShowEndDialog = true;
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(Strings.notify),
            content: Text(Strings.hostCloseMeeting),
            actions: <Widget>[
              CupertinoDialogAction(
                  child: Text(Strings.sure),
                  onPressed: () {
                    Navigator.of(context).pop();
                    isShowEndDialog = false;
                  })
            ],
          );
        });
  }

  void showRecoverJoinMeetingDialog(String meetingNum) {
    AppDialogUtils.showCommonDialog(context, '', Strings.recoverMeeting, () {
      NavUtils.closeCurrentState('cancel');
      GlobalPreferences().setMeetingInfo('');
    }, () async {
      NavUtils.closeCurrentState('ok');
      LoadingUtil.showLoading();
      final result = await NEMeetingUIKit().joinMeetingUI(
        context,
        NEJoinMeetingUIParams(
            meetingNum: meetingNum, displayName: MeetingUtil.getNickName()),
        await buildMeetingUIOptions(),
        onPasswordPageRouteWillPush: () async {
          LoadingUtil.cancelLoading();
        },
        backgroundWidget: HomePageRoute(),
      );
      LoadingUtil.cancelLoading();
      if (!result.isSuccess()) {
        GlobalPreferences().setMeetingInfo('');
        ToastUtils.showToast(context, result.msg);
      }
    },
        acceptText: Strings.recoverMeetingText,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: PageView(
          controller: _pageController,
          onPageChanged: onPageChange,
          allowImplicitScrolling: true,
          physics: AlwaysScrollableScrollPhysics(),
          children: <Widget>[buildHomePage(), buildSettingPage()],
        ),
        bottomNavigationBar: buildBottomAppBar());
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
        buildTitle(Strings.homeTitle),
        MeetingAppNotificationBar(),
        Container(color: AppColors.globalBg, height: 1),
        SizedBox(height: 24),
        Row(
          children: <Widget>[
            Container(
              width: 18,
            ),
            buildItem(AssetName.createMeeting, Strings.createMeeting,
                _onCreateMeeting),
            buildItem(
                AssetName.joinMeeting, Strings.joinMeeting, _onJoinMeeting),
            buildItem(AssetName.scheduleMeeting, Strings.scheduleMeeting,
                _onSchedule),
            Container(
              width: 18,
            ),
          ],
        ),
        SizedBox(
          height: 23,
        ),
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
                  width: 81,
                  height: 28,
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
                    Strings.historyMeeting,
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
    pushPage(RouterName.meetCreate);
  }

  void _onJoinMeeting() {
    pushPage(RouterName.meetJoin);
  }

  void _onHistoryMeeting() {
    pushPage(RouterName.historyMeet);
  }

  void _onSchedule() {
    NavUtils.pushNamed(context, RouterName.scheduleMeeting,
            pageRoute: NEMeetingUIKit().getCurrentMeetingInfo() != null)
        .then((value) {
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
            Strings.scheduleMeetingListEmpty,
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
                '   ${dateTime.month}${Strings.month} ${getTimeSuffix(dateTime)}',
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
      return Strings.today;
    } else if (dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day) {
      return Strings.tomorrow;
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
                      Text.rich(TextSpan(children: [
                        TextSpan(
                            text:
                                '${TimeUtil.timeFormatHourMinute(DateTime.fromMillisecondsSinceEpoch(item.startTime))}',
                            style: TextStyle(
                                color: AppColors.black_222222, fontSize: 12)),
                        TextSpan(
                            text:
                                "${Strings.slashAndMeetingNumPrefix}${TextUtil.applyMask(item.meetingNum ?? "", "000-000-0000")}",
                            style: TextStyle(
                                color: AppColors.color_999999, fontSize: 12)),
                        TextSpan(
                            text: ' ${getItemStatus(item.state)}',
                            style: TextStyle(
                                color: getItemStatusColor(item.state),
                                fontSize: 12))
                      ])),
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
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ScheduleMeetingDetailRoute(item);
        }));
        //NavUtils.pushNamed(context, RouterName.scheduleMeetingDetail);
      },
    );
  }

  Color getItemStatusColor(NEMeetingState status) {
    if (status == NEMeetingState.started) {
      return AppColors.color_337eff;
    }
    return AppColors.color_999999;
  }

  String getItemStatus(NEMeetingState status) {
    // if (status == null) {
    //   return Strings.meetingStatusInvalid;
    // }
    switch (status) {
      case NEMeetingState.init:
        return Strings.meetingStatusInit;
      case NEMeetingState.invalid:
        return Strings.meetingStatusInvalid;
      case NEMeetingState.started:
        return Strings.meetingStatusStarted;
      case NEMeetingState.ended:
        return Strings.meetingStatusEnded;
      case NEMeetingState.cancel:
        return Strings.meetingStatusCancel;
      case NEMeetingState.recycled:
        return Strings.meetingStatusRecycle;
    }
  }

  Expanded buildItem(String assetStr, String text, VoidCallback voidCallback) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: voidCallback,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
                image: AssetImage(
                  assetStr,
                  // package: AssetName.package,
                ),
                width: Dimen.homeIconSize,
                height: Dimen.homeIconSize),
            Text(text,
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
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
          child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: viewportConstraints.maxHeight,
        ),
        child: Container(
          color: AppColors.globalBg,
          child: Column(
            children: <Widget>[
              Container(color: Colors.white, height: 44),
              buildTitle(Strings.settingTitle),
              buildSettingItemPadding(),
              buildUserInfo(
                  nick: MeetingUtil.getNickName(),
                  company:
                      _accountAppInfo?.appName ?? Strings.defaultCompanyName),
              Visibility(
                  visible: MeetingUtil.hasShortMeetingNum(), child: line()),
              Visibility(
                  visible: MeetingUtil.hasShortMeetingNum(),
                  child: buildPersonItem(Strings.shortMeetingNum, null,
                      titleTip: Strings.internalDedicated,
                      arrowTip: MeetingUtil.getShortMeetingNum())),
              line(),
              buildPersonItem(Strings.personMeetingNum, null,
                  arrowTip: MeetingUtil.getMeetingNum()),
              // buildSettingItemPadding(),
              // buildSettingItem(
              //     Strings.packageVersion,
              //     () => NavUtils.pushNamed(
              //         context, RouterName.packageVersionSetting,
              //         arguments: _accountAppInfo?.edition),
              //     iconTip: _accountAppInfo?.edition.name ?? ''),
              buildSettingItemPadding(),
              Visibility(
                  visible: MeetingUtil.hasShortMeetingNum(), child: line()),
              buildSettingItem(Strings.meetingSetting,
                  () => pushPage(RouterName.meetingSetting)),
              line(),
              StreamBuilder(
                stream: NEMeetingKit.instance
                    .getSettingsService()
                    .sdkConfigChangeStream,
                builder: (context, value) {
                  return FutureBuilder<bool>(
                      future: NEMeetingKit.instance
                          .getSettingsService()
                          .isBeautyFaceEnabled(),
                      initialData: isBeautyFaceEnabled,
                      builder: (context, value) {
                        isBeautyFaceEnabled = value.data ?? false;
                        return Column(
                          children: [
                            Visibility(
                                visible: isBeautyFaceEnabled,
                                child: buildSettingItemPadding()),
                            Visibility(
                                visible: isBeautyFaceEnabled,
                                child:
                                    buildSettingItem(Strings.beautySetting, () {
                                  if (NEMeetingUIKit()
                                          .getCurrentMeetingInfo() !=
                                      null) {
                                    ToastUtils.showToast(context,
                                        Strings.miniTipAlreadyInRightMeeting);
                                    return;
                                  }
                                  if (bCanPress) {
                                    bCanPress = false;
                                    NEMeetingUIKit().openBeautyUI(context);
                                    Future.delayed(Duration(milliseconds: 500),
                                        () => bCanPress = true);
                                  }
                                })),
                          ],
                        );
                      });
                },
              ),
              Visibility(
                  visible: isVirtualBackgroundEnabled,
                  child: buildSettingItemPadding()),
              Visibility(
                  visible: isVirtualBackgroundEnabled,
                  child: buildSettingItem(Strings.virtualBackgroundSetting, () {
                    if (NEMeetingUIKit().getCurrentMeetingInfo() != null) {
                      ToastUtils.showToast(
                          context, Strings.miniTipAlreadyInRightMeeting);
                      return;
                    }
                    if (vCanPress) {
                      vCanPress = false;
                      NEMeetingUIKit().openVirtualBackgroundBeautyUI(context);
                      Future.delayed(
                          Duration(milliseconds: 500), () => vCanPress = true);
                    }
                  })),

              // buildSettingItemPadding(),
              // buildSettingItem(Strings.tvControl, () {
              //   NEMeetingSDK.instance
              //       .getControlService()
              //       .openControl(
              //           context,
              //           NEControlParams(displayName: MeetingUtil.getNickName()),
              //           NEControlOptions(
              //               settingMenu: NEControlMenuItem('设置'),
              //               shareMenu: NEControlMenuItem('邀请')))
              //       .then((value) {
              //     if (value.code == NEMeetingErrorCode.alreadyInMeeting) {
              //       ToastUtils.showToast(context, Strings.invalidOpenControlTV);
              //     }
              //   });
              // }),
              buildSettingItemPadding(),
              buildSettingItem(Strings.about, () => pushPage(RouterName.about)),
              Container(
                height: 22,
                color: AppColors.globalBg,
              ),
            ],
          ),
        ),
      ));
    });
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

  GestureDetector buildUserInfo(
      {required String nick, required String company}) {
    return GestureDetector(
        child: Container(
          key: MeetingValueKey.personalSetting,
          height: 88,
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
          child: Row(
            children: <Widget>[
              buildAvatar(),
              Padding(padding: EdgeInsets.only(left: 12)),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Spacer(),
                    Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(bottom: 2),
                        child: Text(
                          nick,
                          style: TextStyle(
                              fontSize: 20, color: AppColors.black_222222),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.ltr,
                          key: MeetingValueKey.nickName,
                        )),
                    Container(
                      width: MediaQuery.of(context).size.width * 2 / 3,
                      child: Text(
                        company,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13, color: AppColors.color_999999),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Spacer(),
                  ]),
              Spacer(),
              Icon(IconFont.iconyx_allowx,
                  size: 14, color: AppColors.greyCCCCCC)
            ],
          ),
        ),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PersonalSetting(
                    _accountAppInfo?.appName ?? Strings.defaultCompanyName))));
  }

  Widget buildAvatar() {
    return ClipOval(
        child: Container(
      height: 48,
      width: 48,
      decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[AppColors.blue_5996FF, AppColors.blue_2575FF],
          ),
          shape: Border()),
      alignment: Alignment.center,
      child: Text(
        MeetingUtil.getCurrentNickLeading(),
        style: TextStyle(fontSize: 21, color: Colors.white),
      ),
    ));
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

  void showSettingNickDialog(BuildContext context) {
    showCupertinoDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              exit(0);
            },
            child: CupertinoAlertDialog(
              title: Text(Strings.setMeetingNick),
              content: Container(
                  height: 30,
                  margin: EdgeInsets.only(top: 20),
                  child: Material(
                    child: TextField(
                      autofocus: false,
                      controller: _textController,
                      keyboardAppearance: Brightness.light,
                      textAlignVertical: TextAlignVertical.bottom,
                      onChanged: (value) {
                        setState(() {});
                      },
                      inputFormatters: [
                        MeetingLengthLimitingTextInputFormatter(nickLengthMax),
                      ],
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        hintText: Strings.setMeetingTips,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10.0),
                        helperMaxLines: 1,
                      ),
                      style: TextStyle(
                          color: AppColors.color_222222, fontSize: 14),
                    ),
                  )),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(Strings.setMeetingOK),
                  onPressed: () {
                    _commit();
                  },
                ),
              ],
            ),
          );
        });
  }

  void _commit() {
    final nick = _textController.text;
    if (!StringUtil.isLetterOrDigitalOrZh(nick)) {
      _textController.text = '';
      ToastUtils.showToast(context, Strings.validatorNickTip);
      setState(() {});
      return;
    }

    lifecycleExecuteUI(UserRepo().updateNickname(nick)).then((result) {
      if (result == null) return;
      if (result.code == HttpCode.success) {
        AuthManager().saveNick(nick);
        ToastUtils.showToast(context, Strings.modifySuccess);
        Navigator.of(context).pop(true);
      } else {
        ToastUtils.showToast(context, result.msg ?? Strings.modifyFailed);
      }
    });
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
    ToastUtils.showToast(context, Strings.loginOnOtherDevice);
    AuthManager().logout();
    NavUtils.pushNamedAndRemoveUntil(context, RouterName.entrance);
  }

  @override
  void onAuthInfoExpired() {
    //如果处于会议中，先等会议页面pop完成，在弹窗
    //合理的做法是从meeting_page一路把错误传出来，但修改密码的场景本来就非高频场景
    //这里暂时delay一段时间，等待pop完成后，在弹窗
    //如果当前不是会议场景，没有必要进行delay
    var status = NEMeetingUIKit().getMeetingStatus().event;
    var navigator = Navigator.of(context);
    Future.delayed(Duration(seconds: status == NEMeetingEvent.idle ? 0 : 3),
        () {
      AuthManager().logout();
      showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(Strings.notify),
              content: Text(Strings.loginTokenExpired),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(Strings.sure),
                  onPressed: () => navigator.pushNamedAndRemoveUntil(
                      RouterName.entrance, (Route<dynamic> route) => false),
                )
              ],
            );
          });
    });
  }

  @override
  void dispose() {
    PrivacyUtil.dispose();
    EventBus().unsubscribe(EventName.meetingClose, _eventCallback);
    _pageController.dispose();
    NEMeetingUIKit().removeListener(_meetingStatusListener);
    NEMeetingKit.instance
        .getPreMeetingService()
        .unRegisterScheduleMeetingStatusChange(scheduleCallback);
    NEMeetingKit.instance.removeAuthListener(this);
    DeepLinkManager().detach(context);
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
      'currentTime': TimeUtil.getCurrentTimeMilliseconds()
    };
    GlobalPreferences().setMeetingInfo(jsonEncode(map));
  }

  void _setGlobalMeetingEvaluation(DateTime date) {
    var map = <String, dynamic>{
      'version': SDKConfig.sdkVersionName,
      'lastTime': date.millisecondsSinceEpoch
    };
    GlobalPreferences().setMeetingEvaluation(jsonEncode(map));
  }

  void meetingEvaluationAction(DateTime startDate, DateTime endDate) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(top: 7, left: 20),
                child: Text(
                  Strings.evaluationTitleFirst,
                  softWrap: true,
                  style: TextStyle(
                      fontSize: 20,
                      color: AppColors.color_333333,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    Strings.evaluationTitleSecond,
                    softWrap: true,
                    style: TextStyle(
                        fontSize: 20,
                        color: AppColors.color_333333,
                        fontWeight: FontWeight.w500),
                  ))
            ],
          ),
          Container(
              height: 16,
              padding: EdgeInsets.only(right: 20),
              child: GestureDetector(
                  key: MeetingValueKey.evaluationCloseBtn,
                  child: Image(
                      image: AssetImage(AssetName.iconEvaluationCloseSheet)),
                  onTap: () {
                    _setGlobalMeetingEvaluation(DateTime.now());
                    Navigator.pop(context);
                    isShowNPS = false;
                  }))
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
          child: Text(Strings.evaluationCoreZero,
              style: TextStyle(fontSize: 13, color: AppColors.black_333333))),
      Container(
          padding: EdgeInsets.only(right: 20),
          child: Text(Strings.evaluationCoreTen,
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
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.only(left: 12, right: 12),
                child: TextField(
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
                      hintText: Strings.evaluationHitTextOne +
                          '\n' +
                          Strings.evaluationHitTextTwo +
                          '\n' +
                          Strings.evaluationHitTextThree,
                      hintStyle: TextStyle(
                          fontSize: 14, color: AppColors.color_999999),
                      border: InputBorder.none),
                  style: TextStyle(fontSize: 14, color: AppColors.black_333333),
                ),
              ),
              SafeValueListenableBuilder(
                  valueListenable: evaluationInputStringLength,
                  builder: (BuildContext context, int value, _) {
                    return Container(
                        padding: EdgeInsets.only(right: 12, bottom: 5),
                        alignment: Alignment.centerRight,
                        child: Text(
                          '$value/500',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 12, color: AppColors.colorAAAAAA),
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
          child: Text(Strings.submit,
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
                      Strings.evaluationThankFeedback,
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
                        Strings.evaluationGoHome,
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

  void pushPage(
    String routeName, {
    Object? arguments,
  }) {
    NavUtils.pushNamed(context, routeName,
        pageRoute: NEMeetingUIKit().getMeetingStatus().event ==
                NEMeetingEvent.inMeetingMinimized ||
            NEMeetingUIKit().getMeetingStatus().event ==
                NEMeetingEvent.inMeeting);
  }
}
