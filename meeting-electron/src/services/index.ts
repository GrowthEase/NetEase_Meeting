import {
  AttendeeOffType,
  LayoutTypeEnum,
  NEClientType,
  NEMeetingInfo,
  NEMenuIDs,
  RecordState,
  Role,
} from '../types'

export const defaultMenus = [
  // 默认主区
  { id: NEMenuIDs.mic },
  { id: NEMenuIDs.camera },
  { id: NEMenuIDs.security },
  { id: NEMenuIDs.screenShare },
  { id: NEMenuIDs.whiteBoard },
  { id: NEMenuIDs.participants },
  { id: NEMenuIDs.record },
  { id: NEMenuIDs.chat },
  { id: NEMenuIDs.invite },
  { id: NEMenuIDs.setting },
]

export const defaultMoreMenus = [
  // 默认更多区域
  { id: NEMenuIDs.sip },
  { id: NEMenuIDs.live },
]

// H5默认主区
export const defaultMenusInH5 = [
  { id: NEMenuIDs.mic },
  { id: NEMenuIDs.camera },
  { id: NEMenuIDs.participants },
  { id: NEMenuIDs.chat },
]

// H5默认更多区域
export const defaultMoreMenusInH5 = []

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
    isLocked: false,
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
    setting: {
      normalSetting: {
        openVideo: false,
        openAudio: false,
        showDurationTime: false,
        showSpeakerList: true,
        showToolbar: true,
        enableTransparentWhiteboard: false,
        downloadPath: '',
        language: '',
      },
      videoSetting: {
        deviceId: '',
        resolution: 720,
        enableVideoMirroring: true,
        isDefaultDevice: false,
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
        recordOutputVolume: 75,
        playouOutputtVolume: 25,
        enableAudioAI: true,
        enableMusicMode: false,
        enableAudioEchoCancellation: true,
        enableAudioStereo: true,
      },
      beautySetting: {
        beautyLevel: 0,
        virtualBackgroundPath: '',
      },
    },
    isCloudRecording: false,
    cloudRecordState: RecordState.NotStart,
    rightDrawerTabs: [],
    activeMemberManageTab: 'room',
  }
}
