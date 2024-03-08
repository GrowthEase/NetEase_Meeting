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
  /** 参会者 */
  participant = 'member',
  /** 主持人 */
  host = 'host',
  /** 联席主持人 */
  coHost = 'cohost',
  /** 影子用户 */
  ghost = 'ghost',
}

export enum AttendeeOffType {
  /** 打开全体关闭视频, 允许自行打开 */
  offNotAllowSelfOn = 'offNotAllowSelfOn',
  /** 打开全体关闭视频，不允许自行打开 */
  offAllowSelfOn = 'offAllowSelfOn',
  /** 关闭全体关闭视频 */
  disable = 'disable',
}

export type MembersMap = Map<string, NEMember>
export interface NEMeetingInfo {
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
  startTime: string
  endTime: string
  type: number
  shortMeetingNum: string
  sipCid?: string
  meetingNum: string
  meetingId?: string
  isUnMutedVideo?: boolean
  isUnMutedAudio?: boolean
  audioOff: AttendeeOffType
  videoOff: AttendeeOffType
  isLocked: boolean
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
  /**
   * G2 私有化配置仅私有化配置使用
   */
  neRtcServerAddresses?: NERtcServerConfig
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

/**
 * 加入会议参数配置
 */
export interface JoinOptions {
  /**
   * 会议号（已弃用）
   * ignore
   */
  meetingId?: string
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
  attendeeVideoOff?: number
  /**
   * 成员入会后全体静音，且不允许自主打开，默认允许打开
   * @ignore
   */
  attendeeAudioOff?: number
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
    showMuteAllVideo: boolean
    /**
     * 显示全体开启按钮
     */
    showUnMuteAllVideo: boolean
    /**
     * 显示全体静音按钮
     */
    showMuteAllAudio: boolean
    /**
     * 显示全体解除静音按钮
     */
    showUnMuteAllAudio: boolean
  }
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
   * 控制栏按钮配置
   */
  toolBarList: ToolBarList
  /**
   * 更多按钮配置
   */
  moreBarList: MoreBarList
  /**
   * 会中“会议号”显示规则，默认都显示
   */
  meetingIdDisplayOption?: NEMeetingIdDisplayOption
}

export enum NEMeetingIdDisplayOption {
  /** 长短号都显示，默认规则 */
  DISPLAY_ALL = 0,
  /** 只显示长号 */
  DISPLAY_LONG_ID_ONLY = 1,
  /** 长短号都存在时，只显示短号，若无短号，则显示长号 */
  DISPLAY_SHORT_ID_ONLY = 2,
}

export type userUuid = string

/**
 * 角色
 */
export enum Role {
  /** 参会者 */
  member = 'member',
  /** 主持人 */
  host = 'host',
  /** 联席主持人 */
  coHost = 'cohost',
}
/**
 * 视频分辨率
 */
export type VideoResolution = 180 | 480 | 720 | 1080
/**
 * 视频帧率
 */
export type VideoFrameRate = 5 | 10 | 15 | 20 | 25

/**
 * @ignore
 */
export type CreateOptions = JoinOptions

export type CustomOptions = {
  toolBarList: ToolBarList
  moreBarList: MoreBarList
}

export type BtnConfig = {
  /** 图标 url地址 */
  icon: string
  /** 展示文案 */
  text: string
}
/**
 * 按钮配置项
 */
export type BtnConfigList = BtnConfig | BtnConfig[]
/**
 * 控制栏菜单列表配置
 */
export type ToolBarList = CommonBar[]
/**
 * 更多菜单列表配置
 */
export type MoreBarList = CommonBar[]

export type CommonBar = {
  /**
   * 按钮id
   */
  id: number
  /**
   * 按钮类型，分为单状态按钮和多状态按钮
   */
  type: 'single' | 'multiple'
  /**
   * 按钮配置项
   */
  btnConfig?: BtnConfigList
  /**
   * 可见范围 0 全体可见 1 主持人可见 2 普通成员可见
   */
  visibility?: 0 | 1 | 2
  /**
   * 默认按钮状态
   */
  btnStatus?: boolean
  /**
   * 按钮触发回调
   */
  injectItemClick?: (btnInstance: { btnStatus: boolean }) => void
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
  neMeeting: any
  /**
   * NEMeetingInfo 当前会议信息
   */
  NEMeetingInfo: {
    isHost: boolean
    isLocked: boolean
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
   * 控制栏按钮配置
   */
  toolBarList: ToolBarList
  /**
   * 更多按钮配置
   */
  moreBarList: MoreBarList
  /**
   * 当前成员信息
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
  // afterLeave: (callback: () => void) => void
  /**
   * 登录接口
   * @param options 相应配置项
   * @param callback 接口回调
   */
  login: (options: LoginOptions, callback: (e?: any) => void) => void
  /**
   * 匿名入会接口
   * @param options 相应配置项
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
  // create: (options: CreateOptions, callback: () => void) => void
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
  on: (actionName: EventName, callback: (data: any) => void) => void
  /**
   * 移除事件监听接口
   * @param actionName 事件名
   * @param callback 事件回调
   */
  off: (actionName: EventName, callback?: (data: any) => void) => void
  /**
   * 设置默认画面展示模式
   * @param mode big | small
   */
  // setDefaultRenderMode: (mode: 'big' | 'small') => void
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
   * @param callback 接口回调
   */
  checkSystemRequirements: (
    callback: (err: any, result?: boolean | string) => void
  ) => void
  /**
   * im 复用场景需要调用该方法，入参为IM，该方法会重新处理getInstance并返回一个包装过的IM，然后直接调用IM.getInstance方法
   */
  // reuseIM: (IM: any) => IM
  /**
   * 增加会议状态变更事件监听
   */
  addMeetingStatusListener: (eventListener: NEMeetingStatusListener) => void
  /**
   * 移除会议状态变更事件监听
   */
  removeMeetingStatusListener: () => void
}

export enum NEMeetingLeaveType {
  LEAVE_BY_SELF = 0,
  KICK_OUT = 2,
  CLOSE_BY_MEMBER = 3,
  NetworkError = 4,
  UNKNOWN = 6,
  OTHER = 7,
  LOGIN_STATE_ERROR = 8,
  CLOSE_BY_BACKEND = 9,
  SYNC_DATA_ERROR = 10,
  ALL_MEMBERS_OUT = 11,
  END_OF_LIFE = 12,
  kICK_BY_SELF = 13,
}

export default interface NEMeetingKitAction {
  actions: NEMeetingKit
}

export interface NEMeetingStatusListener {
  /**
   * status: 当前会议状态
   * arg: 该状态附带的额外参数，可参考NEMeetingStatus
   * obj: 该状态附带的额外数据对象，可空
   */
  onMeetingStatusChanged: (
    status: NEMeetingStatus,
    arg?: NEMeetingCode,
    obj?: any
  ) => void
}

export enum NEMeetingStatus {
  /** 当前正在创建或加入会议 */
  MEETING_STATUS_CONNECTING = 0,
  /** 当前正在从会议中断开，断开原因参见NEMeetingCode  */
  MEETING_STATUS_DISCONNECTING = 1,
  /** 创建或加入会议失败 */
  MEETING_STATUS_FAILED = 2,
  /** 当前未处于任何会议中 */
  MEETING_STATUS_IDLE = 3,
  /** 当前处于会议中 */
  MEETING_STATUS_INMEETING = 4,
  /** 当前处于会议最小化状态 */
  MEETING_STATUS_INMEETING_MINIMIZED = 5,
  /** 未知状态 */
  MEETING_STATUS_UNKNOWN = 6,
  /** 当前处于等待状态 */
  MEETING_STATUS_WAITING = 7,
}

export enum NEMeetingCode {
  /** 当前正在从会议中断开，原因为用户主动断开 */
  MEETING_DISCONNECTING_BY_SELF = 0,
  /** 会议断开的类型之一，当前正在从会议中断开，原因为被会议主持人移除 */
  MEETING_DISCONNECTING_REMOVED_BY_HOST = 1,
  /**当前正在从会议中断开，原因为会议被主持人关闭 */
  MEETING_DISCONNECTING_CLOSED_BY_HOST = 2,
  /** 当前正在从会议中断开，原因为账号在其他设备上登录 */
  MEETING_DISCONNECTING_LOGIN_ON_OTHER_DEVICE = 3,
  /**当前正在从会议中断开，原因为自己作为主持人主动结束了会议 */
  MEETING_DISCONNECTING_CLOSED_BY_SELF_AS_HOST = 4,
  /**当前正在从会议中断开，原因为账号信息已过期 */
  MEETING_DISCONNECTING_AUTH_INFO_EXPIRED = 5,
  /** 会议不存在 */
  MEETING_DISCONNECTING_NOT_EXIST = 7,
  /** 同步房间信息失败 */
  MEETING_DISCONNECTING_SYNC_DATA_ERROR = 8,
  /** rtc 模块初始化失败 */
  MEETING_DISCONNECTING_RTC_INIT_ERROR = 9,
  /** 加入频道失败 */
  MEETING_DISCONNECTING_JOIN_CHANNEL_ERROR = 10,
  /** 入会超时 */
  MEETING_DISCONNECTING_JOIN_TIMEOUT = 11,
  /** 会议时长到达上限 */
  MEETING_DISCONNECTING_END_OF_LIFE = 12,
  /** 正在等待验证会议密码 */
  MEETING_WAITING_VERIFY_PASSWORD = 20,
  /** 开始加入RTC */
  MEETING_JOIN_CHANNEL_START = 21,
  /** 加入RTC成功 */
  MEETING_JOIN_CHANNEL_SUCCESS = 22,
}
