import { FailureBodySync } from 'neroom-types'
import NEMeetingKit from '../../kit/impl/meeting_kit'
import NEMeetingAccountServiceHandle from './service/meeting_account_service'
import NEMeetingServiceHandle from './service/meeting_service'
import NEContactsServiceHandle from './service/meeting_contacts_service'
import NEMeetingMessageChannelServiceHandle from './service/meeting_message_channel_service'
import NEMeetingInviteServiceHandle from './service/meeting_invite_service'
import NESettingsServiceHandle from './service/settings_service'
import NEPreMeetingServiceHandle from './service/pre_meeting_service'
import NEFeedbackServiceHandle from './service/feedback_service'

export type InvokeCallback = (
  sid: number,
  cid: number,
  data: string,
  sn: number
) => void

export default class NEMeetingKitHandle {
  private _meetingKit: NEMeetingKit

  private _listenerInvokeCallback: InvokeCallback

  private _sidMap = new Map<
    number,
    | NEMeetingKitHandle
    | NEMeetingAccountServiceHandle
    | NEMeetingServiceHandle
    | NEContactsServiceHandle
    | NEMeetingMessageChannelServiceHandle
    | NEMeetingInviteServiceHandle
    | NESettingsServiceHandle
    | NEPreMeetingServiceHandle
    | NEFeedbackServiceHandle
  >()

  constructor(listenerInvokeCallback: InvokeCallback) {
    this._listenerInvokeCallback = listenerInvokeCallback
    this._meetingKit = NEMeetingKit.getInstance()
    this._sidMap.set(0, this)
  }

  async onIPCMessageReceived(
    sid: number,
    cid: number,
    data: string
  ): Promise<string> {
    console.log('onIPCMessageReceived')
    console.log('sid:', sid)
    console.log('cid:', cid)
    console.log('data:')
    console.log(data)

    const service = this._sidMap.get(sid)

    if (service) {
      try {
        return await service.onMethodHandle(cid, data)
      } catch (error) {
        console.error('onMethodHandle error', error)
        if (typeof error === 'string') {
          return JSON.stringify(FailureBodySync(undefined, error))
        } else {
          const failureError = error as { code: number; message: string }

          return JSON.stringify(
            FailureBodySync(undefined, failureError.message, failureError.code)
          )
        }
      }
    } else {
      return JSON.stringify(FailureBodySync(undefined, 'service not found'))
    }
  }

  async onMethodHandle(cid: number, data: string): Promise<string> {
    try {
      let res

      switch (cid) {
        case 1:
          res = await this.initialize(data)
          break
        case 3:
          res = await this.unInitialize()
          break
        case 9:
          res = await this.switchLanguage(data)
          break
        case 11:
          res = await this.getLogPath()
          break
        case 13:
          res = await this.getAppNoticeTips()
          break
        default:
          return JSON.stringify(FailureBodySync(undefined, 'method not found'))
      }

      return JSON.stringify(res)
    } catch (error) {
      console.error('onMethodHandle error', error)

      const failureError = error as { code: number; message: string }

      if (failureError.message) {
        return JSON.stringify(FailureBodySync(undefined, failureError.message))
      }

      if (error instanceof FailureBodySync) {
        return JSON.stringify(error)
      } else {
        let errorMsg = 'error'

        if (typeof error === 'string') {
          errorMsg = error
        }
        // 未知错误

        return JSON.stringify(FailureBodySync(undefined, errorMsg))
      }
    }
  }

  async initialize(data: string) {
    const config = JSON.parse(data)

    console.log('initialize config:', config)

    const res = await this._meetingKit.initialize(config)

    if (res.code === 0) {
      const accountService = this._meetingKit.getAccountService()

      if (accountService) {
        this._sidMap.set(
          1,
          new NEMeetingAccountServiceHandle(
            accountService,
            this._listenerInvokeCallback
          )
        )
      }

      const meetingService = this._meetingKit.getMeetingService()

      if (meetingService) {
        this._sidMap.set(
          2,
          new NEMeetingServiceHandle(
            meetingService,
            this._listenerInvokeCallback
          )
        )
      }

      const settingsService = this._meetingKit.getSettingsService()

      if (settingsService) {
        this._sidMap.set(3, new NESettingsServiceHandle(settingsService))
      }

      const preMeetingService = this._meetingKit.getPreMeetingService()

      if (preMeetingService) {
        this._sidMap.set(
          6,
          new NEPreMeetingServiceHandle(
            preMeetingService,
            this._listenerInvokeCallback
          )
        )
      }

      const meetingInviteService = this._meetingKit.getMeetingInviteService()

      if (meetingInviteService) {
        this._sidMap.set(
          7,
          new NEMeetingInviteServiceHandle(
            meetingInviteService,
            this._listenerInvokeCallback
          )
        )
      }

      const contactsService = this._meetingKit.getContactsService()

      if (contactsService) {
        this._sidMap.set(8, new NEContactsServiceHandle(contactsService))
      }

      const meetingMessageChannelService =
        this._meetingKit.getMeetingMessageChannelService()

      if (meetingMessageChannelService) {
        this._sidMap.set(
          9,
          new NEMeetingMessageChannelServiceHandle(
            meetingMessageChannelService,
            this._listenerInvokeCallback
          )
        )
      }

      const feedbackService = this._meetingKit.getFeedbackService()

      if (feedbackService) {
        this._sidMap.set(10, new NEFeedbackServiceHandle(feedbackService))
      }
    }

    return res
  }

  async unInitialize() {
    const res = await this._meetingKit.unInitialize()

    return res
  }

  async switchLanguage(data: string) {
    const { language } = JSON.parse(data)

    const res = await this._meetingKit.switchLanguage(language)

    return res
  }

  async getLogPath() {
    const res = await this._meetingKit.getSDKLogPath()

    return res
  }

  async getAppNoticeTips() {
    const res = await this._meetingKit.getAppNoticeTips()

    return res
  }
}
