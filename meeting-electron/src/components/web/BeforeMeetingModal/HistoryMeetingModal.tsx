import React, { useEffect, useMemo, useState } from 'react'

import { ModalProps, Space, Spin } from 'antd'
import { NERoomService } from 'neroom-web-sdk'
import { useTranslation } from 'react-i18next'
import { IPCEvent } from '../../../../app/src/types'
import EmptyImg from '../../../assets/empty.png'
import NEMeetingService from '../../../services/NEMeeting'
import { MeetingList } from '../../../types/type'
import {
  copyElementValue,
  formatDate,
  objectToQueryString,
} from '../../../utils'
import Modal from '../../common/Modal'
import Toast from '../../common/toast'
import ChatroomModal from './ChatroomModal'
import PluginAppModal from './PluginAppModal'

type MeetingSwitchType = 'all' | 'collect'

interface HistoryMeetingProps extends ModalProps {
  roomService?: NERoomService
  accountId?: string
  neMeeting?: NEMeetingService
  meetingId?: string
  onBack?: () => void
}

const HistoryMeetingModal: React.FC<HistoryMeetingProps> = ({
  roomService,
  accountId,
  neMeeting,
  ...restProps
}) => {
  const { t } = useTranslation()
  const [open, setOpen] = useState<boolean>()
  const [meetingId, setMeetingId] = useState<string>()

  useEffect(() => {
    setMeetingId(restProps.meetingId)
  }, [restProps.meetingId])

  useEffect(() => {
    setOpen(restProps.open)
  }, [restProps.open])

  return (
    <Modal
      title={<span className="modal-title">{t('historyMeeting')}</span>}
      width={375}
      maskClosable={false}
      footer={null}
      wrapClassName="history-meeting-modal"
      styles={{
        body: { padding: 0 },
      }}
      {...restProps}
      open={open}
    >
      <HistoryMeeting
        open={restProps.open}
        roomService={roomService}
        accountId={accountId}
        neMeeting={neMeeting}
        meetingId={meetingId}
        onBack={() => {
          setMeetingId(undefined)
        }}
      />
    </Modal>
  )
}

const HistoryMeeting: React.FC<HistoryMeetingProps> = ({
  open,
  roomService,
  neMeeting,
  accountId,
  meetingId,
  ...restProps
}) => {
  const { t } = useTranslation()

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
  const [meetingList, setMeetingList] = useState<MeetingList[]>([])
  const [isMore, setIsMore] = useState(true) // 是否还有数据
  const [isRequesting, setIsRequesting] = useState<boolean>(true)
  const [currentMeeting, setCurrentMeeting] = useState<MeetingList | null>(null)
  const [showDetails, setShowDetails] = useState<boolean>(false)
  const [recordList, setRecordList] = useState<string[] | null>(null)
  const [joinLoading, setJoinLoading] = useState<boolean>(false)
  const [chatroomArchiveId, setChatroomArchiveId] = useState<string>()
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
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [type, open, meetingId])

  let scrollRef

  const onScrollCapture = (e) => {
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

  const handleCopy = (event, value: any) => {
    event.stopPropagation()
    copyElementValue(value, () => {
      Toast.success(i18n.copySuccess)
    })
  }

  const handleCollect = (roomArchiveId: string, isFavorite: boolean) => {
    if (!isFavorite) {
      neMeeting
        ?.collectMeeting(roomArchiveId)
        ?.then((res) => {
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
        ?.catch((error) => {
          Toast.fail(i18n.collectFail)
        })
    } else {
      neMeeting
        ?.cancelCollectMeeting(roomArchiveId)
        ?.then((res) => {
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
        ?.catch((error) => {
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

  const getHistoryMeetingDetail = async (item: MeetingList) => {
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

  const handleItemClick = (item: MeetingList) => {
    setCurrentMeeting(item)
    setShowDetails(true)
    setRecordList(null)
    setChatroomExportAccess(0)
    setPluginInfoList([])
    getHistoryMeetingDetail(item)
  }

  const onUrlClick = (url) => {
    if (window.isElectronNative) {
      window.ipcRenderer?.invoke(IPCEvent.downloadFileByURL, url)
    } else {
      window.open(url)
    }
  }

  const MeetingDetails = useMemo(() => {
    return currentMeeting ? (
      <div className="nemeeting-details">
        {/* header */}
        <div className="nemeeting-details-header">
          <svg
            onClick={() => {
              setShowDetails(false)
              setCurrentMeeting(null)
              restProps.onBack?.()
            }}
            className={`back-icon icon`}
            aria-hidden="true"
          >
            <use xlinkHref="#iconyx-returnx"></use>
          </svg>
          {/* <div>{i18n.meetingDetails}</div> */}
        </div>
        {/* 内容 */}
        <div className="nemeeting-detail-content">
          <div className="meeting-title mb16">
            <div>{currentMeeting.subject}</div>
            <svg
              onClick={() => {
                handleCollect(
                  currentMeeting.roomArchiveId,
                  currentMeeting.isFavorite
                )
              }}
              className={`icon iconfont collect-icon ${
                currentMeeting.isFavorite ? 'iconcollecting' : 'iconcollection'
              }`}
              aria-hidden="true"
            >
              <use
                xlinkHref={`${
                  currentMeeting.isFavorite
                    ? '#iconcollecting'
                    : '#iconcollection'
                }`}
              ></use>
            </svg>
          </div>
          <div className="meeting-id mb16">
            <span className="meeting-id-content">
              {i18n.meetingNum}：{getMeetingNum(currentMeeting.meetingNum)}
            </span>
            <svg
              onClick={(e) => {
                handleCopy(e, currentMeeting.meetingNum)
              }}
              className="icon icon-blue icon-copy iconfont iconcopy1x"
              aria-hidden="true"
            >
              <use xlinkHref="#iconcopy1x"></use>
            </svg>
          </div>
          <div className="meeting-id mb16">
            <span>
              {i18n.startTime}：
              {formatDate(currentMeeting.roomStartTime, 'yyyy.MM.dd hh:mm')}
            </span>
          </div>
          <div className="meeting-id mb16">
            <span>
              {i18n.creator}：{currentMeeting.ownerNickname}
            </span>
          </div>
        </div>
        {recordList ||
        chatroomExportAccess === 1 ||
        pluginInfoList.length > 0 ? (
          <div className="nemeeting-detail-app">
            <div className="meeting-title mb16">
              <div>{i18n.app}</div>
            </div>
            {recordList && (
              <div className="nemeeting-detail-app-item">
                <div className="nemeeting-detail-app-item-title">
                  <svg className="icon iconfont" aria-hidden="true">
                    <use xlinkHref="#iconyunluzhi" />
                  </svg>
                  {i18n.record}
                </div>
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
                          className="icon icon-copy iconfont iconcopy1x"
                          aria-hidden="true"
                        >
                          <use xlinkHref="#iconcopy1x"></use>
                        </svg>
                      </div>
                    )
                  })
                )}
              </div>
            )}
            {chatroomExportAccess === 1 && (
              <div
                className="nemeeting-detail-app-item"
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
                      '*'
                    )
                  } else {
                    setChatroomArchiveId(currentMeeting.roomArchiveId)
                  }
                }}
              >
                <div className="nemeeting-detail-app-item-title">
                  <svg className="icon iconfont" aria-hidden="true">
                    <use xlinkHref="#iconchat-history" />
                  </svg>
                  {i18n.chat}
                </div>
                <svg className="icon iconfont" aria-hidden="true">
                  <use xlinkHref="#iconarrow-line-regular" />
                </svg>
              </div>
            )}
            {pluginInfoList.map((plugin) => {
              return (
                <div
                  key={plugin.pluginId}
                  className="nemeeting-detail-app-item"
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
                        '*'
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
                    <img
                      crossOrigin="anonymous"
                      className="app-icon-img"
                      src={plugin.icon.defaultIcon}
                    />
                    {plugin.name}
                  </div>
                  <svg className="icon iconfont" aria-hidden="true">
                    <use xlinkHref="#iconarrow-line-regular" />
                  </svg>
                </div>
              )
            })}
          </div>
        ) : null}
      </div>
    ) : (
      <></>
    )
  }, [
    currentMeeting,
    recordList,
    joinLoading,
    chatroomExportAccess,
    pluginInfoList,
  ])

  const MeetingContent = useMemo(() => {
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
                  {new Date().getFullYear() !== currYear ? currYear + '.' : ''}
                  {currDate}
                </div>
              )}
              <div className="meeting-list-item">
                <div
                  className="meeting-item-left"
                  onClick={() => {
                    handleItemClick(item)
                  }}
                >
                  <svg
                    className="icon iconfont iconcalendar1x"
                    aria-hidden="true"
                  >
                    <use xlinkHref="#iconcalendar1x"></use>
                  </svg>
                  {/*<i className="iconfont iconcalendar1x" />*/}
                  <div className="meeting-info">
                    <Space className="meeting-info-top">
                      <span className="moment">
                        {formatDate(item.roomEntryTime, 'hh:mm')}
                      </span>
                      <span className="sub-text">|</span>
                      <span className="sub-text">
                        {i18n.meetingNum}: {getMeetingNum(item.meetingNum)}
                        <svg
                          onClick={(e) => {
                            handleCopy(e, item.meetingNum)
                          }}
                          className="icon icon-blue icon-copy iconfont iconcopy1x"
                          aria-hidden="true"
                        >
                          <use xlinkHref="#iconcopy1x"></use>
                        </svg>
                      </span>
                    </Space>
                    <div className="subject bl-ellipsis" title={item.subject}>
                      {item.subject}
                    </div>
                    <div className="sub-text">
                      {i18n.creator}: {item.ownerNickname}
                    </div>
                  </div>
                </div>
                <span></span>

                <span
                  onClick={() => {
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
                    <use
                      xlinkHref={`${
                        item.isFavorite ? '#iconcollecting' : '#iconcollection'
                      }`}
                    ></use>
                  </svg>
                </span>
              </div>
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
      {showDetails && MeetingDetails}
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
        className="meeting-list"
        onScrollCapture={onScrollCapture}
        ref={(c) => {
          scrollRef = c
        }}
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

export { HistoryMeeting }

export default HistoryMeetingModal
