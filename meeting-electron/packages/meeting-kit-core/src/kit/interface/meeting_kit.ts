import { NEGlobalEventListener, NEServerConfig } from 'neroom-types'
import {
  NEMeetingAppNoticeTips,
  NEMeetingLanguage,
  NEResult,
} from '../../types/type'
import NEMeetingAccountService, {
  NEMeetingCorpInfo,
} from './service/meeting_account_service'
import NEContactsService from './service/meeting_contacts_service'
import NEMeetingInviteService from './service/meeting_invite_service'
import NEMeetingService from './service/meeting_service'
import NEPreMeetingService from './service/pre_meeting_service'
import NESettingsService from './service/settings_service'
import { IM } from '../../types/NEMeetingKit'
import NEMeetingMessageChannelService from './service/meeting_message_channel_service'
import NEFeedbackService from './service/feedback_service'
import { NEGuestService } from './service/guest_service'

export type NEMeetingKitServerConfig = NEServerConfig

export { NEMeetingLanguage }

export type ExceptionHandler = {
  onError: (code: number) => void
}

export type NEMeetingKitConfig = {
  /** 会议AppKey */
  appKey: string
  /** 应用名称 */
  appName?: string
  /** 是否检查并使用私有化服务器配置文件，默认false(仅ELectron版本支持) */
  useAssetServerConfig?: boolean
  /** 应用名称 */
  extras?: Record<string, unknown>
  /** 显示语言，默认系统语言 */
  language?: NEMeetingLanguage
  /** 私有化地址 */
  serverUrl?: string
  /** 企业码，如果填写则会使用企业码进行初始化 */
  corpCode?: string
  /** 企业邮箱，如果填写则会使用企业邮箱进行初始化 */
  corpEmail?: string
  /** 用于复用IM的实例 */
  im?: IM
  /** 私有化配置 */
  serverConfig?: NEMeetingKitServerConfig
  /** 用于设置会议显示区域宽度，(设置为0 则根据容器自适应) */
  width: number
  /** 用于设置会议显示区域高度，(设置为0 则根据容器自适应) */
  height: number
}

/**
 * 组件当前支持的语言类型。通过{@link NEMeetingKit#switchLanguage(NEMeetingLanguage)} 可切换语言。
 * CHINESE 中文；ENGLISH 英文；JAPANESE 日文；
 */

interface NEMeetingKit {
  /*
   * 查询会议SDK当前是否已经完成初始化
   */
  readonly isInitialized: boolean
  /**
   * 初始化会议组件，只有在完成初始化后才能调用会议组件的其他接口。
   * 可通过 NEMeetingKitConfig#appKey 初始化。也可以
   * 通过企业代码 NEMeetingKitConfig#corpCode 或企业邮箱
   * NEMeetingKitConfig#corpEmail 进行初始化，
   * 通过企业信息初始化成功后会返回 NEMeetingCorpInfo。
   * @param config 初始化配置
   */
  initialize(
    config: NEMeetingKitConfig
  ): Promise<NEResult<NEMeetingCorpInfo | undefined>>
  /**
   * 反初始化会议组件，释放资源
   */
  unInitialize(): Promise<NEResult<void>>

  /**
   * 切换语言
   * @param language 对应需要切换语言类型（默认跟随浏览器）
   */
  switchLanguage(language: NEMeetingLanguage): Promise<NEResult<void>>
  /**
   * 获取会议服务
   */
  getMeetingService(): NEMeetingService | undefined
  /**
   * 获取用于邀请服务服务
   */
  getMeetingInviteService(): NEMeetingInviteService | undefined
  /**
   * 获取当前版本
   */
  getAccountService(): NEMeetingAccountService | undefined
  /**
   * 获取会议设置服务
   */
  getSettingsService(): NESettingsService | undefined
  /*
   * 获取会议前服务
   */
  getPreMeetingService(): NEPreMeetingService | undefined
  /**
   * 获取会议消息通知服务,如果未完成初始化，则返回为空
   */
  getMeetingMessageChannelService(): NEMeetingMessageChannelService | undefined
  /**
   *  获取通讯录服务，如果未完成初始化，则返回为空
   *  @return 通讯录服务实例
   */
  getContactsService(): NEContactsService | undefined
  /**
   *  获取反馈服务，如果未完成初始化，则返回为空
   *  @return 反馈服务实例
   */
  getFeedbackService(): NEFeedbackService | undefined
  /**
   *  获取访客服务，如果未完成初始化，则返回为空
   *  @return 反馈访客实例
   */
  getGuestService(): NEGuestService | undefined
  /**
   * 注册登录状态监听器
   * @param listener 全局事件监听器
   */
  addGlobalEventListener: (listener: NEGlobalEventListener) => void

  /**
   * 注册登录状态监听器
   * @param listener 全局事件监听器
   */
  removeGlobalEventListener: (listener: NEGlobalEventListener) => void

  /**
   * 获取会议日志路径
   * @return 返回日志路径
   */
  getSDKLogPath(): Promise<NEResult<string>>

  /*
   * 获取公告提示
   * @return 返回应用公告提示文案
   */
  getAppNoticeTips(): Promise<NEResult<NEMeetingAppNoticeTips>>
  /**
   * 设置异常处理
   */
  setExceptionHandler(handler: ExceptionHandler): void
}

export default NEMeetingKit
