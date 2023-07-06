// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'meeting_ui_kit_localizations.dart';

/// The translations for English (`en`).
class NEMeetingUIKitLocalizationsEn extends NEMeetingUIKitLocalizations {
  NEMeetingUIKitLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get joinMeeting => 'Join';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get beauty => 'Beauty ';

  @override
  String get beautyLevel => 'Level';

  @override
  String get joiningTips => 'Joining...';

  @override
  String get leaveMeeting => 'Leave';

  @override
  String get quitMeeting => 'End';

  @override
  String get defaultMeetingTitle => 'Video Meeting';

  @override
  String get close => 'Close';

  @override
  String get open => 'Open';

  @override
  String get fail => 'Fail';

  @override
  String get networkNotStable => 'Unstable network';

  @override
  String get memberlistTitle => 'Participants';

  @override
  String get joinMeetingFail => 'Failed to join the meeting';

  @override
  String get yourChangeHost => 'You are assigned HOST';

  @override
  String get yourChangeCoHost => 'You are assigned CO-HOST';

  @override
  String get yourChangeCancelCoHost => 'You are unassigned CO-HOST';

  @override
  String get localUserAssignedActiveSpeaker =>
      'You are assigned active speaker';

  @override
  String get localUserUnAssignedActiveSpeaker =>
      'You are unassigned active speaker';

  @override
  String get muteAudioAll => 'Mute All';

  @override
  String get muteAudioAllDialogTips => 'All and new participants are muted';

  @override
  String get muteVideoAllDialogTips =>
      'All and new participants have video turned off';

  @override
  String get unMuteAudioAll => 'Unmute All';

  @override
  String get muteAudio => 'Mute';

  @override
  String get unMuteAudio => 'Unmute';

  @override
  String get muteAllVideo => 'Turn off videos';

  @override
  String get unmuteAllVideo => 'Turn on videos';

  @override
  String get muteVideo => 'Stop Video';

  @override
  String get unMuteVideo => 'Start Video';

  @override
  String get muteAudioAndVideo => 'Turn off audio and video';

  @override
  String get unmuteAudioAndVideo => 'Turn on audio and video';

  @override
  String get screenShare => 'Share Screen';

  @override
  String get hostStopShare => 'Host stopped your screen sharing';

  @override
  String get hostStopWhiteboard => 'Host stopped your whiteboard sharing';

  @override
  String get unScreenShare => 'Stop Share';

  @override
  String get focusVideo => 'Assign active speaker';

  @override
  String get unFocusVideo => 'Unassign active speaker';

  @override
  String get changeHost => 'Transfer HOST';

  @override
  String get changeHostTips => 'Transfer HOST to ';

  @override
  String get remove => 'Remove';

  @override
  String get rename => 'Rename';

  @override
  String get makeCoHost => 'Assign CO-HOST';

  @override
  String get cancelCoHost => 'Unassign CO_HOST';

  @override
  String get renameTips => 'Enter a new nickname';

  @override
  String get renameSuccess => 'Nickname edited';

  @override
  String get renameFail => 'Renaming failed';

  @override
  String get removeTips => 'Remove ';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get cannotRemoveSelf => 'You cannot remove yourself';

  @override
  String get muteAudioFail => 'Muting failed';

  @override
  String get unMuteAudioFail => 'Unmuting failed';

  @override
  String get muteVideoFail => 'Failed to turn off camera';

  @override
  String get unMuteVideoFail => 'Failed to turn on camera';

  @override
  String get focusVideoFail => 'Failed to assign active speaker';

  @override
  String get unFocusVideoFail => 'Failed to unassign active speaker';

  @override
  String get handsUpDownFail => 'Failed to lower hand';

  @override
  String get changeHostFail => 'Failed to transfer HOST';

  @override
  String get removeMemberFail => 'Failed to remove the participant';

  @override
  String get save => 'Save';

  @override
  String get done => 'Complete';

  @override
  String get notify => 'Notification';

  @override
  String get hostKickedYou =>
      'You are removed by HOST or switched to another device, you have left the meeting';

  @override
  String get sure => 'OK';

  @override
  String get openCamera => 'Cam On';

  @override
  String get openMicro => 'Mic On';

  @override
  String get micphoneNotWorksDialogTitle => 'Microphone unavailable';

  @override
  String get micphoneNotWorksDialogMessage =>
      'You are using the microphone. To speak, \n click Unmute and speak';

  @override
  String get hostOpenCameraTips =>
      'Host requests to turn on your camera. Turn on the camera？';

  @override
  String get hostOpenMicroTips =>
      'Host requests to unmute your microphone. Unmute the microphone？';

  @override
  String get finish => 'End';

  @override
  String get leave => 'Leave';

  @override
  String get muteAllAudioTip => 'Allow participants to unmute';

  @override
  String get muteAllVideoTip => 'Allow participants to turn on videos';

  @override
  String get muteAllAudioSuccess => 'All participants are muted';

  @override
  String get muteAllAudioFail => 'Failed to mute all participants';

  @override
  String get muteAllVideoSuccess => 'All participants have video turned off';

  @override
  String get muteAllVideoFail =>
      'Failed to turn off videos of all participants';

  @override
  String get unMuteAllAudioSuccess => 'All participants are unmuted';

  @override
  String get unMuteAllAudioFail => 'Failed to unmute all participants';

  @override
  String get unMuteAllVideoSuccess => 'All participants have video turned on';

  @override
  String get unMuteAllVideoFail =>
      'Failed to turn on videos of all participants';

  @override
  String get meetingHostMuteVideo => 'Your video is turned off';

  @override
  String get meetingHostMuteAudio => 'You are muted';

  @override
  String get meetingHostMuteAllAudio => 'Host muted all participants';

  @override
  String get meetingHostMuteAllVideo =>
      'Host turned off videos of all participants';

  @override
  String get muteAudioHandsUpOnTips => 'You are unmuted and can speak now';

  @override
  String get shareOverLimit =>
      'Someone is sharing screen, you can not share your screen';

  @override
  String get noShareScreenPermission => 'No screen sharing permission';

  @override
  String get hasWhiteBoardShare =>
      'Screen cannot be shared while whiteboard is being shared';

  @override
  String get overRoleLimitCount =>
      'The number of assigned roles exceeds the upper limit';

  @override
  String get hasScreenShareShare =>
      'Whiteboard cannot be shared while screen is being shared';

  @override
  String get screenShareTips => 'All content on your screen will be captured.';

  @override
  String get screenShareStopFail => 'Failed to stop screen sharing';

  @override
  String get whiteBoardShareStopFail => 'Failed to stop whiteboard sharing';

  @override
  String get whiteBoardShareStartFail => 'Failed to start whiteboard sharing';

  @override
  String get screenShareStartFail => 'Failed to start screen sharing';

  @override
  String get screenShareLocalTips => ' is Sharing screen';

  @override
  String get screenShareSuffix => ' screen';

  @override
  String get screenShareInteractionTip => 'Pinch with 2 fingers to adjust zoom';

  @override
  String get whiteBoardInteractionTip =>
      'You are granted the whiteboard permission';

  @override
  String get undoWhiteBoardInteractionTip =>
      'You are revoked the whiteboard permission';

  @override
  String get speakingPrefix => 'Speaking: ';

  @override
  String get iKnow => 'Got it';

  @override
  String get me => 'me';

  @override
  String get live => 'Live';

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
  String get closeWhiteBoard => 'Stop Whiteboard';

  @override
  String get lockMeetingByHost =>
      'The meeting is locked. New participants cannot join the meeting';

  @override
  String get lockMeetingByHostFail => 'Failed to lock the meeting';

  @override
  String get unLockMeetingByHost =>
      'The meeting is unlocked. New participants can join the meeting';

  @override
  String get unLockMeetingByHostFail => 'Failed to unlock the meeting';

  @override
  String get lockMeeting => 'Lock';

  @override
  String get inputMessageHint => 'Entering...';

  @override
  String get cannotSendBlankLetter => 'Unable to send empty messages';

  @override
  String get chat => 'Chat';

  @override
  String get more => 'More';

  @override
  String get searchMember => 'Search';

  @override
  String get enterChatRoomFail => 'Failed to join the chat room';

  @override
  String get newMessage => 'New message';

  @override
  String get unsupportedFileExtension => 'Unsupported file';

  @override
  String get fileSizeExceedTheLimit => 'File size cannot exceed 200MB';

  @override
  String get imageSizeExceedTheLimit => 'Image size cannot exceed 20MB';

  @override
  String get imageMessageTip => '[Image]';

  @override
  String get fileMessageTip => '[File]';

  @override
  String get saveToGallerySuccess => 'Saved to Album';

  @override
  String get saveToGalleryFail => 'Operation failed';

  @override
  String get saveToGalleryFailNoPermission => 'No permission';

  @override
  String get openFileFail => 'Opening file failed';

  @override
  String get openFileFailNoPermission => 'Opening file failed: no permission';

  @override
  String get openFileFailFileNotFound => 'Opening file failed: no file exists';

  @override
  String get openFileFailAppNotFound =>
      'Opening file failed: no app installed to open the file';

  @override
  String get meetingPassword => 'Meeting Password';

  @override
  String get inputMeetingPassword => 'Enter the meeting password';

  @override
  String get wrongPassword => 'Incorrect code';

  @override
  String get headsetState => 'You are using the earphone';

  @override
  String get copy => 'Copy';

  @override
  String get copySuccess => 'Copy succeeded';

  @override
  String get disableLiveAuthLevel =>
      'Editing live streaming permission is not allowed during streaming';

  @override
  String get host => 'HOST';

  @override
  String get coHost => 'CO_HOST';

  @override
  String get meetingInfoDesc => 'The meeting is being encrypted and protected';

  @override
  String get networkUnavailableCloseFail =>
      'Ending meeting failed due to the network error';

  @override
  String get muteAllHandsUpTips =>
      'The host has muted all participants. You can raise your hand';

  @override
  String get muteAllVideoHandsUpTips =>
      'The host has turned off all videos. You can raise your hand';

  @override
  String get alreadyHandsUpTips => 'You are raising hand, waiting for response';

  @override
  String get handsUpApply => 'Raise hand';

  @override
  String get cancelHandsUp => 'Lower hand';

  @override
  String get cancelHandsUpTips => 'Are you sure you want to lower hand?';

  @override
  String get handsUpDown => 'Lower hand';

  @override
  String get whiteBoardInteract => 'Grant the whiteboard permission';

  @override
  String get whiteBoardInteractFail =>
      'Failed to grant the whiteboard permission';

  @override
  String get undoWhiteBoardInteract => 'Revoke the whiteboard permission';

  @override
  String get undoWhiteBoardInteractFail =>
      'Failed to revoke the whiteboard permission';

  @override
  String get inHandsUp => 'Raising';

  @override
  String get handsUpFail => 'Failed to raise hand';

  @override
  String get handsUpSuccess => 'You are raising hand, waiting for response';

  @override
  String get cancelHandsUpFail => 'Failed to lower hand';

  @override
  String get hostRejectAudioHandsUp => 'The host rejected your request';

  @override
  String get sipTip => 'SIP';

  @override
  String get meetingInviteUrl => 'Meeting URL';

  @override
  String get meetingInvitePageTitle => 'Add Participants';

  @override
  String get sipNumber => 'SIP Call';

  @override
  String get sipHost => 'SIP Address';

  @override
  String get inviteListTitle => 'Invitation List';

  @override
  String get invitationSendSuccess => 'Invitation sent';

  @override
  String get invitationSendFail => 'Invitation failed';

  @override
  String get meetingLive => 'Live Meeting';

  @override
  String get meetingLiveTitle => 'Title';

  @override
  String get meetingLiveUrl => 'Live URL';

  @override
  String get pleaseInputLivePassword => 'Enter the live code';

  @override
  String get pleaseInputLivePasswordHint => 'Enter a 6-digit code';

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
  String get livePickerCount => 'Selected';

  @override
  String get livePickerCountPrefix => 'people';

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
  String get editWhiteBoard => 'Edit';

  @override
  String get packUpWhiteBoard => 'Hide';

  @override
  String get noAuthorityWhiteBoard =>
      'Whiteboard is unactivated. contact sales for activating the service';

  @override
  String get ok => 'Got it';

  @override
  String get removedByHost => 'You are removed';

  @override
  String get closeByHost => 'Meeting ended';

  @override
  String get loginOnOtherDevice => 'Switched to another device';

  @override
  String get authInfoExpired =>
      'Network error, please check your network connection and rejoin the meeting';

  @override
  String get syncDataError => 'Failed to sync the room information';

  @override
  String get leaveMeetingBySelf => 'Leave';

  @override
  String get meetingClosed => 'Meeting is closed';

  @override
  String get connectFail => 'Connection failed';

  @override
  String get joinTimeout => 'Joining meeting timeout, try again later';

  @override
  String get endOfLife =>
      'Meeting is closed because the meeting duration reached the upper limit. ';

  @override
  String get endMeetingTip => 'Remaining ';

  @override
  String get min => 'minutes';

  @override
  String get reuseIMNotSupportAnonymousJoinMeeting =>
      'IM reuse does not support anonymous login';

  @override
  String get inviteDialogTitle => 'Meeting Invite';

  @override
  String get inviteContentCopySuccess => 'Meeting invitation copied';

  @override
  String get inviteTitle => 'Invite your to join the meeting \n\n';

  @override
  String get meetingSubject => 'Subject: ';

  @override
  String get meetingTime => 'Time: ';

  @override
  String get meetingNum => 'Meeting number: ';

  @override
  String get shortMeetingNum => 'Short Meeting number: ';

  @override
  String get invitationUrl => 'Meeting URL: ';

  @override
  String get meetingPwd => 'Meeting Password: ';

  @override
  String get copyInvite => 'Copy invitation';

  @override
  String get internalSpecial => 'Internal';

  @override
  String get notWork => 'Unavailable';

  @override
  String get needPermissionTipsFirst => 'Allow';

  @override
  String get needPermissionTipsTail => ' to access your ';

  @override
  String get funcNeed => 'The feature requires ';

  @override
  String get toSetUp => 'Go to';

  @override
  String get permissionTips => 'Permission';

  @override
  String get cameraPermission => 'Camera';

  @override
  String get microphonePermission => 'Microphone';

  @override
  String get bluetoothPermission => 'Bluetooth';

  @override
  String get phoneStatePermission => 'Phone';

  @override
  String get noPermission => 'No permission';

  @override
  String get permissionRationalePrefix =>
      'To make audio and video call, you must request ';

  @override
  String get permissionRationaleSuffixAudio => ' permission for audio calling';

  @override
  String get permissionRationaleSuffixVideo => ' permission for video calling';

  @override
  String get menuTitleParticipants => 'Participants';

  @override
  String get menuTitleManagerParticipants => 'Participants';

  @override
  String get menuTitleInvite => 'Invite';

  @override
  String get menuTitleChatroom => 'Chat';

  @override
  String get menuTitleShareWhiteboard => 'Whiteboard';

  @override
  String get menuTitleCloseWhiteboard => 'Stop';

  @override
  String get notificationContentTitle => 'Video Meeting';

  @override
  String get notificationContentText => 'Meeting is ongoing';

  @override
  String get notificationContentTicker => 'Video meeting';

  @override
  String get notificationChannelId => 'ne_meeting_channel';

  @override
  String get notificationChannelName => 'Video meeting notification';

  @override
  String get notificationChannelDesc => 'Video meeting notification';

  @override
  String get delete => 'Delete';

  @override
  String get nothing => 'None';

  @override
  String get virtualBackgroundSelectTip =>
      'Effective when the image is selected';

  @override
  String get onUserJoinMeeting => ' join the meeting';

  @override
  String get onUserLeaveMeeting => ' leave';

  @override
  String get userHasBeenAssignCoHostRole => ' has been assigned CO-HOST';

  @override
  String get userHasBeenRevokeCoHostRole => ' has been unassigned CO-HOST';

  @override
  String get isInCall => 'Answering the phone now';

  @override
  String get networkConnectionGood => 'Network connection is good';

  @override
  String get networkConnectionGeneral => 'Network connection is general';

  @override
  String get networkConnectionPoor => 'Network connection is poor';

  @override
  String get localLatency => 'Latency';

  @override
  String get packetLossRate => 'Packet Loss Rate';

  @override
  String get startAudioShare => 'Start Sharing system audio';

  @override
  String get stopAudioShare => 'Stop sharing system audio';

  @override
  String get switchFcusView => 'Switch to Focus view';

  @override
  String get switchGalleryView => 'Switch to Gallery view';

  @override
  String get noSupportSwitch => 'iPad does not support switching modes';

  @override
  String get funcNotAvailableWhenInCallState =>
      'Cannot use this feature while on a call';
}
