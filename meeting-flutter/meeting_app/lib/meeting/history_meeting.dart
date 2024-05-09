// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:nemeeting/service/repo/history_repo.dart';
import 'package:nemeeting/uikit/values/asset_name.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import '../language/localizations.dart';
import '../service/response/result.dart';
import '../uikit/values/fonts.dart';
import '../uikit/values/Ints.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/base/util/text_util.dart';
import 'package:netease_meeting_assets/netease_meeting_assets.dart';
import '../service/model/history_meeting.dart';
import '../utils/integration_test.dart';
import 'history_meeting_detail.dart';

class HistoryMeetingRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HistoryMeetingRouteState();
  }
}

class _HistoryMeetingRouteState extends LifecycleBaseState<HistoryMeetingRoute>
    with MeetingAppLocalizationsMixin {
  int _currentIndex = 0;
  late PageController _pageController;

  /// 全部会议p
  List<HistoryMeeting> allMeetingList = <HistoryMeeting>[];

  /// 收藏会议
  List<HistoryMeeting> favoriteMeetingList = <HistoryMeeting>[];

  ScrollController _allMeetingScrollController = ScrollController();
  ScrollController _favoriteMeetingScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _allMeetingScrollController.addListener(_scrollToLoadMeetingListener);
    _favoriteMeetingScrollController
        .addListener(_scrollToLoadFavoriteMeetingListener);
    updateAllMeetings();
    updateFavoriteMeetings();
  }

  @override
  void dispose() {
    _allMeetingScrollController.removeListener(_scrollToLoadMeetingListener);
    _favoriteMeetingScrollController
        .removeListener(_scrollToLoadFavoriteMeetingListener);
    super.dispose();
  }

  void _scrollToLoadMeetingListener() async {
    if (_allMeetingScrollController.offset >=
            _allMeetingScrollController.position.maxScrollExtent &&
        !_allMeetingScrollController.position.outOfRange) {
      var lastMeeting = allMeetingList.last;
      LoadingUtil.showLoading();
      await updateAllMeetings(startId: lastMeeting.attendeeId, isAppend: true);
      LoadingUtil.cancelLoading();
    }
  }

  void _scrollToLoadFavoriteMeetingListener() async {
    if (_favoriteMeetingScrollController.offset >=
            _favoriteMeetingScrollController.position.maxScrollExtent &&
        !_favoriteMeetingScrollController.position.outOfRange) {
      var lastMeeting = favoriteMeetingList.last;
      LoadingUtil.showLoading();
      await updateFavoriteMeetings(
          startId: lastMeeting.favoriteId, isAppend: true);
      LoadingUtil.cancelLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.globalBg,
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              key: MeetingValueKey.back,
              icon: const Icon(
                IconFont.iconyx_returnx,
                size: 18,
                color: AppColors.black_333333,
              ),
              onPressed: () {
                Navigator.maybePop(context);
              },
            );
          },
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          meetingAppLocalizations.historyMeeting,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.black_222222,
              fontSize: 17,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[buildSelectionBoxes(), buildDataListViews()],
      ),
    );
  }

  Future<void> updateAllMeetings({int? startId, bool isAppend = false}) async {
    if (!await ConnectivityManager().isConnected()) {
      ToastUtils.showToast(
          context, meetingAppLocalizations.globalNetworkUnavailableCheck);
      return;
    }
    final result = await HistoryRepo().getAllHistoryMeetings(startId);

    if (result.code != HttpCode.success) {
      return;
    }
    if (!isAppend) {
      allMeetingList.clear();
    }
    if (result.data != null) {
      allMeetingList.addAll(result.data!);
    }
    sortAndGroupData(allMeetingList);
  }

  Future<void> updateFavoriteMeetings(
      {int? startId, bool isAppend = false}) async {
    final result = await HistoryRepo().getFavoriteMeetings(startId: startId);
    if (result.code != HttpCode.success) {
      return;
    }
    if (!isAppend) {
      favoriteMeetingList.clear();
    }
    if (result.data != null) {
      favoriteMeetingList.addAll(result.data!);
    }
    sortAndGroupFavoriteData(favoriteMeetingList);
  }

  void sortAndGroupData(List<HistoryMeeting> list) {
    var temp = <HistoryMeeting>[];

    /// step 1, filter meetingId is null, self insert data
    list.removeWhere((element) => element.meetingNum == "");
    temp.addAll(list);

    /// step 3, group, high efficiency
    list.clear();
    if (temp.isNotEmpty) {
      var last = 0;
      temp.forEach((element) {
        var time = DateTime.fromMillisecondsSinceEpoch(element.roomEntryTime);
        var itemDay =
            DateTime(time.year, time.month, time.day).millisecondsSinceEpoch;
        if (itemDay == last) {
          list.add(element);
        } else {
          last = itemDay;
          list.add(HistoryMeeting.group(last));
          list.add(element);
        }
      });
    }
    if (mounted) {
      setState(() {});
    }
  }

  void sortAndGroupFavoriteData(List<HistoryMeeting> list) {
    var temp = <HistoryMeeting>[];

    /// step 1, filter meetingId is null, self insert data
    list.removeWhere((element) => element.meetingNum == "");
    temp.addAll(list);

    /// step 3, group, high efficiency
    list.clear();
    if (temp.isNotEmpty) {
      var last = 0;
      temp.forEach((element) {
        var time = DateTime.fromMillisecondsSinceEpoch(element.roomEntryTime);
        var itemDay =
            DateTime(time.year, time.month, time.day).millisecondsSinceEpoch;
        if (itemDay == last) {
          list.add(element);
        } else {
          last = itemDay;
          list.add(HistoryMeeting.group(last));
          list.add(element);
        }
      });
    }
    if (mounted) {
      setState(() {});
    }
  }

  Widget buildSelectionBoxes() {
    return Container(
      height: 45,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          buildSelectedItem(
              0, _currentIndex == 0, meetingAppLocalizations.historyAllMeeting),
          buildSelectedItem(1, _currentIndex == 1,
              meetingAppLocalizations.historyCollectMeeting)
        ],
      ),
    );
  }

  Widget buildSelectedItem(int index, bool selected, String titile) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                height: 43,
                child: Text(
                  titile,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: selected
                          ? AppColors.black_333333
                          : AppColors.color_666666,
                      fontSize: 15),
                )),
            Container(
                color: selected ? AppColors.color_007AFF : AppColors.white,
                height: 2),
          ],
        ),
        onTap: () {
          _onTap(index);
        },
      ),
    );
  }

  void _onTap(int value) {
    _pageController.jumpToPage(value);
  }

  Widget buildDataListViews() {
    return Flexible(
      child: PageView(
        controller: _pageController,
        onPageChanged: onPageChanged,
        allowImplicitScrolling: true,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [buildAllMeetingUI(), buildCollectMeetingUI()],
      ),
    );
  }

  void onPageChanged(int value) {
    if (_currentIndex == value) return;
    if (mounted) {
      setState(() {
        _currentIndex = value;
      });
    }
  }

  Widget buildAllMeetingUI() {
    if (allMeetingList.isEmpty) {
      return buildEmptyView(meetingAppLocalizations.historyMeetingListEmpty);
    }
    return ListView.builder(
        itemCount: allMeetingList.length,
        itemBuilder: (context, index) {
          var item = allMeetingList[index];
          if (item.meetingNum == "") {
            return buildTimeTitle(item.roomEntryTime);
          } else {
            return buildMeetingItem(
              item: item,
              showBottomDivider: index + 1 < allMeetingList.length &&
                  allMeetingList[index + 1].meetingNum != "",
            );
          }
        },
        controller: _allMeetingScrollController);
  }

  Widget buildCollectMeetingUI() {
    if (favoriteMeetingList.isEmpty) {
      return buildEmptyView(
          meetingAppLocalizations.historyCollectMeetingListEmpty);
    }
    return ListView.builder(
        itemCount: favoriteMeetingList.length,
        itemBuilder: (context, index) {
          var item = favoriteMeetingList[index];
          if (item.meetingNum == "") {
            return buildTimeTitle(item.roomEntryTime);
          } else {
            return buildMeetingItem(
              item: item,
              isInFavoritePage: true,
              showBottomDivider: index + 1 < favoriteMeetingList.length &&
                  favoriteMeetingList[index + 1].meetingNum != "",
            );
          }
        },
        controller: _favoriteMeetingScrollController);
  }

  Widget buildTimeTitle(int time) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    return Container(
        padding: EdgeInsets.only(left: 20, bottom: 8),
        color: AppColors.globalBg,
        height: 44,
        alignment: Alignment.bottomLeft,
        child: Text(
          DateTime.now().year > dateTime.year
              ? "${dateTime.year}${meetingAppLocalizations.globalYear}${dateTime.month}${meetingAppLocalizations.globalMonth}${dateTime.day}${meetingAppLocalizations.globalDay}  ${dateTime.weekday.toWeekday(context)}"
              : "${dateTime.month}${meetingAppLocalizations.globalMonth}${dateTime.day}${meetingAppLocalizations.globalDay}  ${dateTime.weekday.toWeekday(context)}",
          style: TextStyle(fontSize: 14, color: AppColors.color_666666),
        ));
  }

  /// 缺省图
  Widget buildEmptyView(String content) {
    return Center(
      child: SingleChildScrollView(
        child: Column(children: [
          Image(
            image: AssetImage(AssetName.emptyHistoryMeetingList),
          ),
          Text(
            content,
            style: TextStyle(
                fontSize: 13,
                color: AppColors.color_666666,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none),
          )
        ]),
      ),
    );
  }

  Widget buildMeetingItem({
    required HistoryMeeting item,
    bool isInFavoritePage = false,
    bool showBottomDivider = true,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.only(left: 20),
        height: 72,
        color: AppColors.white,
        // color:Color.fromRGBO(Random().nextInt(256), Random().nextInt(256), Random().nextInt(256), 1),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image(
                    image: AssetImage(AssetName.iconCalendar),
                    width: 24,
                    height: 24),
                SizedBox(width: 26),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text.rich(
                            key: MeetingValueKey.historyMeetingItemTitle,
                            TextSpan(children: [
                              TextSpan(
                                text:
                                    '${MeetingTimeUtil.timeFormatHourMinute(DateTime.fromMillisecondsSinceEpoch(item.roomEntryTime))}',
                                style: TextStyle(
                                    color: AppColors.black_222222,
                                    fontSize: 12),
                              ),
                              TextSpan(
                                  text:
                                      " | ${meetingAppLocalizations.meetingNum}:${TextUtil.applyMask(item.meetingNum, "000-000-0000")}",
                                  style: TextStyle(
                                      color: AppColors.color_999999,
                                      fontSize: 12))
                            ])),
                        SizedBox(width: 10),
                        GestureDetector(
                          key: MeetingValueKey.scheduleMeetingIdCopy,
                          behavior: HitTestBehavior.opaque,
                          child: Icon(NEMeetingIconFont.icon_copy1x,
                              size: 11, color: AppColors.color_337eff),
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: item.meetingNum));
                            ToastUtils.showToast(context,
                                meetingAppLocalizations.globalCopySuccess);
                          },
                        )
                      ],
                    ),
                    SizedBox(height: 4),
                    Container(
                      margin: EdgeInsets.only(right: 50),
                      child: Text(
                        item.subject,
                        style: TextStyle(
                            fontSize: 16, color: AppColors.black_222222),
                      ),
                    ),
                  ],
                ))
              ],
            ),
            if (showBottomDivider)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(left: 50),
                  height: 0.5,
                  color: AppColors.color_999999,
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                  child: Container(
                    margin: EdgeInsets.only(right: 25),
                    child: Image(
                        key: MeetingValueKey.scheduleFavorite,
                        image: AssetImage(item.isFavorite == true
                            ? AssetName.iconHistoryCollected
                            : AssetName.iconHistoryUncollected),
                        width: 21,
                        height: 20),
                  ),
                  onTap: () async {
                    if (!await isNetworkConnect()) return;
                    LoadingUtil.showLoading();

                    /// 取消收藏
                    if (item.isFavorite == true) {
                      final result = await cancelFavorite(item.roomArchiveId);
                      if (result.isSuccess()) {
                        allMeetingList.forEach((element) {
                          if (element.roomArchiveId == item.roomArchiveId) {
                            element.isFavorite = null;
                            element.favoriteId = null;
                          }
                        });
                        sortAndGroupData(allMeetingList);

                        /// 如果在收藏页面直接移除，否则刷新收藏列表
                        if (isInFavoritePage) {
                          favoriteMeetingList.removeWhere(
                              (e) => e.roomArchiveId == item.roomArchiveId);
                          sortAndGroupFavoriteData(favoriteMeetingList);
                          LoadingUtil.cancelLoading();
                        } else {
                          await updateFavoriteMeetings();
                          LoadingUtil.cancelLoading();
                        }
                      }
                    }

                    /// 点击收藏
                    else {
                      final result = await favouriteMeeting(item.roomArchiveId);
                      if (result.isSuccess() && result.data != null) {
                        allMeetingList.forEach((element) {
                          if (element.roomArchiveId == item.roomArchiveId) {
                            element.favoriteId = result.data;
                            element.isFavorite = true;
                          }
                        });
                        sortAndGroupData(allMeetingList);
                        await updateFavoriteMeetings();
                        LoadingUtil.cancelLoading();
                      }
                    }
                  }),
            )
          ],
        ),
      ),
      onTap: () {
        final isFavorite = item.isFavorite;
        Navigator.of(context)
            .push(MaterialMeetingAppPageRoute(
                builder: (context) => HistoryMeetingDetailRoute(item)))
            .then((value) {
          /// 收藏状态变更，则刷新收藏列表
          if (item.isFavorite != isFavorite) {
            allMeetingList.forEach((element) {
              if (element.roomArchiveId == item.roomArchiveId) {
                element.isFavorite = item.isFavorite;
              }
            });
            updateFavoriteMeetings();
          }
        });
      },
    );
  }

  Future<bool> isNetworkConnect() async {
    if (!await ConnectivityManager().isConnected()) {
      ToastUtils.showToast(
          context, meetingAppLocalizations.globalNetworkUnavailableCheck);
      return false;
    }
    return true;
  }

  Future<Result<int?>> favouriteMeeting(int roomArchiveId) {
    return HistoryRepo().favoriteMeeting(roomArchiveId);
  }

  Future<Result<void>> cancelFavorite(int roomArchiveId) {
    return HistoryRepo().cancelFavoriteByRoomArchiveId(roomArchiveId);
  }
}
