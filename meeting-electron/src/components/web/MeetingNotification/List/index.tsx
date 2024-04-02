import dayjs from 'dayjs'
import { NECustomSessionMessage } from 'neroom-web-sdk/dist/types/types/messageChannelService'
import React, { Dispatch, useEffect, useMemo } from 'react'
import { useTranslation } from 'react-i18next'

import EventEmitter from 'eventemitter3'
import EmptyImg from '../../../../assets/empty-notification.png'
import NEMeetingService from '../../../../services/NEMeeting'
import { useGlobalContext, useMeetingInfoContext } from '../../../../store'
import { ActionType, EventType, NEMeetingInfo } from '../../../../types'
import Modal from '../../../common/Modal'
import Toast from '../../../common/toast'
import './index.less'

interface MeetingNotificationListProps {
  neMeeting?: NEMeetingService
  meetingInfo?: NEMeetingInfo
  sessionIds: string[]
  onClick?: (action?: string) => void
  meetingInfoDispatch?: Dispatch<any>
  eventEmitter?: EventEmitter
}

const MeetingNotificationList: React.FC<MeetingNotificationListProps> = (
  props
) => {
  const { sessionIds, eventEmitter, onClick } = props
  const { t } = useTranslation()
  const { neMeeting: neMeetingContext } = useGlobalContext()
  const { meetingInfo: meetingInfoContext, dispatch: dispatchContext } =
    useMeetingInfoContext()
  const contentDomRef = React.useRef<HTMLDivElement>(null)

  const [notificationListMap, setNotificationListMap] = React.useState<
    Record<string, Array<NECustomSessionMessage & { content?: any }>>
  >({})

  const neMeeting = props.neMeeting || neMeetingContext

  const meetingInfo = props.meetingInfo || meetingInfoContext

  const dispatch = props.meetingInfoDispatch || dispatchContext

  const notificationList = useMemo(() => {
    return Object.values(notificationListMap).reduce((acc, cur) => {
      return acc.concat(cur)
    }, [])
  }, [notificationListMap])

  const fetchNotificationList = () => {
    sessionIds.forEach((sessionId) => {
      const lengthIndex = notificationListMap[sessionId]?.length - 1
      const lastMessage = notificationListMap[sessionId]?.[lengthIndex]
      neMeeting
        ?.getSessionMessagesHistory({
          sessionId,
          limit: 20,
          toTime: lastMessage?.time - 1 || Date.now(),
        })
        .then((msgs) => {
          setNotificationListMap((prev: any) => {
            return {
              ...prev,
              [sessionId]: [
                ...(prev[sessionId] || []),
                ...msgs.map((msg) => {
                  return {
                    ...msg,
                    content: msg.data ? JSON.parse(msg.data) : undefined,
                  }
                }),
              ],
            }
          })
        })
    })
  }

  const handleScroll = () => {
    const dom = contentDomRef.current
    if (!dom) return
    const { scrollTop, scrollHeight, clientHeight } = dom
    if (scrollTop + clientHeight >= scrollHeight) {
      // 加载更多
      fetchNotificationList()
    }
  }

  const handleClearAll = () => {
    Modal.confirm({
      width: 300,
      title: t('notifyCenterAllClear'),
      onOk: async () => {
        try {
          const promises = sessionIds.map((sessionId) => {
            return neMeeting?.deleteAllSessionMessage(sessionId)
          })
          await Promise.all(promises)
          fetchNotificationList()
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              notificationMessages: [],
            },
          })
          setNotificationListMap({})
        } catch (error) {
          Toast.fail(t('networkError'))
          throw error
        }
      },
    })
  }

  useEffect(() => {
    if (neMeeting && sessionIds.length > 0) {
      fetchNotificationList()
    }
  }, [sessionIds.length])

  useEffect(() => {
    if (sessionIds.length === 0) {
      const notificationMessages = meetingInfo.notificationMessages
      if (notificationMessages.length > 0) {
        setNotificationListMap(
          notificationMessages.reduce((acc, currentItem) => {
            const { sessionId } = currentItem
            if (!acc[sessionId]) {
              acc[sessionId] = []
            }
            acc[sessionId].push({
              ...currentItem,
              content: currentItem.data
                ? JSON.parse(currentItem.data)
                : undefined,
            })
            return acc
          }, {})
        )
      } else {
        setNotificationListMap({})
      }
    }
  }, [meetingInfo.notificationMessages, sessionIds])

  useEffect(() => {
    eventEmitter?.on(EventType.OnDeleteAllSessionMessage, (sessionId) => {
      setNotificationListMap((prev) => {
        delete prev[sessionId]
        return {
          ...prev,
        }
      })
    })
  }, [eventEmitter])

  return (
    <div className="notification-list-container">
      {notificationList.length === 0 ? (
        <div className="notification-list-empty">
          <img className="img" src={EmptyImg} />
          <div className="label">{t('notifyCenterNoMessage')}</div>
        </div>
      ) : (
        <>
          <div
            className="notification-list-content"
            ref={contentDomRef}
            onScroll={handleScroll}
          >
            {notificationList.map((item) => {
              const timeLabel = item.content?.data?.timestamp
                ? dayjs(item.content?.data?.timestamp).format('MM-DD HH:mm')
                : dayjs(item.time).format('MM-DD HH:mm')

              const notifyCard = item.content?.data?.notifyCard
              const meetingId = item.content?.data?.meetingId

              return notifyCard ? (
                <div className="notification-card" key={item.messageId}>
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
                    <div className="time">{timeLabel}</div>
                  </div>
                  <div className="title">{notifyCard.body?.title}</div>
                  <div className="description">{notifyCard.body?.content}</div>
                  {notifyCard?.notifyCenterCardClickAction ? (
                    <div
                      className="footer"
                      onClick={() => {
                        if (
                          notifyCard?.notifyCenterCardClickAction ===
                          'meeting://meeting_history'
                        ) {
                          onClick?.(
                            notifyCard?.notifyCenterCardClickAction +
                              '?meetingId=' +
                              meetingId
                          )
                        } else {
                          onClick?.(notifyCard?.notifyCenterCardClickAction)
                        }
                      }}
                    >
                      <div className="label">
                        {t('notifyCenterViewingDetails')}
                      </div>
                      <svg className="icon iconfont" aria-hidden="true">
                        <use xlinkHref="#iconyx-allowx"></use>
                      </svg>
                    </div>
                  ) : null}
                </div>
              ) : null
            })}
          </div>
          <div className="clear-all-button" onClick={handleClearAll}>
            <svg className="icon iconfont" aria-hidden="true">
              <use xlinkHref="#icontongzhiqingkong"></use>
            </svg>
          </div>
        </>
      )}
    </div>
  )
}
export default MeetingNotificationList
