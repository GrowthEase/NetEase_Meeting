import { useEffect } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import { ActionType, EventType } from '../types'
import { getWindow } from '../utils/windowsProxy'
import useMeetingPlugin from './useMeetingPlugin'
import { useTranslation } from 'react-i18next'

function useMeetingNotificationInMeeting(): void {
  const { globalConfig, eventEmitter } = useGlobalContext()
  const { meetingInfo, dispatch } = useMeetingInfoContext()
  const { pluginList } = useMeetingPlugin()
  const { t } = useTranslation()

  // 查询通知消息
  useEffect(() => {
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
        if (message.data) {
          const dataObj =
            Object.prototype.toString.call(message.data) === '[object Object]'
              ? message.data
              : JSON.parse(message.data)
          const type = dataObj.data.type
          // 会中过滤非当前会议的通知消息
          if (
            (meetingInfo.meetingId &&
              dataObj.data.meetingId !== meetingInfo.meetingId &&
              type !== 'MEETING.INVITE' &&
              type !== 'MEETING.SCHEDULE.START') ||
            (!meetingInfo.meetingNum &&
              (type === 'MEETING.INVITE' ||
                type === 'MEETING.SCHEDULE.START' ||
                type === 'MEETING.SCHEDULE.INVITE' ||
                type === 'MEETING.SCHEDULE.INFO.UPDATE'))
          ) {
            return
          }
          const inviteNotification =
            type === 'MEETING.INVITE' || type === 'MEETING.SCHEDULE.START'
          // 如果是邀请按钮需要修改按钮
          if (inviteNotification) {
            const notifyCard = dataObj?.data?.notifyCard
            if (notifyCard) {
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
              notifyCard.footTip = t('sipJoinOtherMeetingTip')
              dataObj.data.notifyCard = notifyCard
            }
          }
          message.data = dataObj
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              notificationMessages: [
                {
                  ...message,
                  beNotified: false,
                  noShowInNotificationCenter: inviteNotification,
                  unRead:
                    // 邀请通知，通知中心打开，对应插件打开，不显示未读
                    inviteNotification ||
                    isNotificationCenterOpen ||
                    isPluginOpen
                      ? false
                      : true,
                },
                ...meetingInfo.notificationMessages,
              ], // 通知消息
            },
          })
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
    meetingInfo.meetingNum,
    meetingInfo.rightDrawerTabActiveKey,
    t,
  ])
}

export { useMeetingNotificationInMeeting }
