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
  String get globalMin => 'minutes';

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
  String get meetingNoSupportSwitch => 'iPad does not support switching modes';

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
      'Whiteboard cannot be shared while screen is being shared';

  @override
  String get meetingHasWhiteBoardShare =>
      'Screen cannot be shared while whiteboard is being shared';

  @override
  String get meetingStopSharing => 'Stop sharing';

  @override
  String get meetingStopSharingConfirm =>
      'Are you sure you want to stop sharing in progress?';

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
  String get liveStreaming => 'Live Streaming';

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
  String get participantMe => 'me';

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
  String get participantAttendees => 'Attendees';

  @override
  String get participantAdmit => 'Admit';

  @override
  String get participantWaitingTimePrefix => 'Waiting';

  @override
  String get participantPutInWaitingRoom => 'Remove to waiting room';

  @override
  String get participantExpelWaitingMemberDialogTitle =>
      'Remove waiting members';

  @override
  String get participantDisallowMemberRejoinMeeting =>
      'Do not allow users to join this meeting again';

  @override
  String get cloudRecordingEnabledTitle =>
      'Are you sure you want to start a cloud recording?';

  @override
  String get cloudRecordingEnabledMessage =>
      'After the recording starts, all attendees will be informed and the meeting audio, video and shared screen view will be recorded to the cloud';

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
  String get movedToWaitingRoom => 'The host has moved you to the waiting room';

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
  String get networkNotStable => 'Unstable network';

  @override
  String get networkUnavailableCloseFail =>
      'Ending meeting failed due to the network error';

  @override
  String get networkDisconnectedTryingToReconnect =>
      'Disconnected, trying to reconnect…';
}
