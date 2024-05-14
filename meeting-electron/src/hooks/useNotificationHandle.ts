import { NotificationInstance } from 'antd/es/notification/interface'
import Toast from '../components/common/toast'
import NEMeetingService from '../services/NEMeeting'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import { ActionType, UserEventType } from '../types'
import { getLocalStorageSetting } from '../utils'
import Modal from '../components/common/Modal'

interface UseNotificationHandleProps {
  neMeeting?: NEMeetingService
  notificationApi?: NotificationInstance
  beforeMeeting?: boolean
  beforeMeetingJoin?: (meetingNum: string) => void
  meetingNum?: string
  isLocalSharingScreen?: boolean
}
interface UseNotificationHandleReturn {
  onNotificationClickHandler: (action: string, message?: any) => void
}
export default function useNotificationHandle(
  data: UseNotificationHandleProps
): UseNotificationHandleReturn {
  const {
    neMeeting,
    notificationApi,
    beforeMeeting,
    isLocalSharingScreen,
    beforeMeetingJoin,
    meetingNum,
  } = data
  const { dispatch: globalDispatch, eventEmitter } = useGlobalContext()
  const { dispatch } = useMeetingInfoContext()
  const onNotificationClickHandler = async (action: string, message?: any) => {
    if (!message) return
    const data = message.data?.data
    const type = data?.type
    if (type === 'MEETING.INVITE' || type === 'MEETING.SCHEDULE.START') {
      // 拒绝加入
      if (action === 'reject') {
        neMeeting?.rejectInvite(data.roomUuid)
        notificationApi?.destroy(data?.roomUuid)
      } else if (action === 'join') {
        // 需要先离开当前会议
        globalDispatch?.({
          type: ActionType.UPDATE_GLOBAL_CONFIG,
          data: {
            waitingJoinOtherMeeting: true,
            joinLoading: true,
          },
        })
        if (!beforeMeeting) {
          // 如果是已在邀请的会议则不处理
          if (data.meetingNum === meetingNum) {
            return
          }
          if (isLocalSharingScreen) {
            try {
              await neMeeting?.muteLocalScreenShare()
            } catch (error) {
              console.warn('muteLocalScreenShare', error)
            }
          }
          // 加入新的会议
          setTimeout(async () => {
            try {
              notificationApi?.destroy()
              await neMeeting?.leave()
              Modal.destroyAll()
              globalDispatch?.({
                type: ActionType.JOIN_LOADING,
                data: false,
              })
              dispatch?.({
                type: ActionType.RESET_MEMBER,
                data: null,
              })
              dispatch &&
                dispatch({
                  type: ActionType.RESET_MEETING,
                  data: null,
                })
              const setting = getLocalStorageSetting()
              eventEmitter?.emit(UserEventType.JoinOtherMeeting, {
                meetingNum: data.meetingNum,
                video: setting?.normalSetting.openVideo ? 1 : 2,
                audio: setting?.normalSetting.openAudio ? 1 : 2,
              })
              notificationApi?.destroy()
            } catch (e: any) {
              Toast.fail(e.message || e.msg || e.code)
            }
          })
        } else {
          beforeMeetingJoin?.(data.meetingNum)
          notificationApi?.destroy()
        }
      }
    }
  }

  return {
    onNotificationClickHandler,
  }
}
