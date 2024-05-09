import { useEffect } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import { ActionType, EventType } from '../../../types'
import { getWindow } from '../../../utils/windowsProxy'
import useMeetingPlugin from '../MeetingRightDrawer/MeetingPlugin/useMeetingPlugin'

function useMeetingNotificationInMeeting(): void {
  const { globalConfig, eventEmitter } = useGlobalContext()
  const { meetingInfo, dispatch } = useMeetingInfoContext()
  const { pluginList } = useMeetingPlugin()

  // 查询通知消息
  useEffect(() => {
    const sessionId = globalConfig?.appConfig.notifySenderAccid
    const sessionIds = pluginList?.map((item) => item.notifySenderAccid)
    sessionId && sessionIds?.push(sessionId)
    function onReceiveMessage(message?) {
      try {
        // 有相同的消息，直接返回
        if (
          meetingInfo.notificationMessages.find(
            (item) => item.messageId === message.messageId
          )
        ) {
          return
        }

        const isNotificationCenterOpen =
          !!getWindow('notificationList') ||
          meetingInfo.rightDrawerTabActiveKey === 'notification'
        let isPluginOpen = false
        const plugin = pluginList?.find(
          (item) => item.notifySenderAccid === message?.sessionId
        )
        if (plugin?.pluginId) {
          isPluginOpen =
            !!getWindow(plugin.pluginId) ||
            meetingInfo.rightDrawerTabActiveKey === plugin.pluginId
        }

        if (plugin?.pluginId)
          if (message.data) {
            const dataObj = JSON.parse(message.data)
            // 会中过滤非当前会议的通知消息
            if (
              meetingInfo.meetingId &&
              dataObj.data.meetingId !== meetingInfo.meetingId
            ) {
              return
            }
            if (sessionIds.includes(message?.sessionId)) {
              dispatch?.({
                type: ActionType.UPDATE_MEETING_INFO,
                data: {
                  notificationMessages: [
                    {
                      ...message,
                      beNotified: false,
                      unRead:
                        isNotificationCenterOpen || isPluginOpen ? false : true,
                    },
                    ...meetingInfo.notificationMessages,
                  ], // 通知消息
                },
              })
            }
          }
      } catch {}
    }
    eventEmitter?.on(EventType.OnReceiveSessionMessage, onReceiveMessage)
    return () => {
      eventEmitter?.off(EventType.OnReceiveSessionMessage, onReceiveMessage)
    }
  }, [
    globalConfig,
    eventEmitter,
    pluginList,
    dispatch,
    meetingInfo.notificationMessages,
    meetingInfo.meetingId,
    meetingInfo.rightDrawerTabActiveKey,
  ])
}

export { useMeetingNotificationInMeeting }
