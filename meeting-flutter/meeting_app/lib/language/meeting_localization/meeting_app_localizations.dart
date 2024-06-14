// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'meeting_app_localizations_en.dart';
import 'meeting_app_localizations_ja.dart';
import 'meeting_app_localizations_zh.dart';

/// Callers can lookup localized strings with an instance of MeetingAppLocalizations
/// returned by `MeetingAppLocalizations.of(context)`.
///
/// Applications need to include `MeetingAppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'meeting_localization/meeting_app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: MeetingAppLocalizations.localizationsDelegates,
///   supportedLocales: MeetingAppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the MeetingAppLocalizations.supportedLocales
/// property.
abstract class MeetingAppLocalizations {
  MeetingAppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static MeetingAppLocalizations? of(BuildContext context) {
    return Localizations.of<MeetingAppLocalizations>(
        context, MeetingAppLocalizations);
  }

  static const LocalizationsDelegate<MeetingAppLocalizations> delegate =
      _MeetingAppLocalizationsDelegate();

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

  /// No description provided for @globalSure.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get globalSure;

  /// No description provided for @globalOK.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get globalOK;

  /// No description provided for @globalQuit.
  ///
  /// In zh, this message translates to:
  /// **'退出'**
  String get globalQuit;

  /// No description provided for @globalAgree.
  ///
  /// In zh, this message translates to:
  /// **'同意'**
  String get globalAgree;

  /// No description provided for @globalDisagree.
  ///
  /// In zh, this message translates to:
  /// **'不同意'**
  String get globalDisagree;

  /// No description provided for @globalCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get globalCancel;

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

  /// No description provided for @globalApplication.
  ///
  /// In zh, this message translates to:
  /// **'应用'**
  String get globalApplication;

  /// No description provided for @globalNo.
  ///
  /// In zh, this message translates to:
  /// **'否'**
  String get globalNo;

  /// No description provided for @globalYes.
  ///
  /// In zh, this message translates to:
  /// **'是'**
  String get globalYes;

  /// No description provided for @globalComplete.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get globalComplete;

  /// No description provided for @globalResume.
  ///
  /// In zh, this message translates to:
  /// **'恢复'**
  String get globalResume;

  /// No description provided for @globalCopyright.
  ///
  /// In zh, this message translates to:
  /// **'网易公司版权所有©1997-2024'**
  String get globalCopyright;

  /// No description provided for @globalAppRegistryNO.
  ///
  /// In zh, this message translates to:
  /// **'浙ICP备17006647号-124A'**
  String get globalAppRegistryNO;

  /// No description provided for @globalNetworkUnavailableCheck.
  ///
  /// In zh, this message translates to:
  /// **'网络连接失败，请检查你的网络连接！'**
  String get globalNetworkUnavailableCheck;

  /// No description provided for @globalNetworkNotAvailable.
  ///
  /// In zh, this message translates to:
  /// **'当前网络不可用，请检查网络设置'**
  String get globalNetworkNotAvailable;

  /// No description provided for @globalNetworkNotAvailableTitle.
  ///
  /// In zh, this message translates to:
  /// **'网络连接不可用'**
  String get globalNetworkNotAvailableTitle;

  /// No description provided for @globalNetworkNotAvailablePart1.
  ///
  /// In zh, this message translates to:
  /// **'未能连接到互联网'**
  String get globalNetworkNotAvailablePart1;

  /// No description provided for @globalNetworkNotAvailablePart2.
  ///
  /// In zh, this message translates to:
  /// **'如需要连接到互联网，可以参照以下方法：'**
  String get globalNetworkNotAvailablePart2;

  /// No description provided for @globalNetworkNotAvailablePart3.
  ///
  /// In zh, this message translates to:
  /// **'如果您已接入Wi-Fi网络：'**
  String get globalNetworkNotAvailablePart3;

  /// No description provided for @globalNetworkNotAvailableTip1.
  ///
  /// In zh, this message translates to:
  /// **'您的设备未启用移动网络或Wi-Fi网络'**
  String get globalNetworkNotAvailableTip1;

  /// No description provided for @globalNetworkNotAvailableTip2.
  ///
  /// In zh, this message translates to:
  /// **'• 在设备的“设置”“Wi-F网络”设置面板中选择一个可用的Wi-Fi热点接入。'**
  String get globalNetworkNotAvailableTip2;

  /// No description provided for @globalNetworkNotAvailableTip3.
  ///
  /// In zh, this message translates to:
  /// **'• 在设备的“设置”“网络”设置面板中启用蜂窝数据（启用后运营商可能会收取数据通信费用）。'**
  String get globalNetworkNotAvailableTip3;

  /// No description provided for @globalNetworkNotAvailableTip4.
  ///
  /// In zh, this message translates to:
  /// **'请检查您所连接的Wi-Fi热点是否已接入互联网，或该热点是否已允许您的设备访问互联网。'**
  String get globalNetworkNotAvailableTip4;

  /// No description provided for @globalYear.
  ///
  /// In zh, this message translates to:
  /// **'年'**
  String get globalYear;

  /// No description provided for @globalMonth.
  ///
  /// In zh, this message translates to:
  /// **'月'**
  String get globalMonth;

  /// No description provided for @globalDay.
  ///
  /// In zh, this message translates to:
  /// **'日'**
  String get globalDay;

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

  /// No description provided for @globalSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get globalSave;

  /// No description provided for @globalSunday.
  ///
  /// In zh, this message translates to:
  /// **'周日'**
  String get globalSunday;

  /// No description provided for @globalMonday.
  ///
  /// In zh, this message translates to:
  /// **'周一'**
  String get globalMonday;

  /// No description provided for @globalTuesday.
  ///
  /// In zh, this message translates to:
  /// **'周二'**
  String get globalTuesday;

  /// No description provided for @globalWednesday.
  ///
  /// In zh, this message translates to:
  /// **'周三'**
  String get globalWednesday;

  /// No description provided for @globalThursday.
  ///
  /// In zh, this message translates to:
  /// **'周四'**
  String get globalThursday;

  /// No description provided for @globalFriday.
  ///
  /// In zh, this message translates to:
  /// **'周五'**
  String get globalFriday;

  /// No description provided for @globalSaturday.
  ///
  /// In zh, this message translates to:
  /// **'周六'**
  String get globalSaturday;

  /// No description provided for @globalNotify.
  ///
  /// In zh, this message translates to:
  /// **'通知'**
  String get globalNotify;

  /// No description provided for @globalSubmit.
  ///
  /// In zh, this message translates to:
  /// **'提交'**
  String get globalSubmit;

  /// No description provided for @globalEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get globalEdit;

  /// No description provided for @globalIKnow.
  ///
  /// In zh, this message translates to:
  /// **'我知道了'**
  String get globalIKnow;

  /// No description provided for @globalAdd.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get globalAdd;

  /// No description provided for @globalDateFormat.
  ///
  /// In zh, this message translates to:
  /// **'yyyy年MM月dd日'**
  String get globalDateFormat;

  /// No description provided for @globalMonthJan.
  ///
  /// In zh, this message translates to:
  /// **'1月'**
  String get globalMonthJan;

  /// No description provided for @globalMonthFeb.
  ///
  /// In zh, this message translates to:
  /// **'2月'**
  String get globalMonthFeb;

  /// No description provided for @globalMonthMar.
  ///
  /// In zh, this message translates to:
  /// **'3月'**
  String get globalMonthMar;

  /// No description provided for @globalMonthApr.
  ///
  /// In zh, this message translates to:
  /// **'4月'**
  String get globalMonthApr;

  /// No description provided for @globalMonthMay.
  ///
  /// In zh, this message translates to:
  /// **'5月'**
  String get globalMonthMay;

  /// No description provided for @globalMonthJun.
  ///
  /// In zh, this message translates to:
  /// **'6月'**
  String get globalMonthJun;

  /// No description provided for @globalMonthJul.
  ///
  /// In zh, this message translates to:
  /// **'7月'**
  String get globalMonthJul;

  /// No description provided for @globalMonthAug.
  ///
  /// In zh, this message translates to:
  /// **'8月'**
  String get globalMonthAug;

  /// No description provided for @globalMonthSept.
  ///
  /// In zh, this message translates to:
  /// **'9月'**
  String get globalMonthSept;

  /// No description provided for @globalMonthOct.
  ///
  /// In zh, this message translates to:
  /// **'10月'**
  String get globalMonthOct;

  /// No description provided for @globalMonthNov.
  ///
  /// In zh, this message translates to:
  /// **'11月'**
  String get globalMonthNov;

  /// No description provided for @globalMonthDec.
  ///
  /// In zh, this message translates to:
  /// **'12月'**
  String get globalMonthDec;

  /// No description provided for @authImmediatelyRegister.
  ///
  /// In zh, this message translates to:
  /// **'立即注册'**
  String get authImmediatelyRegister;

  /// No description provided for @authLoginBySSO.
  ///
  /// In zh, this message translates to:
  /// **'SSO登录'**
  String get authLoginBySSO;

  /// No description provided for @authPrivacyCheckedTips.
  ///
  /// In zh, this message translates to:
  /// **'请先勾选同意《隐私协议》和《用户服务协议》'**
  String get authPrivacyCheckedTips;

  /// No description provided for @authLogin.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get authLogin;

  /// No description provided for @authLoginToNetEase.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get authLoginToNetEase;

  /// No description provided for @authRegisterAndLogin.
  ///
  /// In zh, this message translates to:
  /// **'注册/登录'**
  String get authRegisterAndLogin;

  /// No description provided for @authServiceAgreement.
  ///
  /// In zh, this message translates to:
  /// **'用户协议'**
  String get authServiceAgreement;

  /// No description provided for @authPrivacy.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get authPrivacy;

  /// No description provided for @authPrivacyDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'用户协议与隐私政策'**
  String get authPrivacyDialogTitle;

  /// No description provided for @authUserProtocolAndPrivacy.
  ///
  /// In zh, this message translates to:
  /// **'用户服务协议和隐私协议'**
  String get authUserProtocolAndPrivacy;

  /// No description provided for @authNetEaseServiceAgreement.
  ///
  /// In zh, this message translates to:
  /// **'网易会议用户协议'**
  String get authNetEaseServiceAgreement;

  /// No description provided for @authNeteasePrivacy.
  ///
  /// In zh, this message translates to:
  /// **'网易会议隐私政策'**
  String get authNeteasePrivacy;

  /// No description provided for @authPrivacyDialogMessage.
  ///
  /// In zh, this message translates to:
  /// **'网易会议是一款由网易公司向您提供的音视频会议软件产品。我们将通过\"{neteaseUserProtocol}\"与\"{neteasePrivacy}\"来协助您了解会议软件处理个人信息的方式与您的权利与义务。如您同意，点击同意接受我们的服务。'**
  String authPrivacyDialogMessage(
      Object neteasePrivacy, Object neteaseUserProtocol);

  /// No description provided for @authLoginOnOtherDevice.
  ///
  /// In zh, this message translates to:
  /// **'同时登录设备数超出限制，已自动登出'**
  String get authLoginOnOtherDevice;

  /// No description provided for @authLoginTokenExpired.
  ///
  /// In zh, this message translates to:
  /// **'登录状态已过期，请重新登录'**
  String get authLoginTokenExpired;

  /// No description provided for @authInputEmailHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入完整的邮箱地址'**
  String get authInputEmailHint;

  /// No description provided for @authAndLogin.
  ///
  /// In zh, this message translates to:
  /// **'授权并登录'**
  String get authAndLogin;

  /// No description provided for @authNoAuth.
  ///
  /// In zh, this message translates to:
  /// **'请先登录'**
  String get authNoAuth;

  /// No description provided for @authHasReadAndAgreeToPolicy.
  ///
  /// In zh, this message translates to:
  /// **'已阅读并同意网易会议{neteasePrivacy}和{neteaseUserProtocol}'**
  String authHasReadAndAgreeToPolicy(
      Object neteasePrivacy, Object neteaseUserProtocol);

  /// No description provided for @authHasReadAndAgreeMeeting.
  ///
  /// In zh, this message translates to:
  /// **'已阅读并同意网易会议'**
  String get authHasReadAndAgreeMeeting;

  /// No description provided for @authAnd.
  ///
  /// In zh, this message translates to:
  /// **'和'**
  String get authAnd;

  /// No description provided for @authNextStep.
  ///
  /// In zh, this message translates to:
  /// **'下一步'**
  String get authNextStep;

  /// No description provided for @authMobileNotRegister.
  ///
  /// In zh, this message translates to:
  /// **'该手机号未注册'**
  String get authMobileNotRegister;

  /// No description provided for @authVerifyCodeErrorTip.
  ///
  /// In zh, this message translates to:
  /// **'验证码不正确'**
  String get authVerifyCodeErrorTip;

  /// No description provided for @authEnterCheckCode.
  ///
  /// In zh, this message translates to:
  /// **'请输入验证码'**
  String get authEnterCheckCode;

  /// No description provided for @authEnterMobile.
  ///
  /// In zh, this message translates to:
  /// **'请输入手机号'**
  String get authEnterMobile;

  /// No description provided for @authGetCheckCode.
  ///
  /// In zh, this message translates to:
  /// **'获取验证码'**
  String get authGetCheckCode;

  /// No description provided for @authNewRegister.
  ///
  /// In zh, this message translates to:
  /// **'新用户注册'**
  String get authNewRegister;

  /// No description provided for @authCheckMobile.
  ///
  /// In zh, this message translates to:
  /// **'验证手机号'**
  String get authCheckMobile;

  /// No description provided for @authLoginByPassword.
  ///
  /// In zh, this message translates to:
  /// **'密码登录'**
  String get authLoginByPassword;

  /// No description provided for @authLoginByMobile.
  ///
  /// In zh, this message translates to:
  /// **'手机验证码登录'**
  String get authLoginByMobile;

  /// No description provided for @authRegister.
  ///
  /// In zh, this message translates to:
  /// **'注册'**
  String get authRegister;

  /// No description provided for @authEnterAccount.
  ///
  /// In zh, this message translates to:
  /// **'请输入账号'**
  String get authEnterAccount;

  /// No description provided for @authEnterPassword.
  ///
  /// In zh, this message translates to:
  /// **'请输入密码'**
  String get authEnterPassword;

  /// No description provided for @authEnterNick.
  ///
  /// In zh, this message translates to:
  /// **'请输入昵称'**
  String get authEnterNick;

  /// No description provided for @authCompleteSelfInfo.
  ///
  /// In zh, this message translates to:
  /// **'完善个人信息'**
  String get authCompleteSelfInfo;

  /// No description provided for @authResendCode.
  ///
  /// In zh, this message translates to:
  /// **'{second}后重新发送验证码'**
  String authResendCode(Object second);

  /// No description provided for @authCheckCodeHasSendToMobile.
  ///
  /// In zh, this message translates to:
  /// **'验证码已经发送至{mobile}，请在下方输入验证码'**
  String authCheckCodeHasSendToMobile(Object mobile);

  /// No description provided for @authResend.
  ///
  /// In zh, this message translates to:
  /// **'重新发送'**
  String get authResend;

  /// No description provided for @authEnterCorpCode.
  ///
  /// In zh, this message translates to:
  /// **'请输入企业代码'**
  String get authEnterCorpCode;

  /// No description provided for @authSSOTip.
  ///
  /// In zh, this message translates to:
  /// **'暂无所属企业'**
  String get authSSOTip;

  /// No description provided for @authSSONotSupport.
  ///
  /// In zh, this message translates to:
  /// **'当前不支持SSO登录'**
  String get authSSONotSupport;

  /// No description provided for @authSSOLoginFail.
  ///
  /// In zh, this message translates to:
  /// **'SSO登录失败'**
  String get authSSOLoginFail;

  /// No description provided for @authEnterCorpMail.
  ///
  /// In zh, this message translates to:
  /// **'请输入企业邮箱'**
  String get authEnterCorpMail;

  /// No description provided for @authForgetPassword.
  ///
  /// In zh, this message translates to:
  /// **'忘记密码'**
  String get authForgetPassword;

  /// No description provided for @authPhoneErrorTip.
  ///
  /// In zh, this message translates to:
  /// **'手机号不合法'**
  String get authPhoneErrorTip;

  /// No description provided for @authPleaseLoginFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先登录网易会议'**
  String get authPleaseLoginFirst;

  /// No description provided for @authResetInitialPasswordTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置你的新密码'**
  String get authResetInitialPasswordTitle;

  /// No description provided for @authResetInitialPasswordDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置新密码'**
  String get authResetInitialPasswordDialogTitle;

  /// No description provided for @authResetInitialPasswordDialogMessage.
  ///
  /// In zh, this message translates to:
  /// **'当前密码为初始密码，为了安全考虑，建议您前往设置新密码'**
  String get authResetInitialPasswordDialogMessage;

  /// No description provided for @authResetInitialPasswordDialogCancelLabel.
  ///
  /// In zh, this message translates to:
  /// **'暂不设置'**
  String get authResetInitialPasswordDialogCancelLabel;

  /// No description provided for @authResetInitialPasswordDialogOKLabel.
  ///
  /// In zh, this message translates to:
  /// **'前往设置'**
  String get authResetInitialPasswordDialogOKLabel;

  /// No description provided for @authMobileNum.
  ///
  /// In zh, this message translates to:
  /// **'手机号'**
  String get authMobileNum;

  /// No description provided for @authUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'暂无'**
  String get authUnavailable;

  /// No description provided for @authNoCorpCode.
  ///
  /// In zh, this message translates to:
  /// **'没有企业代码？'**
  String get authNoCorpCode;

  /// No description provided for @authCreateAccountByPC.
  ///
  /// In zh, this message translates to:
  /// **'可前往桌面端创建企业'**
  String get authCreateAccountByPC;

  /// No description provided for @authCreateNow.
  ///
  /// In zh, this message translates to:
  /// **'立即创建'**
  String get authCreateNow;

  /// No description provided for @authLoginToCorpEdition.
  ///
  /// In zh, this message translates to:
  /// **'前往正式版'**
  String get authLoginToCorpEdition;

  /// No description provided for @authLoginToTrialEdition.
  ///
  /// In zh, this message translates to:
  /// **'前往体验版'**
  String get authLoginToTrialEdition;

  /// No description provided for @authCorpNotFound.
  ///
  /// In zh, this message translates to:
  /// **'未匹配企业'**
  String get authCorpNotFound;

  /// No description provided for @authHasCorpCode.
  ///
  /// In zh, this message translates to:
  /// **'已有企业代码？'**
  String get authHasCorpCode;

  /// No description provided for @authLoginByCorpCode.
  ///
  /// In zh, this message translates to:
  /// **'企业代码登录'**
  String get authLoginByCorpCode;

  /// No description provided for @authLoginByCorpMail.
  ///
  /// In zh, this message translates to:
  /// **'企业邮箱登录'**
  String get authLoginByCorpMail;

  /// No description provided for @authOldPasswordError.
  ///
  /// In zh, this message translates to:
  /// **'当前密码错误，请重新输入'**
  String get authOldPasswordError;

  /// No description provided for @authEnterOldPassword.
  ///
  /// In zh, this message translates to:
  /// **'请输入原密码'**
  String get authEnterOldPassword;

  /// No description provided for @authSuggestChrome.
  ///
  /// In zh, this message translates to:
  /// **'推荐使用Chrome浏览器'**
  String get authSuggestChrome;

  /// No description provided for @authLoggingIn.
  ///
  /// In zh, this message translates to:
  /// **'正在登录会议'**
  String get authLoggingIn;

  /// No description provided for @authHowToGetCorpCode.
  ///
  /// In zh, this message translates to:
  /// **'如何获取企业代码？'**
  String get authHowToGetCorpCode;

  /// No description provided for @authGetCorpCodeFromAdmin.
  ///
  /// In zh, this message translates to:
  /// **'可与企业管理员咨询您的企业代码'**
  String get authGetCorpCodeFromAdmin;

  /// No description provided for @authIKnowCorpCode.
  ///
  /// In zh, this message translates to:
  /// **'我知道企业代码'**
  String get authIKnowCorpCode;

  /// No description provided for @authIDontKnowCorpCode.
  ///
  /// In zh, this message translates to:
  /// **'我不知道企业代码'**
  String get authIDontKnowCorpCode;

  /// No description provided for @authTypeAccountPwd.
  ///
  /// In zh, this message translates to:
  /// **'账号密码'**
  String get authTypeAccountPwd;

  /// No description provided for @authLoginByAccountPwd.
  ///
  /// In zh, this message translates to:
  /// **'账号密码登录'**
  String get authLoginByAccountPwd;

  /// No description provided for @authLoginByMobilePwd.
  ///
  /// In zh, this message translates to:
  /// **'手机密码登录'**
  String get authLoginByMobilePwd;

  /// No description provided for @authLoginByEmailPwd.
  ///
  /// In zh, this message translates to:
  /// **'邮箱密码登录'**
  String get authLoginByEmailPwd;

  /// No description provided for @authOtherLoginTypes.
  ///
  /// In zh, this message translates to:
  /// **'其他登录方式'**
  String get authOtherLoginTypes;

  /// No description provided for @authEnterEmail.
  ///
  /// In zh, this message translates to:
  /// **'请输入邮箱'**
  String get authEnterEmail;

  /// No description provided for @authEmail.
  ///
  /// In zh, this message translates to:
  /// **'邮箱'**
  String get authEmail;

  /// No description provided for @oldPassword.
  ///
  /// In zh, this message translates to:
  /// **'旧密码'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In zh, this message translates to:
  /// **'新密码'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In zh, this message translates to:
  /// **'再次输入'**
  String get confirmPassword;

  /// No description provided for @meetingCreate.
  ///
  /// In zh, this message translates to:
  /// **'即刻会议'**
  String get meetingCreate;

  /// No description provided for @meetingHold.
  ///
  /// In zh, this message translates to:
  /// **'发起会议'**
  String get meetingHold;

  /// No description provided for @meetingNetworkAbnormalityCheckAndRejoin.
  ///
  /// In zh, this message translates to:
  /// **'网络异常，请检查网络连接后重新入会'**
  String get meetingNetworkAbnormalityCheckAndRejoin;

  /// No description provided for @meetingRecover.
  ///
  /// In zh, this message translates to:
  /// **'检测到您上次异常退出，是否要恢复会议？'**
  String get meetingRecover;

  /// No description provided for @meetingJoin.
  ///
  /// In zh, this message translates to:
  /// **'加入会议'**
  String get meetingJoin;

  /// No description provided for @meetingSchedule.
  ///
  /// In zh, this message translates to:
  /// **'预约会议'**
  String get meetingSchedule;

  /// No description provided for @meetingScheduleListEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无会议'**
  String get meetingScheduleListEmpty;

  /// No description provided for @meetingToday.
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get meetingToday;

  /// No description provided for @meetingTomorrow.
  ///
  /// In zh, this message translates to:
  /// **'明天'**
  String get meetingTomorrow;

  /// No description provided for @meetingNum.
  ///
  /// In zh, this message translates to:
  /// **'会议号'**
  String get meetingNum;

  /// No description provided for @meetingStatusInit.
  ///
  /// In zh, this message translates to:
  /// **'待开始'**
  String get meetingStatusInit;

  /// No description provided for @meetingStatusStarted.
  ///
  /// In zh, this message translates to:
  /// **'进行中'**
  String get meetingStatusStarted;

  /// No description provided for @meetingStatusEnded.
  ///
  /// In zh, this message translates to:
  /// **'已结束'**
  String get meetingStatusEnded;

  /// No description provided for @meetingStatusRecycle.
  ///
  /// In zh, this message translates to:
  /// **'已回收'**
  String get meetingStatusRecycle;

  /// No description provided for @meetingStatusCancel.
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get meetingStatusCancel;

  /// No description provided for @meetingOperationNotSupportedInMeeting.
  ///
  /// In zh, this message translates to:
  /// **'会议中暂不支持该操作'**
  String get meetingOperationNotSupportedInMeeting;

  /// No description provided for @meetingPersonalMeetingID.
  ///
  /// In zh, this message translates to:
  /// **'个人会议号'**
  String get meetingPersonalMeetingID;

  /// No description provided for @meetingPersonalShortMeetingID.
  ///
  /// In zh, this message translates to:
  /// **'个人会议短号'**
  String get meetingPersonalShortMeetingID;

  /// No description provided for @meetingUsePersonalMeetId.
  ///
  /// In zh, this message translates to:
  /// **'使用个人会议号'**
  String get meetingUsePersonalMeetId;

  /// No description provided for @meetingPassword.
  ///
  /// In zh, this message translates to:
  /// **'会议密码'**
  String get meetingPassword;

  /// No description provided for @meetingEnterSixDigitPassword.
  ///
  /// In zh, this message translates to:
  /// **'请输入6位数字密码'**
  String get meetingEnterSixDigitPassword;

  /// No description provided for @meetingJoinCameraOn.
  ///
  /// In zh, this message translates to:
  /// **'入会时打开摄像头'**
  String get meetingJoinCameraOn;

  /// No description provided for @meetingJoinMicrophoneOn.
  ///
  /// In zh, this message translates to:
  /// **'入会时打开麦克风'**
  String get meetingJoinMicrophoneOn;

  /// No description provided for @meetingJoinCloudRecordOn.
  ///
  /// In zh, this message translates to:
  /// **'入会时打开会议录制'**
  String get meetingJoinCloudRecordOn;

  /// No description provided for @meetingCreateAlreadyInTip.
  ///
  /// In zh, this message translates to:
  /// **'这个会议还在进行中，要加入这个会议吗？'**
  String get meetingCreateAlreadyInTip;

  /// No description provided for @meetingCreateFail.
  ///
  /// In zh, this message translates to:
  /// **'创建会议失败'**
  String get meetingCreateFail;

  /// No description provided for @meetingJoinFail.
  ///
  /// In zh, this message translates to:
  /// **'加入会议失败'**
  String get meetingJoinFail;

  /// No description provided for @meetingEnterId.
  ///
  /// In zh, this message translates to:
  /// **'请输入会议号'**
  String get meetingEnterId;

  /// No description provided for @meetingSubject.
  ///
  /// In zh, this message translates to:
  /// **'{userName}预约的会议'**
  String meetingSubject(Object userName);

  /// No description provided for @meetingScheduleNow.
  ///
  /// In zh, this message translates to:
  /// **'立即预约'**
  String get meetingScheduleNow;

  /// No description provided for @meetingEnterPassword.
  ///
  /// In zh, this message translates to:
  /// **'请输入会议密码'**
  String get meetingEnterPassword;

  /// No description provided for @meetingScheduleTimeIllegal.
  ///
  /// In zh, this message translates to:
  /// **'预约时间不能早于当前时间'**
  String get meetingScheduleTimeIllegal;

  /// No description provided for @meetingScheduleSuccess.
  ///
  /// In zh, this message translates to:
  /// **'会议预约成功'**
  String get meetingScheduleSuccess;

  /// No description provided for @meetingDurationTooLong.
  ///
  /// In zh, this message translates to:
  /// **'会议持续时间过长'**
  String get meetingDurationTooLong;

  /// No description provided for @meetingInfo.
  ///
  /// In zh, this message translates to:
  /// **'会议信息'**
  String get meetingInfo;

  /// No description provided for @meetingSecurity.
  ///
  /// In zh, this message translates to:
  /// **'安全'**
  String get meetingSecurity;

  /// No description provided for @meetingWaitingRoomHint.
  ///
  /// In zh, this message translates to:
  /// **'参会者加入会议时先进入等候室'**
  String get meetingWaitingRoomHint;

  /// No description provided for @meetingAttendeeAudioOff.
  ///
  /// In zh, this message translates to:
  /// **'参会者加入会议时自动静音'**
  String get meetingAttendeeAudioOff;

  /// No description provided for @meetingAttendeeAudioOffAllowOn.
  ///
  /// In zh, this message translates to:
  /// **'自动静音且允许自主开麦'**
  String get meetingAttendeeAudioOffAllowOn;

  /// No description provided for @meetingAttendeeAudioOffNotAllowOn.
  ///
  /// In zh, this message translates to:
  /// **'自动静音且不允许自主开麦'**
  String get meetingAttendeeAudioOffNotAllowOn;

  /// No description provided for @meetingEnterTopic.
  ///
  /// In zh, this message translates to:
  /// **'请输入会议主题'**
  String get meetingEnterTopic;

  /// No description provided for @meetingEndTime.
  ///
  /// In zh, this message translates to:
  /// **'结束时间'**
  String get meetingEndTime;

  /// No description provided for @meetingChooseDate.
  ///
  /// In zh, this message translates to:
  /// **'选择日期'**
  String get meetingChooseDate;

  /// No description provided for @meetingLiveOn.
  ///
  /// In zh, this message translates to:
  /// **'开启直播'**
  String get meetingLiveOn;

  /// No description provided for @meetingLiveUrl.
  ///
  /// In zh, this message translates to:
  /// **'直播地址'**
  String get meetingLiveUrl;

  /// No description provided for @meetingLiveLevelTip.
  ///
  /// In zh, this message translates to:
  /// **'仅本企业员工可观看'**
  String get meetingLiveLevelTip;

  /// No description provided for @meetingRecordOn.
  ///
  /// In zh, this message translates to:
  /// **'参会者加入会议时打开会议录制'**
  String get meetingRecordOn;

  /// No description provided for @meetingInviteUrl.
  ///
  /// In zh, this message translates to:
  /// **'邀请链接'**
  String get meetingInviteUrl;

  /// No description provided for @meetingLiveLevel.
  ///
  /// In zh, this message translates to:
  /// **'直播模式'**
  String get meetingLiveLevel;

  /// No description provided for @meetingCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消会议'**
  String get meetingCancel;

  /// No description provided for @meetingCancelConfirm.
  ///
  /// In zh, this message translates to:
  /// **'是否确定要取消会议？'**
  String get meetingCancelConfirm;

  /// No description provided for @meetingNotCancel.
  ///
  /// In zh, this message translates to:
  /// **'暂不取消'**
  String get meetingNotCancel;

  /// No description provided for @meetingEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑会议'**
  String get meetingEdit;

  /// No description provided for @meetingScheduleEditSuccess.
  ///
  /// In zh, this message translates to:
  /// **'会议修改成功'**
  String get meetingScheduleEditSuccess;

  /// No description provided for @meetingInfoDialogMeetingTitle.
  ///
  /// In zh, this message translates to:
  /// **'会议主题'**
  String get meetingInfoDialogMeetingTitle;

  /// No description provided for @meetingDeepLinkTipAlreadyInMeeting.
  ///
  /// In zh, this message translates to:
  /// **'您已在对应会议中'**
  String get meetingDeepLinkTipAlreadyInMeeting;

  /// No description provided for @meetingDeepLinkTipAlreadyInDifferentMeeting.
  ///
  /// In zh, this message translates to:
  /// **'您已在其他会议中，请退出当前会议后重试'**
  String get meetingDeepLinkTipAlreadyInDifferentMeeting;

  /// No description provided for @meetingShareScreenTips.
  ///
  /// In zh, this message translates to:
  /// **'您屏幕上包括通知在内的所有内容，均将被录制。请警惕仿冒客服、校园贷和公检法的诈骗，不要在“共享屏幕”时进行财务转账操作。'**
  String get meetingShareScreenTips;

  /// No description provided for @meetingForegroundContentText.
  ///
  /// In zh, this message translates to:
  /// **'网易会议正在运行中'**
  String get meetingForegroundContentText;

  /// No description provided for @meetingId.
  ///
  /// In zh, this message translates to:
  /// **'会议号:'**
  String get meetingId;

  /// No description provided for @meetingShortId.
  ///
  /// In zh, this message translates to:
  /// **'会议号:'**
  String get meetingShortId;

  /// No description provided for @meetingStartTime.
  ///
  /// In zh, this message translates to:
  /// **'开始时间'**
  String get meetingStartTime;

  /// No description provided for @meetingCloseByHost.
  ///
  /// In zh, this message translates to:
  /// **'主持人已结束会议'**
  String get meetingCloseByHost;

  /// No description provided for @meetingEndOfLife.
  ///
  /// In zh, this message translates to:
  /// **'会议时长已达上限，会议关闭'**
  String get meetingEndOfLife;

  /// No description provided for @meetingSwitchOtherDevice.
  ///
  /// In zh, this message translates to:
  /// **'因被主持人移出或切换至其他设备，您已退出会议'**
  String get meetingSwitchOtherDevice;

  /// No description provided for @meetingSyncDataError.
  ///
  /// In zh, this message translates to:
  /// **'房间信息同步失败'**
  String get meetingSyncDataError;

  /// No description provided for @meetingEnd.
  ///
  /// In zh, this message translates to:
  /// **'会议已结束'**
  String get meetingEnd;

  /// No description provided for @meetingMicrophone.
  ///
  /// In zh, this message translates to:
  /// **'麦克风'**
  String get meetingMicrophone;

  /// No description provided for @meetingCamera.
  ///
  /// In zh, this message translates to:
  /// **'摄像头'**
  String get meetingCamera;

  /// No description provided for @meetingDetail.
  ///
  /// In zh, this message translates to:
  /// **'会议详情'**
  String get meetingDetail;

  /// No description provided for @meetingInfoDialogMeetingDateFormat.
  ///
  /// In zh, this message translates to:
  /// **'yyyy年MM月dd日'**
  String get meetingInfoDialogMeetingDateFormat;

  /// No description provided for @meetingHasBeenCanceled.
  ///
  /// In zh, this message translates to:
  /// **'会议已被其他登录设备取消'**
  String get meetingHasBeenCanceled;

  /// No description provided for @meetingHasBeenCanceledByOwner.
  ///
  /// In zh, this message translates to:
  /// **'会议被创建者取消'**
  String get meetingHasBeenCanceledByOwner;

  /// No description provided for @meetingRepeat.
  ///
  /// In zh, this message translates to:
  /// **'周期'**
  String get meetingRepeat;

  /// No description provided for @meetingFrequency.
  ///
  /// In zh, this message translates to:
  /// **'重复频率'**
  String get meetingFrequency;

  /// No description provided for @meetingNoRepeat.
  ///
  /// In zh, this message translates to:
  /// **'不重复'**
  String get meetingNoRepeat;

  /// No description provided for @meetingRepeatEveryday.
  ///
  /// In zh, this message translates to:
  /// **'每天'**
  String get meetingRepeatEveryday;

  /// No description provided for @meetingRepeatEveryWeekday.
  ///
  /// In zh, this message translates to:
  /// **'每个工作日'**
  String get meetingRepeatEveryWeekday;

  /// No description provided for @meetingRepeatEveryWeek.
  ///
  /// In zh, this message translates to:
  /// **'每周'**
  String get meetingRepeatEveryWeek;

  /// No description provided for @meetingRepeatEveryTwoWeek.
  ///
  /// In zh, this message translates to:
  /// **'每两周'**
  String get meetingRepeatEveryTwoWeek;

  /// No description provided for @meetingRepeatEveryMonth.
  ///
  /// In zh, this message translates to:
  /// **'每月'**
  String get meetingRepeatEveryMonth;

  /// No description provided for @meetingRepeatCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get meetingRepeatCustom;

  /// No description provided for @meetingRepeatEndAt.
  ///
  /// In zh, this message translates to:
  /// **'结束于'**
  String get meetingRepeatEndAt;

  /// No description provided for @meetingRepeatEndAtOneday.
  ///
  /// In zh, this message translates to:
  /// **'结束于某天'**
  String get meetingRepeatEndAtOneday;

  /// No description provided for @meetingRepeatTimes.
  ///
  /// In zh, this message translates to:
  /// **'限定会议次数'**
  String get meetingRepeatTimes;

  /// No description provided for @meetingRepeatStop.
  ///
  /// In zh, this message translates to:
  /// **'结束重复'**
  String get meetingRepeatStop;

  /// No description provided for @meetingDayInMonth.
  ///
  /// In zh, this message translates to:
  /// **'{day}日'**
  String meetingDayInMonth(Object day);

  /// No description provided for @meetingRepeatSelectDate.
  ///
  /// In zh, this message translates to:
  /// **'选择日期'**
  String get meetingRepeatSelectDate;

  /// No description provided for @meetingRepeatDayInWeek.
  ///
  /// In zh, this message translates to:
  /// **'每{week}周的{day}重复'**
  String meetingRepeatDayInWeek(Object day, Object week);

  /// No description provided for @meetingRepeatDay.
  ///
  /// In zh, this message translates to:
  /// **'每{day}天重复'**
  String meetingRepeatDay(Object day);

  /// No description provided for @meetingRepeatDayInMonth.
  ///
  /// In zh, this message translates to:
  /// **'每{month}个月的{day}重复'**
  String meetingRepeatDayInMonth(Object day, Object month);

  /// No description provided for @meetingRepeatDayInWeekInMonth.
  ///
  /// In zh, this message translates to:
  /// **'每{month}个月的第{week}个{weekday}重复'**
  String meetingRepeatDayInWeekInMonth(
      Object month, Object week, Object weekday);

  /// No description provided for @meetingRepeatDate.
  ///
  /// In zh, this message translates to:
  /// **'日期'**
  String get meetingRepeatDate;

  /// No description provided for @meetingRepeatWeekday.
  ///
  /// In zh, this message translates to:
  /// **'星期'**
  String get meetingRepeatWeekday;

  /// No description provided for @meetingRepeatOrderWeekday.
  ///
  /// In zh, this message translates to:
  /// **'第{week}个{weekday}'**
  String meetingRepeatOrderWeekday(Object week, Object weekday);

  /// No description provided for @meetingRepeatEditing.
  ///
  /// In zh, this message translates to:
  /// **'你正在编辑周期性会议'**
  String get meetingRepeatEditing;

  /// No description provided for @meetingRepeatEditCurrent.
  ///
  /// In zh, this message translates to:
  /// **'编辑本次会议'**
  String get meetingRepeatEditCurrent;

  /// No description provided for @meetingRepeatEditAll.
  ///
  /// In zh, this message translates to:
  /// **'编辑所有会议'**
  String get meetingRepeatEditAll;

  /// No description provided for @meetingRepeatEditTips.
  ///
  /// In zh, this message translates to:
  /// **'修改以下信息，将影响该系列周期性会议'**
  String get meetingRepeatEditTips;

  /// No description provided for @meetingLeaveEditTips.
  ///
  /// In zh, this message translates to:
  /// **'确认退出会议编辑吗？'**
  String get meetingLeaveEditTips;

  /// No description provided for @meetingRepeatCancelAll.
  ///
  /// In zh, this message translates to:
  /// **'同时取消该系列周期性会议'**
  String get meetingRepeatCancelAll;

  /// No description provided for @meetingCancelCancel.
  ///
  /// In zh, this message translates to:
  /// **'暂不取消'**
  String get meetingCancelCancel;

  /// No description provided for @meetingCancelConfirm2.
  ///
  /// In zh, this message translates to:
  /// **'取消会议'**
  String get meetingCancelConfirm2;

  /// No description provided for @meetingLeaveEditTips2.
  ///
  /// In zh, this message translates to:
  /// **'退出后，将无法保存当前会议的更改'**
  String get meetingLeaveEditTips2;

  /// No description provided for @meetingEditContinue.
  ///
  /// In zh, this message translates to:
  /// **'继续编辑'**
  String get meetingEditContinue;

  /// No description provided for @meetingEditLeave.
  ///
  /// In zh, this message translates to:
  /// **'退出'**
  String get meetingEditLeave;

  /// No description provided for @meetingRepeatUnitEvery.
  ///
  /// In zh, this message translates to:
  /// **'每'**
  String get meetingRepeatUnitEvery;

  /// No description provided for @meetingRepeatUnitDay.
  ///
  /// In zh, this message translates to:
  /// **'天'**
  String get meetingRepeatUnitDay;

  /// No description provided for @meetingRepeatUnitWeek.
  ///
  /// In zh, this message translates to:
  /// **'周'**
  String get meetingRepeatUnitWeek;

  /// No description provided for @meetingRepeatUnitMonth.
  ///
  /// In zh, this message translates to:
  /// **'个月'**
  String get meetingRepeatUnitMonth;

  /// No description provided for @meetingRepeatLimitTimes.
  ///
  /// In zh, this message translates to:
  /// **'限定会议次数{times}次'**
  String meetingRepeatLimitTimes(Object times);

  /// No description provided for @meetingJoinBeforeHost.
  ///
  /// In zh, this message translates to:
  /// **'允许参会者在主持人进会前加入会议'**
  String get meetingJoinBeforeHost;

  /// No description provided for @meetingRepeatMeetings.
  ///
  /// In zh, this message translates to:
  /// **'周期性会议'**
  String get meetingRepeatMeetings;

  /// No description provided for @meetingRepeatLabel.
  ///
  /// In zh, this message translates to:
  /// **'重复'**
  String get meetingRepeatLabel;

  /// No description provided for @meetingRepeatEnd.
  ///
  /// In zh, this message translates to:
  /// **'结束'**
  String get meetingRepeatEnd;

  /// No description provided for @meetingRepeatOneDay.
  ///
  /// In zh, this message translates to:
  /// **'某天'**
  String get meetingRepeatOneDay;

  /// No description provided for @meetingRepeatFrequency.
  ///
  /// In zh, this message translates to:
  /// **'频率'**
  String get meetingRepeatFrequency;

  /// No description provided for @meetingRepeatAt.
  ///
  /// In zh, this message translates to:
  /// **'位于'**
  String get meetingRepeatAt;

  /// No description provided for @meetingRepeatUncheckTips.
  ///
  /// In zh, this message translates to:
  /// **'当前日程为{date}，无法取消选择'**
  String meetingRepeatUncheckTips(Object date);

  /// No description provided for @meetingRepeatCancelEdit.
  ///
  /// In zh, this message translates to:
  /// **'取消编辑'**
  String get meetingRepeatCancelEdit;

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

  /// No description provided for @meetingAttendees.
  ///
  /// In zh, this message translates to:
  /// **'参会者'**
  String get meetingAttendees;

  /// No description provided for @meetingAttendeeCount.
  ///
  /// In zh, this message translates to:
  /// **'{count}人'**
  String meetingAttendeeCount(Object count);

  /// No description provided for @meetingAddAttendee.
  ///
  /// In zh, this message translates to:
  /// **'添加参会者'**
  String get meetingAddAttendee;

  /// No description provided for @meetingSearchAndAddAttendee.
  ///
  /// In zh, this message translates to:
  /// **'搜索并添加参会人'**
  String get meetingSearchAndAddAttendee;

  /// No description provided for @meetingOpen.
  ///
  /// In zh, this message translates to:
  /// **'展开'**
  String get meetingOpen;

  /// No description provided for @meetingClose.
  ///
  /// In zh, this message translates to:
  /// **'收起'**
  String get meetingClose;

  /// No description provided for @meetingClearRecord.
  ///
  /// In zh, this message translates to:
  /// **'清空记录'**
  String get meetingClearRecord;

  /// No description provided for @meetingPickTimezone.
  ///
  /// In zh, this message translates to:
  /// **'选择时区'**
  String get meetingPickTimezone;

  /// No description provided for @meetingTimezone.
  ///
  /// In zh, this message translates to:
  /// **'时区'**
  String get meetingTimezone;

  /// No description provided for @meetingName.
  ///
  /// In zh, this message translates to:
  /// **'会议名称'**
  String get meetingName;

  /// No description provided for @meetingTime.
  ///
  /// In zh, this message translates to:
  /// **'时间'**
  String get meetingTime;

  /// No description provided for @historyMeeting.
  ///
  /// In zh, this message translates to:
  /// **'历史会议'**
  String get historyMeeting;

  /// No description provided for @historyAllMeeting.
  ///
  /// In zh, this message translates to:
  /// **'全部会议'**
  String get historyAllMeeting;

  /// No description provided for @historyCollectMeeting.
  ///
  /// In zh, this message translates to:
  /// **'收藏会议'**
  String get historyCollectMeeting;

  /// No description provided for @historyMeetingListEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无历史会议'**
  String get historyMeetingListEmpty;

  /// No description provided for @historyCollectMeetingListEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无收藏会议'**
  String get historyCollectMeetingListEmpty;

  /// No description provided for @historyChat.
  ///
  /// In zh, this message translates to:
  /// **'聊天记录'**
  String get historyChat;

  /// No description provided for @historyMeetingOwner.
  ///
  /// In zh, this message translates to:
  /// **'创建人'**
  String get historyMeetingOwner;

  /// No description provided for @historyMeetingCloudRecord.
  ///
  /// In zh, this message translates to:
  /// **'云录制'**
  String get historyMeetingCloudRecord;

  /// No description provided for @historyMeetingCloudRecordingFileBeingGenerated.
  ///
  /// In zh, this message translates to:
  /// **'云录制文件生成中…'**
  String get historyMeetingCloudRecordingFileBeingGenerated;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @settingDefaultCompanyName.
  ///
  /// In zh, this message translates to:
  /// **'无所属企业'**
  String get settingDefaultCompanyName;

  /// No description provided for @settingInternalDedicated.
  ///
  /// In zh, this message translates to:
  /// **'内部专用'**
  String get settingInternalDedicated;

  /// No description provided for @settingMeeting.
  ///
  /// In zh, this message translates to:
  /// **'会议设置'**
  String get settingMeeting;

  /// No description provided for @settingFeedback.
  ///
  /// In zh, this message translates to:
  /// **'意见反馈'**
  String get settingFeedback;

  /// No description provided for @settingBeauty.
  ///
  /// In zh, this message translates to:
  /// **'美颜'**
  String get settingBeauty;

  /// No description provided for @settingVirtualBackground.
  ///
  /// In zh, this message translates to:
  /// **'虚拟背景'**
  String get settingVirtualBackground;

  /// No description provided for @settingAbout.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get settingAbout;

  /// No description provided for @settingSetMeetingNick.
  ///
  /// In zh, this message translates to:
  /// **'设置入会昵称'**
  String get settingSetMeetingNick;

  /// No description provided for @settingSetMeetingTips.
  ///
  /// In zh, this message translates to:
  /// **'请输入中文、英文或数字'**
  String get settingSetMeetingTips;

  /// No description provided for @settingValidatorNickTip.
  ///
  /// In zh, this message translates to:
  /// **'最多20个字符，支持汉字、字母、数字'**
  String get settingValidatorNickTip;

  /// No description provided for @settingModifySuccess.
  ///
  /// In zh, this message translates to:
  /// **'修改成功'**
  String get settingModifySuccess;

  /// No description provided for @settingModifyFailed.
  ///
  /// In zh, this message translates to:
  /// **'修改失败'**
  String get settingModifyFailed;

  /// No description provided for @settingCheckUpdate.
  ///
  /// In zh, this message translates to:
  /// **'检查更新'**
  String get settingCheckUpdate;

  /// No description provided for @settingFindNewVersion.
  ///
  /// In zh, this message translates to:
  /// **'发现新版本'**
  String get settingFindNewVersion;

  /// No description provided for @settingAlreadyLatestVersion.
  ///
  /// In zh, this message translates to:
  /// **'当前已经是最新版'**
  String get settingAlreadyLatestVersion;

  /// No description provided for @settingVersion.
  ///
  /// In zh, this message translates to:
  /// **'Version:'**
  String get settingVersion;

  /// No description provided for @settingAccountAndSafety.
  ///
  /// In zh, this message translates to:
  /// **'账号与安全'**
  String get settingAccountAndSafety;

  /// No description provided for @settingModifyPassword.
  ///
  /// In zh, this message translates to:
  /// **'修改密码'**
  String get settingModifyPassword;

  /// No description provided for @settingEnterNewPasswordTips.
  ///
  /// In zh, this message translates to:
  /// **'请输入新密码'**
  String get settingEnterNewPasswordTips;

  /// No description provided for @settingEnterPasswordConfirm.
  ///
  /// In zh, this message translates to:
  /// **'请再次输入新密码'**
  String get settingEnterPasswordConfirm;

  /// No description provided for @settingValidatorPwdTip.
  ///
  /// In zh, this message translates to:
  /// **'长度6-18个字符，需要包含大小写字母与数字'**
  String get settingValidatorPwdTip;

  /// No description provided for @settingPasswordDifferent.
  ///
  /// In zh, this message translates to:
  /// **'两次输入的新密码不一致，请重新输入'**
  String get settingPasswordDifferent;

  /// No description provided for @settingPasswordSameToOld.
  ///
  /// In zh, this message translates to:
  /// **'新密码与现有密码重复，请重新输入'**
  String get settingPasswordSameToOld;

  /// No description provided for @settingPasswordFormatError.
  ///
  /// In zh, this message translates to:
  /// **'密码格式错误，请重新输入'**
  String get settingPasswordFormatError;

  /// No description provided for @settingCompany.
  ///
  /// In zh, this message translates to:
  /// **'企业'**
  String get settingCompany;

  /// No description provided for @settingSwitchCompanyFail.
  ///
  /// In zh, this message translates to:
  /// **'切换企业失败，请检查当前网络'**
  String get settingSwitchCompanyFail;

  /// No description provided for @settingShowShareUserVideo.
  ///
  /// In zh, this message translates to:
  /// **'共享时开启共享人摄像头'**
  String get settingShowShareUserVideo;

  /// No description provided for @settingOpenCameraMeeting.
  ///
  /// In zh, this message translates to:
  /// **'默认打开摄像头'**
  String get settingOpenCameraMeeting;

  /// No description provided for @settingOpenMicroMeeting.
  ///
  /// In zh, this message translates to:
  /// **'默认打开麦克风'**
  String get settingOpenMicroMeeting;

  /// No description provided for @settingEnableAudioDeviceSwitch.
  ///
  /// In zh, this message translates to:
  /// **'允许音频设备切换'**
  String get settingEnableAudioDeviceSwitch;

  /// No description provided for @settingRename.
  ///
  /// In zh, this message translates to:
  /// **'修改昵称'**
  String get settingRename;

  /// No description provided for @settingPackageVersion.
  ///
  /// In zh, this message translates to:
  /// **'套餐版本'**
  String get settingPackageVersion;

  /// No description provided for @settingNick.
  ///
  /// In zh, this message translates to:
  /// **'昵称'**
  String get settingNick;

  /// No description provided for @settingDeleteAccount.
  ///
  /// In zh, this message translates to:
  /// **'注销账号'**
  String get settingDeleteAccount;

  /// No description provided for @settingEmail.
  ///
  /// In zh, this message translates to:
  /// **'邮箱'**
  String get settingEmail;

  /// No description provided for @settingLogout.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get settingLogout;

  /// No description provided for @settingLogoutConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要退出登录？'**
  String get settingLogoutConfirm;

  /// No description provided for @settingMobile.
  ///
  /// In zh, this message translates to:
  /// **'手机'**
  String get settingMobile;

  /// No description provided for @settingAvatar.
  ///
  /// In zh, this message translates to:
  /// **'头像'**
  String get settingAvatar;

  /// No description provided for @settingAvatarUpdateSuccess.
  ///
  /// In zh, this message translates to:
  /// **'修改头像成功'**
  String get settingAvatarUpdateSuccess;

  /// No description provided for @settingAvatarUpdateFail.
  ///
  /// In zh, this message translates to:
  /// **'修改头像失败'**
  String get settingAvatarUpdateFail;

  /// No description provided for @settingAvatarTitle.
  ///
  /// In zh, this message translates to:
  /// **'头像设置'**
  String get settingAvatarTitle;

  /// No description provided for @settingTakePicture.
  ///
  /// In zh, this message translates to:
  /// **'拍照'**
  String get settingTakePicture;

  /// No description provided for @settingChoosePicture.
  ///
  /// In zh, this message translates to:
  /// **'从手机相册选择'**
  String get settingChoosePicture;

  /// No description provided for @settingPersonalCenter.
  ///
  /// In zh, this message translates to:
  /// **'个人中心'**
  String get settingPersonalCenter;

  /// No description provided for @settingVersionUpgrade.
  ///
  /// In zh, this message translates to:
  /// **'版本更新'**
  String get settingVersionUpgrade;

  /// No description provided for @settingUpgradeNow.
  ///
  /// In zh, this message translates to:
  /// **'立即更新'**
  String get settingUpgradeNow;

  /// No description provided for @settingUpgradeCancel.
  ///
  /// In zh, this message translates to:
  /// **'暂不更新'**
  String get settingUpgradeCancel;

  /// No description provided for @settingDownloadFailTryAgain.
  ///
  /// In zh, this message translates to:
  /// **'下载失败，请重试'**
  String get settingDownloadFailTryAgain;

  /// No description provided for @settingInstallFailTryAgain.
  ///
  /// In zh, this message translates to:
  /// **'安装失败，请重试'**
  String get settingInstallFailTryAgain;

  /// No description provided for @settingModifyAndReLogin.
  ///
  /// In zh, this message translates to:
  /// **'修改后，您需要重新登录'**
  String get settingModifyAndReLogin;

  /// No description provided for @settingServiceBundleTitle.
  ///
  /// In zh, this message translates to:
  /// **'您可召开：'**
  String get settingServiceBundleTitle;

  /// No description provided for @settingServiceBundleExpireTime.
  ///
  /// In zh, this message translates to:
  /// **'服务到期：{expireTime}'**
  String settingServiceBundleExpireTime(Object expireTime);

  /// No description provided for @settingServiceBundleDetailLimitedMinutes.
  ///
  /// In zh, this message translates to:
  /// **'{maxCount}人、限时{maxMinutes}分钟会议'**
  String settingServiceBundleDetailLimitedMinutes(
      Object maxCount, Object maxMinutes);

  /// No description provided for @settingServiceBundleDetailUnlimitedMinutes.
  ///
  /// In zh, this message translates to:
  /// **'{maxCount}人、单场不限时会议'**
  String settingServiceBundleDetailUnlimitedMinutes(Object maxCount);

  /// No description provided for @settingServiceBundleExpirationDate.
  ///
  /// In zh, this message translates to:
  /// **'服务到期：'**
  String get settingServiceBundleExpirationDate;

  /// No description provided for @settingServiceBundleExpirationDateTip.
  ///
  /// In zh, this message translates to:
  /// **'服务已到期，如需延长时问，请联系企业管理员。'**
  String get settingServiceBundleExpirationDateTip;

  /// No description provided for @settingUpdateFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新失败'**
  String get settingUpdateFailed;

  /// No description provided for @settingTryAgainLater.
  ///
  /// In zh, this message translates to:
  /// **'下次再试'**
  String get settingTryAgainLater;

  /// No description provided for @settingRetryNow.
  ///
  /// In zh, this message translates to:
  /// **'立即重试'**
  String get settingRetryNow;

  /// No description provided for @settingUpdating.
  ///
  /// In zh, this message translates to:
  /// **'更新中'**
  String get settingUpdating;

  /// No description provided for @settingCancelUpdate.
  ///
  /// In zh, this message translates to:
  /// **'取消更新'**
  String get settingCancelUpdate;

  /// No description provided for @settingExitApp.
  ///
  /// In zh, this message translates to:
  /// **'退出应用'**
  String get settingExitApp;

  /// No description provided for @settingNotUpdate.
  ///
  /// In zh, this message translates to:
  /// **'暂不更新'**
  String get settingNotUpdate;

  /// No description provided for @settingUPdateNow.
  ///
  /// In zh, this message translates to:
  /// **'立即更新'**
  String get settingUPdateNow;

  /// No description provided for @settingComfirmExitApp.
  ///
  /// In zh, this message translates to:
  /// **'确定退出应用'**
  String get settingComfirmExitApp;

  /// No description provided for @settingSwitchLanguage.
  ///
  /// In zh, this message translates to:
  /// **'语言切换'**
  String get settingSwitchLanguage;

  /// No description provided for @settingSetLanguage.
  ///
  /// In zh, this message translates to:
  /// **'设置语言'**
  String get settingSetLanguage;

  /// No description provided for @settingLanguageTip.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get settingLanguageTip;

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

  /// No description provided for @evaluationTitle.
  ///
  /// In zh, this message translates to:
  /// **'评分'**
  String get evaluationTitle;

  /// No description provided for @evaluationContent.
  ///
  /// In zh, this message translates to:
  /// **'您有多大的可能向同事或合作伙伴推荐网易会议？'**
  String get evaluationContent;

  /// No description provided for @evaluationCoreZero.
  ///
  /// In zh, this message translates to:
  /// **'0-肯定不会'**
  String get evaluationCoreZero;

  /// No description provided for @evaluationCoreTen.
  ///
  /// In zh, this message translates to:
  /// **'10-非常乐意'**
  String get evaluationCoreTen;

  /// No description provided for @evaluationHitTextOne.
  ///
  /// In zh, this message translates to:
  /// **'0-6：让您不满意或者失望的点有哪些？（选填）'**
  String get evaluationHitTextOne;

  /// No description provided for @evaluationHitTextTwo.
  ///
  /// In zh, this message translates to:
  /// **'7-8：您觉得哪些方面能做的更好？（选填）'**
  String get evaluationHitTextTwo;

  /// No description provided for @evaluationHitTextThree.
  ///
  /// In zh, this message translates to:
  /// **'9-10：欢迎分享您体验最好的功能或感受（选填）'**
  String get evaluationHitTextThree;

  /// No description provided for @evaluationToast.
  ///
  /// In zh, this message translates to:
  /// **'请评分后提交喔~'**
  String get evaluationToast;

  /// No description provided for @evaluationThankFeedback.
  ///
  /// In zh, this message translates to:
  /// **'感谢您的反馈'**
  String get evaluationThankFeedback;

  /// No description provided for @evaluationGoHome.
  ///
  /// In zh, this message translates to:
  /// **'返回首页'**
  String get evaluationGoHome;
}

class _MeetingAppLocalizationsDelegate
    extends LocalizationsDelegate<MeetingAppLocalizations> {
  const _MeetingAppLocalizationsDelegate();

  @override
  Future<MeetingAppLocalizations> load(Locale locale) {
    return SynchronousFuture<MeetingAppLocalizations>(
        lookupMeetingAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_MeetingAppLocalizationsDelegate old) => false;
}

MeetingAppLocalizations lookupMeetingAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return MeetingAppLocalizationsEn();
    case 'ja':
      return MeetingAppLocalizationsJa();
    case 'zh':
      return MeetingAppLocalizationsZh();
  }

  throw FlutterError(
      'MeetingAppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
