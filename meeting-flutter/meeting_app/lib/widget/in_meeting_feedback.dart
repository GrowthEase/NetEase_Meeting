// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/strings.dart';
import 'dart:math';
import 'package:connectivity/connectivity.dart';

class InMeetingFeedBack extends StatefulWidget {
  final Function(
      String meetingId,
      String nickname,
      bool needStartAudioDump,
      List<InMeetingFeedBackItem> list,
      String content,
      String? userList) onChange;
  final ValueNotifier<bool> isEnableSubmitNotifier;
  final NEMeetingInfo meetingInfo;

  InMeetingFeedBack({
    required this.onChange,
    required this.meetingInfo,
    required this.isEnableSubmitNotifier,
  });

  @override
  State<StatefulWidget> createState() => _InMeetingFeedBack();
}

class _InMeetingFeedBack extends State<InMeetingFeedBack> {
  final audioQuestions = [
    InMeetingFeedBackItem('对方说话声音延时很大', isNeedAudiDump: true),
    InMeetingFeedBackItem('播放机械音', isNeedAudiDump: true),
    InMeetingFeedBackItem('对方说话声音很卡', isNeedAudiDump: true),
    InMeetingFeedBackItem('杂音', isNeedAudiDump: true),
    InMeetingFeedBackItem('有回声', isNeedAudiDump: true),
    InMeetingFeedBackItem('听不到远端声音', isNeedAudiDump: true),
    InMeetingFeedBackItem('远端听不到我的声音', isNeedAudiDump: true),
    InMeetingFeedBackItem('音量小', isNeedAudiDump: true),
  ];
  final videoQuestions = [
    InMeetingFeedBackItem('视频长时间卡顿'),
    InMeetingFeedBackItem('视频断断续续'),
    InMeetingFeedBackItem('画面撕裂'),
    InMeetingFeedBackItem('画面过亮/过暗'),
    InMeetingFeedBackItem('画面模糊'),
    InMeetingFeedBackItem('画面明显噪点'),
    InMeetingFeedBackItem('音画不同步'),
  ];
  // late bool _isEnableSubmit;
  // var _hasContent = false;
  String _inputContent = '';
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _textController;
  bool _userListExpanded = false;
  late final List<UserItem>
      _userList; // = <String>['张三', '李四', '王五', '赵六', '钱七', '孙八', '周九', '吴十'];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _userList = widget.meetingInfo.userList
        .where((e) => e.isSelf == false)
        .map((e) => UserItem(e))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    var padding = data.size.height * 0.15;
    return Container(
        padding: EdgeInsets.only(top: padding),
        child: SafeArea(
            top: true,
            child: GestureDetector(
              onTap: hideKeyboard,
              child: Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    color: AppColors.white,
                  ),
                  child: Scaffold(
                    backgroundColor: AppColors.white,
                    body: ListView(
                      children: <Widget>[
                        SizedBox(height: 46),
                        buildTitle(Strings.inRoomFeedBackTitleAudio),
                        SizedBox(height: 14),
                        Wrap(
                          children: audioQuestions.map((item) {
                            return buildItem(item);
                          }).toList(),
                          spacing: 24,
                          runSpacing: 14,
                        ),
                        SizedBox(height: 32),
                        buildTitle(Strings.inRoomFeedBackTitleVideo),
                        SizedBox(height: 14),
                        Wrap(
                          children: videoQuestions.map((item) {
                            return buildItem(item);
                          }).toList(),
                          spacing: 24,
                          runSpacing: 14,
                        ),
                        SizedBox(height: 32),
                        buildTitle(Strings.inRoomFeedBackTitleDescription),
                        SizedBox(height: 16),
                        buildInputItem(),
                        SizedBox(height: 24),
                        buildTitle(Strings.inRoomFeedBackTitleUser),
                        SizedBox(height: 17),
                        buildUserListTile(),
                        if (_userListExpanded) SizedBox(height: 10),
                        if (_userListExpanded) buildUserList(),
                        SizedBox(height: 27),
                        buildSubmit(),
                        SizedBox(height: 37),
                      ],
                    ),
                  )),
            )));
  }

  Widget buildItem(InMeetingFeedBackItem categoryQuestion) {
    return Container(
        //height: 36,
        child: GestureDetector(
      onTap: () {
        setState(() {
          categoryQuestion.selected = !categoryQuestion.selected;
        });
      },
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(right: 2),
              alignment: Alignment.centerRight,
              child: checkIcon(categoryQuestion.selected),
            ),
            Text(
              categoryQuestion.name,
              style: TextStyle(
                  color: AppColors.black_333333,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none),
            ),
          ]),
    ));
  }

  Widget checkIcon(bool value, {double iconSize = 20}) {
    return value
        ? Icon(
            Icons.check_box_rounded,
            color: AppColors.blue_337eff,
            size: iconSize,
          )
        : Icon(
            Icons.check_box_outline_blank_rounded,
            color: AppColors.color_999999,
            size: iconSize,
          );
  }

  Widget buildTitle(String title) {
    return Container(
      //height: 48,
      child: Center(
          child: Container(
        // padding: EdgeInsets.only(top: 20, left: 20),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              // Strings.inRoomFeedBackTitleTip,
              title,
              style: TextStyle(
                  color: AppColors.black_333333,
                  fontSize: 16,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.bold),
            )),
      )),
    );
  }

  Widget buildUserListTile() {
    return Container(
      child: ListTile(
        dense: true,
        title: Text(
          getUserListString(),
          style: TextStyle(
            color: AppColors.black_333333,
            fontSize: 14,
            decoration: TextDecoration.none,
            fontWeight: FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          _userListExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
        ),
        onTap: () {
          setState(() {
            if (_userList.isNotEmpty) {
              _userListExpanded = !_userListExpanded;
            }
          });
        },
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.colorE1E3E6,
          width: 1,
        ),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    );
  }

  Widget buildUserList() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.colorE1E3E6,
          width: 1,
        ),
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: min(_userList.length + 1, 7) * 48.0,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _userList.length + 1,
              separatorBuilder: (BuildContext context, int index) {
                return Container(
                  padding: EdgeInsets.only(left: 12, right: 12),
                  height: 1,
                  color: Color(0xF9F9F9),
                );
              },
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return ListTile(
                    leading: checkIcon(hasNoUserSelected()),
                    title: Text(
                      '无',
                      style: TextStyle(
                          color: AppColors.black_333333,
                          fontSize: 14,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w400),
                    ),
                    onTap: () => toggleUserSelect(index),
                    dense: true,
                    horizontalTitleGap: 6,
                  );
                }
                return ListTile(
                  leading: checkIcon(_userList[index - 1].selected),
                  title: Text(
                    _userList[index - 1].userInfo.userName,
                    style: TextStyle(
                        color: AppColors.black_333333,
                        fontSize: 14,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w400),
                  ),
                  onTap: () => toggleUserSelect(index),
                  dense: true,
                  horizontalTitleGap: 6,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool hasNoUserSelected() {
    return _userList.every((user) => !user.selected);
  }

  bool hasUserSelected() {
    return _userList.any((user) => user.selected);
  }

  void toggleUserSelect(int index) {
    if (index == 0) {
      // 当前有选中的用户，取消选中这些用户
      if (hasUserSelected()) {
        setState(() {
          _userListExpanded = false;
          _userList.forEach((user) => user.selected = false);
        });
      }
    } else {
      // 取消或选中当前用户
      setState(() {
        // _userListExpanded = false;
        final item = _userList[index - 1];
        final selected = item.selected;
        item.selected = !selected;
      });
    }
  }

  String get reporterNickname => widget.meetingInfo.userList
      .firstWhere((element) => element.isSelf)
      .userName;

  String getUserListString() {
    final selectedUsers = _userList.where((user) => user.selected).toList();
    if (selectedUsers.isEmpty) {
      return '无';
    }
    return selectedUsers.map((user) => user.userInfo.userName).join(',');
  }

  bool canSubmit() {
    return audioQuestions.any((element) => element.selected) ||
        videoQuestions.any((element) => element.selected) ||
        _textController.text.isNotEmpty;
  }

  Widget buildSubmit() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: 16, right: 6, left: 6),
      color: AppColors.white,
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              return states.contains(MaterialState.disabled)
                  ? AppColors.blue_50_337eff
                  : AppColors.blue_337eff;
            }),
            padding:
                MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 13)),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                side: BorderSide(
                    color: canSubmit()
                        ? AppColors.blue_337eff
                        : AppColors.blue_50_337eff,
                    width: 0),
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
            )),
        onPressed: canSubmit() ? _onSubmit : null,
        child: Text(
          Strings.submit,
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void hideKeyboard() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  Future<void> _onSubmit() async {
    hideKeyboard();

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ToastUtils.showToast(context, Strings.networkUnavailable);
      return;
    }

    final needStartAudioDump =
        audioQuestions.any((element) => element.selected);
    final questions = audioQuestions
        .followedBy(videoQuestions)
        .where((element) => element.selected)
        .toList();
    widget.onChange(
        widget.meetingInfo.meetingId,
        reporterNickname,
        needStartAudioDump,
        questions,
        _inputContent,
        hasUserSelected() ? getUserListString() : null);
    ToastUtils.showToast(context, Strings.feedbackSuccess);

    ///提交后就关闭，，不阻塞用户会中其他操作
    Navigator.of(context).pop();
  }

  Widget buildInputItem() {
    return Material(
      child: Container(
        color: AppColors.white,
        child: TextField(
          autofocus: false,
          focusNode: _focusNode,
          controller: _textController,
          // maxLength: 200,
          minLines: 3,
          maxLines: 4,
          textInputAction: TextInputAction.done,
          onEditingComplete: hideKeyboard,
          keyboardAppearance: Brightness.light,
          decoration: InputDecoration(
            isDense: true,
            hintText: Strings.inRoomFeedBackOtherTip,
            hintStyle: TextStyle(fontSize: 14, color: AppColors.color_999999),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xF8F8F8),
                width: 1.0,
                style: BorderStyle.solid,
              ),
            ),
          ),
          style: TextStyle(color: AppColors.color_222222, fontSize: 14),
          onChanged: (String value) {
            setState(() {
              _inputContent = value;
              // _hasContent = _textController.text.isNotEmpty;
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  bool hasSelected() {
    var _hasSelected = false;
    for (var item in videoQuestions) {
      if (item.selected) {
        _hasSelected = true;
        break;
      }
    }
    return _hasSelected;
  }
}

class UserItem {
  final NEInMeetingUserInfo userInfo;
  bool selected = false;

  UserItem(this.userInfo);
}

class InMeetingFeedBackItem {
  String name;
  bool selected;
  bool isNeedAudiDump;

  InMeetingFeedBackItem(this.name,
      {this.selected = false, this.isNeedAudiDump = false});

  @override
  String toString() =>
      'InMeetingFeedBackItem{name: $name, selected: $selected}, isNeedAudiDump: $isNeedAudiDump';
}
