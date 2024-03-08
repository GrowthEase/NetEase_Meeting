// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'meeting_ui_kit_localizations_en.dart';
import 'meeting_ui_kit_localizations_ja.dart';
import 'meeting_ui_kit_localizations_zh.dart';

/// Callers can lookup localized strings with an instance of NEMeetingUIKitLocalizations
/// returned by `NEMeetingUIKitLocalizations.of(context)`.
///
/// Applications need to include `NEMeetingUIKitLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'meeting_localization/meeting_ui_kit_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: NEMeetingUIKitLocalizations.localizationsDelegates,
///   supportedLocales: NEMeetingUIKitLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the NEMeetingUIKitLocalizations.supportedLocales
/// property.
abstract class NEMeetingUIKitLocalizations {
  NEMeetingUIKitLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static NEMeetingUIKitLocalizations? of(BuildContext context) {
    return Localizations.of<NEMeetingUIKitLocalizations>(
        context, NEMeetingUIKitLocalizations);
  }

  static const LocalizationsDelegate<NEMeetingUIKitLocalizations> delegate =
      _NEMeetingUIKitLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh')
  ];

  /// No description provided for @globalAppName.
  ///
  /// In zh, this message translates to:
  /// **'网易会议'**
  String get globalAppName;

  /// No description provided for @globalDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get globalDelete;

  /// No description provided for @globalNothing.
  ///
  /// In zh, this message translates to:
  /// **'无'**
  String get globalNothing;

  /// No description provided for @globalCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get globalCancel;

  /// No description provided for @globalAdd.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get globalAdd;

  /// No description provided for @globalClose.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get globalClose;

  /// No description provided for @globalOpen.
  ///
  /// In zh, this message translates to:
  /// **'打开'**
  String get globalOpen;

  /// No description provided for @globalFail.
  ///
  /// In zh, this message translates to:
  /// **'失败'**
  String get globalFail;

  /// No description provided for @globalYes.
  ///
  /// In zh, this message translates to:
  /// **'是'**
  String get globalYes;

  /// No description provided for @globalNo.
  ///
  /// In zh, this message translates to:
  /// **'否'**
  String get globalNo;

  /// No description provided for @globalSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get globalSave;

  /// No description provided for @globalDone.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get globalDone;

  /// No description provided for @globalNotify.
  ///
  /// In zh, this message translates to:
  /// **'通知'**
  String get globalNotify;

  /// No description provided for @globalSure.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get globalSure;

  /// No description provided for @globalIKnow.
  ///
  /// In zh, this message translates to:
  /// **'我知道了'**
  String get globalIKnow;

  /// No description provided for @globalCopy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get globalCopy;

  /// No description provided for @globalCopySuccess.
  ///
  /// In zh, this message translates to:
  /// **'复制成功'**
  String get globalCopySuccess;

  /// No description provided for @globalEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get globalEdit;

  /// No description provided for @globalGotIt.
  ///
  /// In zh, this message translates to:
  /// **'知道了'**
  String get globalGotIt;

  /// No description provided for @globalMin.
  ///
  /// In zh, this message translates to:
  /// **'分钟'**
  String get globalMin;

  /// No description provided for @globalNotWork.
  ///
  /// In zh, this message translates to:
  /// **'无法使用{permissionName}'**
  String globalNotWork(Object permissionName);

  /// No description provided for @globalNeedPermissionTips.
  ///
  /// In zh, this message translates to:
  /// **'该功能需要{permissionName},请允许{title}访问您的{permissionName}权限'**
  String globalNeedPermissionTips(Object permissionName, Object title);

  /// No description provided for @globalToSetUp.
  ///
  /// In zh, this message translates to:
  /// **'前往设置'**
  String get globalToSetUp;

  /// No description provided for @globalNoPermission.
  ///
  /// In zh, this message translates to:
  /// **'权限未授权'**
  String get globalNoPermission;

  /// No description provided for @globalDays.
  ///
  /// In zh, this message translates to:
  /// **'天'**
  String get globalDays;

  /// No description provided for @globalHours.
  ///
  /// In zh, this message translates to:
  /// **'小时'**
  String get globalHours;

  /// No description provided for @globalMinutes.
  ///
  /// In zh, this message translates to:
  /// **'分钟'**
  String get globalMinutes;

  /// No description provided for @globalViewMessage.
  ///
  /// In zh, this message translates to:
  /// **'查看消息'**
  String get globalViewMessage;

  /// No description provided for @globalNoLongerRemind.
  ///
  /// In zh, this message translates to:
  /// **'不再提醒'**
  String get globalNoLongerRemind;

  /// No description provided for @globalOperationFail.
  ///
  /// In zh, this message translates to:
  /// **'操作失败'**
  String get globalOperationFail;

  /// No description provided for @meetingBeauty.
  ///
  /// In zh, this message translates to:
  /// **'美颜'**
  String get meetingBeauty;

  /// No description provided for @meetingBeautyLevel.
  ///
  /// In zh, this message translates to:
  /// **'美颜等级'**
  String get meetingBeautyLevel;

  /// No description provided for @meetingJoinTips.
  ///
  /// In zh, this message translates to:
  /// **'正在进入会议...'**
  String get meetingJoinTips;

  /// No description provided for @meetingQuit.
  ///
  /// In zh, this message translates to:
  /// **'结束会议'**
  String get meetingQuit;

  /// No description provided for @meetingDefalutTitle.
  ///
  /// In zh, this message translates to:
  /// **'视频会议'**
  String get meetingDefalutTitle;

  /// No description provided for @meetingJoinFail.
  ///
  /// In zh, this message translates to:
  /// **'加入会议失败'**
  String get meetingJoinFail;

  /// No description provided for @meetingHostKickedYou.
  ///
  /// In zh, this message translates to:
  /// **'因被主持人移出或切换至其他设备，您已退出会议'**
  String get meetingHostKickedYou;

  /// No description provided for @meetingMicphoneNotWorksDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'无法使用麦克风'**
  String get meetingMicphoneNotWorksDialogTitle;

  /// No description provided for @meetingMicphoneNotWorksDialogMessage.
  ///
  /// In zh, this message translates to:
  /// **'您已静音，请点击\"解除静音\"开启麦克风'**
  String get meetingMicphoneNotWorksDialogMessage;

  /// No description provided for @meetingFinish.
  ///
  /// In zh, this message translates to:
  /// **'结束'**
  String get meetingFinish;

  /// No description provided for @meetingLeave.
  ///
  /// In zh, this message translates to:
  /// **'离开'**
  String get meetingLeave;

  /// No description provided for @meetingLeaveFull.
  ///
  /// In zh, this message translates to:
  /// **'离开会议'**
  String get meetingLeaveFull;

  /// No description provided for @meetingSpeakingPrefix.
  ///
  /// In zh, this message translates to:
  /// **'正在讲话:'**
  String get meetingSpeakingPrefix;

  /// No description provided for @meetingLockMeetingByHost.
  ///
  /// In zh, this message translates to:
  /// **'会议已锁定，新参会者将无法加入会议'**
  String get meetingLockMeetingByHost;

  /// No description provided for @meetingLockMeetingByHostFail.
  ///
  /// In zh, this message translates to:
  /// **'会议锁定失败'**
  String get meetingLockMeetingByHostFail;

  /// No description provided for @meetingUnLockMeetingByHost.
  ///
  /// In zh, this message translates to:
  /// **'会议已解锁，新参会者将可以加入会议'**
  String get meetingUnLockMeetingByHost;

  /// No description provided for @meetingUnLockMeetingByHostFail.
  ///
  /// In zh, this message translates to:
  /// **'会议解锁失败'**
  String get meetingUnLockMeetingByHostFail;

  /// No description provided for @meetingLock.
  ///
  /// In zh, this message translates to:
  /// **'锁定会议'**
  String get meetingLock;

  /// No description provided for @meetingMore.
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get meetingMore;

  /// No description provided for @meetingPassword.
  ///
  /// In zh, this message translates to:
  /// **'会议密码'**
  String get meetingPassword;

  /// No description provided for @meetingEnterPassword.
  ///
  /// In zh, this message translates to:
  /// **'请输入会议密码'**
  String get meetingEnterPassword;

  /// No description provided for @meetingWrongPassword.
  ///
  /// In zh, this message translates to:
  /// **'密码错误'**
  String get meetingWrongPassword;

  /// No description provided for @meetingNum.
  ///
  /// In zh, this message translates to:
  /// **'会议号'**
  String get meetingNum;

  /// No description provided for @meetingShortNum.
  ///
  /// In zh, this message translates to:
  /// **'会议短号'**
  String get meetingShortNum;

  /// No description provided for @meetingInfoDesc.
  ///
  /// In zh, this message translates to:
  /// **'会议正在加密保护中'**
  String get meetingInfoDesc;

  /// No description provided for @meetingAlreadyHandsUpTips.
  ///
  /// In zh, this message translates to:
  /// **'您已举手，请等待主持人处理'**
  String get meetingAlreadyHandsUpTips;

  /// No description provided for @meetingHandsUpApply.
  ///
  /// In zh, this message translates to:
  /// **'举手申请'**
  String get meetingHandsUpApply;

  /// No description provided for @meetingCancelHandsUp.
  ///
  /// In zh, this message translates to:
  /// **'取消举手'**
  String get meetingCancelHandsUp;

  /// No description provided for @meetingCancelHandsUpConfirm.
  ///
  /// In zh, this message translates to:
  /// **'是否确定取消举手？'**
  String get meetingCancelHandsUpConfirm;

  /// No description provided for @meetingHandsUpDown.
  ///
  /// In zh, this message translates to:
  /// **'手放下'**
  String get meetingHandsUpDown;

  /// No description provided for @meetingInHandsUp.
  ///
  /// In zh, this message translates to:
  /// **'举手中'**
  String get meetingInHandsUp;

  /// No description provided for @meetingHandsUpFail.
  ///
  /// In zh, this message translates to:
  /// **'举手失败'**
  String get meetingHandsUpFail;

  /// No description provided for @meetingHandsUpSuccess.
  ///
  /// In zh, this message translates to:
  /// **'举手成功，等待主持人处理'**
  String get meetingHandsUpSuccess;

  /// No description provided for @meetingCancelHandsUpFail.
  ///
  /// In zh, this message translates to:
  /// **'取消举手失败'**
  String get meetingCancelHandsUpFail;

  /// No description provided for @meetingHostRejectAudioHandsUp.
  ///
  /// In zh, this message translates to:
  /// **'主持人已将您的手放下'**
  String get meetingHostRejectAudioHandsUp;

  /// No description provided for @meetingSip.
  ///
  /// In zh, this message translates to:
  /// **'SIP'**
  String get meetingSip;

  /// No description provided for @meetingInviteUrl.
  ///
  /// In zh, this message translates to:
  /// **'入会链接'**
  String get meetingInviteUrl;

  /// No description provided for @meetingInvitePageTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加与会者'**
  String get meetingInvitePageTitle;

  /// No description provided for @meetingSipNumber.
  ///
  /// In zh, this message translates to:
  /// **'SIP电话/终端'**
  String get meetingSipNumber;

  /// No description provided for @meetingSipHost.
  ///
  /// In zh, this message translates to:
  /// **'SIP地址'**
  String get meetingSipHost;

  /// No description provided for @meetingInvite.
  ///
  /// In zh, this message translates to:
  /// **'邀请'**
  String get meetingInvite;

  /// No description provided for @meetingInviteListTitle.
  ///
  /// In zh, this message translates to:
  /// **'邀请列表'**
  String get meetingInviteListTitle;

  /// No description provided for @meetingInvitationSendSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已发起邀请'**
  String get meetingInvitationSendSuccess;

  /// No description provided for @meetingInvitationSendFail.
  ///
  /// In zh, this message translates to:
  /// **'邀请失败'**
  String get meetingInvitationSendFail;

  /// No description provided for @meetingRemovedByHost.
  ///
  /// In zh, this message translates to:
  /// **'您已被主持人移除会议'**
  String get meetingRemovedByHost;

  /// No description provided for @meetingCloseByHost.
  ///
  /// In zh, this message translates to:
  /// **'会议已结束'**
  String get meetingCloseByHost;

  /// No description provided for @meetingWasInterrupted.
  ///
  /// In zh, this message translates to:
  /// **'会议已中断'**
  String get meetingWasInterrupted;

  /// No description provided for @meetingSyncDataError.
  ///
  /// In zh, this message translates to:
  /// **'房间信息同步失败'**
  String get meetingSyncDataError;

  /// No description provided for @meetingLeaveMeetingBySelf.
  ///
  /// In zh, this message translates to:
  /// **'离开会议'**
  String get meetingLeaveMeetingBySelf;

  /// No description provided for @meetingClosed.
  ///
  /// In zh, this message translates to:
  /// **'会议被关闭'**
  String get meetingClosed;

  /// No description provided for @meetingConnectFail.
  ///
  /// In zh, this message translates to:
  /// **'连接失败'**
  String get meetingConnectFail;

  /// No description provided for @meetingJoinTimeout.
  ///
  /// In zh, this message translates to:
  /// **'加入会议超时，请重试'**
  String get meetingJoinTimeout;

  /// No description provided for @meetingEndOfLife.
  ///
  /// In zh, this message translates to:
  /// **'会议时长已达上限，会议关闭'**
  String get meetingEndOfLife;

  /// No description provided for @meetingEndTip.
  ///
  /// In zh, this message translates to:
  /// **'距离会议关闭仅剩'**
  String get meetingEndTip;

  /// No description provided for @meetingReuseIMNotSupportAnonymousJoinMeeting.
  ///
  /// In zh, this message translates to:
  /// **'IM复用不支持匿名入会'**
  String get meetingReuseIMNotSupportAnonymousJoinMeeting;

  /// No description provided for @meetingInviteDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'会议邀请'**
  String get meetingInviteDialogTitle;

  /// No description provided for @meetingInviteContentCopySuccess.
  ///
  /// In zh, this message translates to:
  /// **'已复制会议邀请内容'**
  String get meetingInviteContentCopySuccess;

  /// No description provided for @meetingInviteTitle.
  ///
  /// In zh, this message translates to:
  /// **'邀请您参加会议'**
  String get meetingInviteTitle;

  /// No description provided for @meetingSubject.
  ///
  /// In zh, this message translates to:
  /// **'会议主题'**
  String get meetingSubject;

  /// No description provided for @meetingTime.
  ///
  /// In zh, this message translates to:
  /// **'会议时间'**
  String get meetingTime;

  /// No description provided for @meetingInvitationUrl.
  ///
  /// In zh, this message translates to:
  /// **'入会链接'**
  String get meetingInvitationUrl;

  /// No description provided for @meetingCopyInvite.
  ///
  /// In zh, this message translates to:
  /// **'复制邀请'**
  String get meetingCopyInvite;

  /// No description provided for @meetingInternalSpecial.
  ///
  /// In zh, this message translates to:
  /// **'内部专用'**
  String get meetingInternalSpecial;

  /// No description provided for @loginOnOtherDevice.
  ///
  /// In zh, this message translates to:
  /// **'已切换至其他设备'**
  String get loginOnOtherDevice;

  /// No description provided for @authInfoExpired.
  ///
  /// In zh, this message translates to:
  /// **'登录状态已过期，请重新登录'**
  String get authInfoExpired;

  /// No description provided for @meetingCamera.
  ///
  /// In zh, this message translates to:
  /// **'相机'**
  String get meetingCamera;

  /// No description provided for @meetingMicrophone.
  ///
  /// In zh, this message translates to:
  /// **'麦克风'**
  String get meetingMicrophone;

  /// No description provided for @meetingBluetooth.
  ///
  /// In zh, this message translates to:
  /// **'蓝牙'**
  String get meetingBluetooth;

  /// No description provided for @meetingPhoneState.
  ///
  /// In zh, this message translates to:
  /// **'电话'**
  String get meetingPhoneState;

  /// No description provided for @meetingNeedRationaleAudioPermission.
  ///
  /// In zh, this message translates to:
  /// **'音视频会议需要申请{permission}权限，用于会议中的音频交流'**
  String meetingNeedRationaleAudioPermission(Object permission);

  /// No description provided for @meetingNeedRationaleVideoPermission.
  ///
  /// In zh, this message translates to:
  /// **'音视频会议需要申请{permission}权限，用于会议中的视频交流'**
  String meetingNeedRationaleVideoPermission(Object permission);

  /// No description provided for @meetingNeedRationalePhotoPermission.
  ///
  /// In zh, this message translates to:
  /// **'音视频会议需要申请照片权限，用于会议中的虚拟背景（添加、更换背景图片）功能'**
  String get meetingNeedRationalePhotoPermission;

  /// No description provided for @meetingDisconnectAudio.
  ///
  /// In zh, this message translates to:
  /// **'断开音频'**
  String get meetingDisconnectAudio;

  /// No description provided for @meetingReconnectAudio.
  ///
  /// In zh, this message translates to:
  /// **'连接音频'**
  String get meetingReconnectAudio;

  /// No description provided for @meetingDisconnectAudioTips.
  ///
  /// In zh, this message translates to:
  /// **'如需关闭会议声音，您可以点击更多中的“断开音频”'**
  String get meetingDisconnectAudioTips;

  /// No description provided for @meetingNotificationContentTitle.
  ///
  /// In zh, this message translates to:
  /// **'视频会议'**
  String get meetingNotificationContentTitle;

  /// No description provided for @meetingNotificationContentText.
  ///
  /// In zh, this message translates to:
  /// **'视频会议正在进行中'**
  String get meetingNotificationContentText;

  /// No description provided for @meetingNotificationContentTicker.
  ///
  /// In zh, this message translates to:
  /// **'视频会议'**
  String get meetingNotificationContentTicker;

  /// No description provided for @meetingNotificationChannelId.
  ///
  /// In zh, this message translates to:
  /// **'ne_meeting_channel'**
  String get meetingNotificationChannelId;

  /// No description provided for @meetingNotificationChannelName.
  ///
  /// In zh, this message translates to:
  /// **'视频会议通知'**
  String get meetingNotificationChannelName;

  /// No description provided for @meetingNotificationChannelDesc.
  ///
  /// In zh, this message translates to:
  /// **'视频会议通知'**
  String get meetingNotificationChannelDesc;

  /// No description provided for @meetingUserJoin.
  ///
  /// In zh, this message translates to:
  /// **'{userName}加入会议'**
  String meetingUserJoin(Object userName);

  /// No description provided for @meetingUserLeave.
  ///
  /// In zh, this message translates to:
  /// **'{userName}离开会议'**
  String meetingUserLeave(Object userName);

  /// No description provided for @meetingStartAudioShare.
  ///
  /// In zh, this message translates to:
  /// **'开启音频共享'**
  String get meetingStartAudioShare;

  /// No description provided for @meetingStopAudioShare.
  ///
  /// In zh, this message translates to:
  /// **'关闭音频共享'**
  String get meetingStopAudioShare;

  /// No description provided for @meetingSwitchFcusView.
  ///
  /// In zh, this message translates to:
  /// **'切换至演讲者视图'**
  String get meetingSwitchFcusView;

  /// No description provided for @meetingSwitchGalleryView.
  ///
  /// In zh, this message translates to:
  /// **'切换至画廊视图'**
  String get meetingSwitchGalleryView;

  /// No description provided for @meetingNoSupportSwitch.
  ///
  /// In zh, this message translates to:
  /// **'iPad不支持切换模式'**
  String get meetingNoSupportSwitch;

  /// No description provided for @meetingFuncNotAvailableWhenInCallState.
  ///
  /// In zh, this message translates to:
  /// **'系统通话中，无法使用该功能'**
  String get meetingFuncNotAvailableWhenInCallState;

  /// No description provided for @meetingRejoining.
  ///
  /// In zh, this message translates to:
  /// **'重新入会'**
  String get meetingRejoining;

  /// No description provided for @meetingSecurity.
  ///
  /// In zh, this message translates to:
  /// **'安全'**
  String get meetingSecurity;

  /// No description provided for @meetingManagement.
  ///
  /// In zh, this message translates to:
  /// **'会议管理'**
  String get meetingManagement;

  /// No description provided for @meetingWatermark.
  ///
  /// In zh, this message translates to:
  /// **'会议水印'**
  String get meetingWatermark;

  /// No description provided for @meetingBeKickedOutByHost.
  ///
  /// In zh, this message translates to:
  /// **'主持人已将您从会议中移除'**
  String get meetingBeKickedOutByHost;

  /// No description provided for @meetingBeKickedOut.
  ///
  /// In zh, this message translates to:
  /// **'被移除会议'**
  String get meetingBeKickedOut;

  /// No description provided for @meetingClickOkToClose.
  ///
  /// In zh, this message translates to:
  /// **'点击确定，该页面自动关闭'**
  String get meetingClickOkToClose;

  /// No description provided for @meetingLeaveConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要离开会议吗?'**
  String get meetingLeaveConfirm;

  /// No description provided for @meetingWatermarkEnabled.
  ///
  /// In zh, this message translates to:
  /// **'水印已开启'**
  String get meetingWatermarkEnabled;

  /// No description provided for @meetingWatermarkDisabled.
  ///
  /// In zh, this message translates to:
  /// **'水印已关闭'**
  String get meetingWatermarkDisabled;

  /// No description provided for @meetingInfo.
  ///
  /// In zh, this message translates to:
  /// **'会议信息'**
  String get meetingInfo;

  /// No description provided for @meetingNickname.
  ///
  /// In zh, this message translates to:
  /// **'会议昵称'**
  String get meetingNickname;

  /// No description provided for @meetingHostChangeYourMeetingName.
  ///
  /// In zh, this message translates to:
  /// **'主持人修改了你的会中名称'**
  String get meetingHostChangeYourMeetingName;

  /// No description provided for @meetingIsInCall.
  ///
  /// In zh, this message translates to:
  /// **'正在接听系统电话'**
  String get meetingIsInCall;

  /// No description provided for @screenShare.
  ///
  /// In zh, this message translates to:
  /// **'共享屏幕'**
  String get screenShare;

  /// No description provided for @screenShareStop.
  ///
  /// In zh, this message translates to:
  /// **'结束共享'**
  String get screenShareStop;

  /// No description provided for @screenShareOverLimit.
  ///
  /// In zh, this message translates to:
  /// **'已有人在共享，您无法共享'**
  String get screenShareOverLimit;

  /// No description provided for @screenShareNoPermission.
  ///
  /// In zh, this message translates to:
  /// **'没有屏幕共享权限'**
  String get screenShareNoPermission;

  /// No description provided for @screenShareTips.
  ///
  /// In zh, this message translates to:
  /// **'将开始截取您的屏幕上显示的所有内容。'**
  String get screenShareTips;

  /// No description provided for @screenShareStopFail.
  ///
  /// In zh, this message translates to:
  /// **'停止共享屏幕失败'**
  String get screenShareStopFail;

  /// No description provided for @screenShareStartFail.
  ///
  /// In zh, this message translates to:
  /// **'发起共享屏幕失败'**
  String get screenShareStartFail;

  /// No description provided for @screenShareLocalTips.
  ///
  /// In zh, this message translates to:
  /// **'{userName}正在共享屏幕'**
  String screenShareLocalTips(Object userName);

  /// No description provided for @screenShareUser.
  ///
  /// In zh, this message translates to:
  /// **'{userName}的共享屏幕'**
  String screenShareUser(Object userName);

  /// No description provided for @screenShareInteractionTip.
  ///
  /// In zh, this message translates to:
  /// **'双指分开放大画面'**
  String get screenShareInteractionTip;

  /// No description provided for @whiteBoardShareStopFail.
  ///
  /// In zh, this message translates to:
  /// **'停止共享白板失败'**
  String get whiteBoardShareStopFail;

  /// No description provided for @whiteBoardShareStartFail.
  ///
  /// In zh, this message translates to:
  /// **'发起白板共享失败'**
  String get whiteBoardShareStartFail;

  /// No description provided for @whiteboardShare.
  ///
  /// In zh, this message translates to:
  /// **'共享白板'**
  String get whiteboardShare;

  /// No description provided for @whiteBoardClose.
  ///
  /// In zh, this message translates to:
  /// **'退出白板'**
  String get whiteBoardClose;

  /// No description provided for @whiteBoardInteractionTip.
  ///
  /// In zh, this message translates to:
  /// **'您被授予白板互动权限'**
  String get whiteBoardInteractionTip;

  /// No description provided for @whiteBoardUndoInteractionTip.
  ///
  /// In zh, this message translates to:
  /// **'您被取消白板互动权限'**
  String get whiteBoardUndoInteractionTip;

  /// No description provided for @whiteBoardNoAuthority.
  ///
  /// In zh, this message translates to:
  /// **'暂未开通白板权限，请联系销售开通'**
  String get whiteBoardNoAuthority;

  /// No description provided for @whiteBoardPackUp.
  ///
  /// In zh, this message translates to:
  /// **'收起'**
  String get whiteBoardPackUp;

  /// No description provided for @meetingHasScreenShareShare.
  ///
  /// In zh, this message translates to:
  /// **'屏幕共享时暂不支持白板共享'**
  String get meetingHasScreenShareShare;

  /// No description provided for @meetingHasWhiteBoardShare.
  ///
  /// In zh, this message translates to:
  /// **'共享白板时暂不支持屏幕共享'**
  String get meetingHasWhiteBoardShare;

  /// No description provided for @meetingStopSharing.
  ///
  /// In zh, this message translates to:
  /// **'停止共享'**
  String get meetingStopSharing;

  /// No description provided for @meetingStopSharingConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定停止正在进行的共享?'**
  String get meetingStopSharingConfirm;

  /// No description provided for @virtualBackground.
  ///
  /// In zh, this message translates to:
  /// **'虚拟背景'**
  String get virtualBackground;

  /// No description provided for @virtualBackgroundImageNotExist.
  ///
  /// In zh, this message translates to:
  /// **'自定义背景图片不存在'**
  String get virtualBackgroundImageNotExist;

  /// No description provided for @virtualBackgroundImageFormatNotSupported.
  ///
  /// In zh, this message translates to:
  /// **'自定义背景图片的图片格式无效'**
  String get virtualBackgroundImageFormatNotSupported;

  /// No description provided for @virtualBackgroundImageDeviceNotSupported.
  ///
  /// In zh, this message translates to:
  /// **'该设备不支持使用虚拟背景'**
  String get virtualBackgroundImageDeviceNotSupported;

  /// No description provided for @virtualBackgroundImageLarge.
  ///
  /// In zh, this message translates to:
  /// **'自定义背景图片超过5M大小限制'**
  String get virtualBackgroundImageLarge;

  /// No description provided for @virtualBackgroundImageMax.
  ///
  /// In zh, this message translates to:
  /// **'自定义背景图片超过最大数量'**
  String get virtualBackgroundImageMax;

  /// No description provided for @virtualBackgroundSelectTip.
  ///
  /// In zh, this message translates to:
  /// **'所选背景立即生效'**
  String get virtualBackgroundSelectTip;

  /// No description provided for @live.
  ///
  /// In zh, this message translates to:
  /// **'直播'**
  String get live;

  /// No description provided for @liveMeeting.
  ///
  /// In zh, this message translates to:
  /// **'会议直播'**
  String get liveMeeting;

  /// No description provided for @liveMeetingTitle.
  ///
  /// In zh, this message translates to:
  /// **'会议直播主题'**
  String get liveMeetingTitle;

  /// No description provided for @liveMeetingUrl.
  ///
  /// In zh, this message translates to:
  /// **'直播地址'**
  String get liveMeetingUrl;

  /// No description provided for @liveEnterLivePassword.
  ///
  /// In zh, this message translates to:
  /// **'请输入直播密码'**
  String get liveEnterLivePassword;

  /// No description provided for @liveEnterLiveSixDigitPassword.
  ///
  /// In zh, this message translates to:
  /// **'请输入6位数字密码'**
  String get liveEnterLiveSixDigitPassword;

  /// No description provided for @liveInteraction.
  ///
  /// In zh, this message translates to:
  /// **'直播互动'**
  String get liveInteraction;

  /// No description provided for @liveInteractionTips.
  ///
  /// In zh, this message translates to:
  /// **'开启后，会议室和直播间消息互相可见'**
  String get liveInteractionTips;

  /// No description provided for @liveLevel.
  ///
  /// In zh, this message translates to:
  /// **'仅本企业员工可观看'**
  String get liveLevel;

  /// No description provided for @liveLevelTip.
  ///
  /// In zh, this message translates to:
  /// **'开启后，非本企业员工无法观看直播'**
  String get liveLevelTip;

  /// No description provided for @liveViewSetting.
  ///
  /// In zh, this message translates to:
  /// **'直播视图设置'**
  String get liveViewSetting;

  /// No description provided for @liveViewSettingChange.
  ///
  /// In zh, this message translates to:
  /// **'主播发生变更'**
  String get liveViewSettingChange;

  /// No description provided for @liveViewPreviewTips.
  ///
  /// In zh, this message translates to:
  /// **'当前直播视图预览'**
  String get liveViewPreviewTips;

  /// No description provided for @liveViewPreviewDesc.
  ///
  /// In zh, this message translates to:
  /// **'请先进行\n直播视图设置'**
  String get liveViewPreviewDesc;

  /// No description provided for @liveStart.
  ///
  /// In zh, this message translates to:
  /// **'开始直播'**
  String get liveStart;

  /// No description provided for @liveUpdate.
  ///
  /// In zh, this message translates to:
  /// **'更新直播设置'**
  String get liveUpdate;

  /// No description provided for @liveStop.
  ///
  /// In zh, this message translates to:
  /// **'停止直播'**
  String get liveStop;

  /// No description provided for @liveGalleryView.
  ///
  /// In zh, this message translates to:
  /// **'画廊视图'**
  String get liveGalleryView;

  /// No description provided for @liveFocusView.
  ///
  /// In zh, this message translates to:
  /// **'焦点视图'**
  String get liveFocusView;

  /// No description provided for @liveScreenShareView.
  ///
  /// In zh, this message translates to:
  /// **'屏幕共享视图'**
  String get liveScreenShareView;

  /// No description provided for @liveChooseView.
  ///
  /// In zh, this message translates to:
  /// **'选择视图样式'**
  String get liveChooseView;

  /// No description provided for @liveChooseCountTips.
  ///
  /// In zh, this message translates to:
  /// **'选择参会者作为主播，最多选择4人'**
  String get liveChooseCountTips;

  /// No description provided for @liveStartFail.
  ///
  /// In zh, this message translates to:
  /// **'直播开始失败,请稍后重试'**
  String get liveStartFail;

  /// No description provided for @liveStartSuccess.
  ///
  /// In zh, this message translates to:
  /// **'直播开始成功'**
  String get liveStartSuccess;

  /// No description provided for @livePickerCount.
  ///
  /// In zh, this message translates to:
  /// **'已选择{length}人'**
  String livePickerCount(Object length);

  /// No description provided for @liveUpdateFail.
  ///
  /// In zh, this message translates to:
  /// **'直播更新失败,请稍后重试'**
  String get liveUpdateFail;

  /// No description provided for @liveUpdateSuccess.
  ///
  /// In zh, this message translates to:
  /// **'直播更新成功'**
  String get liveUpdateSuccess;

  /// No description provided for @liveStopFail.
  ///
  /// In zh, this message translates to:
  /// **'直播停止失败,请稍后重试'**
  String get liveStopFail;

  /// No description provided for @liveStopSuccess.
  ///
  /// In zh, this message translates to:
  /// **'直播停止成功'**
  String get liveStopSuccess;

  /// No description provided for @livePassword.
  ///
  /// In zh, this message translates to:
  /// **'直播密码'**
  String get livePassword;

  /// No description provided for @liveDisableAuthLevel.
  ///
  /// In zh, this message translates to:
  /// **'直播过程中，不能修改观看直播权限'**
  String get liveDisableAuthLevel;

  /// No description provided for @liveStreaming.
  ///
  /// In zh, this message translates to:
  /// **'直播中'**
  String get liveStreaming;

  /// No description provided for @participants.
  ///
  /// In zh, this message translates to:
  /// **'参会者'**
  String get participants;

  /// No description provided for @participantsManager.
  ///
  /// In zh, this message translates to:
  /// **'管理参会者'**
  String get participantsManager;

  /// No description provided for @participantAssignedHost.
  ///
  /// In zh, this message translates to:
  /// **'您已经成为主持人'**
  String get participantAssignedHost;

  /// No description provided for @participantAssignedCoHost.
  ///
  /// In zh, this message translates to:
  /// **'您已被设为联席主持人'**
  String get participantAssignedCoHost;

  /// No description provided for @participantUnassignedCoHost.
  ///
  /// In zh, this message translates to:
  /// **'您已被取消设为联席主持人'**
  String get participantUnassignedCoHost;

  /// No description provided for @participantAssignedActiveSpeaker.
  ///
  /// In zh, this message translates to:
  /// **'您已被设置为焦点视频'**
  String get participantAssignedActiveSpeaker;

  /// No description provided for @participantUnassignedActiveSpeaker.
  ///
  /// In zh, this message translates to:
  /// **'您已被取消焦点视频'**
  String get participantUnassignedActiveSpeaker;

  /// No description provided for @participantMuteAudioAll.
  ///
  /// In zh, this message translates to:
  /// **'全体静音'**
  String get participantMuteAudioAll;

  /// No description provided for @participantMuteAudioAllDialogTips.
  ///
  /// In zh, this message translates to:
  /// **'所有以及新加入成员将被静音'**
  String get participantMuteAudioAllDialogTips;

  /// No description provided for @participantMuteVideoAllDialogTips.
  ///
  /// In zh, this message translates to:
  /// **'所有以及新加入成员将被关闭摄像头'**
  String get participantMuteVideoAllDialogTips;

  /// No description provided for @participantUnmuteAll.
  ///
  /// In zh, this message translates to:
  /// **'解除全体静音'**
  String get participantUnmuteAll;

  /// No description provided for @participantMute.
  ///
  /// In zh, this message translates to:
  /// **'静音'**
  String get participantMute;

  /// No description provided for @participantUnmute.
  ///
  /// In zh, this message translates to:
  /// **'解除静音'**
  String get participantUnmute;

  /// No description provided for @participantTurnOffVideos.
  ///
  /// In zh, this message translates to:
  /// **'全体关闭视频'**
  String get participantTurnOffVideos;

  /// No description provided for @participantTurnOnVideos.
  ///
  /// In zh, this message translates to:
  /// **'全体打开视频'**
  String get participantTurnOnVideos;

  /// No description provided for @participantStopVideo.
  ///
  /// In zh, this message translates to:
  /// **'停止视频'**
  String get participantStopVideo;

  /// No description provided for @participantStartVideo.
  ///
  /// In zh, this message translates to:
  /// **'开启视频'**
  String get participantStartVideo;

  /// No description provided for @participantTurnOffAudioAndVideo.
  ///
  /// In zh, this message translates to:
  /// **'关闭音视频'**
  String get participantTurnOffAudioAndVideo;

  /// No description provided for @participantTurnOnAudioAndVideo.
  ///
  /// In zh, this message translates to:
  /// **'打开音视频'**
  String get participantTurnOnAudioAndVideo;

  /// No description provided for @participantHostStoppedShare.
  ///
  /// In zh, this message translates to:
  /// **'主持人已终止了您的共享'**
  String get participantHostStoppedShare;

  /// No description provided for @participantHostStopWhiteboard.
  ///
  /// In zh, this message translates to:
  /// **'主持人已终止您的白板共享'**
  String get participantHostStopWhiteboard;

  /// No description provided for @participantAssignActiveSpeaker.
  ///
  /// In zh, this message translates to:
  /// **'设为焦点视频'**
  String get participantAssignActiveSpeaker;

  /// No description provided for @participantUnassignActiveSpeaker.
  ///
  /// In zh, this message translates to:
  /// **'取消焦点视频'**
  String get participantUnassignActiveSpeaker;

  /// No description provided for @participantTransferHost.
  ///
  /// In zh, this message translates to:
  /// **'移交主持人'**
  String get participantTransferHost;

  /// No description provided for @participantTransferHostConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确认将主持人移交给{userName}?'**
  String participantTransferHostConfirm(Object userName);

  /// No description provided for @participantRemove.
  ///
  /// In zh, this message translates to:
  /// **'移除'**
  String get participantRemove;

  /// No description provided for @participantRename.
  ///
  /// In zh, this message translates to:
  /// **'改名'**
  String get participantRename;

  /// No description provided for @participantRenameDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'修改参会姓名'**
  String get participantRenameDialogTitle;

  /// No description provided for @participantAssignCoHost.
  ///
  /// In zh, this message translates to:
  /// **'设置联席主持人'**
  String get participantAssignCoHost;

  /// No description provided for @participantUnassignCoHost.
  ///
  /// In zh, this message translates to:
  /// **'取消联席主持人'**
  String get participantUnassignCoHost;

  /// No description provided for @participantRenameTips.
  ///
  /// In zh, this message translates to:
  /// **'请输入新的昵称'**
  String get participantRenameTips;

  /// No description provided for @participantRenameSuccess.
  ///
  /// In zh, this message translates to:
  /// **'改名成功'**
  String get participantRenameSuccess;

  /// No description provided for @participantRenameFail.
  ///
  /// In zh, this message translates to:
  /// **'改名失败'**
  String get participantRenameFail;

  /// No description provided for @participantRemoveConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确认移除'**
  String get participantRemoveConfirm;

  /// No description provided for @participantCannotRemoveSelf.
  ///
  /// In zh, this message translates to:
  /// **'不能移除自己'**
  String get participantCannotRemoveSelf;

  /// No description provided for @participantMuteAudioFail.
  ///
  /// In zh, this message translates to:
  /// **'静音失败'**
  String get participantMuteAudioFail;

  /// No description provided for @participantUnMuteAudioFail.
  ///
  /// In zh, this message translates to:
  /// **'解除静音失败'**
  String get participantUnMuteAudioFail;

  /// No description provided for @participantMuteVideoFail.
  ///
  /// In zh, this message translates to:
  /// **'停止视频失败'**
  String get participantMuteVideoFail;

  /// No description provided for @participantUnMuteVideoFail.
  ///
  /// In zh, this message translates to:
  /// **'开启视频失败'**
  String get participantUnMuteVideoFail;

  /// No description provided for @participantFailedToAssignActiveSpeaker.
  ///
  /// In zh, this message translates to:
  /// **'设为焦点视频失败'**
  String get participantFailedToAssignActiveSpeaker;

  /// No description provided for @participantFailedToUnassignActiveSpeaker.
  ///
  /// In zh, this message translates to:
  /// **'取消焦点视频失败'**
  String get participantFailedToUnassignActiveSpeaker;

  /// No description provided for @participantFailedToLowerHand.
  ///
  /// In zh, this message translates to:
  /// **'放下成员举手失败'**
  String get participantFailedToLowerHand;

  /// No description provided for @participantFailedToTransferHost.
  ///
  /// In zh, this message translates to:
  /// **'移交主持人失败'**
  String get participantFailedToTransferHost;

  /// No description provided for @participantFailedToRemove.
  ///
  /// In zh, this message translates to:
  /// **'移除失败'**
  String get participantFailedToRemove;

  /// No description provided for @participantOpenCamera.
  ///
  /// In zh, this message translates to:
  /// **'打开摄像头'**
  String get participantOpenCamera;

  /// No description provided for @participantOpenMicrophone.
  ///
  /// In zh, this message translates to:
  /// **'打开麦克风'**
  String get participantOpenMicrophone;

  /// No description provided for @participantHostOpenCameraTips.
  ///
  /// In zh, this message translates to:
  /// **'主持人已重新打开您的摄像头，确认打开？'**
  String get participantHostOpenCameraTips;

  /// No description provided for @participantHostOpenMicroTips.
  ///
  /// In zh, this message translates to:
  /// **'主持人已重新打开您的麦克风，确认打开？'**
  String get participantHostOpenMicroTips;

  /// No description provided for @participantMuteAllAudioTip.
  ///
  /// In zh, this message translates to:
  /// **'允许参会者自行解除静音'**
  String get participantMuteAllAudioTip;

  /// No description provided for @participantMuteAllVideoTip.
  ///
  /// In zh, this message translates to:
  /// **'允许参会者自行开启视频'**
  String get participantMuteAllVideoTip;

  /// No description provided for @participantMuteAllAudioSuccess.
  ///
  /// In zh, this message translates to:
  /// **'您已进行全体静音'**
  String get participantMuteAllAudioSuccess;

  /// No description provided for @participantMuteAllAudioFail.
  ///
  /// In zh, this message translates to:
  /// **'全体静音失败'**
  String get participantMuteAllAudioFail;

  /// No description provided for @participantMuteAllVideoSuccess.
  ///
  /// In zh, this message translates to:
  /// **'您已进行全体关闭视频'**
  String get participantMuteAllVideoSuccess;

  /// No description provided for @participantMuteAllVideoFail.
  ///
  /// In zh, this message translates to:
  /// **'全体关闭视频失败'**
  String get participantMuteAllVideoFail;

  /// No description provided for @participantUnMuteAllAudioSuccess.
  ///
  /// In zh, this message translates to:
  /// **'您已请求解除全体静音'**
  String get participantUnMuteAllAudioSuccess;

  /// No description provided for @participantUnMuteAllAudioFail.
  ///
  /// In zh, this message translates to:
  /// **'解除全体静音失败'**
  String get participantUnMuteAllAudioFail;

  /// No description provided for @participantUnMuteAllVideoSuccess.
  ///
  /// In zh, this message translates to:
  /// **'您已请求全体打开视频'**
  String get participantUnMuteAllVideoSuccess;

  /// No description provided for @participantUnMuteAllVideoFail.
  ///
  /// In zh, this message translates to:
  /// **'全体打开视频失败'**
  String get participantUnMuteAllVideoFail;

  /// No description provided for @participantHostMuteVideo.
  ///
  /// In zh, this message translates to:
  /// **'您已被停止视频'**
  String get participantHostMuteVideo;

  /// No description provided for @participantHostMuteAudio.
  ///
  /// In zh, this message translates to:
  /// **'您已被静音'**
  String get participantHostMuteAudio;

  /// No description provided for @participantHostMuteAllAudio.
  ///
  /// In zh, this message translates to:
  /// **'主持人设置了全体静音'**
  String get participantHostMuteAllAudio;

  /// No description provided for @participantHostMuteAllVideo.
  ///
  /// In zh, this message translates to:
  /// **'主持人设置了全体关闭视频'**
  String get participantHostMuteAllVideo;

  /// No description provided for @participantMuteAudioHandsUpOnTips.
  ///
  /// In zh, this message translates to:
  /// **'主持人已将您解除静音，你可以自由发言'**
  String get participantMuteAudioHandsUpOnTips;

  /// No description provided for @participantOverRoleLimitCount.
  ///
  /// In zh, this message translates to:
  /// **'分配角色超过人数限制'**
  String get participantOverRoleLimitCount;

  /// No description provided for @participantMe.
  ///
  /// In zh, this message translates to:
  /// **'我'**
  String get participantMe;

  /// No description provided for @participantSearchMember.
  ///
  /// In zh, this message translates to:
  /// **'搜索成员'**
  String get participantSearchMember;

  /// No description provided for @participantHost.
  ///
  /// In zh, this message translates to:
  /// **'主持人'**
  String get participantHost;

  /// No description provided for @participantCoHost.
  ///
  /// In zh, this message translates to:
  /// **'联席主持人'**
  String get participantCoHost;

  /// No description provided for @participantMuteAllHandsUpTips.
  ///
  /// In zh, this message translates to:
  /// **'主持人已将全体静音，您可以举手申请发言'**
  String get participantMuteAllHandsUpTips;

  /// No description provided for @participantTurnOffAllVideoHandsUpTips.
  ///
  /// In zh, this message translates to:
  /// **'主持人已将全体视频关闭，您可以举手申请开启视频'**
  String get participantTurnOffAllVideoHandsUpTips;

  /// No description provided for @participantWhiteBoardInteract.
  ///
  /// In zh, this message translates to:
  /// **'授权白板互动'**
  String get participantWhiteBoardInteract;

  /// No description provided for @participantWhiteBoardInteractFail.
  ///
  /// In zh, this message translates to:
  /// **'授权白板互动失败'**
  String get participantWhiteBoardInteractFail;

  /// No description provided for @participantUndoWhiteBoardInteract.
  ///
  /// In zh, this message translates to:
  /// **'撤回白板互动'**
  String get participantUndoWhiteBoardInteract;

  /// No description provided for @participantUndoWhiteBoardInteractFail.
  ///
  /// In zh, this message translates to:
  /// **'撤回白板互动失败'**
  String get participantUndoWhiteBoardInteractFail;

  /// No description provided for @participantUserHasBeenAssignCoHostRole.
  ///
  /// In zh, this message translates to:
  /// **'已被设为联席主持人'**
  String get participantUserHasBeenAssignCoHostRole;

  /// No description provided for @participantUserHasBeenRevokeCoHostRole.
  ///
  /// In zh, this message translates to:
  /// **'已被取消联席主持人'**
  String get participantUserHasBeenRevokeCoHostRole;

  /// No description provided for @participantInMeeting.
  ///
  /// In zh, this message translates to:
  /// **'会议中'**
  String get participantInMeeting;

  /// No description provided for @participantNotJoined.
  ///
  /// In zh, this message translates to:
  /// **'未入会'**
  String get participantNotJoined;

  /// No description provided for @participantAttendees.
  ///
  /// In zh, this message translates to:
  /// **'成员管理'**
  String get participantAttendees;

  /// No description provided for @participantAdmit.
  ///
  /// In zh, this message translates to:
  /// **'准入'**
  String get participantAdmit;

  /// No description provided for @participantWaitingTimePrefix.
  ///
  /// In zh, this message translates to:
  /// **'已等待'**
  String get participantWaitingTimePrefix;

  /// No description provided for @participantPutInWaitingRoom.
  ///
  /// In zh, this message translates to:
  /// **'移至等候室'**
  String get participantPutInWaitingRoom;

  /// No description provided for @participantExpelWaitingMemberDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'移除等候成员'**
  String get participantExpelWaitingMemberDialogTitle;

  /// No description provided for @participantDisallowMemberRejoinMeeting.
  ///
  /// In zh, this message translates to:
  /// **'不允许用户再次加入该会议'**
  String get participantDisallowMemberRejoinMeeting;

  /// No description provided for @cloudRecordingEnabledTitle.
  ///
  /// In zh, this message translates to:
  /// **'是否开启云录制'**
  String get cloudRecordingEnabledTitle;

  /// No description provided for @cloudRecordingEnabledMessage.
  ///
  /// In zh, this message translates to:
  /// **'开启后，将录制会议过程中的音视频与共享屏幕内容到云端，同时告知所有参会成员'**
  String get cloudRecordingEnabledMessage;

  /// No description provided for @cloudRecordingEnabledMessageWithoutNotice.
  ///
  /// In zh, this message translates to:
  /// **'开启后，将录制会议过程中的音视频与共享屏幕内容到云端'**
  String get cloudRecordingEnabledMessageWithoutNotice;

  /// No description provided for @cloudRecordingTitle.
  ///
  /// In zh, this message translates to:
  /// **'该会议正在被录制中'**
  String get cloudRecordingTitle;

  /// No description provided for @cloudRecordingMessage.
  ///
  /// In zh, this message translates to:
  /// **'主持人开启了会议云录制，会议的创建者可以观看云录制文件，你可以在会议结束后联系创建者获取查看链接'**
  String get cloudRecordingMessage;

  /// No description provided for @cloudRecordingAgree.
  ///
  /// In zh, this message translates to:
  /// **'如果留在会议中，表示你同意录制'**
  String get cloudRecordingAgree;

  /// No description provided for @cloudRecordingWhetherEndedTitle.
  ///
  /// In zh, this message translates to:
  /// **'是否结束录制'**
  String get cloudRecordingWhetherEndedTitle;

  /// No description provided for @cloudRecordingEndedMessage.
  ///
  /// In zh, this message translates to:
  /// **'录制文件将会在会议结束后同步至“历史会议-会议详情”中'**
  String get cloudRecordingEndedMessage;

  /// No description provided for @cloudRecordingEndedTitle.
  ///
  /// In zh, this message translates to:
  /// **'云录制已结束'**
  String get cloudRecordingEndedTitle;

  /// No description provided for @cloudRecordingEndedAndGetUrl.
  ///
  /// In zh, this message translates to:
  /// **'你可以在会议结束后联系会议创建者获取查看链接'**
  String get cloudRecordingEndedAndGetUrl;

  /// No description provided for @cloudRecordingStart.
  ///
  /// In zh, this message translates to:
  /// **'云录制'**
  String get cloudRecordingStart;

  /// No description provided for @cloudRecordingStop.
  ///
  /// In zh, this message translates to:
  /// **'停止录制'**
  String get cloudRecordingStop;

  /// No description provided for @cloudRecording.
  ///
  /// In zh, this message translates to:
  /// **'录制中'**
  String get cloudRecording;

  /// No description provided for @cloudRecordingStartFail.
  ///
  /// In zh, this message translates to:
  /// **'开启录制失败'**
  String get cloudRecordingStartFail;

  /// No description provided for @cloudRecordingStopFail.
  ///
  /// In zh, this message translates to:
  /// **'停止录制失败'**
  String get cloudRecordingStopFail;

  /// No description provided for @cloudRecordingStarting.
  ///
  /// In zh, this message translates to:
  /// **'正在开启录制...'**
  String get cloudRecordingStarting;

  /// No description provided for @chat.
  ///
  /// In zh, this message translates to:
  /// **'聊天'**
  String get chat;

  /// No description provided for @chatInputMessageHint.
  ///
  /// In zh, this message translates to:
  /// **'输入消息...'**
  String get chatInputMessageHint;

  /// No description provided for @chatCannotSendBlankLetter.
  ///
  /// In zh, this message translates to:
  /// **'不支持发送空消息'**
  String get chatCannotSendBlankLetter;

  /// No description provided for @chatJoinFail.
  ///
  /// In zh, this message translates to:
  /// **'聊天室进入失败!'**
  String get chatJoinFail;

  /// No description provided for @chatNewMessage.
  ///
  /// In zh, this message translates to:
  /// **'新消息'**
  String get chatNewMessage;

  /// No description provided for @chatUnsupportedFileExtension.
  ///
  /// In zh, this message translates to:
  /// **'暂不支持发送此类文件'**
  String get chatUnsupportedFileExtension;

  /// No description provided for @chatFileSizeExceedTheLimit.
  ///
  /// In zh, this message translates to:
  /// **'文件大小不能超过200MB'**
  String get chatFileSizeExceedTheLimit;

  /// No description provided for @chatImageSizeExceedTheLimit.
  ///
  /// In zh, this message translates to:
  /// **'图片大小不能超过20MB'**
  String get chatImageSizeExceedTheLimit;

  /// No description provided for @chatImageMessageTip.
  ///
  /// In zh, this message translates to:
  /// **'[图片]'**
  String get chatImageMessageTip;

  /// No description provided for @chatFileMessageTip.
  ///
  /// In zh, this message translates to:
  /// **'[文件]'**
  String get chatFileMessageTip;

  /// No description provided for @chatSaveToGallerySuccess.
  ///
  /// In zh, this message translates to:
  /// **'已保存到系统相册'**
  String get chatSaveToGallerySuccess;

  /// No description provided for @chatOperationFailNoPermission.
  ///
  /// In zh, this message translates to:
  /// **'无操作权限'**
  String get chatOperationFailNoPermission;

  /// No description provided for @chatOpenFileFail.
  ///
  /// In zh, this message translates to:
  /// **'打开文件失败'**
  String get chatOpenFileFail;

  /// No description provided for @chatOpenFileFailNoPermission.
  ///
  /// In zh, this message translates to:
  /// **'打开文件失败：无权限'**
  String get chatOpenFileFailNoPermission;

  /// No description provided for @chatOpenFileFailFileNotFound.
  ///
  /// In zh, this message translates to:
  /// **'打开文件失败：文件不存在'**
  String get chatOpenFileFailFileNotFound;

  /// No description provided for @chatOpenFileFailAppNotFound.
  ///
  /// In zh, this message translates to:
  /// **'打开文件失败：无法找到打开此文件的应用'**
  String get chatOpenFileFailAppNotFound;

  /// No description provided for @chatRecall.
  ///
  /// In zh, this message translates to:
  /// **'撤回'**
  String get chatRecall;

  /// No description provided for @chatAboveIsHistoryMessage.
  ///
  /// In zh, this message translates to:
  /// **'以上为历史消息'**
  String get chatAboveIsHistoryMessage;

  /// No description provided for @chatYou.
  ///
  /// In zh, this message translates to:
  /// **'你'**
  String get chatYou;

  /// No description provided for @chatRecallAMessage.
  ///
  /// In zh, this message translates to:
  /// **'撤回一条消息'**
  String get chatRecallAMessage;

  /// No description provided for @chatMessageRecalled.
  ///
  /// In zh, this message translates to:
  /// **'消息已被撤回'**
  String get chatMessageRecalled;

  /// No description provided for @chatMessage.
  ///
  /// In zh, this message translates to:
  /// **'消息'**
  String get chatMessage;

  /// No description provided for @chatSendTo.
  ///
  /// In zh, this message translates to:
  /// **'发送至'**
  String get chatSendTo;

  /// No description provided for @chatAllMembersInMeeting.
  ///
  /// In zh, this message translates to:
  /// **'会议室所有人'**
  String get chatAllMembersInMeeting;

  /// No description provided for @chatAllMembersInWaitingRoom.
  ///
  /// In zh, this message translates to:
  /// **'等候室所有人'**
  String get chatAllMembersInWaitingRoom;

  /// No description provided for @chatHistory.
  ///
  /// In zh, this message translates to:
  /// **'聊天记录'**
  String get chatHistory;

  /// No description provided for @chatMessageSendToWaitingRoom.
  ///
  /// In zh, this message translates to:
  /// **'发给等候室的消息'**
  String get chatMessageSendToWaitingRoom;

  /// No description provided for @chatNoChatHistory.
  ///
  /// In zh, this message translates to:
  /// **'无聊天记录'**
  String get chatNoChatHistory;

  /// No description provided for @waitingRoomJoinMeeting.
  ///
  /// In zh, this message translates to:
  /// **'加入会议'**
  String get waitingRoomJoinMeeting;

  /// No description provided for @waitingRoom.
  ///
  /// In zh, this message translates to:
  /// **'等候室'**
  String get waitingRoom;

  /// No description provided for @waitingRoomJoinMeetingOption.
  ///
  /// In zh, this message translates to:
  /// **'入会选项'**
  String get waitingRoomJoinMeetingOption;

  /// No description provided for @waitingRoomWaitHostToInviteJoinMeeting.
  ///
  /// In zh, this message translates to:
  /// **'请等待，主持人即将拉您进入会议'**
  String get waitingRoomWaitHostToInviteJoinMeeting;

  /// No description provided for @waitingRoomWaitMeetingToStart.
  ///
  /// In zh, this message translates to:
  /// **'请等待，会议尚未开始'**
  String get waitingRoomWaitMeetingToStart;

  /// No description provided for @waitingRoomTurnOnMicrophone.
  ///
  /// In zh, this message translates to:
  /// **'开启麦克风'**
  String get waitingRoomTurnOnMicrophone;

  /// No description provided for @waitingRoomTurnOnVideo.
  ///
  /// In zh, this message translates to:
  /// **'开启摄像头'**
  String get waitingRoomTurnOnVideo;

  /// No description provided for @waitingRoomEnabledOnEntry.
  ///
  /// In zh, this message translates to:
  /// **'等候室已开启'**
  String get waitingRoomEnabledOnEntry;

  /// No description provided for @waitingRoomDisabledOnEntry.
  ///
  /// In zh, this message translates to:
  /// **'等候室已关闭'**
  String get waitingRoomDisabledOnEntry;

  /// No description provided for @waitingRoomDisableDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'关闭等候室'**
  String get waitingRoomDisableDialogTitle;

  /// No description provided for @waitingRoomDisableDialogMessage.
  ///
  /// In zh, this message translates to:
  /// **'等候室关闭后，新成员将直接进入会议室'**
  String get waitingRoomDisableDialogMessage;

  /// No description provided for @waitingRoomDisableDialogAdmitAll.
  ///
  /// In zh, this message translates to:
  /// **'允许现有等候室成员全部进入会议'**
  String get waitingRoomDisableDialogAdmitAll;

  /// No description provided for @waitingRoomCloseRightNow.
  ///
  /// In zh, this message translates to:
  /// **'立即关闭'**
  String get waitingRoomCloseRightNow;

  /// No description provided for @waitingRoomCount.
  ///
  /// In zh, this message translates to:
  /// **'当前等候室已有{count}人等候'**
  String waitingRoomCount(Object count);

  /// No description provided for @movedToWaitingRoom.
  ///
  /// In zh, this message translates to:
  /// **'主持人已将您移至等候室'**
  String get movedToWaitingRoom;

  /// No description provided for @deviceSpeaker.
  ///
  /// In zh, this message translates to:
  /// **'扬声器'**
  String get deviceSpeaker;

  /// No description provided for @deviceReceiver.
  ///
  /// In zh, this message translates to:
  /// **'手机听筒'**
  String get deviceReceiver;

  /// No description provided for @deviceBluetooth.
  ///
  /// In zh, this message translates to:
  /// **'蓝牙耳机'**
  String get deviceBluetooth;

  /// No description provided for @deviceHeadphones.
  ///
  /// In zh, this message translates to:
  /// **'有线耳机'**
  String get deviceHeadphones;

  /// No description provided for @deviceOutput.
  ///
  /// In zh, this message translates to:
  /// **'输出设备'**
  String get deviceOutput;

  /// No description provided for @deviceHeadsetState.
  ///
  /// In zh, this message translates to:
  /// **'您正在使用耳机'**
  String get deviceHeadsetState;

  /// No description provided for @networkConnectionGood.
  ///
  /// In zh, this message translates to:
  /// **'网络连接良好'**
  String get networkConnectionGood;

  /// No description provided for @networkConnectionGeneral.
  ///
  /// In zh, this message translates to:
  /// **'网络连接一般'**
  String get networkConnectionGeneral;

  /// No description provided for @networkConnectionPoor.
  ///
  /// In zh, this message translates to:
  /// **'网络连接较差'**
  String get networkConnectionPoor;

  /// No description provided for @nan.
  ///
  /// In zh, this message translates to:
  /// **'网络连接未知'**
  String get nan;

  /// No description provided for @networkLocalLatency.
  ///
  /// In zh, this message translates to:
  /// **'延迟：'**
  String get networkLocalLatency;

  /// No description provided for @networkPacketLossRate.
  ///
  /// In zh, this message translates to:
  /// **'丢包率：'**
  String get networkPacketLossRate;

  /// No description provided for @networkReconnectionSuccessful.
  ///
  /// In zh, this message translates to:
  /// **'网络重连成功'**
  String get networkReconnectionSuccessful;

  /// No description provided for @networkAbnormalityPleaseCheckYourNetwork.
  ///
  /// In zh, this message translates to:
  /// **'网络异常，请检查您的网络'**
  String get networkAbnormalityPleaseCheckYourNetwork;

  /// No description provided for @networkAbnormality.
  ///
  /// In zh, this message translates to:
  /// **'网络异常'**
  String get networkAbnormality;

  /// No description provided for @networkDisconnectedPleaseCheckYourNetworkStatusOrTryToRejoin.
  ///
  /// In zh, this message translates to:
  /// **'网络已断开，请检查您的网络情况，或尝试重新入会'**
  String get networkDisconnectedPleaseCheckYourNetworkStatusOrTryToRejoin;

  /// No description provided for @networkNotStable.
  ///
  /// In zh, this message translates to:
  /// **'当前网络状况不佳'**
  String get networkNotStable;

  /// No description provided for @networkUnavailableCloseFail.
  ///
  /// In zh, this message translates to:
  /// **'网络异常，结束会议失败'**
  String get networkUnavailableCloseFail;

  /// No description provided for @networkDisconnectedTryingToReconnect.
  ///
  /// In zh, this message translates to:
  /// **'网络已断开，正在尝试重新连接…'**
  String get networkDisconnectedTryingToReconnect;
}

class _NEMeetingUIKitLocalizationsDelegate
    extends LocalizationsDelegate<NEMeetingUIKitLocalizations> {
  const _NEMeetingUIKitLocalizationsDelegate();

  @override
  Future<NEMeetingUIKitLocalizations> load(Locale locale) {
    return SynchronousFuture<NEMeetingUIKitLocalizations>(
        lookupNEMeetingUIKitLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_NEMeetingUIKitLocalizationsDelegate old) => false;
}

NEMeetingUIKitLocalizations lookupNEMeetingUIKitLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return NEMeetingUIKitLocalizationsEn();
    case 'ja':
      return NEMeetingUIKitLocalizationsJa();
    case 'zh':
      return NEMeetingUIKitLocalizationsZh();
  }

  throw FlutterError(
      'NEMeetingUIKitLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
