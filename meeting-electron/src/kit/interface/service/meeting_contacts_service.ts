import { NEResult } from '../../../types/type'

interface NEContactsService {
  /**
   * 根据用户名或电话号码进行企业通讯录模糊搜索
   *
   * @param name 用户名称，可空
   * @param phoneNumber 用户手机号，可空
   * @param pageSize 分页大小
   * @param pageNum 页码
   * @return 结果回调，回调数据类型为NEContact列表。
   */
  searchContactList(
    name: string,
    phoneNumber: string,
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

interface NEContact {
  userUuid: string
  name: string
  avatar?: string
  dept?: string
  phoneNumber?: string
}

interface NEContactsInfoResult {
  foundList: NEContact[]
  notFoundList: string[]
}

export default NEContactsService
