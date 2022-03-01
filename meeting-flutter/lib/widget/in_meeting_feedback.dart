// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:yunxin_meeting/meeting_uikit.dart';
import 'package:uikit/utils/keyboard_utils.dart';
import 'package:uikit/values/colors.dart';
import 'package:uikit/values/strings.dart';

class InMeetingFeedBack extends StatefulWidget {
  final Function(bool needStartAudioDump, List<InMeetingFeedBackItem> list,
      String content) onChange;
  final ValueNotifier<bool> isEnableSubmitNotifier;

  InMeetingFeedBack({
    required this.onChange,
    required this.isEnableSubmitNotifier,
  });

  @override
  State<StatefulWidget> createState() => _InMeetingFeedBack();
}

class _InMeetingFeedBack extends State<InMeetingFeedBack> {
  final categoryQuestions = [
    InMeetingFeedBackItem('听不到声音', isNeedAudiDump: true),
    InMeetingFeedBackItem('杂音、机械音', isNeedAudiDump: true),
    InMeetingFeedBackItem('声音卡顿', isNeedAudiDump: true),
    InMeetingFeedBackItem('看不到画面'),
    InMeetingFeedBackItem('画面模糊'),
    InMeetingFeedBackItem('画面卡顿'),
    InMeetingFeedBackItem('声音画面不同步',isNeedAudiDump: true),
    InMeetingFeedBackItem('意外退出'),
    InMeetingFeedBackItem('其他'),
  ];
  late bool _isEnableSubmit;
  var _hasContent = false;
  String _inputContent = '输入你的问题';
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _isEnableSubmit = widget.isEnableSubmitNotifier.value;
    widget.isEnableSubmitNotifier.addListener(() {
      if(mounted){
        setState(() {
          _isEnableSubmit = widget.isEnableSubmitNotifier.value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    var padding = data.size.height * 0.15;
    return Container(
        padding: EdgeInsets.only(top: padding),
        child: SafeArea(
            top: true,
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    color: AppColors.white),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    buildTitle(),
                    Expanded(
                      child:GestureDetector(
                        onTap: (){
                          if (_focusNode.hasFocus) {
                            _focusNode.unfocus();
                          }
                        },
                        child: Scaffold(
                      body: ListView.builder(
                        itemCount: categoryQuestions.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (categoryQuestions.length - 1 == index) {
                            return buildOtherItem();
                          }
                          return buildItem(categoryQuestions[index]);
                        },
                      ),
                    ))),
                  ],
                ))));
  }

  Widget buildItem(InMeetingFeedBackItem categoryQuestion) {
    return Container(
        height: 36,
        padding: EdgeInsets.only(left: 20, top: 12),
        child: GestureDetector(
          onTap: () {
            setState(() {
              categoryQuestion.selected = !categoryQuestion.selected;
            });
          },
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
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

  Widget buildTitle() {
    return Container(
      height: 48,
      child: Center(
          child: Container(
        padding: EdgeInsets.only(top: 20, left: 20),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              Strings.inRoomFeedBackTitleTip,
              style: TextStyle(
                  color: AppColors.black_333333,
                  fontSize: 16,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.bold),
            )),
      )),
    );
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
                    color: _isEnableSubmit && _hasContent && hasSelected()
                        ? UIColors.blue_337eff
                        : UIColors.blue_50_337eff,
                    width: 0),
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
            )),
        onPressed: (_isEnableSubmit && _hasContent && hasSelected()) ? _onSubmit : null,
        child: Text(
          Strings.submit,
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    }
    KeyboardUtils.dismissKeyboard(context);
    setState(() {
      _isEnableSubmit = false;
    });
    var needStartAudioDump = false;
    categoryQuestions.forEach((element) {
      if (element.selected && element.isNeedAudiDump) {
        needStartAudioDump = true;
      }
    });

    widget.onChange(needStartAudioDump, categoryQuestions, _inputContent);
    ToastUtils.showToast(context, Strings.feedbackSuccess);
    ///提交后就关闭，，不阻塞用户会中其他操作
    Navigator.of(context).pop();
  }

  Widget buildOtherItem() {
    return Material(
      child: Container(
        color: UIColors.white,
        child:SingleChildScrollView(
          //height: _Dimen.editTextItemHeight,
          reverse: true,
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                autofocus: false,
                focusNode: _focusNode,
                controller: _textController,
                maxLines: 4,
                minLines: 3,
                maxLength: 200,
                keyboardAppearance: Brightness.light,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  hintText: Strings.inRoomFeedBackOtherTip,
                  hintStyle:
                      TextStyle(fontSize: 14, color: UIColors.color_999999),
                  // border:
                  //     OutlineInputBorder(borderSide: Borders.feedbackBorder),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: UIColors.color_222222, fontSize: 14),
                onChanged: (String value) {
                  if (value.isNotEmpty) _inputContent = value;
                  setState(() {
                    _hasContent = _textController.text.isNotEmpty;
                  });
                },
              ),
              Container(
                  padding: EdgeInsets.only(top: 12, left: 2),
                  margin: EdgeInsets.all(2),
                  child: Text(
                    Strings.inRoomFeedBackSubTitleTip,
                    style:
                        TextStyle(fontSize: 14, color: UIColors.color_999999),
                  )),
              buildSubmit(),
            ],
          ),
        ) ,),
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
    for (var item in categoryQuestions) {
      if (item.selected) {
        _hasSelected = true;
        break;
      }
    }
    return _hasSelected;
  }
}

class InMeetingFeedBackItem {
  String name;
  bool selected;
  bool isNeedAudiDump;

  InMeetingFeedBackItem(this.name,
      {this.selected = false, this.isNeedAudiDump = false});

  @override
  String toString() {
    return 'InMeetingFeedBackItem{name: $name, selected: $selected}, isNeedAudiDump: ${isNeedAudiDump}';
  }
}
