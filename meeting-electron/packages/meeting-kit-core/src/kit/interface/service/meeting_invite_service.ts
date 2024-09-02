import { NECustomSessionMessage, NEResult } from 'neroom-types'
import { NEMeetingInviteInfo, NEMeetingInviteStatus } from '../../../types/type'
import { NEJoinMeetingParams, NEJoinMeetingOptions } from './meeting_service'

export type NEMeetingInviteStatusListener = {
  onMeetingInviteStatusChanged?: (
    status: NEMeetingInviteStatus,
    inviteInfo: NEMeetingInviteInfo,
    meetingId: number,
    message: NECustomSessionMessage
  ) => void
}

interface NEMeetingInviteService {
  /**
   * 接受邀请，加入一个当前正在进行中的会议
   *
   * <p>加入会议成功后，SDK会拉起会议页面，调用方不用做其他操作。
   *
   * @param param 会议参数对象，不能为空
   * @param opts 会议选项对象，可空；当未指定时，会使用默认的选项
   */
  acceptInvite: (
    param: NEJoinMeetingParams,
    options?: NEJoinMeetingOptions
  ) => Promise<NEResult<void>>
  /**
   * 拒绝会议邀请，只有完成SDK的登录鉴权操作才允许该操作。
   * @param meetingId 会议唯一Id
   */
  rejectInvite(meetingId: number): Promise<NEResult<void>>
  /**
   * 添加邀请状态监听实例，用于接收邀请状态变更通知
   *
   * @param listener 要添加的监听实例
   */
  addMeetingInviteStatusListener: (
    listener: NEMeetingInviteStatusListener
  ) => void
  /**
   * 移除对应的邀请状态监听实例
   *
   * @param listener 要移除的监听实例
   */
  removeMeetingInviteStatusListener: (
    listener: NEMeetingInviteStatusListener
  ) => void
}

export default NEMeetingInviteService
