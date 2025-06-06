import { z, ZodError } from 'zod'
import {
  NEGlobalEventListener,
  SuccessBody,
  FailureBody,
  FailureBodySync,
} from 'neroom-types'
import {
  NEResult,
  NEMeetingAppNoticeTips,
  NEMeetingInitConfig,
} from '../../types/type'
import NEMeetingKitInterface, {
  ExceptionHandler,
  NEMeetingKitConfig,
  NEMeetingLanguage,
} from '../interface/meeting_kit'
import { NEMeetingCorpInfo } from '../interface/service/meeting_account_service'
import NEContactsService from './service/meeting_contacts_service'
import NEMeetingInviteService from './service/meeting_invite_service'
import NEMeetingService from './service/meeting_service'
import NEPreMeetingService from './service/pre_meeting_service'
import NESettingsService from './service/settings_service'
import NEMeetingAccountService from './service/meeting_account_service'
import { Logger } from '../../utils/Logger'
import MeetingKit from '../../index'
import NEMeetingMessageChannelService from './service/meeting_message_channel_service'
import { getEnterPriseInfoApi } from '../../app/src/api'
import { IM } from '../../types/NEMeetingKit'
import NEFeedbackService from './service/feedback_service'
import NEGuestService from './service/guest_service'
import pkg from '../../../package.json'

export default class NEMeetingKit implements NEMeetingKitInterface {
  private _appKey: string = ''
  private _logger: Logger | undefined
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
  private _idpList: NEMeetingCorpInfo['idpList'] = []
  private _isInitialized: boolean = false

  // 兼容老版本sdk，需暴露
  static oldNEMeetingKit = MeetingKit

  static _instance: NEMeetingKit | null = null

  static getInstance(): NEMeetingKit {
    if (!NEMeetingKit._instance) {
      NEMeetingKit._instance = new NEMeetingKit()
    }

    return NEMeetingKit._instance
  }
  static checkSystemRequirements(): boolean | undefined {
    return MeetingKit.actions.checkSystemRequirements()
  }

  constructor() {
    this._electronMethodCallListener()
  }

  get isInitialized(): boolean {
    return this._isInitialized
  }

  reuseIM(im: IM) {
    return MeetingKit.actions.reuseIM(im)
  }
  async initialize(
    config: NEMeetingKitConfig
  ): Promise<NEResult<NEMeetingCorpInfo | undefined>> {
    console.log('initialize', config)
    try {
      if (config.appKey) {
        this._appKey = config.appKey

        const configSchema = z.object({
          appKey: z.string(),
          serverUrl: z.string(),
          appName: z.string().optional(),
          useAssetServerConfig: z.boolean().optional(),
          extras: z.record(z.unknown()).optional(),
          language: z.nativeEnum(NEMeetingLanguage).optional(),
        })

        configSchema.parse(config, {
          path: ['config'],
        })
      } else {
        if (!config.corpCode && !config.corpEmail) {
          throw FailureBody(undefined, 'no appKey or corpCode or corpEmail')
        }
      }
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    this._isInitialized = true

    const { width, height } = config
    const _config: NEMeetingInitConfig = {
      appKey: config.appKey,
      locale: config.language,
      meetingServerDomain: config.serverUrl,
      imPrivateConf: config.serverConfig?.imServerConfig,
      neRtcServerAddresses: config.serverConfig?.rtcServerConfig,
      whiteboardConfig: config.serverConfig?.whiteboardServerConfig,
      im: config.im,
      serverUrl: config.serverUrl,
      extras: config.extras,
      useAssetServerConfig: config.useAssetServerConfig,
      whiteboardAppConfig: config.whiteboardAppConfig,
    }

    return new Promise((resolve, reject) => {
      // 如果传了企业代码或者企业邮箱
      if (!config.appKey && (config.corpCode || config.corpEmail)) {
        getEnterPriseInfoApi(
          {
            code: config.corpCode,
            email: config.corpEmail,
          },
          config.serverUrl
        )
          .then((enterPriseInfo) => {
            _config.appKey = enterPriseInfo.appKey
            this._appKey = enterPriseInfo.appKey

            MeetingKit.actions.init(width, height, _config, (e) => {
              const res = {
                appKey: enterPriseInfo.appKey,
                corpName: enterPriseInfo.appName || '',
                corpCode: config.corpCode || '',
                ssoLevel: enterPriseInfo.ssoLevel,
                idpList:
                  enterPriseInfo.idpList.map((item) => {
                    if (!item.name) {
                      item.name = ''
                    }

                    return item
                  }) || [],
              }

              this._idpList = res.idpList
              this._initHandler()

              if (e) {
                reject(e)
              } else {
                resolve(SuccessBody(res))
              }
            })
          })
          .catch((error) => {
            reject(error)
          })
      } else {
        MeetingKit.actions.init(width, height, _config, (e) => {
          this._initHandler()

          if (e) {
            reject(e)
          } else {
            resolve(SuccessBody(void 0))
          }
        })
      }
    })
  }

  async unInitialize(): Promise<NEResult<void>> {
    console.warn('unInitialize')
    await MeetingKit.actions.destroy()
    this._isInitialized = false
    return Promise.resolve(SuccessBody(void 0))
  }

  async switchLanguage(language: NEMeetingLanguage): Promise<NEResult<void>> {
    try {
      const languageSchema = z.nativeEnum(NEMeetingLanguage)

      languageSchema.parse(language, {
        path: ['language'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    MeetingKit.actions.switchLanguage(language)

    return SuccessBody(void 0)
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
  getMeetingMessageChannelService():
    | NEMeetingMessageChannelService
    | undefined {
    return this._meetingMessageChannelService
  }
  getContactsService(): NEContactsService | undefined {
    return this._contactsService
  }
  getFeedbackService(): NEFeedbackService | undefined {
    return this._feedbackService
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
  setExceptionHandler(handler: ExceptionHandler): void {
    this._exceptionHandlers.push(handler)
  }
  async getSDKLogPath(): Promise<NEResult<string>> {
    return SuccessBody(MeetingKit.actions.neMeeting?.sdkLogPath || '')
  }
  async getAppNoticeTips(): Promise<NEResult<NEMeetingAppNoticeTips>> {
    if (!MeetingKit.actions.neMeeting) {
      throw FailureBodySync(undefined, 'MeetingKit not initialized')
    }

    return MeetingKit.actions.neMeeting.getAppTips().then((res) => {
      return SuccessBody(res)
    })
  }

  async startMarvel(): Promise<NEResult<void>> {
    const marvelConfig = {
      marvelId: window.isWins32
        ? '413fca4c42914546a2df535f997676c6'
        : '151074864cd441e1847cc0e2892cc04b',
      sdkName: 'meeting-kit',
      sdkVersion: pkg.version,
      userId: '',
      deviceIdentifier: '',
      appKey: this._appKey,
    }

    // window.startMarvel?.(marvelConfig)

    window.ipcRenderer?.send('startMarvel', marvelConfig)

    return SuccessBody(void 0)
  }

  destroy(): void {
    MeetingKit.actions.destroy()
  }

  private _initHandler() {
    const logger = new Logger('Meeting-NeMeeting', true)

    const neMeeting = MeetingKit.actions.neMeeting

    if (neMeeting) {
      this._accountService = new NEMeetingAccountService(
        neMeeting,
        this._idpList
      )
      this._contactsService = new NEContactsService({
        neMeeting,
        logger,
      })
      this._meetingInviteService = new NEMeetingInviteService({
        neMeeting,
        eventEmitter: neMeeting.outEventEmitter,
      })
      this._meetingMessageChannelService = new NEMeetingMessageChannelService({
        neMeeting,
        logger,
      })
      this._meetingService = new NEMeetingService({
        neMeeting,
        meetingKit: MeetingKit.actions,
      })
      this._preMeetingService = new NEPreMeetingService(neMeeting)
      this._settingsService = new NESettingsService({
        logger,
        neMeeting,
      })
      this._feedbackService = new NEFeedbackService({
        neMeeting,
      })
      this._guestService = new NEGuestService({
        neMeeting,
        meetingKit: this,
      })
    }
  }

  private _electronMethodCallListener() {
    window.ipcRenderer?.on('NEMeetingKit', (_, data) => {
      const { module, method, args, seqId } = data

      const serviceMap = {
        NEMeetingAccountService: this._accountService,
        NEMeetingService: this._meetingService,
        NEMeetingInviteService: this._meetingInviteService,
        NESettingsService: this._settingsService,
        NEPreMeetingService: this._preMeetingService,
        NEContactsService: this._contactsService,
        NEMeetingMessageChannelService: this._meetingMessageChannelService,
        NEFeedbackService: this._feedbackService,
        NEGuestService: this._guestService,
      }

      const service = module ? serviceMap[module] : this

      if (service) {
        const result = service[method](...args)

        if (result && typeof result.then === 'function' && seqId) {
          result
            .then((res) => {
              this._logger?.debug(module, method, args, res)

              window.ipcRenderer?.send(seqId, {
                result: res,
              })
            })
            .catch((error) => {
              this._logger?.warn(module, method, args, error)
              try {
                window.ipcRenderer?.send(seqId, {
                  error,
                })
              } catch (error) {
                //
              }
            })
        }
      }
    })
  }
}
