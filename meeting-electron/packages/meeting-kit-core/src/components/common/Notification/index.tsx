import { Button } from 'antd'
import React, {
  forwardRef,
  useEffect,
  useImperativeHandle,
  useMemo,
} from 'react'
import { useTranslation } from 'react-i18next'

import { useUpdateEffect } from 'ahooks'
import { NotificationInstance } from 'antd/es/notification/interface'
import { NECustomSessionMessage } from 'neroom-types'
import useMeetingPlugin from '../../../hooks/useMeetingPlugin'
import useNotificationHandle from '../../../hooks/useNotificationHandle'
import NEMeetingService from '../../../services/NEMeeting'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import { ActionType } from '../../../types'
import MeetingNotificationGlobalCard from '../../web/MeetingNotification/GlobalCard'
import './index.less'
import NEMeetingInviteService from '../../../kit/interface/service/meeting_invite_service'

type MeetingNotificationProps = {
  isH5?: boolean
  onClick?: (
    action: string,
    message: NECustomSessionMessage & {
      /** 是否已读 */
      unRead?: boolean
      /** 是否已经弹出通知 */
      beNotified?: boolean
      /** 是否在通知中心展示 */
      noShowInNotificationCenter?: boolean
    }
  ) => void
  beforeMeeting?: boolean
  beforeMeetingJoin?: (meetingNum: string) => void
  customMessage?: NECustomSessionMessage
  notification?: NotificationInstance
  neMeeting?: NEMeetingService
  onNotificationCardWinOpen?: (message: NECustomSessionMessage) => void
  meetingInviteService?: NEMeetingInviteService
  pluginNotifyDuration?: number
  noShowInvite?: boolean
}
export interface MeetingNotificationRef {
  addNoMoreRemindPluginIds: (pluginId: string) => void
}

const MeetingNotification = forwardRef<
  MeetingNotificationRef,
  React.PropsWithChildren<MeetingNotificationProps>
>(
  (
    {
      isH5 = false,
      onClick,
      beforeMeeting,
      customMessage,
      notification,
      neMeeting,
      beforeMeetingJoin,
      onNotificationCardWinOpen,
      meetingInviteService,
      noShowInvite,
      pluginNotifyDuration = 5000,
    },
    ref
  ) => {
    const { t } = useTranslation()
    const { notificationApi: notificationInstance } = useGlobalContext()

    const { meetingInfo, dispatch } = useMeetingInfoContext()

    const noMoreRemindPluginIdsRef = React.useRef<string[]>([])
    const { pluginList, onClickPlugin } = useMeetingPlugin()

    const localMember = meetingInfo.localMember

    const isElectronSharingScreen = useMemo(() => {
      return window.ipcRenderer && localMember.isSharingScreen
    }, [localMember.isSharingScreen])

    function onClickNotifyHandler(
      message: NECustomSessionMessage & {
        /** 是否已读 */
        unRead?: boolean
        /** 是否已经弹出通知 */
        beNotified?: boolean
        /** 是否在通知中心展示 */
        noShowInNotificationCenter?: boolean
      },
      action: string
    ) {
      onClick?.(action, message)
    }

    const notificationApi = useMemo(() => {
      return notificationInstance || notification
    }, [notificationInstance, notification])

    useNotificationHandle({
      neMeeting,
      notificationApi,
      beforeMeeting,
      isLocalSharingScreen: localMember.isSharingScreen,
      beforeMeetingJoin,
      meetingInviteService,
    })
    function onSessionMessageReceived(message: NECustomSessionMessage) {
      console.log('onSessionMessageReceived', message)

      if (meetingInfo.meetingNum || beforeMeeting) {
        try {
          const notify = message.data?.data
          const notifyCard = notify?.notifyCard
          const type = notify?.type
          const pluginId = notify?.pluginId

          if (pluginId && noMoreRemindPluginIdsRef.current.includes(pluginId)) {
            return
          }

          if (window.isElectronNative) {
            if (
              (type === 'MEETING.INVITE' ||
                type === 'MEETING.SCHEDULE.START') &&
              noShowInvite
            ) {
              return
            }

            onNotificationCardWinOpen?.(message)
          } else {
            if (notifyCard && notifyCard.popUp) {
              // h5 删除所有通知
              isH5 && notificationApi?.destroy()
              let notificationContent

              if (
                !isH5 &&
                (type === 'MEETING.INVITE' || type === 'MEETING.SCHEDULE.START')
              ) {
                if (noShowInvite) {
                  return
                }

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
                /**
                 *  配置会中插件通知弹窗持续时间，单位毫秒(ms)，默认5000ms；value=0时，不显示通知弹窗；value<0时，弹窗不自动消失。
                 */
                if (pluginNotifyDuration === 0 && type === 'PLUGIN.CUSTOM')
                  return
                let duration: number | null = 5

                if (type === 'PLUGIN.CUSTOM' && pluginNotifyDuration) {
                  duration =
                    pluginNotifyDuration < 0
                      ? null
                      : pluginNotifyDuration / 1000
                }

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

                        <div className="label">
                          {notifyCard.header?.subject}
                        </div>
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
                                    if (pluginId) {
                                      noMoreRemindPluginIdsRef.current.push(
                                        pluginId
                                      )
                                    }
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
                                    if (pluginId) {
                                      noMoreRemindPluginIdsRef.current.push(
                                        pluginId
                                      )
                                    }
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
                  duration: duration,
                  className: isH5
                    ? 'meeting-notification-h5-card-wrapper'
                    : 'meeting-notification-card-wrapper',
                  placement: isH5 ? 'bottom' : 'topRight',
                }
              }

              // // 会中不需要弹窗
              // if (type === 'MEETING.INVITE' && !beforeMeeting) {
              //   return
              // }

              notificationApi?.open(notificationContent)
            }
          }
        } catch (error) {
          console.log('onSessionMessageReceived error', error)
        }
      }
    }

    useUpdateEffect(() => {
      if (meetingInfo.meetingNum) {
        noMoreRemindPluginIdsRef.current = []
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
            onSessionMessageReceived(message)
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
        onSessionMessageReceived(message)
      }
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
          const dataObj = customMessage.data
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

        onSessionMessageReceived(customMessage)
      }
    }, [customMessage, t])

    useImperativeHandle(
      ref,
      () => ({
        addNoMoreRemindPluginIds: (pluginId: string) => {
          noMoreRemindPluginIdsRef.current.push(pluginId)
        },
      }),
      []
    )

    return <></>
  }
)

MeetingNotification.displayName = 'MeetingNotification'

export default MeetingNotification
