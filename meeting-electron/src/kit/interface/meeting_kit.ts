import { NEGlobalEventListener } from 'neroom-web-sdk'
import {
  NEMeetingAppNoticeTips,
  NEMeetingInitConfig,
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

export type NEMeetingKitConfig = NEMeetingInitConfig

/**
 * 组件当前支持的语言类型。通过{@link NEMeetingKit#switchLanguage(NEMeetingLanguage)} 可切换语言。
 * CHINESE 中文；ENGLISH 英文；JAPANESE 日文；
 */

interface NEMeetingKit {
  /**
   * 获取当前配置
   */
  get config(): NEMeetingKitConfig | undefined
  /**
   * 获取当前语言
   */
  get currentLanguage(): NEMeetingLanguage
  /*
   * 查询会议SDK当前是否已经完成初始化
   */
  get isInitialized(): boolean
  /**
   * 初始化会议组件，只有在完成初始化后才能调用会议组件的其他接口。
   * 可通过 NEMeetingKitConfig#appKey 初始化。也可以
   * 通过企业代码 NEMeetingKitConfig#corpCode 或企业邮箱
   * NEMeetingKitConfig#corpEmail 进行初始化，
   * 通过企业信息初始化成功后会返回 NEMeetingCorpInfo。
   * @param config 初始化配置
   */
  initialize(config: NEMeetingKitConfig): Promise<NEResult<NEMeetingCorpInfo>>
  /**
   * 切换语言
   * @param language 对应需要切换语言类型（默认跟随浏览器）
   */
  switchLanguage(language: NEMeetingLanguage): void
  /**
   * 获取会议日志路径
   */
  getMeetingLogPath(): string
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
   *  获取通讯录服务，如果未完成初始化，则返回为空
   *  @return 通讯录服务实例
   */
  getContactsService(): NEContactsService | undefined

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
  getSDKLogPath(): string

  /*
   * 获取公告提示
   * @return 返回应用公告提示文案
   */
  getAppNoticeTips(): Promise<NEResult<NEMeetingAppNoticeTips>>
}

export default NEMeetingKit
