import { NEResult, SuccessBody } from 'neroom-types'
import { NEMeetingOptions } from '../../interface'
import NEGuestServiceInterface, {
  NEGuestJoinMeetingParams,
} from '../../interface/service/guest_service'
import MeetingService from '../../../services/NEMeeting'
import NEMeetingKit from '../meeting_kit'
import { GuestMeetingInfo, NEMeetingStatusListener } from '../../../types/type'

export default class NEGuestService implements NEGuestServiceInterface {
  private _neMeeting: MeetingService
  private _meetingKit: NEMeetingKit
  private _meetingStatusListeners: NEMeetingStatusListener[] | undefined = []
  constructor(param: { neMeeting: MeetingService; meetingKit: NEMeetingKit }) {
    this._meetingKit = param.meetingKit
    this._neMeeting = param.neMeeting
  }

  async joinMeetingAsGuest(
    param: NEGuestJoinMeetingParams,
    opts?: NEMeetingOptions
  ): Promise<NEResult<void>> {
    const { meetingNum, phoneNumber, smsCode } = param

    let res: GuestMeetingInfo

    if (phoneNumber && smsCode) {
      res = await this._neMeeting.getMeetingInfoForGuestByPhoneNum({
        phoneNum: phoneNumber,
        verifyCode: smsCode,
        meetingNum,
      })
    } else {
      res = await this._neMeeting.getMeetingInfoForGuest(meetingNum)
    }

    const meetingService = this._meetingKit.getMeetingService()

    this._meetingStatusListeners = meetingService?._meetingStatusListeners
    try {
      meetingService?.removeMeetingStatusListener()
      await this._meetingKit.unInitialize()
    } catch (error) {
      //
    }

    await this._joinMeeting(param, res, opts)
    return SuccessBody(void 0)
  }

  async requestSmsCodeForGuestJoin(
    meetingNum: string,
    phoneNumber: string
  ): Promise<NEResult<void>> {
    await this._neMeeting.sendVerifyCodeApiByGuest(meetingNum, phoneNumber)
    return SuccessBody(void 0)
  }
  private async _joinMeeting(
    param: NEGuestJoinMeetingParams,
    res: GuestMeetingInfo,
    opts?: NEMeetingOptions
  ) {
    const domain = this._neMeeting._meetingServerDomain

    await this._meetingKit.initialize({
      appKey: res.meetingAppKey,
      serverUrl: domain,
      width: 0,
      height: 0,
    })
    await this._meetingKit
      .getAccountService()
      ?.loginByDynamicToken(
        res.meetingUserUuid,
        res.meetingUserToken,
        res.meetingAuthType
      )
      .catch(async (e) => {
        console.log('loginByDynamicToken', e)
        await this._meetingKit.unInitialize().catch(() => {
          //
        })
        throw e
      })
    const meetingService = this._meetingKit.getMeetingService()

    // 需要把之前监听的事件缓存重新赋值，因为是新的实列
    if (meetingService && this._meetingStatusListeners) {
      meetingService._meetingStatusListeners = this._meetingStatusListeners
    }

    await this._meetingKit
      .getMeetingService()
      ?.joinMeeting(param, opts)
      .catch(async (e) => {
        console.log('joinMeeting ==== ', e)
        await this._meetingKit
          .getAccountService()
          ?.logout()
          .catch(() => {
            //
          })
        await this._meetingKit.unInitialize().catch(() => {
          //
        })
        throw e
      })
  }
}
