// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'meeting_ui_kit_localizations.dart';

/// The translations for English (`en`).
class NEMeetingUIKitLocalizationsEn extends NEMeetingUIKitLocalizations {
  NEMeetingUIKitLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get globalAppName => 'NetEase Meeting';

  @override
  String get globalDelete => 'delete';

  @override
  String get globalNothing => 'None';

  @override
  String get globalCancel => 'Cancel';

  @override
  String get globalAdd => 'Add';

  @override
  String get globalClose => 'Close';

  @override
  String get globalOpen => 'Open';

  @override
  String get globalFail => 'Failed';

  @override
  String get globalYes => 'Yes';

  @override
  String get globalNo => 'No';

  @override
  String get globalSave => 'Save';

  @override
  String get globalDone => 'Complete';

  @override
  String get globalNotify => 'Notification';

  @override
  String get globalSure => 'OK';

  @override
  String get globalIKnow => 'Got it';

  @override
  String get globalCopy => 'Copy';

  @override
  String get globalCopySuccess => 'Copy succeeded';

  @override
  String get globalEdit => 'Edit';

  @override
  String get globalGotIt => 'Got it';

  @override
  String globalNotWork(Object permissionName) {
    return 'Unable to use $permissionName';
  }

  @override
  String globalNeedPermissionTips(Object permissionName, Object title) {
    return 'The function requires $permissionName,  allow $title to access your $permissionName permission.';
  }

  @override
  String get globalToSetUp => 'Go to';

  @override
  String get globalNoPermission => 'No permission';

  @override
  String get globalDays => 'days';

  @override
  String get globalHours => 'hours';

  @override
  String get globalMinutes => 'minutes';

  @override
  String get globalViewMessage => 'View Message';

  @override
  String get globalNoLongerRemind => 'Don\'t Remind Me Again';

  @override
  String get globalOperationFail => 'Operation failed';

  @override
  String get globalOperationNotSupportedInMeeting =>
      'This operation is not supported in the meeting.';

  @override
  String get globalClear => 'Clear';

  @override
  String get globalSearch => 'Search';

  @override
  String get globalReject => 'Reject';

  @override
  String get globalCancelled => 'cancelled';

  @override
  String get globalClearAll => 'Clear all';

  @override
  String get globalStart => 'Turn on';

  @override
  String get globalTips => 'Tips';

  @override
  String get globalNetworkUnavailableCheck =>
      'Network connection failed, please check your network connection!';

  @override
  String get globalSubmit => 'Submit';

  @override
  String get globalGotoSettings => 'Go to Settings';

  @override
  String get globalPhotosPermissionRationale =>
      'Apply for permission to upload pictures or modify your profile picture';

  @override
  String get globalPhotosPermission => 'Albums unavailable';

  @override
  String get globalSend => 'Send';

  @override
  String get globalPause => 'Pause';

  @override
  String get meetingBeauty => 'Beauty';

  @override
  String get meetingBeautyLevel => 'Level';

  @override
  String get meetingJoinTips => 'Joining...';

  @override
  String get meetingQuit => 'End';

  @override
  String get meetingDefalutTitle => 'Video Meeting';

  @override
  String get meetingJoinFail => 'Failed to join the meeting';

  @override
  String get meetingHostKickedYou =>
      'You are removed by HOST or switched to another device, you have left the meeting';

  @override
  String get meetingMicphoneNotWorksDialogTitle => 'Microphone unavailable';

  @override
  String get meetingMicphoneNotWorksDialogMessage =>
      'You are using the microphone. To speak,\n click Unmute and speak';

  @override
  String get meetingFinish => 'End';

  @override
  String get meetingLeave => 'Leave';

  @override
  String get meetingLeaveFull => 'Leave';

  @override
  String get meetingSpeakingPrefix => 'Speaking:';

  @override
  String get meetingLockMeetingByHost =>
      'The meeting is locked. New participants cannot join the meeting';

  @override
  String get meetingLockMeetingByHostFail => 'Failed to lock the meeting';

  @override
  String get meetingUnLockMeetingByHost =>
      'The meeting is unlocked. New participants can join the meeting';

  @override
  String get meetingUnLockMeetingByHostFail => 'Failed to unlock the meeting';

  @override
  String get meetingLock => 'Lock';

  @override
  String get meetingMore => 'More';

  @override
  String get meetingPassword => 'Meeting Password';

  @override
  String get meetingEnterPassword => 'Enter the meeting password';

  @override
  String get meetingWrongPassword => 'Incorrect code';

  @override
  String get meetingNum => 'Meeting ID';

  @override
  String get meetingShortNum => 'Short Meeting ID';

  @override
  String get meetingInfoDesc => 'The meeting is being encrypted and protected';

  @override
  String get meetingAlreadyHandsUpTips =>
      'You are raising hand, waiting for response';

  @override
  String get meetingHandsUpApply => 'Raise hand';

  @override
  String get meetingCancelHandsUp => 'Lower hand';

  @override
  String get meetingCancelHandsUpConfirm =>
      'Are you sure you want to lower hand?';

  @override
  String get meetingHandsUpDown => 'Lower hand';

  @override
  String get meetingInHandsUp => 'Raising hand';

  @override
  String get meetingHandsUpFail => 'Failed to raise hand';

  @override
  String get meetingHandsUpSuccess =>
      'You are raising hand, waiting for response';

  @override
  String get meetingCancelHandsUpFail => 'Failed to lower hand';

  @override
  String get meetingHostRejectAudioHandsUp => 'The host rejected your request';

  @override
  String get meetingSip => 'SIP';

  @override
  String get meetingInviteUrl => 'Meeting URL';

  @override
  String get meetingInvitePageTitle => 'Add Participants';

  @override
  String get meetingSipNumber => 'SIP Call';

  @override
  String get meetingMobileDialInTitle => 'Phone Call';

  @override
  String meetingMobileDialInMsg(Object phoneNumber) {
    return 'Dial $phoneNumber';
  }

  @override
  String meetingInputSipNumber(Object sipNumber) {
    return 'Enter $sipNumber to join the meeting';
  }

  @override
  String get meetingSipHost => 'SIP Address';

  @override
  String get meetingInvite => 'Invite';

  @override
  String get meetingInviteListTitle => 'Invitation List';

  @override
  String get meetingInvitationSendSuccess => 'Invitation sent';

  @override
  String get meetingInvitationSendFail => 'Invitation failed';

  @override
  String get meetingRemovedByHost => 'You are removed';

  @override
  String get meetingCloseByHost => 'Meeting ended';

  @override
  String get meetingWasInterrupted => 'The meeting was interrupted';

  @override
  String get meetingSyncDataError => 'Failed to sync the room information';

  @override
  String get meetingLeaveMeetingBySelf => 'Leave';

  @override
  String get meetingClosed => 'Meeting is closed';

  @override
  String get meetingConnectFail => 'Connection failed';

  @override
  String get meetingJoinTimeout => 'Joining meeting timeout, try again later';

  @override
  String get meetingEndOfLife =>
      'Meeting is closed because the meeting duration reached the upper limit.';

  @override
  String get meetingEndTip => 'Remaining';

  @override
  String get meetingReuseIMNotSupportAnonymousJoinMeeting =>
      'IM reuse does not support anonymous login';

  @override
  String get meetingInviteDialogTitle => 'Meeting Invite';

  @override
  String get meetingInviteContentCopySuccess => 'Meeting invitation copied';

  @override
  String get meetingInviteTitle => 'Invite your to join the meeting';

  @override
  String get meetingSubject => 'Subject';

  @override
  String get meetingTime => 'Time';

  @override
  String get meetingInvitationUrl => 'Meeting URL';

  @override
  String get meetingCopyInvite => 'Copy invitation';

  @override
  String get meetingInternalSpecial => 'Internal';

  @override
  String get loginOnOtherDevice => 'Switched to another device';

  @override
  String get authInfoExpired => 'Authorization expired, please log in again';

  @override
  String get meetingCamera => 'Camera';

  @override
  String get meetingMicrophone => 'Microphone';

  @override
  String get meetingBluetooth => 'Bluetooth';

  @override
  String get meetingPhoneState => 'Phone';

  @override
  String meetingNeedRationaleAudioPermission(Object permission) {
    return 'Audio-video meeting needs to apply for $permission permission for audio communication.';
  }

  @override
  String meetingNeedRationaleVideoPermission(Object permission) {
    return 'Audio-video meeting needs to apply for $permission permission for video communication.';
  }

  @override
  String get meetingNeedRationalePhotoPermission =>
      'Need to apply for photo permission for the virtual background (adding and changing background images) function in the meeting';

  @override
  String get meetingDisconnectAudio => 'Disconnect Audio';

  @override
  String get meetingReconnectAudio => 'Audio';

  @override
  String get meetingDisconnectAudioTips =>
      'To turn off the conference sound, you can click on \"Disconnect Audio\" in More';

  @override
  String get meetingNotificationContentTitle => 'Video Meeting';

  @override
  String get meetingNotificationContentText => 'Meeting is ongoing';

  @override
  String get meetingNotificationContentTicker => 'Video meeting';

  @override
  String get meetingNotificationChannelId => 'ne_meeting_channel';

  @override
  String get meetingNotificationChannelName => 'Video meeting notification';

  @override
  String get meetingNotificationChannelDesc => 'Video meeting notification';

  @override
  String meetingUserJoin(Object userName) {
    return '$userName joined the meeting.';
  }

  @override
  String meetingUserLeave(Object userName) {
    return '$userName left the meeting.';
  }

  @override
  String get meetingStartAudioShare => 'Start Sharing system audio';

  @override
  String get meetingStopAudioShare => 'Stop sharing system audio';

  @override
  String get meetingSwitchFcusView => 'Switch to Focus view';

  @override
  String get meetingSwitchGalleryView => 'Switch to Gallery view';

  @override
  String get meetingNoSupportSwitch =>
      'This device does not support switching modes';

  @override
  String get meetingFuncNotAvailableWhenInCallState =>
      'Cannot use this feature while on a call';

  @override
  String get meetingRejoining => 'Rejoining';

  @override
  String get meetingSecurity => 'Security';

  @override
  String get meetingManagement => 'Meeting Management';

  @override
  String get meetingWatermark => 'Meeting Watermark';

  @override
  String get meetingBeKickedOutByHost =>
      'The host has removed you from the meeting';

  @override
  String get meetingBeKickedOut => 'Removed from the meeting';

  @override
  String get meetingClickOkToClose =>
      'Click OK and the page closes automatically';

  @override
  String get meetingLeaveConfirm =>
      'Are you sure you want to leave this meeting?';

  @override
  String get meetingWatermarkEnabled => 'You have enabled watermark';

  @override
  String get meetingWatermarkDisabled => 'You have disabled watermark';

  @override
  String get meetingInfo => 'Meeting information';

  @override
  String get meetingNickname => 'Nickname';

  @override
  String get meetingHostChangeYourMeetingName =>
      'The host has changed your name';

  @override
  String get meetingIsInCall => 'Answering the phone now';

  @override
  String get meetingPinView => 'Lock video';

  @override
  String meetingPinViewTip(Object corner) {
    return 'The video is locked, tap unlock at $corner to unlock';
  }

  @override
  String get meetingTopLeftCorner => 'top left corner';

  @override
  String get meetingBottomRightCorner => 'bottom right corner';

  @override
  String get meetingUnpinView => 'Unlock video';

  @override
  String get meetingUnpinViewTip => 'Video unlocked';

  @override
  String get meetingUnpin => 'Unlock';

  @override
  String get meetingPinFailedByFocus =>
      'The host has set the focus video, and this operation is not supported.';

  @override
  String get meetingBlacklist => 'Meeting Blacklist';

  @override
  String get meetingBlacklistDetail =>
      'Once turned on, users marked \"No Re-joining\" will not be able to join the meeting.';

  @override
  String get unableMeetingBlacklistTitle =>
      'Are you sure to turn off the meeting blacklist?';

  @override
  String get unableMeetingBlacklistTip =>
      'After turned off, the blacklist will be cleared, and users marked \"No Re-joining\" can re-join the meeting.';

  @override
  String get meetingNotAllowedToRejoin =>
      'Not allowed to join the meeting again.';

  @override
  String get meetingAllowMembersTo => 'Allow participants to';

  @override
  String get meetingChat => 'Group and Private Chats';

  @override
  String get meetingChatEnabled => 'Chat has been enabled.';

  @override
  String get meetingChatDisabled => 'Chat has been disabled.';

  @override
  String get meetingReclaimHost => 'Reclaim Host';

  @override
  String get meetingReclaimHostCancel => 'Not Now';

  @override
  String meetingReclaimHostTip(Object user) {
    return '$user is the host now, and withdrawing host privileges may interrupt screen sharing, etc';
  }

  @override
  String meetingUserIsNowTheHost(Object user) {
    return '$user is the host now.';
  }

  @override
  String get meetingGuestJoin => 'Guest Mode';

  @override
  String get meetingGuestJoinSecurityNotice =>
      'Guest mode enabled, please pay attention to the security of meeting';

  @override
  String get meetingGuestJoinEnableTip =>
      'External visitors will be allowed to attend the meeting when enabled.';

  @override
  String get meetingGuestJoinEnabled => 'Guest mode has been enabled';

  @override
  String get meetingGuestJoinDisabled => 'Guest mode  has been closed';

  @override
  String get meetingGuestJoinConfirm => 'Are you sure to enable guest mode?';

  @override
  String get meetingGuestJoinConfirmTip =>
      'External visitors will be allowed to attend the meeting when enabled.';

  @override
  String get meetingSearchNotFound => 'No search results are available';

  @override
  String get meetingGuestJoinSupported =>
      'External visitors can join this meeting';

  @override
  String get meetingGuest => 'Guest';

  @override
  String get meetingGuestJoinNamePlaceholder => 'Enter the meeting nickname';

  @override
  String meetingAppInvite(Object userName) {
    return '$userName invites you to join';
  }

  @override
  String get meetingAudioJoinAction => 'Voice';

  @override
  String get meetingVideoJoinAction => 'Video';

  @override
  String get meetingMaxMembers => 'Maximum participants';

  @override
  String get speakerVolumeMuteTips =>
      'The speaker device is silent. Please check whether the system speakers have been unmuted and adjusted to the appropriate volume.';

  @override
  String get meetingAnnotationPermissionEnabled => 'Annotate';

  @override
  String get meetingMemberMaxTip =>
      'The maximum number of participants has been reached';

  @override
  String get meetingIsUnderGoing =>
      'The meeting is still ongoing. Invalid operation';

  @override
  String get unauthorized => 'Login state expired, log in again';

  @override
  String get meetingIdShouldNotBeEmpty => 'Meeting ID is required';

  @override
  String get meetingPasswordNotValid => 'Invalid meeting password';

  @override
  String get displayNameShouldNotBeEmpty => 'Nickname is required';

  @override
  String get meetingLogPathParamsError =>
      'Parameter error, invalid log path or no permission';

  @override
  String get meetingLocked => 'Meeting is locked';

  @override
  String get meetingNotExist => 'Meeting does not exist';

  @override
  String get meetingSaySomeThing => 'Type to chat';

  @override
  String get meetingKeepSilence => 'Block all chats';

  @override
  String get reuseIMNotSupportAnonymousLogin =>
      'IM reuse does not support anonymous login';

  @override
  String get unmuteAudioBySelf => 'Self-unmute';

  @override
  String get updateNicknameBySelf => 'Rename';

  @override
  String get updateNicknameNoPermission => 'Renaming is not allowed';

  @override
  String get shareNoPermission => 'Sharing failed, only the host can share';

  @override
  String get localRecordPermission => 'Local Recording Permissions';

  @override
  String get localRecordOnlyHost => 'Only the host can record';

  @override
  String get localRecordAll => 'Allow all members to record';

  @override
  String get sharingStopByHost => 'The host has terminated your sharing';

  @override
  String get suspendParticipantActivities => 'Suspend participant activities';

  @override
  String get suspendParticipantActivitiesTips =>
      'Everyone in the meeting will be muted and their videos and shared screen will stop. The meeting will be locked.';

  @override
  String get alreadySuspendParticipantActivitiesByHost =>
      'The host has suspended participant activities';

  @override
  String get alreadySuspendParticipantActivities =>
      'Participant activities have been suspended';

  @override
  String get suspendAllParticipantActivities =>
      'Suspend all participant activities?';

  @override
  String get hideAvatarByHost => 'The host has hidden all profile pictures';

  @override
  String get hideAvatar => 'Hide profile pictures';

  @override
  String get screenShare => 'Share';

  @override
  String get screenShareStop => 'Stop Share';

  @override
  String get screenShareOverLimit =>
      'Someone is sharing screen, you can not share your screen';

  @override
  String get screenShareNoPermission => 'No screen sharing permission';

  @override
  String get screenShareTips => 'All content on your screen will be captured.';

  @override
  String get screenShareStopFail => 'Failed to stop screen sharing';

  @override
  String get screenShareStartFail => 'Failed to start screen sharing';

  @override
  String screenShareLocalTips(Object userName) {
    return '$userName is Sharing screen';
  }

  @override
  String screenShareUser(Object userName) {
    return 'Shared screen of $userName';
  }

  @override
  String get screenShareMyself => 'You are sharing your screen';

  @override
  String get screenShareInteractionTip => 'Pinch with 2 fingers to adjust zoom';

  @override
  String get whiteBoardShareStopFail => 'Failed to stop whiteboard sharing';

  @override
  String get whiteBoardShareStartFail => 'Failed to start whiteboard sharing';

  @override
  String get whiteboardShare => 'Whiteboard';

  @override
  String get whiteBoardClose => 'Stop Whiteboard';

  @override
  String get whiteBoardInteractionTip =>
      'You are granted the whiteboard permission';

  @override
  String get whiteBoardUndoInteractionTip =>
      'You are revoked the whiteboard permission';

  @override
  String get whiteBoardNoAuthority =>
      'Whiteboard is unactivated. contact sales for activating the service';

  @override
  String get whiteBoardPackUp => 'Hide';

  @override
  String get meetingHasScreenShareShare =>
      'Whiteboard cannot be shared while screen or computer audio is being shared';

  @override
  String get meetingHasWhiteBoardShare =>
      'Screen cannot be shared while whiteboard is being shared';

  @override
  String get meetingStopSharing => 'Stop sharing';

  @override
  String get meetingStopSharingConfirm =>
      'Are you sure you want to stop sharing in progress?';

  @override
  String get screenShareWarning =>
      'Recently, there are criminals posing as customer service, campus loans and public security fraud, please be vigilant. A security risk has been detected for your meeting and sharing has been disabled.';

  @override
  String get backSharingView => 'Switch to shared content';

  @override
  String screenSharingViewUserLabel(Object userName) {
    return 'Screen shared by $userName';
  }

  @override
  String whiteBoardSharingViewUserLabel(Object userName) {
    return 'Whiteboard shared by $userName';
  }

  @override
  String get virtualBackground => 'Background';

  @override
  String get virtualBackgroundImageNotExist =>
      'Custom background image does not exist';

  @override
  String get virtualBackgroundImageFormatNotSupported =>
      'Invalid background image format';

  @override
  String get virtualBackgroundImageDeviceNotSupported =>
      'The device is not supported';

  @override
  String get virtualBackgroundImageLarge =>
      'The custom background image exceeds 5MB in size';

  @override
  String get virtualBackgroundImageMax =>
      'The custom background images exceed the maximum number';

  @override
  String get virtualBackgroundSelectTip =>
      'Effective when the image is selected';

  @override
  String get virtualDefaultBackground => 'Default';

  @override
  String get virtualCustom => 'Custom';

  @override
  String get live => 'Live';

  @override
  String get liveMeeting => 'Live Meeting';

  @override
  String get liveMeetingTitle => 'Title';

  @override
  String get liveMeetingUrl => 'Live URL';

  @override
  String get liveEnterLivePassword => 'Enter the live code';

  @override
  String get liveEnterLiveSixDigitPassword => 'Enter a 6-digit code';

  @override
  String get liveInteraction => 'Interaction';

  @override
  String get liveInteractionTips =>
      'If enabled, messaging in the meeting room and live room is visible';

  @override
  String get liveLevel => 'Only staff participants can view';

  @override
  String get liveLevelTip =>
      'Non-staff participants are unable to view the live if enabled';

  @override
  String get liveViewSetting => 'View Settings';

  @override
  String get liveViewSettingChange => 'The view is changed';

  @override
  String get liveViewPreviewTips => 'Live streaming preview';

  @override
  String get liveViewPreviewDesc => 'Configure the view settings';

  @override
  String get liveStart => 'Start';

  @override
  String get liveUpdate => 'Update';

  @override
  String get liveStop => 'Stop';

  @override
  String get liveGalleryView => 'Gallery';

  @override
  String get liveFocusView => 'Focus';

  @override
  String get liveScreenShareView => 'Screen Sharing';

  @override
  String get liveChooseView => 'View Mode';

  @override
  String get liveChooseCountTips => 'Select up to 4 participants';

  @override
  String get liveStartFail => 'Failed to start live streaming, try again later';

  @override
  String get liveStartSuccess => 'Live streaming started';

  @override
  String livePickerCount(Object length) {
    return 'Selected $length participant(s)';
  }

  @override
  String get liveUpdateFail =>
      'Failed to update the live streaming, try again later';

  @override
  String get liveUpdateSuccess => 'Live streaming updated';

  @override
  String get liveStopFail =>
      'Failed to stop the live streaming, try again later';

  @override
  String get liveStopSuccess => 'Live streaming stopped';

  @override
  String get livePassword => 'Live code';

  @override
  String get liveDisableAuthLevel =>
      'Editing live streaming permission is not allowed during streaming';

  @override
  String get liveStreaming => 'Live';

  @override
  String get participants => 'Participants';

  @override
  String get participantsManager => 'Participants';

  @override
  String get participantAssignedHost => 'You are assigned HOST';

  @override
  String get participantAssignedCoHost => 'You are assigned CO-HOST';

  @override
  String get participantUnassignedCoHost => 'You are unassigned CO-HOST';

  @override
  String get participantAssignedActiveSpeaker =>
      'You are assigned active speaker';

  @override
  String get participantUnassignedActiveSpeaker =>
      'You are unassigned active speaker';

  @override
  String get participantMuteAudioAll => 'Mute All';

  @override
  String get participantMuteAudioAllDialogTips =>
      'All and new participants are muted';

  @override
  String get participantMuteVideoAllDialogTips =>
      'All and new participants have video turned off';

  @override
  String get participantUnmuteAll => 'Unmute All';

  @override
  String get participantMute => 'Mute';

  @override
  String get participantUnmute => 'Unmute';

  @override
  String get participantTurnOffVideos => 'Turn off all videos';

  @override
  String get participantTurnOnVideos => 'Turn on all videos';

  @override
  String get participantStopVideo => 'Video Off';

  @override
  String get participantStartVideo => 'Video On';

  @override
  String get participantTurnOffAudioAndVideo => 'Turn off audio and video';

  @override
  String get participantTurnOnAudioAndVideo => 'Turn on audio and video';

  @override
  String get participantHostStoppedShare => 'Host stopped your screen sharing';

  @override
  String get participantHostStopWhiteboard =>
      'Host stopped your whiteboard sharing';

  @override
  String get participantAssignActiveSpeaker => 'Assign active speaker';

  @override
  String get participantUnassignActiveSpeaker => 'Unassign active speaker';

  @override
  String get participantTransferHost => 'Transfer HOST';

  @override
  String participantTransferHostConfirm(Object userName) {
    return 'Transfer HOST to $userName';
  }

  @override
  String get participantRemove => 'Remove';

  @override
  String get participantRename => 'Rename';

  @override
  String get participantRenameDialogTitle => 'Change Nickname';

  @override
  String get participantAssignCoHost => 'Assign CO-HOST';

  @override
  String get participantUnassignCoHost => 'Unassign CO-HOST';

  @override
  String get participantRenameTips => 'Enter a new nickname';

  @override
  String get participantRenameSuccess => 'Nickname edited';

  @override
  String get participantRenameFail => 'Renaming failed';

  @override
  String get participantRemoveConfirm => 'Remove';

  @override
  String get participantCannotRemoveSelf => 'You cannot remove yourself';

  @override
  String get participantMuteAudioFail => 'Muting failed';

  @override
  String get participantUnMuteAudioFail => 'Unmuting failed';

  @override
  String get participantMuteVideoFail => 'Failed to turn off camera';

  @override
  String get participantUnMuteVideoFail => 'Failed to turn on camera';

  @override
  String get participantFailedToAssignActiveSpeaker =>
      'Failed to assign active speaker';

  @override
  String get participantFailedToUnassignActiveSpeaker =>
      'Failed to unassign active speaker';

  @override
  String get participantFailedToLowerHand => 'Failed to lower hand';

  @override
  String get participantFailedToTransferHost => 'Failed to transfer HOST';

  @override
  String get participantFailedToRemove => 'Failed to remove the participant';

  @override
  String get participantOpenCamera => 'Cam On';

  @override
  String get participantOpenMicrophone => 'Mic On';

  @override
  String get participantHostOpenCameraTips =>
      'Host requests to turn on your camera. Turn on the camera？';

  @override
  String get participantHostOpenMicroTips =>
      'Host requests to unmute your microphone. Unmute the microphone？';

  @override
  String get participantMuteAllAudioTip => 'Allow participants to unmute';

  @override
  String get participantMuteAllVideoTip =>
      'Allow participants to turn on videos';

  @override
  String get participantMuteAllAudioSuccess => 'All participants are muted';

  @override
  String get participantMuteAllAudioFail => 'Failed to mute all participants';

  @override
  String get participantMuteAllVideoSuccess =>
      'All participants have video turned off';

  @override
  String get participantMuteAllVideoFail =>
      'Failed to turn off videos of all participants';

  @override
  String get participantUnMuteAllAudioSuccess => 'All participants are unmuted';

  @override
  String get participantUnMuteAllAudioFail =>
      'Failed to unmute all participants';

  @override
  String get participantUnMuteAllVideoSuccess =>
      'All participants have video turned on';

  @override
  String get participantUnMuteAllVideoFail =>
      'Failed to turn on videos of all participants';

  @override
  String get participantHostMuteVideo => 'Your video is turned off';

  @override
  String get participantHostMuteAudio => 'You are muted';

  @override
  String get participantHostMuteAllAudio => 'Host muted all participants';

  @override
  String get participantHostMuteAllVideo =>
      'Host turned off videos of all participants';

  @override
  String get participantMuteAudioHandsUpOnTips =>
      'You are unmuted and can speak now';

  @override
  String get participantOverRoleLimitCount =>
      'The number of assigned roles exceeds the upper limit';

  @override
  String get participantMe => 'Me';

  @override
  String get participantSearchMember => 'Search';

  @override
  String get participantHost => 'HOST';

  @override
  String get participantCoHost => 'CO-HOST';

  @override
  String get participantMuteAllHandsUpTips =>
      'The host has muted all participants. You can raise your hand';

  @override
  String get participantTurnOffAllVideoHandsUpTips =>
      'The host has turned off all videos. You can raise your hand';

  @override
  String get participantWhiteBoardInteract => 'Grant the whiteboard permission';

  @override
  String get participantWhiteBoardInteractFail =>
      'Failed to grant the whiteboard permission';

  @override
  String get participantUndoWhiteBoardInteract =>
      'Revoke the whiteboard permission';

  @override
  String get participantUndoWhiteBoardInteractFail =>
      'Failed to revoke the whiteboard permission';

  @override
  String get participantUserHasBeenAssignCoHostRole =>
      'has been assigned CO-HOST';

  @override
  String get participantUserHasBeenRevokeCoHostRole =>
      'has been unassigned CO-HOST';

  @override
  String get participantInMeeting => 'In meeting';

  @override
  String get participantNotJoined => 'Not joined';

  @override
  String get participantJoining => 'Be joining';

  @override
  String get participantAttendees => 'Participants';

  @override
  String get participantAdmit => 'Admit';

  @override
  String get participantWaitingTimePrefix => 'Waiting';

  @override
  String get participantPutInWaitingRoom => 'Remove to waiting room';

  @override
  String get participantDisallowMemberRejoinMeeting =>
      'Do not allow users to join this meeting again';

  @override
  String participantVideoIsPinned(Object corner) {
    return 'The video is locked, tap unlock at $corner to unlock';
  }

  @override
  String get participantVideoIsUnpinned => 'Video unlocked';

  @override
  String get participantNotFound => 'No member found';

  @override
  String get participantSetHost => 'Set as host';

  @override
  String get participantSetCoHost => 'Set as co-host';

  @override
  String get participantCancelCoHost => 'Cancel the co-host';

  @override
  String get participantRemoveAttendee => 'Delete';

  @override
  String get participantUpperLimitWaitingRoomTip =>
      'The number of participants has reached  the limit , it is recommended to use the waiting room.';

  @override
  String get participantUpperLimitReleaseSeatsTip =>
      'The number of participants has reached  the limit , and new participants will not be able to join the meeting.You can try removing not-joined members or releasing a seat in the meeting.';

  @override
  String get participantUpperLimitTipAdmitOtherTip =>
      'The number of participants has reached  the limit . Please remove an unjoined member or release a seat in the meeting before admitting a member to the waiting room.';

  @override
  String get cloudRecordingEnabledTitle =>
      'Are you sure you want to start a cloud recording?';

  @override
  String get cloudRecordingEnabledMessage =>
      'After the recording starts, all participants will be informed and the meeting audio, video and shared screen view will be recorded to the cloud';

  @override
  String get cloudRecordingEnabledMessageWithoutNotice =>
      'After the recording starts,  the meeting audio, video and shared screen view will be recorded to the cloud';

  @override
  String get cloudRecordingTitle => 'This meeting is being recorded';

  @override
  String get cloudRecordingMessage =>
      'The host has started a cloud recording and the meeting creator will receive the cloud recording file. You can contact the creator for the cloud recording file.';

  @override
  String get cloudRecordingAgree =>
      'By staying in the meeting, you agree to the recording.';

  @override
  String get cloudRecordingWhetherEndedTitle => 'End Cloud Recording';

  @override
  String get cloudRecordingEndedMessage =>
      'Go to \'Historical Meeting - Meeting Details\' to check recorded files after meeting.';

  @override
  String get cloudRecordingEndedTitle => 'Cloud recording has ended';

  @override
  String get cloudRecordingEndedAndGetUrl =>
      'You can contact the meeting creator after the meeting to obtain a viewing link';

  @override
  String get cloudRecordingStart => 'Cloud recording';

  @override
  String get cloudRecordingStop => 'stop recording';

  @override
  String get cloudRecording => 'Recording';

  @override
  String get cloudRecordingStartFail => 'Failed to start recording';

  @override
  String get cloudRecordingStopFail => 'Failed to stop recording';

  @override
  String get cloudRecordingStarting => 'Starting recording…';

  @override
  String get chat => 'Chat';

  @override
  String get chatInputMessageHint => 'Entering...';

  @override
  String get chatCannotSendBlankLetter => 'Unable to send empty messages';

  @override
  String get chatJoinFail => 'Failed to join the chat room';

  @override
  String get chatNewMessage => 'New message';

  @override
  String get chatUnsupportedFileExtension => 'Unsupported file';

  @override
  String get chatFileSizeExceedTheLimit => 'File size cannot exceed 200MB';

  @override
  String get chatImageSizeExceedTheLimit => 'Image size cannot exceed 20MB';

  @override
  String get chatImageMessageTip => '[Image]';

  @override
  String get chatFileMessageTip => '[File]';

  @override
  String get chatSaveToGallerySuccess => 'Saved to Album';

  @override
  String get chatOperationFailNoPermission => 'No permission';

  @override
  String get chatOpenFileFail => 'Opening file failed';

  @override
  String get chatOpenFileFailNoPermission =>
      'Opening file failed: no permission';

  @override
  String get chatOpenFileFailFileNotFound =>
      'Opening file failed: no file exists';

  @override
  String get chatOpenFileFailAppNotFound =>
      'Opening file failed: no app installed to open the file';

  @override
  String get chatRecall => 'Recall';

  @override
  String get chatAboveIsHistoryMessage => 'Historical chat messages above';

  @override
  String get chatYou => 'You';

  @override
  String get chatRecallAMessage => 'recalled a message';

  @override
  String get chatMessageRecalled => 'Message recalled';

  @override
  String get chatMessage => 'Message';

  @override
  String get chatSendTo => 'Send to';

  @override
  String get chatAllMembersInMeeting => 'Everyone in the meeting';

  @override
  String get chatAllMembersInWaitingRoom => 'Everyone in the waiting room';

  @override
  String get chatHistory => 'Chat History';

  @override
  String get chatMessageSendToWaitingRoom => 'To the waiting room';

  @override
  String get chatNoChatHistory => 'No chat history';

  @override
  String get chatAllMembers => 'Everyone';

  @override
  String get chatPrivate => 'Private';

  @override
  String get chatPrivateInWaitingRoom => 'Waiting room-private';

  @override
  String get chatPermission => 'Chat permissions';

  @override
  String get chatFree => 'All chats allowed';

  @override
  String get chatPublicOnly => 'Group chats only';

  @override
  String get chatPrivateHostOnly => 'Chat with host only';

  @override
  String get chatMuted => 'Mute all participants';

  @override
  String get chatPermissionInMeeting => 'Chat permissions in the meeting';

  @override
  String get chatPermissionInWaitingRoom =>
      'Chat permissions in the waiting room';

  @override
  String get chatWaitingRoomPrivateHostOnly => 'Chat with the host';

  @override
  String get chatHostMutedEveryone => 'Block all chats';

  @override
  String get chatHostLeft =>
      'The host has left and cannot send private chat messages';

  @override
  String chatSaidToMe(Object userName) {
    return '$userName said to me';
  }

  @override
  String chatISaidTo(Object userName) {
    return 'I said to$userName';
  }

  @override
  String chatSaidToWaitingRoom(Object userName) {
    return '$userName to everyone waiting';
  }

  @override
  String get chatISaidToWaitingRoom => 'To Everyone waiting';

  @override
  String get chatSendFailed => 'Failed to send';

  @override
  String get chatMemberLeft => 'The participants have left the meeting';

  @override
  String get chatWaitingRoomMuted => 'The host has not opened the chat';

  @override
  String get chatHistoryNotEnabled =>
      'Chat history is not enabled. Please contact your administrator';

  @override
  String get waitingRoomJoinMeeting => 'Join';

  @override
  String get waitingRoom => 'Waiting Room';

  @override
  String get waitingRoomJoinMeetingOption => 'Meeting Settings';

  @override
  String get waitingRoomWaitHostToInviteJoinMeeting =>
      'Please wait. The host will let you into the meeting soon.';

  @override
  String get waitingRoomWaitMeetingToStart =>
      'Please wait. The meeting will begin soon';

  @override
  String get waitingRoomTurnOnMicrophone => 'Turn On Mic';

  @override
  String get waitingRoomTurnOnVideo => 'Turn On Video';

  @override
  String get waitingRoomEnabledOnEntry => 'You have enabled waiting room';

  @override
  String get waitingRoomDisabledOnEntry => 'You have disabled waiting room';

  @override
  String get waitingRoomDisableDialogTitle => 'Close the waiting room';

  @override
  String get waitingRoomDisableDialogMessage =>
      'After the waiting room closes, new members will join the meeting directly';

  @override
  String get waitingRoomDisableDialogAdmitAll =>
      'Allow all members of the waiting room to enter the meeting';

  @override
  String get waitingRoomCloseRightNow => 'Close';

  @override
  String waitingRoomCount(Object count) {
    return '${count}attendee(s) waiting';
  }

  @override
  String get waitingRoomAutoAdmit => 'Admit to meeting automatically';

  @override
  String get movedToWaitingRoom => 'The host has moved you to the waiting room';

  @override
  String get waitingRoomAdmitAll => 'Admit All';

  @override
  String get waitingRoomRemoveAll => 'Remove All';

  @override
  String get waitingRoomAdmitMember => 'Admit Waiting Attendee';

  @override
  String get waitingRoomAdmitAllMembersTip =>
      'Do you want to admit all attendees in the waiting room to the meeting';

  @override
  String get waitingRoomRemoveAllMemberTip =>
      'Are you sure you want to remove all attendees from the waiting room ?';

  @override
  String get waitingRoomExpelWaitingMember => 'Remove waiting members';

  @override
  String get waiting => 'Waiting';

  @override
  String get waitingRoomEnable => 'Enable Waiting Room';

  @override
  String get deviceSpeaker => 'Speaker';

  @override
  String get deviceReceiver => 'Receiver';

  @override
  String get deviceBluetooth => 'Bluetooth';

  @override
  String get deviceHeadphones => 'Headphones';

  @override
  String get deviceOutput => 'Audio Device';

  @override
  String get deviceHeadsetState => 'You are using the earphone';

  @override
  String get networkConnectionGood => 'Network connection is good';

  @override
  String get networkConnectionGeneral => 'Network connection is fair';

  @override
  String get networkConnectionPoor => 'Network connection is poor';

  @override
  String get nan => 'Network connection is unknown';

  @override
  String get networkLocalLatency => 'Latency';

  @override
  String get networkPacketLossRate => 'Packet Loss Rate';

  @override
  String get networkReconnectionSuccessful => 'Network reconnection successful';

  @override
  String get networkAbnormalityPleaseCheckYourNetwork =>
      'Network abnormality, please check your network';

  @override
  String get networkAbnormality => 'Network abnormality';

  @override
  String get networkDisconnectedPleaseCheckYourNetworkStatusOrTryToRejoin =>
      'Network disconnected, please check your network status or try to rejoin.';

  @override
  String get networkNotStable => 'The network status is not good';

  @override
  String get networkUnavailableCloseFail =>
      'Ending meeting failed due to the network error';

  @override
  String get networkDisconnectedTryingToReconnect =>
      'Disconnected, trying to reconnect…';

  @override
  String get networkUnavailableCheck =>
      'Network connection failed, please check your network connection!';

  @override
  String get networkUnstableTip => 'The network is unstable, connecting...';

  @override
  String get notifyCenter => 'Notification';

  @override
  String get notifyCenterAllClear => 'Confirm to clear all notifications?';

  @override
  String get notifyCenterNoMessage => 'No news';

  @override
  String get notifyCenterViewDetailsUnsupported =>
      'The message does not support viewing details';

  @override
  String get notifyCenterViewingDetails => 'View details';

  @override
  String get sipCallByNumber => 'Phone';

  @override
  String get sipCall => 'Call';

  @override
  String get sipContacts => 'Contacts';

  @override
  String get sipNumberPlaceholder => 'Enter the phone number';

  @override
  String get sipName => 'Invitee name';

  @override
  String get sipNamePlaceholder => 'Names will be presented at the meeting';

  @override
  String get sipCallNumber => 'Dial out number:';

  @override
  String get sipNumberError => 'Phone number error';

  @override
  String get sipCallIsCalling => 'The number is already in a call';

  @override
  String get sipLocalContacts => 'Local contacts';

  @override
  String get sipContactsClear => 'Clear';

  @override
  String get sipCalling => 'Calling';

  @override
  String get sipCallTerm => 'Hang up';

  @override
  String get sipCallOthers => 'Call other members';

  @override
  String get sipCallFailed => 'Call failed';

  @override
  String get sipCallAgain => 'Redial';

  @override
  String get sipSearch => 'Search';

  @override
  String get sipSearchContacts => 'Search and add participants';

  @override
  String get sipCallPhone => 'Phone call';

  @override
  String get sipCallingNumber => 'To join';

  @override
  String get sipCallCancel => 'Cancel call';

  @override
  String get sipCallAgainEx => 'Call again';

  @override
  String get sipCallStatusCalling => 'Calling';

  @override
  String get callStatusCalling => 'Calling';

  @override
  String get sipCallStatusWaiting => 'Waiting for call';

  @override
  String get callStatusWaitingJoin => 'To join';

  @override
  String get sipCallStatusTermed => 'Hung up';

  @override
  String get sipCallStatusUnaccepted => 'No answer';

  @override
  String get sipCallStatusRejected => 'Rejected';

  @override
  String get sipCallStatusCanceled => 'Cancelled';

  @override
  String get sipCallStatusError => 'Call exception';

  @override
  String get sipPhoneNumber => 'Phone number';

  @override
  String sipCallMemberSelected(Object count) {
    return 'Selected: $count';
  }

  @override
  String get sipContactsPrivacy =>
      'Authorize access to your address book to call a contact to join a meeting by phone';

  @override
  String get memberCountOutOfRange =>
      'The maximum number of participants has been reached';

  @override
  String get sipContactNoNumber => 'User has no number.';

  @override
  String get sipCallIsInMeeting => 'The user is already in a meeting.';

  @override
  String get callInWaitingMeeting =>
      'The member is already in the waiting room';

  @override
  String get sipCallIsInInviting => 'The user is inviting.';

  @override
  String get sipCallIsInBlacklist =>
      'The member has been blocked. To invite, disable the meeting blacklist';

  @override
  String get sipCallByPhone => 'Phone';

  @override
  String get sipKeypad => 'Keypad';

  @override
  String get sipBatchCall => 'Batch Call';

  @override
  String get sipLocalContactsEmpty => 'Local address book is empty';

  @override
  String sipCallMaxCount(Object count) {
    return 'Select at most $count people at a time.';
  }

  @override
  String get sipInviteInfo => 'Copy details';

  @override
  String get sipAddressInvite => 'Contacts';

  @override
  String get sipJoinOtherMeetingTip =>
      'Will leave the current meeting once you accept.';

  @override
  String get sipRoom => 'Conference room';

  @override
  String get sipCallOutPhone => 'Phone';

  @override
  String get sipCallOutRoom => 'Call SIP/H.323';

  @override
  String get sipCallOutRoomInputTip =>
      'IP address or SIP URI or registered device number';

  @override
  String get sipDisplayName => 'Name';

  @override
  String get sipDeviceIsInCalling => 'The device is already on the call';

  @override
  String get sipDeviceIsInMeeting => 'The device is already in the meeting';

  @override
  String get monitoring => 'Quality Monitoring';

  @override
  String get overall => 'Overall';

  @override
  String get soundAndVideo => 'Audiovisual';

  @override
  String get cpu => 'CPU';

  @override
  String get memory => 'Memory';

  @override
  String get network => 'Network';

  @override
  String get bandwidth => 'Bandwidth';

  @override
  String get networkType => 'Network Type';

  @override
  String get networkState => 'Network';

  @override
  String get delay => 'Latency';

  @override
  String get packageLossRate => 'Packet loss';

  @override
  String get recently => 'Last';

  @override
  String get audio => 'Audio';

  @override
  String get microphone => 'Mic';

  @override
  String get speaker => 'Speaker';

  @override
  String get bitrate => 'Bitrate';

  @override
  String get speakerPlayback => 'Speaker Playback';

  @override
  String get microphoneAcquisition => 'Mic Capture';

  @override
  String get resolution => 'Resolution';

  @override
  String get frameRate => 'Frame';

  @override
  String get moreMonitoring => 'View More';

  @override
  String get layoutSettings => 'Layout setting';

  @override
  String get galleryModeMaxCount =>
      'Max participants per screen in gallery view';

  @override
  String galleryModeScreens(Object count) {
    return '$count';
  }

  @override
  String get followGalleryLayout => 'Follow the host\'s video sequence';

  @override
  String get resetGalleryLayout => 'Reset video sequence';

  @override
  String get followGalleryLayoutTips =>
      'The first 25 videos in host gallery mode are synchronized to all participants, and participants are not allowed to change themselves.';

  @override
  String get followGalleryLayoutConfirm =>
      'The host has set \"Follow the host\'s video sequence\" and cannot move the video.';

  @override
  String get followGalleryLayoutResetConfirm =>
      'The host has set \"Follow the host\'s video sequence\", and the video order cannot be reset.';

  @override
  String get saveGalleryLayoutTitle => 'Save video sequence';

  @override
  String get saveGalleryLayoutContent =>
      'Save the current video sequence to the scheduled meeting for subsequent meetings. Are you sure to save the video sequence?';

  @override
  String get replaceGalleryLayoutContent =>
      'The scheduled meeting already has an old video sequence. Do you want to replace it and save it to the new video sequence?';

  @override
  String get loadGalleryLayoutTitle => 'Load video sequence';

  @override
  String get loadGalleryLayoutContent =>
      'The scheduled meeting already has a video sequence. Do you want to load it?';

  @override
  String get load => 'Load';

  @override
  String get noLoadGalleryLayout => 'There is no video sequence to load';

  @override
  String get loadSuccess => 'Load successfully';

  @override
  String get loadFail => 'Failed to load';

  @override
  String get globalUpdate => 'Update';

  @override
  String get globalLang => 'Language';

  @override
  String get globalView => 'View';

  @override
  String get interpretation => 'Interpretation';

  @override
  String get interpInterpreter => 'Interpreter';

  @override
  String get interpSelectInterpreter => 'Select interpreter';

  @override
  String get interpInterpreterAlreadyExists =>
      'The user has been selected as a interpreter and cannot be selected again';

  @override
  String get interpInfoIncompleteTitle =>
      'Interpreter information is incomplete';

  @override
  String get interpInfoIncompleteMsg =>
      'Quitting will remove interpreters with incomplete information';

  @override
  String get interpStart => 'Start';

  @override
  String get interpStartNotification =>
      'The host has started simultaneous interpretation';

  @override
  String get interpStop => 'Stop interpretation';

  @override
  String get interpStopNotification =>
      'The host has turned off simultaneous interpretation';

  @override
  String get interpConfirmStopMsg =>
      'Turning off simultaneous interpretation will turn off all listening channels. Do you want to turn it off?';

  @override
  String get interpConfirmUpdateMsg => 'Update?';

  @override
  String get interpConfirmCancelEditMsg =>
      'Are you sure to cancel the settings ?';

  @override
  String get interpSelectListenLanguage => 'Please select a listening language';

  @override
  String get interpSelectLanguage => 'Select language';

  @override
  String get interpAddLanguage => 'Add';

  @override
  String get interpInputLanguage => 'Input';

  @override
  String get interpLanguageAlreadyExists => 'Language already exists';

  @override
  String get interpListenMajorAudioMeanwhile => 'Listen to the original sound';

  @override
  String get interpManagement => 'Manage interpretation';

  @override
  String get interpSettings => 'Set up';

  @override
  String get interpMajorAudio => 'Original sound';

  @override
  String get interpMajorChannel => 'Main';

  @override
  String get interpMajorAudioVolume => 'Original volume';

  @override
  String get interpAddInterpreter => 'Add interpreter';

  @override
  String get interpJoinChannelErrorMsg =>
      'Failed to join the interpretation channel. Do you want to rejoin?';

  @override
  String get interpReJoinChannel => 'Rejoin';

  @override
  String get interpAssignInterpreter =>
      'You have become the interpreter of this meeting';

  @override
  String get interpAssignLanguage => 'Language';

  @override
  String get interpAssignInterpreterTip =>
      'You can set the listening language and translation language in \"Interpretation\"';

  @override
  String get interpUnassignInterpreter =>
      'You have been removed from interpreters by the host';

  @override
  String interpLanguageRemoved(Object language) {
    return 'The host has deleted the listening language \"$language\"';
  }

  @override
  String get interpInterpreterOffline =>
      'All the interpreters have left the channel you are listening to . Would you like to switch back to the original sound ?';

  @override
  String get interpDontSwitch => 'Not Now';

  @override
  String get interpSwitchToMajorAudio => 'Switch back';

  @override
  String get interpAudioShareIsForbiddenDesktop =>
      'As an interpreter, you will not be able to share your computer voice when sharing the screen';

  @override
  String get interpAudioShareIsForbiddenMobile =>
      'As an interpreter, you will not be able to share device audio when sharing the screen';

  @override
  String get interpInterpreterInMeetingStatusChanged =>
      'Interpreter participation status has changed';

  @override
  String interpSpeakerTip(Object language1, Object language2) {
    return 'You are listening to $language1 and saying $language2';
  }

  @override
  String get interpOutputLanguage => 'Translation language';

  @override
  String get interpRemoveInterpreterOnly => 'Only delete interpreter';

  @override
  String get interpRemoveInterpreterInMembers => 'Delete from participants';

  @override
  String get interpRemoveMemberInInterpreters =>
      'The participant is also assigned as an interpreter. Deleting the participant will cancel the interpreter assignment at the same time.';

  @override
  String get interpListeningChannelDisconnect =>
      'The listening language channel has been disconnected, trying to reconnect';

  @override
  String get interpSpeakingChannelDisconnect =>
      'The interpreter language channel has been disconnected, trying to reconnect';

  @override
  String get langChinese => 'Chinese';

  @override
  String get langEnglish => 'English';

  @override
  String get langJapanese => 'Japanese';

  @override
  String get langKorean => 'Korean';

  @override
  String get langFrench => 'French';

  @override
  String get langGerman => 'German';

  @override
  String get langSpanish => 'Spanish';

  @override
  String get langRussian => 'Russian';

  @override
  String get langPortuguese => 'Portuguese';

  @override
  String get langItalian => 'Italian';

  @override
  String get langTurkish => 'Turkish';

  @override
  String get langVietnamese => 'Vietnamese';

  @override
  String get langThai => 'Thai';

  @override
  String get langIndonesian => 'Indonesian';

  @override
  String get langMalay => 'Malay';

  @override
  String get langArabic => 'Arabic';

  @override
  String get langHindi => 'Hindi';

  @override
  String get annotation => 'Annotate';

  @override
  String get annotationEnabled => 'Annotation enabled';

  @override
  String get annotationDisabled => 'Annotation disabled';

  @override
  String get startAnnotation => 'Annotate';

  @override
  String get stopAnnotation => 'Exit annotation';

  @override
  String get inAnnotation => 'Annotating';

  @override
  String get saveAnnotation => 'Save annotations';

  @override
  String get cancelAnnotation => 'Cancel annotation';

  @override
  String get settings => 'Settings';

  @override
  String get settingAudio => 'Audio';

  @override
  String get settingVideo => 'Video';

  @override
  String get settingCommon => 'General';

  @override
  String get settingAudioAINS => 'Smart Noise Reduction';

  @override
  String get settingEnableTransparentWhiteboard =>
      'Set the whiteboard to transparent';

  @override
  String get settingEnableFrontCameraMirror => 'Front camera mirroring';

  @override
  String get settingShowMeetDuration => 'Show Meeting Duration';

  @override
  String get settingSpeakerSpotlight => 'Speaker Spotlight';

  @override
  String get settingSpeakerSpotlightTip =>
      'When turned on, the participants who are speaking will be displayed first.';

  @override
  String get settingShowName =>
      'Always display participant names on their video';

  @override
  String get settingHideNotYetJoinedMembers => 'Hide unjoined members';

  @override
  String get settingChatMessageNotification => 'Chat message notifications';

  @override
  String get settingChatMessageNotificationBarrage => 'Chat area';

  @override
  String get settingChatMessageNotificationBubble => 'Speech bubble';

  @override
  String get settingChatMessageNotificationNoReminder => 'Off';

  @override
  String get usingComputerAudioInMeeting =>
      'Use PC audio when joining a meeting';

  @override
  String get joinMeetingSettings => 'Join Settings';

  @override
  String get memberJoinWithMute => 'Mute participants upon entry';

  @override
  String get ringWhenMemberJoinOrLeave =>
      'Play sound when someone joins or leaves';

  @override
  String get transcriptionEnableCaption => 'Enable subtitles';

  @override
  String get transcriptionEnableCaptionHint =>
      'The current subtitles are only visible to you';

  @override
  String get transcriptionDisableCaption => 'Disable subtitles';

  @override
  String get transcriptionDisableCaptionHint => 'You have turned off subtitles';

  @override
  String get transcriptionCaptionLoading =>
      'Transcription enabled, The machine recognition results are only for reference.';

  @override
  String get transcriptionDisclaimer => 'Machine results for reference.';

  @override
  String get transcriptionCaptionSettingsHint =>
      'Click to enter subtitle settings.';

  @override
  String get transcriptionCaptionSettings => 'Subtitle settings';

  @override
  String get transcriptionAllowEnableCaption => 'Use subtitles';

  @override
  String get transcriptionCanNotEnableCaption =>
      'The subtitle function is unavailable. Please contact the host or administrator.';

  @override
  String get transcriptionCaptionForbidden =>
      'Participants are not allowed to use subtitles, and subtitles have been turned off.';

  @override
  String get transcriptionCaptionNotAvailableInSubChannel =>
      'Not listening to the original sound, subtitles are not available, if you need to use please listen to the original sound.';

  @override
  String get transcriptionCaptionFontSize => 'Text Size';

  @override
  String get transcriptionCaptionSmall => 'Small';

  @override
  String get transcriptionCaptionBig => 'Big';

  @override
  String get transcriptionCaptionEnableWhenJoin =>
      'Enable subtitles when joining a meeting';

  @override
  String get transcriptionCaptionExampleSize => 'Example of subtitle text size';

  @override
  String get transcriptionCaptionTypeSize => 'Text Size';

  @override
  String get transcription => 'Real-time transcription';

  @override
  String get transcriptionStart => 'Transcribe';

  @override
  String get transcriptionStop => 'End transcript';

  @override
  String get transcriptionStartConfirmMsg =>
      'Do you want to enable real-time translation?';

  @override
  String get transcriptionStartedNotificationMsg =>
      'The host has started real-time transcription, and all members can view the transcription content.';

  @override
  String get transcriptionRunning => 'Translating';

  @override
  String get transcriptionStartedTip =>
      'The host has enabled real-time transcription';

  @override
  String get transcriptionStoppedTip =>
      'The host has disabled real-time transcription';

  @override
  String get transcriptionNotStarted =>
      'Real-time transcription is not enabled. Contact the host to enable the transcription.';

  @override
  String get transcriptionStopFailed => 'Failed to disable subtitles';

  @override
  String get transcriptionStartFailed => 'Failed to enable subtitles';

  @override
  String get transcriptionTranslationSettings => 'Translation Settings';

  @override
  String get transcriptionSettings => 'Transcription Settings';

  @override
  String get transcriptionTargetLang => 'Translation Display';

  @override
  String get transcriptionShowBilingual => 'Bilingual Mode';

  @override
  String get transcriptionNotTranslated => 'Do Not Translate';

  @override
  String get transcriptionMemberPermission => 'Member viewing permissions';

  @override
  String get transcriptionViewFullContent => 'View full content';

  @override
  String get transcriptionViewConferenceContent =>
      'View the contents during the meeting';

  @override
  String get feedbackInRoom => 'Feedback';

  @override
  String get feedbackProblemType => 'Problem Type';

  @override
  String get feedbackSuccess => 'Submitted successfully';

  @override
  String get feedbackFail => 'Failed to submit';

  @override
  String get feedbackAudioLatency => 'A large delay';

  @override
  String get feedbackAudioFreeze => 'Stuck';

  @override
  String get feedbackCannotHearOthers => 'Can\'t hear the other\'s voice';

  @override
  String get feedbackCannotHearMe => 'The others can\'t hear me';

  @override
  String get feedbackTitleExtras => 'Additional Information';

  @override
  String get feedbackTitleDate => 'Occurrence Time';

  @override
  String get feedbackContentEmpty => 'Empty';

  @override
  String get feedbackTitleSelectPicture => 'Picture';

  @override
  String get feedbackAudioMechanicalNoise => 'Mechanical sound';

  @override
  String get feedbackAudioNoise => 'Noise';

  @override
  String get feedbackAudioEcho => 'Echo';

  @override
  String get feedbackAudioVolumeSmall => 'Low volume';

  @override
  String get feedbackVideoFreeze => 'Long time stuck';

  @override
  String get feedbackVideoIntermittent => 'Video is intermittent';

  @override
  String get feedbackVideoTearing => 'Tearing';

  @override
  String get feedbackVideoTooBrightOrDark => 'Picture too bright/too dark';

  @override
  String get feedbackVideoBlurry => 'Blurred image';

  @override
  String get feedbackVideoNoise => 'Obvious noise';

  @override
  String get feedbackAudioVideoNotSync =>
      'Sound and picture are not synchronized';

  @override
  String get feedbackUnexpectedExit => 'Unexpected exit';

  @override
  String get feedbackOthers => 'There are other problems';

  @override
  String get feedbackTitleAudio => 'Audio problem';

  @override
  String get feedbackTitleVideo => 'Video problem';

  @override
  String get feedbackTitleOthers => 'Other';

  @override
  String get feedbackTitleDescription => 'Description';

  @override
  String get feedbackOtherTip =>
      'Please describe your problem (when you select \"There are other problems\"), you need to fill in a specific description before submitting';

  @override
  String get feedback => 'Feedback';
}
