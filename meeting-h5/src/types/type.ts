import { LayoutTypeEnum, MeetingSetting } from './innerType'
import WebRoomkit, { NERoomLiveState } from 'neroom-web-sdk'
import NEMeetingService from '../services/NEMeeting'

export interface NEMember {
  /**
   * 音频是否打开
   */
  isAudioOn: boolean
  /**
   * 当前成员是否在聊天室内
   */
  isInChatroom: boolean
  /**
   * 当前成员是否在RTC房间内
   */
  isInRtcChannel: boolean
  /**
   * 当前成员是否正在屏幕共享中
   */
  isSharingScreen: boolean
  /**
   * 视频是否打开
   */
  isVideoOn: boolean
  /**
   * 当前成员是否正在共享白板
   */
  isSharingWhiteboard: boolean
  /**
   * 用户名
   */
  name: string
  /**
   * 属性
   */
  properties: {
    wbDrawable?: { value: '1' | '0' }
    // 当前成员是否在系统通过状态
    phoneState?: { value: '1' | '0' }
    // 当前成员标签
    tag?: { value: string }
    [key: string]: any
  }
  /**
   * 角色
   */
  role: string
  /**
   * 用户id
   */
  uuid: string
  /**
   * 用户的终端类型[NEClientType]
   */
  clientType: NEClientType
  /**
   * @ignore 不对外暴露
   */
  rtcUid?: number
  isHandsUp?: boolean
}

export enum NEClientType {
  WEB = 'web',
  ANDROID = 'android',
  IOS = 'ios',
  PC = 'pc',
  MINIAPP = 'miniApp',
  MAC = 'mac',
  SIP = 'SIP',
  UNKNOWN = 'unknown',
}
export enum NEMeetingRole {
  participant = 'member', // 参会者
  host = 'host', // 主持人
  coHost = 'cohost', // 联席主持人
  ghost = 'ghost', // 影子用户
}

export enum AttendeeOffType {
  offNotAllowSelfOn = 'offNotAllowSelfOn', // 打开全体关闭视频, 允许自行打开
  offAllowSelfOn = 'offAllowSelfOn', // 打开全体关闭视频，不允许自行打开
  disable = 'disable', // 关闭全体关闭视频
}

export type MembersMap = Map<string, NEMember>
// 存储外部用户配置，非sdk获取到的会议信息
export interface NEMeetingInfo extends NEMeetingSDKInfo {
  // 主画面，实际画面长宽非画布长宽
  mainVideoSize: {
    width: number
    height: number
  }
  // 是否根据声音大小进行排序
  enableSortByVoice?: boolean
  layout: LayoutTypeEnum
  // 配置是否开启透明白板
  enableTransparentWhiteboard?: boolean
  // 当前房间属性是否是透明白板
  isWhiteboardTransparent?: boolean
  /**
   * 是否能够通过长按空格解除静音
   */
  enableUnmuteBySpace?: boolean
  chatroomConfig?: {
    /**
     * 聊天室是否开启文件上传
     */
    enableFileMessage?: boolean
    /**
     * 聊天室是否开启图片上传
     */
    enableImageMessage?: boolean
  }
  /**
   * 是否显示说话者列表
   */
  showSpeaker?: boolean
  /**
   * 是否显示会议剩余时间提醒
   */
  showMeetingRemainingTip?: boolean
  // 主画面渲染方式：小画面布局还是大画面布局（小布局适用于面试间）
  renderModel?: 'small' | 'big'
  // 聊天室未读消息数量
  unReadChatroomMsgCount?: number

  /**
   * 控制栏按钮配置（h5暂不支持）
   */
  toolBarList: ToolBarList
  /**
   * 更多按钮配置（h5暂不支持）
   */
  moreBarList: MoreBarList
  /**
   * 成员自定义标签
   */
  memberTag?: string
  /**
   * 当前使用环境Electron或者web
   */
  env?: 'electron' | 'web'
  /**
   * 是否显示成员tag，默认关闭
   */
  showMemberTag?: boolean
  /**
   * 是否显示成员列表顶部的房间最大成员数量
   */
  showMaxCount?: boolean
  /**
   * 是否始终固定任务栏 默认固定
   */
  enableFixedToolbar?: boolean
  /**
   * 是否开启本端镜像 默认为true 镜像
   */
  enableVideoMirror?: boolean
  /**
   * 是否显示会议持续时间，默认为false 不显示
   */
  showDurationTime?: boolean
  /**
   * 设置项
   */
  setting: MeetingSetting
}

export interface NEMeetingSDKInfo {
  localMember: NEMember
  myUuid: string
  hostUuid: string
  hostName: string
  screenUuid: string
  whiteboardUuid: string
  focusUuid: string
  activeSpeakerUuid: string
  properties: Record<string, any>
  password?: string
  subject: string
  startTime: number
  endTime: number
  type: number
  shortMeetingNum: string
  sipCid?: string
  meetingNum: string
  meetingInviteUrl: string
  meetingId?: string
  isUnMutedVideo?: boolean
  isUnMutedAudio?: boolean
  audioOff: AttendeeOffType
  videoOff: AttendeeOffType
  isLocked: boolean
  liveConfig: {
    liveAddress: string
  }
  liveState?: NERoomLiveState // 2表示锁定，1解除锁定
  remainingSeconds?: number
}
export interface NEMeetingSDK {
  memberList: NEMember[]
  meetingInfo: NEMeetingSDKInfo
}
export interface NEMeeting {
  memberList: NEMember[]
  meetingInfo: NEMeetingInfo
}
/**
 * 初始化相关配置
 */
export type NEMeetingInitConfig = {
  /**
   * 是否开启日志打印(默认为true)
   */
  debug?: boolean
  /**
   * 国际化语言
   */
  locale?: string
  /**
   * 是否开启日志上(报默认为true)
   */
  eventTracking?: boolean
  /**
   * 会议appKey
   */
  appKey: string
  /**
   * 会议服务器地址，支持私有化配置
   */
  meetingServerDomain?: string //会议服务器地址，支持私有化部署
  /**
   * IM私有化配置仅限于私有化配置时使用
   */
  imPrivateConf?: NEIMServerConfig
  // G2 SDK私有化配置仅私有化配置使用
  /**
   * G2 私有化配置仅私有化配置使用
   */
  neRtcServerAddresses?: NERtcServerConfig
  // 白板私有化仅私有化配置使用
  /**
   * 白板私有化配置使用
   */
  whiteboardConfig?: NEWhiteboardServerConfig
  /**
   * @ignore
   */
  globalEventListener?: Record<string, any>
  /**
   * @ignore
   */
  im?: any
  /**
   * 私有化配置使用，如果配置该字段则会从服务端对应接口拉取配置文件。但是优先级低于其他私有化配置字段，如果配置过其他字段则该配置不生效
   */
  serverUrl?: string
  /**
   * 扩展字段
   */
  extras?: Record<string, any>
}
export type NEIMServerConfig = {
  /**
   * lbs连接地址
   */
  lbs: string
  /**
   * link连接地址
   */
  link: string
  /**
   * 是否对link连接进行https处理
   */
  linkSslWeb: boolean
  /**
   * nos上传地址
   */
  nosUploader: string
  /**
   * nos是否开启https
   */
  httpsEnabled: boolean
  /**
   * nos下载地址 这个是用来接到消息后，要按一定模式替换掉文件链接的。给予一个安全下载链接。
   */
  nosDownloader: string
}

export type NERtcServerConfig = {
  /**
   * 通道信息服务器地址
   */
  channelServer: string
  /**
   * 统计上报服务器地址
   */
  statisticsServer: string
  /**
   * roomServer服务器地址
   */
  roomServer: string
  /**
   * 是否使用ipv6
   */
  useIPv6: boolean
}

export type NEWhiteboardServerConfig = {
  /**
   * getChannelInfo接口的地址。用于创建加入白板房间
   */
  roomServer: string
  /**
   * 白板日志上传接口地址
   */
  sdkLogNosServer: string
  /**
   * 白板日志上报地址
   */
  dataReportServer: string
  /**
   * 白板私有化sdk地址
   * WhiteboardUrl ToolCollectionUrl 白板sdk下载地址
   * PPTRendererUrl 如果需要展示动态ppt，需要添加该文件
   */
  privateSDKUrl?: {
    WhiteboardUrl?: string
    ToolCollectionUrl?: string
    PPTRendererUrl?: string
  }
  /**
   * nos直传地址
   */
  directNosServer: string
  /**
   * 音视频，图片上传地址
   */
  mediaUploadServer: string
  /**
   * 文档转码地址
   */
  docTransServer: string
}

/**
 * 登录参数
 * @param accountId 用户id
 * @param accountToken 用户token
 */
export type LoginOptions = {
  accountId: string
  accountToken: string
  loginType?: number
}


export interface NEEncryptionConfig {
  encryptionType: NEEncryptionType
  encryptKey: string
}

export type NEEncryptionType = 'none' | 'sm4-128-ecb'

/**
 * 加入会议参数配置
 */
export interface JoinOptions {
  /**
   * 会议号（已弃用）
   * ignore
   */
  meetingId?: number
  /**
   * 会议号
   */
  meetingNum: string
  /**
   * 用户昵称
   */
  nickName: string
  /**
   * 是否开启视频入会 1为开启 2为关闭
   */
  video?: 1 | 2
  /**
   * 是否开启音频入会 1为开启 2为关闭
   */
  audio?: 1 | 2
  /**
   * 会时模式，1 常规（默认）， 2开启白板入会
   * @ignore
   */
  defaultWindowMode?: number
  /**
   * 是否开启会中改名，默认为false（开启）
   * @ignore
   */
  noRename?: boolean
  /**
   * 开启会议录制，false（默认） 录制 true 不录制
   * @ignore
   */
  noCloudRecord?: boolean
  /**
   * 成员自定义标签
   * @ignore
   */
  memberTag?: string
  /**
   * 会议号展示 0 都展示 1 展示长号，2 展示短号 默认为 0
   * @ignore
   */
  meetingIdDisplayOptions?: NEMeetingIdDisplayOptions
  /**
   * 入会密码 创建会议传入则创建有密码的会议
   * @ignore
   */
  password?: string
  /**
   * 是否显示会议应进最大人数,需配合extraData字段设置
   * @ignore
   */
  showMaxCount?: boolean
  /**
   * 是否显示会议主题
   */
  showSubject?: boolean
  /**
   * 是否显示成员标签
   * @ignore
   */
  showMemberTag?: boolean
  /**
   * 成员入会后全体关闭视频，且不允许自主打开，默认允许打开
   * @ignore
   */
  attendeeVideoOff?: boolean
  /**
   * 成员入会后全体静音，且不允许自主打开，默认允许打开
   * @ignore
   */
  attendeeAudioOff?: boolean
  /**
   * 扩展字段，格式为json字符串，如果showMaxCount字段设置为true，且该字段传{maxCount: 100}，会议应进最大人数为100
   * @ignore
   */
  extraData?: string
  /**
   * 成员列表底部按钮配置
   * @ignore
   */
  muteBtnConfig?: {
    /**
     * 显示全体关闭视频按钮
     */
    showMuteAllVideo: boolean // 显示全体关闭视频按钮
    /**
     * 显示全体开启按钮
     */
    showUnMuteAllVideo: boolean // 显示全体开启按钮
    /**
     * 显示全体静音按钮
     */
    showMuteAllAudio: boolean // 显示全体静音按钮
    /**
     * 显示全体解除静音按钮
     */
    showUnMuteAllAudio: boolean // 显示全体解除静音按钮
  }
  /**
   * 是否显示会议剩余时间提醒，默认为false 关闭
   */
  showMeetingRemainingTip?: boolean
  /**
   * 是否显示设置焦点后画面右上角的按钮， 默认为true
   * @ignore
   */
  showFocusBtn?: boolean
  /**
   * 视频分辨率及帧率设置
   * @ignore
   */
  videoProfile?: {
    resolution: VideoResolution
    frameRate: VideoFrameRate
  }
  /**
   * 焦点成员分辨率及帧率设置
   * @ignore
   */
  focusVideoProfile?: {
    resolution: VideoResolution
    frameRate: VideoFrameRate
  }
  /**
   * 是否开启根据声音大小排序 默认为true
   * @ignore
   */
  enableSortByVoice?: boolean
  /**
   * 是否设置主持人默认焦点 默认 false
   * @ignore
   */
  enableSetDefaultFocus?: boolean
  /**
   * 是否关闭sip  true为不开启 false为开启，默认为不开启
   * @ignore
   */
  noSip?: boolean
  /**
   * 入会角色绑定
   * @ignore
   */
  roleBinds?: Record<userUuid, Role>
  /**
   * 是否显示说话者列表，默认显示
   */
  showSpeaker?: boolean
  /**
   * @ignore
   */
  toolBarList?: ToolBarList
  /**
   * @ignore
   */
  moreBarList?: MoreBarList
  /**
   * 是否能够通过长按空格解除静音
   */
  enableUnmuteBySpace?: boolean
  /**
   * 是否开启透明白板功能，默认为关闭
   */
  enableTransparentWhiteboard?: boolean
  /**
   * 是否始终显示工具栏
   *
   */
  enableFixedToolbar?: boolean
  /**
   * 是否开启本端镜像 默认为true 镜像
   */
  enableVideoMirror?: boolean
  /**
   * 是否显示会议持续时间，默认为false 不显示
   */
  showDurationTime?: boolean

  chatroomConfig?: {
    /**
     * 聊天室是否开启文件上传
     */
    enableFileMessage?: boolean
    /**
     * 聊天室是否开启图片上传
     */
    enableImageMessage?: boolean
  }
  /**
   * 当前集成环境，如果是Electron则设置为electron，其他不需要设置
   */
  env?: 'web' | 'electron'
}

export type userUuid = string

/**
 * 角色
 */
export enum Role {
  member = 'member', // 参会者
  host = 'host', // 主持人
  coHost = 'cohost', // 联席主持人
}
/**
 * 视频分辨率
 */
export type VideoResolution = 180 | 480 | 720 | 1080
/**
 * 视频帧率
 */
export type VideoFrameRate = 5 | 10 | 15 | 20 | 25

export type CreateOptions = JoinOptions

export type CustomOptions = {
  toolBarList: ToolBarList
  moreBarList: MoreBarList
}

export type ToolBar = {
  /**
   * 按钮id
   */
  id: number
  /**
   * 可见范围 0 全体可见 1 主持人可见 2 普通成员可见
   */
  visibility?: 0 | 1 | 2
  /**
   * 按钮配置项
   */
  btnConfig?: BtnConfigList
}

export type BtnConfig = {
  icon: string // 图标 url地址
  text: string // 展示文案
}
/**
 * 按钮配置项
 * icon 按钮图标
 * icon 按钮文案
 */
export type BtnConfigList = BtnConfig | BtnConfig[]
/**
 * 控制栏菜单列表配置
 */
export type ToolBarList = ToolBar[]

export type MoreBar = {
  /**
   * 按钮id
   */
  id: number
  /**
   * 按钮类型，分为单状态按钮和多状态按钮
   */
  type?: 'single' | 'multiple'
  /**
   * 按钮配置项
   * icon 按钮图标
   * icon 按钮文案
   */
  btnConfig?: {
    icon: string // 图标 url地址
    text: string // 展示文案
  }
  /**
   * 默认按钮状态
   */
  btnStatus?: boolean
  /**
   * 按钮触发回调
   */
  injectItemClick?: (btnInstance?: { btnStatus: boolean }) => void
}

/**
 * 更多菜单列表配置
 */
export type MoreBarList = MoreBar[]

export enum NEMeetingIdDisplayOptions {
  /**
   * 默认全部展示
   */
  displayAll, // 默认
  /**
   * 只展示长号
   */
  displayLongId, // 只展示长号
  /**
   * 只展示短号
   */
  displayShortId, // 只展示短号
}
export type LogName = 'meetingLog' | 'rtcLog' | 'imLog'
/**
 * peerJoin 成员加入: (member) => void
 * peerLeave 成员离开: (uuids: string[]) => void
 * roomEnded 房间结束: (reason: NEMeetingLeaveType) => void
 */
export type EventName = 'peerJoin' | 'peerLeave' | 'roomEnded'
/**
 * 会议组件
 */
export interface NEMeetingKit {
  /**
   * NEMeetingInfo 当前会议信息
   */
  // meeting: any

  /**
   * @ignore
   */
  globalEventListener: GlobalEventListener | null

  /**
   *@ignore
   */
  view: HTMLElement | null
  /**
   *@ignore
   */
  isInitialized: boolean

  /**
   *@ignore
   */
  neMeeting: NEMeetingService | null
  /**
   *@ignore
   */
  roomkit: WebRoomkit
  /**
   * NEMeetingInfo 当前会议信息
   */
  NEMeetingInfo: {
    isHost: boolean
    isLocked: boolean
    meetingNum: string
    meetingId: string
    password?: string
    shortMeetingId?: string
    sipId?: string
  }
  /**
   *@ignore
   */
  // NESettingService: any
  /**
   * 控制栏按钮配置 (h5暂不支持)
   */
  toolBarList: ToolBarList
  /**
   * 更多按钮配置
   */
  moreBarList: MoreBarList
  /**
   * 当前成员信息 (h5暂不支持)
   */
  memberInfo: NEMember
  /**
   * 入会成员信息
   */
  joinMemberInfo: {
    [key: string]: NEMember
  }
  /**
   * 初始化接口
   * @param width 画布宽度
   * @param height 画布高度
   * @param config 配置项
   */
  init: (
    width: number,
    height: number,
    config: NEMeetingInitConfig,
    callback: () => void
  ) => void
  /**
   * 销毁房间方法
   */
  destroy: () => void
  /**
   * 离开房间回调方法
   * @param callback
   */
  afterLeave: (callback: () => void) => void
  /**
   * 登录接口
   * @param options 相应配置项
   * @param callback 接口回调
   */
  login: (options: LoginOptions, callback: (e?: any) => void) => void
  /**
   * @ignore
   * 账号密码登录接口
   * @param options 相应配置项
   * @param callback 接口回调
   */
  loginWithPassword: (
    options: { username: string; password: string },
    callback: (e?: any) => void
  ) => void
  /**
   * @ignore
   */
  anonymousJoinMeeting: (
    options: JoinOptions,
    callback: (e?: any) => void
  ) => void
  /**
   * 登出接口
   * @param callback 接口回调
   */
  logout: (callback: () => void) => void
  /**
   * 创建会议接口
   * @param options 相应配置参数
   * @param callback 接口回调
   */
  create: (options: CreateOptions, callback: (e?: any) => void) => void
  /**
   * 加入会议接口
   * @param options 相应配置参数
   * @param callback 接口回调
   */
  join: (options: JoinOptions, callback: (e?: any) => void) => void
  /**
   * 动态更新自定义按钮
   * @param options
   */
  // setCustomList: (options: CustomOptions) => void
  /**
   * 事件监听接口
   * @param actionName 事件名
   * @param callback 事件回调
   */
  on: (actionName: EventName, callback: (...data: any) => void) => void
  /**
   * 移除事件监听接口
   * @param actionName 事件名
   * @param callback 事件回调
   */
  off: (actionName: EventName, callback?: (...data: any) => void) => void
  /**
   * 设置默认画面展示模式
   * @param mode big | small
   */
  setDefaultRenderMode: (mode: 'big' | 'small') => void
  /**
   * 上传日志接口
   * @param logNames 日志类型名称
   * @param start 日志开始时间
   * @param end 日志结束时间
   */
  // uploadLog: (logNames?: LogName, start?: number, end?: number) => void
  /**
   * 下载日志接口
   * @param logNames 日志类型类型
   * @param start 日志开始时间
   * @param end 日志结束时间
   */
  // downloadLog: (logNames?: LogName, start?: number, end?: number) => void
  /**
   * 检测浏览器是否兼容
   * @return true表示支持
   */
  checkSystemRequirements: () => boolean
  /**
   * im 复用场景需要调用该方法，入参为IM，该方法会重新处理getInstance并返回一个包装过的IM，然后直接调用IM.getInstance方法
   */
  reuseIM: (IM: any) => any
  /**
   * electron环境使用用于设置需要共享的源id
   * @param sourceId
   */
  setScreenSharingSourceId: (sourceId: string) => void
  /**
   * electron环境下有效是否开启共享
   * @param enable
   */
  enableScreenShare: (enable: boolean) => void
  /**
   * 增加全局事件监听
   */
  addGlobalEventListener: (eventListener: GlobalEventListener) => void
  /**
   * 切换语言
   * @param language 对应需要切换语言类型（默认跟随浏览器）
   */
  switchLanguage: (language: NEMeetingLanguage) => void
}

export enum NEMeetingLeaveType {
  leaveBySelf = 0,
  endBySelf = 1,
  leaveByHost = 2,
  endByHost = 3,
  networkError = 4,
}

export default interface NEMeetingKitAction {
  actions: NEMeetingKit
}

export interface SipMember {
  sipNum: string
  sipHost: string
  status: 1 | 2 | 3 | 4 // 邀请状态，1.邀请中，2.邀请成功，3.拒绝，4.挂断 |
  inviterUid: string // 邀请人id
}

export interface MeetingList {
  attendeeId: number // 参会记录id
  roomArchiveId: number
  meetingNum: number
  subject: string
  type: number
  roomStartTime: number
  ownerNickname: string
  isFavorite: boolean
}

/**
 * 组件当前支持的语言类型。通过{@link NEMeetingKit#switchLanguage(NEMeetingLanguage)} 可切换语言。
 * CHINESE 中文；ENGLISH 英文；JAPANESE 日文；
 */
export enum NEMeetingLanguage {
  CHINESE = 'CHINESE',
  ENGLISH = 'ENGLISH',
  JAPANESE = 'JAPANESE',
}
// export type NEMeetingLanguage = 'CHINESE' | 'ENGLISH' | 'JAPANESE'

/**
 * 全局事件监听
 */
export interface GlobalEventListener {
  /**
   * rtc engine 初始化前回调
   */
  beforeRtcEngineInitialize: (meetingId: string) => void
  /**
   * rtc engine 初始化后回调
   */
  afterRtcEngineInitialize: (meetingId: string, rtcWrapper: RtcWrapper) => void
  /**
   * rtc engine 销毁前回调
   */
  beforeRtcEngineRelease: (meetingId: string, rtcWrapper: RtcWrapper) => void
}
/**
 * RTC实例包装类，可获取RTC实例，添加/删除RTC回调
 */
export interface RtcWrapper {
  /**
   * 获取RTC实例
   */
  rtcEngine: {
    client: any
  }
}
