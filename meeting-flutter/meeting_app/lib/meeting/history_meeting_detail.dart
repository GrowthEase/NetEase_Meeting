// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/base/util/text_util.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/pre_meeting/transcription_history.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/uikit/utils/nav_utils.dart';
import 'package:nemeeting/uikit/utils/router_name.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import 'package:nemeeting/widget/ne_widget.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';
import '../language/localizations.dart';
import '../service/repo/history_repo.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/values/asset_name.dart';
import '../uikit/values/colors.dart';
import '../utils/integration_test.dart';

class HistoryMeetingDetailRoute extends StatefulWidget {
  final NERemoteHistoryMeeting item;

  HistoryMeetingDetailRoute(this.item);

  @override
  State<StatefulWidget> createState() {
    return _HistoryMeetingDetailRouteState(item);
  }
}

class _HistoryMeetingDetailRouteState
    extends AppBaseState<HistoryMeetingDetailRoute> {
  NERemoteHistoryMeeting item;

  bool hasCloudRecordTask = false;
  bool hasChatHistory = false;
  final recordUrlList = <String>[];
  late NEChatroomInfo chatroomInfo;
  final pluginInfoList = <NEMeetingWebAppItem>[];
  NETimezone? timezone;

  _HistoryMeetingDetailRouteState(this.item);

  final _textStyle = TextStyle(
      fontSize: 14, color: AppColors.color_1E1F27, fontWeight: FontWeight.w500);

  @override
  void initState() {
    super.initState();
    if (AuthManager().accountId == item.ownerUserUuid) {
      NEMeetingKit.instance
          .getPreMeetingService()
          .getMeetingCloudRecordList(item.meetingId)
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
          if (chatroomInfo.exportAccess.index == 1 &&
              chatroomInfo.chatroomId != null &&
              chatroomInfo.chatroomId != 0) {
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
    TimezonesUtil.getTimezoneById(item.timezoneId).then((value) {
      setState(() {
        timezone = value;
      });
    });
  }

  @override
  String getTitle() {
    return getAppLocalizations().meetingDetail;
  }

  @override
  Color getAppBarBackgroundColor() => Colors.transparent;

  @override
  Widget buildCustomAppBar() {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage(
          AssetName.headerBackground,
        ),
        fit: BoxFit.cover,
      )),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildAppBar(),
          buildSubject(),
        ],
      ),
    );
  }

  @override
  Widget buildBody() {
    return Container(
      child: Column(
        children: [
          MeetingCard(children: [
            MeetingListCopyable.withTopCorner(
                title: getAppLocalizations().meetingNum,
                content: TextUtil.applyMask(item.meetingNum, '000-000-0000')),
            buildOwner(),
          ]),
          MeetingCard(children: [
            buildTime(getAppLocalizations().meetingStartTime,
                DateTime.fromMillisecondsSinceEpoch(item.roomStartTime)),
            buildTime(getAppLocalizations().meetingEndTime,
                DateTime.fromMillisecondsSinceEpoch(item.roomEndTime)),
          ]),
          Flexible(child: buildApplicationModule()),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget buildApplicationTitle() {
    return Container(
      padding: EdgeInsets.only(left: 20, top: 20, bottom: 16),
      color: Colors.white,
      width: double.infinity,
      child: Text(
        getAppLocalizations().globalApplication,
        style: TextStyle(
          fontSize: 16,
          color: AppColors.black_333333,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget buildApplicationModule() {
    return MeetingCard(
      children: [
        if (hasCloudRecordTask) Flexible(child: buildCloudRecord()),
        if (hasChatHistory) buildMessageHistory(),
        if (pluginInfoList.isNotEmpty) buildPluginListWidget(),
        buildTranscriptionMessageHistory(),
      ],
    );
  }

  Widget buildMessageHistory() {
    return MeetingArrowItem(
        title: getAppLocalizations().historyChat,
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
                    roomArchiveId: item.meetingId.toString(),
                  ),
                );
              });
        });
  }

  Future<NEResult<List<NEMeetingTranscriptionInfo>>>? transcriptionInfoResult;
  Widget buildTranscriptionMessageHistory() {
    if (AuthManager().accountId != item.ownerUserUuid) return SizedBox.shrink();
    transcriptionInfoResult ??= NEMeetingKit.instance
        .getPreMeetingService()
        .getHistoryMeetingTranscriptionInfo(item.meetingId);
    return FutureBuilder(
        future: transcriptionInfoResult,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox.shrink();
          }
          final result = snapshot.requireData;
          final transcriptionList = result.data;
          if (transcriptionList == null || transcriptionList.isEmpty) {
            return SizedBox.shrink();
          }

          /// 只要有一个已经生成完成，就展示转写入口
          final hasGenerated = transcriptionList.any((e) => e.isGenerated);
          return MeetingArrowItem(
            title: getAppLocalizations().transcription,
            content: !hasGenerated
                ? getAppLocalizations().transcriptionGenerating
                : null,
            contentTextStyle: !hasGenerated
                ? TextStyle(
                    fontSize: 14,
                    color: AppColors.color_337eff,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                  )
                : null,
            showArrow: hasGenerated,
            onTap: hasGenerated
                ? () {
                    if (transcriptionList.length == 1) {
                      TranscriptionMessageHistoryPage.show(
                          context, item.meetingId, transcriptionList.first);
                    } else {
                      NavUtils.pushNamed(
                          context, RouterName.transcriptionTiming,
                          arguments: [item.meetingId, transcriptionList]);
                    }
                  }
                : null,
          );
        });
  }

  Widget buildPluginListWidget() {
    return Container(
        height: (48 * pluginInfoList.length).toDouble(),
        child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: pluginInfoList
                  .map((plugin) => MeetingArrowItem(
                      title: plugin.name,
                      onTap: () async {
                        showMeetingPopupPageRoute(
                            barrierColor: Colors.black.withOpacity(0.8),
                            context: context,
                            routeSettings: RouteSettings(name: plugin.name),
                            builder: (context) {
                              return NEMeetingKit.instance
                                  .getPreMeetingService()
                                  .loadWebAppView(item.meetingId, plugin);
                            });
                      }))
                  .toList(),
            )));
  }

  Widget buildMeetingEnd() {
    return Container(
      height: 66,
      color: AppColors.white,
      child: Center(
          child: Text(getAppLocalizations().meetingCloseByHost,
              style: TextStyle(
                  fontSize: 16,
                  color: AppColors.color_999999,
                  fontWeight: FontWeight.w400))),
    );
  }

  Widget buildSubject() {
    return Padding(
      padding: EdgeInsets.only(left: 20, top: 14, bottom: 16, right: 20),
      child: Row(
        children: [
          Expanded(
              child: Text(
            item.subject,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 20,
                color: AppColors.color_1E1F27,
                fontWeight: FontWeight.w500),
          )),
          NEGestureDetector(
              key: MeetingValueKey.scheduleFavorite,
              child: Container(
                child: Icon(
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

                if (item.isFavorite == true) {
                  final result = await cancelFavorite();
                  if (result.isSuccess()) {
                    item.favoriteId = null;
                  }
                } else {
                  final result = await favouriteMeeting();
                  if (result.isSuccess()) {
                    item.favoriteId = result.data;
                  }
                }
                LoadingUtil.cancelLoading();
                setState(() {});
              })
        ],
      ),
    );
  }

  Widget buildOwner() {
    return Container(
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      child: Row(
        children: [
          Text('${getAppLocalizations().historyMeetingOwner}',
              style: _textStyle),
          Expanded(
              child: Align(
            alignment: Alignment.centerRight,
            child: Text(item.ownerNickname,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.color_53576A,
                  fontWeight: FontWeight.w400,
                )),
          )),
          SizedBox(width: 12.w),
          NEMeetingAvatar.medium(
            url: item.ownerAvatar,
            name: item.ownerNickname,
          )
        ],
      ),
    );
  }

  Widget buildTime(String title, DateTime dateTime) {
    return MeetingArrowItem(
        title: title,
        content:
            '${MeetingTimeUtil.timeFormatWithMinute2(dateTime)} ${timezone?.time ?? ''}',
        showArrow: false);
  }

  Widget buildCloudRecord() {
    final hasRecordItem = recordUrlList.isNotEmpty;
    return Container(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: 16, right: 16, top: 13, bottom: 13),
          child: Row(
            children: [
              Text(
                getAppLocalizations().historyMeetingCloudRecord,
                style: TextStyle(
                  color: AppColors.color_1E1F27,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (!hasRecordItem)
                Expanded(
                  child: Text(
                      textAlign: TextAlign.right,
                      getAppLocalizations()
                          .historyMeetingCloudRecordingFileBeingGenerated,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.color_337eff,
                        fontWeight: FontWeight.w400,
                      )),
                ),
            ],
          ),
        ),
        if (hasRecordItem)
          Flexible(
              child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: recordUrlList
                  .map((url) => Container(
                        padding: EdgeInsets.only(left: 32, right: 16),
                        height: 48,
                        child: Row(
                          children: [
                            Expanded(
                                child: GestureDetector(
                              child: Text(
                                url,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.color_337eff),
                              ),
                              onTap: () => NavUtils.launchByURL(url),
                            )),
                            SizedBox(width: 16),
                            NEGestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: url));
                                  ToastUtils.showToast(context,
                                      getAppLocalizations().globalCopySuccess);
                                },
                                child: Icon(
                                  NEMeetingIconFont.icon_copy,
                                  color: AppColors.color_337EFF,
                                  size: 24,
                                ))
                          ],
                        ),
                      ))
                  .toList(),
            ),
          )),
      ],
    ));
  }

  Future<bool> isNetworkConnect() async {
    var state = await ConnectivityManager().isConnected();
    if (!state) {
      ToastUtils.showToast(
          context, getAppLocalizations().globalNetworkUnavailableCheck);
    }
    return state;
  }

  Future<NEResult<int?>> favouriteMeeting() {
    return HistoryRepo().favoriteMeeting(item.meetingId);
  }

  Future<NEResult<void>> cancelFavorite() {
    return HistoryRepo().cancelFavoriteByRoomArchiveId(item.meetingId);
  }

  Future<NEResult<NERemoteHistoryMeetingDetail>> getHistoryMeetingDetail() {
    return HistoryRepo().getHistoryMeetingDetail(item.meetingId);
  }
}
