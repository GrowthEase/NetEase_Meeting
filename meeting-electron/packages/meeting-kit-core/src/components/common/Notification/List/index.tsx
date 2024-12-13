import dayjs from 'dayjs'
import { NECommonError, NECustomSessionMessage } from 'neroom-types'
import React, {
  forwardRef,
  useCallback,
  useEffect,
  useMemo,
  useImperativeHandle,
} from 'react'
import { useTranslation } from 'react-i18next'

import EmptyImg from '../../../../assets/empty-notification.png'
import { useGlobalContext, useMeetingInfoContext } from '../../../../store'
import { ActionType, EventType } from '../../../../types'
import Modal from '../../Modal'
import Toast from '../../toast'
import './index.less'
import NEMeetingService from '../../../../services/NEMeeting'
import EventEmitter from 'eventemitter3'
import { NEMeetingMessageChannelService } from '../../../../kit'

export interface MeetingNotificationListRef {
  handleClearAll: () => void
}

interface MeetingNotificationListProps {
  sessionIds: string[]
  onClick?: (action?: string) => void
  isH5?: boolean
  neMeeting?: NEMeetingService
  eventEmitter?: EventEmitter
  meetingMessageChannelService?: NEMeetingMessageChannelService
}

const MeetingNotificationList = forwardRef<
  MeetingNotificationListRef,
  React.PropsWithChildren<MeetingNotificationListProps>
>((props, ref) => {
  const { sessionIds, isH5, onClick } = props
  const { t } = useTranslation()
  const {
    neMeeting: neMeetingContext,
    eventEmitter: eventEmitterContext,
  } = useGlobalContext()
  const { meetingInfo, dispatch } = useMeetingInfoContext()
  const contentDomRef = React.useRef<HTMLDivElement>(null)

  const [notificationListMap, setNotificationListMap] = React.useState<
    Record<
      string,
      Array<
        NECustomSessionMessage & {
          content?: {
            data: {
              meetingId: string
              notifyCard: {
                notifyCenterCardClickAction: string
                header: {
                  icon: string
                  title: string
                  subject: string
                }
                body: {
                  title: string
                  content: string
                }
              }
              timestamp: number
            }
          }
        }
      >
    >
  >({})

  const notificationList = useMemo(() => {
    return Object.values(notificationListMap).reduce((acc, cur) => {
      return acc.concat(cur)
    }, [])
  }, [notificationListMap])

  const neMeeting = props.neMeeting || neMeetingContext
  const eventEmitter = props.eventEmitter || eventEmitterContext

  const getSessionMessagesHistory =
    props.meetingMessageChannelService?.getSessionMessagesHistory.bind(
      props.meetingMessageChannelService
    ) || neMeeting?.getSessionMessagesHistory.bind(neMeeting)

  const deleteAllSessionMessage =
    props.meetingMessageChannelService?.deleteAllSessionMessage.bind(
      props.meetingMessageChannelService
    ) || neMeeting?.deleteAllSessionMessage.bind(neMeeting)

  const fetchNotificationList = (init = false) => {
    sessionIds.forEach((sessionId) => {
      const lengthIndex = notificationListMap[sessionId]?.length - 1
      const lastMessage = notificationListMap[sessionId]?.[lengthIndex]
      const toTime = init ? Date.now() : lastMessage?.time - 1

      getSessionMessagesHistory?.({
        sessionId,
        limit: 20,
        toTime: toTime,
        searchOrder: 0,
      }).then((res) => {
        let { data: msgs } = res

        msgs = [
          ...msgs.map((msg) => {
            return {
              ...msg,
              content: msg.data ? JSON.parse(msg.data) : undefined,
            }
          }),
        ]
        setNotificationListMap((prev) => {
          return {
            ...prev,
            [sessionId]: init ? msgs : [...(prev[sessionId] || []), ...msgs],
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

  const handleClearAll = useCallback(() => {
    Modal.confirm({
      key: 'notifyCenterAllClear',
      width: 300,
      title: (
        <div
          style={{
            fontSize: 16,
            fontWeight: 500,
            textAlign: 'center',
            paddingTop: 20,
          }}
        >
          {t('notifyCenterAllClear')}
        </div>
      ),
      onOk: async () => {
        try {
          const promises = sessionIds.map((sessionId) => {
            return deleteAllSessionMessage?.(sessionId)
          })

          await Promise.all(promises)
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              notificationMessages: [],
            },
          })
          setNotificationListMap({})
        } catch (e: unknown) {
          const error = e as NECommonError

          Toast.fail(error.msg || error.message)
          throw error
        }
      },
    })
  }, [sessionIds, dispatch, t, neMeeting])

  useEffect(() => {
    if (neMeeting && sessionIds.length > 0) {
      const handleReceiveSessionMessage = () => {
        setTimeout(() => {
          fetchNotificationList(true)
        }, 1000)
      }

      fetchNotificationList(true)
      eventEmitter?.on(
        EventType.onSessionMessageReceived,
        handleReceiveSessionMessage
      )
      return () => {
        eventEmitter?.off(
          EventType.onSessionMessageReceived,
          handleReceiveSessionMessage
        )
      }
    }
  }, [sessionIds.length, eventEmitter, neMeeting])

  useEffect(() => {
    if (sessionIds.length === 0) {
      const notificationMessages = meetingInfo.notificationMessages

      if (notificationMessages.length > 0) {
        setNotificationListMap(
          notificationMessages.reduce((acc, currentItem) => {
            if (currentItem.noShowInNotificationCenter) {
              return acc
            }

            const { sessionId } = currentItem

            if (!acc[sessionId]) {
              acc[sessionId] = []
            }

            acc[sessionId].push({
              ...currentItem,
              content: currentItem.data || undefined,
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

  useImperativeHandle(
    ref,
    () => ({
      handleClearAll,
    }),
    [handleClearAll]
  )

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
                            'meeting://meeting_history' ||
                          notifyCard?.notifyCenterCardClickAction ===
                            'meeting://meeting_info'
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
          {isH5 ? null : (
            <div className="clear-all-button" onClick={handleClearAll}>
              <svg className="icon iconfont" aria-hidden="true">
                <use xlinkHref="#icontongzhiqingkong"></use>
              </svg>
            </div>
          )}
        </>
      )}
    </div>
  )
})

MeetingNotificationList.displayName = 'MeetingNotificationList'

export default MeetingNotificationList
