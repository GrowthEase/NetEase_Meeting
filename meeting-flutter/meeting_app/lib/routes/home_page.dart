// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:nemeeting/base/util/stringutil.dart';
import 'package:flutter/services.dart';
import 'package:nemeeting/utils/const_config.dart';
import 'package:nemeeting/widget/length_text_input_formatter.dart';
import 'package:nemeeting/service/repo/user_repo.dart';
import 'package:nemeeting/uikit/const/consts.dart';
import 'package:nemeeting/base/util/text_util.dart';
import 'package:nemeeting/base/util/timeutil.dart';
import 'package:nemeeting/base/util/url_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netease_common/netease_common.dart';
import 'package:netease_meeting_core/meeting_service.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import 'package:nemeeting/channel/ne_platform_channel.dart';
import 'package:nemeeting/pre_meeting/schedule_meeting_detail.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:nemeeting/utils/privacy_util.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/event_name.dart';
import 'package:nemeeting/service/model/account_app_info.dart';
import 'package:nemeeting/service/profile/app_profile.dart';
import 'package:nemeeting/service/repo/accountinfo_repo.dart';
import 'package:nemeeting/uikit/utils/nav_utils.dart';
import 'package:nemeeting/uikit/utils/router_name.dart';
import 'package:nemeeting/uikit/values/asset_name.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/uikit/values/dimem.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import 'package:nemeeting/uikit/values/strings.dart';

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

  late NEMeetingChannelCallback _callback;

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
    handleDeepLink();
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
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      if (MeetingUtil.getAutoRegistered()) {
        showSettingNickDialog(context);
      }
    });
    GlobalPreferences().meetingInfo.then((meetingInfo) {
      if (TextUtil.isEmpty(meetingInfo)) return;
      var info = jsonDecode(meetingInfo!) as Map?;
      if (info == null) return;
      var meetingId = info['meetingId'] as String?;
      if (meetingId == null) return;
      var currentTime = info['currentTime'] as int;
      var startDate = DateTime.fromMillisecondsSinceEpoch(currentTime);
      var endDate = DateTime.now();
      var minutes = endDate.difference(startDate).inMinutes;
      if (minutes < 15) {
        showRecoverJoinMeetingDialog(meetingId);
      } else {
        Alog.d(tag: tag, content: 'minutes >15 meeting info clean');
        GlobalPreferences().setMeetingInfo('');
      }
    });
  }

  void handleMeetingSdk() {
    _meetingStatusListener = (status) {
      switch (status.event) {
        case NEMeetingEvent.disconnecting:
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
          _setGlobalMeetingInfo(meetingInfo);

          /// 定是写入当前时间,每30秒写入
          timerRecord = Timer.periodic(const Duration(seconds: 30), (timer) {
            //callback function
            _setGlobalMeetingInfo(meetingInfo);
          });
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
          meetingList.removeWhere((e1) => e1.meetingId == element.meetingId);
          if (element.state == NEMeetingState.init ||
              element.state == NEMeetingState.started ||
              element.state == NEMeetingState.ended) {
            meetingList.add(element);
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
                  })
            ],
          );
        });
  }

  void showRecoverJoinMeetingDialog(String meetingId) {
    DialogUtils.showCommonDialog(context, '', Strings.recoverMeeting, () {
      NavUtils.closeCurrentState('cancel');
      GlobalPreferences().setMeetingInfo('');
    }, () async {
      NavUtils.closeCurrentState('ok');
      LoadingUtil.showLoading();
      var settingsService = NEMeetingKit.instance.getSettingsService();
      final result = await NEMeetingUIKit().joinMeetingUI(
          context,
          NEJoinMeetingUIParams(
              meetingId: meetingId, displayName: MeetingUtil.getNickName()),
          NEMeetingUIOptions(
            noVideo:
                !await settingsService.isTurnOnMyVideoWhenJoinMeetingEnabled(),
            noAudio:
                !await settingsService.isTurnOnMyAudioWhenJoinMeetingEnabled(),
            showMeetingTime:
                await settingsService.isShowMyMeetingElapseTimeEnabled(),
            restorePreferredOrientations: [DeviceOrientation.portraitUp],
            extras: {'shareScreenTips': Strings.shareScreenTips},
            noMuteAllVideo: noMuteAllVideo,
            noSip: kNoSip,
            showMeetingRemainingTip: kShowMeetingRemainingTip,
          ));
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

  void handleDeepLink() {
    _callback = (String uri) {
      var meetingId = UrlUtil.getParamValue(uri, UrlUtil.paramMeetingId);
      AppProfile.deepLinkMeetingId = meetingId;
      if (!TextUtil.isEmpty(meetingId)) {
        if (ModalRoute.of(context)!.isCurrent) {
          _onJoinMeeting();
        }
      }
    };
    NEPlatformChannel().listen(_callback);
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
          child: buildMeetingList(),
        )
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

  void _onSchedule() {
    NavUtils.pushNamed(context, RouterName.scheduleMeeting).then((value) {
      if (value == null) return;
      meetingList
          .removeWhere((element) => element.meetingId == value.meetingId);
      meetingList.add(value as NEMeetingItem);
      sortAndGroupData();
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
          )),
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
          if (item.meetingId == null) {
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
                                "${Strings.slashAndMeetingIdPrefix}${TextUtil.applyMask(item.meetingNum ?? "", "000-000-0000")}",
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
                  visible: MeetingUtil.hasShortMeetingId(), child: line()),
              Visibility(
                  visible: MeetingUtil.hasShortMeetingId(),
                  child: buildPersonItem(Strings.shortMeetingId, null,
                      titleTip: Strings.internalDedicated,
                      arrowTip: MeetingUtil.getShortMeetingId())),
              line(),
              buildPersonItem(Strings.personMeetingId, null,
                  arrowTip: MeetingUtil.getMeetingId()),
              // buildSettingItemPadding(),
              // buildSettingItem(
              //     Strings.packageVersion,
              //     () => NavUtils.pushNamed(
              //         context, RouterName.packageVersionSetting,
              //         arguments: _accountAppInfo?.edition),
              //     iconTip: _accountAppInfo?.edition.name ?? ''),
              buildSettingItemPadding(),
              Visibility(
                  visible: MeetingUtil.hasShortMeetingId(), child: line()),
              buildSettingItem(Strings.meetingSetting,
                  () => NavUtils.pushNamed(context, RouterName.meetingSetting)),
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
              buildSettingItem(Strings.about,
                  () => NavUtils.pushNamed(context, RouterName.about)),
              Container(
                height: 22,
                color: AppColors.globalBg,
              ),
              // Expanded(
              //   flex: 1,
              //   child: Container(
              //     color: AppColors.global_bg,
              //   ),
              // )
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
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                Widget>[
              Spacer(),
              Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(bottom: 2),
                  child: Text(
                    nick,
                    style:
                        TextStyle(fontSize: 20, color: AppColors.black_222222),
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
                  style: TextStyle(fontSize: 13, color: AppColors.color_999999),
                  textAlign: TextAlign.left,
                ),
              ),
              Spacer(),
            ]),
            Spacer(),
            Icon(IconFont.iconyx_allowx, size: 14, color: AppColors.greyCCCCCC)
          ],
        ),
      ),
      onTap: () => NavUtils.pushNamed(context, RouterName.personalSetting,
          arguments: _accountAppInfo?.appName ?? Strings.defaultCompanyName),
    );
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
    NEPlatformChannel().unListen(_callback);
    NEMeetingUIKit().removeListener(_meetingStatusListener);
    NEMeetingKit.instance
        .getPreMeetingService()
        .unRegisterScheduleMeetingStatusChange(scheduleCallback);
    NEMeetingKit.instance.removeAuthListener(this);
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
      'meetingId': currentMeetingInfo?.meetingId,
      'currentTime': TimeUtil.getCurrentTimeMilliseconds()
    };
    GlobalPreferences().setMeetingInfo(jsonEncode(map));
  }
}
