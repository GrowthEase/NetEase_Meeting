import React, { useEffect, useMemo, useState } from 'react'

import { ModalProps, Spin } from 'antd'
import { NERoomService } from 'neroom-web-sdk'
import { useTranslation } from 'react-i18next'
import { IPCEvent } from '../../../../../app/src/types'
import EmptyImg from '../../../../assets/empty.png'
import NEMeetingService from '../../../../services/NEMeeting'
import { MeetingListItem } from '../../../../types/type'
import dayjs from 'dayjs'
import {
  copyElementValue,
  formatDate,
  formatTimeWithLanguage,
  formatTimestamp,
  objectToQueryString,
} from '../../../../utils'
import Toast from '../../../common/toast'
import ChatroomModal from '../ChatroomModal'
import PluginAppModal from '../PluginAppModal'
import { EventType } from '../../../../types'
import EventEmitter from 'eventemitter3'
import UserAvatar from '../../../common/Avatar'
import timezones_zh from '../../../../locales/timezones/timezones_zh'

type MeetingSwitchType = 'all' | 'collect'

interface HistoryMeetingProps extends ModalProps {
  roomService?: NERoomService
  accountId?: string
  neMeeting: NEMeetingService
  meetingId?: string
  onBack?: () => void
  eventEmitter: EventEmitter
}

const HistoryMeeting: React.FC<HistoryMeetingProps> = ({
  open,
  roomService,
  neMeeting,
  accountId,
  meetingId,
  eventEmitter,
  ...restProps
}) => {
  const { t, i18n: i18next } = useTranslation()

  const i18n = {
    allMeeting: t('allMeeting'),
    app: t('app'),
    collectMeeting: t('collectMeeting'),
    meetingSubject: t('inviteSubject'),
    meetingDate: t('inviteTime'),
    meetingNum: t('meetingId'),
    creator: t('creator'),
    operations: t('operations'),
    collect: t('collect'),
    cancelCollect: t('cancelCollect'),
    collectSuccess: t('collectSuccess'),
    collectFail: t('collectFail'),
    cancelCollectSuccess: t('cancelCollectSuccess'),
    cancelCollectFail: t('cancelCollectFail'),
    noHistory: t('noHistory'),
    noCollect: t('noCollect'),
    copySuccess: t('copySuccess'),
    scrollEnd: t('scrollEnd'),
    meetingDetails: t('meetingDetails'),
    startTime: t('startTime'),
    recordUrl: t('cloudRecordingLink'),
    record: t('startCloudRecord'),
    chat: t('chatHistory'),
    joinMeeting: t('meetingJoin'),
    recordFileGenerating: t('generatingCloudRecordingFile'),
    endTime: t('endTime'),
    weekdays: [
      t('globalSunday'),
      t('globalMonday'),
      t('globalTuesday'),
      t('globalWednesday'),
      t('globalThursday'),
      t('globalFriday'),
      t('globalSaturday'),
    ],
    today: t('today'),
    tomorrow: t('tomorrow'),
    yesterday: t('yesterday'),
  }

  const WeekdaysSort = [
    t('globalSunday'),
    t('globalMonday'),
    t('globalTuesday'),
    t('globalWednesday'),
    t('globalThursday'),
    t('globalFriday'),
    t('globalSaturday'),
  ]

  const [type, setType] = useState<MeetingSwitchType>('all')
  const [meetingList, setMeetingList] = useState<MeetingListItem[]>([])
  const [isMore, setIsMore] = useState(true) // 是否还有数据
  const [isRequesting, setIsRequesting] = useState<boolean>(true)
  const [currentMeeting, setCurrentMeeting] = useState<MeetingListItem | null>(
    null
  )

  const [showDetails, setShowDetails] = useState<boolean>(false)
  const [recordList, setRecordList] = useState<string[] | null>(null)
  const [chatroomArchiveId, setChatroomArchiveId] = useState<number>()
  // 导出状态，1.可导出，2.没权限，3.已过期
  const [chatroomExportAccess, setChatroomExportAccess] = useState<number>(0)

  const [pluginInfoList, setPluginInfoList] = useState<any[]>([])
  const [currentPluginInfo, setCurrentPluginInfo] = useState<any>()

  useEffect(() => {
    if (open) {
      if (meetingId) {
        neMeeting
          ?.getHistoryMeeting({ meetingId })
          .then((item) => {
            setShowDetails(true)
            setCurrentMeeting(item)
            return getHistoryMeetingDetail(item)
          })
          .then(() => {
            setIsRequesting(true)
            getTableData()
          })
      } else {
        setShowDetails(false)
        setCurrentMeeting(null)
        setIsRequesting(true)
        getTableData()
      }
    } else {
      setMeetingList([])
    }
  }, [type, open, meetingId])

  let scrollRef

  const onScrollCapture = () => {
    // scrollTop会有小数点导致等式不成立，解决方案：四舍五入
    if (
      Math.round(scrollRef.scrollTop) + scrollRef.clientHeight ==
      scrollRef.scrollHeight
    ) {
      if (!isMore || isRequesting) {
        return false
      }

      setIsRequesting(true)
      getTableData(true)
    }
  }

  /**
   * @param isMore 是否为向下滚动请求更多
   * @param neeAll 是否为查询目前所有数据
   */
  const getTableData = async (isMore = false, needAll = false) => {
    const params: any = {}

    if (isMore) {
      // 接口入参的起始id为当前数据最后一条的id
      const key = type === 'all' ? 'attendeeId' : 'favoriteId'
      const startId = meetingList?.[meetingList?.length - 1]?.[key]

      typeof startId === 'number' && (params.startId = startId)
    }

    if (needAll) {
      // 接口请求条数为当前数据长度
      let total = 0

      setMeetingList((_data) => {
        total = _data?.length
        return _data
      })
      params.limit = total
    }

    const getMeetingList = async (params) => {
      const method =
        type === 'all' ? 'getHistoryMeetingList' : 'getCollectMeetingList'
      const res = await neMeeting?.[method]?.(params)
      const list = res?.[type === 'all' ? 'meetingList' : 'favoriteList']

      return (
        list?.map((item) => ({
          ...item,
          isFavorite: item.isFavorite || type === 'collect',
        })) || []
      )
    }

    try {
      const resList = await Promise.allSettled([getMeetingList(params)])
      const list = resList.flatMap((res) =>
        res.status === 'fulfilled' ? res.value : []
      )

      if (isMore) {
        setMeetingList([...meetingList, ...list])
      } else {
        setMeetingList([...list])
      }

      setIsMore(list?.length >= 20) // 服务端默认分页条数为20条
    } catch (error) {
      console.error(error)
    } finally {
      setIsRequesting(false)
    }
  }

  const handleCollect = (roomArchiveId: number, isFavorite: boolean) => {
    console.log('roomArchiveId>>>>', roomArchiveId)

    if (!isFavorite) {
      neMeeting
        ?.collectMeeting(roomArchiveId)
        ?.then(() => {
          Toast.success(i18n.collectSuccess)
          if (currentMeeting?.roomArchiveId === roomArchiveId) {
            setCurrentMeeting({ ...currentMeeting, isFavorite: true })
          }

          meetingList?.find((item) => {
            if (item.roomArchiveId === roomArchiveId) {
              item.isFavorite = true
              return item
            }
          })
          setMeetingList([...meetingList])
        })
        ?.catch(() => {
          Toast.fail(i18n.collectFail)
        })
    } else {
      neMeeting
        ?.cancelCollectMeeting(roomArchiveId)
        ?.then(() => {
          Toast.success(i18n.cancelCollectSuccess)
          if (currentMeeting?.roomArchiveId === roomArchiveId) {
            setCurrentMeeting({ ...currentMeeting, isFavorite: false })
          }

          const idx = meetingList?.findIndex(
            (item) => item.roomArchiveId === roomArchiveId
          )

          if (idx > -1) {
            if (type === 'collect') {
              meetingList?.splice(idx, 1)
            } else {
              meetingList[idx].isFavorite = false
            }

            setMeetingList([...meetingList])
          }
        })
        ?.catch(() => {
          Toast.fail(i18n.cancelCollectFail)
        })
    }
  }

  // 格式化为'x月x日 周x'
  const dateFormatting = (time) => {
    const date = formatDate(time, 'MM.dd')
    const weekDay = WeekdaysSort[new Date(time).getDay()]

    return date + ' ' + weekDay
  }

  const getMeetingNum = (num) => {
    return num.slice(0, 3) + '-' + num.slice(3, 6) + '-' + num.slice(6)
  }

  const handleCopy = (event, value: string | number) => {
    event.stopPropagation()
    copyElementValue(value, () => {
      Toast.success(i18n.copySuccess)
    })
  }

  const getHistoryMeetingDetail = async (item: MeetingListItem) => {
    neMeeting
      ?.getRoomCloudRecordList(item.roomArchiveId)
      .then((res) => {
        console.log('res>>>>>', res)
        // 没有开启录制
        if (res.code !== 0) {
          console.log('不存在')
          setRecordList(null)
        } else {
          const recordList: string[] = []
          const data = res.data

          if (data) {
            data.forEach((item) => {
              item.infoList.forEach((info) => {
                info.url && recordList.push(info.url)
              })
            })
          }

          console.log('recordList》》》', recordList)
          setRecordList(recordList)
        }
      })
      .catch((error) => {
        console.log('error>>>>', error)
        setRecordList(null)
      })
    neMeeting
      ?.getHistoryMeetingDetail({
        roomArchiveId: item.roomArchiveId,
      })
      .then((res) => {
        if (res.chatroom) {
          setChatroomExportAccess(res.chatroom.exportAccess)
        }

        if (res.pluginInfoList) {
          setPluginInfoList(res.pluginInfoList)
        }
      })
  }

  const handleItemClick = (item: MeetingListItem) => {
    setCurrentMeeting(item)
    setShowDetails(true)
    setRecordList(null)
    setChatroomExportAccess(0)
    setPluginInfoList([])
    getHistoryMeetingDetail(item)
    eventEmitter.emit(EventType.OnHistoryMeetingPageModeChanged, 'detail')
  }

  const onUrlClick = (url) => {
    if (window.isElectronNative) {
      window.ipcRenderer?.invoke(IPCEvent.downloadFileByURL, url)
    } else {
      window.open(url)
    }
  }

  console.log('meetingList>>>>', meetingList)
  console.log('currentMeeting>>>>', currentMeeting)

  const MeetingDetails = useMemo(() => {
    return currentMeeting ? (
      <div className="nemeeting-details">
        {/* header */}
        <div className="nemeeting-details-header">
          <div className="nemeeting-details-back">
            <svg
              onClick={() => {
                setShowDetails(false)
                setCurrentMeeting(null)
                restProps.onBack?.()
                eventEmitter.emit(
                  EventType.OnHistoryMeetingPageModeChanged,
                  'list'
                )
              }}
              className={`back-icon icon`}
              aria-hidden="true"
            >
              <use xlinkHref="#iconyx-returnx"></use>
            </svg>
          </div>
          <div className="meeting-subject">
            <div className="meeting-subject-content">
              {currentMeeting.subject}
            </div>
            <div className="collect-icon-wrap">
              <svg
                onClick={(e) => {
                  e.stopPropagation()
                  handleCollect(
                    currentMeeting.roomArchiveId,
                    currentMeeting.isFavorite
                  )
                }}
                className={`icon iconfont collect-icon ${
                  currentMeeting.isFavorite
                    ? 'iconcollecting'
                    : 'iconcollection'
                }`}
                aria-hidden="true"
              >
                <use xlinkHref="#iconshoucang"></use>
              </svg>
            </div>
          </div>
        </div>
        {/* 内容 */}
        <div className="nemeeting-detail-content">
          <div className="meeting-id-and-creator">
            <div className="meeting-id">
              <span className="meeting-detail-item-label">
                {i18n.meetingNum}
              </span>
              <div className="meeting-id-right">
                <span className="id">
                  {getMeetingNum(currentMeeting.meetingNum)}
                </span>
                <svg
                  onClick={(e) => {
                    handleCopy(e, currentMeeting.meetingNum)
                  }}
                  className="icon icon-blue iconfuzhi1 iconfont"
                  aria-hidden="true"
                >
                  <use xlinkHref="#iconfuzhi1"></use>
                </svg>
              </div>
            </div>
            <div className="meeting-creator">
              <span className="meeting-detail-item-label">{i18n.creator}</span>
              <span className="nick-avatar-wrap">
                <span className="meeting-creator-ownerNickname">
                  {currentMeeting.ownerNickname}
                </span>
                <span className="owner-avatar">
                  <UserAvatar
                    nickname={currentMeeting?.ownerNickname}
                    avatar={currentMeeting?.ownerAvatar}
                    size={32}
                  ></UserAvatar>
                </span>
              </span>
            </div>
          </div>
          <div className="meeting-detail-time">
            <div className="meeting-start-time">
              <div className="meeting-detail-item-label">{i18n.startTime}</div>
              <div className="meeting-start-time-right">
                {formatTimestamp(currentMeeting.roomStartTime)}
                {
                  timezones_zh[
                    currentMeeting?.timezoneId || dayjs.tz.guess()
                  ].split(' ')[0]
                }
              </div>
            </div>
            <div className="meeting-start-time">
              <div className="meeting-detail-item-label">{i18n.endTime}</div>
              <div className="meeting-start-time-right">
                {formatTimestamp(currentMeeting.roomEndTime)}
                {
                  timezones_zh[
                    currentMeeting?.timezoneId || dayjs.tz.guess()
                  ].split(' ')[0]
                }
              </div>
            </div>
          </div>
          {recordList ||
          chatroomExportAccess === 1 ||
          pluginInfoList.length > 0 ? (
            <div className="nemeeting-detail-app">
              {recordList && (
                <div className="nemeeting-record-wrap">
                  <div className="nemeeting-detail-app-item-title">
                    {i18n.record}
                  </div>
                  <div className="nemeeting-record-list">
                    {recordList.length === 0 ? (
                      <div className="record-file-generating">
                        <Spin
                          className="record-file-loading"
                          spinning={true}
                          size="small"
                        />
                        {i18n.recordFileGenerating}
                      </div>
                    ) : (
                      recordList.map((url, index) => {
                        return (
                          <div key={index} className="meeting-record-item">
                            <div
                              onClick={() => onUrlClick(url)}
                              className="meeting-record-url bl-ellipsis"
                            >
                              {url}
                            </div>
                            <svg
                              onClick={(e) => {
                                handleCopy(e, url)
                              }}
                              className="icon icon-copy iconfont iconfuzhi1"
                              aria-hidden="true"
                            >
                              <use xlinkHref="#iconfuzhi1"></use>
                            </svg>
                          </div>
                        )
                      })
                    )}
                  </div>
                </div>
              )}
              {chatroomExportAccess === 1 && (
                <div
                  className="nemeeting-detail-app-item nemeeting-detail-app-item-chat"
                  onClick={() => {
                    if (window.isElectronNative) {
                      const parentWindow = window.parent

                      parentWindow?.postMessage(
                        {
                          event: 'openWindow',
                          payload: {
                            name: 'chatWindow',
                            postMessageData: {
                              event: 'updateData',
                              payload: {
                                roomArchiveId: String(
                                  currentMeeting.roomArchiveId
                                ),
                                subject: currentMeeting.subject,
                                startTime: currentMeeting.roomStartTime,
                              },
                            },
                          },
                        },
                        parentWindow.origin
                      )
                    } else {
                      setChatroomArchiveId(currentMeeting.roomArchiveId)
                    }
                  }}
                >
                  <div className="nemeeting-detail-app-item-title">
                    {i18n.chat}
                  </div>
                  <svg
                    className="icon iconfont iconchat-history"
                    aria-hidden="true"
                  >
                    <use xlinkHref="#iconyoujiantou-16px-2"></use>
                  </svg>
                </div>
              )}
              {pluginInfoList.map((plugin) => {
                return (
                  <div
                    key={plugin.pluginId}
                    className="nemeeting-detail-app-item nemeeting-detail-app-check-in"
                    onClick={() => {
                      if (window.isElectronNative) {
                        const parentWindow = window.parent
                        const url =
                          '#/plugin?' +
                          objectToQueryString({ pluginId: plugin.pluginId })

                        parentWindow?.postMessage(
                          {
                            event: 'openWindow',
                            payload: {
                              name: plugin.pluginId,
                              url: url,
                              postMessageData: {
                                event: 'updateData',
                                payload: {
                                  pluginId: plugin.pluginId,
                                  url: plugin.homeUrl,
                                  roomArchiveId: currentMeeting.roomArchiveId,
                                  isInMeeting: false,
                                  title: plugin.name,
                                },
                              },
                            },
                          },
                          parentWindow.origin
                        )
                      } else {
                        setCurrentPluginInfo({
                          ...plugin,
                          roomArchiveId: currentMeeting.roomArchiveId,
                        })
                      }
                    }}
                  >
                    <div className="nemeeting-detail-app-item-title">
                      {plugin.name}
                    </div>
                    <svg
                      className="icon iconfont iconchat-history"
                      aria-hidden="true"
                    >
                      <use xlinkHref="#iconyoujiantou-16px-2"></use>
                    </svg>
                  </div>
                )
              })}
            </div>
          ) : null}
        </div>
      </div>
    ) : (
      <></>
    )
  }, [currentMeeting, recordList, chatroomExportAccess, pluginInfoList])

  const MeetingContent = useMemo(() => {
    function formatScheduleMeetingDateTitle(time: number) {
      const weekdays = i18n.weekdays
      const weekday =
        dayjs(time) > dayjs().startOf('day')
          ? i18n.today
          : dayjs(time) > dayjs().subtract(1, 'day').startOf('day')
          ? i18n.yesterday
          : weekdays[dayjs(time).day()]

      const date = formatTimeWithLanguage(time, i18next.language)

      return (
        <div className="history-meeting-group-date">
          <span className="weekday">{weekday}</span>
          <span className="date">{date}</span>
        </div>
      )
    }

    return (
      <>
        {meetingList?.map((item, index) => {
          const currDate = dateFormatting(item.roomEntryTime)
          const prevDate =
            index > 0
              ? dateFormatting(meetingList[index - 1].roomEntryTime)
              : null
          const currYear = new Date(item.roomEntryTime).getFullYear()

          return (
            <div key={item.roomArchiveId}>
              {currDate !== prevDate && (
                <div className="meeting-list-date">
                  <div>
                    {' '}
                    {formatScheduleMeetingDateTitle(item.roomEntryTime)}
                  </div>
                  <div>
                    {' '}
                    {new Date().getFullYear() !== currYear ? currYear : ''}
                  </div>
                </div>
              )}
              <div
                className="meeting-list-item"
                onClick={() => {
                  handleItemClick(item)
                }}
              >
                <div className="meeting-list-item-left">
                  <div
                    className="meeting-list-item-subject"
                    title={item.subject}
                    style={{
                      fontWeight:
                        window.systemPlatform === 'win32' ? 'bold' : 500,
                    }}
                  >
                    {item.subject}
                  </div>
                  <div className="meeting-list-item-detail">
                    <div className="meeting-list-item-dur">
                      {formatDate(item.roomStartTime, 'hh:mm')}-
                      {formatDate(item.roomEndTime, 'hh:mm')}
                    </div>
                    <div className="meeting-list-item-line"></div>
                    <div className="meeting-list-item-num">
                      {getMeetingNum(item.meetingNum)}
                    </div>
                    <div className="meeting-list-item-line"></div>
                    <div className="meeting-list-item-owner">
                      {item.ownerNickname}
                    </div>
                  </div>
                </div>
                <div className="meeting-list-item-right">
                  <span
                    onClick={(e) => {
                      e.stopPropagation()
                      handleCollect(item.roomArchiveId, item.isFavorite)
                    }}
                    className="collect"
                  >
                    <svg
                      className={`icon iconfont collect-icon ${
                        item.isFavorite ? 'iconcollecting' : 'iconcollection'
                      }`}
                      aria-hidden="true"
                    >
                      <use xlinkHref="#iconshoucang"></use>
                    </svg>
                  </span>
                </div>
              </div>
              <div className="bottom-line"></div>
            </div>
          )
        })}
      </>
    )
  }, [type, meetingList])

  const changeType = (type) => {
    scrollRef.scrollTop = 0
    setIsMore(true)
    setType(type)
  }

  return (
    <div className="meeting-history">
      <Spin spinning={isRequesting} className="scroll-loading" />
      {showDetails ? (
        MeetingDetails
      ) : (
        <div data-overlayscrollbars-initialize>
          <div className="meeting-type">
            <div
              onClick={() => {
                changeType('all')
              }}
              className={`meeting-type-item ${
                type === 'all' ? 'meeting-type-item-active' : ''
              }`}
            >
              {i18n.allMeeting}
            </div>
            <div
              onClick={() => {
                changeType('collect')
              }}
              className={`meeting-type-item ${
                type === 'collect' ? 'meeting-type-item-active' : ''
              }`}
            >
              {i18n.collectMeeting}
            </div>
          </div>
          <div
            ref={(c) => {
              scrollRef = c
            }}
            className="meeting-list"
            id="history-meeting-list"
            onScrollCapture={onScrollCapture}
          >
            {meetingList?.length ? (
              MeetingContent
            ) : isRequesting ? null : (
              <div className="empty-list">
                <img src={EmptyImg} alt="" />
                <div>{type === 'all' ? i18n.noHistory : i18n.noCollect}</div>
              </div>
            )}
            {meetingList?.length && !isMore ? (
              <div className="scroll-end">{i18n.scrollEnd}</div>
            ) : (
              <></>
            )}
          </div>
        </div>
      )}
      <ChatroomModal
        open={!!chatroomArchiveId}
        roomArchiveId={chatroomArchiveId}
        roomService={roomService}
        accountId={accountId}
        subject={currentMeeting?.subject}
        startTime={currentMeeting?.roomStartTime}
        onCancel={() => setChatroomArchiveId(undefined)}
      />
      <PluginAppModal
        open={!!currentPluginInfo}
        pluginInfo={currentPluginInfo}
        neMeeting={neMeeting}
        onCancel={() => setCurrentPluginInfo(undefined)}
      />
    </div>
  )
}

export default HistoryMeeting
