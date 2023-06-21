// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nemeeting/service/repo/history_repo.dart';
import 'package:nemeeting/uikit/values/asset_name.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import '../uikit/values/fonts.dart';
import '../uikit/values/strings.dart';
import '../uikit/values/Ints.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/base/util/timeutil.dart';
import 'package:nemeeting/base/util/text_util.dart';
import 'package:netease_meeting_assets/netease_meeting_assets.dart';
import '../service/model/history_meeting.dart';

class HistoryMeetingRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HistoryMeetingRouteState();
  }
}

class _HistoryMeetingRouteState
    extends LifecycleBaseState<HistoryMeetingRoute> {
  int _currentIndex = 0;
  late PageController _pageController;

  /// 全部会议p
  List<HistoryMeeting> allMeetingList = <HistoryMeeting>[];

  /// 收藏会议
  List<FavoriteMeeting> favoriteMeetingList = <FavoriteMeeting>[];

  ScrollController _allMeetingScrollController = ScrollController();
  ScrollController _favoriteMeetingScrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _allMeetingScrollController.addListener(_allMeetingListener);
    _favoriteMeetingScrollController.addListener(_favoriteMeetingListener);
    allMeetings();
    favoruteMeetings();
  }

  @override
  void dispose() {
    _allMeetingScrollController.removeListener(_allMeetingListener);
    _favoriteMeetingScrollController.removeListener(_favoriteMeetingListener);
    super.dispose();
  }

  void _allMeetingListener() {
    if (_allMeetingScrollController.offset >=
            _allMeetingScrollController.position.maxScrollExtent &&
        !_allMeetingScrollController.position.outOfRange) {
      var lastMeeting = allMeetingList.last;
      allMeetings(false, lastMeeting.attendeeId);
    }
  }

  void _favoriteMeetingListener() {
    if (_favoriteMeetingScrollController.offset >=
            _favoriteMeetingScrollController.position.maxScrollExtent &&
        !_favoriteMeetingScrollController.position.outOfRange) {
      var lastMeeting = favoriteMeetingList.last;
      favoruteMeetings(false, lastMeeting.favoriteId);
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
          Strings.historyMeeting,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.black_222222, fontSize: 17),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[buildSelectionBoxes(), buildDataListViews()],
      ),
    );
  }

  void allMeetings([bool isLoading = true, int? startId]) async {
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      ToastUtils.showToast(context, Strings.networkUnavailableCheck);
      return;
    }
    if (isLoading) LoadingUtil.showLoading();
    HistoryRepo().getAllHistoryMeetings(startId).then((result) {
      if (result.code != HttpCode.success) {
        if (isLoading) LoadingUtil.cancelLoading();
        return;
      }
      if (startId == null) {
        allMeetingList.clear();
      }
      if (result.data != null) {
        allMeetingList.addAll(result.data!);
      }
      sortAndGroupData(allMeetingList);
      if (isLoading) LoadingUtil.cancelLoading();
    });
  }

  void favoruteMeetings([bool isLoading = true, int? startId]) {
    if (isLoading) LoadingUtil.showLoading();
    HistoryRepo().getFavoriteMeetings(startId).then((result) {
      if (result.code != HttpCode.success) {
        if (isLoading) LoadingUtil.cancelLoading();
        return;
      }
      if (startId == null) {
        favoriteMeetingList.clear();
      }
      if (result.data != null) {
        favoriteMeetingList.addAll(result.data!);
      }
      sortAndGroupFavoriteData(favoriteMeetingList);
      if (isLoading) LoadingUtil.cancelLoading();
    });
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

  void sortAndGroupFavoriteData(List<FavoriteMeeting> list) {
    var temp = <FavoriteMeeting>[];

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
          list.add(FavoriteMeeting.group(last));
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
          buildSelectedItem(0, _currentIndex == 0, Strings.history_allMeeting),
          buildSelectedItem(
              1, _currentIndex == 1, Strings.history_collectMeeting)
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
      return buildEmptyView();
    }
    return ListView.builder(
        // padding: EdgeInsets.only(left: 20, bottom: 20),
        itemCount: allMeetingList.length,
        itemBuilder: (context, index) {
          var item = allMeetingList[index];
          if (item.meetingNum == "") {
            return buildTimeTitle(item.roomEntryTime);
          } else {
            return buildMeetingItem(item);
          }
        },
        controller: _allMeetingScrollController);
  }

  Widget buildCollectMeetingUI() {
    if (favoriteMeetingList.isEmpty) {
      return buildEmptyView();
    }
    return ListView.builder(
        itemCount: favoriteMeetingList.length,
        itemBuilder: (context, index) {
          var item = favoriteMeetingList[index];
          if (item.meetingNum == "") {
            return buildTimeTitle(item.roomEntryTime);
          } else {
            return buildMeetingItem(item);
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
              ? "${dateTime.year}${Strings.year}${dateTime.month}${Strings.month}${dateTime.day}${Strings.day}  ${dateTime.weekday.toWeekday()}"
              : "${dateTime.month}${Strings.month}${dateTime.day}${Strings.day}  ${dateTime.weekday.toWeekday()}",
          style: TextStyle(fontSize: 14, color: AppColors.color_666666),
        ));
  }

  /// 缺省图
  Widget buildEmptyView() {
    return Center(
      child: SingleChildScrollView(
        child: Column(children: [
          Image(
            image: AssetImage(AssetName.emptyHistoryMeetingList),
          ),
          Text(
            Strings.historyMeetingListEmpty,
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

  Widget buildMeetingItem<T>(T item) {
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
                        Text.rich(TextSpan(children: [
                          TextSpan(
                            text: (item is HistoryMeeting)
                                ? '${TimeUtil.timeFormatHourMinute(DateTime.fromMillisecondsSinceEpoch(item.roomEntryTime))}'
                                : '${TimeUtil.timeFormatHourMinute(DateTime.fromMillisecondsSinceEpoch((item as FavoriteMeeting).roomEntryTime))}',
                            style: TextStyle(
                                color: AppColors.black_222222, fontSize: 12),
                          ),
                          TextSpan(
                              text: (item is HistoryMeeting)
                                  ? "${Strings.slashAndMeetingNumPrefix}${TextUtil.applyMask(item.meetingNum, "000-000-0000")}"
                                  : "${Strings.slashAndMeetingNumPrefix}${TextUtil.applyMask((item as FavoriteMeeting).meetingNum, "000-000-0000")}",
                              style: TextStyle(
                                  color: AppColors.color_999999, fontSize: 12))
                        ])),
                        SizedBox(width: 10),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: Icon(NEMeetingIconFont.icon_copy1x,
                              size: 11, color: AppColors.color_337eff),
                          onTap: () {
                            Clipboard.setData(ClipboardData(
                                text: (item is HistoryMeeting)
                                    ? item.meetingNum
                                    : (item as FavoriteMeeting).meetingNum));
                            ToastUtils.showToast(context, Strings.copySuccess);
                          },
                        )
                      ],
                    ),
                    SizedBox(height: 4),
                    Container(
                      margin: EdgeInsets.only(right: 50),
                      child: Text(
                        (item is HistoryMeeting)
                            ? item.subject
                            : (item as FavoriteMeeting).subject,
                        style: TextStyle(
                            fontSize: 16, color: AppColors.black_222222),
                      ),
                    ),
                  ],
                ))
              ],
            ),
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
                      image: AssetImage((item is HistoryMeeting)
                          ? (item.isFavorite == true
                              ? AssetName.iconHistoryCollected
                              : AssetName.iconHistoryUncollected)
                          : AssetName.iconHistoryCollected),
                      width: 21,
                      height: 20),
                ),
                onTap: () async {
                  if (item is HistoryMeeting) {
                    if (item.isFavorite == true) {
                      isNetworkConnect().then((value) {
                        if (value) {
                          return cancelFavorite(item.roomArchiveId);
                        } else {
                          return Future.value(-1);
                        }
                      }).then((code) {
                        if (code == 0) {
                          allMeetingList.forEach((element) {
                            if (element.roomArchiveId == item.roomArchiveId) {
                              element.isFavorite = null;
                              element.favoriteId = null;
                            }
                          });
                          sortAndGroupData(allMeetingList);
                          favoruteMeetings();
                        }
                      });
                    } else {
                      isNetworkConnect().then((value) {
                        if (value) {
                          return favouriteMeeting(item.roomArchiveId);
                        } else {
                          return Future.value(null);
                        }
                      }).then((value) {
                        if (value != null) {
                          allMeetingList.forEach((element) {
                            if (element.roomArchiveId == item.roomArchiveId) {
                              element.favoriteId = value;
                              element.isFavorite = true;
                            }
                          });
                          sortAndGroupData(allMeetingList);
                          favoruteMeetings(false);
                        }
                      });
                    }
                  } else {
                    isNetworkConnect().then((value) {
                      if (value) {
                        return cancelFavorite(
                            (item as FavoriteMeeting).roomArchiveId);
                      } else {
                        return Future.value(-1);
                      }
                    }).then((code) {
                      if (code == 0) {
                        favoriteMeetingList.removeWhere((element) =>
                            (item as FavoriteMeeting).roomArchiveId ==
                            element.roomArchiveId);
                        sortAndGroupFavoriteData(favoriteMeetingList);
                        allMeetings(false);
                      }
                    });
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<bool> isNetworkConnect() async {
    var state =
        await Connectivity().checkConnectivity() != ConnectivityResult.none;
    if (!state) {
      ToastUtils.showToast(context, Strings.networkUnavailableCheck);
    }
    return state;
  }

  Future<int?> favouriteMeeting(int roomArchiveId) async {
    LoadingUtil.showLoading();
    var result = await HistoryRepo().favourteMeeting(roomArchiveId);
    LoadingUtil.cancelLoading();
    if (result.code == 0) {
      return result.data;
    }
    return null;
  }

  Future<int> cancelFavorite(int roomArchiveId) async {
    LoadingUtil.showLoading();
    var result =
        await HistoryRepo().cancelFavoriteByRoomArchiveId(roomArchiveId);
    LoadingUtil.cancelLoading();
    return result.code;
  }
}
