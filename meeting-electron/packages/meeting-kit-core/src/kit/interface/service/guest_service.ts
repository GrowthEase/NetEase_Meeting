import { NEResult } from 'neroom-types'
import { NEJoinMeetingParams, NEMeetingOptions } from './meeting_service'

export type NEGuestJoinMeetingParams = {
  phoneNumber?: string
  smsCode?: string
} & NEJoinMeetingParams

export interface NEGuestService {
  joinMeetingAsGuest(
    param: NEGuestJoinMeetingParams,
    opts?: NEMeetingOptions
  ): Promise<NEResult<void>>

  requestSmsCodeForGuestJoin(
    meetingNum: string,
    phoneNumber: string
  ): Promise<NEResult<void>>
}

export default NEGuestService
