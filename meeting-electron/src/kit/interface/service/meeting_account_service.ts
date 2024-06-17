import { NEResult } from 'neroom-web-sdk'
import { EnterPriseInfo, NEAccountInfo } from '../../../types/type'
import { GetAccountInfoListResponse, SearchAccountInfo } from '../../../types'

export interface NEAccountServiceListener {
  /** 登录状态变更为未登录，原因为当前登录账号已在其他设备上重新登录 */
  onKickOut: () => void
  /** 账号信息过期通知，原因为用户修改了密码，应用层随后应该重新登录 */
  onAuthInfoExpired: () => void
  /** 断线重连成功 */
  onReconnected: () => void
  /** 账号信息更新通知 {@link NEAccountInfo} */
  onAccountInfoUpdated: (accountInfo: NEAccountInfo) => void
}

export type NEContact = SearchAccountInfo

export type NEContactsInfoResponse = GetAccountInfoListResponse

export type NEMeetingCorpInfo = EnterPriseInfo & {
  ssoLoginUrl?: string
}

export default interface NEMeetingAccountService {
  /**
   * 尝试自动登录鉴权。成功时返回 {@link NEAccountInfo}
   */
  tryAutoLogin: () => Promise<NEResult<NEAccountInfo>>
  /**
   * 通过用户唯一ID和Token登录鉴权。成功时返回 {@link NEAccountInfo}。
   * @param userUuid 用户唯一ID
   * @param token 登录令牌
   */
  loginByToken: (
    userUuid: string,
    token: string
  ) => Promise<NEResult<NEAccountInfo>>
  /**
   * 通过用户唯一ID和密码登录鉴权。成功时返回 {@link NEAccountInfo}。
   * @param userUuid 用户唯一ID
   * @param password 登录密码
   */
  loginByPassword: (
    userUuid: string,
    password: string
  ) => Promise<NEResult<NEAccountInfo>>
  /**
   * 请求登录手机验证码。
   * @param phoneNumber 手机号
   */
  requestSmsCodeForLogin: (phoneNumber: string) => Promise<NEResult<void>>
  /**
   * 请求访客认证手机验证码
   * @param phoneNumber 手机号
   */
  requestSmsCodeForGuest: (phoneNumber: string) => Promise<NEResult<void>>
  /**
   * 通过手机验证码登录鉴权。成功时返回 {@link NEAccountInfo}。
   * @param mobile 手机号
   * @param code 手机验证码
   */
  loginBySmsCode: (
    mobile: string,
    smsCode: string
  ) => Promise<NEResult<NEAccountInfo>>
  /**
   * 生成SSO登录链接，调用方使用该链接通过浏览器去完成SSO登录。
   */
  generateSSOLoginWebURL: () => Promise<NEResult<string>>
  /**
   * 通过SSO登录结果uri完成会议组件登录鉴权。成功时返回 {@link NEAccountInfo}。
   * @param ssoUri SSO登录结果uri
   */
  loginBySSOUri: (ssoUri: string) => Promise<NEResult<NEAccountInfo>>
  /**
   * 通过邮箱密码登录鉴权。成功时返回 {@link NEAccountInfo}。
   *
   * @param email 登录邮箱
   * @param password 登录密码
   */
  loginByEmail: (
    email: string,
    password: string
  ) => Promise<NEResult<NEAccountInfo>>
  /**
   * 通过手机号密码登录鉴权。成功时返回 {@link NEAccountInfo}。
   * @param phoneNumber 登录手机号
   * @param password 登录密码
   */
  loginByPhoneNumber: (
    phoneNumber: string,
    password: string
  ) => Promise<NEResult<NEAccountInfo>>
  /**
   * 获取当前登录账号信息。成功时返回 {@link NEAccountInfo}。
   */
  getAccountInfo: () => NEAccountInfo | undefined
  /**
   * 注册登录状态监听器
   * @param listener 要添加的监听实例
   */
  addListener: (listener: NEAccountServiceListener) => void
  /**
   * 移除登录状态监听器
   * @param listener 要移除的监听实例
   */
  removeListener: (listener: NEAccountServiceListener) => void
  /**
   * 重置密码
   * @param userUuid 用户唯一ID
   * @param newPassword 新密码
   * @param oldPassword 旧密码
   */
  resetPassword: (
    userUuid: string,
    newPassword: string,
    oldPassword: string
  ) => Promise<NEResult<void>>
  /**
   * 修改当前登录账号头像
   * @param imageBlob 新头像图片内容
   */
  updateAvatar: (imageBlob: Blob) => Promise<NEResult<void>>
  /**
   * 修改当前登录账号昵称
   * @param nickname 新昵称
   */
  updateNickname: (nickname: string) => Promise<NEResult<void>>
  /**
   * 登出当前已登录的账号
   */
  logout: () => Promise<NEResult<void>>
}
