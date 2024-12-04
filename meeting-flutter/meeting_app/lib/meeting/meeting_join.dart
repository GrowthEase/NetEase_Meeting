// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/auth/guest_login.dart';
import 'package:nemeeting/base/util/text_util.dart';
import 'package:nemeeting/routes/home_page.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/uikit/state/meeting_base_state.dart';
import 'package:nemeeting/utils/const_config.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:nemeeting/widget/meeting_text_field.dart';
import 'package:nemeeting/widget/ne_widget.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';

import '../global_state.dart';
import '../language/localizations.dart';
import '../uikit/const/consts.dart';
import '../uikit/utils/nav_utils.dart';
import '../uikit/values/colors.dart';
import '../utils/dialog_utils.dart';
import '../utils/privacy_util.dart';

class MeetJoinRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeetJoinRouteState();
  }
}

class _MeetJoinRouteState extends AppBaseState<MeetJoinRoute>
    with FirstBuildScope, GuestJoinController {
  ValueNotifier<bool> openCamera = ValueNotifier(true);

  ValueNotifier<bool> openMicrophone = ValueNotifier(true);

  final maxIdLength = 12;

  late TextEditingController _meetingNumController;
  late final _meetingNumFocusNode = FocusNode();
  late final _meetingNicknameFocusNode = FocusNode();
  late final _meetingNicknameController = TextEditingController();

  ValueNotifier<bool> joinEnable = ValueNotifier(false);

  final NESettingsService settingsService =
      NEMeetingKit.instance.getSettingsService();
  final accountService = NEMeetingKit.instance.getAccountService();

  int _selectedRecordIndex = 0;

  final preMeetingService = NEMeetingKit.instance.getPreMeetingService();

  @override
  void initState() {
    super.initState();
    var meetingNum = GlobalState.deepLinkMeetingNum;
    GlobalState.deepLinkMeetingNum = null;
    _meetingNumController = TextEditingController(text: meetingNum);
    _meetingNumController.addListener(_onMeetingNumChanged);
    Future.wait([
      settingsService.isTurnOnMyVideoWhenJoinMeetingEnabled(),
      settingsService.isTurnOnMyAudioWhenJoinMeetingEnabled(),
    ]).then((values) {
      openCamera.value = values[0];
      openMicrophone.value = values[1];
    });

    String? nickname;
    if (meetingNum != null) {
      nickname = LocalHistoryMeetingManager().getLatestNickname(meetingNum);
    }
    nickname = AuthManager().nickName;
    if (nickname != null && nickname.isNotEmpty) {
      _meetingNicknameController.text = nickname;
    }

    Listenable.merge([
      _meetingNumController,
      _meetingNicknameController,
    ]).addListener(_onMeetingParamsChanged);
  }

  @override
  void onFirstBuild() {
    super.onFirstBuild();
    ModalRoute.of(context)!.animation?.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _meetingNumFocusNode.requestFocus();
      }
    });
  }

  @override
  String getTitle() {
    return getAppLocalizations().meetingJoin;
  }

  @override
  Widget buildBody() {
    return NEGestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MeetingCard(
                  children: [
                    Table(
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      columnWidths: {
                        1: FlexColumnWidth(),
                      },
                      defaultColumnWidth: IntrinsicColumnWidth(),
                      children: [
                        TableRow(
                          children: [
                            buildInputRowTitle(
                                getAppLocalizations().meetingNum),
                            buildMeetingIdInput(),
                            SizedBox(width: 10.w),
                          ],
                        ),
                        TableRow(
                          children: [
                            buildInputRowTitle(
                                getAppLocalizations().meetingNickname),
                            buildMeetingNicknameInput(),
                            SizedBox(width: 10.w),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                MeetingCard(children: [
                  buildMicrophoneItem(),
                  buildCameraItem(),
                ]),
              ],
            ),
          )),
          if (!AuthManager().isLoggedIn)
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: PrivacyUtil.protocolTips()),
          buildJoin()
        ],
      ),
    );
  }

  Widget buildMeetingIdInput() {
    return TextField(
      key: MeetingValueKey.inputMeetingId,
      focusNode: _meetingNumFocusNode,
      style: TextStyle(color: AppColors.color_53576A, fontSize: 16),
      inputFormatters: [
        LengthLimitingTextInputFormatter(maxIdLength),
        FilteringTextInputFormatter.allow(RegExp(r'\d[-\d]*')),
      ],
      maxLines: 1,
      keyboardType: TextInputType.number,
      cursorColor: AppColors.blue_337eff,
      controller: _meetingNumController,
      textAlign: TextAlign.left,
      keyboardAppearance: Brightness.light,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
          hintText: getAppLocalizations().meetingEnterId,
          hintStyle: TextStyle(fontSize: 16, color: AppColors.color_CDCFD7),
          border: InputBorder.none,
          suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ListenableBuilder(
                    listenable: _meetingNumController,
                    builder: (context, _) {
                      return Visibility(
                        visible: _meetingNumController.text.isNotEmpty,
                        child: ClearIconButton(
                          padding: EdgeInsets.all(6),
                          size: 16,
                          onPressed: () {
                            _meetingNumController.clear();
                          },
                        ),
                      );
                    }),
                SizedBox(width: 12.w),
                Visibility(
                  visible: hasMeetingRecords,
                  child: DropdownIconButton(
                    key: MeetingValueKey.openCameraCreateMeeting,
                    padding: EdgeInsets.all(6),
                    size: 16,
                    onPressed: () {
                      _showHistoryMeetingDialog();
                      setState(() {});
                    },
                  ),
                ),
              ])),
    );
  }

  Widget buildInputRowTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.color_1E1F27,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget buildMeetingNicknameInput() {
    return TextField(
      key: MeetingValueKey.inputMeetingNickname,
      focusNode: _meetingNicknameFocusNode,
      style: TextStyle(color: AppColors.color_53576A, fontSize: 16),
      keyboardType: TextInputType.text,
      cursorColor: AppColors.blue_337eff,
      controller: _meetingNicknameController,
      textAlign: TextAlign.left,
      maxLines: 1,
      keyboardAppearance: Brightness.light,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        hintText: getAppLocalizations().meetingEnterNickname,
        hintStyle: TextStyle(fontSize: 16, color: AppColors.color_CDCFD7),
        border: InputBorder.none,
      ),
      inputFormatters: [
        MeetingLengthLimitingTextInputFormatter(nickLengthMax),
      ],
    );
  }

  Widget buildCameraItem() {
    return MeetingSwitchItem(
      switchKey: MeetingValueKey.openCameraJoinMeeting,
      title: getAppLocalizations().meetingJoinCameraOn,
      valueNotifier: openCamera,
      onChanged: (bool value) {
        openCamera.value = value;
        settingsService.enableTurnOnMyVideoWhenJoinMeeting(value);
      },
    );
  }

  Widget buildMicrophoneItem() {
    return MeetingSwitchItem(
      switchKey: MeetingValueKey.openMicrophoneJoinMeeting,
      title: getAppLocalizations().meetingJoinMicrophoneOn,
      valueNotifier: openMicrophone,
      onChanged: (bool value) {
        openMicrophone.value = value;
        settingsService.enableTurnOnMyAudioWhenJoinMeeting(value);
      },
    );
  }

  Widget buildJoin() {
    return ValueListenableBuilder(
        valueListenable: joinEnable,
        builder: (context, value, child) {
          return SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              child: MeetingActionButton(
                key: MeetingValueKey.createMeetingBtn,
                onTap: value ? joinMeeting : null,
                text: getAppLocalizations().meetingJoin,
              ),
            ),
          );
        });
  }

  Future<void> joinMeeting() async {
    final isLoggedIn = AuthManager().isLoggedIn;
    FocusScope.of(context).requestFocus(FocusNode());
    if (isLoggedIn) {
      _onJoinMeeting();
    } else {
      if (!await PrivacyUtil.ensurePrivacyAgree(context)) return;
      _guestJoinMeeting();
    }
  }

  String get targetMeetingNum =>
      TextUtil.replace(_meetingNumController.text, RegExp(r'-'), '');

  void _onJoinMeeting() async {
    LoadingUtil.showLoading();
    final result = await NEMeetingKit.instance.getMeetingService().joinMeeting(
      context,
      NEJoinMeetingParams(
        meetingNum: targetMeetingNum,
        displayName: _meetingNicknameController.text,
        watermarkConfig: buildNEWatermarkConfig(),
      ),
      await buildMeetingUIOptions(
        noVideo: !openCamera.value,
        noAudio: !openMicrophone.value,
        context: context,
      ),
      onPasswordPageRouteWillPush: () async {
        LoadingUtil.cancelLoading();
      },
      onMeetingPageRouteWillPush: () async {
        LoadingUtil.cancelLoading();
        if (!mounted) return;
        NavUtils.pop(context);
      },
      backgroundWidget: HomePageRoute(),
    );
    if (!mounted) return;
    final errorCode = result.code;
    final errorMessage = result.msg;
    LoadingUtil.cancelLoading();
    if (errorCode == NEMeetingErrorCode.success) {
    } else if (errorCode == NEMeetingErrorCode.noNetwork) {
      ToastUtils.showToast(
          context, getAppLocalizations().globalNetworkUnavailableCheck);
    } else if (errorCode == NEMeetingErrorCode.noAuth) {
      ToastUtils.showToast(
          context, getAppLocalizations().authLoginOnOtherDevice);
      AuthManager().logout();
      NavUtils.toEntrance(context);
    } else if (errorCode == NEMeetingErrorCode.alreadyInMeeting) {
      ToastUtils.showToast(
          context, getAppLocalizations().meetingOperationNotSupportedInMeeting);
    } else if (errorCode == NEMeetingErrorCode.cancelled) {
      /// 暂不处理
    } else if (errorCode == NEMeetingErrorCode.guestJoinNotSupported ||
        errorCode == NEMeetingErrorCode.crossAppJoinNotSupported) {
      var title = getAppLocalizations().meetingCrossAppJoinNotSupportedTitle;
      var message = getAppLocalizations().meetingCrossAppJoinNotSupported;
      if (errorCode == NEMeetingErrorCode.guestJoinNotSupported) {
        title = getAppLocalizations().meetingGuestJoinNotSupportedTitle;
        message = getAppLocalizations().meetingGuestJoinNotSupported;
      }
      AppDialogUtils.showOneButtonCommonDialog(
        context,
        title,
        message,
        () => Navigator.pop(context),
      );
    } else if (errorCode == NEMeetingErrorCode.meetingLocked) {
      AppDialogUtils.showOneButtonCommonDialog(
        context,
        NEMeetingUIKit.instance.getUIKitLocalizations().meetingLocked,
        NEMeetingUIKit.instance.getUIKitLocalizations().meetingLockedTip,
        () => Navigator.pop(context),
      );
    } else {
      var errorTips =
          HttpCode.getMsg(errorMessage, getAppLocalizations().meetingJoinFail);
      ToastUtils.showToast(context, errorTips);
    }
  }

  void _guestJoinMeeting() async {
    LoadingUtil.showLoading();
    if (!NEMeetingKit.instance.isInitialized) {
      final initResult = await AuthManager().initialize(appKey: '');
      if (!initResult.isSuccess()) {
        LoadingUtil.cancelLoading();
        ToastUtils.showToast(context, getAppLocalizations().meetingJoinFail);
        return;
      }
    }
    guestJoinMeeting(
      meetingNum: targetMeetingNum,
      displayName: _meetingNicknameController.text,
      noVideo: !openCamera.value,
      noAudio: !openMicrophone.value,
    );
  }

  void _onMeetingNumChanged() {
    final nickname =
        LocalHistoryMeetingManager().getLatestNickname(targetMeetingNum);
    if (nickname != null) {
      _meetingNicknameController.text = nickname;
    }
  }

  void _onMeetingParamsChanged() {
    joinEnable.value = _meetingNumController.text.isNotEmpty &&
        _meetingNicknameController.text.isNotEmpty;
  }

  void _showHistoryMeetingDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogTitle(),
            _buildDialogContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogTitle() {
    return Container(
      height: 44,
      decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
              side: BorderSide(
                color: AppColors.colorF2F2F5,
              ),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: 150,
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: 8),
            child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _clearMeetingRecords();
                },
                child: Text(getAppLocalizations().meetingClearRecord,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.color_1f2329,
                      fontWeight: FontWeight.normal,
                    ))),
          ),
          Container(
              width: 150,
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _selectMeetingRecord();
                  },
                  child: Text(getAppLocalizations().globalSure,
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.blue_337eff,
                          fontWeight: FontWeight.w500)))),
        ],
      ),
    );
  }

  Widget _buildDialogContent() {
    return Container(
      color: AppColors.white,
      height: MediaQuery.of(context).copyWith().size.height / 3,
      child: !hasMeetingRecords
          ? Container()
          : CupertinoPicker(
              itemExtent: 40, // 单个选项的高度
              scrollController: FixedExtentScrollController(
                  initialItem: _selectedRecordIndex),
              onSelectedItemChanged: (int index) {
                _selectedRecordIndex = index;
              },
              children:
                  preMeetingService.getLocalHistoryMeetingList().map((record) {
                return Center(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        record.subject,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      TextUtil.applyMask(record.meetingNum, '000-000-0000'),
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ));
              }).toList(),
            ),
    );
  }

  bool get hasMeetingRecords =>
      LocalHistoryMeetingManager().hasLocalMeetingHistory;

  void _selectMeetingRecord() {
    if (preMeetingService.getLocalHistoryMeetingList().isEmpty) {
      return;
    }
    var record =
        preMeetingService.getLocalHistoryMeetingList()[_selectedRecordIndex];
    _meetingNumController.text = record.meetingNum;
  }

  void _clearMeetingRecords() async {
    preMeetingService.clearLocalHistoryMeetingList();
    setState(() {});
  }

  @override
  void dispose() {
    _meetingNumController.dispose();
    _meetingNumFocusNode.dispose();
    _meetingNicknameController.dispose();
    _meetingNicknameFocusNode.dispose();
    LoadingUtil.cancelLoading();
    super.dispose();
  }
}
