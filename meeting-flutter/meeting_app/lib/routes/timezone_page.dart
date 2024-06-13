// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

import '../language/localizations.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/fonts.dart';

class TimezonePage extends StatefulWidget {
  final ValueNotifier<NETimezone?> timezoneNotifier;

  const TimezonePage({super.key, required this.timezoneNotifier});

  @override
  State<TimezonePage> createState() => _TimezonePageState();
}

class _TimezonePageState extends AppBaseState<TimezonePage> {
  List<NETimezone> timezones = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    TimezonesUtil.getTimezones().then((value) {
      setState(() {
        timezones.addAll(value);

        /// 选中的时区初始化显示在中间
        var offset = timezones.indexWhere(
                (element) => element.id == widget.timezoneNotifier.value?.id) *
            48.0;
        offset = offset -
            MediaQuery.of(context).size.height / 2 +
            56 +
            MediaQuery.of(context).padding.top;
        if (offset < 0) {
          offset = 0;
        }
        _scrollController.jumpTo(offset);
      });
    });
    widget.timezoneNotifier.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget buildBody() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: timezones.length,
      itemBuilder: (context, index) {
        final isChecked =
            timezones[index].id == widget.timezoneNotifier.value?.id;
        return GestureDetector(
          onTap: () {
            widget.timezoneNotifier.value = timezones[index];
            Navigator.of(context).pop();
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(
                  top: index == 0 ? Radius.circular(8) : Radius.zero,
                  bottom: index == timezones.length - 1
                      ? Radius.circular(8)
                      : Radius.zero),
            ),
            margin: EdgeInsets.only(
                top: index == 0 ? 16 : 0,
                bottom: index == timezones.length - 1 ? 16 : 0,
                left: 16,
                right: 16),
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${timezones[index].time} ${timezones[index].zone}',
                    style: TextStyle(
                      fontSize: 16,
                      color: isChecked
                          ? AppColors.color_337eff
                          : AppColors.color_1E1F27,
                    ),
                  ),
                ),
                if (isChecked) ...[
                  SizedBox(width: 12),
                  Icon(
                    size: 16,
                    IconFont.icon_yx_gouxuan,
                    color: AppColors.color_337eff,
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  String getTitle() {
    return getAppLocalizations().meetingPickTimezone;
  }
}
