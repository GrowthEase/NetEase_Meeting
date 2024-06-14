import { NEResult, NERoomContext } from 'neroom-web-sdk'
import { NEMeetingJoinOptions } from '../../../types'
import {
  NEJoinMeetingParams,
  NEMeetingInviteInfo,
  NEMeetingInviteStatus,
} from '../../../types/type'

export interface NEMeetingInviteStatusListener {
  onMeetingInviteStatusChanged: (
    status: NEMeetingInviteStatus,
    inviteInfo: NEMeetingInviteInfo,
    meetingId: string
  ) => void
}

interface NEMeetingInviteService {
  /**
   * 加入一个当前正在进行中的会议，已登录或未登录均可加入会议。
   *
   * <p>加入会议成功后，SDK会拉起会议页面，调用方不用做其他操作。
   *
   * @param param 会议参数对象，不能为空
   * @param opts 会议选项对象，可空；当未指定时，会使用默认的选项
   */
  acceptInvite: (
    param: NEJoinMeetingParams,
    options: NEMeetingJoinOptions
  ) => Promise<NEResult<NERoomContext>>
  /**
   * 拒绝一个邀请，只有完成SDK的登录鉴权操作才允许该操作。 挂断正在进行的呼叫，无论是正在响铃还是等待响铃都可以使用
   * @param meetingId
   */
  rejectInvite: (meetingId: string) => Promise<NEResult<void>>
  /**
   * 获取邀请状态
   *
   * @return 邀请状态
   */
  getMeetingInviteStatus(): NEMeetingInviteStatus
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
