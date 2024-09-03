import { BrowserWindow, ipcMain } from 'electron'
import { NEResult } from 'neroom-types'
import NEMeetingAccountServiceInterface, {
  NEAccountInfo,
  NEAccountServiceListener,
} from 'nemeeting-core-sdk/dist/web/types/kit/interface/service/meeting_account_service'
import { BUNDLE_NAME } from '../meeting_kit'
import ElectronBaseService from './meeting_electron_base_service'

const MODULE_NAME = 'NEMeetingAccountService'

let seqCount = 0

class NEMeetingAccountService
  extends ElectronBaseService
  implements NEMeetingAccountServiceInterface
{
  // 该字段用来缓存用户信息，用户崩溃恢复
  accountInfo?: NEAccountInfo

  private _listeners: NEAccountServiceListener[] = []

  constructor(_win: BrowserWindow) {
    super(_win)
    this._addListening()
  }

  async tryAutoLogin(): Promise<NEResult<NEAccountInfo>> {
    const functionName = 'tryAutoLogin'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<NEAccountInfo>(seqId)
  }

  async loginByToken(
    userUuid: string,
    token: string
  ): Promise<NEResult<NEAccountInfo>> {
    const functionName = 'loginByToken'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [userUuid, token],
      seqId,
    })

    return this._IpcMainListener<NEAccountInfo>(seqId)
  }

  async loginByPassword(
    userUuid: string,
    password: string
  ): Promise<NEResult<NEAccountInfo>> {
    const functionName = 'loginByPassword'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [userUuid, password],
      seqId,
    })

    return this._IpcMainListener<NEAccountInfo>(seqId)
  }

  async requestSmsCodeForLogin(phoneNumber: string): Promise<NEResult<void>> {
    const functionName = 'requestSmsCodeForLogin'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [phoneNumber],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }

  async requestSmsCodeForGuest(phoneNumber: string): Promise<NEResult<void>> {
    const functionName = 'requestSmsCodeForGuest'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [phoneNumber],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }

  async loginBySmsCode(
    phoneNumber: string,
    smsCode: string
  ): Promise<NEResult<NEAccountInfo>> {
    const functionName = 'loginBySmsCode'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [phoneNumber, smsCode],
      seqId,
    })

    return this._IpcMainListener<NEAccountInfo>(seqId)
  }

  async generateSSOLoginWebURL(schemaUrl: string): Promise<NEResult<string>> {
    const functionName = 'generateSSOLoginWebURL'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [schemaUrl],
      seqId,
    })

    return this._IpcMainListener<string>(seqId)
  }

  async loginBySSOUri(ssoUri: string): Promise<NEResult<NEAccountInfo>> {
    const functionName = 'loginBySSOUri'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [ssoUri],
      seqId,
    })

    return this._IpcMainListener<NEAccountInfo>(seqId)
  }

  async loginByEmail(
    email: string,
    password: string
  ): Promise<NEResult<NEAccountInfo>> {
    const functionName = 'loginByEmail'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [email, password],
      seqId,
    })

    return this._IpcMainListener<NEAccountInfo>(seqId)
  }

  async loginByPhoneNumber(
    phoneNumber: string,
    password: string
  ): Promise<NEResult<NEAccountInfo>> {
    const functionName = 'loginByPhoneNumber'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [phoneNumber, password],
      seqId,
    })

    return this._IpcMainListener<NEAccountInfo>(seqId)
  }

  getAccountInfo(): Promise<NEResult<NEAccountInfo>> {
    const functionName = 'getAccountInfo'

    const seqId = this._generateSeqId(functionName)

    if (this._win.isDestroyed()) {
      throw new Error('getAccoutnInfo window is destroyed')
    }

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<NEAccountInfo>(seqId)
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
    const functionName = 'resetPassword'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [userUuid, newPassword, oldPassword],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }

  async updateAvatar(image: Blob | string): Promise<NEResult<void>> {
    const functionName = 'updateAvatar'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [image],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }

  async updateNickname(nickname: string): Promise<NEResult<void>> {
    const functionName = 'updateNickname'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [nickname],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }

  async logout(): Promise<NEResult<void>> {
    const functionName = 'logout'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }

  private _addListening(): void {
    const channel = `NEMeetingKitListener::${MODULE_NAME}`

    ipcMain.removeAllListeners(channel)
    ipcMain.removeHandler(channel)

    ipcMain.on(channel, (_, data) => {
      const { module, event, payload } = data

      if (module !== MODULE_NAME) {
        return
      }

      this._listeners.forEach((l) => {
        l[event]?.(...payload)
      })
    })
  }

  private _generateSeqId(functionName: string) {
    seqCount++
    return `${BUNDLE_NAME}::${MODULE_NAME}::${functionName}::${seqCount}`
  }

  private _IpcMainListener<T>(seqId: string): Promise<NEResult<T>> {
    return new Promise((resolve, reject) => {
      ipcMain.once(seqId, (_, res) => {
        if (res.error) {
          reject(res.error)
        } else {
          const result = res.result as NEResult<T>

          // 这里强制缓存一下用户信息，用户崩溃恢复
          const data = result.data as NEAccountInfo

          if (data && data.userUuid && data.userToken) {
            this.accountInfo = data
          }

          resolve(result)
        }
      })
    })
  }
}

export default NEMeetingAccountService
