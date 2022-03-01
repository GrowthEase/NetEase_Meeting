// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:yunxin_base/yunxin_base.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import 'package:base/util/textutil.dart';
import 'package:base/util/timeutil.dart';
import 'package:base/util/url_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:yunxin_meeting/meeting_sdk.dart';
import 'package:yunxin_meeting/meeting_sdk_interface.dart';
import 'package:yunxin_meeting/meeting_uikit.dart';
import 'package:nemeeting/channel/ne_platform_channel.dart';
import 'package:nemeeting/pre_meeting/schedule_meeting_detail.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:nemeeting/utils/privacy_util.dart';
import 'package:service/auth/auth_manager.dart';
import 'package:service/client/http_code.dart';
import 'package:service/event_name.dart';
import 'package:service/model/account_app_info.dart';
import 'package:service/profile/app_profile.dart';
import 'package:service/repo/accountinfo_repo.dart';
import 'package:uikit/const/packages.dart';
import 'package:uikit/utils/nav_utils.dart';
import 'package:uikit/utils/router_name.dart';
import 'package:uikit/values/asset_name.dart';
import 'package:uikit/values/colors.dart';
import 'package:uikit/values/dimem.dart';
import 'package:uikit/values/fonts.dart';
import 'package:uikit/values/strings.dart';

///会议中心
class HomePageRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageRouteState();
  }
}

class _HomePageRouteState extends LifecycleBaseState<HomePageRoute>
    implements  NEMeetingAuthListener, ControlListener {
  late PageController _pageController;

  int _currentIndex = 0;

  late Callback _callback;

  late EventCallback _eventCallback;

  late NERoomStatusListener _meetingStatusListener;

  List<NERoomItem> meetingList = <NERoomItem>[];
  bool isBeautyFaceEnabled = false;

  late ScheduleCallback<List<NERoomItem>> scheduleCallback;
  AccountAppInfo? _accountAppInfo;
  NEMeetingAuthListener? _meetingAuthListener;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: _currentIndex);
    lifecycleListen(AuthManager().authInfoStream(), (event) {
      setState(() {});
    });
    lifecycleExecuteUI(AccountInfoRepo().getAccountAppInfo()).then((result) {
      if (result?.code == HttpCode.success) {
        _accountAppInfo = result?.data;
        setState(() {});
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
    NEMeetingSDK.instance
        .getSettingsService()
        .isBeautyFaceEnabled()
        .then((value) {
      setState(() {
        isBeautyFaceEnabled = value;
      });
    });
  }

  void handleMeetingSdk() {
    _meetingStatusListener = (status) {
      if (status.event == NEMeetingEvent.disconnecting) {
        if (status.arg == NEMeetingCode.closeByHost) {
          showCloseDialog();
        }
      }
    };
    NEMeetingSDK.instance.getMeetingService().addListener(_meetingStatusListener);
    NEMeetingSDK.instance.addAuthListener(this);
    NEMeetingSDK.instance
        .getControlService()
        .setOnSettingMenuItemClickListener((menuItem, meetingInfo) {
      NavUtils.pushNamed(context, RouterName.controlSetting);
    });
    NEMeetingSDK.instance.getControlService().registerControlListener(this);
  }

  void scheduleMeeting() {
    getMeetingList();
    scheduleCallback = (List<NERoomItem> data, bool incremental) {
      if (incremental) {
        data.forEach((element) {
          meetingList.removeWhere((e1) => e1.roomUniqueId == element.roomUniqueId);
          if (element.status == NERoomItemStatus.init ||
              element.status == NERoomItemStatus.started ||
              element.status == NERoomItemStatus.ended) {
            meetingList.add(element);
          }
        });
      } else {
        meetingList.clear();
        meetingList.addAll(data);
      }
      sortAndGroupData();
    };
    NEMeetingSDK.instance
        .getPreMeetingService()
        .registerScheduleMeetingStatusChange(scheduleCallback);
  }

  void getMeetingList() {
    NEMeetingSDK.instance.getPreMeetingService().getMeetingList([
      NERoomItemStatus.init,
      NERoomItemStatus.started,
      NERoomItemStatus.ended,
    ]).then((NEResult<List<NERoomItem>> result) {
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
    var temp = <NERoomItem>[];
    temp.addAll(meetingList);

    /// step 1, filter meetingUniqueId is null, self insert data
    temp.removeWhere((value) => value.roomUniqueId == null);

    /// step 2, sort
    temp.sort((value1, value2) {
      var t = value1.startTime - value2.startTime;
      if (t == 0) {
        return value1.createTime - value2.createTime;
      } else {
        return t;
      }
    });

    /// step 3, group, high efficiency
    meetingList.clear();
    if (temp.isNotEmpty) {
      var last = 0;
      temp.forEach((element) {
        var time = DateTime.fromMillisecondsSinceEpoch(element.startTime);
        var itemDay = DateTime(time.year, time.month, time.day).millisecondsSinceEpoch;
        if (itemDay == last) {
          meetingList.add(element);
        } else {
          last = itemDay;
          meetingList.add(NERoomItem()..startTime = last);
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
              boxShadow: [BoxShadow(color: AppColors.color_19000000, offset: Offset(0, -2), blurRadius: 2)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                buildTabItem(0, _currentIndex == 0, AssetName.tabHomeSelect, AssetName.tabHome),
                buildTabItem(1, _currentIndex == 1, AssetName.tabSettingSelect, AssetName.tabSetting),
              ],
            )));
  }

  Widget buildTabItem(int index, bool select, String selectAsset, String normalAsset) {
    return GestureDetector(
      key: index == 0 ? MeetingValueKey.tabHomeSelect : MeetingValueKey.tabSettingSelect,
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _onTap(index);
      },
      child: Image.asset(select ? selectAsset : normalAsset, package: Packages.uiKit, width: 130, height: 32),
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
            buildItem(AssetName.createMeeting, Strings.createMeeting, _onCreateMeeting),
            buildItem(AssetName.joinMeeting, Strings.joinMeeting, _onJoinMeeting),
            buildItem(AssetName.scheduleMeeting, Strings.scheduleMeeting, _onSchedule),
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
      meetingList.removeWhere((element) => element.roomUniqueId == value.roomUniqueId);
      meetingList.add(value as NERoomItem);
      sortAndGroupData();
    });
  }

  Widget buildMeetingList() {
    if (meetingList.isEmpty) {
      return Center(
          child: SingleChildScrollView(
              child: Column(
                children: [
                  Image(image: AssetImage(AssetName.emptyMeetingList, package: Packages.uiKit)),
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
          if (item.roomUniqueId == null) {
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
            text: '   ${dateTime.month}${Strings.month} ${getTimeSuffix(dateTime)}',
            style: TextStyle(fontSize: 14, color: AppColors.black_222222))
      ])),
    );
  }

  String getTimeSuffix(DateTime dateTime) {
    var now = DateTime.now();
    var tomorrow = now.add(Duration(days: 1));
    if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
      return Strings.today;
    } else if (dateTime.year == tomorrow.year && dateTime.month == tomorrow.month && dateTime.day == tomorrow.day) {
      return Strings.tomorrow;
    }
    return '';
  }

  Widget buildMeetingItem(NERoomItem item) {
    var valueKey = '${item.roomUniqueId}&${item.roomId}';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      key: MeetingValueKey.dynamicValueKey(valueKey),
      child: Container(
          height: 72,
          child: Stack(children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image(image: AssetImage(AssetName.iconCalendar, package: Packages.uiKit), width: 24, height: 24),
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
                            style: TextStyle(color: AppColors.black_222222, fontSize: 12)),
                        TextSpan(
                            text:
                            "${Strings.slashAndMeetingIdPrefix}${TextUtil.applyMask(item.roomId ?? "", "000-000-0000")}",
                            style: TextStyle(color: AppColors.color_999999, fontSize: 12)),
                        TextSpan(
                            text: ' ${getItemStatus(item.status)}',
                            style: TextStyle(color: getItemStatusColor(item.status), fontSize: 12))
                      ])),
                      SizedBox(height: 4),
                      Container(
                        margin: EdgeInsets.only(right: 40),
                        child: Text(item.subject ?? '',
                            style: TextStyle(fontSize: 16, color: AppColors.black_222222)),
                      ),
                      MeetingValueKey.addTextWidgetValueKey(text:valueKey),
                    ],
                  ),
                ),
              ],
            ),
            Align(
                alignment: Alignment.centerRight,
                child: Container(
                    margin: EdgeInsets.only(right: 20),
                    child: Icon(IconFont.iconyx_allowx, size: 14, color: AppColors.greyCCCCCC))),
            Align(
                alignment: Alignment.bottomCenter,
                widthFactor: 1.0,
                child: Container(margin: EdgeInsets.only(left: 52), height: 0.5, color: AppColors.colorE6E7EB))
          ])),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ScheduleMeetingDetailRoute(item);
        }));
        //NavUtils.pushNamed(context, RouterName.scheduleMeetingDetail);
      },
    );
  }

  Color getItemStatusColor(NERoomItemStatus status) {
    if (status == NERoomItemStatus.started) {
      return AppColors.color_337eff;
    }
    return AppColors.color_999999;
  }

  String getItemStatus(NERoomItemStatus status) {
    // if (status == null) {
    //   return Strings.meetingStatusInvalid;
    // }
    switch (status) {
      case NERoomItemStatus.init:
        return Strings.meetingStatusInit;
      case NERoomItemStatus.invalid:
        return Strings.meetingStatusInvalid;
      case NERoomItemStatus.started:
        return Strings.meetingStatusStarted;
      case NERoomItemStatus.ended:
        return Strings.meetingStatusEnded;
      case NERoomItemStatus.cancel:
        return Strings.meetingStatusCancel;
      case NERoomItemStatus.recycled:
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
                image: AssetImage(assetStr, package: Packages.uiKit),
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
              buildUserInfo(nick: MeetingUtil.getNickName(), company: _accountAppInfo?.appName ?? ''),
              Visibility(visible: MeetingUtil.hasShortMeetingId(), child: line()),
              Visibility(
                  visible: MeetingUtil.hasShortMeetingId(),
                  child: buildPersonItem(Strings.shortMeetingId, null,
                      titleTip: Strings.internalDedicated, arrowTip: MeetingUtil.getShortMeetingId())),
              line(),
              buildPersonItem(Strings.personMeetingId, null, arrowTip: MeetingUtil.getMeetingId()),
              buildSettingItemPadding(),
              buildSettingItem(
                  Strings.packageVersion,
                  () => NavUtils.pushNamed(context, RouterName.packageVersionSetting,
                      arguments: _accountAppInfo?.edition),
                  iconTip: _accountAppInfo?.edition.name ?? ''),
              buildSettingItemPadding(),
              Visibility(visible: MeetingUtil.hasShortMeetingId(), child: line()),
              buildSettingItem(Strings.meetingSetting, () => NavUtils.pushNamed(context, RouterName.meetingSetting)),
              Visibility(visible: isBeautyFaceEnabled, child: buildSettingItemPadding()),
              Visibility(
                  visible: isBeautyFaceEnabled,
                  child: buildSettingItem(
                      Strings.beautySetting, () => NEMeetingSDK.instance.getSettingsService().openBeautyUI(context))),
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
            Column(
                crossAxisAlignment:CrossAxisAlignment.start,
                children: <Widget>[
                  Spacer(),
                  Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(bottom: 2),
                      child: Text(nick, style: TextStyle(fontSize: 20, color: AppColors.black_222222),
                          textAlign: TextAlign.center,
                          textDirection:TextDirection.ltr
                      )),
                  Container(
                    width: MediaQuery.of(context).size.width *2/3,
                    child: Text(company,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: AppColors.color_999999),
                      textAlign: TextAlign.left,),
                  ),
                  Spacer(),
                ]),
            Spacer(),
            Icon(IconFont.iconyx_allowx, size: 14, color: AppColors.greyCCCCCC)
          ],
        ),
      ),
      onTap: () => NavUtils.pushNamed(context, RouterName.personalSetting,
          arguments: _accountAppInfo?.appName ?? ''),
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

  Widget buildSettingItem(String title, VoidCallback voidCallback,{String iconTip = ''}) {
    return GestureDetector(
      child: Container(
        height: Dimen.primaryItemHeight,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
        child: Row(
          children: <Widget>[
            Text(title, style: TextStyle(fontSize: 16, color: AppColors.black_222222)),
            Spacer(),
            iconTip==''? Container(): Text(iconTip, style: TextStyle(fontSize: 14, color: AppColors.color_999999)),
            Container(width: 10,),
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
            arrowTip==''? Container(): Text(arrowTip, style: TextStyle(fontSize: 14, color: AppColors.color_999999),),
            Container(width: 20,),
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
    var status = NEMeetingSDK.instance.getMeetingService().getMeetingStatus().event;
    var navigator = Navigator.of(context);
    Future.delayed(Duration(seconds: status == NEMeetingEvent.idle ? 0 : 3), () {
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
                  onPressed: () =>
                      navigator.pushNamedAndRemoveUntil(RouterName.entrance, (Route<dynamic> route) => false),
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
    NEMeetingSDK.instance.getMeetingService().removeListener(_meetingStatusListener);
    NEMeetingSDK.instance.getPreMeetingService().unRegisterScheduleMeetingStatusChange(scheduleCallback);
    NEMeetingSDK.instance.removeAuthListener(this);
    NEMeetingSDK.instance.getControlService().unRegisterControlListener(this);
    super.dispose();
  }

  @override
  void onJoinMeetingResult(NEControlResult result) {
    if (result.code != NEMeetingErrorCode.success) {
      ToastUtils.showToast(context, result.message);
    }
  }

  @override
  void onStartMeetingResult(NEControlResult result) {
    if (result.code != NEMeetingErrorCode.success) {
      ToastUtils.showToast(context, result.message);
    }
  }

  @override
  void onUnbind(int unBindType){
    if(unBindType == NEUnbindType.tvUnbind) {
      ToastUtils.showToast(context, Strings.tvUnbind);
      NavUtils.popUntil(context, RouterName.homePage);
    }else if(unBindType == NEUnbindType.forceUnbind){
      ToastUtils.showToast(context, Strings.controlUnbind);
      NavUtils.popUntil(context, RouterName.homePage);
    }
  }

  Widget line() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
      color: AppColors.colorE8E9EB,
      height: 0.5,
    );
  }

  @override
  void onTCProtocolUpgrade(NETCProtocolUpgrade protocolUpgrade) {
    Alog.d(
        tag:tag,
        content: 'onTCProtocolUpgrade protocolUpgrade = $protocolUpgrade');
    if (!(protocolUpgrade.isCompatible)) {
      ToastUtils.showToast(context, Strings.tcProtocolNotCompatible);
    }
  }
}
