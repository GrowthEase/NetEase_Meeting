import { NEMessageSearchOrder } from 'neroom-web-sdk/dist/types/types/messageChannelService'

export const enum NEMeetingSessionTypeEnum {
  None = -1,
  P2P = 0,
}

export interface NEMeetingGetMessageHistoryParams {
  /** 获取聊天对象的Id（好友帐号，群ID等） 会话Id */
  sessionId: string
  /** 查询开启时间点 */
  fromTime: number
  /** 查询截止时间点 */
  toTime: number
  /** 条数限制 限制0~100，否则414。其中0会被转化为100 */
  limit: number
  /** 查询方向,默认从大到小排序 */
  searchOrder: NEMessageSearchOrder
}

export interface NEMeetingSessionMessage {
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

interface NEMeetingMessageChannelListener {
  /**
   * 接收到自定义消息时会回调该方法
   * @param message
   */
  onSessionMessageReceived: (message: NEMeetingSessionMessage) => void
  /**
   * 会话消息全部被删除时会回调该方法
   */
  onSessionMessageAllDeleted: (
    sessionId: string,
    sessionType: NEMeetingSessionTypeEnum
  ) => void
}

// interface NEMeetingMessageChannelService {
//   /**
//    * 添加自定义消息监听
//    * @param listener 消息监听器
//    */
//   addMeetingMessageChannelListener: (
//     listener: NEMeetingMessageChannelListener
//   ) => void
//   /**
//    * 移除自定义消息监听
//    * @param listener 消息监听器
//    */
//   removeMeetingMessageChannelListener: (
//     listener: NEMeetingMessageChannelListener
//   ) => void
//   /**
//    * 获取指定会话的未读消息列表
//    * @param sessionId 会话id
//    */
//   queryUnreadMessageList(): Promise<NEResult<NEMeetingSessionMessage[]>>
//   /**
//    * 清除指定会话的未读消息数
//    * @param sessionId 会话id
//    */
//   clearUnreadCount(): Promise<NEResult<void[]>>
//   /**
//    * 删除指定会话的所有消息
//    * 该接口会触发，{@link NEMeetingMessageChannelListener.onSessionMessageAllDeleted} 回调通知
//    * @param sessionId 会话id
//    */
//   deleteAllSessionMessage(): Promise<NEResult<void>>
//   /**
//    * 获取指定会话的历史消息
//    * @param param 查询参数
//    */
//   getSessionMessagesHistory(
//     param: NEMeetingGetMessageHistoryParams
//   ): Promise<NEResult<NEMeetingSessionMessage[]>>
// }

export default NEMeetingMessageChannelListener
