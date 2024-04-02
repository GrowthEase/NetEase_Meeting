// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingUINotifyMessagePage extends StatefulWidget {
  static const String routeName = "/meetingNotifyCenter";
  final void Function() onClearAllMessage;
  final List<String> sessionIdList;
  final List<NEMeetingCustomSessionMessage> messageList;
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
  ValueNotifier<List<NEMeetingCustomSessionMessage>> _messageListListenable =
      ValueNotifier([]);

  ValueListenable<List<NEMeetingCustomSessionMessage>>
      get messageListListenable => _messageListListenable;
  bool isShowClearDialogDialog = false;
  ScrollController _scrollController = ScrollController();
  int toTime = 0;
  List<String> _sessionIdList = [];
  late final List<NEMeetingCustomSessionMessage> _messageList;
  final _radius = Radius.circular(8);

  @override
  void initState() {
    super.initState();
    _sessionIdList = widget.sessionIdList;
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    var padding = data.size.height * 0.15;
    return PopScope(
      child: Padding(
        padding: EdgeInsets.only(top: padding),
        child: Container(
          // padding: EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.only(topLeft: _radius, topRight: _radius)),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  height: 48,
                  child: Stack(
                    children: [
                      Container(
                        child: _messageListListenable.value.isNotEmpty
                            ? TextButton(
                                onPressed:
                                    _messageListListenable.value.isNotEmpty
                                        ? showClearDialog
                                        : null,
                                child: Icon(
                                  NEMeetingIconFont.icon_delete,
                                  color: _UIColors.color33333E,
                                  size: 24,
                                ),
                              )
                            : null,
                      ),
                      Center(
                        child: Text(
                          NEMeetingUIKitLocalizations.of(context)!.notifyCenter,
                          style: TextStyle(
                              color: _UIColors.color_222222,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: RawMaterialButton(
                          constraints: const BoxConstraints(
                              minWidth: 40.0, minHeight: 48.0),
                          child: Icon(
                            NEMeetingIconFont.icon_yx_tv_duankaix,
                            color: _UIColors.color_666666,
                            size: 15,
                            key: MeetingUIValueKeys.close,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: _buildBody(),
                ),
              ],
            ),
          ),
        ),
      ),
      canPop: true,
      onPopInvoked: (value) {
        Navigator.maybePop(context);
      },
    );
  }

  Future<void> showClearDialog() async {
    if (isShowClearDialogDialog) return;
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
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
                      _sessionIdList.forEach((element) {
                        lifecycleExecuteUI(NEMeetingKit.instance
                            .deleteAllSessionMessage(element)
                            .then((result) {
                          if (result.isSuccess()) {
                            setState(() {
                              _messageListListenable.value.clear();
                            });
                          }
                          Navigator.of(context).pop();
                          isShowClearDialogDialog = false;
                        }));
                      });
                      widget.onClearAllMessage.call();
                    })
              ],
            ));
  }

  Widget buildNotifyMessageItem(BuildContext context, int index) {
    int? timeStamp = _messageListListenable.value[index].data?.data?.timestamp;
    CardData? cardData = _messageListListenable.value[index].data?.data;
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
                            ? timeStamp.formatToTimeString('MM月dd日 HH:mm')
                            : NEMeetingUIKitLocalizations.of(context)!
                                .globalNothing,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            color: _UIColors.color_999999,
                            fontWeight: FontWeight.normal),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding:
                    EdgeInsets.only(left: 16, top: 6, bottom: 2, right: 16),
                child: Text(
                  '${notifyCard?.body?.title}',
                  overflow: TextOverflow.ellipsis,
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
    _messageListListenable.value.clear();
    toTime = 0;
    super.dispose();
  }

  Widget _buildBody() {
    return Container(
      color: _UIColors.colorF2F3F5,
      child: SafeValueListenableBuilder(
          valueListenable: messageListListenable,
          builder: (BuildContext context,
              List<NEMeetingCustomSessionMessage> value, Widget? child) {
            return value.isEmpty
                ? Container(
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
                    child: SingleChildScrollView(
                        // controller: _scrollController,
                        child: ListView.separated(
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              return buildNotifyMessageItem(context, index);
                            },
                            itemCount: value.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics())),
                  );
          }),
    );
  }

  void _initData() {
    _messageList = widget.messageList;
    _messageList.sort((a, b) => b.time!.compareTo(a.time!));
    _messageListListenable.value = _messageList;
    _sessionIdList.forEach((element) {
      NEMeetingKit.instance.clearUnreadCount(element).then((result) async {
        if (await Connectivity().checkConnectivity() ==
            ConnectivityResult.none) {
          ToastUtils.showToast(context,
              NEMeetingUIKitLocalizations.of(context)!.networkAbnormality);
          return;
        }
      });
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
