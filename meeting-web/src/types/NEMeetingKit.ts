import {
  CreateOptions,
  CustomOptions,
  EventName,
  GlobalEventListener,
  JoinOptions,
  LoginOptions,
  LogName,
  MoreBarList,
  NEMeetingInitConfig,
  ToolBarList,
} from '@/types/type'

/**
 * 会议组件
 */
export interface NEMeetingKit {
  /**
   *@ignore
   */
  meeting: any
  /**
   * NEMeetingInfo 当前会议信息
   */
  NEMeetingInfo: {
    /**
     * 是否是主持人
     */
    isHost: boolean
    /**
     * 是否锁定房间
     */
    isLocked: boolean
    /**
     * 会议号
     */
    meetingId: string
    /**
     * 会议密码
     */
    password?: string
    /**
     * 会议短号
     */
    shortMeetingId?: string
    /**
     * sipId
     */
    sipId?: string
  }
  /**
   *@ignore
   */
  NESettingService: any
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
  memberInfo: any
  /**
   * 入会成员信息
   */
  joinMemberInfo: any
  /**
   * 增加全局事件监听
   */
  addGlobalEventListener: (eventListener: GlobalEventListener) => void
  /**
   * 初始化接口
   * @param width 画布宽度
   * @param height 画布高度
   * @param config 配置项
   */
  init: (width: number, height: number, config: NEMeetingInitConfig) => void
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
  login: (options: LoginOptions, callback: () => void) => void
  /**
   * 创建会议接口
   * @param options 相应配置参数
   * @param callback 接口回调
   */
  create: (options: CreateOptions, callback: () => void) => void
  /**
   * 加入会议接口
   * @param options 相应配置参数
   * @param callback 接口回调
   */
  join: (options: JoinOptions, callback: () => void) => void
  /**
   * 动态更新自定义按钮
   * @param options
   */
  setCustomList: (options: CustomOptions) => void
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
  off: (actionName: string, callback?: (data: any) => void) => void
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
  uploadLog: (logNames?: LogName, start?: number, end?: number) => void
  /**
   * 下载日志接口
   * @param logNames 日志类型类型
   * @param start 日志开始时间
   * @param end 日志结束时间
   */
  downloadLog: (logNames?: LogName, start?: number, end?: number) => void
  /**
   * im 复用场景需要调用该方法，入参为IM，该方法会重新处理getInstance并返回一个包装过的IM，然后直接调用IM.getInstance方法
   */
  reuseIM: (IM: any) => IM
  /**
   * electron环境使用用于设置需要共享的源id
   * @param sourceId
   * @ignore
   */
  setScreenSharingSourceId: (sourceId: string) => void
  /**
   * electron环境下有效是否开启共享
   * @param enable
   * @ignore
   */
  enableScreenShare: (enable: boolean) => void
}

export type IM = any
