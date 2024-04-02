import { Button } from 'antd'
import React, { useEffect, useMemo } from 'react'
import { useTranslation } from 'react-i18next'

import { useUpdateEffect } from 'ahooks'
import { NECustomSessionMessage } from 'neroom-web-sdk/dist/types/types/messageChannelService'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import { ActionType } from '../../../types'
import { openWindow } from '../../../utils/windowsProxy'
import useMeetingPlugin from '../MeetingRightDrawer/MeetingPlugin/useMeetingPlugin'
import './index.less'

const MeetingNotification: React.FC = (props) => {
  const { t } = useTranslation()
  const { notificationApi } = useGlobalContext()

  const { meetingInfo, dispatch } = useMeetingInfoContext()

  const noMoreRemindSessionIdsRef = React.useRef<string[]>([])
  const { pluginList, onClickPlugin } = useMeetingPlugin()

  const localMember = meetingInfo.localMember

  const isElectronSharingScreen = useMemo(() => {
    return window.ipcRenderer && localMember.isSharingScreen
  }, [localMember.isSharingScreen])

  function onReceiveSessionMessage(message: NECustomSessionMessage) {
    if (
      meetingInfo.meetingNum &&
      !noMoreRemindSessionIdsRef.current.includes(message.sessionId)
    ) {
      try {
        const notify = JSON.parse(message.data)
        const notifyCard = notify?.data?.notifyCard
        if (!isElectronSharingScreen) {
          if (notifyCard && notifyCard.popUp) {
            notificationApi?.open({
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
                            if (item.action === 'meeting://no_more_remind') {
                              noMoreRemindSessionIdsRef.current.push(
                                message.sessionId
                              )
                            }
                            if (
                              item.action.startsWith('meeting://open_plugin')
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
                </div>
              ),
              description: (
                <>
                  <div className="title">{notifyCard.body?.title}</div>
                  <div className="description">{notifyCard.body?.content}</div>
                </>
              ),
              closeIcon: (
                <div className="close-icon">
                  <svg className="icon iconfont" aria-hidden="true">
                    <use xlinkHref="#iconcross"></use>
                  </svg>
                </div>
              ),
              duration: 5,
              className: 'meeting-notification-card-wrapper',
            })
          }
        } else {
          const notificationCardWin = openWindow('notificationCardWindow')
          const notificationCardWinOpenData = {
            event: 'updateNotifyCard',
            payload: {
              notifyCard,
            },
          }
          if (notificationCardWin?.firstOpen === false) {
            notificationCardWin.postMessage(notificationCardWinOpenData, '*')
          } else {
            notificationCardWin?.addEventListener('load', () => {
              notificationCardWin?.postMessage(notificationCardWinOpenData, '*')
            })
            function messageListener(e) {
              const { event, payload } = e.data
              if (event === 'notificationClick') {
                const { action } = payload
                if (action.startsWith('meeting://open_plugin')) {
                  onClickPlugin(action)
                } else if (action === 'meeting://no_more_remind') {
                  noMoreRemindSessionIdsRef.current.push(message.sessionId)
                }
              }
            }
            notificationCardWin?.addEventListener('message', messageListener)
          }
        }
      } catch {}
    }
  }

  useUpdateEffect(() => {
    if (meetingInfo.meetingNum) {
      noMoreRemindSessionIdsRef.current = []
      meetingInfo.notificationMessages.forEach((message) => {
        if (message && message.beNotified === false && meetingInfo.meetingNum) {
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
    if (message && message.beNotified === false && meetingInfo.meetingNum) {
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

  return <></>
}
export default MeetingNotification
