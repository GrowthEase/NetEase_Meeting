import { NEResult } from '../../../types/type'

export type NEContact = {
  userUuid: string
  name: string
  avatar?: string
  dept?: string
  phoneNumber?: string
}

export type NEContactsInfoResult = {
  foundList: NEContact[]
  notFoundList: string[]
}

interface NEContactsService {
  /**
   * 根据电话号码进行企业通讯录模糊搜索
   *
   * @param phoneNumber 用户电话号码，不可空
   * @param pageSize 分页大小
   * @param pageNum 页码
   * @return 结果回调，回调数据类型为NEContact列表。
   */
  searchContactListByPhoneNumber(
    phoneNumber: string,
    pageSize: number,
    pageNum: number
  ): Promise<NEResult<NEContact[]>>

  /**
   * 根据用户名进行企业通讯录模糊搜索
   *
   * @param name 用户名，不可空
   * @param pageSize 分页大小
   * @param pageNum 页码
   * @return 结果回调，回调数据类型为NEContact列表。
   */
  searchContactListByName(
    name: string,
    pageSize: number,
    pageNum: number
  ): Promise<NEResult<NEContact[]>>

  /**
   * 通讯录用户信息查询
   *
   * @param userUuids 用户id列表
   * @param callback 结果回调，回调数据类型为NEContactsInfoResult。
   */
  getContactsInfo(userUuids: string[]): Promise<NEResult<NEContactsInfoResult>>
}

export default NEContactsService
