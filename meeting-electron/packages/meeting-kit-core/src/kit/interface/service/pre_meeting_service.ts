import { NEResult, NERoomRecord } from 'neroom-types'
import { CreateMeetingResponse, NECloudRecordConfig } from '../../../types'
import {
  MeetingListItem,
  NEHistoryMeetingDetail,
  NEScheduledMember,
  AttendeeOffType as NEAttendeeOffType,
  NEMeetingWebAppItem,
  NELocalHistoryMeeting,
  NELocalRecordInfo
} from '../../../types/type'
import { NEMeetingRoleType } from './meeting_service'

type NEMeetingRecord = NERoomRecord

export { NEMeetingRecord }

export { NEScheduledMember }

export { NEMeetingWebAppItem }

export { NELocalHistoryMeeting }

export { NELocalRecordInfo }

export type NEPreMeetingListener = {
  /**
   * 会议信息变更回调，一次回调可能包含多个会议信息或状态的变更
   * @param meetingItemList 变更的会议列表
   */
  onMeetingItemInfoChanged?: (meetingItemList: NEMeetingItem[]) => void
  /**
   * 本地录制状态回调
   * @param status 本地录制的状态
   */
  onLocalRecorderStatus?: (status: number) => void
  /**
   * 本地录制状态回调
   * @param status 本地录制错误
   */
  onLocalRecorderError?: (status: number) => void
}

/// 聊天室导出状态
export const enum NEChatroomExportAccess {
  /** 未知 */
  kUnknown = 0,
  /** 可导出 */
  kAvailable,
  /** 无权限导出 */
  kNoPermission,
  /** 已过期 */
  kOutOfDate,
}

/// 会议状态
export enum NEMeetingItemStatus {
  /** 无效状态 */
  invalid = 0,
  /** 会议初始状态，没有人入会 */
  init = 1,
  /** 已开始 */
  started = 2,
  /** 已结束可以再次入会 */
  ended = 3,
  /** 已取消 */
  cancel = 4,
  /** 已回收，不能再次入会 */
  recycled = 5,
}
export { NEAttendeeOffType }
export type NERemoteHistoryMeeting = MeetingListItem
export type NERemoteHistoryMeetingDetail = NEHistoryMeetingDetail

export type NEMeetingControl = {
  /** 控制类型：'audio' | 'video' */
  type: string
  /** 开关类型 */
  attendeeOff: NEMeetingAttendeeOffType
}

export enum NEMeetingAttendeeOffType {
  /** 无操作 */
  AttendeeOffTypeNone = 0,
  /** 关闭，允许自行打开 */
  AttendeeOffTypeOffAllowSelfOn = 1,
  /** 关闭，不允许自行打开 */
  AttendeeOffTypeOffNotAllowSelfOn = 2,
}

export enum NEMeetingType {
  /** 随机会议 */
  NEMeetingTypeRadom = 1,
  /** 个人会议 */
  NEMeetingTypePersonal = 2,
  /** 预约会议 */
  NEMeetingTypeReservation = 3,
}

export type NEMeetingItemSetting = {
  /**@deprecated 入会时云端录制开关，废弃，建议使用{@link NEMeetingItem.cloudRecordConfig.enable}替代 */
  cloudRecordOn: boolean
  /** 成员音视频控制 */
  controls: NEMeetingControl[]
  /** 当前用户音频控制 */
  currentAudioControl: NEMeetingControl
  /** 当前用户视频控制 */
  currentVideoControl: NEMeetingControl
}

export enum NEMeetingLiveAuthLevel {
  /** 不需要鉴权 */
  NEMeetingLiveAuthLevelNormal = 0,
  /** 需要登录并且账号要与直播应用绑定 */
  NEMeetingLiveAuthLevelToken = 1,
  /** 需要登录并且账号要与直播应用绑定 */
  NEMeetingLiveAuthLevelAppToken = 2,
}

export enum NEMeetingItemLiveStatus {
  /* 无效状态 */
  NEMeetingItemLiveStatusInvalid = 0,
  /* 会议直播初始状态，未开始 */
  NEMeetingItemLiveStatusInit,
  /** 已开始直播 */
  NEMeetingItemLiveStatusStarted,
  /* 已结束直播 */
  NEMeetingItemLiveStatusEnded,
}

export type NEMeetingItemLive = {
  enable: boolean
  liveWebAccessControlLevel: NEMeetingLiveAuthLevel
  hlsPullUrl: string
  httpPullUrl: string
  rtmpPullUrl: string
  liveUrl: string
  pushUrl: string
  chatRoomId: string
  liveAVRoomUids: string[]
  liveChatRoomEnable: boolean
  meetingNum: string
  state: NEMeetingItemLiveStatus
  taskId: string
  title: string
  liveChatRoomIndependent: boolean
  liveBackground?: NEMeetingItemLiveBackground
  livePushThirdParties?: NEmeetingItemLivePushThirdPart[]
  enableThirdParties?: boolean
  livePassword?: string
}

export type NEmeetingItemLivePushThirdPart = {
  platformName: string
  pushUrl: string
  pushSecretKey?: string
}

export type NEMeetingItemLiveBackground = {
  backgroundUrl?: string
  backgroundFile?: Blob | string
  notStartCoverUrl?: string
  thumbnailBackUrl?: string
  thumbnailBackFile?: Blob | string
  notStartThumbnailUrl?: string
}

export type NEMeetingRecurringRule = CreateMeetingResponse['recurringRule']

export type NEMeetingInterpreter = {
  userId: string
  firstLang: string
  secondLang: string
  isValid: boolean
}

export type NEMeetingItem = {
  /** 会议唯一标识 */
  meetingId: number
  /** 会议号 */
  meetingNum: string
  /** 会议主题 */
  subject: string
  /** 会议开始时间 */
  startTime: number
  /** 会议结束时间 */
  endTime: number
  /** 是否开启SIP功能，默认为false */
  noSip: boolean
  /** 配置会议是否默认开启等候室 */
  waitingRoomEnabled: boolean
  /** 配置会议是否允许参会者在主持人进入会议前加入会议，默认为允许 */
  enableJoinBeforeHost: boolean
  /** 是否允许访客入会 */
  enableGuestJoin: boolean
  /** 会议密码 */
  password: string
  /** 会议额外选项 */
  settings: NEMeetingItemSetting
  /** 会议状态 */
  status: NEMeetingItemStatus
  /** 会议类型 */
  meetingType: NEMeetingType
  /** 会议邀请链接 */
  inviteUrl: string
  /** 房间号 */
  roomUuid: string
  /** 创建者id */
  ownerUserUuid: string
  /** 创建人昵称 */
  ownerNickname: string
  /** 会议短号 */
  shortMeetingNum: string
  /** 会议直播信息设置 */
  live: NEMeetingItemLive
  /* 会议扩展字段，可空，最大长度为 2K */
  extraData: string
  /** 角色 */
  roleBinds: Record<string, NEMeetingRoleType>
  /** 周期性会议规则 */
  recurringRule?: NEMeetingRecurringRule
  /** 预约指定角色的成员，后台配置开启预定成员功能时有效 */
  scheduledMemberList: NEScheduledMember[]
  /** 时区 */
  timezoneId: string
  /** 同声传译设置。如果设置为nil或译员列表为空，则表示关闭同声传译 */
  interpretationSettings?: {
    interpreterList: NEMeetingInterpreter[]
  }
  /** 云录制设置 */
  cloudRecordConfig: NECloudRecordConfig
  /** sip号 */
  sipCid: string
  /** 跨应用入会token */
  meetingUserToken?: string
  /** 跨应用入会uuid */
  meetingUserUuid?: string
  /** 跨应用入会appKey */
  meetingAppKey?: string
  /** 跨应用鉴权类型 */
  meetingAuthType?: string
  /** 访客跨应用入会类型 0 不允许访客入会 1 实名访客入会 2 匿名访客入会*/
  guestJoinType?: string
}

export type ScheduleCallback = {
  (meetingItems: NEMeetingItem[]): void
}

interface NEPreMeetingService {
  /**
   * 获取收藏会议列表，返回会议时间早于 anchorId 的最多 limit 个会议。
   * 如果 anchorId 小于等于 0，则从头开始查询。
   * @param anchorId 锚点Id，用于分页查询
   * @param limit 查询数量
   */
  getFavoriteMeetingList(
    anchorId: number,
    limit: number
  ): Promise<NEResult<NERemoteHistoryMeeting[]>>
  /**
   * 添加收藏会议
   * @param meetingId 会议唯一id
   */
  addFavoriteMeeting(meetingId: number): Promise<NEResult<number>>
  /**
   * 取消收藏会议
   * @param meetingId 会议唯一id
   */
  removeFavoriteMeeting(meetingId: number): Promise<NEResult<void>>
  /**
   * 获取历史会议列表
   * @param anchorMeetingId 锚点会议 Id，用于分页查询
   * @param limit 查询数量
   */
  getHistoryMeetingList(
    anchorId: number,
    limit: number
  ): Promise<NEResult<NERemoteHistoryMeeting[]>>
  /**
   * 获取历史会议详情
   * @param roomArchiveId 会议唯一id
   */
  getHistoryMeetingDetail(
    meetingId: number
  ): Promise<NEResult<NERemoteHistoryMeetingDetail>>
  /**
   * 获取本地历史会议记录列表，不支持漫游保存，默认保存最近10条记录
   **/
  getLocalHistoryMeetingList(): Promise<NEResult<NELocalHistoryMeeting[]>>
  /**
   * 清空本地历史会议记录列表
   **/
  clearLocalHistoryMeetingList(): Promise<NEResult<void>>
  /**
   * 获取会议云录制记录列表,仅在返回错误码为成功时,才代表有云录制任务,解码任务过程中获取列表可能会有延迟
   *
   * @param meetingId 会议ID
   */
  getMeetingCloudRecordList(
    meetingId: number
  ): Promise<NEResult<NEMeetingRecord[]>>
  /**
   * 根据会议号查询历史会议
   * @param meetingId 会议唯一id
   */
  getHistoryMeeting(
    meetingId: number
  ): Promise<NEResult<NERemoteHistoryMeeting>>
  /**
   * 创建一个会议条目
   */
  createScheduleMeetingItem(): Promise<NEResult<NEMeetingItem>>
  /**
   * 预约会议
   * @param item 会议条目，通过{@link NEPreMeetingService#createScheduleMeetingItem()}创建
   */
  scheduleMeeting: (item: NEMeetingItem) => Promise<NEResult<NEMeetingItem>>
  /**
   * 修改已预定的会议信息
   * @param item 会议条目
   * @param editRecurringMeeting 是否修改所有周期性会议
   */
  editMeeting: (
    meeting: NEMeetingItem,
    editRecurringMeeting: boolean
  ) => Promise<NEResult<NEMeetingItem>>
  /**
   * 取消已预定的会议
   * @param meetingId 会议唯一Id
   * @param cancelRecurringMeeting 是否取消所有周期性会议
   */
  cancelMeeting: (
    meetingId: number,
    cancelRecurringMeeting: boolean
  ) => Promise<NEResult<void>>
  /**
   * 根据 meetingNum 查询预定会议信息
   * @param meetingNum 会议号
   */
  getMeetingItemByNum(meetingNum: string): Promise<NEResult<NEMeetingItem>>
  /**
   * 根据 meetingId 查询预定会议信息
   * @param meetingId 会议Id
   */
  getMeetingItemById(meetingId: number): Promise<NEResult<NEMeetingItem>>
  /**
   * 根据会议状态查询会议信息列表， 不传默认返回NEMeetingItemStatus.init, NEMeetingItemStatus.started
   * @param status 会议状态
   * @param offset 偏移量
   * @param size 数量，默认20
   */
  getMeetingList(
    status: NEMeetingItemStatus[],
    offset: number,
    size: number
  ): Promise<NEResult<NEMeetingItem[]>>
  /**
   * 查询预约会议成员列表
   * @param meetingNum 会议号
   */
  getScheduledMeetingMemberList(
    meetingNum: string
  ): Promise<NEResult<NEScheduledMember[]>>
  /**
   * 注册预定会议状态变更监听器
   * @param listener 监听器
   */
  addListener(listener: NEPreMeetingListener): void
  /**
   * 反注册预定会议状态变更监听器
   * @param listener 监听器
   */
  removeListener(listener: NEPreMeetingListener): void
  /*
   * 获取历史会议的转写信息
   * @param meetingId 会议唯一 Id
   */
  getHistoryMeetingTranscriptionInfo(
    meetingId: number
  ): Promise<NEResult<NEMeetingTranscriptionInfo[]>>

  /*
   * 获取历史会议的转写文件下载地址
   * @param meetingId 会议唯一 Id
   * @param fileKey 转写文件的文件 key
   */
  getHistoryMeetingTranscriptionFileUrl(
    meetingId: number,
    fileKey: string
  ): Promise<NEResult<string>>

  /*
   * 获取历史会议的转写文件的消息列表
   * @param meetingId 会议唯一 Id
   * @param fileKey 转写文件的文件 key
   */
  getHistoryMeetingTranscriptionMessageList(
    meetingId: number,
    fileKey: string
  ): Promise<NEResult<NEMeetingTranscriptionMessage[]>>
  /**
   * 加载小应用页面，用于会议历史详情的展示
   * @param meetingId 会议唯一 Id
   * @param item 小应用对象，通过 {@link NERemoteHistoryMeetingDetail} 对象获取到
   */
  loadWebAppView(
    meetingId: number,
    item: NEMeetingWebAppItem
  ): Promise<NEResult<void>>
  /**
   * 加载会议聊天室历史消息页面
   * @param meetingId 会议唯一 Id
   */
  loadChatroomHistoryMessageView(meetingId: number): Promise<NEResult<void>>
  /**
   * 查询会议聊天室历史消息
   * @param meetingId 会议唯一 Id
   * @param option 查询选项
   */
  fetchChatroomHistoryMessageList(
    meetingId: number,
    option: NEChatroomHistoryMessageSearchOption
  ): Promise<NEResult<NEMeetingChatMessage[]>>
  /*
   * 导出会议聊天室历史消息
   * @param meetingId 会议唯一 Id
   */
  exportChatroomHistoryMessageList(meetingId: number): Promise<NEResult<string>>

  /**
   * 查询特定状态下的会议列表。如果不指定要查询的状态，则会默认查询{@link NEMeetingItemStatus#init}、{@link NEMeetingItemStatus#started}列表。 目前暂不支持查询{@link NEMeetingItemStatus#cancel} 与 {@linkNEMeetingItemStatus#recycled} 状态下的会议列表。
   * 只返回本端预约或者他人预约邀请的会议
   *
   * @param status 目标会议状态列表
   */
  getScheduledMeetingList(
    status: NEMeetingItemStatus[]
  ): Promise<NEResult<NEMeetingItem[]>>

  stopLocalRecorderRemux(): void
}

/**
 * 转写消息对象
 */
export type NEMeetingTranscriptionMessage = {
  /**
   * 讲话者用户唯一 Id
   */
  fromUserUuid: string
  /**
   * 讲话者昵称
   */
  fromNickname: string
  /**
   * 消息内容
   */
  content: string
  /**
   * 消息发送时间，单位为ms
   */
  timestamp: number
}
/**
 * 会议转写信息
 */
export type NEMeetingTranscriptionInfo = {
  /**
   * 当前实时转写状态：1：生成中；2：已生成
   */
  state: number
  /**
   * 开关转写的时间范围列表
   */
  timeRanges: NEMeetingTranscriptionInterval[]

  /**
   * 原始转写文件的 key 列表，可使用 key 获取文件下载地址。文件内容每一行为一条转写消息
   */
  originalNosFileKeys: string[]

  /**
   * txt 格式转写文件的 key 列表，可使用 key 获取文件下载地址。
   */
  txtNosFileKeys: string[]
  /**
   * word 格式的转写文件的 key 列表，可使用 key 获取文件下载地址
   */
  wordNosFileKeys?: string[]

  /**
   * pdf 格式的转写文件的 key 列表，可使用 key 获取文件下载地址。
   */
  pdfNosFileKeys?: string[]
}

/**
 * 会议转写时间段
 */
export type NEMeetingTranscriptionInterval = {
  /**
   * 转写开始时间戳，单位为ms
   */
  start: number
  /**
   * 转写开始时间戳，单位为ms
   */
  stop: number
}

export enum NEChatroomMessageSearchOrder {
  /** 从新消息往旧消息查询 */
  NEChatroomMessageSearchOrderDesc = 0,
  /** 从旧消息往新消息查询 */
  NEChatroomMessageSearchOrderAsc,
}

export type NEChatroomHistoryMessageSearchOption = {
  /** 检索消息起始时间，需要检索的起始时间，没有则传入0。即以该时间为起点，往前或往后查询。单位毫秒 */
  startTime: number
  /** 检索条数，最大限制 100 条 */
  limit: number
  /** 检索顺序 */
  order: NEChatroomMessageSearchOrder
}

export enum NEMeetingChatMessageType {
  /** 文本消息 */
  NEMeetingChatMessageTypeText = 0,
  /** 文件消息 */
  NEMeetingChatMessageTypeFile,
  /** 图片消息 */
  NEMeetingChatMessageTypeImage,
  /** 自定义消息 */
  NEMeetingChatMessageTypeCustom,
}

export type NEMeetingChatMessage = {
  /** 消息唯一 id */
  messageUuid: string
  /** 消息类型 */
  messageType: NEMeetingChatMessageType
  /** 发送者 id */
  fromUserUuid: string
  /** 发送者昵称 */
  fromNick: string
  /** 发送者头像 */
  fromAvatar: string
  /** 接收者 id */
  toUserUuidList: string[]
  /** 发送时间，单位毫秒 */
  time: number
}

export type NEMeetingChatTextMessage = NEMeetingChatMessage & {
  /** 消息内容 */
  text: string
}

export type NEMeetingChatCustomMessage = NEMeetingChatMessage & {
  /** 自定义消息内容 */
  attachStr: string
}

export type NEMeetingChatFileMessage = NEMeetingChatMessage & {
  /** 文件名称 */
  displayName: string
  /** 文件扩展名 */
  extension: string
  /** 文件md5 */
  md5: string
  /** 文件下载地址 */
  url: string
  /** 文件大小 */
  size: number
  /** 缩略图地址  */
  thumbPath: string
  /** 文件路径 */
  path: string
}

export type NEMeetingChatImageMessage = NEMeetingChatFileMessage & {
  /** 图片宽度 */
  width: number
  /** 图片高度 */
  height: number
}

export default NEPreMeetingService
