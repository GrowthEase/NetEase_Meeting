import { useCallback, useEffect } from 'react'
import { useGlobalContext } from '../store'
import { NEMeetingInviteInfo, NEMeetingInviteStatus } from '../types/type'
import { getWindow, openWindow } from '../utils/windowsProxy'
import { ActionType, EventType, UserEventType } from '../types'
import { getLocalStorageSetting } from '../utils'
import { useTranslation } from 'react-i18next'
import { NECustomSessionMessage } from 'neroom-types'

export default function useElectronInvite(data: {
  needOpenWindow: boolean
}): void {
  const { needOpenWindow } = data
  const { t } = useTranslation()
  const { inviteService, neMeeting, eventEmitter, dispatch } =
    useGlobalContext()

  const onNotificationClickHandler = useCallback(
    (action: string, message: NECustomSessionMessage) => {
      if (!message || !window.isElectronNative) return
      const data = message.data?.data
      const type = data?.type

      if (type === 'MEETING.INVITE') {
        if (action === 'reject') {
          neMeeting?.rejectInvite(data.roomUuid)
        } else if (action === 'join') {
          dispatch?.({
            type: ActionType.UPDATE_GLOBAL_CONFIG,
            data: {
              waitingJoinOtherMeeting: true,
              joinLoading: true,
            },
          })
          const setting = getLocalStorageSetting()
          const options = {
            meetingNum: data.meetingNum,
            video: setting?.normalSetting.openAudio ? 1 : 2,
            audio: setting?.normalSetting.openVideo ? 1 : 2,
          }

          eventEmitter?.emit(UserEventType.JoinOtherMeeting, options, (e) => {
            console.log('加入房间', e)
          })
        }
      }
    },
    [neMeeting, dispatch, eventEmitter]
  )

  const windowLoadListener = useCallback(
    (childWindow) => {
      function messageListener(e) {
        const { event, payload } = e.data

        if (event === 'notificationClick') {
          const { action, message } = payload

          if (action.startsWith('join') || action.startsWith('reject')) {
            onNotificationClickHandler(action, message)
          }
        }
      }

      childWindow?.addEventListener('message', messageListener)
    },
    [onNotificationClickHandler]
  )

  const openNotificationCardWindow = useCallback(
    (message) => {
      const notificationCardWindow = openWindow('notificationCardWindow')
      const postMessage = () => {
        notificationCardWindow?.postMessage(
          {
            event: 'updateNotifyCard',
            payload: {
              message,
            },
          },
          notificationCardWindow.origin
        )
      }

      // 不是第一次打开
      if (notificationCardWindow?.firstOpen === false) {
        postMessage()
      } else {
        windowLoadListener(notificationCardWindow)
        notificationCardWindow?.addEventListener('load', () => {
          postMessage()
        })
      }
    },
    [windowLoadListener]
  )

  useEffect(() => {
    if (window.isElectronNative) {
      const handleMeetingInviteStatusChanged = (
        status: NEMeetingInviteStatus,
        meetingId: string,
        inviteInfo: NEMeetingInviteInfo,
        message: NECustomSessionMessage
      ) => {
        console.warn('handleMeetingInviteStatusChanged>>>', status, inviteInfo)
        if (status === NEMeetingInviteStatus.calling) {
          const dataObj = message.data
          const notifyCard = dataObj?.data?.notifyCard
          const type = dataObj.data.type

          if (notifyCard && type === 'MEETING.INVITE') {
            notifyCard.popUpCardBottomButton = [
              {
                name: t('globalReject'),
                action: 'reject',
                ghost: true,
              },
              {
                name: t('meetingJoin'),
                action: 'join',
              },
            ]
            dataObj.data.notifyCard = notifyCard
          }

          message.data = dataObj
          needOpenWindow && openNotificationCardWindow(message)
        } else if (
          status === NEMeetingInviteStatus.rejected ||
          status === NEMeetingInviteStatus.canceled ||
          status === NEMeetingInviteStatus.busy ||
          status === NEMeetingInviteStatus.removed
        ) {
          const notificationCardWindow = getWindow('notificationCardWindow')

          console.warn('notificationCardWindow>>', notificationCardWindow)
          notificationCardWindow?.postMessage(
            {
              event: 'inviteStateChange',
              payload: {
                status,
                meetingId,
              },
            },
            notificationCardWindow.origin
          )
        }
      }

      inviteService?.on(
        EventType.OnMeetingInviteStatusChange,
        handleMeetingInviteStatusChanged
      )
      return () => {
        inviteService?.off(
          EventType.OnMeetingInviteStatusChange,
          handleMeetingInviteStatusChanged
        )
      }
    }
  }, [inviteService, t, needOpenWindow, openNotificationCardWindow])
}
