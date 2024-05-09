// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:nemeeting/base/util/text_util.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/service/model/chatroom_info.dart';
import 'package:nemeeting/service/model/history_meeting_detail.dart';
import 'package:nemeeting/uikit/utils/nav_utils.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:netease_meeting_assets/netease_meeting_assets.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import '../language/localizations.dart';
import '../service/model/history_meeting.dart';
import '../service/repo/history_repo.dart';
import '../service/response/result.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/values/asset_name.dart';
import '../uikit/values/colors.dart';
import '../utils/integration_test.dart';

class HistoryMeetingDetailRoute extends StatefulWidget {
  final HistoryMeeting item;

  HistoryMeetingDetailRoute(this.item);

  @override
  State<StatefulWidget> createState() {
    return _HistoryMeetingDetailRouteState(item);
  }
}

class _HistoryMeetingDetailRouteState
    extends MeetingBaseState<HistoryMeetingDetailRoute>
    with MeetingAppLocalizationsMixin {
  HistoryMeeting item;
  final myUuid = MeetingUtil.getUuid();

  bool hasCloudRecordTask = false;
  bool hasChatHistory = false;
  final recordUrlList = <String>[];
  late ChatroomInfo chatroomInfo;
  final pluginInfoList = <NEMeetingWebAppItem>[];

  _HistoryMeetingDetailRouteState(this.item);

  final _textStyle = TextStyle(
      fontSize: 14, color: AppColors.black_333333, fontWeight: FontWeight.w400);

  @override
  void initState() {
    super.initState();
    if (myUuid == item.ownerUserUuid) {
      NEMeetingKit.instance
          .getMeetingService()
          .getRoomCloudRecordList(item.roomArchiveId.toString())
          .then((value) {
        if (!mounted) return;
        hasCloudRecordTask = value.isSuccess();
        if (value.isSuccess()) {
          value.data?.forEach((record) {
            recordUrlList.addAll(record.infoList.map((e) => e.url));
          });
        }
        if (mounted) setState(() {});
      });
    }
    getHistoryMeetingDetail().then((value) {
      if (mounted && value.isSuccess() && value.data != null) {
        if (value.data!.chatroomInfo != null) {
          chatroomInfo = value.data!.chatroomInfo!;
          if (chatroomInfo.exportAccess == 1 &&
              chatroomInfo.chatroomId != null) {
            hasChatHistory = true;
            setState(() {});
          }
        }
        if (value.data!.pluginInfoList?.isNotEmpty ?? false) {
          value.data!.pluginInfoList?.forEach((element) {
            pluginInfoList.clear();
            if (element.homeUrl.isNotEmpty &&
                element.pluginId.isNotEmpty &&
                element.name.isNotEmpty) {
              pluginInfoList.add(NEMeetingWebAppItem(
                pluginId: element.pluginId,
                name: element.name,
                icon: element.icon,
                homeUrl: element.homeUrl,
                sessionId: element.sessionId,
              ));
            }
            setState(() {});
          });
        }
      }
    });
  }

  @override
  String getTitle() {
    return meetingAppLocalizations.meetingDetail;
  }

  @override
  Widget buildBody() {
    final sizeBetween = 16.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(color: AppColors.globalBg, height: 1),
        Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildSubject(),
                  SizedBox(height: sizeBetween),
                  buildMeetingNum(),
                  SizedBox(height: sizeBetween),
                  buildStartTime(
                      DateTime.fromMillisecondsSinceEpoch(item.roomStartTime)),
                  SizedBox(height: sizeBetween),
                  buildOwner(),
                  SizedBox(height: sizeBetween),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        if (hasChatHistory || hasCloudRecordTask) buildApplicationTitle(),
        if (hasChatHistory || hasCloudRecordTask || pluginInfoList.isNotEmpty)
          buildApplicationModule()
      ],
    );
  }

  Widget buildApplicationTitle() {
    return Container(
      padding: EdgeInsets.only(left: 20, top: 20, bottom: 16),
      color: Colors.white,
      width: double.infinity,
      child: Text(
        meetingAppLocalizations.globalApplication,
        style: TextStyle(
          fontSize: 16,
          color: AppColors.black_333333,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget buildApplicationModule() {
    return Expanded(
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
          color: Colors.white,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasCloudRecordTask) buildCloudRecord(),
              if (hasCloudRecordTask) SizedBox(height: 10),
              if (hasChatHistory) buildMessageHistory(),
              SizedBox(height: 10),
              if (pluginInfoList.isNotEmpty) buildPluginListWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMessageHistory() {
    return GestureDetector(
        onTap: () async {
          showMeetingPopupPageRoute(
              context: context,
              barrierColor: Colors.black.withOpacity(0.8),
              routeSettings: RouteSettings(name: MeetingChatRoomPage.routeName),
              builder: (context) {
                return NEMeetingUIKitLocalizationsScope(
                  child: MeetingChatRoomPage(
                    arguments: ChatRoomArguments(
                        messageSource: ChatRoomMessageSource()),
                    roomArchiveId: item.roomArchiveId.toString(),
                  ),
                );
              });
        },
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.color_EAEBEC, width: 1),
              color: AppColors.white,
              borderRadius: BorderRadius.circular(4)),
          height: 52,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(
              children: [
                Icon(NEMeetingIconFont.icon_history_message,
                    size: 20, color: AppColors.color_666666),
                SizedBox(width: 6),
                Text(meetingAppLocalizations.historyChat, style: _textStyle)
              ],
            ),
            Icon(NEMeetingIconFont.icon_yx_allowx,
                size: 18, color: AppColors.color_999999)
          ]),
        ));
  }

  Widget buildPluginListWidget() {
    return Container(
        height: (52 * pluginInfoList.length).toDouble(),
        child: ListView.builder(
            itemCount: pluginInfoList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                  onTap: () async {
                    showMeetingPopupPageRoute(
                        barrierColor: Colors.black.withOpacity(0.8),
                        context: context,
                        routeSettings:
                            RouteSettings(name: MeetingWebAppPage.routeName),
                        builder: (context) {
                          return MeetingWebAppPage(
                            roomArchiveId: item.roomArchiveId.toString(),
                            homeUrl: pluginInfoList[index].homeUrl,
                            title: pluginInfoList[index].name,
                            sessionId: pluginInfoList[index].sessionId,
                          );
                        });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: AppColors.color_EAEBEC, width: 1),
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(4)),
                    height: 52,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(NEMeetingIconFont.icon_history_message,
                                  size: 20, color: AppColors.color_666666),
                              SizedBox(width: 6),
                              Text(pluginInfoList[index].name,
                                  style: _textStyle)
                            ],
                          ),
                          Icon(NEMeetingIconFont.icon_yx_allowx,
                              size: 18, color: AppColors.color_999999)
                        ]),
                  ));
            }));
  }

  Widget buildMeetingEnd() {
    return Container(
      height: 66,
      color: AppColors.white,
      child: Center(
          child: Text(meetingAppLocalizations.meetingCloseByHost,
              style: TextStyle(
                  fontSize: 16,
                  color: AppColors.color_999999,
                  fontWeight: FontWeight.w400))),
    );
  }

  Widget buildSubject() {
    return Row(
      children: [
        Expanded(
            child: Text(
          item.subject,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 16,
              color: AppColors.black_333333,
              fontWeight: FontWeight.w500),
        )),
        GestureDetector(
            key: MeetingValueKey.scheduleFavorite,
            child: Container(
              margin: EdgeInsets.only(right: 2),
              child: Image(
                  image: AssetImage(item.isFavorite == true
                      ? AssetName.iconHistoryCollected
                      : AssetName.iconHistoryUncollected),
                  width: 22,
                  height: 22),
            ),
            onTap: () async {
              if (!await isNetworkConnect()) return;
              LoadingUtil.showLoading();

              if (item.isFavorite == true) {
                final result = await cancelFavorite();
                if (result.isSuccess()) {
                  item.isFavorite = false;
                }
              } else {
                final result = await favouriteMeeting();
                if (result.isSuccess() && result.data != null) {
                  item.isFavorite = true;
                  item.favoriteId = result.data;
                }
              }
              LoadingUtil.cancelLoading();
              setState(() {});
            })
      ],
    );
  }

  Widget buildMeetingNum() {
    return Row(
      children: [
        Text(
          '${meetingAppLocalizations.meetingNum}: ${TextUtil.applyMask(item.meetingNum, '000-000-0000')}',
          style: _textStyle,
        ),
        SizedBox(width: 4),
        GestureDetector(
            key: MeetingValueKey.copy,
            onTap: () {
              final value = TextUtil.replace(item.meetingNum, RegExp(r'-'), '');
              Clipboard.setData(ClipboardData(text: value));
              ToastUtils.showToast(
                  context, meetingAppLocalizations.globalCopySuccess);
            },
            child: Icon(
              NEMeetingIconFont.icon_copy1x,
              color: AppColors.color909AB6,
              size: 14,
            ))
      ],
    );
  }

  Widget buildOwner() {
    return Text(
        '${meetingAppLocalizations.historyMeetingOwner}: ${item.ownerNickname}',
        style: _textStyle);
  }

  Widget buildStartTime(DateTime dateTime) {
    return Text(
        '${meetingAppLocalizations.meetingStartTime}: ${MeetingTimeUtil.timeFormatWithMinute2(dateTime)}',
        style: _textStyle);
  }

  Widget buildCloudRecord() {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.color_EAEBEC, width: 1),
            color: AppColors.white,
            borderRadius: BorderRadius.circular(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text('${meetingAppLocalizations.meetingCloudRecordLinks}:', style: _textStyle),
            // SizedBox(height: 12),
            Container(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Row(
                children: [
                  Icon(NEMeetingIconFont.icon_cloud_recording,
                      size: 20, color: AppColors.color_666666),
                  SizedBox(
                    width: 6,
                  ),
                  Text(meetingAppLocalizations.historyMeetingCloudRecord,
                      style: _textStyle)
                ],
              ),
            ),
            Container(
                padding: EdgeInsets.all(16),
                width: double.infinity,
                child: recordUrlList.isNotEmpty
                    ? ListView.separated(
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              Expanded(
                                  child: GestureDetector(
                                child: Text(
                                  recordUrlList[index],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.color_337eff),
                                ),
                                onTap: () =>
                                    NavUtils.launchByURL(recordUrlList[index]),
                              )),
                              SizedBox(width: 4),
                              GestureDetector(
                                  onTap: () {
                                    final value = recordUrlList[index];
                                    Clipboard.setData(
                                        ClipboardData(text: value));
                                    ToastUtils.showToast(
                                        context,
                                        meetingAppLocalizations
                                            .globalCopySuccess);
                                  },
                                  child: Icon(
                                    NEMeetingIconFont.icon_copy1x,
                                    color: AppColors.color909AB6,
                                    size: 14,
                                  ))
                            ],
                          );
                        },
                        itemCount: recordUrlList.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics())
                    : Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)),
                            SizedBox(width: 8),
                            Text(
                                meetingAppLocalizations
                                    .historyMeetingCloudRecordingFileBeingGenerated,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.color_337eff)),
                          ],
                        ),
                      ))
          ],
        ));
  }

  Future<bool> isNetworkConnect() async {
    var state = await ConnectivityManager().isConnected();
    if (!state) {
      ToastUtils.showToast(
          context, meetingAppLocalizations.globalNetworkUnavailableCheck);
    }
    return state;
  }

  Future<Result<int?>> favouriteMeeting() {
    return HistoryRepo().favoriteMeeting(item.roomArchiveId);
  }

  Future<Result<void>> cancelFavorite() {
    return HistoryRepo().cancelFavoriteByRoomArchiveId(item.roomArchiveId);
  }

  Future<Result<HistoryMeetingDetail>> getHistoryMeetingDetail() {
    return HistoryRepo().getHistoryMeetingDetail(item.roomArchiveId);
  }
}
