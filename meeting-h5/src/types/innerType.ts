import Eventemitter from 'eventemitter3'
import NEMeetingService from '../services/NEMeeting'
import { ReactNode } from 'react'
import { Roomkit } from 'neroom-web-sdk'
import {
  NEEncryptionConfig,
  NEMeeting,
  NEMeetingInfo,
  NEMeetingSDK,
  NEMember,
  Role,
  VideoFrameRate,
  VideoResolution
} from "./type";
import { Logger } from '../utils/Logger'
import { IntervalEvent } from '@xkit-yx/utils'

/**
 * 内部使用的类型不对外暴露
 * 对外暴露类型放入type中
 */
export interface CreateMeetingResponse {
  meetingId: number
  meetingNum: string
  roomUuid: string
  state: number
  startTime: number
  endTime: number
  subject: string
  meetingInviteUrl: string
  meetingCode: string
  type: number
  shortMeetingNum?: number
  meetingUserUuid?: string // 跨应用加入房间使用的userUuid
  meetingUserToken?: string // 跨应用加入房间使用的userToken
  meetingAppKey?: string // 跨应用加入房间使用的appKey
  roomArchiveId: string
  settings: {
    roomInfo: {
      roomConfigId: number
      roomConfig: {
        resource: {
          chatroom: boolean
          live: boolean
          record: boolean
          rtc: boolean
          sip: boolean
          whiteboard: boolean
        }
      }
      password?: string
      roomProperties?: Record<string, any>
    }
    liveConfig?: {
      liveAddress: string
    }
  }
}

export interface LoginResponse {
  userUuid: string
  userToken: string
  nickname: string
  privateMeetingNum: string // 个人会议号
  shortMeetingNum: string // 个人会议短号
}

export interface AccountInfo {
  nickname: string
  meetingNum: string
  shortMeetingNum: string // 个人会议短号
}

export interface AnonymousLoginResponse {
  imKey: string
  imToken: string
  rtcKey: string
  userToken: string
  userUuid: string
  privateMeetingNum?: string
}

export interface LoginOptions {
  accountId: string
  accountToken: string
}

export enum EventType {
  MemberAudioMuteChanged = 'memberAudioMuteChanged',
  MemberJoinRoom = 'memberJoinRoom',
  MemberNameChanged = 'memberNameChanged',
  MemberJoinRtcChannel = 'memberJoinRtcChannel',
  MemberLeaveChatroom = 'memberLeaveChatroom',
  MemberLeaveRoom = 'memberLeaveRoom',
  MemberLeaveRtcChannel = 'memberLeaveRtcChannel',
  MemberRoleChanged = 'memberRoleChanged',
  MemberScreenShareStateChanged = 'memberScreenShareStateChanged',
  MemberVideoMuteChanged = 'memberVideoMuteChanged',
  MemberWhiteboardStateChanged = 'memberWhiteboardStateChanged',
  RoomPropertiesChanged = 'roomPropertiesChanged',
  RoomLockStateChanged = 'roomLockStateChanged',
  MemberPropertiesChanged = 'memberPropertiesChanged',
  MemberPropertiesDeleted = 'memberPropertiesDeleted',
  RoomPropertiesDeleted = 'roomPropertiesDeleted',
  RoomEnded = 'roomEnded',
  RtcActiveSpeakerChanged = 'rtcActiveSpeakerChanged',
  RtcChannelError = 'rtcChannelError',
  RtcAudioVolumeIndication = 'rtcAudioVolumeIndication',
  RoomLiveStateChanged = 'roomLiveStateChanged',
  NetworkQuality = 'networkQuality',
  RtcStats = 'rtcStats',
  RoomConnectStateChanged = 'roomConnectStateChanged',
  CameraDeviceChanged = 'cameraDeviceChanged',
  PlayoutDeviceChanged = 'playoutDeviceChanged',
  RecordDeviceChanged = 'recordDeviceChanged',
  ReceiveChatroomMessages = 'receiveChatroomMessages',
  ChatroomMessageAttachmentProgress = 'chatroomMessageAttachmentProgress',
  ReceivePassThroughMessage = 'receivePassThroughMessage',
  ReceiveScheduledMeetingUpdate = 'receiveScheduledMeetingUpdate',
  DeviceChange = 'deviceChange',
  NetworkError = 'networkError',
  ClientBanned = 'ClientBanned', // 用户被踢
  AutoPlayNotAllowed = 'autoplayNotAllowed',
  NetworkReconnect = 'networkReconnect',
  NetworkReconnectSuccess = 'networkReconnectSuccess',
  CheckNeedHandsUp = 'checkNeedHandsUp',
  NeedVideoHandsUp = 'needVideoHandsUp',
  NeedAudioHandsUp = 'needAudioHandsUp',
  MeetingExits = 'meetingExits',
  roomRemainingSecondsRenewed = 'roomRemainingSecondsRenewed',
}

export enum MeetingEventType {
  rtcChannelError = 'rtcChannelError',
}

export enum UserEventType {
  Login = 'login',
  Logout = 'logout',
  LoginWithPassword = 'loginWithPassword',
  CreateMeeting = 'createMeeting',
  JoinMeeting = 'joinMeeting',
  AnonymousJoinMeeting = 'anonymousJoinMeeting',
  SetLeaveCallback = 'setLeaveCallback',
  RejoinMeeting = 'rejoinMeeting',
}

export enum memberAction {
  muteAudio = 51,
  unmuteAudio = 56,
  muteVideo = 50,
  unmuteVideo = 55,
  muteScreen = 52,
  unmuteScreen = 57,
  handsUp = 58,
  handsDown = 59,
  openWhiteShare = 60,
  closeWhiteShare = 61,
  shareWhiteShare = 62,
  cancelShareWhiteShare = 63,
  modifyMeetingNickName = 104,
}

export enum hostAction {
  remove = 0,
  muteMemberVideo = 10,
  muteMemberAudio = 11,
  muteAllAudio = 12,
  lockMeeting = 13,
  muteAllVideo = 14,
  unmuteMemberVideo = 15,
  unmuteMemberAudio = 16,
  unmuteAllAudio = 17,
  unlockMeeting = 18,
  unmuteAllVideo = 19,
  muteVideoAndAudio = 20,
  unmuteVideoAndAudio = 21,
  transferHost = 22,
  setCoHost = 23, // 设置联席主持人
  unSetCoHost = 9999, // 取消设置联席主持人
  setFocus = 30,
  unsetFocus = 31,
  forceMuteAllAudio = 40,
  // agreeHandsUp = 41,
  rejectHandsUp = 42,
  forceMuteAllVideo = 43,
  closeScreenShare = 53,
  openWhiteShare = 60,
  closeWhiteShare = 61,
}

export type NERoomChatMessageType =
  | 'text'
  | 'image'
  | 'audio'
  | 'video'
  | 'file'
  | 'geo'
  | 'custom'
  | 'tip'
  | 'notification'

/**
 * 房间内聊天消息
 */
export interface NERoomChatMessage {
  fromClientType: 'Android' | 'iOS' | 'PC' | 'Web' | 'Mac'
  /**
   * 消息类型
   */
  messageType: NERoomChatMessageType
  /**
   * 发送端用户ID。如果为空字符串，则说明该用户可能未加入房间内。
   */
  fromUserUuid: string
  /**
   * 发送端昵称
   */
  fromNick: string
  /**
   * 接收端; 为空表示聊天室全体成员
   */
  toUserUuidList?: string[]
  /**
   * 消息时间戳
   */
  time: number
  /**
   * 消息类型
   */
  type: string
  /**
   * 文本内容
   */
  text: string
  /**
   * 消息状态
   */
  status: string
  /**
   * 附加信息
   */
  attach?: {
    from: string
    fromNick: string
    type: string
    to: string[]
    toNick: string[]
  }
  /**
   * 消息来源
   */
  from: string
  /**
   * 消息是否来自自己
   */
  isMe?: boolean
  /**
   * 重发
   */
  resend?: boolean
  /**
   * 客户端唯一ID
   */
  idClient?: string
}
export interface GlobalProviderProps {
  eventEmitter: Eventemitter
  outEventEmitter: Eventemitter
  neMeeting: NEMeetingService
  children: ReactNode
  globalConfig: GetMeetingConfigResponse
  joinLoading?: boolean
  logger: Logger
  showMeetingRemainingTip?: boolean
}
export interface MeetingInfoProviderProps {
  meetingInfo: NEMeetingInfo
  memberList: NEMember[]
  children: ReactNode
}

export type Dispatch = (params: Action<ActionType>) => void
export interface GlobalContext {
  name?: string
  joinLoading?: boolean
  showSubject?: boolean
  roomkit?: Roomkit
  eventEmitter?: Eventemitter
  outEventEmitter?: Eventemitter
  neMeeting?: NEMeetingService
  dispatch?: Dispatch
  logger?: Logger
  globalConfig?: GetMeetingConfigResponse
  showMeetingRemainingTip?: boolean
  waitingRejoinMeeting?: boolean // 正在重新加入会议
  online?: boolean
}

export type GetMeetingConfigResponse = {
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

export interface MeetingInfoContextInterface {
  meetingInfo: NEMeetingInfo
  memberList: NEMember[]
  dispatch?: Dispatch
}
export interface Action<T extends ActionType> {
  type: T
  data: ActionHandleType<T>
}

export interface ActionHandle {
  [ActionType.UPDATE_NAME]: { name: string }
  [ActionType.UPDATE_GLOBAL_CONFIG]: Partial<GlobalContext>
  [ActionType.RESET_NAME]: never
  [ActionType.UPDATE_MEMBER]: { uuid: string; member: Partial<NEMember> }
  [ActionType.DELETE_MEMBER_PROPERTIES]: { uuid: string; properties: string[] }
  [ActionType.ADD_MEMBER]: { member: NEMember }
  [ActionType.REMOVE_MEMBER]: { uuids: string[] }
  [ActionType.RESET_MEMBER]: null
  [ActionType.UPDATE_MEETING_INFO]: Partial<NEMeetingInfo>
  [ActionType.SET_MEETING]: NEMeeting | NEMeetingSDK
  [ActionType.RESET_MEETING]: null
  [ActionType.JOIN_LOADING]: boolean
}

export type ActionHandleType<T extends ActionType> = ActionHandle[T]

export enum ActionType {
  UPDATE_GLOBAL_CONFIG = 'updateGlobalConfig',
  UPDATE_NAME = 'updateName',
  RESET_NAME = 'resetName',
  UPDATE_MEMBER = 'updateMember',
  RESET_MEMBER = 'resetMember',
  DELETE_MEMBER_PROPERTIES = 'deleteMemberProperties',
  ADD_MEMBER = 'addMember',
  REMOVE_MEMBER = 'removeMember',
  UPDATE_MEETING_INFO = 'updateMeetingInfo',
  SET_MEETING = 'setMeeting',
  RESET_MEETING = 'resetMeeting',
  JOIN_LOADING = 'joinLoading',
}

export enum BrowserType {
  WX = 'WX',
  UC = 'UC',
  QQ = 'QQ',
  UNKNOWN = 'unknown',
  OTHER = 'other',
}

export interface IMInfo {
  nim: any
  imAccid: string
  imAppKey: string
  imToken: string
  nickName: string
  chatRoomId: string
}

export type MeetingAccountInfo = {
  nickname: string
  privateMeetingNum: string
  shortMeetingNum: string // 个人会议短号
}

export interface NEMeetingLoginByPasswordOptions {
  username: string
  password: string
  loginType: LoginType.LoginByPassword
  loginReport?: IntervalEvent
}
export interface NEMeetingLoginByTokenOptions {
  accountId: string
  accountToken: string
  loginType: LoginType.LoginByToken
  loginReport?: IntervalEvent
}
export enum LoginType {
  LoginByToken = 1,
  LoginByPassword = 2,
}

export interface NEMeetingGetListOptions {
  startTime: number
  endTime: number
}

export interface NEMeetingCreateOptions extends NEMeetingBaseOptions {
  video?: number
  audio?: number
  subject?: string
  roleBinds?: Record<string, string>
  noSip?: boolean
  noChat?: boolean
  openLive?: boolean
  liveOnlyEmployees?: boolean
  noCloudRecord?: boolean
  extraData?: string
  attendeeAudioOff?: boolean
  attendeeVideoOff?: boolean
  startTime?: number
  endTime?: number
  createMeetingReport: IntervalEvent
}
interface NEMeetingBaseOptions {
  meetingId?: number
  meetingNum: string // 原先使用meetingId后续兼容meetingNum
  nickName: string
  password?: string
  memberTag?: string
  noChat?: boolean
  /**
   * 视频分辨率及帧率设置
   */
  videoProfile?: {
    resolution: VideoResolution
    frameRate: VideoFrameRate
  }
  encryptionConfig?: NEEncryptionConfig
}
export interface NEMeetingJoinOptions extends NEMeetingBaseOptions {
  role?: Role
  joinMeetingReport?: IntervalEvent
}

export interface JoinHandlerOptions {
  role?: Role
  meetingId: string
  meetingNum?: string // 原先使用meetingId后续兼容meetingNum
  nickName: string
  password?: string
  memberTag?: string
  noChat?: boolean
  /**
   * 视频分辨率及帧率设置
   */
  videoProfile?: {
    resolution: VideoResolution
    frameRate: VideoFrameRate
  }
  encryptionConfig?: NEEncryptionConfig
  joinMeetingReport?: IntervalEvent
}

export enum MeetingErrorCode {
  MeetingNumIncorrect = -5,
  ReuseIMError = 112001,
  RtcNetworkError = 10002, // rtc所有的服务器地址都连接失败 <NETWORK_ERROR 10002>
}

export enum LayoutTypeEnum {
  Gallery = 'gallery',
  Speaker = 'speaker',
}

export interface Speaker {
  uid: string
  nickName: string
  level: number // 声音大小
}

export interface NELiveMember {
  accountId: string
  isVideoOn: boolean
  isSharingScreen: boolean
  nickName: string
}

export enum NEMenuIDs { // 菜单项ID
  mic = 0,
  camera = 1,
  screenShare = 2,
  participants = 3,
  manageParticipants = 4,
  gallery = 5,
  invite = 20,
  chat = 21,
  whiteBoard = 22,
  myVideoControl = 23,
  sip = 24,
  live = 25,
}

export enum SingleMeunIds { // 单状态按钮
  participants = 3,
  manageParticipants = 4,
  invite = 20,
  chat = 21,
}

export enum MutipleMenuIds { // 多状态按钮
  mic = 0,
  camera = 1,
  screenShare = 2,
  gallery = 5,
  whiteBoard = 22,
}

export enum NEMenuVisibility {
  VISIBLE_ALWAYS = 0, // 默认总是可见
  VISIBLE_EXCLUDE_HOST = 1, // 仅主持人可见
  VISIBLE_TO_HOST_ONLY = 2, // 非主持人可见
}

export interface MeetingSetting {
  normalSetting: {
    openVideo: boolean
    openAudio: boolean
    showDurationTime: boolean
    showSpeakerList: boolean
    showToolbar: boolean
    enableTransparentWhiteboard: boolean
  }
  videoSetting: {
    deviceId: string
    resolution: number
    // 是否开启视频镜像
    enableVideoMirroring: boolean
  }
  audioSetting: {
    recordDeviceId: string
    playoutDeviceId: string
    enableUnmuteBySpace: boolean
    recordVolume: number
    playoutVolume: number
    recordOutputVolume: number
    playouOutputtVolume: number
  }
}

export enum StaticReportType {
  MeetingKit_login = 'MeetingKit_login',
  Account_info = 'account_info',
  Roomkit_login = 'roomkit_login',
  MeetingKit_start_meeting = 'MeetingKit_start_meeting',
  MeetingKit_join_meeting = 'MeetingKit_join_meeting',
  Create_room = 'create_room',
  Join_room = 'join_room',
  Join_rtc = 'join_rtc',
  Server_join_rtc = 'server_join_rtc',
  Anonymous_login = 'anonymous_login',
  Meeting_info = 'meeting_info',
  MeetingKit_meeting_end = 'MeetingKit_meeting_end',
}
