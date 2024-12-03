// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/language/localizations.dart';
import 'package:nemeeting/service/repo/contacts_repo.dart';
import 'package:nemeeting/uikit/state/meeting_base_state.dart';
import 'package:nemeeting/uikit/utils/router_name.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:netease_common/netease_common.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';

class TranscriptionTimingPage extends StatefulWidget {
  const TranscriptionTimingPage({
    super.key,
  });

  @override
  State<TranscriptionTimingPage> createState() =>
      _TranscriptionTimingPageState();
}

class _TranscriptionTimingPageState
    extends AppBaseState<TranscriptionTimingPage> {
  late int meetingId;
  late List<NEMeetingTranscriptionInfo> transcriptionInfoList;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)!.settings.arguments as List;
    meetingId = arguments[0] as int;
    transcriptionInfoList = arguments[1] as List<NEMeetingTranscriptionInfo>;
  }

  @override
  Widget buildBody() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: EdgeInsets.all(16.w),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: 48,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 16.w),
              child: Text(
                getAppLocalizations().transcriptionTiming,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.color_1E1F27,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            for (var info in transcriptionInfoList)
              MeetingArrowItem(
                title: info.timeRanges.first.start
                    .formatToTimeString('yyyy.MM.dd HH:mm'),
                titleTextStyle: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.color_53576A,
                  fontWeight: FontWeight.w400,
                ),
                content: info.isGenerating
                    ? getAppLocalizations().transcriptionGenerating
                    : null,
                contentTextStyle: info.isGenerating
                    ? TextStyle(
                        fontSize: 14,
                        color: AppColors.color_337eff,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                      )
                    : null,
                showArrow: info.isGenerated,
                onTap: info.isGenerated
                    ? () {
                        TranscriptionMessageHistoryPage.show(
                          context,
                          meetingId,
                          info,
                        );
                      }
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  @override
  String getTitle() {
    return getAppLocalizations().transcription;
  }
}

/// 转写消息历史页面
class TranscriptionMessageHistoryPage extends StatefulWidget {
  static void show(
    BuildContext context,
    int meetingId,
    NEMeetingTranscriptionInfo transcriptionInfo,
  ) {
    showMeetingPopupPageRoute(
        context: context,
        routeSettings: RouteSettings(name: RouterName.transcriptionHistory),
        builder: (context) {
          /// 只有一份转写历史，直接跳转到详情页
          return TranscriptionMessageHistoryPage(
            meetingId: meetingId,
            transcriptionInfo: transcriptionInfo,
          );
        });
  }

  final int meetingId;
  final NEMeetingTranscriptionInfo transcriptionInfo;

  const TranscriptionMessageHistoryPage({
    super.key,
    required this.meetingId,
    required this.transcriptionInfo,
  });

  @override
  State<TranscriptionMessageHistoryPage> createState() =>
      _TranscriptionMessageHistoryPageState();
}

class _TranscriptionMessageHistoryPageState
    extends AppBaseState<TranscriptionMessageHistoryPage> {
  int? selectedIndex;
  int nextPageIndex = 0;
  var loading = false;
  final List<NEMeetingTranscriptionMessage> messageList = [];
  final scrollController = ScrollController();

  @override
  Color get backgroundColor => Colors.white;

  @override
  bool get showContentDivider => true;

  @override
  bool isShowBackBtn() => false;

  List<Widget> buildActions() {
    return [
      TitleBarCloseIcon(),
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadData(nextPageIndex);
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent -
              scrollController.position.pixels <
          50) {
        _loadData(nextPageIndex);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _loadData(int index) async {
    final originalNosFileKey =
        widget.transcriptionInfo.originalNosFileKeys.elementAtOrNull(index);
    if (originalNosFileKey == null) return;
    if (loading) return;
    loading = true;
    final curPage = nextPageIndex;
    final result = await NEMeetingKit.instance
        .getPreMeetingService()
        .getHistoryMeetingTranscriptionMessageList(
            widget.meetingId, originalNosFileKey);
    loading = false;
    if (mounted && result.isSuccess() && curPage == nextPageIndex) {
      nextPageIndex++;
      setState(() {
        messageList.addAll(result.data!);
      });
    }
  }

  @override
  Widget buildBody() {
    if (messageList.isEmpty) {
      return Container(
        padding: EdgeInsets.only(top: 100),
        alignment: Alignment.topCenter,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          NEMeetingImages.assetImage(
            NEMeetingImages.iconNoContent,
            width: 120,
            height: 120,
          ),
          SizedBox(height: 8),
          Text(NEMeetingUIKit.instance.getUIKitLocalizations().globalNoContent,
              style: TextStyle(fontSize: 14, color: AppColors.color_8D90A0))
        ]),
      );
    }
    return ListView.separated(
      controller: scrollController,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
      itemCount: messageList.length,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        final message = messageList.elementAtOrNull(index);
        if (message == null) return SizedBox.shrink();
        return buildMessageItem(index, message);
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 12.h);
      },
    );
  }

  Widget buildMessageItem(int index, NEMeetingTranscriptionMessage message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder(
                future: ContactsRepo().getContact(message.fromUserUuid),
                builder: (context, snapshot) {
                  return NEMeetingAvatar.small(
                    name: message.fromNickname,
                    url: snapshot.hasData ? snapshot.requireData?.avatar : null,
                  );
                }),
            SizedBox(width: 8.w),
            Text(
              message.fromNickname,
              style: TextStyle(
                fontSize: 14.spMin,
                color: AppColors.color_1E1F27,
                fontWeight: FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(width: 8.w),
            Text(
              message.timestamp.formatToTimeString('HH:mm:ss'),
              style: TextStyle(
                fontSize: 14.spMin,
                color: AppColors.color_8D90A0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 24),
            SizedBox(width: 8.w),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  color: selectedIndex == index
                      ? AppColors.color_ADCBFF
                      : Colors.transparent,
                ),
                child: ChatMenuWidget(
                  showOnTap: true,
                  showOnLongPress: false,
                  onValueChanged: (value) {
                    Clipboard.setData(ClipboardData(text: message.content));
                  },
                  actions: [
                    getAppLocalizations().globalCopy,
                  ],
                  willShow: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 16.spMin,
                      color: AppColors.color_1E1F27,
                      fontWeight: FontWeight.normal,
                    ),
                    strutStyle: StrutStyle(
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  String getTitle() {
    return getAppLocalizations().transcription;
  }
}
