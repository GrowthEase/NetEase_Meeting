import { NEResult } from 'neroom-web-sdk'
import { CreateOptions, JoinOptions } from '../../../types'
import {
  CommonBar,
  NEJoinMeetingParams,
  NELocalHistoryMeeting,
  NEMeetingInfo,
  NEMeetingStatus,
  NEMeetingStatusListener,
  NEStartMeetingParams,
} from '../../../types/type'

export type NEStartMeetingOptions = CreateOptions
export type NEMeetingJoinOptions = JoinOptions

export interface NEMeetingServiceListener {
  onRoomEnded?: (reason: number) => void
}

type NEMeetingMenuItem = CommonBar

interface NEMeetingService {
  /**
   * 开始一个新的会议，只有完成SDK的登录鉴权操作才允许创建会议。
   * @param param 会议参数对象，不能为空
   * @param opts 会议选项对象，可空；当未指定时，会使用默认的选项
   */
  startMeeting(
    param: NEStartMeetingParams,
    opts?: NEStartMeetingOptions
  ): Promise<NEResult<void>>
  /**
   * 加入一个当前正在进行中的会议，已登录或未登录均可加入会议。
   * 加入会议成功后，SDK会拉起会议页面，调用方不用做其他操作
   * @param param 会议参数对象，不能为空
   * @param opts 会议选项对象，可空；当未指定时，会使用默认的选项
   */
  joinMeeting(
    param: NEJoinMeetingParams,
    opts?: NEMeetingJoinOptions
  ): Promise<NEResult<void>>
  /**
   * 匿名加入一个当前正在进行中的会议
   * 加入会议成功后，SDK会拉起会议页面，调用方不用做其他操作
   * @param param 会议参数对象，不能为空
   * @param opts 会议选项对象，可空；当未指定时，会使用默认的选项
   */
  anonymousJoinMeeting(
    param: NEJoinMeetingParams,
    opts?: NEMeetingJoinOptions
  ): Promise<NEResult<void>>
  /**
   * 添加自定义注入菜单按钮的点击事件监听
   *
   * @param listener 事件监听器
   */
  // setOnInjectedMenuItemClickListener(
  //   listener: NEMeetingOnInjectedMenuItemClickListener
  // ): void

  /**
   * 更新当前存在的自定义菜单项的状态 注意：该接口更新菜单项的文本(最长为10，超过不生效)
   *
   * @param item 当前已存在的菜单项
   */
  updateInjectedMenuItem(item: NEMeetingMenuItem): void
  /**
   * 获取当前的会议状态，会议状态的定义参考
   *
   * @return 会议状态
   */
  getMeetingStatus(): Promise<NEMeetingStatus>

  /**
   * 获取当前会议详情。如果当前无正在进行中的会议，则返回undefined
   *
   */
  getCurrentMeetingInfo(): Promise<NEMeetingInfo | undefined>
  /**
   * 添加会议状态监听实例，用于接收会议状态变更通知
   *
   * @param listener 要添加的监听实例
   */
  addMeetingStatusListener(listener: NEMeetingStatusListener): void
  /**
   * 移除对应的会议状态的监听实例
   *
   * @param listener 要移除的监听实例
   */
  removeMeetingStatusListener(listener: NEMeetingStatusListener): void
  /**
   * 获取本地历史会议记录列表，不支持漫游保存，默认保存最近10条记录
   **/
  getLocalHistoryMeetingList(): Promise<NELocalHistoryMeeting[]>

  /**
   * 离开当前进行中的会议，并通过参数控制是否同时结束当前会议；
   *
   * <p>只有主持人才能结束会议，其他用户设置结束会议无效；
   *
   * <p>如果退出当前会议后，会议中再无其他成员，则该会议也会结束；
   *
   * @param closeIfHost true：结束会议；false：不结束会议；
   */
  leaveCurrentMeeting(closeIfHost: boolean): Promise<NEResult<void>>
  /**
   * 添加会议监听
   * @param listener
   */
  addEventListener(listener: NEMeetingServiceListener): void
  /**
   * 移除会议监听
   * @param listener
   */
  removeEventListener(listener: NEMeetingServiceListener): void
}

export default NEMeetingService
