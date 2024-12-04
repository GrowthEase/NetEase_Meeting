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

  /// No description provided for @globalOperationNotSupportedInMeeting.
  ///
  /// In zh, this message translates to:
  /// **'会议中暂不支持该操作'**
  String get globalOperationNotSupportedInMeeting;

  /// No description provided for @globalClear.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get globalClear;

  /// No description provided for @globalSearch.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get globalSearch;

  /// No description provided for @globalReject.
  ///
  /// In zh, this message translates to:
  /// **'拒绝'**
  String get globalReject;

  /// No description provided for @globalCancelled.
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get globalCancelled;

  /// No description provided for @globalClearAll.
  ///
  /// In zh, this message translates to:
  /// **'清空全部'**
  String get globalClearAll;

  /// No description provided for @globalStart.
  ///
  /// In zh, this message translates to:
  /// **'开启'**
  String get globalStart;

  /// No description provided for @globalTips.
  ///
  /// In zh, this message translates to:
  /// **'提示'**
  String get globalTips;

  /// No description provided for @globalNetworkUnavailableCheck.
  ///
  /// In zh, this message translates to:
  /// **'网络连接失败，请检查你的网络连接！'**
  String get globalNetworkUnavailableCheck;

  /// No description provided for @globalSubmit.
  ///
  /// In zh, this message translates to:
  /// **'提交'**
  String get globalSubmit;

  /// No description provided for @globalGotoSettings.
  ///
  /// In zh, this message translates to:
  /// **'前往设置'**
  String get globalGotoSettings;

  /// No description provided for @globalPhotosPermissionRationale.
  ///
  /// In zh, this message translates to:
  /// **'音视频会议需要申请相册权限，用于上传图片或修改头像'**
  String get globalPhotosPermissionRationale;

  /// No description provided for @globalPhotosPermission.
  ///
  /// In zh, this message translates to:
  /// **'无法使用相册'**
  String get globalPhotosPermission;

  /// No description provided for @globalSend.
  ///
  /// In zh, this message translates to:
  /// **'发送'**
  String get globalSend;

  /// No description provided for @globalPause.
  ///
  /// In zh, this message translates to:
  /// **'暂停'**
  String get globalPause;

  /// No description provided for @globalNoContent.
  ///
  /// In zh, this message translates to:
  /// **'暂无内容'**
  String get globalNoContent;

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

  /// No description provided for @meetingRaiseHand.
  ///
  /// In zh, this message translates to:
  /// **'举手'**
  String get meetingRaiseHand;

  /// No description provided for @meetingCancelHandsUp.
  ///
  /// In zh, this message translates to:
  /// **'取消举手'**
  String get meetingCancelHandsUp;

  /// No description provided for @meetingCancelHandsUpConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定将手放下吗？'**
  String get meetingCancelHandsUpConfirm;

  /// No description provided for @meetingHandsUpDown.
  ///
  /// In zh, this message translates to:
  /// **'手放下'**
  String get meetingHandsUpDown;

  /// No description provided for @meetingHandsUpDownAll.
  ///
  /// In zh, this message translates to:
  /// **'全部手放下'**
  String get meetingHandsUpDownAll;

  /// No description provided for @meetingHandsUpDownAllSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已将全部手放下'**
  String get meetingHandsUpDownAllSuccess;

  /// No description provided for @meetingHandsUpDownAllFail.
  ///
  /// In zh, this message translates to:
  /// **'全部手放下失败'**
  String get meetingHandsUpDownAllFail;

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

  /// No description provided for @meetingHandsUpNumber.
  ///
  /// In zh, this message translates to:
  /// **'{num}人正在举手'**
  String meetingHandsUpNumber(Object num);

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
  /// **'添加参会者'**
  String get meetingInvitePageTitle;

  /// No description provided for @meetingSipNumber.
  ///
  /// In zh, this message translates to:
  /// **'内线话机/终端入会'**
  String get meetingSipNumber;

  /// No description provided for @meetingMobileDialInTitle.
  ///
  /// In zh, this message translates to:
  /// **'手机拨号入会'**
  String get meetingMobileDialInTitle;

  /// No description provided for @meetingMobileDialInMsg.
  ///
  /// In zh, this message translates to:
  /// **'拨打 {phoneNumber}'**
  String meetingMobileDialInMsg(Object phoneNumber);

  /// No description provided for @meetingInputSipNumber.
  ///
  /// In zh, this message translates to:
  /// **'输入 {sipNumber} 加入会议'**
  String meetingInputSipNumber(Object sipNumber);

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
  /// **'该设备不支持切换模式'**
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

  /// No description provided for @meetingAppointNewHost.
  ///
  /// In zh, this message translates to:
  /// **'指定一名新主持人'**
  String get meetingAppointNewHost;

  /// No description provided for @meetingAppointAndLeave.
  ///
  /// In zh, this message translates to:
  /// **'指定并离开'**
  String get meetingAppointAndLeave;

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

  /// No description provided for @meetingPinView.
  ///
  /// In zh, this message translates to:
  /// **'锁定视频'**
  String get meetingPinView;

  /// No description provided for @meetingPinViewTip.
  ///
  /// In zh, this message translates to:
  /// **'画面已锁定，点击{corner}取消锁定'**
  String meetingPinViewTip(Object corner);

  /// No description provided for @meetingTopLeftCorner.
  ///
  /// In zh, this message translates to:
  /// **'左上角'**
  String get meetingTopLeftCorner;

  /// No description provided for @meetingBottomRightCorner.
  ///
  /// In zh, this message translates to:
  /// **'右下角'**
  String get meetingBottomRightCorner;

  /// No description provided for @meetingUnpinView.
  ///
  /// In zh, this message translates to:
  /// **'取消锁定视频'**
  String get meetingUnpinView;

  /// No description provided for @meetingUnpinViewTip.
  ///
  /// In zh, this message translates to:
  /// **'画面已解锁'**
  String get meetingUnpinViewTip;

  /// No description provided for @meetingUnpin.
  ///
  /// In zh, this message translates to:
  /// **'取消锁定'**
  String get meetingUnpin;

  /// No description provided for @meetingPinFailedByFocus.
  ///
  /// In zh, this message translates to:
  /// **'主持人已设置焦点视频，不支持该操作'**
  String get meetingPinFailedByFocus;

  /// No description provided for @meetingBlacklist.
  ///
  /// In zh, this message translates to:
  /// **'会议黑名单'**
  String get meetingBlacklist;

  /// No description provided for @meetingBlacklistDetail.
  ///
  /// In zh, this message translates to:
  /// **'开启后，被标记“不允许再次加入”的用户将无法加入该会议'**
  String get meetingBlacklistDetail;

  /// No description provided for @unableMeetingBlacklistTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认关闭会议黑名单？'**
  String get unableMeetingBlacklistTitle;

  /// No description provided for @unableMeetingBlacklistTip.
  ///
  /// In zh, this message translates to:
  /// **'关闭后将清空黑名单，被标记“不允许再次加入”的用户可重新加入会议'**
  String get unableMeetingBlacklistTip;

  /// No description provided for @meetingNotAllowedToRejoin.
  ///
  /// In zh, this message translates to:
  /// **'不允许再次加入该会议'**
  String get meetingNotAllowedToRejoin;

  /// No description provided for @meetingAllowMembersTo.
  ///
  /// In zh, this message translates to:
  /// **'允许参会人员'**
  String get meetingAllowMembersTo;

  /// No description provided for @meetingEmojiResponse.
  ///
  /// In zh, this message translates to:
  /// **'回应'**
  String get meetingEmojiResponse;

  /// No description provided for @meetingAllowEmojiResponse.
  ///
  /// In zh, this message translates to:
  /// **'允许成员表情回应'**
  String get meetingAllowEmojiResponse;

  /// No description provided for @meetingRejectEmojiResponse.
  ///
  /// In zh, this message translates to:
  /// **'禁止成员表情回应'**
  String get meetingRejectEmojiResponse;

  /// No description provided for @meetingChat.
  ///
  /// In zh, this message translates to:
  /// **'会中聊天'**
  String get meetingChat;

  /// No description provided for @meetingChatEnabled.
  ///
  /// In zh, this message translates to:
  /// **'会中聊天已开启'**
  String get meetingChatEnabled;

  /// No description provided for @meetingChatDisabled.
  ///
  /// In zh, this message translates to:
  /// **'会中聊天已关闭'**
  String get meetingChatDisabled;

  /// No description provided for @meetingReclaimHost.
  ///
  /// In zh, this message translates to:
  /// **'收回主持人'**
  String get meetingReclaimHost;

  /// No description provided for @meetingReclaimHostCancel.
  ///
  /// In zh, this message translates to:
  /// **'暂不收回'**
  String get meetingReclaimHostCancel;

  /// No description provided for @meetingReclaimHostTip.
  ///
  /// In zh, this message translates to:
  /// **'{user}目前是主持人，收回主持人权限可能会中断屏幕共享等'**
  String meetingReclaimHostTip(Object user);

  /// No description provided for @meetingUserIsNowTheHost.
  ///
  /// In zh, this message translates to:
  /// **'{user}已经成为主持人'**
  String meetingUserIsNowTheHost(Object user);

  /// No description provided for @meetingGuestJoin.
  ///
  /// In zh, this message translates to:
  /// **'访客入会'**
  String get meetingGuestJoin;

  /// No description provided for @meetingGuestJoinSecurityNotice.
  ///
  /// In zh, this message translates to:
  /// **'已开启访客入会，请注意会议信息安全'**
  String get meetingGuestJoinSecurityNotice;

  /// No description provided for @meetingGuestJoinEnableTip.
  ///
  /// In zh, this message translates to:
  /// **'开启后允许外部人员参会'**
  String get meetingGuestJoinEnableTip;

  /// No description provided for @meetingGuestJoinEnabled.
  ///
  /// In zh, this message translates to:
  /// **'访客入会已开启'**
  String get meetingGuestJoinEnabled;

  /// No description provided for @meetingGuestJoinDisabled.
  ///
  /// In zh, this message translates to:
  /// **'访客入会已关闭'**
  String get meetingGuestJoinDisabled;

  /// No description provided for @meetingGuestJoinConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确认开启访客入会？'**
  String get meetingGuestJoinConfirm;

  /// No description provided for @meetingGuestJoinConfirmTip.
  ///
  /// In zh, this message translates to:
  /// **'开启后允许外部人员参会'**
  String get meetingGuestJoinConfirmTip;

  /// No description provided for @meetingSearchNotFound.
  ///
  /// In zh, this message translates to:
  /// **'暂无搜索结果'**
  String get meetingSearchNotFound;

  /// No description provided for @meetingGuestJoinSupported.
  ///
  /// In zh, this message translates to:
  /// **'该会议支持外部访客入会'**
  String get meetingGuestJoinSupported;

  /// No description provided for @meetingGuest.
  ///
  /// In zh, this message translates to:
  /// **'外部访客'**
  String get meetingGuest;

  /// No description provided for @meetingGuestJoinNamePlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'请输入入会昵称'**
  String get meetingGuestJoinNamePlaceholder;

  /// No description provided for @meetingAppInvite.
  ///
  /// In zh, this message translates to:
  /// **'{userName} 邀请你加入'**
  String meetingAppInvite(Object userName);

  /// No description provided for @meetingAudioJoinAction.
  ///
  /// In zh, this message translates to:
  /// **'语音入会'**
  String get meetingAudioJoinAction;

  /// No description provided for @meetingVideoJoinAction.
  ///
  /// In zh, this message translates to:
  /// **'视频入会'**
  String get meetingVideoJoinAction;

  /// No description provided for @meetingMaxMembers.
  ///
  /// In zh, this message translates to:
  /// **'最多参会人数'**
  String get meetingMaxMembers;

  /// No description provided for @speakerVolumeMuteTips.
  ///
  /// In zh, this message translates to:
  /// **'当前选中的扬声器设备暂无声音效果，请检查系统扬声器是否已解除静音并调至合适音量。'**
  String get speakerVolumeMuteTips;

  /// No description provided for @meetingAnnotationPermissionEnabled.
  ///
  /// In zh, this message translates to:
  /// **'互动批注'**
  String get meetingAnnotationPermissionEnabled;

  /// No description provided for @meetingMemberMaxTip.
  ///
  /// In zh, this message translates to:
  /// **'会议人数达到上限'**
  String get meetingMemberMaxTip;

  /// No description provided for @meetingIsUnderGoing.
  ///
  /// In zh, this message translates to:
  /// **'当前会议还未结束，不能进行此类操作'**
  String get meetingIsUnderGoing;

  /// No description provided for @unauthorized.
  ///
  /// In zh, this message translates to:
  /// **'登录状态已过期，请重新登录'**
  String get unauthorized;

  /// No description provided for @meetingIdShouldNotBeEmpty.
  ///
  /// In zh, this message translates to:
  /// **'会议号不能为空'**
  String get meetingIdShouldNotBeEmpty;

  /// No description provided for @meetingPasswordNotValid.
  ///
  /// In zh, this message translates to:
  /// **'会议密码不合法'**
  String get meetingPasswordNotValid;

  /// No description provided for @displayNameShouldNotBeEmpty.
  ///
  /// In zh, this message translates to:
  /// **'昵称不能为空'**
  String get displayNameShouldNotBeEmpty;

  /// No description provided for @meetingLogPathParamsError.
  ///
  /// In zh, this message translates to:
  /// **'参数错误，日志路径不合法或无创建权限'**
  String get meetingLogPathParamsError;

  /// No description provided for @meetingLocked.
  ///
  /// In zh, this message translates to:
  /// **'会议已锁定'**
  String get meetingLocked;

  /// No description provided for @meetingLockedTip.
  ///
  /// In zh, this message translates to:
  /// **'很抱歉，您尝试加入的会议已锁定。如有需要，请联系会议组织者解锁会议。'**
  String get meetingLockedTip;

  /// No description provided for @meetingNotExist.
  ///
  /// In zh, this message translates to:
  /// **'会议不存在'**
  String get meetingNotExist;

  /// No description provided for @meetingSaySomeThing.
  ///
  /// In zh, this message translates to:
  /// **'说点什么…'**
  String get meetingSaySomeThing;

  /// No description provided for @meetingKeepSilence.
  ///
  /// In zh, this message translates to:
  /// **'当前禁言中'**
  String get meetingKeepSilence;

  /// No description provided for @reuseIMNotSupportAnonymousLogin.
  ///
  /// In zh, this message translates to:
  /// **'IM复用不支持匿名登录'**
  String get reuseIMNotSupportAnonymousLogin;

  /// No description provided for @unmuteAudioBySelf.
  ///
  /// In zh, this message translates to:
  /// **'自行解除静音'**
  String get unmuteAudioBySelf;

  /// No description provided for @updateNicknameBySelf.
  ///
  /// In zh, this message translates to:
  /// **'自己改名'**
  String get updateNicknameBySelf;

  /// No description provided for @updateNicknameNoPermission.
  ///
  /// In zh, this message translates to:
  /// **'主持人不允许成员改名'**
  String get updateNicknameNoPermission;

  /// No description provided for @shareNoPermission.
  ///
  /// In zh, this message translates to:
  /// **'共享失败，仅主持人可共享'**
  String get shareNoPermission;

  /// No description provided for @localRecordPermission.
  ///
  /// In zh, this message translates to:
  /// **'本地录制权限'**
  String get localRecordPermission;

  /// No description provided for @localRecordOnlyHost.
  ///
  /// In zh, this message translates to:
  /// **'仅主持人可录制'**
  String get localRecordOnlyHost;

  /// No description provided for @localRecordAll.
  ///
  /// In zh, this message translates to:
  /// **'所有人可录制'**
  String get localRecordAll;

  /// No description provided for @sharingStopByHost.
  ///
  /// In zh, this message translates to:
  /// **'主持人已终止了你的共享'**
  String get sharingStopByHost;

  /// No description provided for @suspendParticipantActivities.
  ///
  /// In zh, this message translates to:
  /// **'暂停参会者活动'**
  String get suspendParticipantActivities;

  /// No description provided for @suspendParticipantActivitiesTips.
  ///
  /// In zh, this message translates to:
  /// **'所有人都将被静音，视频、屏幕共享将停止，会议将被锁定。'**
  String get suspendParticipantActivitiesTips;

  /// No description provided for @alreadySuspendParticipantActivitiesByHost.
  ///
  /// In zh, this message translates to:
  /// **'主持人已暂停参会者活动'**
  String get alreadySuspendParticipantActivitiesByHost;

  /// No description provided for @alreadySuspendParticipantActivities.
  ///
  /// In zh, this message translates to:
  /// **'已暂停参会者活动'**
  String get alreadySuspendParticipantActivities;

  /// No description provided for @suspendAllParticipantActivities.
  ///
  /// In zh, this message translates to:
  /// **'暂停所有参会者活动?'**
  String get suspendAllParticipantActivities;

  /// No description provided for @hideAvatarByHost.
  ///
  /// In zh, this message translates to:
  /// **'主持人已隐藏所有头像'**
  String get hideAvatarByHost;

  /// No description provided for @hideAvatar.
  ///
  /// In zh, this message translates to:
  /// **'隐藏头像'**
  String get hideAvatar;

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

  /// No description provided for @screenShareMyself.
  ///
  /// In zh, this message translates to:
  /// **'你正在共享屏幕'**
  String get screenShareMyself;

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
  /// **'屏幕或电脑音频共享时暂不支持白板共享'**
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

  /// No description provided for @screenShareWarning.
  ///
  /// In zh, this message translates to:
  /// **'近期有不法分子冒充客服、校园贷和公检法诈骗，请您提高警惕。检测到您的会议有安全风险，已禁用了共享功能。'**
  String get screenShareWarning;

  /// No description provided for @backSharingView.
  ///
  /// In zh, this message translates to:
  /// **'返回共享内容'**
  String get backSharingView;

  /// No description provided for @screenSharingViewUserLabel.
  ///
  /// In zh, this message translates to:
  /// **'{userName}的屏幕共享'**
  String screenSharingViewUserLabel(Object userName);

  /// No description provided for @whiteBoardSharingViewUserLabel.
  ///
  /// In zh, this message translates to:
  /// **'{userName}的白板共享'**
  String whiteBoardSharingViewUserLabel(Object userName);

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

  /// No description provided for @virtualDefaultBackground.
  ///
  /// In zh, this message translates to:
  /// **'默认背景'**
  String get virtualDefaultBackground;

  /// No description provided for @virtualCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get virtualCustom;

  /// No description provided for @virtualBackgroundPerfInadequate.
  ///
  /// In zh, this message translates to:
  /// **'设备性能不足'**
  String get virtualBackgroundPerfInadequate;

  /// No description provided for @virtualBackgroundPerfInadequateTip.
  ///
  /// In zh, this message translates to:
  /// **'您的设备性能不足，开启虚拟背景功能可能会导致视频质量下降或出现卡顿。您仍然希望尝试开启吗'**
  String get virtualBackgroundPerfInadequateTip;

  /// No description provided for @virtualBackgroundForce.
  ///
  /// In zh, this message translates to:
  /// **'强制开启'**
  String get virtualBackgroundForce;

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

  /// No description provided for @participantJoining.
  ///
  /// In zh, this message translates to:
  /// **'加入中...'**
  String get participantJoining;

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

  /// No description provided for @participantDisallowMemberRejoinMeeting.
  ///
  /// In zh, this message translates to:
  /// **'不允许用户再次加入该会议'**
  String get participantDisallowMemberRejoinMeeting;

  /// No description provided for @participantVideoIsPinned.
  ///
  /// In zh, this message translates to:
  /// **'画面已锁定，点击{corner}取消锁定'**
  String participantVideoIsPinned(Object corner);

  /// No description provided for @participantVideoIsUnpinned.
  ///
  /// In zh, this message translates to:
  /// **'画面已解锁'**
  String get participantVideoIsUnpinned;

  /// No description provided for @participantNotFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到相关成员'**
  String get participantNotFound;

  /// No description provided for @participantSetHost.
  ///
  /// In zh, this message translates to:
  /// **'设为主持人'**
  String get participantSetHost;

  /// No description provided for @participantSetCoHost.
  ///
  /// In zh, this message translates to:
  /// **'设为联席主持人'**
  String get participantSetCoHost;

  /// No description provided for @participantCancelCoHost.
  ///
  /// In zh, this message translates to:
  /// **'撤销联席主持人'**
  String get participantCancelCoHost;

  /// No description provided for @participantRemoveAttendee.
  ///
  /// In zh, this message translates to:
  /// **'删除参会者'**
  String get participantRemoveAttendee;

  /// No description provided for @participantUpperLimitWaitingRoomTip.
  ///
  /// In zh, this message translates to:
  /// **'当前会议已达人数上限，建议开启等候室。'**
  String get participantUpperLimitWaitingRoomTip;

  /// No description provided for @participantUpperLimitReleaseSeatsTip.
  ///
  /// In zh, this message translates to:
  /// **'当前会议已达到人数上限，新参会者将无法加入会议，您可以尝试移除未入会成员或释放会议中的一个席位。'**
  String get participantUpperLimitReleaseSeatsTip;

  /// No description provided for @participantUpperLimitTipAdmitOtherTip.
  ///
  /// In zh, this message translates to:
  /// **'当前会议已达到人数上限，请先移除未入会成员或释放会议中的一个席位，然后再准入等候室成员。'**
  String get participantUpperLimitTipAdmitOtherTip;

  /// No description provided for @cloudRecordingEnabledTitle.
  ///
  /// In zh, this message translates to:
  /// **'是否开启云录制'**
  String get cloudRecordingEnabledTitle;

  /// No description provided for @cloudRecordingEnabledMessage.
  ///
  /// In zh, this message translates to:
  /// **'开启后，会议过程中的音视频及共享屏幕内容将被录制到云端，同时告知所有参会成员'**
  String get cloudRecordingEnabledMessage;

  /// No description provided for @cloudRecordingEnabledMessageWithoutNotice.
  ///
  /// In zh, this message translates to:
  /// **'开启后，会议过程中的音视频及共享屏幕内容将被录制到云端'**
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

  /// No description provided for @cloudRecordingUnableToStart.
  ///
  /// In zh, this message translates to:
  /// **'无法启动云录制'**
  String get cloudRecordingUnableToStart;

  /// No description provided for @cloudRecordingUnableToStartTips.
  ///
  /// In zh, this message translates to:
  /// **'当前会议中无人开启麦克风或视频,为了启动录制,请解除静音'**
  String get cloudRecordingUnableToStartTips;

  /// No description provided for @cloudRecordingEnableAISummary.
  ///
  /// In zh, this message translates to:
  /// **'同时开启智能录制'**
  String get cloudRecordingEnableAISummary;

  /// No description provided for @cloudRecordingEnableAISummaryTip.
  ///
  /// In zh, this message translates to:
  /// **'开启后本场会议将生成智能AI纪要（含总结、待办）'**
  String get cloudRecordingEnableAISummaryTip;

  /// No description provided for @cloudRecordingAISummaryStarted.
  ///
  /// In zh, this message translates to:
  /// **'本场会议已开启智能录制，将生成智能AI纪要（含总结、待办）'**
  String get cloudRecordingAISummaryStarted;

  /// No description provided for @cloudRecordingEnableAISummaryFail.
  ///
  /// In zh, this message translates to:
  /// **'智能录制开启失败，请稍后关闭录制后重试'**
  String get cloudRecordingEnableAISummaryFail;

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
  /// **'会议中所有人'**
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

  /// No description provided for @chatAllMembers.
  ///
  /// In zh, this message translates to:
  /// **'所有人'**
  String get chatAllMembers;

  /// No description provided for @chatPrivate.
  ///
  /// In zh, this message translates to:
  /// **'私聊'**
  String get chatPrivate;

  /// No description provided for @chatPrivateInWaitingRoom.
  ///
  /// In zh, this message translates to:
  /// **'等候室-私聊'**
  String get chatPrivateInWaitingRoom;

  /// No description provided for @chatPermission.
  ///
  /// In zh, this message translates to:
  /// **'聊天权限'**
  String get chatPermission;

  /// No description provided for @chatFree.
  ///
  /// In zh, this message translates to:
  /// **'允许自由聊天'**
  String get chatFree;

  /// No description provided for @chatPublicOnly.
  ///
  /// In zh, this message translates to:
  /// **'仅允许公开聊天'**
  String get chatPublicOnly;

  /// No description provided for @chatPrivateHostOnly.
  ///
  /// In zh, this message translates to:
  /// **'仅允许私聊主持人'**
  String get chatPrivateHostOnly;

  /// No description provided for @chatMuted.
  ///
  /// In zh, this message translates to:
  /// **'全体成员禁言'**
  String get chatMuted;

  /// No description provided for @chatPermissionInMeeting.
  ///
  /// In zh, this message translates to:
  /// **'会议中聊天权限'**
  String get chatPermissionInMeeting;

  /// No description provided for @chatPermissionInWaitingRoom.
  ///
  /// In zh, this message translates to:
  /// **'等候室聊天权限'**
  String get chatPermissionInWaitingRoom;

  /// No description provided for @chatWaitingRoomPrivateHostOnly.
  ///
  /// In zh, this message translates to:
  /// **'允许等候室成员私聊主持人'**
  String get chatWaitingRoomPrivateHostOnly;

  /// No description provided for @chatHostMutedEveryone.
  ///
  /// In zh, this message translates to:
  /// **'主持人已设置为全员禁言'**
  String get chatHostMutedEveryone;

  /// No description provided for @chatHostLeft.
  ///
  /// In zh, this message translates to:
  /// **'主持人已离会，无法发送私聊消息'**
  String get chatHostLeft;

  /// No description provided for @chatSaidToMe.
  ///
  /// In zh, this message translates to:
  /// **'{userName} 对我说'**
  String chatSaidToMe(Object userName);

  /// No description provided for @chatISaidTo.
  ///
  /// In zh, this message translates to:
  /// **'我对{userName}说'**
  String chatISaidTo(Object userName);

  /// No description provided for @chatSaidToWaitingRoom.
  ///
  /// In zh, this message translates to:
  /// **'{userName} 对等候室所有人说'**
  String chatSaidToWaitingRoom(Object userName);

  /// No description provided for @chatISaidToWaitingRoom.
  ///
  /// In zh, this message translates to:
  /// **'我对等候室所有人说'**
  String get chatISaidToWaitingRoom;

  /// No description provided for @chatSendFailed.
  ///
  /// In zh, this message translates to:
  /// **'发送失败'**
  String get chatSendFailed;

  /// No description provided for @chatMemberLeft.
  ///
  /// In zh, this message translates to:
  /// **'参会者已离开会议'**
  String get chatMemberLeft;

  /// No description provided for @chatWaitingRoomMuted.
  ///
  /// In zh, this message translates to:
  /// **'主持人暂未开放等候室聊天'**
  String get chatWaitingRoomMuted;

  /// No description provided for @chatHistoryNotEnabled.
  ///
  /// In zh, this message translates to:
  /// **'聊天历史记录功能尚未开通，请联系管理员'**
  String get chatHistoryNotEnabled;

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

  /// No description provided for @waitingRoomAutoAdmit.
  ///
  /// In zh, this message translates to:
  /// **'本次会议自动准入'**
  String get waitingRoomAutoAdmit;

  /// No description provided for @movedToWaitingRoom.
  ///
  /// In zh, this message translates to:
  /// **'主持人已将您移至等候室'**
  String get movedToWaitingRoom;

  /// No description provided for @waitingRoomAdmitAll.
  ///
  /// In zh, this message translates to:
  /// **'全部准入'**
  String get waitingRoomAdmitAll;

  /// No description provided for @waitingRoomRemoveAll.
  ///
  /// In zh, this message translates to:
  /// **'全部移除'**
  String get waitingRoomRemoveAll;

  /// No description provided for @waitingRoomAdmitMember.
  ///
  /// In zh, this message translates to:
  /// **'准入等候成员'**
  String get waitingRoomAdmitMember;

  /// No description provided for @waitingRoomAdmitAllMembersTip.
  ///
  /// In zh, this message translates to:
  /// **'是否允许等候室所有成员加入会议?'**
  String get waitingRoomAdmitAllMembersTip;

  /// No description provided for @waitingRoomRemoveAllMemberTip.
  ///
  /// In zh, this message translates to:
  /// **'将等候室的所有成员都移除?'**
  String get waitingRoomRemoveAllMemberTip;

  /// No description provided for @waitingRoomExpelWaitingMember.
  ///
  /// In zh, this message translates to:
  /// **'移除等候成员'**
  String get waitingRoomExpelWaitingMember;

  /// No description provided for @waiting.
  ///
  /// In zh, this message translates to:
  /// **'等候中'**
  String get waiting;

  /// No description provided for @waitingRoomEnable.
  ///
  /// In zh, this message translates to:
  /// **'开启等候室'**
  String get waitingRoomEnable;

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

  /// No description provided for @networkConnectionUnknown.
  ///
  /// In zh, this message translates to:
  /// **'网络连接未知'**
  String get networkConnectionUnknown;

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
  /// **'当前网络状态不佳'**
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

  /// No description provided for @networkUnavailableCheck.
  ///
  /// In zh, this message translates to:
  /// **'网络连接失败，请检查你的网络连接！'**
  String get networkUnavailableCheck;

  /// No description provided for @networkUnstableTip.
  ///
  /// In zh, this message translates to:
  /// **'网络不稳定，正在连接...'**
  String get networkUnstableTip;

  /// No description provided for @notifyCenter.
  ///
  /// In zh, this message translates to:
  /// **'通知中心'**
  String get notifyCenter;

  /// No description provided for @notifyCenterAllClear.
  ///
  /// In zh, this message translates to:
  /// **'确认清空所有通知?'**
  String get notifyCenterAllClear;

  /// No description provided for @notifyCenterNoMessage.
  ///
  /// In zh, this message translates to:
  /// **'暂无消息'**
  String get notifyCenterNoMessage;

  /// No description provided for @notifyCenterViewDetailsUnsupported.
  ///
  /// In zh, this message translates to:
  /// **'该消息不支持查看详情'**
  String get notifyCenterViewDetailsUnsupported;

  /// No description provided for @notifyCenterViewingDetails.
  ///
  /// In zh, this message translates to:
  /// **'查看详情'**
  String get notifyCenterViewingDetails;

  /// No description provided for @sipCallByNumber.
  ///
  /// In zh, this message translates to:
  /// **'拨号入会'**
  String get sipCallByNumber;

  /// No description provided for @sipCall.
  ///
  /// In zh, this message translates to:
  /// **'呼叫'**
  String get sipCall;

  /// No description provided for @sipContacts.
  ///
  /// In zh, this message translates to:
  /// **'会议通讯录'**
  String get sipContacts;

  /// No description provided for @sipNumberPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'请输入手机号'**
  String get sipNumberPlaceholder;

  /// No description provided for @sipName.
  ///
  /// In zh, this message translates to:
  /// **'受邀者名称'**
  String get sipName;

  /// No description provided for @sipNamePlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'名字将会在会议中展示'**
  String get sipNamePlaceholder;

  /// No description provided for @sipCallNumber.
  ///
  /// In zh, this message translates to:
  /// **'拨出号码：'**
  String get sipCallNumber;

  /// No description provided for @sipNumberError.
  ///
  /// In zh, this message translates to:
  /// **'请输入正确的手机号'**
  String get sipNumberError;

  /// No description provided for @sipCallIsCalling.
  ///
  /// In zh, this message translates to:
  /// **'该号码已在呼叫中'**
  String get sipCallIsCalling;

  /// No description provided for @sipLocalContacts.
  ///
  /// In zh, this message translates to:
  /// **'本地通讯录'**
  String get sipLocalContacts;

  /// No description provided for @sipContactsClear.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get sipContactsClear;

  /// No description provided for @sipCalling.
  ///
  /// In zh, this message translates to:
  /// **'正在呼叫中...'**
  String get sipCalling;

  /// No description provided for @sipCallTerm.
  ///
  /// In zh, this message translates to:
  /// **'挂断'**
  String get sipCallTerm;

  /// No description provided for @sipCallOthers.
  ///
  /// In zh, this message translates to:
  /// **'呼叫其他成员'**
  String get sipCallOthers;

  /// No description provided for @sipCallFailed.
  ///
  /// In zh, this message translates to:
  /// **'呼叫失败'**
  String get sipCallFailed;

  /// No description provided for @sipCallBusy.
  ///
  /// In zh, this message translates to:
  /// **'对方忙'**
  String get sipCallBusy;

  /// No description provided for @sipCallAgain.
  ///
  /// In zh, this message translates to:
  /// **'重新拨打'**
  String get sipCallAgain;

  /// No description provided for @sipSearch.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get sipSearch;

  /// No description provided for @sipSearchContacts.
  ///
  /// In zh, this message translates to:
  /// **'搜索并添加参会人'**
  String get sipSearchContacts;

  /// No description provided for @sipCallPhone.
  ///
  /// In zh, this message translates to:
  /// **'电话呼叫'**
  String get sipCallPhone;

  /// No description provided for @sipCallingNumber.
  ///
  /// In zh, this message translates to:
  /// **'未入会'**
  String get sipCallingNumber;

  /// No description provided for @sipCallCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消呼叫'**
  String get sipCallCancel;

  /// No description provided for @sipCallAgainEx.
  ///
  /// In zh, this message translates to:
  /// **'再次呼叫'**
  String get sipCallAgainEx;

  /// No description provided for @sipCallStatusCalling.
  ///
  /// In zh, this message translates to:
  /// **'电话呼叫中'**
  String get sipCallStatusCalling;

  /// No description provided for @callStatusCalling.
  ///
  /// In zh, this message translates to:
  /// **'呼叫中…'**
  String get callStatusCalling;

  /// No description provided for @sipCallStatusWaiting.
  ///
  /// In zh, this message translates to:
  /// **'等待呼叫中'**
  String get sipCallStatusWaiting;

  /// No description provided for @callStatusWaitingJoin.
  ///
  /// In zh, this message translates to:
  /// **'待入会'**
  String get callStatusWaitingJoin;

  /// No description provided for @sipCallStatusTermed.
  ///
  /// In zh, this message translates to:
  /// **'已挂断'**
  String get sipCallStatusTermed;

  /// No description provided for @sipCallStatusUnaccepted.
  ///
  /// In zh, this message translates to:
  /// **'未接听'**
  String get sipCallStatusUnaccepted;

  /// No description provided for @sipCallStatusRejected.
  ///
  /// In zh, this message translates to:
  /// **'已拒接'**
  String get sipCallStatusRejected;

  /// No description provided for @sipCallStatusCanceled.
  ///
  /// In zh, this message translates to:
  /// **'呼叫已取消'**
  String get sipCallStatusCanceled;

  /// No description provided for @sipCallStatusError.
  ///
  /// In zh, this message translates to:
  /// **'呼叫异常'**
  String get sipCallStatusError;

  /// No description provided for @sipPhoneNumber.
  ///
  /// In zh, this message translates to:
  /// **'电话号码'**
  String get sipPhoneNumber;

  /// No description provided for @sipCallMemberSelected.
  ///
  /// In zh, this message translates to:
  /// **'已选：{count}'**
  String sipCallMemberSelected(Object count);

  /// No description provided for @sipContactsPrivacy.
  ///
  /// In zh, this message translates to:
  /// **'请授权访问您的通讯录，用于呼叫联系人以电话方式入会'**
  String get sipContactsPrivacy;

  /// No description provided for @memberCountOutOfRange.
  ///
  /// In zh, this message translates to:
  /// **'已达会议人数上限'**
  String get memberCountOutOfRange;

  /// No description provided for @sipContactNoNumber.
  ///
  /// In zh, this message translates to:
  /// **'该成员无电话信息，暂不支持选择'**
  String get sipContactNoNumber;

  /// No description provided for @sipCallIsInMeeting.
  ///
  /// In zh, this message translates to:
  /// **'该成员已在会议中'**
  String get sipCallIsInMeeting;

  /// No description provided for @callInWaitingMeeting.
  ///
  /// In zh, this message translates to:
  /// **'该成员已在等候室中'**
  String get callInWaitingMeeting;

  /// No description provided for @sipCallIsInInviting.
  ///
  /// In zh, this message translates to:
  /// **'该成员正在呼叫中'**
  String get sipCallIsInInviting;

  /// No description provided for @sipCallIsInBlacklist.
  ///
  /// In zh, this message translates to:
  /// **'该成员已被标记不允许再次加入，如需邀请，请关闭会议黑名单'**
  String get sipCallIsInBlacklist;

  /// No description provided for @sipCallDeviceIsInBlacklist.
  ///
  /// In zh, this message translates to:
  /// **'该设备已被标记不允许再次加入，如需邀请，请关闭会议黑名单'**
  String get sipCallDeviceIsInBlacklist;

  /// No description provided for @sipCallByPhone.
  ///
  /// In zh, this message translates to:
  /// **'电话呼叫'**
  String get sipCallByPhone;

  /// No description provided for @sipKeypad.
  ///
  /// In zh, this message translates to:
  /// **'拨号'**
  String get sipKeypad;

  /// No description provided for @sipBatchCall.
  ///
  /// In zh, this message translates to:
  /// **'批量呼叫'**
  String get sipBatchCall;

  /// No description provided for @sipLocalContactsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'本地通讯录为空'**
  String get sipLocalContactsEmpty;

  /// No description provided for @sipCallMaxCount.
  ///
  /// In zh, this message translates to:
  /// **'单次最多选择{count}人'**
  String sipCallMaxCount(Object count);

  /// No description provided for @sipInviteInfo.
  ///
  /// In zh, this message translates to:
  /// **'邀请信息'**
  String get sipInviteInfo;

  /// No description provided for @sipAddressInvite.
  ///
  /// In zh, this message translates to:
  /// **'通讯录邀请'**
  String get sipAddressInvite;

  /// No description provided for @sipJoinOtherMeetingTip.
  ///
  /// In zh, this message translates to:
  /// **'加入后将离开当前会议'**
  String get sipJoinOtherMeetingTip;

  /// No description provided for @sipRoom.
  ///
  /// In zh, this message translates to:
  /// **'会议室'**
  String get sipRoom;

  /// No description provided for @sipCallOutPhone.
  ///
  /// In zh, this message translates to:
  /// **'呼叫电话'**
  String get sipCallOutPhone;

  /// No description provided for @sipCallOutRoom.
  ///
  /// In zh, this message translates to:
  /// **'呼叫SIP/H.323会议室'**
  String get sipCallOutRoom;

  /// No description provided for @sipCallOutRoomInputTip.
  ///
  /// In zh, this message translates to:
  /// **'请输入IP地址 或 SIP URI 或 已注册设备号码'**
  String get sipCallOutRoomInputTip;

  /// No description provided for @sipCallOutRoomH323InputTip.
  ///
  /// In zh, this message translates to:
  /// **'请输入 IP 地址 或 E.164 号码'**
  String get sipCallOutRoomH323InputTip;

  /// No description provided for @sipDisplayName.
  ///
  /// In zh, this message translates to:
  /// **'入会名称'**
  String get sipDisplayName;

  /// No description provided for @sipDeviceIsInCalling.
  ///
  /// In zh, this message translates to:
  /// **'该设备已在呼叫中'**
  String get sipDeviceIsInCalling;

  /// No description provided for @sipDeviceIsInMeeting.
  ///
  /// In zh, this message translates to:
  /// **'该设备已在会议中'**
  String get sipDeviceIsInMeeting;

  /// No description provided for @sip.
  ///
  /// In zh, this message translates to:
  /// **'SIP'**
  String get sip;

  /// No description provided for @h323.
  ///
  /// In zh, this message translates to:
  /// **'H.323'**
  String get h323;

  /// No description provided for @sipProtocol.
  ///
  /// In zh, this message translates to:
  /// **'呼叫信令协议'**
  String get sipProtocol;

  /// No description provided for @roomSipCallIsInBlacklist.
  ///
  /// In zh, this message translates to:
  /// **'该设备已被标记不允许再次加入，如需邀请，请关闭会议黑名单'**
  String get roomSipCallIsInBlacklist;

  /// No description provided for @roomSipCallIsInMeeting.
  ///
  /// In zh, this message translates to:
  /// **'该设备已在会议中'**
  String get roomSipCallIsInMeeting;

  /// No description provided for @roomSipCallrNetworkError.
  ///
  /// In zh, this message translates to:
  /// **'网络异常无法呼叫，请检查网络'**
  String get roomSipCallrNetworkError;

  /// No description provided for @roomSipCallrNickNameLimit.
  ///
  /// In zh, this message translates to:
  /// **'入会名称太长，请重新设置'**
  String get roomSipCallrNickNameLimit;

  /// No description provided for @monitoring.
  ///
  /// In zh, this message translates to:
  /// **'质量监控'**
  String get monitoring;

  /// No description provided for @overall.
  ///
  /// In zh, this message translates to:
  /// **'总体'**
  String get overall;

  /// No description provided for @soundAndVideo.
  ///
  /// In zh, this message translates to:
  /// **'音视频'**
  String get soundAndVideo;

  /// No description provided for @cpu.
  ///
  /// In zh, this message translates to:
  /// **'CPU'**
  String get cpu;

  /// No description provided for @memory.
  ///
  /// In zh, this message translates to:
  /// **'内存'**
  String get memory;

  /// No description provided for @network.
  ///
  /// In zh, this message translates to:
  /// **'网络'**
  String get network;

  /// No description provided for @bandwidth.
  ///
  /// In zh, this message translates to:
  /// **'带宽'**
  String get bandwidth;

  /// No description provided for @networkType.
  ///
  /// In zh, this message translates to:
  /// **'网络类型'**
  String get networkType;

  /// No description provided for @networkState.
  ///
  /// In zh, this message translates to:
  /// **'网络状况'**
  String get networkState;

  /// No description provided for @delay.
  ///
  /// In zh, this message translates to:
  /// **'延迟'**
  String get delay;

  /// No description provided for @packageLossRate.
  ///
  /// In zh, this message translates to:
  /// **'丢包率'**
  String get packageLossRate;

  /// No description provided for @recently.
  ///
  /// In zh, this message translates to:
  /// **'近'**
  String get recently;

  /// No description provided for @audio.
  ///
  /// In zh, this message translates to:
  /// **'音频'**
  String get audio;

  /// No description provided for @microphone.
  ///
  /// In zh, this message translates to:
  /// **'麦克风'**
  String get microphone;

  /// No description provided for @speaker.
  ///
  /// In zh, this message translates to:
  /// **'扬声器'**
  String get speaker;

  /// No description provided for @bitrate.
  ///
  /// In zh, this message translates to:
  /// **'码率'**
  String get bitrate;

  /// No description provided for @speakerPlayback.
  ///
  /// In zh, this message translates to:
  /// **'扬声器播放'**
  String get speakerPlayback;

  /// No description provided for @microphoneAcquisition.
  ///
  /// In zh, this message translates to:
  /// **'麦克风采集'**
  String get microphoneAcquisition;

  /// No description provided for @resolution.
  ///
  /// In zh, this message translates to:
  /// **'分辨率'**
  String get resolution;

  /// No description provided for @frameRate.
  ///
  /// In zh, this message translates to:
  /// **'帧率'**
  String get frameRate;

  /// No description provided for @moreMonitoring.
  ///
  /// In zh, this message translates to:
  /// **'查看更多数据'**
  String get moreMonitoring;

  /// No description provided for @layoutSettings.
  ///
  /// In zh, this message translates to:
  /// **'布局设置'**
  String get layoutSettings;

  /// No description provided for @galleryModeMaxCount.
  ///
  /// In zh, this message translates to:
  /// **'画廊模式下单屏显示的最大画面数'**
  String get galleryModeMaxCount;

  /// No description provided for @galleryModeScreens.
  ///
  /// In zh, this message translates to:
  /// **'{count} 画面'**
  String galleryModeScreens(Object count);

  /// No description provided for @followGalleryLayout.
  ///
  /// In zh, this message translates to:
  /// **'跟随主持人视频顺序'**
  String get followGalleryLayout;

  /// No description provided for @resetGalleryLayout.
  ///
  /// In zh, this message translates to:
  /// **'重置视频顺序'**
  String get resetGalleryLayout;

  /// No description provided for @followGalleryLayoutTips.
  ///
  /// In zh, this message translates to:
  /// **'将主持人画廊模式前25个视频顺序同步给所有参会者，且不允许参会者自行改变。'**
  String get followGalleryLayoutTips;

  /// No description provided for @followGalleryLayoutConfirm.
  ///
  /// In zh, this message translates to:
  /// **'主持人已设置“跟随主持人视频顺序”，无法移动视频。'**
  String get followGalleryLayoutConfirm;

  /// No description provided for @followGalleryLayoutResetConfirm.
  ///
  /// In zh, this message translates to:
  /// **'主持人已设置“跟随主持人视频顺序”，无法重置视频顺序。'**
  String get followGalleryLayoutResetConfirm;

  /// No description provided for @saveGalleryLayoutTitle.
  ///
  /// In zh, this message translates to:
  /// **'保存视频顺序'**
  String get saveGalleryLayoutTitle;

  /// No description provided for @saveGalleryLayoutContent.
  ///
  /// In zh, this message translates to:
  /// **'将当前视频顺序保存到该预约会议，可供后续会议使用，确定保存？'**
  String get saveGalleryLayoutContent;

  /// No description provided for @replaceGalleryLayoutContent.
  ///
  /// In zh, this message translates to:
  /// **'该预约会议已有一份旧的视频顺序，是否替换并保存为新的视频顺序？'**
  String get replaceGalleryLayoutContent;

  /// No description provided for @loadGalleryLayoutTitle.
  ///
  /// In zh, this message translates to:
  /// **'加载视频顺序'**
  String get loadGalleryLayoutTitle;

  /// No description provided for @loadGalleryLayoutContent.
  ///
  /// In zh, this message translates to:
  /// **'该预约会议已有一份视频顺序，是否加载？'**
  String get loadGalleryLayoutContent;

  /// No description provided for @load.
  ///
  /// In zh, this message translates to:
  /// **'加载'**
  String get load;

  /// No description provided for @noLoadGalleryLayout.
  ///
  /// In zh, this message translates to:
  /// **'暂无可加载的视频顺序'**
  String get noLoadGalleryLayout;

  /// No description provided for @loadSuccess.
  ///
  /// In zh, this message translates to:
  /// **'加载成功'**
  String get loadSuccess;

  /// No description provided for @loadFail.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get loadFail;

  /// No description provided for @globalUpdate.
  ///
  /// In zh, this message translates to:
  /// **'更新'**
  String get globalUpdate;

  /// No description provided for @globalLang.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get globalLang;

  /// No description provided for @globalView.
  ///
  /// In zh, this message translates to:
  /// **'查看'**
  String get globalView;

  /// No description provided for @interpretation.
  ///
  /// In zh, this message translates to:
  /// **'同声传译'**
  String get interpretation;

  /// No description provided for @interpInterpreter.
  ///
  /// In zh, this message translates to:
  /// **'译员'**
  String get interpInterpreter;

  /// No description provided for @interpSelectInterpreter.
  ///
  /// In zh, this message translates to:
  /// **'选择译员'**
  String get interpSelectInterpreter;

  /// No description provided for @interpInterpreterAlreadyExists.
  ///
  /// In zh, this message translates to:
  /// **'用户已被选为译员，无法重复选择'**
  String get interpInterpreterAlreadyExists;

  /// No description provided for @interpInfoIncompleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'译员信息不完整'**
  String get interpInfoIncompleteTitle;

  /// No description provided for @interpInfoIncompleteMsg.
  ///
  /// In zh, this message translates to:
  /// **'退出将删除信息不完整的译员'**
  String get interpInfoIncompleteMsg;

  /// No description provided for @interpStart.
  ///
  /// In zh, this message translates to:
  /// **'开始同声传译'**
  String get interpStart;

  /// No description provided for @interpStartNotification.
  ///
  /// In zh, this message translates to:
  /// **'主持人已开启同声传译'**
  String get interpStartNotification;

  /// No description provided for @interpStop.
  ///
  /// In zh, this message translates to:
  /// **'关闭同声传译'**
  String get interpStop;

  /// No description provided for @interpStopNotification.
  ///
  /// In zh, this message translates to:
  /// **'主持人已关闭同声传译'**
  String get interpStopNotification;

  /// No description provided for @interpConfirmStopMsg.
  ///
  /// In zh, this message translates to:
  /// **'关闭同声传译将关闭所有收听的频道，是否关闭？'**
  String get interpConfirmStopMsg;

  /// No description provided for @interpConfirmUpdateMsg.
  ///
  /// In zh, this message translates to:
  /// **'是否更新？'**
  String get interpConfirmUpdateMsg;

  /// No description provided for @interpConfirmCancelEditMsg.
  ///
  /// In zh, this message translates to:
  /// **'确定取消同声传译设置吗？'**
  String get interpConfirmCancelEditMsg;

  /// No description provided for @interpSelectListenLanguage.
  ///
  /// In zh, this message translates to:
  /// **'请选择收听语言'**
  String get interpSelectListenLanguage;

  /// No description provided for @interpSelectLanguage.
  ///
  /// In zh, this message translates to:
  /// **'选择语言'**
  String get interpSelectLanguage;

  /// No description provided for @interpAddLanguage.
  ///
  /// In zh, this message translates to:
  /// **'添加语言'**
  String get interpAddLanguage;

  /// No description provided for @interpInputLanguage.
  ///
  /// In zh, this message translates to:
  /// **'输入语言'**
  String get interpInputLanguage;

  /// No description provided for @interpLanguageAlreadyExists.
  ///
  /// In zh, this message translates to:
  /// **'语言已存在'**
  String get interpLanguageAlreadyExists;

  /// No description provided for @interpListenMajorAudioMeanwhile.
  ///
  /// In zh, this message translates to:
  /// **'同时收听原声'**
  String get interpListenMajorAudioMeanwhile;

  /// No description provided for @interpManagement.
  ///
  /// In zh, this message translates to:
  /// **'管理同声传译'**
  String get interpManagement;

  /// No description provided for @interpSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置同声传译'**
  String get interpSettings;

  /// No description provided for @interpMajorAudio.
  ///
  /// In zh, this message translates to:
  /// **'原声'**
  String get interpMajorAudio;

  /// No description provided for @interpMajorChannel.
  ///
  /// In zh, this message translates to:
  /// **'主频道'**
  String get interpMajorChannel;

  /// No description provided for @interpMajorAudioVolume.
  ///
  /// In zh, this message translates to:
  /// **'原声音量'**
  String get interpMajorAudioVolume;

  /// No description provided for @interpAddInterpreter.
  ///
  /// In zh, this message translates to:
  /// **'添加译员'**
  String get interpAddInterpreter;

  /// No description provided for @interpJoinChannelErrorMsg.
  ///
  /// In zh, this message translates to:
  /// **'加入传译频道失败，是否重新加入？'**
  String get interpJoinChannelErrorMsg;

  /// No description provided for @interpReJoinChannel.
  ///
  /// In zh, this message translates to:
  /// **'重新加入'**
  String get interpReJoinChannel;

  /// No description provided for @interpAssignInterpreter.
  ///
  /// In zh, this message translates to:
  /// **'您已成为本场会议的同传译员'**
  String get interpAssignInterpreter;

  /// No description provided for @interpAssignLanguage.
  ///
  /// In zh, this message translates to:
  /// **'当前语言'**
  String get interpAssignLanguage;

  /// No description provided for @interpAssignInterpreterTip.
  ///
  /// In zh, this message translates to:
  /// **'您可以在“同声传译”中设置收听语言与传译语言'**
  String get interpAssignInterpreterTip;

  /// No description provided for @interpUnassignInterpreter.
  ///
  /// In zh, this message translates to:
  /// **'您已被主持人从同传译员中移除'**
  String get interpUnassignInterpreter;

  /// No description provided for @interpLanguageRemoved.
  ///
  /// In zh, this message translates to:
  /// **'主持人已删除收听语言“{language}”'**
  String interpLanguageRemoved(Object language);

  /// No description provided for @interpInterpreterOffline.
  ///
  /// In zh, this message translates to:
  /// **'当前收听的频道中，译员已全部离开，是否为您切换回原声？'**
  String get interpInterpreterOffline;

  /// No description provided for @interpDontSwitch.
  ///
  /// In zh, this message translates to:
  /// **'暂不切换'**
  String get interpDontSwitch;

  /// No description provided for @interpSwitchToMajorAudio.
  ///
  /// In zh, this message translates to:
  /// **'切回原声'**
  String get interpSwitchToMajorAudio;

  /// No description provided for @interpAudioShareIsForbiddenDesktop.
  ///
  /// In zh, this message translates to:
  /// **'作为译员，您共享屏幕时将无法同时共享电脑声音'**
  String get interpAudioShareIsForbiddenDesktop;

  /// No description provided for @interpAudioShareIsForbiddenMobile.
  ///
  /// In zh, this message translates to:
  /// **'作为译员，您共享屏幕时将无法同时共享设备音频'**
  String get interpAudioShareIsForbiddenMobile;

  /// No description provided for @interpInterpreterInMeetingStatusChanged.
  ///
  /// In zh, this message translates to:
  /// **'译员参会状态已变更'**
  String get interpInterpreterInMeetingStatusChanged;

  /// No description provided for @interpSpeakerTip.
  ///
  /// In zh, this message translates to:
  /// **'您正在收听{language1}，说{language2}'**
  String interpSpeakerTip(Object language1, Object language2);

  /// No description provided for @interpOutputLanguage.
  ///
  /// In zh, this message translates to:
  /// **'传译语言'**
  String get interpOutputLanguage;

  /// No description provided for @interpRemoveInterpreterOnly.
  ///
  /// In zh, this message translates to:
  /// **'仅删除译员'**
  String get interpRemoveInterpreterOnly;

  /// No description provided for @interpRemoveInterpreterInMembers.
  ///
  /// In zh, this message translates to:
  /// **'同时从参会人中删除'**
  String get interpRemoveInterpreterInMembers;

  /// No description provided for @interpRemoveMemberInInterpreters.
  ///
  /// In zh, this message translates to:
  /// **'该参会人同时被指派为译员，删除参会者将会同时取消译员指派'**
  String get interpRemoveMemberInInterpreters;

  /// No description provided for @interpListeningChannelDisconnect.
  ///
  /// In zh, this message translates to:
  /// **'收听语言频道已断开，正在尝试重连'**
  String get interpListeningChannelDisconnect;

  /// No description provided for @interpSpeakingChannelDisconnect.
  ///
  /// In zh, this message translates to:
  /// **'传译语言频道已断开，正在尝试重连'**
  String get interpSpeakingChannelDisconnect;

  /// No description provided for @langChinese.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get langChinese;

  /// No description provided for @langEnglish.
  ///
  /// In zh, this message translates to:
  /// **'英语'**
  String get langEnglish;

  /// No description provided for @langJapanese.
  ///
  /// In zh, this message translates to:
  /// **'日语'**
  String get langJapanese;

  /// No description provided for @langKorean.
  ///
  /// In zh, this message translates to:
  /// **'韩语'**
  String get langKorean;

  /// No description provided for @langFrench.
  ///
  /// In zh, this message translates to:
  /// **'法语'**
  String get langFrench;

  /// No description provided for @langGerman.
  ///
  /// In zh, this message translates to:
  /// **'德语'**
  String get langGerman;

  /// No description provided for @langSpanish.
  ///
  /// In zh, this message translates to:
  /// **'西班牙语'**
  String get langSpanish;

  /// No description provided for @langRussian.
  ///
  /// In zh, this message translates to:
  /// **'俄语'**
  String get langRussian;

  /// No description provided for @langPortuguese.
  ///
  /// In zh, this message translates to:
  /// **'葡萄牙语'**
  String get langPortuguese;

  /// No description provided for @langItalian.
  ///
  /// In zh, this message translates to:
  /// **'意大利语'**
  String get langItalian;

  /// No description provided for @langTurkish.
  ///
  /// In zh, this message translates to:
  /// **'土耳其语'**
  String get langTurkish;

  /// No description provided for @langVietnamese.
  ///
  /// In zh, this message translates to:
  /// **'越南语'**
  String get langVietnamese;

  /// No description provided for @langThai.
  ///
  /// In zh, this message translates to:
  /// **'泰语'**
  String get langThai;

  /// No description provided for @langIndonesian.
  ///
  /// In zh, this message translates to:
  /// **'印尼语'**
  String get langIndonesian;

  /// No description provided for @langMalay.
  ///
  /// In zh, this message translates to:
  /// **'马来语'**
  String get langMalay;

  /// No description provided for @langArabic.
  ///
  /// In zh, this message translates to:
  /// **'阿拉伯语'**
  String get langArabic;

  /// No description provided for @langHindi.
  ///
  /// In zh, this message translates to:
  /// **'印地语'**
  String get langHindi;

  /// No description provided for @annotation.
  ///
  /// In zh, this message translates to:
  /// **'互动批注'**
  String get annotation;

  /// No description provided for @annotationEnabled.
  ///
  /// In zh, this message translates to:
  /// **'互动批注已开启'**
  String get annotationEnabled;

  /// No description provided for @annotationDisabled.
  ///
  /// In zh, this message translates to:
  /// **'互动批注已关闭'**
  String get annotationDisabled;

  /// No description provided for @startAnnotation.
  ///
  /// In zh, this message translates to:
  /// **'批注'**
  String get startAnnotation;

  /// No description provided for @stopAnnotation.
  ///
  /// In zh, this message translates to:
  /// **'退出批注'**
  String get stopAnnotation;

  /// No description provided for @inAnnotation.
  ///
  /// In zh, this message translates to:
  /// **'正在批注中'**
  String get inAnnotation;

  /// No description provided for @saveAnnotation.
  ///
  /// In zh, this message translates to:
  /// **'保存当前批注'**
  String get saveAnnotation;

  /// No description provided for @cancelAnnotation.
  ///
  /// In zh, this message translates to:
  /// **'取消批注'**
  String get cancelAnnotation;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @settingAudio.
  ///
  /// In zh, this message translates to:
  /// **'音频'**
  String get settingAudio;

  /// No description provided for @settingVideo.
  ///
  /// In zh, this message translates to:
  /// **'视频'**
  String get settingVideo;

  /// No description provided for @settingCommon.
  ///
  /// In zh, this message translates to:
  /// **'通用'**
  String get settingCommon;

  /// No description provided for @settingAudioAINS.
  ///
  /// In zh, this message translates to:
  /// **'智能降噪'**
  String get settingAudioAINS;

  /// No description provided for @settingEnableTransparentWhiteboard.
  ///
  /// In zh, this message translates to:
  /// **'设置白板透明'**
  String get settingEnableTransparentWhiteboard;

  /// No description provided for @settingEnableFrontCameraMirror.
  ///
  /// In zh, this message translates to:
  /// **'前置摄像头镜像'**
  String get settingEnableFrontCameraMirror;

  /// No description provided for @settingShowMeetDuration.
  ///
  /// In zh, this message translates to:
  /// **'显示会议持续时间'**
  String get settingShowMeetDuration;

  /// No description provided for @settingShowParticipationTime.
  ///
  /// In zh, this message translates to:
  /// **'显示参会时长'**
  String get settingShowParticipationTime;

  /// No description provided for @settingShowElapsedTime.
  ///
  /// In zh, this message translates to:
  /// **'显示时间'**
  String get settingShowElapsedTime;

  /// No description provided for @settingShowNone.
  ///
  /// In zh, this message translates to:
  /// **'不显示'**
  String get settingShowNone;

  /// No description provided for @settingShowMeetingElapsedTime.
  ///
  /// In zh, this message translates to:
  /// **'会议持续时间'**
  String get settingShowMeetingElapsedTime;

  /// No description provided for @settingShowParticipationElapsedTime.
  ///
  /// In zh, this message translates to:
  /// **'参会时长'**
  String get settingShowParticipationElapsedTime;

  /// No description provided for @settingSpeakerSpotlight.
  ///
  /// In zh, this message translates to:
  /// **'语音激励'**
  String get settingSpeakerSpotlight;

  /// No description provided for @settingSpeakerSpotlightTip.
  ///
  /// In zh, this message translates to:
  /// **'开启后，将优先显示正在说话的参会成员'**
  String get settingSpeakerSpotlightTip;

  /// No description provided for @settingShowName.
  ///
  /// In zh, this message translates to:
  /// **'始终在视频中显示参会者名字'**
  String get settingShowName;

  /// No description provided for @settingHideNotYetJoinedMembers.
  ///
  /// In zh, this message translates to:
  /// **'隐藏未入会成员'**
  String get settingHideNotYetJoinedMembers;

  /// No description provided for @settingChatMessageNotification.
  ///
  /// In zh, this message translates to:
  /// **'新聊天消息提醒'**
  String get settingChatMessageNotification;

  /// No description provided for @settingChatMessageNotificationBarrage.
  ///
  /// In zh, this message translates to:
  /// **'弹幕'**
  String get settingChatMessageNotificationBarrage;

  /// No description provided for @settingChatMessageNotificationBubble.
  ///
  /// In zh, this message translates to:
  /// **'气泡'**
  String get settingChatMessageNotificationBubble;

  /// No description provided for @settingChatMessageNotificationNoReminder.
  ///
  /// In zh, this message translates to:
  /// **'不提醒'**
  String get settingChatMessageNotificationNoReminder;

  /// No description provided for @settingHideVideoOffAttendees.
  ///
  /// In zh, this message translates to:
  /// **'隐藏非视频参会者'**
  String get settingHideVideoOffAttendees;

  /// No description provided for @settingHideMyVideo.
  ///
  /// In zh, this message translates to:
  /// **'隐藏本人视图'**
  String get settingHideMyVideo;

  /// No description provided for @settingLeaveTheMeetingRequiresConfirmation.
  ///
  /// In zh, this message translates to:
  /// **'离开会议需要弹窗确认'**
  String get settingLeaveTheMeetingRequiresConfirmation;

  /// No description provided for @usingComputerAudioInMeeting.
  ///
  /// In zh, this message translates to:
  /// **'入会时使用电脑麦克风'**
  String get usingComputerAudioInMeeting;

  /// No description provided for @settingEnterFullscreen.
  ///
  /// In zh, this message translates to:
  /// **'开始或加入会议时自动进入全屏模式'**
  String get settingEnterFullscreen;

  /// No description provided for @enterFullscreenTips.
  ///
  /// In zh, this message translates to:
  /// **'按ESC或点击右上角按钮退出全屏模式'**
  String get enterFullscreenTips;

  /// No description provided for @joinMeetingSettings.
  ///
  /// In zh, this message translates to:
  /// **'入会设置'**
  String get joinMeetingSettings;

  /// No description provided for @memberJoinWithMute.
  ///
  /// In zh, this message translates to:
  /// **'成员入会时自动静音'**
  String get memberJoinWithMute;

  /// No description provided for @ringWhenMemberJoinOrLeave.
  ///
  /// In zh, this message translates to:
  /// **'成员入会或离开时播放提示音'**
  String get ringWhenMemberJoinOrLeave;

  /// No description provided for @windowSizeWhenSharingTheScreen.
  ///
  /// In zh, this message translates to:
  /// **'共享屏幕时的窗口大小'**
  String get windowSizeWhenSharingTheScreen;

  /// No description provided for @sideBySideMode.
  ///
  /// In zh, this message translates to:
  /// **'并排模式'**
  String get sideBySideMode;

  /// No description provided for @sideBySideModeTips.
  ///
  /// In zh, this message translates to:
  /// **'查看其他用户共享屏幕时自动将参会者视频放置在共享屏幕右侧'**
  String get sideBySideModeTips;

  /// No description provided for @whenIShareMyScreenInMeeting.
  ///
  /// In zh, this message translates to:
  /// **'当我在会议中共享屏幕时'**
  String get whenIShareMyScreenInMeeting;

  /// No description provided for @showAllSharingOptions.
  ///
  /// In zh, this message translates to:
  /// **'显示所有共享选项'**
  String get showAllSharingOptions;

  /// No description provided for @automaticDesktopSharing.
  ///
  /// In zh, this message translates to:
  /// **'自动桌面共享'**
  String get automaticDesktopSharing;

  /// No description provided for @automaticDesktopSharingTips.
  ///
  /// In zh, this message translates to:
  /// **'当你有多个显示器，系统将自动共享你的主桌面'**
  String get automaticDesktopSharingTips;

  /// No description provided for @onlyShowTheEntireScreen.
  ///
  /// In zh, this message translates to:
  /// **'仅显示整个屏幕'**
  String get onlyShowTheEntireScreen;

  /// No description provided for @sharedLimitFrameRate.
  ///
  /// In zh, this message translates to:
  /// **'将你的屏幕共享限制为'**
  String get sharedLimitFrameRate;

  /// No description provided for @sharedLimitFrameRateTips.
  ///
  /// In zh, this message translates to:
  /// **'开启后，屏幕共享帧率将不超过设置值。共享视频时推荐使用高帧率可提升观看视频流畅性，其他场景推荐使用低帧率降低CPU消耗'**
  String get sharedLimitFrameRateTips;

  /// No description provided for @sharedLimitFrameRateUnit.
  ///
  /// In zh, this message translates to:
  /// **'帧/秒'**
  String get sharedLimitFrameRateUnit;

  /// No description provided for @preferMotionModel.
  ///
  /// In zh, this message translates to:
  /// **'视频流畅度优先'**
  String get preferMotionModel;

  /// No description provided for @preferMotionModelTips.
  ///
  /// In zh, this message translates to:
  /// **'减少性能和带宽占用，优先保障共享流畅度'**
  String get preferMotionModelTips;

  /// No description provided for @transcriptionEnableCaption.
  ///
  /// In zh, this message translates to:
  /// **'开启字幕'**
  String get transcriptionEnableCaption;

  /// No description provided for @transcriptionEnableCaptionHint.
  ///
  /// In zh, this message translates to:
  /// **'当前字幕仅自己可见'**
  String get transcriptionEnableCaptionHint;

  /// No description provided for @transcriptionDisableCaption.
  ///
  /// In zh, this message translates to:
  /// **'关闭字幕'**
  String get transcriptionDisableCaption;

  /// No description provided for @transcriptionDisableCaptionHint.
  ///
  /// In zh, this message translates to:
  /// **'您已关闭字幕'**
  String get transcriptionDisableCaptionHint;

  /// No description provided for @transcriptionCaptionLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在开启字幕，机器识别仅供参考...'**
  String get transcriptionCaptionLoading;

  /// No description provided for @transcriptionDisclaimer.
  ///
  /// In zh, this message translates to:
  /// **'机器识别仅供参考'**
  String get transcriptionDisclaimer;

  /// No description provided for @transcriptionCaptionSettingsHint.
  ///
  /// In zh, this message translates to:
  /// **'点击进入字幕设置'**
  String get transcriptionCaptionSettingsHint;

  /// No description provided for @transcriptionCaptionSettings.
  ///
  /// In zh, this message translates to:
  /// **'字幕设置'**
  String get transcriptionCaptionSettings;

  /// No description provided for @transcriptionAllowEnableCaption.
  ///
  /// In zh, this message translates to:
  /// **'使用字幕功能'**
  String get transcriptionAllowEnableCaption;

  /// No description provided for @transcriptionCanNotEnableCaption.
  ///
  /// In zh, this message translates to:
  /// **'字幕暂不可用，请联系主持人或管理员'**
  String get transcriptionCanNotEnableCaption;

  /// No description provided for @transcriptionCaptionForbidden.
  ///
  /// In zh, this message translates to:
  /// **'主持人不允许成员使用字幕，已关闭字幕'**
  String get transcriptionCaptionForbidden;

  /// No description provided for @transcriptionCaptionNotAvailableInSubChannel.
  ///
  /// In zh, this message translates to:
  /// **'当前未收听原声，字幕暂不可用，如需使用请收听原声'**
  String get transcriptionCaptionNotAvailableInSubChannel;

  /// No description provided for @transcriptionCaptionFontSize.
  ///
  /// In zh, this message translates to:
  /// **'字号'**
  String get transcriptionCaptionFontSize;

  /// No description provided for @transcriptionCaptionSmall.
  ///
  /// In zh, this message translates to:
  /// **'小'**
  String get transcriptionCaptionSmall;

  /// No description provided for @transcriptionCaptionBig.
  ///
  /// In zh, this message translates to:
  /// **'大'**
  String get transcriptionCaptionBig;

  /// No description provided for @transcriptionCaptionEnableWhenJoin.
  ///
  /// In zh, this message translates to:
  /// **'加入会议时开启字幕'**
  String get transcriptionCaptionEnableWhenJoin;

  /// No description provided for @transcriptionCaptionExampleSize.
  ///
  /// In zh, this message translates to:
  /// **'字幕文字大小示例'**
  String get transcriptionCaptionExampleSize;

  /// No description provided for @transcriptionCaptionTypeSize.
  ///
  /// In zh, this message translates to:
  /// **'字号大小'**
  String get transcriptionCaptionTypeSize;

  /// No description provided for @transcription.
  ///
  /// In zh, this message translates to:
  /// **'实时转写'**
  String get transcription;

  /// No description provided for @transcriptionStart.
  ///
  /// In zh, this message translates to:
  /// **'开启转写'**
  String get transcriptionStart;

  /// No description provided for @transcriptionStop.
  ///
  /// In zh, this message translates to:
  /// **'停止转写'**
  String get transcriptionStop;

  /// No description provided for @transcriptionStartConfirmMsg.
  ///
  /// In zh, this message translates to:
  /// **'是否开启实时转写？'**
  String get transcriptionStartConfirmMsg;

  /// No description provided for @transcriptionStartedNotificationMsg.
  ///
  /// In zh, this message translates to:
  /// **'主持人已开启实时转写，所有成员可查看转写内容'**
  String get transcriptionStartedNotificationMsg;

  /// No description provided for @transcriptionRunning.
  ///
  /// In zh, this message translates to:
  /// **'转写中'**
  String get transcriptionRunning;

  /// No description provided for @transcriptionStartedTip.
  ///
  /// In zh, this message translates to:
  /// **'主持人已开启实时转写'**
  String get transcriptionStartedTip;

  /// No description provided for @transcriptionStoppedTip.
  ///
  /// In zh, this message translates to:
  /// **'主持人已关闭实时转写'**
  String get transcriptionStoppedTip;

  /// No description provided for @transcriptionNotStarted.
  ///
  /// In zh, this message translates to:
  /// **'暂未开启实时转写，请联系主持人开启转写'**
  String get transcriptionNotStarted;

  /// No description provided for @transcriptionStopFailed.
  ///
  /// In zh, this message translates to:
  /// **'关闭字幕失败'**
  String get transcriptionStopFailed;

  /// No description provided for @transcriptionStartFailed.
  ///
  /// In zh, this message translates to:
  /// **'开启字幕失败'**
  String get transcriptionStartFailed;

  /// No description provided for @transcriptionTranslationSettings.
  ///
  /// In zh, this message translates to:
  /// **'翻译设置'**
  String get transcriptionTranslationSettings;

  /// No description provided for @transcriptionSettings.
  ///
  /// In zh, this message translates to:
  /// **'转写设置'**
  String get transcriptionSettings;

  /// No description provided for @transcriptionTargetLang.
  ///
  /// In zh, this message translates to:
  /// **'目标翻译语言'**
  String get transcriptionTargetLang;

  /// No description provided for @transcriptionShowBilingual.
  ///
  /// In zh, this message translates to:
  /// **'同时显示双语'**
  String get transcriptionShowBilingual;

  /// No description provided for @transcriptionNotTranslated.
  ///
  /// In zh, this message translates to:
  /// **'不翻译'**
  String get transcriptionNotTranslated;

  /// No description provided for @transcriptionMemberPermission.
  ///
  /// In zh, this message translates to:
  /// **'查看成员权限'**
  String get transcriptionMemberPermission;

  /// No description provided for @transcriptionViewFullContent.
  ///
  /// In zh, this message translates to:
  /// **'查看完整内容'**
  String get transcriptionViewFullContent;

  /// No description provided for @transcriptionViewConferenceContent.
  ///
  /// In zh, this message translates to:
  /// **'查看参会期间内容'**
  String get transcriptionViewConferenceContent;

  /// No description provided for @feedbackInRoom.
  ///
  /// In zh, this message translates to:
  /// **'问题反馈'**
  String get feedbackInRoom;

  /// No description provided for @feedbackProblemType.
  ///
  /// In zh, this message translates to:
  /// **'问题类型'**
  String get feedbackProblemType;

  /// No description provided for @feedbackSuccess.
  ///
  /// In zh, this message translates to:
  /// **'反馈提交成功'**
  String get feedbackSuccess;

  /// No description provided for @feedbackFail.
  ///
  /// In zh, this message translates to:
  /// **'反馈提交失败'**
  String get feedbackFail;

  /// No description provided for @feedbackAudioLatency.
  ///
  /// In zh, this message translates to:
  /// **'对方说话声音延迟很大'**
  String get feedbackAudioLatency;

  /// No description provided for @feedbackAudioFreeze.
  ///
  /// In zh, this message translates to:
  /// **'对方说话声音很卡'**
  String get feedbackAudioFreeze;

  /// No description provided for @feedbackCannotHearOthers.
  ///
  /// In zh, this message translates to:
  /// **'听不到对方声音'**
  String get feedbackCannotHearOthers;

  /// No description provided for @feedbackCannotHearMe.
  ///
  /// In zh, this message translates to:
  /// **'对方听不到我的声音'**
  String get feedbackCannotHearMe;

  /// No description provided for @feedbackTitleExtras.
  ///
  /// In zh, this message translates to:
  /// **'补充信息'**
  String get feedbackTitleExtras;

  /// No description provided for @feedbackTitleDate.
  ///
  /// In zh, this message translates to:
  /// **'问题发生时间'**
  String get feedbackTitleDate;

  /// No description provided for @feedbackContentEmpty.
  ///
  /// In zh, this message translates to:
  /// **'无'**
  String get feedbackContentEmpty;

  /// No description provided for @feedbackTitleSelectPicture.
  ///
  /// In zh, this message translates to:
  /// **'本地图片'**
  String get feedbackTitleSelectPicture;

  /// No description provided for @feedbackAudioMechanicalNoise.
  ///
  /// In zh, this message translates to:
  /// **'播放机械音'**
  String get feedbackAudioMechanicalNoise;

  /// No description provided for @feedbackAudioNoise.
  ///
  /// In zh, this message translates to:
  /// **'杂音'**
  String get feedbackAudioNoise;

  /// No description provided for @feedbackAudioEcho.
  ///
  /// In zh, this message translates to:
  /// **'有回声'**
  String get feedbackAudioEcho;

  /// No description provided for @feedbackAudioVolumeSmall.
  ///
  /// In zh, this message translates to:
  /// **'音量小'**
  String get feedbackAudioVolumeSmall;

  /// No description provided for @feedbackVideoFreeze.
  ///
  /// In zh, this message translates to:
  /// **'视频长时间卡顿'**
  String get feedbackVideoFreeze;

  /// No description provided for @feedbackVideoIntermittent.
  ///
  /// In zh, this message translates to:
  /// **'视频断断续续'**
  String get feedbackVideoIntermittent;

  /// No description provided for @feedbackVideoTearing.
  ///
  /// In zh, this message translates to:
  /// **'画面撕裂'**
  String get feedbackVideoTearing;

  /// No description provided for @feedbackVideoTooBrightOrDark.
  ///
  /// In zh, this message translates to:
  /// **'画面过亮/过暗'**
  String get feedbackVideoTooBrightOrDark;

  /// No description provided for @feedbackVideoBlurry.
  ///
  /// In zh, this message translates to:
  /// **'画面模糊'**
  String get feedbackVideoBlurry;

  /// No description provided for @feedbackVideoNoise.
  ///
  /// In zh, this message translates to:
  /// **'画面明显噪点'**
  String get feedbackVideoNoise;

  /// No description provided for @feedbackAudioVideoNotSync.
  ///
  /// In zh, this message translates to:
  /// **'音画不同步'**
  String get feedbackAudioVideoNotSync;

  /// No description provided for @feedbackUnexpectedExit.
  ///
  /// In zh, this message translates to:
  /// **'意外退出'**
  String get feedbackUnexpectedExit;

  /// No description provided for @feedbackOthers.
  ///
  /// In zh, this message translates to:
  /// **'存在其他问题'**
  String get feedbackOthers;

  /// No description provided for @feedbackTitleAudio.
  ///
  /// In zh, this message translates to:
  /// **'音频问题'**
  String get feedbackTitleAudio;

  /// No description provided for @feedbackTitleVideo.
  ///
  /// In zh, this message translates to:
  /// **'视频问题'**
  String get feedbackTitleVideo;

  /// No description provided for @feedbackTitleOthers.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get feedbackTitleOthers;

  /// No description provided for @feedbackTitleDescription.
  ///
  /// In zh, this message translates to:
  /// **'问题描述'**
  String get feedbackTitleDescription;

  /// No description provided for @feedbackOtherTip.
  ///
  /// In zh, this message translates to:
  /// **'请描述您的问题，（当您选中\"存在其他问题\"时），需填写具体描述才可进行提交'**
  String get feedbackOtherTip;

  /// No description provided for @feedback.
  ///
  /// In zh, this message translates to:
  /// **'意见反馈'**
  String get feedback;
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
