import { NEResult } from 'neroom-web-sdk'
import { CreateMeetingResponse } from '../../../types'
import {
  MeetingListItem,
  NEHistoryMeetingDetail,
  NEScheduledMember,
} from '../../../types/type'

export interface NEPreMeetingListener {
  /**
   * 会议信息变更回调，一次回调可能包含多个会议信息或状态的变更
   * @param meetingItemList 变更的会议列表
   */
  onMeetingItemInfoChanged: (meetingItemList: NEMeetingItem[]) => void
}

/// 聊天室导出状态
export const enum NEChatroomExportAccess {
  /** 未知 */
  kUnknown = 0,
  /** 可导出 */
  kAvailable,
  /** 无权限导出 */
  kNoPermission,
  /** 已过期 */
  kOutOfDate,
}

/// 会议状态
export const enum NEMeetingItemStatus {
  /** 无效状态 */
  invalid = 0,
  /** 会议初始状态，没有人入会 */
  init = 1,
  /** 已开始 */
  started = 2,
  /** 已结束可以再次入会 */
  ended = 3,
  /** 已取消 */
  cancel = 4,
  /** 已回收，不能再次入会 */
  recycled = 5,
}

export type NERemoteHistoryMeeting = MeetingListItem
export type NERemoteHistoryMeetingDetail = NEHistoryMeetingDetail
export type NEMeetingItem = CreateMeetingResponse

export interface ScheduleCallback {
  (meetingItems: NEMeetingItem[]): void
}

interface NEPreMeetingService {
  /**
   * 获取收藏会议列表，返回会议时间早于 anchorId 的最多 limit 个会议。
   * 如果 anchorId 小于等于 0，则从头开始查询。
   * @param anchorId 锚点Id，用于分页查询
   * @param limit 查询数量
   */
  getFavoriteMeetingList(
    anchorId: number,
    limit: number
  ): Promise<NEResult<NERemoteHistoryMeeting[]>>
  /**
   * 添加收藏会议
   * @param roomArchiveId 会议唯一id
   */
  addFavoriteMeeting(roomArchiveId: number): Promise<NEResult<void>>
  /**
   * 取消收藏会议
   * @param roomArchiveId 会议唯一id
   */
  removeFavoriteMeeting(roomArchiveId: number): Promise<NEResult<void>>
  /**
   * 获取历史会议列表
   * @param anchorMeetingId 锚点会议 Id，用于分页查询
   * @param limit 查询数量
   */
  getHistoryMeetingList(
    anchorMeetingId: number,
    limit: number
  ): Promise<NEResult<NERemoteHistoryMeeting[]>>
  /**
   * 获取历史会议详情
   * @param roomArchiveId 会议唯一id
   */
  getHistoryMeetingDetail(
    roomArchiveId: number
  ): Promise<NEResult<NERemoteHistoryMeetingDetail>>
  /**
   * 根据会议号查询历史会议
   * @param meetingId 会议唯一id
   */
  getHistoryMeeting(
    meetingId: number
  ): Promise<NEResult<NERemoteHistoryMeeting>>
  /**
   * 创建一个会议条目
   */
  createScheduleMeetingItem(): Promise<NEResult<NEMeetingItem>>
  /**
   * 预约会议
   * @param item 会议条目，通过{@link NEPreMeetingService#createScheduleMeetingItem()}创建
   */
  scheduleMeeting: (item: NEMeetingItem) => Promise<NEResult<NEMeetingItem>>
  /**
   * 修改已预定的会议信息
   * @param item 会议条目
   * @param editRecurringMeeting 是否修改所有周期性会议
   */
  editMeeting: (
    meeting: NEMeetingItem,
    editRecurringMeeting: boolean
  ) => Promise<NEResult<NEMeetingItem>>
  /**
   * 取消已预定的会议
   * @param meetingId 会议唯一Id
   * @param cancelRecurringMeeting 是否取消所有周期性会议
   */
  cancelMeeting: (
    meetingId: number,
    cancelRecurringMeeting: boolean
  ) => Promise<NEResult<void>>
  /**
   * 根据 meetingNum 查询预定会议信息
   * @param meetingNum 会议号
   */
  getMeetingItemByNum(meetingNum: string): Promise<NEResult<NEMeetingItem>>
  /**
   * 根据 meetingId 查询预定会议信息
   * @param meetingId 会议Id
   */
  getMeetingItemById(meetingId: number): Promise<NEResult<NEMeetingItem>>
  /**
   * 根据会议状态查询会议信息列表， 不传默认返回NEMeetingItemStatus.init, NEMeetingItemStatus.started
   * @param status 会议状态
   */
  getMeetingList(
    status: NEMeetingItemStatus[]
  ): Promise<NEResult<NEMeetingItem[]>>
  /**
   * 查询预约会议成员列表
   * @param meetingNum 会议号
   */
  getScheduledMeetingMemberList(
    meetingNum: string
  ): Promise<NEResult<NEScheduledMember[]>>
  /**
   * 注册预定会议状态变更监听器
   * @param listener 监听器
   */
  addListener(listener: NEScheduleMeetingStatusListener): void
  /**
   * 反注册预定会议状态变更监听器
   * @param listener 监听器
   */
  removeListener(listener: NEScheduleMeetingStatusListener): void
}

export default NEPreMeetingService
