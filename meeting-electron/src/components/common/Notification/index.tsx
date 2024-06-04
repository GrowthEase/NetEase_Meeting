import { Button } from 'antd'
import React, { useEffect, useMemo } from 'react'
import { useTranslation } from 'react-i18next'

import { useUpdateEffect } from 'ahooks'
import { NotificationInstance } from 'antd/es/notification/interface'
import { NECustomSessionMessage } from 'neroom-web-sdk/dist/types/types/messageChannelService'
import useMeetingPlugin from '../../../hooks/useMeetingPlugin'
import useNotificationHandle from '../../../hooks/useNotificationHandle'
import NEMeetingService from '../../../services/NEMeeting'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import { ActionType } from '../../../types'
import MeetingNotificationGlobalCard from '../../web/MeetingNotification/GlobalCard'
import './index.less'

type MeetingNotificationProps = {
  isH5?: boolean
  onClick?: (action: string, message: any) => void
  beforeMeeting?: boolean
  beforeMeetingJoin?: (meetingNum: string) => void
  customMessage?: NECustomSessionMessage
  notification?: NotificationInstance
  neMeeting?: NEMeetingService
  onNotificationCardWinOpen?: (message: NECustomSessionMessage) => void
}

const MeetingNotification: React.FC<MeetingNotificationProps> = ({
  isH5 = false,
  onClick,
  beforeMeeting,
  customMessage,
  notification,
  neMeeting,
  beforeMeetingJoin,
  onNotificationCardWinOpen,
}) => {
  const { t } = useTranslation()
  const { notificationApi: notificationInstance } = useGlobalContext()

  const { meetingInfo, dispatch } = useMeetingInfoContext()

  const noMoreRemindSessionIdsRef = React.useRef<string[]>([])
  const { pluginList, onClickPlugin } = useMeetingPlugin()

  const localMember = meetingInfo.localMember

  const isElectronSharingScreen = useMemo(() => {
    return window.ipcRenderer && localMember.isSharingScreen
  }, [localMember.isSharingScreen])

  function onClickNotifyHandler(message: any, action: string) {
    onClick?.(action, message)
  }

  const notificationApi = useMemo(() => {
    return notificationInstance || notification
  }, [notificationInstance, notification])
  const { onNotificationClickHandler } = useNotificationHandle({
    neMeeting,
    notificationApi,
    beforeMeeting,
    isLocalSharingScreen: localMember.isSharingScreen,
    beforeMeetingJoin,
  })
  function onReceiveSessionMessage(message: NECustomSessionMessage) {
    if (
      (meetingInfo.meetingNum || beforeMeeting) &&
      !noMoreRemindSessionIdsRef.current.includes(message.sessionId)
    ) {
      try {
        const notify = message.data as any
        const notifyCard = notify?.data?.notifyCard
        const type = notify?.data?.type

        if (window.isElectronNative) {
          onNotificationCardWinOpen?.(message)
        } else {
          if (notifyCard && notifyCard.popUp) {
            // h5 删除所有通知
            isH5 && notificationApi?.destroy()
            let notificationContent: any = {}
            if (
              !isH5 &&
              beforeMeeting &&
              (type === 'MEETING.INVITE' || type === 'MEETING.SCHEDULE.START')
            ) {
              notificationContent = {
                key: message.data?.data?.meetingId,
                message: null,
                description: (
                  <MeetingNotificationGlobalCard
                    messageList={[message]}
                    onClick={(action, message) =>
                      onClickNotifyHandler(message, action)
                    }
                    showCloseIcon={false}
                  />
                ),
                style: {},
                className: 'nemeeting-invite-notify',
                duration: message.data?.data?.popupDuration || 60,
              }
            } else {
              notificationContent = {
                key: message.messageId,
                message: (
                  <div className="header">
                    <div className="info">
                      {notifyCard.header?.icon ? (
                        <img
                          alt=""
                          className="icon"
                          src={notifyCard.header?.icon}
                        />
                      ) : null}

                      <div className="label">{notifyCard.header?.subject}</div>
                    </div>
                    {isH5 ? null : (
                      <div className="buttons">
                        {notifyCard.popUpCardBottomButton?.map((item) => {
                          return (
                            <Button
                              key={item.name}
                              className="button"
                              type={
                                item.action === 'meeting://no_more_remind'
                                  ? 'text'
                                  : 'primary'
                              }
                              onClick={() => {
                                if (
                                  item.action === 'meeting://no_more_remind'
                                ) {
                                  noMoreRemindSessionIdsRef.current.push(
                                    message.sessionId
                                  )
                                }
                                if (
                                  item.action.startsWith(
                                    'meeting://open_plugin'
                                  )
                                ) {
                                  onClickPlugin(item.action, isH5)
                                }
                                notificationApi?.destroy(message.messageId)
                              }}
                            >
                              {item.name}
                            </Button>
                          )
                        })}
                      </div>
                    )}
                  </div>
                ),
                description: (
                  <>
                    <div className="title">{notifyCard.body?.title}</div>
                    {isH5 ? (
                      <div className="buttons">
                        {notifyCard.popUpCardBottomButton?.map((item) => {
                          return (
                            <Button
                              key={item.name}
                              className="button"
                              type={
                                item.action === 'meeting://no_more_remind'
                                  ? 'text'
                                  : 'primary'
                              }
                              onClick={() => {
                                if (
                                  item.action === 'meeting://no_more_remind'
                                ) {
                                  noMoreRemindSessionIdsRef.current.push(
                                    message.sessionId
                                  )
                                }
                                if (
                                  item.action.startsWith(
                                    'meeting://open_plugin'
                                  )
                                ) {
                                  onClickPlugin(item.action)
                                }
                                notificationApi?.destroy(message.messageId)
                              }}
                            >
                              {item.name}
                            </Button>
                          )
                        })}
                      </div>
                    ) : (
                      <div className="description">
                        {notifyCard.body?.content}
                      </div>
                    )}
                  </>
                ),
                closeIcon: isH5 ? undefined : (
                  <div className="close-icon">
                    <svg className="icon iconfont" aria-hidden="true">
                      <use xlinkHref="#iconcross"></use>
                    </svg>
                  </div>
                ),
                duration: 5,
                className: isH5
                  ? 'meeting-notification-h5-card-wrapper'
                  : 'meeting-notification-card-wrapper',
                placement: isH5 ? 'bottom' : 'topRight',
              }
            }
            // 会中不需要弹窗
            if (type === 'MEETING.INVITE' && !beforeMeeting) {
              return
            }
            notificationApi?.open(notificationContent)
          }
        }
      } catch {}
    }
  }

  useUpdateEffect(() => {
    if (meetingInfo.meetingNum) {
      noMoreRemindSessionIdsRef.current = []
      meetingInfo.notificationMessages.forEach((message) => {
        if (
          message &&
          message.beNotified === false &&
          (meetingInfo.meetingNum || beforeMeeting)
        ) {
          message.beNotified = true
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              notificationMessages: [...meetingInfo.notificationMessages],
            },
          })
          onReceiveSessionMessage(message)
        }
      })
    } else {
      notificationApi?.destroy()
    }
  }, [meetingInfo.meetingNum])

  useEffect(() => {
    const message = meetingInfo.notificationMessages[0]
    if (
      message &&
      message.beNotified === false &&
      (meetingInfo.meetingNum || beforeMeeting)
    ) {
      message.beNotified = true
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          notificationMessages: [...meetingInfo.notificationMessages],
        },
      })
      onReceiveSessionMessage(message)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [
    notificationApi,
    t,
    meetingInfo.meetingNum,
    pluginList,
    onClickPlugin,
    isElectronSharingScreen,
    meetingInfo.notificationMessages,
    dispatch,
  ])

  useEffect(() => {
    if (customMessage) {
      if (customMessage.data) {
        const dataObj = customMessage.data as any
        const notifyCard = dataObj?.data?.notifyCard
        const type = dataObj.data.type
        if (
          notifyCard &&
          (type === 'MEETING.INVITE' || type === 'MEETING.SCHEDULE.START')
        ) {
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
        customMessage.data = dataObj
      }
      onReceiveSessionMessage(customMessage)
    }
  }, [customMessage])

  return <></>
}
export default MeetingNotification
