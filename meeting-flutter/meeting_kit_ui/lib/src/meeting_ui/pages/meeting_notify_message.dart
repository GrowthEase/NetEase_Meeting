// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingUINotifyMessagePage extends StatefulWidget {
  static const String routeName = "/meetingNotifyCenter";
  final void Function() onClearAllMessage;
  final List<String> sessionIdList;
  final ValueListenable<List<NEMeetingSessionMessage>> messageList;
  final NERoomContext roomContext;
  final List<NESingleStateMenuItem<NEMeetingWebAppItem>>? webAppList;

  MeetingUINotifyMessagePage(
      {required this.onClearAllMessage,
      required this.sessionIdList,
      required this.messageList,
      required this.roomContext,
      required this.webAppList});

  @override
  State<StatefulWidget> createState() {
    return MeetingUINotifyMessagePageState();
  }
}

class MeetingUINotifyMessagePageState
    extends LifecycleBaseState<MeetingUINotifyMessagePage>
    with MeetingKitLocalizationsMixin, MeetingStateScope {
  bool isShowClearDialogDialog = false;
  ScrollController _scrollController = ScrollController();
  int toTime = 0;
  List<String> _sessionIdList = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeValueListenableBuilder(
        valueListenable: widget.messageList,
        builder: (context, messageList, child) {
          postOnFrame(() {
            if (messageList.isNotEmpty) {
              _scrollController.animateTo(0,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeIn);
            }
          });
          return Scaffold(
            appBar: TitleBar(
              leading: messageList.isNotEmpty
                  ? TextButton(
                      onPressed: showClearDialog,
                      child: Icon(
                        NEMeetingIconFont.icon_delete,
                        color: _UIColors.color33333E,
                        size: 24,
                      ),
                    )
                  : null,
              title: TitleBarTitle(
                NEMeetingUIKitLocalizations.of(context)!.notifyCenter,
              ),
            ),
            body: _buildBody(messageList.toList()),
          );
        });
  }

  Future<void> showClearDialog() async {
    if (isShowClearDialogDialog) return;
    if (!await ConnectivityManager().isConnected()) {
      ToastUtils.showToast(
          context, NEMeetingUIKitLocalizations.of(context)!.networkAbnormality);
      return;
    }
    isShowClearDialogDialog = true;
    var cancel = NEMeetingUIKitLocalizations.of(context)!.globalCancel;
    var sure = NEMeetingUIKitLocalizations.of(context)!.globalSure;
    var clearAllNotifyCenter =
        NEMeetingUIKitLocalizations.of(context)!.notifyCenterAllClear;
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              content: Text(clearAllNotifyCenter),
              actions: <Widget>[
                CupertinoDialogAction(
                    child: Text(cancel),
                    onPressed: () {
                      Navigator.of(context).pop();
                      isShowClearDialogDialog = false;
                    }),
                CupertinoDialogAction(
                    child: Text(sure),
                    onPressed: () {
                      Navigator.of(context).pop();
                      isShowClearDialogDialog = false;
                      _sessionIdList.forEach(NEMeetingKit.instance
                          .getMeetingMessageChannelService()
                          .deleteAllSessionMessage);
                      widget.onClearAllMessage.call();
                    })
              ],
            ));
  }

  Widget buildNotifyMessageItem(
      BuildContext context, NEMeetingSessionMessage item) {
    int? timeStamp = item.data?.data?.timestamp;
    CardData? cardData = item.data?.data;
    NotifyCard? notifyCard = cardData?.notifyCard;
    return GestureDetector(
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                height: 48,
                padding: EdgeInsets.only(left: 16, top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 8),
                      child: MeetingCachedNetworkImage.CachedNetworkImage(
                        width: 28,
                        height: 28,
                        imageUrl: '${notifyCard?.header?.icon}',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${notifyCard?.header?.subject}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 5,
                        style: TextStyle(
                            fontSize: 16,
                            color: _UIColors.color_999999,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 16),
                      child: Text(
                        timeStamp != null
                            ? MeetingTimeUtil.getTimeFormatMDHM(timeStamp)
                            : NEMeetingUIKitLocalizations.of(context)!
                                .globalNothing,
                        style: TextStyle(
                            fontSize: 14,
                            color: _UIColors.color_999999,
                            fontWeight: FontWeight.normal),
                      ),
                    )
                  ],
                ),
              ),
              if (notifyCard?.body?.title?.isNotEmpty == true)
                Container(
                  alignment: Alignment.centerLeft,
                  padding:
                      EdgeInsets.only(left: 16, top: 6, bottom: 2, right: 16),
                  child: Text(
                    '${notifyCard?.body?.title}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: _UIColors.black_333333,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              Container(
                alignment: Alignment.centerLeft,
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                child: Text(
                  '${notifyCard?.body?.content}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 10,
                  style: TextStyle(
                    fontSize: 14,
                    color: _UIColors.color_666666,
                  ),
                ),
              ),
              Container(
                height: 0.5,
                margin: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                color: _UIColors.colorE8E9EB,
              ),
              if (notifyCard?.notifyCenterCardClickAction != null)
                buildDetailItem(
                    NEMeetingUIKitLocalizations.of(context)!
                        .notifyCenterViewingDetails, () {
                  pushPage(cardData);
                }),
            ],
          ),
        ),
        onTap: () {
          pushPage(cardData);
        });
  }

  Widget buildDetailItem(String title, VoidCallback voidCallback,
      {String iconTip = ''}) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
        child: Row(
          children: <Widget>[
            Text(title,
                style: TextStyle(
                    fontSize: 14,
                    color: _UIColors.black_222222,
                    fontWeight: FontWeight.normal)),
            Spacer(),
            iconTip == ''
                ? Container()
                : Text(iconTip,
                    style:
                        TextStyle(fontSize: 14, color: _UIColors.color_999999)),
            Container(
              width: 10,
            ),
            Icon(NEMeetingIconFont.icon_yx_allowx,
                size: 12, color: _UIColors.greyCCCCCC)
          ],
        ),
      ),
      onTap: voidCallback,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    toTime = 0;
    // 退出时清空未读消息数
    _sessionIdList.forEach((element) {
      NEMeetingKit.instance
          .getMeetingMessageChannelService()
          .clearUnreadCount(element);
    });
    super.dispose();
  }

  Widget _buildBody(List<NEMeetingSessionMessage> messageList) {
    messageList.sort((a, b) => b.time.compareTo(a.time));
    return messageList.isEmpty
        ? Container(
            color: _UIColors.colorF2F3F5,
            padding: EdgeInsets.only(bottom: 24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(NEMeetingImages.noMessageHistory,
                      package: NEMeetingImages.package),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    NEMeetingUIKitLocalizations.of(context)!
                        .notifyCenterNoMessage,
                    style: TextStyle(
                        fontSize: 14,
                        color: _UIColors.color_666666,
                        decoration: TextDecoration.none),
                  )
                ],
              ),
            ))
        : Container(
            padding: EdgeInsets.all(16),
            child: ListView.separated(
              controller: _scrollController,
              separatorBuilder: (context, index) => SizedBox(height: 6),
              itemBuilder: (context, index) {
                return buildNotifyMessageItem(context, messageList[index]);
              },
              itemCount: messageList.length,
              shrinkWrap: true,
            ),
          );
  }

  void _initData() {
    _sessionIdList = widget.sessionIdList;
    ConnectivityManager().isConnected().then((connected) {
      if (!mounted) return;
      if (!connected) {
        ToastUtils.showToast(context,
            NEMeetingUIKitLocalizations.of(context)!.networkAbnormality);
      } else {
        _sessionIdList.forEach((element) {
          NEMeetingKit.instance
              .getMeetingMessageChannelService()
              .clearUnreadCount(element);
        });
      }
    });
  }

  void pushPage(CardData? cardData) {
    if (cardData != null &&
        cardData.notifyCard?.notifyCenterCardClickAction != null) {
      var item;
      if (cardData.pluginId != null) {
        item = widget.webAppList?.firstWhere((value) =>
            value.singleStateItem.customObject?.pluginId == cardData.pluginId);
      }

      if (cardData.pluginId != null && item != null) {
        MeetingNotifyCenterActionUtil.openPlugin(
            context, widget.roomContext, item);
      } else {
        ToastUtils.showToast(
            context,
            NEMeetingUIKitLocalizations.of(context)!
                .notifyCenterViewDetailsUnsupported);
      }
    }
  }
}
