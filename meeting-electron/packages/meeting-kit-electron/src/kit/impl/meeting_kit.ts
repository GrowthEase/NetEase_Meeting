import { BrowserWindow, ipcMain } from 'electron'
import { NEGlobalEventListener, SuccessBody } from 'neroom-types'
import { isWin32 } from '../../constant'
import {
  NEMeetingLanguage,
  NEResult,
  NEMeetingAppNoticeTips,
} from 'nemeeting-core-sdk/dist/web/types/types/type'
import NEMeetingKitInterface, {
  ExceptionHandler,
  NEMeetingKitConfig,
} from 'nemeeting-core-sdk/dist/web/types/kit/interface/meeting_kit'
import { NEMeetingCorpInfo } from 'nemeeting-core-sdk/dist/web/types/kit/interface/service/meeting_account_service'
import NEContactsService from './service/meeting_contacts_service'
import NEMeetingInviteService from './service/meeting_invite_service'
import NEMeetingService from './service/meeting_service'
import NEPreMeetingService from './service/pre_meeting_service'
import NESettingsService from './service/settings_service'
import NEMeetingAccountService from './service/meeting_account_service'
import NEMeetingMessageChannelService from './service/meeting_message_channel_service'

import {
  openMeetingWindow,
  closeMeetingWindow,
} from '../../mainMeetingWindow/index'
import NEFeedbackService from './service/feedback_service'
import NEGuestService from './service/guest_service'

export const BUNDLE_NAME = 'NEMeetingKit'

let seqCount = 0

export default class NEMeetingKit implements NEMeetingKitInterface {
  static _instance: NEMeetingKit | null = null

  private _win: BrowserWindow & {
    inMeeting: boolean
    isDomReady: boolean
    domReadyCallback: () => void
    initMainWindowSize: () => void
  }
  private _meetingService: NEMeetingService | undefined
  private _meetingInviteService: NEMeetingInviteService | undefined
  private _accountService: NEMeetingAccountService | undefined
  private _settingsService: NESettingsService | undefined
  private _preMeetingService: NEPreMeetingService | undefined
  private _contactsService: NEContactsService | undefined
  private _feedbackService: NEFeedbackService | undefined
  private _guestService: NEGuestService | undefined
  private _meetingMessageChannelService:
    | NEMeetingMessageChannelService
    | undefined
  private _globalEventListeners: NEGlobalEventListener | undefined
  private _exceptionHandlers: ExceptionHandler[] = []
  private _isInitialized: boolean = false
  private _initConfig: NEMeetingKitConfig | undefined

  static getInstance(): NEMeetingKit {
    if (!NEMeetingKit._instance) {
      NEMeetingKit._instance = new NEMeetingKit()
    }

    return NEMeetingKit._instance
  }

  constructor() {
    this._win = openMeetingWindow()
  }

  get isInitialized(): boolean {
    return this._isInitialized
  }

  async initialize(
    config: NEMeetingKitConfig
  ): Promise<NEResult<NEMeetingCorpInfo | undefined>> {
    return await this._initialize(config)
  }

  unInitialize(): Promise<NEResult<void>> {
    const functionName = 'unInitialize'

    const seqId = this._generateSeqId(functionName)

    this._isInitialized = false
    this._win.webContents.send(BUNDLE_NAME, {
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<void>(seqId).then(() => {
      closeMeetingWindow()
      this._win = openMeetingWindow()
      return SuccessBody(void 0)
    })
  }

  switchLanguage(language: NEMeetingLanguage): Promise<NEResult<void>> {
    const functionName = 'switchLanguage'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      method: functionName,
      args: [language],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  getMeetingService(): NEMeetingService | undefined {
    return this._meetingService
  }
  getMeetingInviteService(): NEMeetingInviteService | undefined {
    return this._meetingInviteService
  }
  getAccountService(): NEMeetingAccountService | undefined {
    return this._accountService
  }
  getSettingsService(): NESettingsService | undefined {
    return this._settingsService
  }
  getPreMeetingService(): NEPreMeetingService | undefined {
    return this._preMeetingService
  }
  getFeedbackService(): NEFeedbackService | undefined {
    return this._feedbackService
  }
  getMeetingMessageChannelService():
    | NEMeetingMessageChannelService
    | undefined {
    return this._meetingMessageChannelService
  }
  getContactsService(): NEContactsService | undefined {
    return this._contactsService
  }
  getGuestService(): NEGuestService | undefined {
    return this._guestService
  }
  addGlobalEventListener(listener: NEGlobalEventListener): void {
    this._globalEventListeners = this._globalEventListeners
      ? { ...this._globalEventListeners, ...listener }
      : listener
  }
  removeGlobalEventListener(listener: NEGlobalEventListener): void {
    if (listener) {
      const keys = Object.keys(listener)

      keys.forEach((key) => {
        this._globalEventListeners && delete this._globalEventListeners[key]
      })
    } else {
      this._globalEventListeners = undefined
    }
  }
  getSDKLogPath(): Promise<NEResult<string>> {
    const functionName = 'getSDKLogPath'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<string>(seqId)
  }
  getAppNoticeTips(): Promise<NEResult<NEMeetingAppNoticeTips>> {
    const functionName = 'getAppNoticeTips'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<NEMeetingAppNoticeTips>(seqId)
  }

  setExceptionHandler(handler: ExceptionHandler): void {
    this._exceptionHandlers.push(handler)
  }

  startMarvel(): Promise<NEResult<void>> {
    const functionName = 'startMarvel'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }

  private async _initialize(
    config: NEMeetingKitConfig,
    recover: boolean = false
  ): Promise<NEResult<NEMeetingCorpInfo | undefined>> {
    const _fn = () => {
      const functionName = 'initialize'

      const seqId = this._generateSeqId(functionName)

      if (!this._win?.isDestroyed()) {
        this._win.webContents.send(BUNDLE_NAME, {
          method: functionName,
          args: [config],
          seqId,
        })
      }

      return this._IpcMainListener<NEMeetingCorpInfo | undefined>(seqId).then(
        (res) => {
          if (recover) {
            this._meetingService?.setWin(this._win)
            this._meetingInviteService?.setWin(this._win)
            this._accountService?.setWin(this._win)
            this._settingsService?.setWin(this._win)
            this._preMeetingService?.setWin(this._win)
            this._contactsService?.setWin(this._win)
            this._meetingMessageChannelService?.setWin(this._win)
            this._feedbackService?.setWin(this._win)
            this._guestService?.setWin(this._win)
          } else {
            this._isInitialized = true
            this._initConfig = config

            this._meetingService = new NEMeetingService(this._win)
            this._meetingInviteService = new NEMeetingInviteService(this._win)
            this._accountService = new NEMeetingAccountService(this._win)
            this._settingsService = new NESettingsService(this._win)
            this._preMeetingService = new NEPreMeetingService(this._win)
            this._contactsService = new NEContactsService(this._win)
            this._meetingMessageChannelService =
              new NEMeetingMessageChannelService(this._win)
            this._feedbackService = new NEFeedbackService(this._win)
            this._guestService = new NEGuestService(this._win)

            this._onMeetingEnd()
          }

          this._daemonProcess()

          return res
        }
      )
    }

    if (this._win.isDomReady) {
      return _fn()
    } else {
      return new Promise((resolve) => {
        this._win.domReadyCallback = () => {
          resolve(_fn())
        }
      })
    }
  }

  private _onMeetingEnd() {
    if (this._meetingService) {
      this._meetingService.addMeetingStatusListener({
        onMeetingStatusChanged: async ({ status }) => {
          if (status === 6 || status === -1) {
            // 先直接隐藏
            this._win.initMainWindowSize()
            this._win.inMeeting = false
            if (isWin32) {
              this._win.hide()
            } else {
              // mac 需要判断是否全屏
              if (this._win.isFullScreen()) {
                this._win.on('leave-full-screen', () => {
                  if (!this._win.inMeeting) {
                    this._win.hide()
                  }
                })
              } else {
                this._win.hide()
              }
            }
          }
        },
      })
    }
  }

  private _daemonProcess() {
    this._win?.webContents.on('crashed', async () => {
      await this._recover()

      this._exceptionHandlers.forEach((handler) => {
        handler.onError(0)
      })
    })
  }

  private async _recover() {
    // 先销毁原先的进程
    if (this._accountService) {
      closeMeetingWindow()
      this._win = openMeetingWindow()
      if (this._initConfig) {
        await this._initialize(this._initConfig, true)
      }

      const accountInfo = this._accountService.accountInfo

      if (accountInfo) {
        await this._accountService.loginByToken(
          accountInfo.userUuid,
          accountInfo.userToken
        )
      }
    }
  }

  private _generateSeqId(functionName: string) {
    seqCount++
    return `${BUNDLE_NAME}::${functionName}::${seqCount}`
  }

  private _IpcMainListener<T>(seqId: string): Promise<NEResult<T>> {
    return new Promise((resolve, reject) => {
      ipcMain.once(seqId, (_, res) => {
        if (res.error) {
          reject(res.error)
        } else {
          resolve(res.result)
        }
      })
    })
  }
}
