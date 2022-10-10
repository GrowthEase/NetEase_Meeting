import { memberAction, hostAction, Role } from '../libs/enum'
import {
  NERoomChatController,
  NERoomContext,
  NERoomRtcController,
  NERoomWhiteboardController,
} from 'neroom-web-sdk'

export interface ImInfo {
  nim: any
  imAccid: string
  imAppKey: string
  imToken: string
  nickName: string
  chatRoomId: string
}

type VideoProfile = {
  resolution: number // 设置视频分辨率 1080 720 480 180
  frameRate: number // 设置帧率25 20 15 10 5
}

type ChatroomConfig = {
  tags?: string[]
  enableDirectionalTransmission?: boolean
  defaultDirectionalTags?: string[]
  enableFileMessage?: boolean
  enableImageMessage?: boolean
}

type LoginResponse = {
  userUuid: string
  userToken: string
  nickname: string
  privateMeetingNum: string // 个人会议号
}

export type AccountInfo = {
  nickname: string
  privateMeetingNum: string
  settings: any
}

export type AnonymousLoginResponse = {
  imKey: string
  imToken: string
  rtcKey: string
  userToken: string
  userUuid: string
  privateMeetingNum?: string
}

type GetMeetingConfigResponse = {
  deviceConfig?: any
  appConfig: {
    APP_ROOM_RESOURCE: {
      whiteboard: boolean
      chatroom: boolean
      live: boolean
      rtc: boolean
    }
    MEETING_BEAUTY?: {
      licenseUrl: string
      md5: string
      levels: any[]
    }
    MEETING_RECORD?: {
      mode: number
      videoEnabled: boolean
      audioEnabled: boolean
    }
    MEETING_VIRTUAL_BACKGROUND?: {
      enable: boolean
    }
    ROOM_END_TIME_TIP?: {
      enable: boolean
    }
  }
}

type CreateMeetingResponse = {
  meetingId: number
  meetingNum: string
  roomUuid: string
  state: number
  startTime: number
  endTime: number
  subject: string
  type: number
  shortMeetingNum?: number
  settings: {
    roomInfo: {
      roomConfigId: number
      password?: string
      roomProperties?: Record<string, any>
    }
  }
}

interface NeMeeting {
  meetingId: string
  webrtc: any
  personalMeetingId: string
  avRoomUid: number
  meetingStatus: string
  microphoneId: string
  cameraId: string
  speakerId: string
  NIMconf: any
  neRtcServerAddresses: NeRtcServerAddresses // G2私有化
  meetingInfo: any
  imInfo?: ImInfo
  roomContext: NERoomContextany
  rtcController: NERoomRtcController
  chatController: NERoomChatController
  whiteboardController: NERoomWhiteboardController
  previewController: any
  showMemberTag?: boolean // 是否显示成员tag
  showMaxCount?: boolean // 是否显示会议最大人数
  showSubject?: boolean // 顶部是否显示会议主题
  showFocusBtn?: boolean // 是否显示设置焦点后画面右上角的按钮， 默认为true
  videoProfile?: VideoProfile // 设置媒体属性
  enableSortByVoice?: boolean // 设置是否根据声音大小动态排序 默认为true
  enableSetDefaultFocus?: boolean // 是否设置主持人为默认焦点画面
  localMember?: any
  roomDeviceId: string
  login(options: any): Promise<void>
  leave(role?: string): Promise<void>
  end(): Promise<void>
  create(options: object): Promise<void>
  join(options?: object): Promise<any>
  on(event: string, handler: Function): void
  once(type: string | number, handler: Function): void
  off(event: string, handler: Function): void
  removeAllListeners(event: string): void
  eventNames(): Array<string | number>
  initConf(val: any): void
  getMeetingInfo(avRoomUid?: string): Promise<any>
  sendMemberControl(type: memberAction, avRoomUid?: Array<string>): Promise<any>
  muteLocalAudio(need?: boolean): Promise<any>
  unmuteLocalAudio(deviceId?: string, need?: boolean): Promise<any>
  muteLocalVideo(need?: boolean): Promise<any>
  unmuteLocalVideo(
    deviceId?: string,
    need?: boolean,
    videoProfile?: VideoProfile
  ): Promise<any>
  muteLocalScreenShare(): Promise<any>
  unmuteLocalScreenShare(sourceId?: string): Promise<any>
  getMicrophones(): Promise<any>
  getCameras(): Promise<any>
  getSpeakers(): Promise<any>
  selectSpeakers(speakerId: string)
  changeLocalAudio(deviceId: string): Promise<any>
  changeLocalVideo(deviceId: string, boolean): Promise<any>
  setCaptureVolume(volume: number): void
  getAudioLevel(): void
  getCameraStram(deviceId: string): Promise<any>
  sendHostControl(
    type: hostAction,
    accountIds?: Array<string>,
    avRoomUid?: Array<string>,
    data?: any
  ): Promise<any>
  resetStatus(): void
  modifyNickName(options: { nickName: string }): Promise<void>
  getGlobalConfig(): Promise<GetMeetingConfigResponse>
  whiteBoardGlobalConfig: any
  recordGlobalConfig: any
  destroy(): void
  destroyRoomContext(): Promise<void>
  getLayout(): Layout | null
  setVideoProfile(resolution: number, frameRate: number): void
  setCanvas(userUuid: string, type: 'video' | 'screen'): void
  addSipMember(sipNum: string, sipHost: string): Promise<void>
  getSipMemberList(): Promise<{ list: SipMember[] }>
  anonymousJoin(options?: object): Promise<any>
  removeGlobalEventListener(): void
}

interface NeMember {
  accountId: string
  nickName: string
  video: number
  audio: number
  screenSharing: number
  avRoomUid: number
  status: number
  stream?: any
  isHost?: boolean
  isFocus?: boolean
  isActiveSpeaker?: boolean
  role: Role
  roleType?: number
}

export interface SipMember {
  sipNum: string
  sipHost: string
  status: 1 | 2 | 3 | 4 // 邀请状态，1.邀请中，2.邀请成功，3.拒绝，4.挂断 |
  inviterUid: string // 邀请人id
}

interface Theme {
  headerBgColor?: string
  headerColor?: string
  contentBgColor?: string
  contentColor?: string
  controlBarBgColor?: string
  controlBarColor?: string
  videoBgColor?: string
}

interface MeetingControl {
  type: 'audio' | 'video' | 'whiteboard'
  state: 1 | 0 // 全局控制状态，1：全体关闭控制，0：取消全体关闭控制(初始根据attendeeOff后端设置，后续根据会控会变化)
  attendeeOff: 0 | 1 | 2 // 入会后自动关闭，0：无，1：关闭，2：关闭且不能自行操作，默认不操作(该字段为创建会议时候传入，后续不会更改)
  allowSelfOn: boolean // 允许自行解除关闭控制，true：允许，false：不允许，默认允许(初始根据attendeeOff后端设置，后续根据会控会变化, 该字段如果为false也需要根据state判断是否能够开启)
}
interface Layout {
  canvas: {
    // 画布数据
    height: number
    width: number
  }
  users: Array<LayoutUser> // 每个成员布局数据
}

interface LayoutUser {
  uid: string
  x: number
  y: number
  width: number
  height: number
  isScreen?: boolean
}

interface NeRtcServerAddresses {
  channelServer?: string // 通道信息服务器地址
  mediaServer?: string // mediaServer服务器地址
  roomServer?: string // roomServer服务器地址
  statisticsServer?: string // 统计上报服务器地址
}

interface NoMuteAllConfig {
  noMuteAllVideo: boolean // 配置会议中成员列表是否显示"全体关闭/打开视频"，默认为true，即不显示
  noMuteAllAudio: boolean // 配置会议中成员列表是否显示"全体禁音/解除全体静音"，默认为false，即显示
}

interface MuteBtnConfig {
  // 四个按钮独立配置显示
  showMuteAllVideo: boolean // 显示全体关闭视频按钮
  showUnMuteAllVideo: boolean // 显示全体开启按钮
  showMuteAllAudio: boolean // 显示全体静音按钮
  showUnMuteAllAudio: boolean // 显示全体解除静音按钮
}
export interface DeviceInfo {
  deviceId: string
  label: string
}

interface StreamState {
  isVideoOn: boolean
  isAudioOn: boolean
  isSharingScreen: boolean
}
export {
  NeMeeting,
  NeMember,
  Theme,
  MeetingControl,
  Layout,
  LayoutUser,
  NeRtcServerAddresses,
  NoMuteAllConfig,
  VideoProfile,
  MuteBtnConfig,
  ChatroomConfig,
  LoginResponse,
  CreateMeetingResponse,
  GetMeetingConfigResponse,
  StreamState,
}
