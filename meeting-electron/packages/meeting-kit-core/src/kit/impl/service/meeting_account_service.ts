import { z, ZodError } from 'zod'
import {
  FailureBody,
  FailureBodySync,
  NEAuthEvent,
  NEResult,
  SuccessBody,
} from 'neroom-types'
import NEMeetingService from '../../../services/NEMeeting'
import NEMeetingAccountServiceInterface, {
  NEAccountInfo,
  NEAccountServiceListener,
  NEMeetingCorpInfo,
} from '../../interface/service/meeting_account_service'
import { EventType } from '../../../types'
import { getLocalStorageSetting } from '../../../utils'
import { ACCOUNT_INFO_KEY } from '../../../config'

const MODULE_NAME = 'NEMeetingAccountService'
const LISTENER_CHANNEL = `NEMeetingKitListener::${MODULE_NAME}`

class NEMeetingAccountService implements NEMeetingAccountServiceInterface {
  private _meetingKit: NEMeetingService
  private _accountInfo?: NEAccountInfo
  private _listeners: NEAccountServiceListener[] = []
  private _idpList: NEMeetingCorpInfo['idpList'] = []
  // 登录成功记录次数，用于判断是否是重连还是第一次登录
  private _loginCount = 0

  constructor(
    meetingKit: NEMeetingService,
    idpList: NEMeetingCorpInfo['idpList']
  ) {
    this._meetingKit = meetingKit
    this._idpList = idpList
    this._addListening()
  }

  async tryAutoLogin(): Promise<NEResult<NEAccountInfo>> {
    const accountInfoStr = localStorage.getItem(ACCOUNT_INFO_KEY)

    if (accountInfoStr) {
      const accountInfo: NEAccountInfo = JSON.parse(accountInfoStr)

      return await this.loginByToken(
        accountInfo.userUuid,
        accountInfo.userToken
      )
    }

    throw FailureBody(undefined, 'no account info')
  }

  async loginByToken(
    userUuid: string,
    token: string
  ): Promise<NEResult<NEAccountInfo>> {
    try {
      const userUuidSchema = z.string()
      const tokenSchema = z.string()

      userUuidSchema.parse(userUuid, {
        path: ['userUuid'],
      })

      tokenSchema.parse(token, {
        path: ['token'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const res = await this._meetingKit.login({
      accountId: userUuid,
      accountToken: token,
      loginType: 1,
    })

    return SuccessBody(this._formatAccountInfo(res))
  }

  async loginByPassword(
    userUuid: string,
    password: string
  ): Promise<NEResult<NEAccountInfo>> {
    try {
      const userUuidSchema = z.string()
      const passwordSchema = z.string()

      userUuidSchema.parse(userUuid, {
        path: ['userUuid'],
      })

      passwordSchema.parse(password, {
        path: ['password'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const res = await this._meetingKit.login({
      username: userUuid,
      password: password,
      loginType: 2,
    })

    return SuccessBody(this._formatAccountInfo(res))
  }

  async requestSmsCodeForLogin(phoneNumber: string): Promise<NEResult<void>> {
    try {
      const phoneNumberSchema = z.string()

      phoneNumberSchema.parse(phoneNumber, {
        path: ['phoneNumber'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    await this._meetingKit.sendVerifyCodeApi({
      mobile: phoneNumber,
      scene: 1,
    })

    return SuccessBody(void 0)
  }

  async requestSmsCodeForGuest(phoneNumber: string): Promise<NEResult<void>> {
    try {
      const phoneNumberSchema = z.string()

      phoneNumberSchema.parse(phoneNumber, {
        path: ['phoneNumber'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    await this._meetingKit.sendVerifyCodeApi({
      mobile: phoneNumber,
      scene: 3,
    })

    return SuccessBody(void 0)
  }

  async loginBySmsCode(
    phoneNumber: string,
    smsCode: string
  ): Promise<NEResult<NEAccountInfo>> {
    try {
      const phoneNumberSchema = z.string()
      const smsCodeSchema = z.string()

      phoneNumberSchema.parse(phoneNumber, {
        path: ['phoneNumber'],
      })

      smsCodeSchema.parse(smsCode, {
        path: ['smsCode'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const res = await this._meetingKit.loginApi({
      mobile: phoneNumber,
      verifyCode: smsCode,
    })

    return await this.loginByToken(res.userUuid, res.userToken)
  }

  async generateSSOLoginWebURL(schemaUrl: string): Promise<NEResult<string>> {
    const ipdInfo = this._idpList.find((item) => {
      return item.type === 1
    })

    if (!ipdInfo) {
      throw FailureBodySync(undefined, 'no idp info, not support sso login')
    }

    const baseUrl = this._meetingKit.generateSSOLoginWebURL(
      schemaUrl,
      ipdInfo.id
    )

    return SuccessBody(baseUrl)
  }

  async loginBySSOUri(ssoUri: string): Promise<NEResult<NEAccountInfo>> {
    try {
      const ssoUriSchema = z.string().url()

      ssoUriSchema.parse(ssoUri, {
        path: ['ssoUri'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const urlObj = new URL(ssoUri)
    const searchParams = new URLSearchParams(urlObj.search)
    const param = searchParams.get('param')

    if (param) {
      const res = await this._meetingKit.loginBySSOUri(param)

      return await this.loginByToken(res.userUuid, res.userToken)
    }

    throw FailureBody(undefined, 'no account info')
  }

  async loginByEmail(
    email: string,
    password: string
  ): Promise<NEResult<NEAccountInfo>> {
    try {
      const emailSchema = z.string().email()
      const passwordSchema = z.string()

      emailSchema.parse(email, {
        path: ['email'],
      })
      passwordSchema.parse(password, {
        path: ['password'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const res = await this._meetingKit.loginApiNew({
      email: email,
      password: password,
    })

    return await this.loginByToken(res.userUuid, res.userToken)
  }

  async loginByPhoneNumber(
    phoneNumber: string,
    password: string
  ): Promise<NEResult<NEAccountInfo>> {
    try {
      const phoneNumberSchema = z.string()
      const passwordSchema = z.string()

      phoneNumberSchema.parse(phoneNumber, {
        path: ['phoneNumber'],
      })
      passwordSchema.parse(password, {
        path: ['password'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const res = await this._meetingKit.loginApiNew({
      phone: phoneNumber,
      password: password,
    })

    return await this.loginByToken(res.userUuid, res.userToken)
  }

  async getAccountInfo(): Promise<NEResult<NEAccountInfo>> {
    if (this._accountInfo) {
      return SuccessBody(this._accountInfo)
    }

    throw FailureBodySync(undefined, 'no account info')
  }

  addListener(listener: NEAccountServiceListener): void {
    this._listeners.push(listener)
  }

  removeListener(listener: NEAccountServiceListener): void {
    this._listeners = this._listeners.filter((l) => l !== listener)
  }

  async resetPassword(
    userUuid: string,
    newPassword: string,
    oldPassword: string
  ): Promise<NEResult<void>> {
    try {
      const userUuidSchema = z.string()
      const newPasswordSchema = z.string()
      const oldPasswordSchema = z.string()

      userUuidSchema.parse(userUuid, {
        path: ['userUuid'],
      })
      newPasswordSchema.parse(newPassword, {
        path: ['newPassword'],
      })
      oldPasswordSchema.parse(oldPassword, {
        path: ['oldPassword'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    await this._meetingKit.resetPassword({
      userUuid,
      newPassword,
      oldPassword,
    })

    return SuccessBody(void 0)
  }

  async updateAvatar(image: Blob | string): Promise<NEResult<void>> {
    try {
      const imageSchema = z.union([z.instanceof(Blob), z.string()])

      imageSchema.parse(image, {
        path: ['image'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    await this._meetingKit.updateAccountAvatar(image)

    return SuccessBody(void 0)
  }

  async updateNickname(nickname: string): Promise<NEResult<void>> {
    try {
      const nicknameSchema = z.string()

      nicknameSchema.parse(nickname, {
        path: ['nickname'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    await this._meetingKit.updateUserNickname(nickname)

    return SuccessBody(void 0)
  }

  async logout(): Promise<NEResult<void>> {
    await this._meetingKit.logout()
    this._loginCount = 0
    this._accountInfo = undefined
    localStorage.removeItem(ACCOUNT_INFO_KEY)
    return SuccessBody(void 0)
  }

  async loginByDynamicToken(
    userUuid: string,
    token: string,
    authType: string
  ): Promise<NEResult<void>> {
    try {
      const userUuidSchema = z.string()
      const tokenSchema = z.string()
      const authTypeSchema = z.string()

      userUuidSchema.parse(userUuid, {
        path: ['userUuid'],
      })

      tokenSchema.parse(token, {
        path: ['token'],
      })

      authTypeSchema.parse(authType, {
        path: ['authType'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    await this._meetingKit.login({
      accountId: userUuid,
      accountToken: token,
      loginType: 1,
      isTemporary: true,
      authType,
    })

    return SuccessBody(void 0)
  }
  private _addListening(): void {
    this._meetingKit.eventEmitter.on(
      EventType.ReceiveAccountInfoUpdate,
      async (res) => {
        if (this._accountInfo) {
          if (res.reason === 'CHANGE_AVATAR') {
            this._accountInfo.avatar = res.meetingAccountInfo.avatar
          } else {
            this._accountInfo.nickname = res.meetingAccountInfo.nickname
          }

          this._listeners.forEach((l) => {
            this._accountInfo && l?.onAccountInfoUpdated?.(this._accountInfo)
          })

          window.ipcRenderer?.send(LISTENER_CHANNEL, {
            module: 'NEMeetingAccountService',
            event: 'onAccountInfoUpdated',
            payload: [this._accountInfo],
          })
        }
      }
    )

    this._meetingKit.outEventEmitter.on(
      EventType.AuthEvent,
      (evt: NEAuthEvent) => {
        if (evt === NEAuthEvent.KICK_OUT) {
          this._listeners.forEach((l) => {
            l?.onKickOut?.()
          })

          window.ipcRenderer?.send(LISTENER_CHANNEL, {
            module: 'NEMeetingAccountService',
            event: 'onKickOut',
            payload: [],
          })
        } else if (evt === NEAuthEvent.TOKEN_EXPIRED) {
          this._listeners.forEach((l) => {
            l.onAuthInfoExpired?.()
          })

          window.ipcRenderer?.send(LISTENER_CHANNEL, {
            module: 'NEMeetingAccountService',
            event: 'onAuthInfoExpired',
            payload: [],
          })
        } else if (evt === NEAuthEvent.LOGGED_IN) {
          this._loginCount++

          if (this._loginCount > 1) {
            this._listeners.forEach((l) => {
              l.onReconnected?.()
            })

            window.ipcRenderer?.send(LISTENER_CHANNEL, {
              module: 'NEMeetingAccountService',
              event: 'onReconnected',
              payload: [],
            })
          }
        }
      }
    )
  }

  private _formatAccountInfo(accountInfo: NEAccountInfo): NEAccountInfo {
    const initData = {
      copyName: '',
      userUuid: '',
      userToken: '',
      nickname: '',
      avatar: '',
      phoneNumber: '',
      email: '',
      privateMeetingNum: '',
      privateShortMeetingNum: '',
      isInitialPassword: false,
      serviceBundle: {
        name: '',
        maxMinutes: 0,
        maxMembers: 0,
        expireTimestamp: -1,
        expireTip: '',
      },
      isAnonymous: false,
    }

    let serviceBundle = accountInfo.serviceBundle

    if (serviceBundle) {
      serviceBundle = {
        ...initData.serviceBundle,
        ...serviceBundle,
        maxMembers: serviceBundle.meetingMaxMembers,
        maxMinutes: serviceBundle.meetingMaxMinutes,
      }
    }

    this._accountInfo = {
      ...initData,
      ...accountInfo,
      serviceBundle,
      privateShortMeetingNum: accountInfo.shortMeetingNum,
    }

    localStorage.setItem(ACCOUNT_INFO_KEY, JSON.stringify(this._accountInfo))

    // 如果不存在设置需要添加默认设置
    getLocalStorageSetting()

    return this._accountInfo
  }
}

export default NEMeetingAccountService
