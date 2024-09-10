import { z, ZodError } from 'zod'
import { FailureBody, SuccessBody } from 'neroom-types'
import NEMeetingService from '../../../services/NEMeeting'
import { NEResult } from '../../../types/type'
import { Logger } from '../../../utils/Logger'
import NEContactsServiceInterface, {
  NEContactsInfoResult,
  NEContact,
} from '../../interface/service/meeting_contacts_service'
import { GetAccountInfoListResponse, SearchAccountInfo } from '../../../types'

export default class NEContactsService implements NEContactsServiceInterface {
  private _logger: Logger
  private _neMeeting: NEMeetingService

  constructor(params: { logger: Logger; neMeeting: NEMeetingService }) {
    this._logger = params.logger
    this._neMeeting = params.neMeeting
  }
  async searchContactListByName(
    name: string,
    pageSize: number,
    pageNum: number
  ): Promise<NEResult<NEContact[]>> {
    try {
      const nameSchema = z.string()
      const pageSizeSchema = z.number()
      const pageNumSchema = z.number()

      nameSchema.parse(name, {
        path: ['name'],
      })

      pageSizeSchema.parse(pageSize, {
        path: ['pageSize'],
      })

      pageNumSchema.parse(pageNum, {
        path: ['pageNum'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    return this._neMeeting
      .searchAccount({
        name,
        pageSize,
        pageNum,
      })
      .then((res: SearchAccountInfo[]) => {
        return SuccessBody(res.map(this._formatNEContact))
      })
  }
  async searchContactListByPhoneNumber(
    phoneNumber: string,
    pageSize: number,
    pageNum: number
  ): Promise<NEResult<NEContact[]>> {
    try {
      const phoneNumberSchema = z.string()
      const pageSizeSchema = z.number()
      const pageNumSchema = z.number()

      phoneNumberSchema.parse(phoneNumber, {
        path: ['phoneNumber'],
      })

      pageSizeSchema.parse(pageSize, {
        path: ['pageSize'],
      })

      pageNumSchema.parse(pageNum, {
        path: ['pageNum'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    return this._neMeeting
      .searchAccount({
        phoneNumber,
        pageSize,
        pageNum,
      })
      .then((res: SearchAccountInfo[]) => {
        return SuccessBody(res.map(this._formatNEContact))
      })
  }
  getContactsInfo(
    userUuids: string[]
  ): Promise<NEResult<NEContactsInfoResult>> {
    try {
      const userUuidsSchema = z.array(z.string())

      userUuidsSchema.parse(userUuids, {
        path: ['userUuids'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    return this._neMeeting
      .getAccountInfoList(userUuids)
      .then((res: GetAccountInfoListResponse) => {
        return SuccessBody({
          foundList:
            res.meetingAccountListResp?.map(this._formatNEContact) || [],
          notFoundList: res.notFindUserUuids,
        })
      })
  }

  private _formatNEContact(item: SearchAccountInfo) {
    return {
      userUuid: item.userUuid,
      name: item.name,
      avatar: item.avatar || '',
      dept: item.dept || '',
      phoneNumber: item.phoneNumber || '',
    }
  }
}
