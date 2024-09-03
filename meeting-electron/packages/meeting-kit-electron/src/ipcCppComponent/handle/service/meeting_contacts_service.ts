import { FailureBodySync } from 'neroom-types'
import NEContactsService from '../../../kit/impl/service/meeting_contacts_service'

export default class NEContactsServiceHandle {
  private _contactsService: NEContactsService

  constructor(contactsService: NEContactsService) {
    this._contactsService = contactsService
  }

  async onMethodHandle(cid: number, data: string): Promise<string> {
    let res

    switch (cid) {
      case 1:
        res = await this.searchContactListByPhoneNumber(data)
        break
      case 3:
        res = await this.searchContactListByName(data)
        break
      case 5:
        res = await this.getContactsInfo(data)
        break
      default:
        return JSON.stringify(FailureBodySync(undefined, 'method not found'))
    }

    return JSON.stringify(res)
  }

  async searchContactListByPhoneNumber(data: string) {
    const { phoneNumber, pageSize, pageNum } = JSON.parse(data)

    return await this._contactsService.searchContactListByPhoneNumber(
      phoneNumber,
      pageSize,
      pageNum
    )
  }

  async searchContactListByName(data: string) {
    const { name, pageSize, pageNum } = JSON.parse(data)

    return await this._contactsService.searchContactListByName(
      name,
      pageSize,
      pageNum
    )
  }

  async getContactsInfo(data: string) {
    const { userUuids } = JSON.parse(data)

    return await this._contactsService.getContactsInfo(userUuids)
  }
}
