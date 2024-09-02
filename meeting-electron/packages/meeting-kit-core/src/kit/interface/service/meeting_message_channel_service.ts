import {
  NEMessageSearchOrder,
  NEResult,
  NERoomSessionTypeEnum,
} from 'neroom-types'

export type NEMeetingGetMessageHistoryParams = {
  /** 获取聊天对象的Id（好友帐号，群ID等） 会话Id */
  sessionId: string
  /** 查询开启时间点 */
  fromTime?: number
  /** 查询截止时间点 */
  toTime: number
  /** 条数限制 限制0~100，否则414。其中0会被转化为100 */
  limit: number
  /** 查询方向,默认从大到小排序 */
  searchOrder?: NEMessageSearchOrder
}

export type NEMeetingSessionTypeEnum = NERoomSessionTypeEnum

export type NEMeetingSessionMessage = {
  /** 会话 id */
  sessionId: string
  /** 会话类型 */
  sessionType: NEMeetingSessionTypeEnum
  /** 消息 id */
  messageId: string
  /** 消息内容 */
  data: string
  /** 消息时间 */
  time: number
}

export type NEMeetingRecentSession = {
  /**
   * 获取聊天对象的Id（好友帐号，群ID等）
   * 会话Id
   */
  sessionId: string
  /**
   * 获取与该联系人的最后一条消息的发送方的帐号
   * 发送者帐号
   */
  fromAccount: string
  /**
   * 获取与该联系人的最后一条消息的发送方的昵称
   * 发送者昵称
   */
  fromNick: string
  /**
   * 会话类型
   */
  sessionType: NEMeetingSessionTypeEnum
  /**
   * 最近一条消息的UUID
   */
  recentMessageId: string
  /**
   * 该联系人的未读消息条数
   */

  unreadCount: number
  /**
   * 最近一条消息的缩略内容
   */
  content: string
  /**
   * 最近一条消息的时间，单位为ms
   */
  time: number
}

export type NEMeetingMessageChannelListener = {
  /**
   * 接收到自定义消息时会回调该方法
   * @param message 自定义会话消息
   */
  onSessionMessageReceived?(message: NEMeetingSessionMessage): void
  /**
   * 会话消息未读数变更时会回调该方法
   *
   * @param messages 未读消息列表
   */
  onSessionMessageRecentChanged?(messages: NEMeetingRecentSession[]): void
  /**
   * 会话消息被删除时会回调该方法
   *
   * @param message 自定义会话消息
   */
  onSessionMessageDeleted?(message: NEMeetingSessionMessage): void
  /**
   * 会话消息全部被删除时会回调该方法
   *
   * @param sessionId 会话id
   * @param sessionType 会话类型
   */
  onSessionMessageAllDeleted?(
    sessionId: string,
    sessionType: NEMeetingSessionTypeEnum
  ): void
}

interface NEMeetingMessageChannelService {
  /**
   * 添加自定义消息监听
   * @param listener 消息监听器
   */
  addMeetingMessageChannelListener: (
    listener: NEMeetingMessageChannelListener
  ) => void
  /**
   * 移除自定义消息监听
   * @param listener 消息监听器
   */
  removeMeetingMessageChannelListener: (
    listener: NEMeetingMessageChannelListener
  ) => void
  /**
   * 获取指定会话的未读消息列表
   * @param sessionId 会话id
   */
  queryUnreadMessageList(
    sessionId: string
  ): Promise<NEResult<NEMeetingSessionMessage[]>>
  /**
   * 清除指定会话的未读消息数
   * @param sessionId 会话id
   */
  clearUnreadCount(sessionId: string): Promise<NEResult<void>>
  /**
   * 删除指定会话的所有消息
   * 该接口会触发，{@link NEMeetingMessageChannelListener.onSessionMessageAllDeleted} 回调通知
   * @param sessionId 会话id
   */
  deleteAllSessionMessage(sessionId: string): Promise<NEResult<void>>
  /**
   * 获取指定会话的历史消息
   * @param param 查询参数
   */
  getSessionMessagesHistory(
    param: NEMeetingGetMessageHistoryParams
  ): Promise<NEResult<NEMeetingSessionMessage[]>>
}

export default NEMeetingMessageChannelService
