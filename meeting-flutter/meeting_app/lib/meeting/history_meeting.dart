// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:nemeeting/uikit/state/meeting_base_state.dart';
import 'package:nemeeting/uikit/values/asset_name.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/widget/ne_widget.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';
import '../language/localizations.dart';
import '../service/repo/history_repo.dart';
import '../uikit/values/fonts.dart';
import '../uikit/values/Ints.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/base/util/text_util.dart';
import '../utils/integration_test.dart';
import 'history_meeting_detail.dart';

class HistoryMeetingRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HistoryMeetingRouteState();
  }
}

class _HistoryMeetingRouteState extends AppBaseState<HistoryMeetingRoute> {
  int _currentIndex = 0;
  late PageController _pageController;

  /// 全部会议p
  List<NERemoteHistoryMeeting> allMeetingList = <NERemoteHistoryMeeting>[];

  /// 收藏会议
  List<NERemoteHistoryMeeting> favoriteMeetingList = <NERemoteHistoryMeeting>[];

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
      await updateAllMeetings(startId: lastMeeting.anchorId, isAppend: true);
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
  String getTitle() {
    return getAppLocalizations().historyMeeting;
  }

  @override
  Widget buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[buildSelectionBoxes(), buildDataListViews()],
    );
  }

  Future<void> updateAllMeetings({int? startId, bool isAppend = false}) async {
    if (!await ConnectivityManager().isConnected()) {
      ToastUtils.showToast(
          context, getAppLocalizations().globalNetworkUnavailableCheck);
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

  void sortAndGroupData(List<NERemoteHistoryMeeting> list) {
    var temp = <NERemoteHistoryMeeting>[];

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
          list.add(NERemoteHistoryMeeting(roomEntryTime: last));
          list.add(element);
        }
      });
    }
    if (mounted) {
      setState(() {});
    }
  }

  void sortAndGroupFavoriteData(List<NERemoteHistoryMeeting> list) {
    var temp = <NERemoteHistoryMeeting>[];

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
          list.add(NERemoteHistoryMeeting(roomEntryTime: last));
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
      color: Colors.white,
      child: Row(
        children: <Widget>[
          buildSelectedItem(
              0, _currentIndex == 0, getAppLocalizations().historyAllMeeting),
          buildSelectedItem(1, _currentIndex == 1,
              getAppLocalizations().historyCollectMeeting)
        ],
      ),
    );
  }

  Widget buildSelectedItem(int index, bool selected, String title) {
    return Expanded(
      child: NEGestureDetector(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                height: 48,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.color_1E1F27,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                )),
            Container(
                color: selected ? AppColors.color_337eff : AppColors.white,
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
      return buildEmptyView(getAppLocalizations().historyMeetingListEmpty);
    }
    return ListView.builder(
        key: MeetingValueKey.historyMeetingList,
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
          getAppLocalizations().historyCollectMeetingListEmpty);
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
        padding: EdgeInsets.only(left: 20, top: 5, bottom: 5),
        color: AppColors.globalBg,
        child: Text(
          DateTime.now().year > dateTime.year
              ? "${dateTime.year}${getAppLocalizations().globalYear}${dateTime.month}${getAppLocalizations().globalMonth}${dateTime.day}${getAppLocalizations().globalDay}  ${dateTime.weekday.toWeekday(context)}"
              : "${dateTime.month}${getAppLocalizations().globalMonth}${dateTime.day}${getAppLocalizations().globalDay}  ${dateTime.weekday.toWeekday(context)}",
          style: TextStyle(fontSize: 14, color: AppColors.color_53576A),
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
    required NERemoteHistoryMeeting item,
    bool isInFavoritePage = false,
    bool showBottomDivider = true,
  }) {
    final spanBetween = TextSpan(
        text: " | ",
        style: TextStyle(color: AppColors.color_CDCFD7, fontSize: 14));
    final spanTextStyle =
        TextStyle(color: AppColors.color_3D3D3D, fontSize: 14);
    return NEGestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 84,
            padding: EdgeInsets.symmetric(horizontal: 20),
            color: AppColors.white,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          item.subject,
                          style: TextStyle(
                              fontSize: 16,
                              color: AppColors.color_1E1F27,
                              fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text.rich(
                          key: MeetingValueKey.historyMeetingItemTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          TextSpan(children: [
                            TextSpan(
                              text:
                                  '${MeetingTimeUtil.timeFormatHourMinute(DateTime.fromMillisecondsSinceEpoch(item.roomStartTime))}-${MeetingTimeUtil.timeFormatHourMinute(DateTime.fromMillisecondsSinceEpoch(item.roomEndTime))}',
                              style: spanTextStyle,
                            ),
                            spanBetween,
                            TextSpan(
                              text:
                                  '${TextUtil.applyMask(item.meetingNum, "000-000-0000")}',
                              style: spanTextStyle,
                            ),
                            spanBetween,
                            TextSpan(
                              text: '${item.ownerNickname}',
                              style: spanTextStyle,
                            ),
                          ])),
                    ],
                  ),
                ),
                buildFavoriteStar(item, isInFavoritePage),
              ],
            ),
          ),
          if (showBottomDivider)
            Container(
              width: 20,
              height: 1,
              color: AppColors.white,
            ),
        ],
      ),
      onTap: () {
        final isFavorite = item.isFavorite;
        Navigator.of(context)
            .push(NEMeetingPageRoute(
                builder: (context) => HistoryMeetingDetailRoute(item)))
            .then((value) {
          /// 收藏状态变更，则刷新收藏列表
          if (item.isFavorite != isFavorite) {
            allMeetingList.forEach((element) {
              if (element.meetingId == item.meetingId) {
                element.favoriteId = item.favoriteId;
              }
            });
            updateFavoriteMeetings();
          }
        });
      },
    );
  }

  Widget buildFavoriteStar(NERemoteHistoryMeeting item, bool isInFavoritePage) {
    return NEGestureDetector(
        child: Container(
          child: Icon(
            key: MeetingValueKey.scheduleFavorite,
            IconFont.icon_collect,
            size: 22,
            color: item.isFavorite == true
                ? AppColors.color_FF7903
                : AppColors.colorE6E7EB,
          ),
        ),
        onTap: () async {
          if (!await isNetworkConnect()) return;
          LoadingUtil.showLoading();

          /// 取消收藏
          if (item.isFavorite == true) {
            final result = await cancelFavorite(item.meetingId);
            if (result.isSuccess()) {
              allMeetingList.forEach((element) {
                if (element.meetingId == item.meetingId) {
                  element.favoriteId = null;
                }
              });
              sortAndGroupData(allMeetingList);

              /// 如果在收藏页面直接移除，否则刷新收藏列表
              if (isInFavoritePage) {
                favoriteMeetingList
                    .removeWhere((e) => e.meetingId == item.meetingId);
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
            final result = await favouriteMeeting(item.meetingId);
            if (result.isSuccess()) {
              allMeetingList.forEach((element) {
                if (element.meetingId == item.meetingId) {
                  element.favoriteId = result.data;
                }
              });
              sortAndGroupData(allMeetingList);
              await updateFavoriteMeetings();
              LoadingUtil.cancelLoading();
            }
          }
        });
  }

  Future<bool> isNetworkConnect() async {
    if (!await ConnectivityManager().isConnected()) {
      ToastUtils.showToast(
          context, getAppLocalizations().globalNetworkUnavailableCheck);
      return false;
    }
    return true;
  }

  Future<NEResult<int>> favouriteMeeting(int meetingId) {
    return HistoryRepo().favoriteMeeting(meetingId);
  }

  Future<NEResult<void>> cancelFavorite(int meetingId) {
    return HistoryRepo().cancelFavoriteByRoomArchiveId(meetingId);
  }
}
