/**
 * 初始化相关配置
 */
export type NEMeetingInitConfig = {
  /**
   * 会议appKey
   */
  appKey: string
  /**
   * 会议服务器地址，支持私有化配置
   */
  meetingServerDomain?: '' //会议服务器地址，支持私有化部署
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
}

/**
 * 加入会议参数配置
 */
export interface JoinOptions {
  meetingId: number // 1随机0固定
  /**
   * 用户昵称
   */
  nickName: string
  /**
   * 是否开启视频入会 1为开启 2为关闭
   */
  video?: number
  /**
   * 是否开启音频入会 1为开启 2为关闭
   */
  audio?: number
  /**
   * 会时模式，1 常规（默认）， 2开启白板入会
   */
  defaultWindowMode?: number
  /**
   * 是否开启会中改名，默认为false（开启）
   */
  noRename?: boolean
  /**
   * 开启会议录制，false（默认） 录制 true 不录制
   */
  noCloudRecord?: boolean
  /**
   * 成员自定义标签
   */
  memberTag?: string
  /**
   * 会议号展示 0 都展示 1 展示长号，2 展示短号 默认为 0
   */
  meetingIdDisplayOptions?: NEMeetingIdDisplayOptions
  /**
   * 入会密码 创建会议传入则创建有密码的会议
   */
  password?: string
  /**
   * 是否显示会议应进最大人数,需配合extraData字段设置
   */
  showMaxCount?: boolean
  /**
   * 是否显示会议主题
   */
  showSubject?: boolean
  /**
   * 是否显示成员标签
   */
  showMemberTag?: boolean
  /**
   * 成员入会后全体关闭视频，且不允许自主打开，默认允许打开
   */
  attendeeVideoOff?: number
  /**
   * 成员入会后全体静音，且不允许自主打开，默认允许打开
   */
  attendeeAudioOff?: number
  /**
   * 扩展字段，格式为json字符串，如果showMaxCount字段设置为true，且该字段传{maxCount: 100}，会议应进最大人数为100
   */
  extraData?: string
  /**
   * 成员列表底部按钮配置
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
   * 是否显示设置焦点后画面右上角的按钮， 默认为true
   */
  showFocusBtn: boolean
  /**
   * 视频分辨率及帧率设置
   */
  videoProfile?: {
    resolution: VideoResolution
    frameRate: VideoFrameRate
  }
  /**
   * 焦点成员分辨率及帧率设置
   */
  focusVideoProfile?: {
    resolution: VideoResolution
    frameRate: VideoFrameRate
  }
  /**
   * 是否开启根据声音大小排序 默认为true
   */
  enableSortByVoice?: boolean
  /**
   * 是否设置主持人默认焦点 默认 false
   */
  enableSetDefaultFocus?: boolean
  /**
   * 是否关闭sip  true为不开启 false为开启，默认为不开启
   */
  noSip?: boolean
  /**
   * 入会角色绑定
   */
  roleBinds: Record<userUuid, Role>
  /**
   * 是否显示说话者列表
   */
  showSpeaker: boolean
  /**
   * 是否显示会议剩余时间提醒
   */
  showMeetingRemainingTip: boolean
  toolBarList: ToolBarList
  moreBarList: MoreBarList
  /**
   * 是否能够通过长按空格解除静音
   */
  enableUnmuteBySpace: boolean
  chatroomConfig: {
    /**
     * 聊天室是否开启文件上传
     */
    enableFileMessage?: boolean
    /**
     * 聊天室是否开启图片上传
     */
    enableImageMessage?: boolean
  }
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

export interface CreateOptions extends JoinOptions {
  meetingId: number // 1随机0固定
}

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
  type: 'single' | 'multiple'
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
  injectItemClick?: (btnInstance: { btnStatus: boolean }) => void
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
 * 事件名称 peerJoin 成员加入 peerLeave 成员离开
 */
export type EventName = 'peerJoin' | 'peerLeave'

export interface Speaker {
  uid: string
  nickName: string
  leave: number // 声音大小
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
