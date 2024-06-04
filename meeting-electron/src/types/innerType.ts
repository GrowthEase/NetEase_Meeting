import { IntervalEvent } from '@xkit-yx/utils'
import Eventemitter from 'eventemitter3'
import { Roomkit } from 'neroom-web-sdk'
import { NEWaitingRoomMember } from 'neroom-web-sdk/dist/types/types/interface'
import { ReactNode } from 'react'
import NEMeetingService from '../services/NEMeeting'
import { Logger } from '../utils/Logger'
import {
  AttendeeOffType,
  MoreBarList,
  NEEncryptionConfig,
  NEMeeting,
  NEMeetingIdDisplayOption,
  NEMeetingInfo,
  NEMeetingScheduledMember,
  NEMeetingSDK,
  NEMember,
  Role,
  ToolBarList,
  VideoFrameRate,
  VideoResolution,
} from './type'
import NEMeetingInviteService from '../services/NEMeetingInviteService'

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
  ownerUserUuid: string
  scheduledMembers?: NEMeetingScheduledMember[]
  settings: {
    roomInfo: {
      roomConfigId: number
      openWaitingRoom?: boolean
      enableJoinBeforeHost?: boolean
      roomConfig: {
        resource: {
          chatroom: boolean
          live: boolean
          record: boolean
          rtc: boolean
          sip: boolean
          whiteboard: boolean
          waitingRoom: boolean
        }
      }
      password?: string
      roomProperties?: Record<string, any>
      viewOrder?: string
    }
    liveConfig?: {
      liveAddress: string
    }
  }
  recurringRule: {
    type: MeetingRepeatType
    customizedFrequency?: {
      stepSize: number
      stepUnit: MeetingRepeatCustomStepUnit
      daysOfWeek: number[]
      daysOfMonth: number[]
    }
    endRule: {
      type: number
      date: number
      times: number
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
  avatar?: string
  meetingNum: string
  shortMeetingNum: string // 个人会议短号
  serviceBundle?: {
    name: string
    meetingMaxMinutes: number
    meetingMaxMembers: number
  }
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
  RoomWatermarkChanged = 'roomWatermarkChanged',
  MemberPropertiesChanged = 'memberPropertiesChanged',
  MemberAudioConnectStateChanged = 'memberAudioConnectStateChanged',
  MemberPropertiesDeleted = 'memberPropertiesDeleted',
  RoomPropertiesDeleted = 'roomPropertiesDeleted',
  RoomEnded = 'roomEnded',
  RtcActiveSpeakerChanged = 'rtcActiveSpeakerChanged',
  RtcChannelError = 'rtcChannelError',
  RtcAudioVolumeIndication = 'rtcAudioVolumeIndication',
  RtcLocalAudioVolumeIndication = 'rtcLocalAudioVolumeIndication',
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
  ReceiveAccountInfoUpdate = 'receiveAccountInfoUpdate',
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
  roomCloudRecordStateChanged = 'roomCloudRecordStateChanged',
  RtcScreenCaptureStatus = 'rtcScreenCaptureStatus',
  onVideoFrameData = 'onVideoFrameData',
  previewVideoFrameData = 'previewVideoFrameData',
  rtcVirtualBackgroundSourceEnabled = 'rtcVirtualBackgroundSourceEnabled',
  meetingStatusChanged = 'meetingStatusChanged',
  // Rooms 应用的事件
  RoomsCustomEvent = 'roomsCustomEvent',
  RoomsSendEvent = 'roomsSendEvent',

  MemberJoinWaitingRoom = 'memberJoinWaitingRoom',
  MemberLeaveWaitingRoom = 'memberLeaveWaitingRoom',
  MemberAdmitted = 'memberAdmitted',
  MemberNameChangedInWaitingRoom = 'memberNameChangedInWaitingRoom',
  MyWaitingRoomStatusChanged = 'myWaitingRoomStatusChanged',
  WaitingRoomInfoUpdated = 'waitingRoomInfoUpdated',
  WaitingRoomAllMembersKicked = 'waitingRoomAllMembersKicked',
  RoomLiveBackgroundInfoChanged = 'roomLiveBackgroundInfoChanged',
  RoomBlacklistStateChanged = 'onRoomBlacklistStateChanged',
  MemberSipInviteStateChanged = 'onMemberSipInviteStateChanged',
  MemberAppInviteStateChanged = 'onMemberAppInviteStateChanged',
  AcceptInvite = 'acceptInvite',

  // 说话者列表相关
  ActiveSpeakerActiveChanged = 'OnActiveSpeakerActiveChanged',
  ActiveSpeakerListChanged = 'OnActiveSpeakerListChanged',
  // 通知
  OnReceiveSessionMessage = 'onReceiveSessionMessage',
  OnChangeRecentSession = 'onChangeRecentSession',
  OnMeetingInviteStatusChange = 'onMeetingInviteStatusChanged',
  OnMeetingInvite = 'onMeetingInvite',
  OnDeleteSessionMessage = 'onDeleteSessionMessage',
  OnDeleteAllSessionMessage = 'onDeleteAllSessionMessage',

  ChangeDeviceFromSetting = 'changeDeviceFromSetting',
  // 私聊
  OnPrivateChatMemberIdSelected = 'onPrivateChatMemberIdSelected',
}

export interface GetAccountInfoListResponse {
  meetingAccountListResp: SearchAccountInfo[]
  notFindUserUuids: string[]
}
export interface SearchAccountInfo {
  userUuid: string
  name: string
  avatar?: string
  dept: string
  phoneNumber: string
  // 非服务端返回，端上用于通讯录设置
  role?: Role
  disabled?: boolean
}

export enum MeetingEventType {
  rtcChannelError = 'rtcChannelError',
  needShowRecordTip = 'needShowRecordTip',
  leaveOrEndRoom = 'leaveOrEndRoom',
  noCameraPermission = 'noCameraPermission',
  noMicPermission = 'noMicPermission',
  changeMemberListTab = 'changeMemberListTab',
  waitingRoomMemberListChange = 'waitingRoomMemberListChange',
  rejoinAfterAdmittedToRoom = 'rejoinAfterAdmittedToRoom',
  updateWaitingRoomUnReadCount = 'updateWaitingRoomUnReadCount',
  updateMeetingInfo = 'updateMeetingInfo',
}

export enum UserEventType {
  Login = 'login',
  Logout = 'logout',
  LoginWithPassword = 'loginWithPassword',
  CreateMeeting = 'createMeeting',
  JoinMeeting = 'joinMeeting',
  AnonymousJoinMeeting = 'anonymousJoinMeeting',
  SetLeaveCallback = 'setLeaveCallback',
  onMeetingStatusChanged = 'onMeetingStatusChanged',
  RejoinMeeting = 'rejoinMeeting',
  JoinOtherMeeting = 'joinOtherMeeting',
  CancelJoin = 'cancelJoin',
  SetScreenSharingSourceId = 'setScreenSharingSourceId',
  EndMeeting = 'endMeeting',
  LeaveMeeting = 'leaveMeeting',
  UpdateMeetingInfo = 'updateMeetingInfo',
  OnScreenSharingStatusChange = 'onScreenSharingStatusChange',
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
  pinView = 67,
  unpinView = 68,
  modifyMeetingNickName = 104,
  takeBackTheHost = 105,
  privateChat = 106,
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
  moveToWaitingRoom = 66,
  openWatermark = 64,
  closeWatermark = 65,
  changeChatPermission = 70,
  changeWaitingRoomChatPermission = 71,
  changeGuestJoin = 72,
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
  /**
   * 消息 id
   */
  messageUuid?: string
  /**
   * 客户端类型
   */
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
    url: string
    name: string
    msgId: string
    msgTime: number
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
  /**
   * 文件
   */
  file?: {
    name: string
    ext: string
    size: number
    url: string
  }
  /**
   * 自定义信息
   */
  custom?: string
  /**
   * 0: 会内聊天室；1: 等候室
   */
  chatroomType?: number
  /**
   *  临时文件，用于重发
   */
  tempFile?: File
  /**
   * 是否是私聊
   */
  isPrivate?: boolean
  /**
   * 发送给的昵称
   */
  toNickname?: string
  /**
   * 头像
   */
  fromAvatar?: string
}
export interface GlobalProviderProps {
  eventEmitter: Eventemitter
  outEventEmitter: Eventemitter
  neMeeting: NEMeetingService
  inviteService: NEMeetingInviteService
  children: ReactNode
  globalConfig?: GetMeetingConfigResponse
  joinLoading?: boolean
  logger?: Logger
  showMeetingRemainingTip?: boolean
}
export interface MeetingInfoProviderProps {
  meetingInfo: NEMeetingInfo
  memberList: NEMember[]
  inInvitingMemberList?: NEMember[]
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
  inviteService?: NEMeetingInviteService
  dispatch?: Dispatch
  logger?: Logger
  globalConfig?: GetMeetingConfigResponse
  showMeetingRemainingTip?: boolean
  waitingRejoinMeeting?: boolean // 正在重新加入会议
  waitingJoinOtherMeeting?: boolean // 正在加入其他会议
  online?: boolean
  meetingIdDisplayOption?: NEMeetingIdDisplayOption
  showCloudRecordMenuItem?: boolean
  showCloudRecordingUI?: boolean
  showScreenShareUserVideo?: boolean
  toolBarList?: ToolBarList
  moreBarList?: MoreBarList
}
export enum RecordState {
  NotStart = 'notStart',
  Recording = 'recording',
  Starting = 'starting',
  Stopping = 'stopping',
}

export enum NEChatPermission {
  FREE_CHAT = 1,
  PUBLIC_CHAT_ONLY = 2,
  PRIVATE_CHAT_HOST_ONLY = 3,
  NO_CHAT = 4,
}

export enum NEWaitingRoomChatPermission {
  NO_CHAT = 0,
  PRIVATE_CHAT_HOST_ONLY = 1,
}

export type WatermarkInfo = {
  videoStrategy: WATERMARK_STRATEGY
  videoStyle: WATERMARK_STYLE
  videoFormat: string
}

export enum WATERMARK_STRATEGY {
  /**
   * 关闭水印
   */
  CLOSE = 0,
  /**
   * 开启水印
   */
  OPEN = 1,
  /**
   * 强制开启水印
   */
  FORCE_OPEN = 2,
}

export enum WATERMARK_STYLE {
  /**
   * 单条居中
   */
  SINGLE = 1,
  /**
   * 全屏多条
   */
  MULTI = 2,
}

export type GetMeetingConfigResponse = {
  data: any
  deviceConfig?: any
  appConfig: {
    APP_ROOM_RESOURCE: {
      whiteboard: boolean
      chatroom: boolean
      live: boolean
      rtc: boolean
      record: boolean
      sip: boolean
      waitingRoom: boolean
      sipInvite: boolean
      appInvite: boolean
    }
    MEETING_BEAUTY?: {
      enable: boolean
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
    MEETING_CLIENT_CONFIG?: {
      activeSpeakerConfig: ActiveSpeakerConfig
    }
    ROOM_END_TIME_TIP?: {
      enable: boolean
    }
    ROOM_WATERMARK: WatermarkInfo
    notifySenderAccid: string
    MEETING_ACCOUNT_CONFIG: {
      avatarUpdateDisabled: boolean
      nicknameUpdateDisabled: boolean
      phoneNumberPattern: string
      userNameRegisterEnabled: boolean
      usernameAsPhoneNumber: boolean
    }
    MEETING_SCHEDULED_MEMBER_CONFIG?: {
      enable: boolean // 预约会议时是否支持选定成员，默认true
      coHostLimit: number // 模版里配置的联席主持人人数限制，默认4 待定
      max: number // 单会议人数限制
    }
    outboundPhoneNumber?: string
  }
}

export interface WaitingRoomContextInterface {
  waitingRoomInfo: {
    memberCount: number
    isEnabledOnEntry: boolean
    unReadMsgCount?: number
    backgroundImageUrl?: string
  }
  memberList: NEWaitingRoomMember[]
  dispatch?: Dispatch
}
export interface MeetingInfoContextInterface {
  meetingInfo: NEMeetingInfo
  memberList: NEMember[]
  inInvitingMemberList?: NEMember[]
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
  [ActionType.UPDATE_MEMBER_PROPERTIES]: { uuid: string; properties: string[] }
  [ActionType.DELETE_MEMBER_PROPERTIES]: { uuid: string; properties: string[] }
  [ActionType.ADD_MEMBER]: { member: NEMember }
  [ActionType.REMOVE_MEMBER]: { uuids: string[] }
  [ActionType.RESET_MEMBER]: null
  [ActionType.UPDATE_MEETING_INFO]: Partial<NEMeetingInfo>
  [ActionType.SET_MEETING]: NEMeeting | NEMeetingSDK
  [ActionType.RESET_MEETING]: null
  [ActionType.JOIN_LOADING]: boolean

  [ActionType.WAITING_ROOM_ADD_MEMBER]: { member: NEWaitingRoomMember }
  [ActionType.WAITING_ROOM_REMOVE_MEMBER]: { uuid: string }
  [ActionType.WAITING_ROOM_UPDATE_MEMBER]: {
    uuid: string
    member: Partial<NEWaitingRoomMember>
  }
  [ActionType.WAITING_ROOM_UPDATE_INFO]: {
    info: Partial<WaitingRoomContextInterface['waitingRoomInfo']>
  }
  [ActionType.WAITING_ROOM_SET_MEMBER_LIST]: {
    memberList: NEWaitingRoomMember[]
  }
  [ActionType.WAITING_ROOM_ADD_MEMBER_LIST]: {
    memberList: NEWaitingRoomMember[]
  }

  [ActionType.SIP_ADD_MEMBER]: { member: NEMember }
  [ActionType.SIP_REMOVE_MEMBER]: { uuids: string[] }
  [ActionType.SIP_UPDATE_MEMBER]: { uuid: string; member: Partial<NEMember> }
  [ActionType.SIP_RESET_MEMBER]: { uuids: string[] }
}

export type ActionHandleType<T extends ActionType> = ActionHandle[T]

export enum ActionType {
  UPDATE_GLOBAL_CONFIG = 'updateGlobalConfig',
  UPDATE_NAME = 'updateName',
  RESET_NAME = 'resetName',
  UPDATE_MEMBER = 'updateMember',
  RESET_MEMBER = 'resetMember',
  UPDATE_MEMBER_PROPERTIES = 'updateMemberProperties',
  DELETE_MEMBER_PROPERTIES = 'deleteMemberProperties',
  ADD_MEMBER = 'addMember',
  REMOVE_MEMBER = 'removeMember',
  UPDATE_MEETING_INFO = 'updateMeetingInfo',
  SET_MEETING = 'setMeeting',
  RESET_MEETING = 'resetMeeting',
  JOIN_LOADING = 'joinLoading',

  WAITING_ROOM_ADD_MEMBER = 'waitingRoomAddMember',
  WAITING_ROOM_REMOVE_MEMBER = 'waitingRoomRemoveMember',
  WAITING_ROOM_UPDATE_MEMBER = 'waitingRoomUpdateMember',
  WAITING_ROOM_UPDATE_INFO = 'waitingRoomUpdateInfo',
  WAITING_ROOM_SET_MEMBER_LIST = 'waitingRoomSetMemberList',
  WAITING_ROOM_ADD_MEMBER_LIST = 'waitingRoomAddMemberList',

  SIP_ADD_MEMBER = 'sipAddMember',
  SIP_REMOVE_MEMBER = 'sipRemoveMember',
  SIP_UPDATE_MEMBER = 'sipUpdateMember',
  SIP_RESET_MEMBER = 'sipResetMember',
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
  avatar?: string
  serviceBundle?: {
    name: string
    meetingMaxMinutes: number
    meetingMaxMembers: number
    expireTimeStamp: number
    expireTip: string
  }
}

export interface NEMeetingLoginByPasswordOptions {
  username: string
  password: string
  loginType: LoginType.LoginByPassword
  isTemporary?: boolean
  loginReport?: IntervalEvent
}
export interface NEMeetingLoginByTokenOptions {
  accountId: string
  accountToken: string
  loginType: LoginType.LoginByToken
  authType?: string
  isTemporary?: boolean
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
  createMeetingReport?: IntervalEvent
  enableWaitingRoom?: boolean
  enableGuestJoin?: boolean
  attendeeAudioOffType?: AttendeeOffType
  enableJoinBeforeHost?: boolean
  recurringRule?: Record<string, any>
  scheduledMembers?: NEMeetingScheduledMember[]
}
interface NEMeetingBaseOptions {
  meetingId?: number
  meetingNum: string // 原先使用meetingId后续兼容meetingNum
  nickName: string
  password?: string
  memberTag?: string
  noChat?: boolean
  avatar?: string
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
  security = 26,
  record = 27,
  setting = 28,
  notification = 29,
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

export interface MeetingDeviceInfo {
  deviceId: string
  deviceName: string
  defaultDevice?: boolean
  default?: boolean // 应用层添加字段，用于判断当前选择的根据默认设备走还是选择了和默认设备一样的设备
  originDeviceId?: string // 原始设备id
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
    downloadPath: string
    language: string
  }
  videoSetting: {
    deviceId: string
    isDefaultDevice?: boolean
    resolution: number
    // 是否开启视频镜像
    enableVideoMirroring: boolean
    galleryModeMaxCount: number
  }
  audioSetting: {
    recordDeviceId: string
    isDefaultRecordDevice?: boolean
    playoutDeviceId: string
    isDefaultPlayoutDevice?: boolean
    /**
     * 自动调节麦克风音量，默认开
     */
    enableAudioVolumeAutoAdjust: boolean
    enableUnmuteBySpace: boolean
    recordVolume: number
    playoutVolume: number
    recordOutputVolume?: number
    playouOutputtVolume?: number
    // 更多设置-仅桌面端支持
    /**
     * 智能降噪，默认开
     */
    enableAudioAI: boolean
    /**
     * 音乐模式，默认关
     */
    enableMusicMode: boolean
    /**
     * 回声消除，默认开，依赖开启音乐模式
     */
    enableAudioEchoCancellation: boolean
    /**
     * 立体声，默认开，依赖开启音乐模式
     */
    enableAudioStereo: boolean
  }
  beautySetting: {
    beautyLevel: number
    virtualBackgroundPath: string
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

export const CustomButtonIdBoundaryValue = 100

export enum NERoomBeautyEffectType {
  /**
   * 美牙。强度默认值为 0.0。
   */
  kNERoomBeautyWhiteTeeth = 0,

  /**
   * 亮眼。强度默认值为 0.0。
   */
  kNERoomBeautyLightEye,

  /**
   * 美白。强度默认值为 0.0。
   */
  kNERoomBeautyWhiten,

  /**
   * 磨皮。强度默认值为 0.0。
   */
  kNERoomBeautySmooth,

  /**
   * 小鼻。强度默认值为 0.0。
   */
  kNERoomBeautySmallNose,

  /**
   * 眼距调整。强度默认值为 0.5。
   */
  kNERoomBeautyEyeDis,

  /**
   * 眼角调整。强度默认值为 0.5。
   */
  kNERoomBeautyEyeAngle,

  /**
   * 嘴型调整。强度默认值为 0.5。
   */
  kNERoomBeautyMouth,

  /**
   * 大眼。强度默认值为 0.0。
   */
  kNERoomcBeautyBigEye,

  /**
   * 小脸。强度默认值为 0.0。
   */
  kNERoomBeautySmallFace,

  /**
   * 下巴调整。强度默认值为 0.0。
   */
  kNERoomBeautyJaw,

  /**
   * 瘦脸。强度默认值为 0.0。
   */
  kNERoomBeautyThinFace,

  /**
   *红润。强度默认值为0.0。
   */
  kNERoomBeautyFaceRuddy,

  /**
   * 长鼻。强度默认值为 0.5。
   */
  kNERoomBeautyLongNose,

  /**
   * 人中。强度默认值为 0.5。
   */
  kNERoomBeautyRenZhong,

  /**
   * 嘴角。强度默认值为 0.5。
   */
  kNERoomBeautyMouthAngle,

  /**
   * 圆眼。强度默认值为 0.0。
   */
  kNERoomBeautyRoundEye,

  /**
   * 开眼角。强度默认值为 0.0。
   */
  kNERoomBeautyOpenEyeAngle,

  /**
   * V脸。强度默认值为 0.0。
   */
  kNERoomBeautyVFace,

  /**
   * 瘦下颌。强度默认值为 0.0。
   */
  kNERoomBeautyThinUnderjaw,

  /**
   * 窄脸。强度默认值为 0.0。
   */
  kNERoomBeautyNarrowFace,

  /**
   * 瘦颧骨。强度默认值为 0.0。
   */
  kNERoomBeautyCheekBone,

  /**
   *锐化。强度默认值为0.0。
   */
  kNERoomBeautyFaceSharpen,
}

export enum tagNERoomScreenCaptureStatus {
  kNERoomScreenCaptureStatusStart = 1 /**< 开始屏幕分享 */,
  kNERoomScreenCaptureStatusPause = 2 /**< 暂停屏幕分享 */,
  kNERoomScreenCaptureStatusResume = 3 /**< 恢复屏幕分享 */,
  kNERoomScreenCaptureStatusStop = 4 /**< 停止屏幕分享 */,
  kNERoomScreenCaptureStatusCovered = 5 /**< 屏幕分享的目标窗口被覆盖 */,
}

export enum tagNERoomRtcAudioProfileType {
  /**
   * 默认设置。Speech 场景下为 kNEAudioProfileStandardExtend，Music 场景下为 kNEAudioProfileHighQuality
   */
  kNEAudioProfileDefault = 0,
  /**
   * 普通质量的音频编码，16000Hz，20Kbps
   */
  kNEAudioProfileStandard = 1,
  /**
   * 普通质量的音频编码，16000Hz，32Kbps
   */
  kNEAudioProfileStandardExtend = 2,
  /**
   * 中等质量的音频编码，48000Hz，32Kbps
   */
  kNEAudioProfileMiddleQuality = 3,
  /**
   * 中等质量的立体声编码，48000Hz * 2，64Kbps
   */
  kNEAudioProfileMiddleQualityStereo = 4,
  /**
   * 高质量的音频编码，48000Hz，64Kbps
   */
  kNEAudioProfileHighQuality = 5,
  /**
   * 高质量的立体声编码，48000Hz * 2，128Kbps
   */
  kNEAudioProfileHighQualityStereo = 6,
}

export enum tagNERoomRtcAudioScenarioType {
  /**
   * 默认设置
   * kNEChannelProfileCommunication 下为 kNEAudioScenarioSpeech
   * kNEChannelProfileLiveBroadcasting 下为 kNEAudioScenarioMusic
   */
  kNEAudioScenarioDefault = 0,
  /**
   * 语音场景。NERoomRtcAudioProfileType 推荐使用 kNEAudioProfileMiddleQuality 及以下
   */
  kNEAudioScenarioSpeech = 1,
  /**
   * 音乐场景。NERoomRtcAudioProfileType 推荐使用 kNEAudioProfileMiddleQualityStereo 及以上
   */
  kNEAudioScenarioMusic = 2,
}

export interface ResUpdateInfo {
  forceVersionCode: number
  latestVersionName: string
  latestVersionCode: number
  downloadUrl: string
  description: string
  title: string
  url: string
  notify: number
  checkCode: string
  extVersionConfig?: Record<string, any>
}

export enum UpdateType {
  noUpdate,
  normalUpdate,
  forceUpdate,
}
/**
 * 1: 'TV',
  2: 'iOS',
  3: 'AOS',
  4: 'Windows',
  5: 'MAC',
  6: 'web',
  7: 'Rooms-大屏-windows',
  8: 'Rooms-大屏-mac',
  15: 'electron-windows',
  16: 'electron-mac',
  20: 'Rooms-控制器-android
 */
export enum ClientType {
  TV = 1,
  iOS = 2,
  AOS = 3,
  Windows = 4,
  MAC = 5,
  web = 6,
  RoomsWindows = 7,
  RoomsMac = 8,
  ElectronWindows = 15,
  ElectronMac = 16,
  RoomsAndroid = 20,
}

export interface LiveBackgroundInfo {
  backgroundUrl?: string
  thumbnailBackgroundUrl?: string
  coverUrl?: string
  thumbnailCoverUrl?: string
  newSequence?: number // 服务端发送的最新序号，用于和当前对比是否需要更新
  sequence?: number
}

export interface ActiveSpeakerConfig {
  maxActiveSpeakerCount: number
  validVolumeThreshold: number
  activeSpeakerVolumeThreshold: number
  volumeIndicationInterval: number
  volumeIndicationWindowSize: number
  enableVideoPreSubscribe: boolean
}

export type AvatarSize = 64 | 48 | 36 | 32 | 24 | 22

export enum MeetingRepeatType {
  NoRepeat = 1,
  Everyday = 2,
  EveryWeekday,
  EveryWeek,
  EveryTwoWeek,
  EveryMonth,
  Custom,
}
export enum MeetingEndType {
  Day = 1,
  Times,
}

export enum MeetingRepeatCustomStepUnit {
  Day = 1,
  Week,
  MonthOfDay,
  MonthOfWeek,
}

export enum MeetingRepeatFrequencyType {
  Day = 1,
  Week = 2,
  Month = 3,
}

// 通讯录成员
export interface MeetingConnectMember {
  userUuid: string
  name: string
  avatar: string
  dept: string
  phoneNumber: string
}
