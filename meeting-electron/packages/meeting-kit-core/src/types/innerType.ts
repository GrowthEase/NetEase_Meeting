import { IntervalEvent } from '@xkit-yx/utils'
import Eventemitter from 'eventemitter3'
import {
  Roomkit,
  NEWaitingRoomMember,
  NERoomCaptionMessage,
  NERoomEndReason,
  NERoomCaptionTranslationLanguage,
  NERoomSipDeviceInviteProtocolType
} from 'neroom-types'
import { ReactNode } from 'react'
import NEMeetingService from '../services/NEMeeting'
import { Logger } from '../utils/Logger'
import {
  AttendeeOffType,
  MoreBarList,
  NEProps,
  NEEncryptionConfig,
  NEMeeting,
  NEMeetingIdDisplayOption,
  NEMeetingInfo,
  NEMeetingInterpretationSettings,
  NEMeetingScheduledMember,
  NEMeetingSDK,
  NEMember,
  NEScheduledMember,
  Role,
  ToolBarList,
  VideoFrameRate,
  VideoResolution,
} from './type'
import NEMeetingInviteService from '../services/NEMeetingInviteService'
import {
  NEWindowMode,
  NEMenuVisibility,
} from '../kit/interface/service/meeting_service'
import {
  NEMeetingItemLiveBackground,
  NEmeetingItemLivePushThirdPart,
  NEMeetingRecurringRule,
} from '../kit/interface'
import { IM } from './NEMeetingKit'

export { NEMenuVisibility }

/**
 * 内部使用的类型不对外暴露
 * 对外暴露类型放入type中
 */
export interface CreateMeetingResponse {
  /** 会议id */
  meetingId: number
  /** 会议号 */
  meetingNum: string
  /** 房间uuid */
  roomUuid: string
  /** 会议状态 */
  state: number
  /** 会议开始时间 */
  startTime: number
  /** 会议结束时间 */
  endTime: number
  /** 会议主题 */
  subject: string
  /** 会议邀请链接 */
  meetingInviteUrl: string
  /** 会议 code */
  meetingCode: string
  /** 会议类型 */
  type: number
  /** 会议短号 */
  shortMeetingNum?: string
  /** @ignore 跨应用加入房间使用的userUuid */
  meetingUserUuid?: string
  /** @ignore 跨应用加入房间使用的userToken */
  meetingUserToken?: string
  /** @ignore 跨应用加入房间使用的appKey */
  meetingAppKey?: string
  /** @ignore 跨应用加入房间使用的鉴权类型 */
  meetingAuthType?: string
  /** @ignore 不对外暴露  */
  roomArchiveId: string
  /** 房间拥有者 uuid */
  ownerUserUuid: string
  /** 房间拥有者 用户名 */
  ownerNickname: string
  /** 预约指定角色的成员  */
  scheduledMembers?: NEMeetingScheduledMember[]
  /** 时区 */
  timezoneId?: string
  /** @ignore 不对外暴露 */
  settings: {
    roomInfo: {
      roomConfigId: number
      openWaitingRoom: boolean
      enableJoinBeforeHost: boolean
      roleBinds: Record<string, Role>
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
      roomProperties?: Record<string, NEProps>
      viewOrder?: string
    }
    recordConfig?: {
      recordStrategy: number
    }
    liveConfig?: {
      liveAddress: string
    }
    livePrivateConfig?: {
      title: string
      password?: string
      pushThirdParties: NEmeetingItemLivePushThirdPart[]
      background?: NEMeetingItemLiveBackground
      enableThirdParties?: boolean
    }
  }
  /** 周期性会议 */
  recurringRule?: {
    type: MeetingRepeatType
    customizedFrequency?: {
      stepSize: number
      stepUnit: MeetingRepeatCustomStepUnit
      daysOfWeek: number[]
      daysOfMonth: number[]
    }
    endRule: {
      type: number
      date?: string
      times?: number
    }
  }
  inviteUrl?: string
  /** 与会者视频关闭 */
  attendeeVideoOff?: boolean
  /** 与会者音频关闭 */
  attendeeAudioOff?: boolean
  /** 与会者音频关闭模式 */
  attendeeAudioOffType?: AttendeeOffType
  /** 会议密码 */
  password?: string
  /** 是否开启云录制 */
  noCloudRecord?: boolean
  /** 是否开启聊天室 */
  noChat?: boolean
  /** 是否开启直播 */
  openLive?: boolean
  /** 直播是否本企业可用 */
  liveOnlyEmployees?: boolean
  /** 是否开启SIP功能 */
  noSip: boolean
  /** 配置会议是否默认开启等候室 */
  enableWaitingRoom: boolean
  /** 配置会议是否允许参会者在主持人进入会议前加入会议，默认为允许 */
  enableJoinBeforeHost: boolean
  /** 是否允许访客入会 */
  enableGuestJoin: boolean
  /** 会议扩展字段，可空，最大长度为 2K。 */
  extraData?: string
  /** 会议主持人角色绑定 */
  roleBinds?: Record<string, string>
  /** 同声传译 */
  interpretation?: {
    interpreters?: {
      [key: string]: string[]
    }
    started: boolean
  }
  /** 云录制 */
  cloudRecordConfig?: NECloudRecordConfig
  /** 访客跨应用入会类型 0 不允许访客入会 1 实名访客入会 2 匿名访客入会*/
  guestJoinType?: '0' | '1' | '2'
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
  shortMeetingNum?: string // 个人会议短号
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

export enum EndRoomReason {
  JOIN_TIMEOUT = 'JOIN_TIMEOUT',
}

export type MeetingEndRoomReason = EndRoomReason | NERoomEndReason

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
  MemberSystemAudioShareStateChanged = 'MemberSystemAudioShareStateChanged',
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
  ReceivePluginMessage = 'receivePluginMessage',
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
  WaitingRoomOnManagersUpdated = 'WaitingRoomOnManagersUpdated',
  RoomLiveBackgroundInfoChanged = 'roomLiveBackgroundInfoChanged',
  RoomBlacklistStateChanged = 'onRoomBlacklistStateChanged',
  MemberSipInviteStateChanged = 'onMemberSipInviteStateChanged',
  MemberAppInviteStateChanged = 'onMemberAppInviteStateChanged',
  AcceptInvite = 'acceptInvite',
  AcceptInviteJoinSuccess = 'acceptInviteJoinSuccess',

  // 说话者列表相关
  ActiveSpeakerActiveChanged = 'OnActiveSpeakerActiveChanged',
  ActiveSpeakerListChanged = 'OnActiveSpeakerListChanged',
  // 通知
  onSessionMessageReceived = 'onSessionMessageReceived',
  onSessionMessageRecentChanged = 'onSessionMessageRecentChanged',
  OnMeetingInviteStatusChange = 'onMeetingInviteStatusChanged',
  OnMeetingInvite = 'onMeetingInvite',
  onSessionMessageDeleted = 'onSessionMessageDeleted',
  OnDeleteAllSessionMessage = 'onDeleteAllSessionMessage',
  onInterpretationSettingChange = 'onInterpretationSettingChange',

  ChangeDeviceFromSetting = 'changeDeviceFromSetting',
  // 私聊
  OnPrivateChatMemberIdSelected = 'onPrivateChatMemberIdSelected',
  // 预约会议页面模式
  OnScheduledMeetingPageModeChanged = 'onScheduledMeetingPageModeChanged',
  // 历史会议页面模式
  OnHistoryMeetingPageModeChanged = 'onHistoryMeetingPageModeChanged',
  // 批注
  RoomAnnotationEnableChanged = 'onRoomAnnotationEnableChanged',
  RoomAnnotationWebJsBridge = 'roomAnnotationWebJsBridge',
  AuthEvent = 'AuthEvent',
  RtcScreenShareVideoResize = 'rtcScreenShareVideoResize',
  // 最大人数变更
  RoomMaxMembersChanged = 'roomMaxMembersChanged',

  ReceiveCaptionMessages = 'receiveCaptionMessages',
  CaptionStateChanged = 'captionStateChanged',

  // 译员全部离开事件
  OnInterpreterLeaveAll = 'onInterpreterLeaveAll',
  // 音视频权限被拒绝
  OnAccessDenied = 'onAccessDenied',
  // 开始播放媒体流
  OnStartPlayMedia = 'onStartPlayMedia',
  // 对应频道译员离开
  OnInterpreterLeave = 'onInterpreterLeave',
  // 本端被移除译员
  MyInterpreterRemoved = 'MyInterpreterRemoved',

  RtcChannelDisconnect = 'RtcChannelDisconnect',

  // 暂停参会者活动
  OnStopMemberActivities = 'OnStopMemberActivities',

  // 表情回应
  OnEmoticonsReceived = 'OnEmoticonsReceived',
}

export interface GetAccountInfoListResponse {
  meetingAccountListResp: SearchAccountInfo[]
  notFindUserUuids: string[]
}
export interface SearchAccountInfo {
  // 非服务端返回，端上用于通讯录设置
  role?: Role
  disabled?: boolean
  inInviting?: boolean
  userUuid: string
  name: string
  avatar?: string
  dept?: string
  phoneNumber?: string
}

export enum MeetingEventType {
  rtcChannelError = 'meetingRtcChannelError',
  needShowRecordTip = 'needShowRecordTip',
  leaveOrEndRoom = 'leaveOrEndRoom',
  noCameraPermission = 'noCameraPermission',
  noMicPermission = 'noMicPermission',
  changeMemberListTab = 'changeMemberListTab',
  waitingRoomMemberListChange = 'waitingRoomMemberListChange',
  rejoinAfterAdmittedToRoom = 'rejoinAfterAdmittedToRoom',
  updateWaitingRoomUnReadCount = 'updateWaitingRoomUnReadCount',
  updateMeetingInfo = 'updateMeetingInfo',
  openCaption = 'openCaption',
  openTranscriptionWindow = 'openTranscriptionWindow',
  transcriptionMsgCountChange = 'transcriptionMsgCountChange',
}

export enum UserEventType {
  Login = 'login',
  Logout = 'logout',
  LoginWithPassword = 'loginWithPassword',
  CreateMeeting = 'createMeeting',
  JoinMeeting = 'joinMeeting',
  GuestJoinMeeting = 'guestJoinMeeting',
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
  GetReducerMeetingInfo = 'getReducerMeetingInfo',
  OnScreenSharingStatusChange = 'onScreenSharingStatusChange',
  UpdateInjectedMenuItem = 'updateInjectedMenuItem',
  OnInjectedMenuItemClick = 'onInjectedMenuItemClick',
  OpenSettingsWindow = 'openSettingsWindow',
  OpenPluginWindow = 'openPluginWindow',
  OpenFeedbackWindow = 'OpenFeedbackWindow',
  OpenChatWindow = 'openChatWindow',
  StopWhiteboard = 'StopWhiteboard',
  StopSharingComputerSound = 'stopSharingComputerSound',
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

export enum SecurityItem {
  screenSharePermission = 'screenSharePermission',
  unmuteAudioBySelfPermission = 'unmuteAudioBySelfPermission',
  unmuteVideoBySelfPermission = 'unmuteVideoBySelfPermission',
  updateNicknamePermission = 'updateNicknamePermission',
  whiteboardPermission = 'whiteboardPermission',
  localRecordPermission = 'localRecordPermission',
  annotationPermission = 'annotationPermission',
}
export enum MeetingSecurityCtrlValue {
  /// 是否允许批注
  ANNOTATION_DISABLE = 0x1,

  /// 是否允许屏幕共享
  SCREEN_SHARE_DISABLE = 0x1 << 1,

  /// 是否允许开启白板
  WHILE_BOARD_SHARE_DISABLE = 0x1 << 2,

  /// 是否允许自己改名
  EDIT_NAME_DISABLE = 0x1 << 3,

  /// 是否是全体静音
  AUDIO_OFF = 0x1 << 4,

  /// 是否允许自行解除静音
  AUDIO_NOT_ALLOW_SELF_ON = 0x1 << 5,

  /// 是否是全体关闭视频
  VIDEO_OFF = 0x1 << 6,

  /// 是否允许自行打开视频
  VIDEO_NOT_ALLOW_SELF_ON = 0x1 << 7,

  /// 表情回复开关
  EMOJI_RESP_DISABLE = 0x1 << 8,

  /// 本地录制开关
  LOCAL_RECORD_DISABLE = 0x1 << 9,

  /// 成员加入离开播放提示音
  PLAY_SOUND = 0x1 << 10,

  /// 头像显示隐藏
  AVATAR_HIDE = 0x1 << 11,

  /// 智能会议纪要
  SMART_SUMMARY = 0x1 << 12,
}

export enum SecurityCtrlEnum {
  // 批注
  ANNOTATION_DISABLE = 'ANNOTATION_DISABLE',
  /**
   *  共享屏幕
   */
  SCREEN_SHARE_DISABLE = 'SCREEN_SHARE_DISABLE',
  /**
   * 1: 共享白板关闭
   * 0: 共享白板开启
   */
  WHILE_BOARD_SHARE_DISABLE = 'WHILE_BOARD_SHARE_DISABLE',
  /**
   * 1: 不允许自己改名
   * 0: 允许自己改名
   */
  EDIT_NAME_DISABLE = 'EDIT_NAME_DISABLE',
  /**
   * 1: 全体音频关闭
   * 0: 全体音频开启
   */
  AUDIO_OFF = 'AUDIO_OFF',

  /**
   * 1: 音频不允许自己打开
   * 0: 音频允许自己打开
   */
  AUDIO_NOT_ALLOW_SELF_ON = 'AUDIO_NOT_ALLOW_SELF_ON',
  /**
   * 1: 全体视频关闭
   * 0: 全体视频开启
   */
  VIDEO_OFF = 'VIDEO_OFF',

  /**
   * 1: 视频不允许自己打开
   * 0: 视频允许自己打开
   */
  VIDEO_NOT_ALLOW_SELF_ON = 'VIDEO_NOT_ALLOW_SELF_ON',

  /**
   * 1: 表情回应功能关闭
   * 0: 表情回应功能打开
   */
  EMOJI_RESP_DISABLE = 'EMOJI_RESP_DISABLE',

  /**
   * 1: 本地录制功能关闭
   * 0: 本地录制功能打开
   */
  LOCAL_RECORD_DISABLE = 'LOCAL_RECORD_DISABLE',

  /**
   * 成员离开入会播放提示声音
   *
   *  1: 播放提示音
   *  0：不播放提示音
   */
  PLAY_SOUND = 'PLAY_SOUND',

  /**
   * 1: 隐藏头像
   * 0: 显示头像
   */
  AVATAR_HIDE = 'AVATAR_HIDE',

  /**
   * 智能会议纪要
   * 1: 开启
   * 0: 关闭
   */
  SMART_SUMMARY = 'SMART_SUMMARY',
}

export interface MeetingPermission {
  annotationPermission: boolean
  screenSharePermission: boolean
  unmuteAudioBySelfPermission: boolean
  unmuteVideoBySelfPermission: boolean
  updateNicknamePermission: boolean
  whiteboardPermission: boolean
  emojiRespPermission: boolean
  videoAllOff: boolean
  audioAllOff: boolean
  playSound: boolean
  avatarHide: boolean
  smartSummary: boolean
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
  closeAudioShare = 54,
  openWhiteShare = 60,
  closeWhiteShare = 61,
  moveToWaitingRoom = 66,
  openWatermark = 64,
  closeWatermark = 65,
  changeChatPermission = 70,
  changeWaitingRoomChatPermission = 71,
  changeGuestJoin = 72,
  annotationPermission = 73,
  screenSharePermission = 74,
  unmuteAudioBySelfPermission = 75,
  unmuteVideoBySelfPermission = 76,
  updateNicknamePermission = 77,
  whiteboardPermission = 78,
  localRecordPermission = 79,
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

export interface Progress {
  total?: string
  loaded?: string
  percentage: number
  percentageText?: string
}

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
  idClient: string
  /**
   * 文件
   */
  file?: {
    name: string
    ext: string
    size: number
    url: string
    filePath: string
    w: number
    h: number
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

  progress: Progress
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

export interface NEMeetingCaptionMessage extends NERoomCaptionMessage {
  fromNickname: string
}

export interface CaptionMessageUserInfo {
  userId: string
  nickname: string
  avatar?: string
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
  noCaptions?: boolean
  noTranscription?: boolean
  pluginNotifyDuration?: number
  noChat?: boolean
  noWhiteboard?: boolean
  noInvite?: boolean
  noSip?: boolean
  noSwitchAudioMode?: boolean
  noGallery?: boolean
  noLive?: boolean
  enableAudioShare?: boolean
  detectMutedMic?: boolean
  defaultWindowMode?: NEWindowMode

  showScreenShareUserVideo?: boolean
  toolBarList?: ToolBarList
  moreBarList?: MoreBarList
  interpretationSetting?: NEMeetingInterpretationSettings

  enableDirectMemberMediaControlByHost?: boolean
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
  data: NEProps
  deviceConfig?: NEProps
  appConfig: {
    APP_ROOM_RESOURCE: {
      annotation: boolean
      whiteboard: boolean
      chatroom: boolean
      live: boolean
      rtc: boolean
      record: boolean
      sip: boolean
      waitingRoom: boolean
      sipInvite: boolean
      callOutRoomSystemDevice: boolean
      appInvite: boolean
      caption: boolean
      guest: boolean
      screenShare:
        | {
            enable: boolean
            message: string
          }
        | undefined
      transcript: boolean
      interpretation?: {
        enable: boolean
        maxInterpreters: number
        enableCustomLang: boolean
        maxCustomLanguageLength: number
        maxLanguagesPerInterpreter: number
      }
      summary: boolean
    }
    MEETING_BEAUTY?: {
      enable: boolean
      licenseUrl: string
      md5: string
      levels: number[]
    }
    MEETING_CHATROOM?: {
      enableFileMessage: boolean
      enableImageMessage: boolean
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
    MEETING_LIVE?: {
      maxThirdPartyNum: number
    }
    inboundPhoneNumber?: string
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
  nim: IM
  imAccid: string
  imAppKey: string
  imToken: string
  nickName: string
  chatRoomId: string
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
  startTime?: number
  endTime?: number
  states?: number[]
}

export interface NEMeetingCreateOptions extends NEMeetingBaseOptions {
  video?: number
  audio?: number
  subject?: string
  roleBinds?: Record<string, string>
  noSip?: boolean
  noChat?: boolean
  noWhiteBoard?: boolean
  openLive?: boolean
  liveOnlyEmployees?: boolean
  liveChatRoomEnable?: boolean
  noCloudRecord?: boolean
  extraData?: string
  attendeeVideoOff?: boolean
  attendeeAudioOff?: boolean
  attendeeAudioOffType?: AttendeeOffType
  startTime?: number
  endTime?: number
  createMeetingReport?: IntervalEvent
  enableWaitingRoom?: boolean
  enableGuestJoin?: boolean
  enableJoinBeforeHost?: boolean
  recurringRule?: Record<string, NEMeetingRecurringRule>
  scheduledMembers?: NEScheduledMember[]
  timezoneId?: string
  interpretation?: {
    interpreters?: {
      [key: string]: string[]
    }
    started: boolean
  }
  cloudRecordConfig?: NECloudRecordConfig
  liveConfig?: NEMeetingLivePrivateConfig
}

export interface PlatformInfo {
  platformName: string
  pushUrl: string
  pushSecretKey?: string
  id?: string
}

interface NEMeetingLivePrivateConfig {
  title: string
  background?: NEMeetingItemLiveBackground
  pushThirdParties?: NEmeetingItemLivePushThirdPart[]
  enableThirdParties?: boolean
  password?: string
}
interface NEMeetingBaseOptions {
  meetingId?: number
  meetingNum: string // 原先使用meetingId后续兼容meetingNum
  nickName: string
  password?: string
  memberTag?: string
  noChat?: boolean
  noWhiteBoard?: boolean
  noCaptions?: boolean
  avatar?: string
  /**
   * 视频分辨率及帧率设置
   */
  videoProfile?: {
    resolution: VideoResolution
    frameRate: VideoFrameRate
  }
  encryptionConfig?: NEEncryptionConfig
  joinTimeout?: number
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
  NoPermission = 10212, // 无权限
  RepeatJoinRtc = 30004
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
  isAudioOn: boolean
  isSharingScreen: boolean
  isSharingSystemAudio: boolean
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
  interpretation = 31,
  annotation = 30,
  caption = 32,
  transcription = 33,
  feedback = 34,
  emoticons = 35,
}

export enum SingleMenuIds { // 单状态按钮
  participants = 3,
  manageParticipants = 4,
  invite = 20,
  chat = 21,
}

export enum MultipleMenuIds { // 多状态按钮
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

export type NECloudRecordConfig = {
  enable: boolean
  recordStrategy: NECloudRecordStrategyType
}

export enum NECloudRecordStrategyType {
  HOST_JOIN = 0,
  MEMBER_JOIN = 1,
}

/// 聊天消息提醒类型
export enum NEChatMessageNotificationType {
  /// 弹幕
  barrage = 0,

  /// 气泡
  bubble = 1,

  /// 不提醒
  noRemind = 2,
}

export interface MeetingSetting {
  normalSetting: {
    openVideo: boolean
    openAudio: boolean
    showDurationTime: boolean
    showParticipationTime: boolean
    showTimeType: number
    showSpeakerList: boolean
    showToolbar: boolean
    enableTransparentWhiteboard: boolean
    enableVoicePriorityDisplay: boolean
    downloadPath: string
    language: string
    chatMessageNotificationType: NEChatMessageNotificationType
    foldChatMessageBarrage: boolean
    enableShowNotYetJoinedMembers: boolean
    automaticSavingOfMeetingChatRecords: boolean
    leaveTheMeetingRequiresConfirmation: boolean
    enterFullscreen: boolean
  }
  captionSetting: {
    /** 字幕字号 */
    fontSize: number
    /** 入会时开启字幕 */
    autoEnableCaptionsOnJoin: boolean
    /** 目标翻译语言 */
    targetLanguage?: NERoomCaptionTranslationLanguage
    /** 字幕是否同时显示双语 */
    showCaptionBilingual?: boolean
    /** 转写是否同时显示双语 */
    showTranslationBilingual?: boolean
  }
  videoSetting: {
    deviceId: string
    isDefaultDevice?: boolean
    resolution: number
    // 是否开启视频镜像
    enableVideoMirroring: boolean
    galleryModeMaxCount: number
    enableFrontCameraMirror: boolean
    showMemberName: boolean
    enableHideVideoOffAttendees?: boolean
    enableHideMyVideo?: boolean
  }
  audioSetting: {
    recordDeviceId: string
    isDefaultRecordDevice?: boolean
    playoutDeviceId: string
    isDefaultPlayoutDevice?: boolean
    shouldUnPubOnAudioMute?: boolean
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
    /** 是否使用电脑麦克风，默认关 */
    usingComputerAudio: boolean
  }
  beautySetting: {
    beautyLevel: number
    virtualBackgroundPath: string
    enableVirtualBackgroundForce?: boolean
    externalVirtualBackgroundPath?: string
    enableVirtualBackground: boolean
    virtualBackgroundList?: string[]
    externalVirtualBackgroundList?: string[]
  }
  recordSetting: {
    autoCloudRecord: boolean
    autoCloudRecordStrategy: NECloudRecordStrategyType //  1: 主持人入会后开启 2: 成员入会后开启
  }
  screenShareSetting: {
    sideBySideModeOpen: boolean
    screenShareOptionInMeeting: number // 0: 显示所有 1: 自动共享主屏幕 2: 只显示屏幕
    sharedLimitFrameRateEnable: boolean
    sharedLimitFrameRate: number
  }
}

export interface BeforeMeetingConfig {
  appConfig: {
    APP_ROOM_RESOURCE: {
      whiteboard: boolean
      live: boolean
      record: boolean
      waitingRoom: boolean
      guest: boolean
      interpretation?: {
        enable: boolean
        maxInterpreters: number
        enableCustomLang: boolean
        maxCustomLanguageLength: number
        maxLanguagesPerInterpreter: number
      }
    }
    MEETING_LIVE?: {
      maxThirdPartyNum: number
    }
    MEETING_SCHEDULED_MEMBER_CONFIG?: {
      enable: boolean // 预约会议时是否支持选定成员，默认true
      coHostLimit: number // 模版里配置的联席主持人人数限制，默认4 待定
      max: number // 单会议人数限制
    }
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
  MeetingKit_access_denied = 'MeetingKit_access_denied',
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
  extVersionConfig?: Record<string, unknown>
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

export type AvatarSize = 64 | 48 | 36 | 32 | 24 | 22 | 16

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

export interface ServerError {
  msg: string
  message: string
  code: number
}

export interface InterpreterSettingRef {
  getNeedUpdate(): void
  getNeedSave(): void
  handleCloseBeforeMeetingWindow(): void
  handleCloseInMeetingWindow(): void
}

export interface SaveSipCallItem {
  userUuid: string
  name: string
  phoneNumber: string
}

export interface SaveRoomSipCallItem {
  userUuid: string
  name: string
  protocol: NERoomSipDeviceInviteProtocolType
  roomIP: string
}
