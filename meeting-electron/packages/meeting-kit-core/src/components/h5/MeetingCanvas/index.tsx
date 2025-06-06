import React, { useContext, useEffect, useMemo, useRef, useState } from 'react'
import { Swiper, SwiperSlide } from 'swiper/react'
import './index.less'
import { Pagination, Virtual } from 'swiper'
import 'swiper/css'
import 'swiper/css/pagination'
import VideoCard from '../../common/VideoCard'
import { NEMember, EventType } from '../../../types'
import {
  MeetingInfoContext,
  useGlobalContext,
  GlobalContext,
} from '../../../store'
import WhiteboardView from './WhiteboardView'
import { getClientType } from '../../../utils'
import { useIsAudioMode } from '../../../hooks/useAudioMode'
import AudioModeCanvas from './AudioModeCanvas'

import { Swiper as SwiperClass } from 'swiper/types'
import useActiveSpeakerManager from '../../../hooks/useActiveSpeakerManager'
import useMeetingCanvas from '../../../hooks/useMeetingCanvas'
import { useTranslation } from 'react-i18next'

interface MeetingCanvasProps {
  className?: string
  onActiveIndexChanged: (activeIndex: number) => void
}
const MeetingCanvas: React.FC<MeetingCanvasProps> = (props) => {
  const { t } = useTranslation()
  const { className, onActiveIndexChanged } = props
  // const [groupMembers, setGroupMembers] = useState<Array<NEMember[]>>([])
  const [groupNum] = useState<number>(4)
  const [fullScreenIndex, setFullScreenIndex] = useState(0)
  const { meetingInfo, memberList } = useContext(MeetingInfoContext)
  // 当前显示页面index
  const [activeIndex, setActiveIndex] = useState(0)
  const [iosTime, setIosTime] = useState(0)
  const [showPagination, setShowPagination] = useState(true)
  const { eventEmitter, showScreenShareUserVideo } = useGlobalContext()
  const [canEditWhiteboard, setCanEditWhiteboard] = useState(false)
  const memberListRef = useRef(memberList)

  memberListRef.current = memberList

  const { isAudioMode } = useIsAudioMode({
    meetingInfo,
    memberList,
  })
  const viewType = useMemo(() => {
    return meetingInfo.screenUuid ? 'screen' : 'video'
  }, [meetingInfo.screenUuid])

  useActiveSpeakerManager()

  const {
    canPreSubscribe,
    groupMembers,
    handleUnsubscribeMembers,
    clearUnsubscribeMembersTimer,
  } = useMeetingCanvas({
    isSpeaker: true,
    isSpeakerLayoutPlacementRight: false,
    isAudioMode: isAudioMode,
    groupNum,
    resizableWidth: 0,
    groupType: 'h5',
  })

  const { neMeeting } = useContext(GlobalContext)

  const swiperInstanceRef = useRef<SwiperClass | null>(null)

  useEffect(() => {
    // 屏幕共享
    if (meetingInfo.screenUuid) {
      setFullScreenIndex(0)
    }
  }, [meetingInfo.screenUuid])

  // 不在当前页的成员5s后取消订阅，如果5s内重新进入当前页则取消定时器
  useEffect(() => {
    handleUnsubscribeMembers(groupMembers, [], activeIndex)
  }, [activeIndex, groupMembers])

  // 返回第一页，解决ios滑动到页面重新回来video标签遮挡。需要重新渲染
  useEffect(() => {
    onActiveIndexChanged && onActiveIndexChanged(activeIndex)
    // 切换到非第一页，ios需要重新渲染防止video遮挡昵称
    if (activeIndex !== 0 && getClientType() === 'IOS') {
      setShowPagination(false)
      setTimeout(() => {
        setShowPagination(true)
      }, 500)
    }
  }, [activeIndex])

  useEffect(() => {
    function handleActiveSpeakerActiveChanged(info: {
      user: string
      active: boolean
    }) {
      // 需要订阅大流
      if (info.active) {
        neMeeting?.subscribeRemoteVideoStream(info.user, 0)
        clearUnsubscribeMembersTimer(info.user)
      } else {
        // 如果不在说话列表且不再当前页则取消订阅，否则订阅大流;
        const memberList = groupMembers[activeIndex]
        const member = memberList?.find((item) => {
          item.uuid === info.user
        })

        if (member) {
          neMeeting?.subscribeRemoteVideoStream(info.user, 1)
          clearUnsubscribeMembersTimer(info.user)
        } else {
          console.warn('取消订阅》》》4', info.user, info.active)
          // neMeeting?.unsubscribeRemoteVideoStream(info.user, 0)
        }
      }
    }

    if (canPreSubscribe) {
      eventEmitter?.on(
        EventType.ActiveSpeakerActiveChanged,
        handleActiveSpeakerActiveChanged
      )
      return () => {
        eventEmitter?.off(
          EventType.ActiveSpeakerActiveChanged,
          handleActiveSpeakerActiveChanged
        )
      }
    }
  }, [groupMembers, activeIndex, canPreSubscribe])

  // 在第一页，当大屏的渲染人员变更后，video标签遮挡右上角小屏要重新渲染
  useEffect(() => {
    if (activeIndex === 0) {
      setTimeout(() => {
        setIosTime(Math.random())
      }, 800)
    }
  }, [groupMembers, activeIndex])

  useEffect(() => {
    if (meetingInfo.whiteboardUuid) {
      //滚动到第一页
      setActiveIndex(0)
      if (swiperInstanceRef.current?.destroyed) {
        return
      }

      swiperInstanceRef.current?.slideTo(0)
    }
  }, [meetingInfo.whiteboardUuid])

  const enableDraw = useMemo(() => {
    return (
      meetingInfo.whiteboardUuid === meetingInfo.localMember.uuid ||
      meetingInfo.localMember.properties.wbDrawable?.value == '1'
    )
  }, [
    meetingInfo.whiteboardUuid,
    meetingInfo.localMember.uuid,
    meetingInfo.localMember.properties,
  ])

  useEffect(() => {
    if (!enableDraw) {
      setCanEditWhiteboard(false)
    }
  }, [enableDraw])

  function handleWhiteboardEdit(event) {
    event.stopPropagation()
    setCanEditWhiteboard(!canEditWhiteboard)
    // 开启白板编辑需隐藏底部分页图标
    setShowPagination(canEditWhiteboard)
  }

  function handleCardClick(
    uuid: string,
    index: number,
    event: React.MouseEvent<HTMLDivElement>
  ) {
    if (index !== fullScreenIndex) {
      event.stopPropagation()
    }

    if (meetingInfo.screenUuid === uuid) return
    setFullScreenIndex(index)
  }

  return isAudioMode ? (
    <AudioModeCanvas meetingInfo={meetingInfo} memberList={memberList} />
  ) : (
    <div className={`meeting-canvas ${className}`}>
      <Swiper
        spaceBetween={50}
        slidesPerView={1}
        modules={[Pagination, Virtual]}
        pagination={
          showPagination && !meetingInfo?.isWhiteboardTransparent
            ? { dynamicBullets: true }
            : false
        }
        virtual
        className={`meeting-canvas-swiper h-full w-full ${
          canEditWhiteboard ? 'swiper-no-swiping' : ''
        }`}
        onSwiper={(swiper) => (swiperInstanceRef.current = swiper)}
        onActiveIndexChange={(swp) => setActiveIndex(swp.activeIndex)}
      >
        {groupMembers.map((members, index: number) => {
          {
            return (
              <SwiperSlide
                className={'swiper-slide flex flex-wrap relative'}
                key={index}
                virtualIndex={index}
              >
                {/*第一页展示大小屏*/}
                {index === 0 ? (
                  meetingInfo?.whiteboardUuid &&
                  !meetingInfo.isWhiteboardTransparent ? (
                    <div>
                      {enableDraw && (
                        <>
                          {!canEditWhiteboard && (
                            <div className="nemeeting-whiteboard-mask"></div>
                          )}
                          <div
                            onClick={handleWhiteboardEdit}
                            className="nemeeting-edit-whiteboard-btn"
                          >
                            {canEditWhiteboard
                              ? t('whiteBoardPackUp')
                              : t('globalEdit')}
                          </div>
                        </>
                      )}
                      <WhiteboardView
                        className={'whiteboard-index'}
                        canEdit={canEditWhiteboard}
                      />
                    </div>
                  ) : (
                    <>
                      {meetingInfo.whiteboardUuid &&
                        meetingInfo.isWhiteboardTransparent && (
                          <div className="whiteboard-transparent                                                                                                                                                                                                                                                                       -index">
                            {enableDraw && (
                              <div
                                onClick={handleWhiteboardEdit}
                                className="nemeeting-edit-whiteboard-btn"
                              >
                                {canEditWhiteboard
                                  ? t('whiteBoardPackUp')
                                  : t('globalEdit')}
                              </div>
                            )}
                            <WhiteboardView
                              className={'whiteboard-index'}
                              canEdit={canEditWhiteboard}
                            />
                          </div>
                        )}
                      {members.map((member: NEMember, i: number) => {
                        return (
                          <VideoCard
                            isH5={true}
                            style={{
                              display: `${
                                i === 1 &&
                                ((showScreenShareUserVideo === false &&
                                  viewType === 'screen') ||
                                  (meetingInfo.isWhiteboardTransparent &&
                                    canEditWhiteboard))
                                  ? 'none'
                                  : 'block'
                              }`,
                            }}
                            isMySelf={member.uuid === meetingInfo.myUuid}
                            key={`${member.uuid}-main-${i}-${
                              i === 0 ? viewType : 'video'
                            }`}
                            showInPhoneTip={i === 0}
                            noPin={true}
                            isSubscribeVideo={index === activeIndex}
                            isMain={i === 0}
                            streamType={
                              i === 0 && i === fullScreenIndex ? 0 : 1
                            }
                            type={i === 0 ? viewType : 'video'}
                            iosTime={i !== fullScreenIndex ? iosTime : 0}
                            avatarSize={i === fullScreenIndex ? 64 : 48}
                            className={`${
                              i === fullScreenIndex
                                ? 'full-screen-card'
                                : 'small-video-card'
                            } ${
                              member.uuid === meetingInfo.localMember.uuid
                                ? 'local-member'
                                : ''
                            }`}
                            onClick={(event) =>
                              handleCardClick(member.uuid, i, event)
                            }
                            member={member}
                          />
                        )
                      })}
                    </>
                  )
                ) : (
                  members.map((member: NEMember) => {
                    return (
                      <VideoCard
                        isH5={true}
                        showBorder={
                          meetingInfo.focusUuid
                            ? meetingInfo.focusUuid === member.uuid
                            : meetingInfo.activeSpeakerUuid === member.uuid
                        }
                        streamType={1}
                        noPin={true}
                        avatarSize={48}
                        showInPhoneTip={true}
                        isSubscribeVideo={index === activeIndex}
                        isMain={false}
                        isMySelf={member.uuid === meetingInfo.myUuid}
                        key={member.uuid}
                        type={'video'}
                        style={{ height: '50%', width: '50%' }}
                        className={`w-full h-full text-white w-1/2 h-1/2`}
                        member={member}
                      />
                    )
                  })
                )}
              </SwiperSlide>
            )
          }
        })}
      </Swiper>
      {/* {meetingInfo?.whiteboardUuid && !meetingInfo.screenUuid && (
        <WhiteboardView className={'whiteboard-index'} />
      )} */}
    </div>
  )
}

export default React.memo(MeetingCanvas)
