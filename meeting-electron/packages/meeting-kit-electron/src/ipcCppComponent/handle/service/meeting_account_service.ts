import { FailureBodySync } from 'neroom-types'
import NEMeetingAccountService from '../../../kit/impl/service/meeting_account_service'
import { InvokeCallback } from '../meeting_kit'

export default class NEMeetingAccountServiceHandle {
  private _accountService: NEMeetingAccountService
  private _listenerInvokeCallback: InvokeCallback

  constructor(
    meetingAccountService: NEMeetingAccountService,
    listenerInvokeCallback: InvokeCallback
  ) {
    this._accountService = meetingAccountService
    this._listenerInvokeCallback = listenerInvokeCallback

    this._accountService.addListener({
      onKickOut: () => {
        this._listenerInvokeCallback(1, 101, '{}', 0)
      },
      onAuthInfoExpired: () => {
        this._listenerInvokeCallback(1, 102, '{}', 0)
      },
      onReconnected: () => {
        this._listenerInvokeCallback(1, 103, '{}', 0)
      },
      onAccountInfoUpdated: (accountInfo) => {
        this._listenerInvokeCallback(
          1,
          104,
          JSON.stringify({
            accountInfo,
          }),
          0
        )
      },
    })
  }

  async onMethodHandle(cid: number, data: string): Promise<string> {
    let res

    switch (cid) {
      case 1:
        res = await this.tryAutoLogin()
        break
      case 3:
        res = await this.loginByToken(data)
        break
      case 5:
        res = await this.loginByPassword(data)
        break
      case 7:
        res = await this.requestSmsCodeForLogin(data)
        break
      case 9:
        res = await this.requestSmsCodeForGuest(data)
        break
      case 11:
        res = await this.loginBySmsCode(data)
        break
      case 13:
        res = await this.generateSSOLoginWebURL(data)
        break
      case 15:
        res = await this.loginBySSOUri(data)
        break
      case 17:
        res = await this.loginByEmail(data)
        break
      case 19:
        res = await this.loginByPhoneNumber(data)
        break
      case 21:
        res = await this.getAccountInfo()
        break
      case 27:
        res = await this.resetPassword(data)
        break
      case 29:
        res = await this.updateAvatar(data)
        break
      case 31:
        res = await this.updateNickname(data)
        break
      case 33:
        res = await this.logout()
        break
      default:
        return JSON.stringify(FailureBodySync(undefined, 'method not found'))
    }

    return JSON.stringify(res)
  }

  async tryAutoLogin() {
    return await this._accountService.tryAutoLogin()
  }

  async loginByToken(data: string) {
    const { userUuid, token } = JSON.parse(data)

    return await this._accountService.loginByToken(userUuid, token)
  }

  async loginByPassword(data: string) {
    const { userUuid, password } = JSON.parse(data)

    return await this._accountService.loginByPassword(userUuid, password)
  }

  async requestSmsCodeForLogin(data: string) {
    const { phoneNumber } = JSON.parse(data)

    return await this._accountService.requestSmsCodeForLogin(phoneNumber)
  }

  async requestSmsCodeForGuest(data: string) {
    const { phoneNumber } = JSON.parse(data)

    return await this._accountService.requestSmsCodeForGuest(phoneNumber)
  }

  async loginBySmsCode(data: string) {
    const { phoneNumber, smsCode } = JSON.parse(data)

    return await this._accountService.loginBySmsCode(phoneNumber, smsCode)
  }

  async generateSSOLoginWebURL(data) {
    const { schemaUrl } = JSON.parse(data)

    return await this._accountService.generateSSOLoginWebURL(schemaUrl)
  }

  async loginBySSOUri(data: string) {
    const { ssoUri } = JSON.parse(data)

    return await this._accountService.loginBySSOUri(ssoUri)
  }

  async loginByEmail(data: string) {
    const { email, password } = JSON.parse(data)

    return await this._accountService.loginByEmail(email, password)
  }

  async loginByPhoneNumber(data: string) {
    const { phoneNumber, password } = JSON.parse(data)

    return await this._accountService.loginByPhoneNumber(phoneNumber, password)
  }

  async getAccountInfo() {
    return await this._accountService.getAccountInfo()
  }

  async resetPassword(data: string) {
    const { userUuid, newPassword, oldPassword } = JSON.parse(data)

    return await this._accountService.resetPassword(
      userUuid,
      newPassword,
      oldPassword
    )
  }

  async updateAvatar(data: string) {
    const { imagePath } = JSON.parse(data)

    return await this._accountService.updateAvatar(imagePath)
  }

  async updateNickname(data: string) {
    const { nickname } = JSON.parse(data)

    return await this._accountService.updateNickname(nickname)
  }

  async logout() {
    return await this._accountService.logout()
  }
}
