import { NERoomCaptionTranslationLanguage } from 'neroom-types'
import { PLAYOUT_DEFAULT_VOLUME, RECORD_DEFAULT_VOLUME } from '../config'
import {
  AttendeeOffType,
  LayoutTypeEnum,
  MeetingSetting,
  NEClientType,
  NEMeetingInfo,
  NEMenuIDs,
  RecordState,
  LocalRecordState,
  Role,
} from '../types'

export const defaultMenus = [
  // 默认主区
  { id: NEMenuIDs.mic },
  { id: NEMenuIDs.camera },
  { id: NEMenuIDs.security },
  { id: NEMenuIDs.invite },
  { id: NEMenuIDs.participants },
  { id: NEMenuIDs.chat },
  { id: NEMenuIDs.screenShare },
  { id: NEMenuIDs.whiteBoard },
  { id: NEMenuIDs.record },
  { id: NEMenuIDs.emoticons },
]

export const defaultMoreMenus = [
  // 默认更多区域
  { id: NEMenuIDs.notification },
  { id: NEMenuIDs.sip },
  { id: NEMenuIDs.annotation },
  { id: NEMenuIDs.caption },
  { id: NEMenuIDs.transcription },
  { id: NEMenuIDs.interpretation },
  { id: NEMenuIDs.live },
  { id: NEMenuIDs.setting },
  { id: NEMenuIDs.feedback },
]

// H5默认主区
export const defaultMenusInH5 = [
  { id: NEMenuIDs.mic },
  { id: NEMenuIDs.camera },
  { id: NEMenuIDs.participants },
  { id: NEMenuIDs.chat },
]

// H5默认更多区域
export const defaultMoreMenusInH5 = [
  { id: NEMenuIDs.notification },
  { id: NEMenuIDs.interpretation },
  { id: NEMenuIDs.caption },
  { id: NEMenuIDs.setting },
]

export const defaultSmallMenus = [
  { id: NEMenuIDs.mic },
  { id: NEMenuIDs.camera },
  { id: NEMenuIDs.myVideoControl },
  // {
  //   id: 1111,
  //   type: 'single',
  //   btnConfig: {
  //     icon: 'https://zos.alipayobjects.com/rmsportal/hfVtzEhPzTUewPm.png'
  //   },
  //   injectItemClick() {
  //     console.log(666)
  //   }
  // },
  // {
  //   id: 1121,
  //   type: 'multiple',
  //   btnStatus: false,
  //   btnConfig: [
  //     {
  //       icon: 'https://zos.alipayobjects.com/rmsportal/hfVtzEhPzTUewPm.png',
  //       status: true
  //     },
  //     {
  //       icon: 'https://zos.alipayobjects.com/rmsportal/dKbkpPXKfvZzWCM.png',
  //       status: false
  //     }
  //   ],
  //   injectItemClick(item) {
  //     console.log(777)
  //     item.btnStatus = !item.btnStatus;
  //   }
  // }
]

export function createDefaultSetting(): MeetingSetting {
  return {
    normalSetting: {
      openVideo: false,
      openAudio: false,
      showDurationTime: false,
      showParticipationTime: false,
      showTimeType: 0, // 0: DurationTime, 1: ParticipationTime
      showSpeakerList: true,
      showToolbar: true,
      enableTransparentWhiteboard: false,
      enableVoicePriorityDisplay: true,
      downloadPath: '',
      language: '',
      chatMessageNotificationType: 0,
      foldChatMessageBarrage: false,
      enableShowNotYetJoinedMembers: true,
      automaticSavingOfMeetingChatRecords: false,
      leaveTheMeetingRequiresConfirmation: true,
      enterFullscreen: false,
      dualMonitors: false,
    },
    videoSetting: {
      deviceId: '',
      resolution: 720,
      enableVideoMirroring: true,
      enableFrontCameraMirror: false,
      isDefaultDevice: false,
      galleryModeMaxCount: 16,
      showMemberName: true,
    },
    audioSetting: {
      recordDeviceId: '',
      isDefaultRecordDevice: true,
      playoutDeviceId: '',
      isDefaultPlayoutDevice: true,
      enableAudioVolumeAutoAdjust: true,
      enableUnmuteBySpace: true,
      recordVolume: 0,
      playoutVolume: 0,
      recordOutputVolume: RECORD_DEFAULT_VOLUME,
      playouOutputtVolume: PLAYOUT_DEFAULT_VOLUME,
      enableAudioAI: true,
      enableMusicMode: false,
      enableAudioEchoCancellation: true,
      enableAudioStereo: true,
      usingComputerAudio: false,
    },
    beautySetting: {
      beautyLevel: 0,
      virtualBackgroundPath: '',
      enableVirtualBackground: true,
      virtualBackgroundType: 2,
    },
    recordSetting: {
      autoCloudRecord: false,
      autoCloudRecordStrategy: 0,
      localRecordAudio: false,
      localRecordNickName: true,
      localRecordTimestamp: false,
      localRecordScreenShareAndVideo: false,
      localRecordScreenShareSideBySideVideo: false,
      localRecordDefaultPath: '',
      cloudRecordCurrentSpeakerWithSharedScreen: true,
      cloudRecordGalleryViewWithSharedScreen: false,
      cloudRecordSeparateRecordingCurrentSpeaker: false,
      cloudRecordSeparateRecordingGalleryView: false,
      cloudRecordSeparateRecordingSharedScreen: false,
      cloudRecordSeparateAudioFile: false,
    },
    captionSetting: createDefaultCaptionSetting(),
    screenShareSetting: {
      sideBySideModeOpen: false,
      screenShareOptionInMeeting: 0,
      sharedLimitFrameRateEnable: false,
      sharedLimitFrameRate: 20,
      noMoreScreenShareMessage: false,
    },
  }
}

export function createDefaultCaptionSetting(): MeetingSetting['captionSetting'] {
  return {
    autoEnableCaptionsOnJoin: false,
    fontSize: 15,
    targetLanguage: NERoomCaptionTranslationLanguage.NONE,
    showCaptionBilingual: false,
    showTranslationBilingual: false,
  }
}

export function createMeetingInfoFactory(): NEMeetingInfo {
  return {
    localMember: {
      isAudioConnected: true,
      uuid: '',
      isAudioOn: false,
      isInChatroom: false,
      isInRtcChannel: false,
      isSharingScreen: false,
      isVideoOn: false,
      isSharingWhiteboard: false,
      properties: {},
      clientType: NEClientType.WEB,
      inviteState: 0,
      role: Role.member,
      name: '',
    },
    ownerUserUuid: '',
    meetingNum: '',
    roomArchiveId: '',
    hostUuid: '',
    hostName: '',
    screenUuid: '',
    whiteboardUuid: '',
    annotationEnabled: false,
    isSupportChatroom: true,
    focusUuid: '',
    activeSpeakerUuid: '',
    properties: {},
    subject: '',
    startTime: 0,
    rtcStartTime: 0,
    endTime: 0,
    type: 0,
    shortMeetingNum: '',
    meetingInviteUrl: '',
    remainingSeconds: 0,
    myUuid: '',
    audioOff: AttendeeOffType.disable,
    videoOff: AttendeeOffType.disable,
    videoAllOff: false,
    audioAllOff: false,
    unmuteAudioBySelfPermission: false,
    unmuteVideoBySelfPermission: false,
    annotationPermission: true,
    whiteboardPermission: true,
    screenSharePermission: true,
    localRecordPermission: {
      all: false,
      host: true,
      some: false
    },
    updateNicknamePermission: true,
    emojiRespPermission: true,
    isLocked: false,
    isAllowParticipantsEnableCaption: true,
    liveConfig: {
      liveAddress: '',
    },

    mainVideoSize: {
      width: 0,
      height: 0,
    },
    enableSortByVoice: true,
    layout: LayoutTypeEnum.Speaker,
    speakerLayoutPlacement: 'top',
    enableTransparentWhiteboard: false,
    enableUnmuteBySpace: false,
    showSpeaker: true,
    showMeetingRemainingTip: true,
    renderModel: 'big',
    toolBarList: defaultMenus,
    moreBarList: defaultMoreMenus,
    setting: createDefaultSetting(),
    isCloudRecording: false,
    cloudRecordState: RecordState.NotStart,
    isCloudRecordingConfirmed: false,
    rightDrawerTabs: [],
    activeMemberManageTab: 'room',
    notificationMessages: [],
    privateChatMemberId: 'meetingAll',
    //本地录制相关的参数缺省值为false
    isLocalRecording: false,
    localRecordState: LocalRecordState.NotStart,
    isLocalRecordingConfirmed: false,
    isOtherLocalRecordingConfirmed: false,
    isOtherCloudRecordingStartConfirmed: false,
    isOtherCloudRecordingStopConfirmed: false
  }
}
