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

/// Callers can lookup localized strings with an instance of NEMeetingUIKitLocalizations returned
/// by `NEMeetingUIKitLocalizations.of(context)`.
///
/// Applications need to include `NEMeetingUIKitLocalizations.delegate()` in their app's
/// localizationDelegates list, and the locales they support in the app's
/// supportedLocales list. For example:
///
/// ```
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
/// ```
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # rest of dependencies
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

  /// No description provided for @joinMeeting.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinMeeting;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @beauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty '**
  String get beauty;

  /// No description provided for @beautyLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get beautyLevel;

  /// No description provided for @joiningTips.
  ///
  /// In en, this message translates to:
  /// **'Joining...'**
  String get joiningTips;

  /// No description provided for @leaveMeeting.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveMeeting;

  /// No description provided for @quitMeeting.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get quitMeeting;

  /// No description provided for @defaultMeetingTitle.
  ///
  /// In en, this message translates to:
  /// **'Video Meeting'**
  String get defaultMeetingTitle;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @fail.
  ///
  /// In en, this message translates to:
  /// **'Fail'**
  String get fail;

  /// No description provided for @networkNotStable.
  ///
  /// In en, this message translates to:
  /// **'Unstable network'**
  String get networkNotStable;

  /// No description provided for @memberlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get memberlistTitle;

  /// No description provided for @joinMeetingFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to join the meeting'**
  String get joinMeetingFail;

  /// No description provided for @yourChangeHost.
  ///
  /// In en, this message translates to:
  /// **'You are assigned HOST'**
  String get yourChangeHost;

  /// No description provided for @yourChangeCoHost.
  ///
  /// In en, this message translates to:
  /// **'You are assigned CO-HOST'**
  String get yourChangeCoHost;

  /// No description provided for @yourChangeCancelCoHost.
  ///
  /// In en, this message translates to:
  /// **'You are unassigned CO-HOST'**
  String get yourChangeCancelCoHost;

  /// No description provided for @localUserAssignedActiveSpeaker.
  ///
  /// In en, this message translates to:
  /// **'You are assigned active speaker'**
  String get localUserAssignedActiveSpeaker;

  /// No description provided for @localUserUnAssignedActiveSpeaker.
  ///
  /// In en, this message translates to:
  /// **'You are unassigned active speaker'**
  String get localUserUnAssignedActiveSpeaker;

  /// No description provided for @muteAudioAll.
  ///
  /// In en, this message translates to:
  /// **'Mute All'**
  String get muteAudioAll;

  /// No description provided for @muteAudioAllDialogTips.
  ///
  /// In en, this message translates to:
  /// **'All and new participants are muted'**
  String get muteAudioAllDialogTips;

  /// No description provided for @muteVideoAllDialogTips.
  ///
  /// In en, this message translates to:
  /// **'All and new participants have video turned off'**
  String get muteVideoAllDialogTips;

  /// No description provided for @unMuteAudioAll.
  ///
  /// In en, this message translates to:
  /// **'Unmute All'**
  String get unMuteAudioAll;

  /// No description provided for @muteAudio.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get muteAudio;

  /// No description provided for @unMuteAudio.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unMuteAudio;

  /// No description provided for @muteAllVideo.
  ///
  /// In en, this message translates to:
  /// **'Turn off videos'**
  String get muteAllVideo;

  /// No description provided for @unmuteAllVideo.
  ///
  /// In en, this message translates to:
  /// **'Turn on videos'**
  String get unmuteAllVideo;

  /// No description provided for @muteVideo.
  ///
  /// In en, this message translates to:
  /// **'Stop Video'**
  String get muteVideo;

  /// No description provided for @unMuteVideo.
  ///
  /// In en, this message translates to:
  /// **'Start Video'**
  String get unMuteVideo;

  /// No description provided for @muteAudioAndVideo.
  ///
  /// In en, this message translates to:
  /// **'Turn off audio and video'**
  String get muteAudioAndVideo;

  /// No description provided for @unmuteAudioAndVideo.
  ///
  /// In en, this message translates to:
  /// **'Turn on audio and video'**
  String get unmuteAudioAndVideo;

  /// No description provided for @screenShare.
  ///
  /// In en, this message translates to:
  /// **'Share Screen'**
  String get screenShare;

  /// No description provided for @hostStopShare.
  ///
  /// In en, this message translates to:
  /// **'Host stopped your screen sharing'**
  String get hostStopShare;

  /// No description provided for @hostStopWhiteboard.
  ///
  /// In en, this message translates to:
  /// **'Host stopped your whiteboard sharing'**
  String get hostStopWhiteboard;

  /// No description provided for @unScreenShare.
  ///
  /// In en, this message translates to:
  /// **'Stop Share'**
  String get unScreenShare;

  /// No description provided for @focusVideo.
  ///
  /// In en, this message translates to:
  /// **'Assign active speaker'**
  String get focusVideo;

  /// No description provided for @unFocusVideo.
  ///
  /// In en, this message translates to:
  /// **'Unassign active speaker'**
  String get unFocusVideo;

  /// No description provided for @changeHost.
  ///
  /// In en, this message translates to:
  /// **'Transfer HOST'**
  String get changeHost;

  /// No description provided for @changeHostTips.
  ///
  /// In en, this message translates to:
  /// **'Transfer HOST to '**
  String get changeHostTips;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @makeCoHost.
  ///
  /// In en, this message translates to:
  /// **'Assign CO-HOST'**
  String get makeCoHost;

  /// No description provided for @cancelCoHost.
  ///
  /// In en, this message translates to:
  /// **'Unassign CO_HOST'**
  String get cancelCoHost;

  /// No description provided for @renameTips.
  ///
  /// In en, this message translates to:
  /// **'Enter a new nickname'**
  String get renameTips;

  /// No description provided for @renameSuccess.
  ///
  /// In en, this message translates to:
  /// **'Nickname edited'**
  String get renameSuccess;

  /// No description provided for @renameFail.
  ///
  /// In en, this message translates to:
  /// **'Renaming failed'**
  String get renameFail;

  /// No description provided for @removeTips.
  ///
  /// In en, this message translates to:
  /// **'Remove '**
  String get removeTips;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @cannotRemoveSelf.
  ///
  /// In en, this message translates to:
  /// **'You cannot remove yourself'**
  String get cannotRemoveSelf;

  /// No description provided for @muteAudioFail.
  ///
  /// In en, this message translates to:
  /// **'Muting failed'**
  String get muteAudioFail;

  /// No description provided for @unMuteAudioFail.
  ///
  /// In en, this message translates to:
  /// **'Unmuting failed'**
  String get unMuteAudioFail;

  /// No description provided for @muteVideoFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to turn off camera'**
  String get muteVideoFail;

  /// No description provided for @unMuteVideoFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to turn on camera'**
  String get unMuteVideoFail;

  /// No description provided for @focusVideoFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to assign active speaker'**
  String get focusVideoFail;

  /// No description provided for @unFocusVideoFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to unassign active speaker'**
  String get unFocusVideoFail;

  /// No description provided for @handsUpDownFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to lower hand'**
  String get handsUpDownFail;

  /// No description provided for @changeHostFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to transfer HOST'**
  String get changeHostFail;

  /// No description provided for @removeMemberFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove the participant'**
  String get removeMemberFail;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get done;

  /// No description provided for @notify.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notify;

  /// No description provided for @hostKickedYou.
  ///
  /// In en, this message translates to:
  /// **'You are removed by HOST or switched to another device, you have left the meeting'**
  String get hostKickedYou;

  /// No description provided for @sure.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get sure;

  /// No description provided for @openCamera.
  ///
  /// In en, this message translates to:
  /// **'Cam On'**
  String get openCamera;

  /// No description provided for @openMicro.
  ///
  /// In en, this message translates to:
  /// **'Mic On'**
  String get openMicro;

  /// No description provided for @micphoneNotWorksDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone unavailable'**
  String get micphoneNotWorksDialogTitle;

  /// No description provided for @micphoneNotWorksDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'You are using the microphone. To speak, \n click Unmute and speak'**
  String get micphoneNotWorksDialogMessage;

  /// No description provided for @hostOpenCameraTips.
  ///
  /// In en, this message translates to:
  /// **'Host requests to turn on your camera. Turn on the camera？'**
  String get hostOpenCameraTips;

  /// No description provided for @hostOpenMicroTips.
  ///
  /// In en, this message translates to:
  /// **'Host requests to unmute your microphone. Unmute the microphone？'**
  String get hostOpenMicroTips;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get finish;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @muteAllAudioTip.
  ///
  /// In en, this message translates to:
  /// **'Allow participants to unmute'**
  String get muteAllAudioTip;

  /// No description provided for @muteAllVideoTip.
  ///
  /// In en, this message translates to:
  /// **'Allow participants to turn on videos'**
  String get muteAllVideoTip;

  /// No description provided for @muteAllAudioSuccess.
  ///
  /// In en, this message translates to:
  /// **'All participants are muted'**
  String get muteAllAudioSuccess;

  /// No description provided for @muteAllAudioFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to mute all participants'**
  String get muteAllAudioFail;

  /// No description provided for @muteAllVideoSuccess.
  ///
  /// In en, this message translates to:
  /// **'All participants have video turned off'**
  String get muteAllVideoSuccess;

  /// No description provided for @muteAllVideoFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to turn off videos of all participants'**
  String get muteAllVideoFail;

  /// No description provided for @unMuteAllAudioSuccess.
  ///
  /// In en, this message translates to:
  /// **'All participants are unmuted'**
  String get unMuteAllAudioSuccess;

  /// No description provided for @unMuteAllAudioFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to unmute all participants'**
  String get unMuteAllAudioFail;

  /// No description provided for @unMuteAllVideoSuccess.
  ///
  /// In en, this message translates to:
  /// **'All participants have video turned on'**
  String get unMuteAllVideoSuccess;

  /// No description provided for @unMuteAllVideoFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to turn on videos of all participants'**
  String get unMuteAllVideoFail;

  /// No description provided for @meetingHostMuteVideo.
  ///
  /// In en, this message translates to:
  /// **'Your video is turned off'**
  String get meetingHostMuteVideo;

  /// No description provided for @meetingHostMuteAudio.
  ///
  /// In en, this message translates to:
  /// **'You are muted'**
  String get meetingHostMuteAudio;

  /// No description provided for @meetingHostMuteAllAudio.
  ///
  /// In en, this message translates to:
  /// **'Host muted all participants'**
  String get meetingHostMuteAllAudio;

  /// No description provided for @meetingHostMuteAllVideo.
  ///
  /// In en, this message translates to:
  /// **'Host turned off videos of all participants'**
  String get meetingHostMuteAllVideo;

  /// No description provided for @muteAudioHandsUpOnTips.
  ///
  /// In en, this message translates to:
  /// **'You are unmuted and can speak now'**
  String get muteAudioHandsUpOnTips;

  /// No description provided for @shareOverLimit.
  ///
  /// In en, this message translates to:
  /// **'Someone is sharing screen, you can not share your screen'**
  String get shareOverLimit;

  /// No description provided for @noShareScreenPermission.
  ///
  /// In en, this message translates to:
  /// **'No screen sharing permission'**
  String get noShareScreenPermission;

  /// No description provided for @hasWhiteBoardShare.
  ///
  /// In en, this message translates to:
  /// **'Screen cannot be shared while whiteboard is being shared'**
  String get hasWhiteBoardShare;

  /// No description provided for @overRoleLimitCount.
  ///
  /// In en, this message translates to:
  /// **'The number of assigned roles exceeds the upper limit'**
  String get overRoleLimitCount;

  /// No description provided for @hasScreenShareShare.
  ///
  /// In en, this message translates to:
  /// **'Whiteboard cannot be shared while screen is being shared'**
  String get hasScreenShareShare;

  /// No description provided for @screenShareTips.
  ///
  /// In en, this message translates to:
  /// **'All content on your screen will be captured.'**
  String get screenShareTips;

  /// No description provided for @screenShareStopFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to stop screen sharing'**
  String get screenShareStopFail;

  /// No description provided for @whiteBoardShareStopFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to stop whiteboard sharing'**
  String get whiteBoardShareStopFail;

  /// No description provided for @whiteBoardShareStartFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to start whiteboard sharing'**
  String get whiteBoardShareStartFail;

  /// No description provided for @screenShareStartFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to start screen sharing'**
  String get screenShareStartFail;

  /// No description provided for @screenShareLocalTips.
  ///
  /// In en, this message translates to:
  /// **' is Sharing screen'**
  String get screenShareLocalTips;

  /// No description provided for @screenShareSuffix.
  ///
  /// In en, this message translates to:
  /// **' screen'**
  String get screenShareSuffix;

  /// No description provided for @screenShareInteractionTip.
  ///
  /// In en, this message translates to:
  /// **'Pinch with 2 fingers to adjust zoom'**
  String get screenShareInteractionTip;

  /// No description provided for @whiteBoardInteractionTip.
  ///
  /// In en, this message translates to:
  /// **'You are granted the whiteboard permission'**
  String get whiteBoardInteractionTip;

  /// No description provided for @undoWhiteBoardInteractionTip.
  ///
  /// In en, this message translates to:
  /// **'You are revoked the whiteboard permission'**
  String get undoWhiteBoardInteractionTip;

  /// No description provided for @speakingPrefix.
  ///
  /// In en, this message translates to:
  /// **'Speaking: '**
  String get speakingPrefix;

  /// No description provided for @iKnow.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get iKnow;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'me'**
  String get me;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @virtualBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get virtualBackground;

  /// No description provided for @virtualBackgroundImageNotExist.
  ///
  /// In en, this message translates to:
  /// **'Custom background image does not exist'**
  String get virtualBackgroundImageNotExist;

  /// No description provided for @virtualBackgroundImageFormatNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Invalid background image format'**
  String get virtualBackgroundImageFormatNotSupported;

  /// No description provided for @virtualBackgroundImageDeviceNotSupported.
  ///
  /// In en, this message translates to:
  /// **'The device is not supported'**
  String get virtualBackgroundImageDeviceNotSupported;

  /// No description provided for @virtualBackgroundImageLarge.
  ///
  /// In en, this message translates to:
  /// **'The custom background image exceeds 5MB in size'**
  String get virtualBackgroundImageLarge;

  /// No description provided for @virtualBackgroundImageMax.
  ///
  /// In en, this message translates to:
  /// **'The custom background images exceed the maximum number'**
  String get virtualBackgroundImageMax;

  /// No description provided for @closeWhiteBoard.
  ///
  /// In en, this message translates to:
  /// **'Stop Whiteboard'**
  String get closeWhiteBoard;

  /// No description provided for @lockMeetingByHost.
  ///
  /// In en, this message translates to:
  /// **'The meeting is locked. New participants cannot join the meeting'**
  String get lockMeetingByHost;

  /// No description provided for @lockMeetingByHostFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to lock the meeting'**
  String get lockMeetingByHostFail;

  /// No description provided for @unLockMeetingByHost.
  ///
  /// In en, this message translates to:
  /// **'The meeting is unlocked. New participants can join the meeting'**
  String get unLockMeetingByHost;

  /// No description provided for @unLockMeetingByHostFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to unlock the meeting'**
  String get unLockMeetingByHostFail;

  /// No description provided for @lockMeeting.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get lockMeeting;

  /// No description provided for @inputMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Entering...'**
  String get inputMessageHint;

  /// No description provided for @cannotSendBlankLetter.
  ///
  /// In en, this message translates to:
  /// **'Unable to send empty messages'**
  String get cannotSendBlankLetter;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @searchMember.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchMember;

  /// No description provided for @enterChatRoomFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to join the chat room'**
  String get enterChatRoomFail;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get newMessage;

  /// No description provided for @unsupportedFileExtension.
  ///
  /// In en, this message translates to:
  /// **'Unsupported file'**
  String get unsupportedFileExtension;

  /// No description provided for @fileSizeExceedTheLimit.
  ///
  /// In en, this message translates to:
  /// **'File size cannot exceed 200MB'**
  String get fileSizeExceedTheLimit;

  /// No description provided for @imageSizeExceedTheLimit.
  ///
  /// In en, this message translates to:
  /// **'Image size cannot exceed 20MB'**
  String get imageSizeExceedTheLimit;

  /// No description provided for @imageMessageTip.
  ///
  /// In en, this message translates to:
  /// **'[Image]'**
  String get imageMessageTip;

  /// No description provided for @fileMessageTip.
  ///
  /// In en, this message translates to:
  /// **'[File]'**
  String get fileMessageTip;

  /// No description provided for @saveToGallerySuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved to Album'**
  String get saveToGallerySuccess;

  /// No description provided for @saveToGalleryFail.
  ///
  /// In en, this message translates to:
  /// **'Operation failed'**
  String get saveToGalleryFail;

  /// No description provided for @saveToGalleryFailNoPermission.
  ///
  /// In en, this message translates to:
  /// **'No permission'**
  String get saveToGalleryFailNoPermission;

  /// No description provided for @openFileFail.
  ///
  /// In en, this message translates to:
  /// **'Opening file failed'**
  String get openFileFail;

  /// No description provided for @openFileFailNoPermission.
  ///
  /// In en, this message translates to:
  /// **'Opening file failed: no permission'**
  String get openFileFailNoPermission;

  /// No description provided for @openFileFailFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Opening file failed: no file exists'**
  String get openFileFailFileNotFound;

  /// No description provided for @openFileFailAppNotFound.
  ///
  /// In en, this message translates to:
  /// **'Opening file failed: no app installed to open the file'**
  String get openFileFailAppNotFound;

  /// No description provided for @meetingPassword.
  ///
  /// In en, this message translates to:
  /// **'Meeting Password'**
  String get meetingPassword;

  /// No description provided for @inputMeetingPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter the meeting password'**
  String get inputMeetingPassword;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect code'**
  String get wrongPassword;

  /// No description provided for @headsetState.
  ///
  /// In en, this message translates to:
  /// **'You are using the earphone'**
  String get headsetState;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copySuccess.
  ///
  /// In en, this message translates to:
  /// **'Copy succeeded'**
  String get copySuccess;

  /// No description provided for @disableLiveAuthLevel.
  ///
  /// In en, this message translates to:
  /// **'Editing live streaming permission is not allowed during streaming'**
  String get disableLiveAuthLevel;

  /// No description provided for @host.
  ///
  /// In en, this message translates to:
  /// **'HOST'**
  String get host;

  /// No description provided for @coHost.
  ///
  /// In en, this message translates to:
  /// **'CO_HOST'**
  String get coHost;

  /// No description provided for @meetingInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'The meeting is being encrypted and protected'**
  String get meetingInfoDesc;

  /// No description provided for @networkUnavailableCloseFail.
  ///
  /// In en, this message translates to:
  /// **'Ending meeting failed due to the network error'**
  String get networkUnavailableCloseFail;

  /// No description provided for @muteAllHandsUpTips.
  ///
  /// In en, this message translates to:
  /// **'The host has muted all participants. You can raise your hand'**
  String get muteAllHandsUpTips;

  /// No description provided for @muteAllVideoHandsUpTips.
  ///
  /// In en, this message translates to:
  /// **'The host has turned off all videos. You can raise your hand'**
  String get muteAllVideoHandsUpTips;

  /// No description provided for @alreadyHandsUpTips.
  ///
  /// In en, this message translates to:
  /// **'You are raising hand, waiting for response'**
  String get alreadyHandsUpTips;

  /// No description provided for @handsUpApply.
  ///
  /// In en, this message translates to:
  /// **'Raise hand'**
  String get handsUpApply;

  /// No description provided for @cancelHandsUp.
  ///
  /// In en, this message translates to:
  /// **'Lower hand'**
  String get cancelHandsUp;

  /// No description provided for @cancelHandsUpTips.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to lower hand?'**
  String get cancelHandsUpTips;

  /// No description provided for @handsUpDown.
  ///
  /// In en, this message translates to:
  /// **'Lower hand'**
  String get handsUpDown;

  /// No description provided for @whiteBoardInteract.
  ///
  /// In en, this message translates to:
  /// **'Grant the whiteboard permission'**
  String get whiteBoardInteract;

  /// No description provided for @whiteBoardInteractFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to grant the whiteboard permission'**
  String get whiteBoardInteractFail;

  /// No description provided for @undoWhiteBoardInteract.
  ///
  /// In en, this message translates to:
  /// **'Revoke the whiteboard permission'**
  String get undoWhiteBoardInteract;

  /// No description provided for @undoWhiteBoardInteractFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to revoke the whiteboard permission'**
  String get undoWhiteBoardInteractFail;

  /// No description provided for @inHandsUp.
  ///
  /// In en, this message translates to:
  /// **'Raising'**
  String get inHandsUp;

  /// No description provided for @handsUpFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to raise hand'**
  String get handsUpFail;

  /// No description provided for @handsUpSuccess.
  ///
  /// In en, this message translates to:
  /// **'You are raising hand, waiting for response'**
  String get handsUpSuccess;

  /// No description provided for @cancelHandsUpFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to lower hand'**
  String get cancelHandsUpFail;

  /// No description provided for @hostRejectAudioHandsUp.
  ///
  /// In en, this message translates to:
  /// **'The host rejected your request'**
  String get hostRejectAudioHandsUp;

  /// No description provided for @sipTip.
  ///
  /// In en, this message translates to:
  /// **'SIP'**
  String get sipTip;

  /// No description provided for @meetingInviteUrl.
  ///
  /// In en, this message translates to:
  /// **'Meeting URL'**
  String get meetingInviteUrl;

  /// No description provided for @meetingInvitePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Participants'**
  String get meetingInvitePageTitle;

  /// No description provided for @sipNumber.
  ///
  /// In en, this message translates to:
  /// **'SIP Call'**
  String get sipNumber;

  /// No description provided for @sipHost.
  ///
  /// In en, this message translates to:
  /// **'SIP Address'**
  String get sipHost;

  /// No description provided for @inviteListTitle.
  ///
  /// In en, this message translates to:
  /// **'Invitation List'**
  String get inviteListTitle;

  /// No description provided for @invitationSendSuccess.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent'**
  String get invitationSendSuccess;

  /// No description provided for @invitationSendFail.
  ///
  /// In en, this message translates to:
  /// **'Invitation failed'**
  String get invitationSendFail;

  /// No description provided for @meetingLive.
  ///
  /// In en, this message translates to:
  /// **'Live Meeting'**
  String get meetingLive;

  /// No description provided for @meetingLiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get meetingLiveTitle;

  /// No description provided for @meetingLiveUrl.
  ///
  /// In en, this message translates to:
  /// **'Live URL'**
  String get meetingLiveUrl;

  /// No description provided for @pleaseInputLivePassword.
  ///
  /// In en, this message translates to:
  /// **'Enter the live code'**
  String get pleaseInputLivePassword;

  /// No description provided for @pleaseInputLivePasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a 6-digit code'**
  String get pleaseInputLivePasswordHint;

  /// No description provided for @liveInteraction.
  ///
  /// In en, this message translates to:
  /// **'Interaction'**
  String get liveInteraction;

  /// No description provided for @liveInteractionTips.
  ///
  /// In en, this message translates to:
  /// **'If enabled, messaging in the meeting room and live room is visible'**
  String get liveInteractionTips;

  /// No description provided for @liveLevel.
  ///
  /// In en, this message translates to:
  /// **'Only staff participants can view'**
  String get liveLevel;

  /// No description provided for @liveLevelTip.
  ///
  /// In en, this message translates to:
  /// **'Non-staff participants are unable to view the live if enabled'**
  String get liveLevelTip;

  /// No description provided for @liveViewSetting.
  ///
  /// In en, this message translates to:
  /// **'View Settings'**
  String get liveViewSetting;

  /// No description provided for @liveViewSettingChange.
  ///
  /// In en, this message translates to:
  /// **'The view is changed'**
  String get liveViewSettingChange;

  /// No description provided for @liveViewPreviewTips.
  ///
  /// In en, this message translates to:
  /// **'Live streaming preview'**
  String get liveViewPreviewTips;

  /// No description provided for @liveViewPreviewDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure the view settings'**
  String get liveViewPreviewDesc;

  /// No description provided for @liveStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get liveStart;

  /// No description provided for @liveUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get liveUpdate;

  /// No description provided for @liveStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get liveStop;

  /// No description provided for @liveGalleryView.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get liveGalleryView;

  /// No description provided for @liveFocusView.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get liveFocusView;

  /// No description provided for @liveScreenShareView.
  ///
  /// In en, this message translates to:
  /// **'Screen Sharing'**
  String get liveScreenShareView;

  /// No description provided for @liveChooseView.
  ///
  /// In en, this message translates to:
  /// **'View Mode'**
  String get liveChooseView;

  /// No description provided for @liveChooseCountTips.
  ///
  /// In en, this message translates to:
  /// **'Select up to 4 participants'**
  String get liveChooseCountTips;

  /// No description provided for @liveStartFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to start live streaming, try again later'**
  String get liveStartFail;

  /// No description provided for @liveStartSuccess.
  ///
  /// In en, this message translates to:
  /// **'Live streaming started'**
  String get liveStartSuccess;

  /// No description provided for @livePickerCount.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get livePickerCount;

  /// No description provided for @livePickerCountPrefix.
  ///
  /// In en, this message translates to:
  /// **'people'**
  String get livePickerCountPrefix;

  /// No description provided for @liveUpdateFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to update the live streaming, try again later'**
  String get liveUpdateFail;

  /// No description provided for @liveUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Live streaming updated'**
  String get liveUpdateSuccess;

  /// No description provided for @liveStopFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to stop the live streaming, try again later'**
  String get liveStopFail;

  /// No description provided for @liveStopSuccess.
  ///
  /// In en, this message translates to:
  /// **'Live streaming stopped'**
  String get liveStopSuccess;

  /// No description provided for @livePassword.
  ///
  /// In en, this message translates to:
  /// **'Live code'**
  String get livePassword;

  /// No description provided for @editWhiteBoard.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editWhiteBoard;

  /// No description provided for @packUpWhiteBoard.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get packUpWhiteBoard;

  /// No description provided for @noAuthorityWhiteBoard.
  ///
  /// In en, this message translates to:
  /// **'Whiteboard is unactivated. contact sales for activating the service'**
  String get noAuthorityWhiteBoard;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get ok;

  /// No description provided for @removedByHost.
  ///
  /// In en, this message translates to:
  /// **'You are removed'**
  String get removedByHost;

  /// No description provided for @closeByHost.
  ///
  /// In en, this message translates to:
  /// **'Meeting ended'**
  String get closeByHost;

  /// No description provided for @loginOnOtherDevice.
  ///
  /// In en, this message translates to:
  /// **'Switched to another device'**
  String get loginOnOtherDevice;

  /// No description provided for @authInfoExpired.
  ///
  /// In en, this message translates to:
  /// **'Network error, please check your network connection and rejoin the meeting'**
  String get authInfoExpired;

  /// No description provided for @syncDataError.
  ///
  /// In en, this message translates to:
  /// **'Failed to sync the room information'**
  String get syncDataError;

  /// No description provided for @leaveMeetingBySelf.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveMeetingBySelf;

  /// No description provided for @meetingClosed.
  ///
  /// In en, this message translates to:
  /// **'Meeting is closed'**
  String get meetingClosed;

  /// No description provided for @connectFail.
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get connectFail;

  /// No description provided for @joinTimeout.
  ///
  /// In en, this message translates to:
  /// **'Joining meeting timeout, try again later'**
  String get joinTimeout;

  /// No description provided for @endOfLife.
  ///
  /// In en, this message translates to:
  /// **'Meeting is closed because the meeting duration reached the upper limit. '**
  String get endOfLife;

  /// No description provided for @endMeetingTip.
  ///
  /// In en, this message translates to:
  /// **'Remaining '**
  String get endMeetingTip;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get min;

  /// No description provided for @reuseIMNotSupportAnonymousJoinMeeting.
  ///
  /// In en, this message translates to:
  /// **'IM reuse does not support anonymous login'**
  String get reuseIMNotSupportAnonymousJoinMeeting;

  /// No description provided for @inviteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Meeting Invite'**
  String get inviteDialogTitle;

  /// No description provided for @inviteContentCopySuccess.
  ///
  /// In en, this message translates to:
  /// **'Meeting invitation copied'**
  String get inviteContentCopySuccess;

  /// No description provided for @inviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite your to join the meeting \n\n'**
  String get inviteTitle;

  /// No description provided for @meetingSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject: '**
  String get meetingSubject;

  /// No description provided for @meetingTime.
  ///
  /// In en, this message translates to:
  /// **'Time: '**
  String get meetingTime;

  /// No description provided for @meetingNum.
  ///
  /// In en, this message translates to:
  /// **'Meeting number: '**
  String get meetingNum;

  /// No description provided for @shortMeetingNum.
  ///
  /// In en, this message translates to:
  /// **'Short Meeting number: '**
  String get shortMeetingNum;

  /// No description provided for @invitationUrl.
  ///
  /// In en, this message translates to:
  /// **'Meeting URL: '**
  String get invitationUrl;

  /// No description provided for @meetingPwd.
  ///
  /// In en, this message translates to:
  /// **'Meeting Password: '**
  String get meetingPwd;

  /// No description provided for @copyInvite.
  ///
  /// In en, this message translates to:
  /// **'Copy invitation'**
  String get copyInvite;

  /// No description provided for @internalSpecial.
  ///
  /// In en, this message translates to:
  /// **'Internal'**
  String get internalSpecial;

  /// No description provided for @notWork.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get notWork;

  /// No description provided for @needPermissionTipsFirst.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get needPermissionTipsFirst;

  /// No description provided for @needPermissionTipsTail.
  ///
  /// In en, this message translates to:
  /// **' to access your '**
  String get needPermissionTipsTail;

  /// No description provided for @funcNeed.
  ///
  /// In en, this message translates to:
  /// **'The feature requires '**
  String get funcNeed;

  /// No description provided for @toSetUp.
  ///
  /// In en, this message translates to:
  /// **'Go to'**
  String get toSetUp;

  /// No description provided for @permissionTips.
  ///
  /// In en, this message translates to:
  /// **'Permission'**
  String get permissionTips;

  /// No description provided for @cameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraPermission;

  /// No description provided for @microphonePermission.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get microphonePermission;

  /// No description provided for @bluetoothPermission.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth'**
  String get bluetoothPermission;

  /// No description provided for @phoneStatePermission.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneStatePermission;

  /// No description provided for @noPermission.
  ///
  /// In en, this message translates to:
  /// **'No permission'**
  String get noPermission;

  /// No description provided for @permissionRationalePrefix.
  ///
  /// In en, this message translates to:
  /// **'To make audio and video call, you must request '**
  String get permissionRationalePrefix;

  /// No description provided for @permissionRationaleSuffixAudio.
  ///
  /// In en, this message translates to:
  /// **' permission for audio calling'**
  String get permissionRationaleSuffixAudio;

  /// No description provided for @permissionRationaleSuffixVideo.
  ///
  /// In en, this message translates to:
  /// **' permission for video calling'**
  String get permissionRationaleSuffixVideo;

  /// No description provided for @menuTitleParticipants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get menuTitleParticipants;

  /// No description provided for @menuTitleManagerParticipants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get menuTitleManagerParticipants;

  /// No description provided for @menuTitleInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get menuTitleInvite;

  /// No description provided for @menuTitleChatroom.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get menuTitleChatroom;

  /// No description provided for @menuTitleShareWhiteboard.
  ///
  /// In en, this message translates to:
  /// **'Whiteboard'**
  String get menuTitleShareWhiteboard;

  /// No description provided for @menuTitleCloseWhiteboard.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get menuTitleCloseWhiteboard;

  /// No description provided for @notificationContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Video Meeting'**
  String get notificationContentTitle;

  /// No description provided for @notificationContentText.
  ///
  /// In en, this message translates to:
  /// **'Meeting is ongoing'**
  String get notificationContentText;

  /// No description provided for @notificationContentTicker.
  ///
  /// In en, this message translates to:
  /// **'Video meeting'**
  String get notificationContentTicker;

  /// No description provided for @notificationChannelId.
  ///
  /// In en, this message translates to:
  /// **'ne_meeting_channel'**
  String get notificationChannelId;

  /// No description provided for @notificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'Video meeting notification'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Video meeting notification'**
  String get notificationChannelDesc;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @nothing.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get nothing;

  /// No description provided for @virtualBackgroundSelectTip.
  ///
  /// In en, this message translates to:
  /// **'Effective when the image is selected'**
  String get virtualBackgroundSelectTip;

  /// No description provided for @onUserJoinMeeting.
  ///
  /// In en, this message translates to:
  /// **' join the meeting'**
  String get onUserJoinMeeting;

  /// No description provided for @onUserLeaveMeeting.
  ///
  /// In en, this message translates to:
  /// **' leave'**
  String get onUserLeaveMeeting;

  /// No description provided for @userHasBeenAssignCoHostRole.
  ///
  /// In en, this message translates to:
  /// **' has been assigned CO-HOST'**
  String get userHasBeenAssignCoHostRole;

  /// No description provided for @userHasBeenRevokeCoHostRole.
  ///
  /// In en, this message translates to:
  /// **' has been unassigned CO-HOST'**
  String get userHasBeenRevokeCoHostRole;

  /// No description provided for @isInCall.
  ///
  /// In en, this message translates to:
  /// **'Answering the phone now'**
  String get isInCall;

  /// No description provided for @networkConnectionGood.
  ///
  /// In en, this message translates to:
  /// **'Network connection is good'**
  String get networkConnectionGood;

  /// No description provided for @networkConnectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'Network connection is general'**
  String get networkConnectionGeneral;

  /// No description provided for @networkConnectionPoor.
  ///
  /// In en, this message translates to:
  /// **'Network connection is poor'**
  String get networkConnectionPoor;

  /// No description provided for @localLatency.
  ///
  /// In en, this message translates to:
  /// **'Latency'**
  String get localLatency;

  /// No description provided for @packetLossRate.
  ///
  /// In en, this message translates to:
  /// **'Packet Loss Rate'**
  String get packetLossRate;

  /// No description provided for @startAudioShare.
  ///
  /// In en, this message translates to:
  /// **'Start Sharing system audio'**
  String get startAudioShare;

  /// No description provided for @stopAudioShare.
  ///
  /// In en, this message translates to:
  /// **'Stop sharing system audio'**
  String get stopAudioShare;

  /// No description provided for @switchFcusView.
  ///
  /// In en, this message translates to:
  /// **'Switch to Focus view'**
  String get switchFcusView;

  /// No description provided for @switchGalleryView.
  ///
  /// In en, this message translates to:
  /// **'Switch to Gallery view'**
  String get switchGalleryView;

  /// No description provided for @noSupportSwitch.
  ///
  /// In en, this message translates to:
  /// **'iPad does not support switching modes'**
  String get noSupportSwitch;

  /// No description provided for @funcNotAvailableWhenInCallState.
  ///
  /// In en, this message translates to:
  /// **'Cannot use this feature while on a call'**
  String get funcNotAvailableWhenInCallState;
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
