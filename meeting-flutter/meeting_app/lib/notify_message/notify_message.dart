// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/service/repo/history_repo.dart';
import 'package:nemeeting/widget/ne_widget.dart';
import 'package:netease_common/netease_common.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';
import '../meeting/history_meeting_detail.dart';
import '../pre_meeting/schedule_meeting_detail.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/values/asset_name.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/fonts.dart';

class MeetingAppNotifyCenter extends StatefulWidget {
  final String sessionId;
  final void Function()? onClearAllMessage;

  MeetingAppNotifyCenter({required this.sessionId, this.onClearAllMessage});

  @override
  State<StatefulWidget> createState() {
    return MeetingAppNotifyCenterState();
  }
}

class MeetingAppNotifyCenterState extends AppBaseState<MeetingAppNotifyCenter>
    with NEMeetingMessageChannelListener {
  ValueNotifier<List<NEMeetingSessionMessage>> _messageListListenable =
      ValueNotifier([]);

  ValueListenable<List<NEMeetingSessionMessage>> get messageListListenable =>
      _messageListListenable;
  bool isShowClearDialogDialog = false;
  ScrollController _scrollController = ScrollController();
  int? toTime;
  final NEMeetingMessageChannelService _messageChannelService =
      NEMeetingKit.instance.getMeetingMessageChannelService();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreData();
      }
    });
    lifecycleExecuteUI(_messageChannelService
        .clearUnreadCount(widget.sessionId)
        .then((result) async {
      if (result.isSuccess()) {
        widget.onClearAllMessage?.call();
      }
    }));
    _loadMoreData();
    _messageChannelService.addMeetingMessageChannelListener(this);
  }

  @override
  Widget buildBody() {
    double appBarHeight = AppBar().preferredSize.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return NotificationListener<ScrollNotification>(
        child: SafeValueListenableBuilder(
            valueListenable: messageListListenable,
            builder: (BuildContext context, List<NEMeetingSessionMessage> value,
                Widget? child) {
              return value.length > 0
                  ? Container(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return NEGestureDetector(
                            child: buildNotifyMessageItem(context, index),
                            onTap: () {
                              pushPage(index);
                            },
                          );
                        },
                        itemCount: value.length,
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.only(
                          bottom: appBarHeight + statusBarHeight),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image(
                              image:
                                  AssetImage(AssetName.iconNotificationEmpty),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              NEMeetingUIKitLocalizations.of(context)!
                                  .notifyCenterNoMessage,
                              style: TextStyle(
                                  fontSize: 14, color: AppColors.color_222222),
                            )
                          ],
                        ),
                      ));
            }));
  }

  @override
  String getTitle() {
    return NEMeetingUIKitLocalizations.of(context)!.notifyCenter;
  }

  @override
  List<Widget> buildActions() {
    return <Widget>[
      _messageListListenable.value.isNotEmpty
          ? TextButton(
              child: Icon(
                IconFont.icon_delete,
                size: 24,
                color: AppColors.color_53576A,
              ),
              onPressed: _messageListListenable.value.isNotEmpty
                  ? showClearDialog
                  : null,
            )
          : Container()
    ];
  }

  /// 显示清空对话框
  Future<void> showClearDialog() async {
    /// 会议中不支持操作
    if (NEMeetingKit.instance.getMeetingService().getCurrentMeetingInfo() !=
        null) {
      ToastUtils.showToast(context,
          NEMeetingUIKitLocalizations.of(context)!.globalOperationFail);
      return;
    }

    if (isShowClearDialogDialog) return;
    if (!await ConnectivityManager().isConnected()) {
      ToastUtils.showToast(
          context, NEMeetingUIKitLocalizations.of(context)!.networkAbnormality);
      return;
    }
    isShowClearDialogDialog = true;
    showCupertinoDialog(
        context: context,
        builder: (BuildContext buildContext) => CupertinoAlertDialog(
              content: Text(NEMeetingUIKitLocalizations.of(context)!
                  .notifyCenterAllClear),
              actions: <Widget>[
                CupertinoDialogAction(
                    child: Text(
                        NEMeetingUIKitLocalizations.of(context)!.globalCancel),
                    onPressed: () {
                      Navigator.of(context).pop();
                      isShowClearDialogDialog = false;
                    }),
                CupertinoDialogAction(
                    child: Text(
                        NEMeetingUIKitLocalizations.of(context)!.globalSure),
                    onPressed: () {
                      lifecycleExecuteUI(_messageChannelService
                          .deleteAllSessionMessage(widget.sessionId)
                          .then((result) {
                        if (!mounted) return;
                        if (result.isSuccess()) {
                          setState(() {
                            _messageListListenable.value.clear();
                          });
                        }
                        Navigator.of(context).pop();
                        isShowClearDialogDialog = false;
                      }));
                    })
              ],
            ));
  }

  /// 构建通知消息item
  /// [index] index 对应的数据
  /// [context] context 对应的上下文
  /// [notifyData] notifyData 对应通知的数据
  Widget buildNotifyMessageItem(BuildContext context, int index) {
    var notifyData = _messageListListenable.value[index].data;
    CardData? data = null;
    if (notifyData != null) {
      data = NotifyCardData.fromMap(jsonDecode(notifyData)).data;
    }
    int? timeStamp = data?.timestamp;
    var header = data?.notifyCard?.header;
    String? icon = header?.icon;
    var notifyCenterCardClickAction =
        data?.notifyCard?.notifyCenterCardClickAction;
    var body = data?.notifyCard?.body;
    return Container(
      margin: EdgeInsets.only(
          top: 16,
          bottom: index == _messageListListenable.value.length ? 16 : 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          color: AppColors.white,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              buildHeader(icon, header, timeStamp),
              if (body?.title?.isNotEmpty == true)
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 16, top: 12, right: 16),
                  child: Text(
                    '${body?.title}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.black_333333,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              if (body?.content?.isNotEmpty == true)
                Container(
                  alignment: Alignment.centerLeft,
                  padding:
                      EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 12),
                  child: Text(
                    '${body?.content}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 10,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.color_53576A,
                      height: 1.5,
                    ),
                  ),
                ),
              if (notifyCenterCardClickAction != null)
                Container(
                  height: 0.5,
                  margin: EdgeInsets.only(left: 16, right: 16),
                  color: AppColors.colorE8E9EB,
                ),
              if (notifyCenterCardClickAction != null)
                buildDetailItem(
                    NEMeetingUIKitLocalizations.of(context)!
                        .notifyCenterViewingDetails, () {
                  pushPage(index);
                })
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetailItem(String title, VoidCallback voidCallback,
      {String iconTip = ''}) {
    return NEGestureDetector(
      child: Container(
        height: 43,
        padding: EdgeInsets.only(left: 16, right: 16),
        alignment: Alignment.center,
        child: Row(
          children: <Widget>[
            Text(title,
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.black_222222,
                    fontWeight: FontWeight.normal)),
            Spacer(),
            iconTip == ''
                ? Container()
                : Text(iconTip,
                    style:
                        TextStyle(fontSize: 14, color: AppColors.color_999999)),
            Container(
              width: 10,
            ),
            Icon(IconFont.iconyx_allowx, size: 12, color: AppColors.greyCCCCCC)
          ],
        ),
      ),
      onTap: voidCallback,
    );
  }

  void _loadMoreData() {
    var param = NEMeetingGetMessageHistoryParams(
      sessionId: widget.sessionId,
      fromTime: 0,
      limit: 20,
      toTime: toTime,
    );
    lifecycleExecuteUI(
        _messageChannelService.getSessionMessagesHistory(param).then((value) {
      if (value.isSuccess() && value.data != null && value.data!.isNotEmpty) {
        setState(() {
          toTime = value.data?.last.time;
          _messageListListenable.value.addAll(value.data!);
        });
      }
    }));
  }

  /// 收到新的会话消息
  @override
  void onSessionMessageReceived(NEMeetingSessionMessage message) {
    if (message.sessionId == widget.sessionId) {
      setState(() {
        final index = _messageListListenable.value.firstIndexOf((element) {
          return message.time >= element.time;
        });
        if (index == -1) {
          _messageListListenable.value.add(message);
        } else {
          _messageListListenable.value.insert(index, message);
          if (index == 0) {
            postOnFrame(() {
              _scrollController.animateTo(0,
                  duration: Duration(milliseconds: 100), curve: Curves.easeIn);
            });
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _messageChannelService
      ..removeMeetingMessageChannelListener(this)
      ..clearUnreadCount(widget.sessionId);
    _scrollController.dispose();
    _messageListListenable.value.clear();
    super.dispose();
  }

  /// 跳转到对应的页面
  void pushPage(int index) {
    var message = _messageListListenable.value[index].data;
    if (TextUtils.isEmpty(message)) return;
    final data = NotifyCardData.fromMap(jsonDecode(message!)).data;
    final type = data?.type;
    if (type == null) return;
    switch (type) {
      case NotifyCenterCardType.meetingNewRecordFile:
        _pushMeetingHistory(data);
        break;
      case NotifyCenterCardType.meetingScheduleInvite:
      case NotifyCenterCardType.meetingScheduleInfoUpdate:
        _pushMeetingScheduleDetail(data);
        break;
      default:
        break;
    }
  }

  /// 跳转到会议历史详情
  void _pushMeetingHistory(CardData? data) {
    if (data?.meetingId == null) return;
    HistoryRepo()
        .getHistoryMeetingDetailsByMeetingId(data!.meetingId!)
        .then((value) {
      if (value.isSuccess() && value.data != null) {
        Navigator.of(context).push(NEMeetingPageRoute(
            builder: (context) => HistoryMeetingDetailRoute(
                value.data as NERemoteHistoryMeeting)));
      } else {
        ToastUtils.showToast(
            context,
            NEMeetingUIKitLocalizations.of(context)!
                .notifyCenterViewDetailsUnsupported);
      }
    });
  }

  /// 跳转到会议日程详情
  void _pushMeetingScheduleDetail(CardData? data) {
    if (data?.meetingId == null) return;
    NEMeetingKit.instance
        .getPreMeetingService()
        .getMeetingItemById(data!.meetingId!)
        .then((value) {
      if (value.isSuccess() && value.data != null) {
        Navigator.of(context).push(NEMeetingPageRoute(
            settings: RouteSettings(name: ScheduleMeetingDetailRoute.routeName),
            builder: (context) => ScheduleMeetingDetailRoute(value.data!)));
      } else {
        ToastUtils.showToast(
            context,
            NEMeetingUIKitLocalizations.of(context)!
                .notifyCenterViewDetailsUnsupported);
      }
    });
  }

  /// 构建头部
  /// [icon] icon 对应的url
  /// [header] header 对应的数据
  /// [timeStamp] 时间戳
  ///
  Widget buildHeader(String? icon, Header? header, int? timeStamp) {
    return GestureDetector(
      child: Container(
        height: 48,
        padding: EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.color_FDFDFD,
              AppColors.color_FDFDFD,
              AppColors.color_F7F7F7,
            ],
            stops: [0.0, 0.90, 1.0],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null && icon.isNotEmpty)
              Container(
                padding: EdgeInsets.only(right: 10),
                child: CachedNetworkImage(
                  width: 24,
                  height: 24,
                  imageUrl: icon,
                  fit: BoxFit.cover,
                ),
              ),
            Expanded(
              child: Text(
                '${header?.subject}',
                overflow: TextOverflow.ellipsis,
                maxLines: 5,
                style: TextStyle(
                    fontSize: 16,
                    color: AppColors.color_1E1F27,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 16),
              child: Text(
                timeStamp != null
                    ? MeetingTimeUtil.getTimeFormatMDHM(timeStamp)
                    : NEMeetingUIKitLocalizations.of(context)!.globalNothing,
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.color_8D90A0,
                    fontWeight: FontWeight.normal),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NotifyCenterCardType {
  /// 录制文件生成通知
  static const String meetingNewRecordFile = 'MEETING.NEW_RECORD_FILE';

  /// 预约会议更新通知
  static const String meetingScheduleInfoUpdate =
      'MEETING.SCHEDULE.INFO.UPDATE';

  /// 预约会议邀请通知
  static const String meetingScheduleInvite = 'MEETING.SCHEDULE.INVITE';

  /// 预约会议取消通知
  static const String meetingScheduleCancel = 'MEETING.SCHEDULE.CANCEL';

  /// 预约成员被移除通知
  static const String meetingScheduleMemberRemove =
      'MEETING.SCHEDULE.MEMBER.REMOVED';
}
