import React, {
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react'
import VideoCard from '../../common/VideoCard'
import { Swiper, SwiperSlide } from 'swiper/react'
import { Navigation } from 'swiper'
import 'swiper/css'
import 'swiper/css/navigation'
import { MeetingInfoContext, useGlobalContext } from '../../../store'
import { groupMembersService } from '../../h5/MeetingCanvas/service'
import './index.less'
import { EventType, LayoutTypeEnum, NEMember, Role } from '../../../types'
import { useTranslation } from 'react-i18next'
import WhiteboardView from './WhiteboardView'
import { Swiper as SwiperClass } from 'swiper/types'
import { Resizable } from 're-resizable'
import classNames from 'classnames'

import useActiveSpeakerManager from '../../../hooks/useActiveSpeakerManager'
import AudioModeCanvas from './AudioModeCanvas'

interface MeetingCanvasProps {
  className?: string
  mainHeight: number
  isSpeaker: boolean
  isLocalScreen: boolean
  isAudioMode: boolean
  isFullSharingScreen: boolean
  onHandleFullSharingScreen: () => void
  wrapperWidth?: number
}

interface SmallRenderProps {
  mainHeight: number
}

const VIEW_RATIO = 16 / 9

// 正常画布显示
const BigRender: React.FC<MeetingCanvasProps> = (props) => {
  const { isSpeaker, isLocalScreen, isAudioMode } = props
  const { eventEmitter, globalConfig, neMeeting } = useGlobalContext()
  const { activeSpeakerList } = useActiveSpeakerManager()
  const {
    meetingInfo,
    memberList: originMemberList,
    dispatch,
  } = useContext(MeetingInfoContext)
  // 当前显示页面index
  const [activeIndex, setActiveIndex] = useState(0)
  const [windowInnerWidth, setWindowInnerWidth] = useState(656)
  const [windowInnerHeight, setWindowInnerHeight] = useState(368)
  const [videoViewHeight, setVideoViewHeight] = useState(95)
  const [speakerRightViewWidth, setSpeakerRightViewWidth] = useState(0)
  const [speakerRightViewHeight, setSpeakerRightViewHeight] = useState(0)
  const [resizableWidth, setResizableWidth] = useState(180)
  const [speakerTopCollapse, setSpeakerTopCollapse] = useState(false)
  const [speakerRightCollapse, setSpeakerRightCollapse] = useState(false)
  const [swiperWidth, setSwiperWidth] = useState<'100%' | number>('100%')
  const [maxResizableWidth, setMaxResizableWidth] = useState(0)
  // const [activeSpeakerList, setActiveSpeakerList] = useState<string[]>([])
  const isSpeakerRef = useRef<boolean>(isSpeaker)
  // const [speakerRightViewColumnNum, setSpeakerRightViewColumnNum] = useState(1)
  const swiperInstanceRef = useRef<SwiperClass | null>(null)
  isSpeakerRef.current = isSpeaker

  const isSpeakerLayoutPlacementRight =
    isSpeaker && meetingInfo.speakerLayoutPlacement === 'right'

  const hideNoVideoMembers =
    meetingInfo.localMember.properties?.hideNoVideoMembers?.value === '1'

  const memberList = useMemo(() => {
    if (hideNoVideoMembers) {
      const list = originMemberList.filter(
        (item) => item.isVideoOn || item.isSharingScreen
      )
      return list.length > 0 ? list : [meetingInfo.localMember]
    }
    return originMemberList
  }, [hideNoVideoMembers, originMemberList, meetingInfo.localMember])

  const showCollapseBtn = useMemo(() => {
    if (
      memberList.length === 1 ||
      meetingInfo.whiteboardUuid ||
      meetingInfo.localMember.isSharingScreen
    ) {
      return false
    }
    return isSpeaker
  }, [
    memberList.length,
    meetingInfo.whiteboardUuid,
    isSpeaker,
    meetingInfo.localMember.isSharingScreen,
  ])

  const onResize = useCallback((entries: ResizeObserverEntry[]) => {
    for (const entry of entries) {
      const { width, height } = entry.contentRect
      setWindowInnerWidth(width)
      setWindowInnerHeight(height)
    }
  }, [])

  function getVideoViewSize(params: {
    lineNum: number
    columnNum: number
    windowInnerWidth: number
    windowInnerHeight: number
  }) {
    const { lineNum, columnNum, windowInnerHeight, windowInnerWidth } = params
    // 宽高比大于16：9使用高作为基准
    const viewWidth = windowInnerWidth / columnNum
    const viewHeight = windowInnerHeight / lineNum
    let height = Math.floor(viewHeight)
    let width = Math.floor(viewWidth)
    if (viewWidth / viewHeight > VIEW_RATIO) {
      width = Math.floor(viewHeight * VIEW_RATIO)
    } else {
      height = Math.floor(viewWidth / VIEW_RATIO)
    }

    return {
      width,
      height,
    }
  }

  useEffect(() => {
    const wrapDom = document.querySelector('.nemeeting-canvas-web')
    let observer: ResizeObserver
    if (wrapDom) {
      setWindowInnerWidth(wrapDom.clientWidth)
      setWindowInnerHeight(wrapDom.clientHeight)
      observer = new ResizeObserver(onResize)
      observer.observe(wrapDom)
    }

    return () => {
      if (wrapDom && observer) {
        observer.unobserve(wrapDom)
        observer.disconnect()
      }
    }
  }, [])

  const isSpeakerFull = useMemo(() => {
    if (
      meetingInfo.layout === LayoutTypeEnum.Gallery ||
      meetingInfo.whiteboardUuid
    ) {
      return false
    }
    return isSpeakerLayoutPlacementRight
      ? speakerRightCollapse
      : speakerTopCollapse
  }, [
    isSpeakerLayoutPlacementRight,
    speakerRightCollapse,
    speakerTopCollapse,
    meetingInfo.layout,
    meetingInfo.whiteboardUuid,
  ])

  const viewType = useMemo(() => {
    return !!meetingInfo.screenUuid ? 'screen' : 'video'
  }, [meetingInfo.screenUuid])

  const isHost =
    meetingInfo.localMember.role === Role.host ||
    meetingInfo.localMember.role === Role.coHost

  const groupNum = useMemo(() => {
    let groupNum = 4
    if (isSpeakerLayoutPlacementRight) {
      groupNum = 6
      if (resizableWidth > 340) {
        groupNum = 4
      }
      if (resizableWidth > 500) {
        groupNum = 9
      }
      if (resizableWidth > 660) {
        groupNum = 16
      }
    }
    return groupNum
  }, [resizableWidth, isSpeakerLayoutPlacementRight])

  // 对成员列表进行排序
  const groupMembers = useMemo(() => {
    if (isAudioMode) {
      // 如果是音频模式则所有成员都在一页不用分页;
      return [memberList]
    } else {
      return groupMembersService({
        memberList,
        groupNum: isSpeaker ? groupNum : 16,
        screenUuid: meetingInfo.screenUuid,
        focusUuid: meetingInfo.focusUuid,
        myUuid: meetingInfo.localMember.uuid,
        activeSpeakerUuid: meetingInfo.lastActiveSpeakerUuid || '',
        groupType: 'web',
        enableSortByVoice: !!meetingInfo.enableSortByVoice,
        layout: isSpeaker ? LayoutTypeEnum.Speaker : LayoutTypeEnum.Gallery,
        whiteboardUuid: meetingInfo.whiteboardUuid,
        isWhiteboardTransparent: meetingInfo.isWhiteboardTransparent,
      })
    }
  }, [
    memberList,
    memberList.length,
    meetingInfo.hostUuid,
    meetingInfo.focusUuid,
    meetingInfo.activeSpeakerUuid,
    meetingInfo.screenUuid,
    meetingInfo.whiteboardUuid,
    meetingInfo.layout,
    isSpeaker,
    meetingInfo.lastActiveSpeakerUuid,
    meetingInfo.isWhiteboardTransparent,
    resizableWidth,
    isSpeakerLayoutPlacementRight,
    groupNum,
    isAudioMode,
  ])
  // 获取画布行数和列数
  function getLineNumAndColumnNum(memberCount: number) {
    // 一行存放几个视图
    let splitNum = 1
    if (memberCount >= 2 && memberCount <= 4) {
      splitNum = 2
    } else if (memberCount >= 5 && memberCount <= 9) {
      splitNum = 3
    } else if (memberCount >= 10) {
      splitNum = 4
    }
    // 计算目前视图数量需要几行排放
    const count = Math.ceil(Math.min(memberCount, 16) / splitNum)
    return {
      lineNum: count,
      columnNum: splitNum,
    }
  }
  useEffect(() => {
    setActiveIndex(0)
    // 切换到画廊模式需要设置下每个画布宽高比为16:9
    if (!isSpeaker && !isAudioMode) {
      if (swiperInstanceRef.current?.destroyed) {
        return
      }
      swiperInstanceRef.current?.slideTo(0)
      // 当画布切换的时候，元素还没有重新设置成新的宽度，造成第一次切换比列不对，需要手动算一次
      const swiperDom = document.querySelector('.nemeeting-canvas-web')
      if (swiperDom) {
        const memberCount = memberList.length
        // 获取画布对应几行和几列
        calculateViewSize({ memberCount, windowInnerHeight, windowInnerWidth })
      }
    }
  }, [isSpeaker, isAudioMode])
  // 是否能够提前订阅
  const canPreSubscribe = useMemo(() => {
    console.log(
      'canPreSubscribe',
      globalConfig?.appConfig.MEETING_CLIENT_CONFIG?.activeSpeakerConfig,
      isSpeaker,
      !meetingInfo.focusUuid
    )
    return (
      globalConfig?.appConfig.MEETING_CLIENT_CONFIG?.activeSpeakerConfig
        .enableVideoPreSubscribe &&
      isSpeaker &&
      !meetingInfo.focusUuid
    )
  }, [globalConfig?.appConfig, isSpeaker, meetingInfo.focusUuid])

  useEffect(() => {
    if (isSpeakerRef.current && !isSpeakerLayoutPlacementRight) {
      setSwiperWidth(windowInnerWidth * 0.6)
      return
    }
    const memberList = groupMembers[activeIndex]
    // 获取画布对应几行和几列
    calculateViewSize({
      memberCount: memberList?.length,
      windowInnerHeight,
      windowInnerWidth,
    })
  }, [
    windowInnerWidth,
    windowInnerHeight,
    groupMembers,
    activeIndex,
    isSpeakerLayoutPlacementRight,
  ])

  function calculateViewSize(params: {
    memberCount: number
    windowInnerWidth: number
    windowInnerHeight: number
  }) {
    const { memberCount, windowInnerHeight, windowInnerWidth } = params
    // 获取画布对应几行和几列
    const { lineNum, columnNum } = getLineNumAndColumnNum(memberCount)
    const { width, height } = getVideoViewSize({
      lineNum,
      columnNum,
      windowInnerWidth,
      windowInnerHeight,
    })
    setVideoViewHeight(height)
    // 加20宽度，否则会出现父容器宽度跟不上里面画面宽度，造成竖向排列
    setSwiperWidth(width * columnNum + 20)
  }

  function handleCollapse() {
    if (isSpeakerLayoutPlacementRight) {
      setSpeakerRightCollapse(!speakerRightCollapse)
    } else {
      setSpeakerTopCollapse(!speakerTopCollapse)
    }
  }

  const videoCardViewHeight = useMemo(() => {
    return isAudioMode ? 128 : videoViewHeight
  }, [isAudioMode, videoViewHeight])

  const videoViewWidth = useMemo(() => {
    return isAudioMode ? 102 : Math.floor(videoViewHeight * VIEW_RATIO)
  }, [videoViewHeight, isAudioMode])

  // 高度如果是演讲者模式，则宽高比16:9，否则100%
  const swiperHeight = useMemo(() => {
    return swiperWidth === '100%' ? '100%' : (swiperWidth * 0.25) / VIEW_RATIO
  }, [swiperWidth, isSpeaker])

  // 顶部成员画面
  const sliderGroupMembers = useMemo(() => {
    let sliderGroupMembers =
      isSpeaker &&
      (!meetingInfo.whiteboardUuid || meetingInfo.isWhiteboardTransparent)
        ? groupMembers.slice(1)
        : groupMembers
    if (groupMembers.length === 1 && !!meetingInfo.screenUuid) {
      sliderGroupMembers = groupMembers
    }
    return sliderGroupMembers
  }, [
    groupMembers,
    isSpeaker,
    meetingInfo.screenUuid,
    meetingInfo.whiteboardUuid,
    meetingInfo.isWhiteboardTransparent,
  ])

  useEffect(() => {
    function handleActiveSpeakerActiveChanged(info: {
      user: string
      active: boolean
    }) {
      // 需要订阅大流
      if (info.active) {
        console.warn('开始订阅大流>>>>>', info.user)
        neMeeting?.rtcController?.subscribeRemoteVideoStream(info.user, 0)
      } else {
        // 如果不在说话列表且不再当前页则取消订阅，否则订阅大流;
        const memberList = sliderGroupMembers[activeIndex]
        const member = memberList.find((item) => {
          item.uuid === info.user
        })
        console.warn('取消订阅大流>>>>>', member, info.user)
        if (member) {
          neMeeting?.rtcController?.subscribeRemoteVideoStream(info.user, 1)
        } else {
          neMeeting?.rtcController?.unsubscribeRemoteVideoStream(info.user, 0)
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
  }, [sliderGroupMembers, activeIndex, canPreSubscribe])

  // 主画面成员
  const mainMember = useMemo(() => {
    return groupMembers[0]?.[0] || meetingInfo.localMember
  }, [groupMembers])

  // 是否显示顶部成员列表
  let isShowSlider =
    (sliderGroupMembers.length > 0 && !isLocalScreen) ||
    (!!meetingInfo.whiteboardUuid &&
      meetingInfo.enableTransparentWhiteboard &&
      sliderGroupMembers.length > 0)

  if (hideNoVideoMembers && isSpeaker) {
    isShowSlider =
      sliderGroupMembers[0]?.filter((item) => item.isVideoOn).length > 0
  }

  // 是否显示主画面
  const isShowMainVideo =
    isSpeaker &&
    !meetingInfo.screenUuid &&
    !mainMember?.hide &&
    (!meetingInfo.whiteboardUuid || meetingInfo.isWhiteboardTransparent)

  const isElectronSharingScreen = useMemo(() => {
    return window.ipcRenderer && meetingInfo.localMember.isSharingScreen
  }, [meetingInfo.localMember.isSharingScreen])

  useEffect(() => {
    if (
      (!sliderGroupMembers[activeIndex] ||
        sliderGroupMembers[activeIndex].length === 0) &&
      activeIndex > 0
    ) {
      setActiveIndex(activeIndex - 1)
    }
  }, [sliderGroupMembers, activeIndex])

  useEffect(() => {
    if (isSpeakerLayoutPlacementRight && !isElectronSharingScreen) {
      const wrapper = document.querySelector('#nemeeting-canvas-web')
      function resize() {
        const groupMembers = sliderGroupMembers[activeIndex]
        if (wrapper && groupMembers) {
          const length = groupMembers.length
          const wrapperHeight = wrapper.clientHeight
          let width = resizableWidth - 20
          if (groupNum === 6 || length < 2) {
            const maxHeight = wrapperHeight / length
            const maxWidth = maxHeight * VIEW_RATIO
            if (width > maxWidth) {
              width = maxWidth
            }
          } else if (groupNum === 4 || length < 4) {
            const maxHeight = wrapperHeight / 2
            const maxWidth = maxHeight * VIEW_RATIO
            width = width / 2
            if (width > maxWidth) {
              width = maxWidth
            }
          } else if (groupNum === 9 || length < 9) {
            const maxHeight = wrapperHeight / 3
            const maxWidth = maxHeight * VIEW_RATIO
            width = width / 3
            if (width > maxWidth) {
              width = maxWidth
            }
          } else if (groupNum === 16 || length < 16) {
            const maxHeight = wrapperHeight / 4
            const maxWidth = maxHeight * VIEW_RATIO
            width = width / 4
            if (width > maxWidth) {
              width = maxWidth
            }
          }
          if (width >= 160) {
            setSpeakerRightViewWidth(width)
            setSpeakerRightViewHeight(width / VIEW_RATIO)
          }
        }
        return resizableWidth
      }
      resize()
      const ro = new ResizeObserver((entries) => {
        if (entries.length > 0) {
          if (wrapper && wrapper.clientWidth > 600) {
            if (resizableWidth > wrapper.clientWidth - 160) {
              setResizableWidth(wrapper.clientWidth - 160)
            }
            setMaxResizableWidth(wrapper.clientWidth - 160)
            resize()
          }
        }
      })
      ro.observe(wrapper as HTMLElement)
      return () => {
        ro.unobserve(wrapper as HTMLElement)
      }
    } else {
      setMaxResizableWidth(0)
    }
  }, [
    resizableWidth,
    sliderGroupMembers,
    activeIndex,
    groupNum,
    meetingInfo.screenUuid,
    isSpeakerLayoutPlacementRight,
    isElectronSharingScreen,
  ])

  useEffect(() => {
    setActiveIndex(0)
  }, [meetingInfo.layout, meetingInfo.speakerLayoutPlacement])

  const speakerRightViewColumnNum = useMemo(() => {
    const length = sliderGroupMembers[activeIndex]?.length
    if (groupNum === 6 || length < 2) {
      return 1
    } else if (groupNum === 4 || length < 4) {
      return 2
    } else if (groupNum === 9 || length < 9) {
      return 3
    } else if (groupNum === 16 || length < 16) {
      return 4
    }
    return 1
  }, [groupNum, sliderGroupMembers, activeIndex])

  return isElectronSharingScreen ? null : isAudioMode ? ( // 音频模式
    <AudioModeCanvas
      meetingInfo={meetingInfo}
      memberList={memberList.filter((item) => {
        return !hideNoVideoMembers || item.isVideoOn
      })}
    />
  ) : (
    <>
      {isShowSlider && !isSpeakerFull && (
        <Resizable
          enable={isSpeakerLayoutPlacementRight ? { left: true } : false}
          className={`nemeeting-swiper-slider ${
            isSpeaker ? 'speaker-slider' : 'gallery-slider'
          }  swiper-view-wrap`}
          size={{
            width: isSpeakerLayoutPlacementRight ? resizableWidth : '100%',
            height: `${
              isSpeaker && !isSpeakerLayoutPlacementRight
                ? swiperHeight + 'px'
                : '100%'
            }`,
          }}
          minWidth={isSpeakerLayoutPlacementRight ? 180 : 0}
          maxWidth={maxResizableWidth || '100%'}
          handleStyles={{
            left: {
              zIndex: 999,
            },
          }}
          onResize={(e, direction, ref, d) => {
            setResizableWidth(ref.clientWidth)
          }}
          style={
            {
              // background: window.isElectronNative ? 'transparent' : undefined,
            }
          }
        >
          <div className="nemeeting-slider-resizable-indicate" />
          <div
            className={'h-full neswiper-wrap'}
            style={{
              width: `${swiperWidth === '100%' ? '100%' : swiperWidth + 'px'}`,
            }}
          >
            {/*左右切换视图按钮-左*/}
            {/*左右切换视图按钮*/}
            <>
              <div
                id={'meetingSwiperButtonPrev'}
                className={classNames('slider-button-prev', {
                  'slider-button-gallery-prev': !isSpeaker,
                  'slider-button-speaker-right-prev':
                    isSpeakerLayoutPlacementRight,
                  'meeting-swiper-button-disabled':
                    activeIndex === 0 || sliderGroupMembers.length <= 1,
                })}
                onClick={() => {
                  setActiveIndex(activeIndex - 1)
                }}
              />
              <div
                id={'meetingSwiperButtonNext'}
                className={classNames('slider-button-next', {
                  'slider-button-gallery-next': !isSpeaker,
                  'slider-button-speaker-right-next':
                    isSpeakerLayoutPlacementRight,
                  'meeting-swiper-button-disabled':
                    activeIndex === sliderGroupMembers.length - 1 ||
                    sliderGroupMembers.length <= 1,
                })}
                onClick={() => {
                  setActiveIndex(activeIndex + 1)
                }}
              />
            </>

            <Swiper
              // spaceBetween={50}
              // slidesPerView={1}
              onSwiper={(swiper) => (swiperInstanceRef.current = swiper)}
              /*
              navigation={{
                prevEl: '#meetingSwiperButtonPrev',
                nextEl: '#meetingSwiperButtonNext',
                disabledClass: 'meeting-swiper-button-disabled',
              }}
              */
              modules={[Navigation]}
              className={'meeting-canvas-swiper-web swiper-no-swiping'}
              /*
              onActiveIndexChange={(swp) => {
                setActiveIndex(swp.activeIndex)
              }}
              */
            >
              {sliderGroupMembers.map((members, index) => {
                const filterMembers =
                  members?.filter(
                    (item) =>
                      !hideNoVideoMembers ||
                      item.isVideoOn ||
                      members.length === 1
                  ) || []

                return index === activeIndex ? (
                  <SwiperSlide
                    className={classNames('nemeeting-swiper-slide', {
                      ['nemeeting-swiper-slide-widescreen']:
                        !isSpeakerLayoutPlacementRight,
                    })}
                    key={index + meetingInfo.layout + hideNoVideoMembers}
                    style={
                      isSpeakerLayoutPlacementRight
                        ? {
                            width:
                              speakerRightViewColumnNum *
                                speakerRightViewWidth +
                              20,
                          }
                        : undefined
                    }
                  >
                    {filterMembers.map((member, i) => {
                      const needPreSubscribe =
                        canPreSubscribe &&
                        activeSpeakerList.includes(member.uuid)
                      return (
                        <VideoCard
                          mirroring={
                            meetingInfo.enableVideoMirror &&
                            member?.uuid === meetingInfo.myUuid
                          }
                          isAudioMode={isAudioMode}
                          avatarSize={isSpeaker ? 32 : 48}
                          showBorder={
                            isSpeaker
                              ? false
                              : meetingInfo.focusUuid
                              ? meetingInfo.focusUuid === member.uuid
                              : meetingInfo.showSpeaker
                              ? meetingInfo.activeSpeakerUuid === member.uuid
                              : false
                          }
                          isSubscribeVideo={
                            index == activeIndex || needPreSubscribe
                          }
                          isMain={false}
                          streamType={
                            isSpeaker
                              ? needPreSubscribe
                                ? 0
                                : 1
                              : members.length > 3
                              ? 1
                              : 0
                          }
                          isMySelf={member.uuid === meetingInfo.myUuid}
                          sliderMembersLength={filterMembers.length}
                          key={member.uuid}
                          type={'video'}
                          className={`h-full text-white nemeeting-video-card video-card card-for-${members.length}`}
                          member={member}
                          style={
                            isSpeakerLayoutPlacementRight
                              ? {
                                  height: speakerRightViewHeight,
                                  width: speakerRightViewWidth,
                                }
                              : !isSpeaker
                              ? {
                                  height:
                                    members.length === 1
                                      ? '100%'
                                      : videoViewHeight + 'px',
                                  width:
                                    members.length === 1
                                      ? '100%'
                                      : videoViewWidth + 'px',
                                }
                              : undefined
                          }
                        />
                      )
                    })}
                  </SwiperSlide>
                ) : null
              })}
            </Swiper>
          </div>
        </Resizable>
      )}
      {isSpeaker && (
        <div className={`w-full nemeeting-main-view`}>
          {showCollapseBtn && (
            <div
              className={classNames('nemeeting-main-view-collapse-allow', {
                ['top']: !isSpeakerLayoutPlacementRight,
                ['right']: isSpeakerLayoutPlacementRight,
                ['collapse']: isSpeakerFull,
              })}
              onClick={handleCollapse}
            >
              <svg className={classNames('icon iconfont')} aria-hidden="true">
                <use
                  xlinkHref={
                    isSpeakerLayoutPlacementRight
                      ? '#iconyx-allowx'
                      : '#iconcollapse'
                  }
                ></use>
              </svg>
            </div>
          )}
          {isShowMainVideo &&
            //防止复用共享屏幕video标签使逻辑变复杂，所以使用数组渲染
            [mainMember].map((member) => {
              return (
                <VideoCard
                  mirroring={
                    meetingInfo.enableVideoMirror &&
                    !(
                      meetingInfo.isWhiteboardTransparent &&
                      !!meetingInfo.whiteboardUuid &&
                      meetingInfo.whiteboardUuid === meetingInfo.myUuid
                    ) &&
                    member?.uuid === meetingInfo.myUuid
                  }
                  showBorder={false}
                  isSubscribeVideo={true}
                  isMain={true}
                  isMySelf={member?.uuid === meetingInfo.myUuid}
                  key={member?.uuid}
                  type={'video'}
                  className={`w-full h-full text-white bg-black`}
                  member={member}
                  avatarSize={64}
                  canShowCancelFocusBtn={
                    member?.uuid == meetingInfo.focusUuid && isHost
                  }
                  focusBtnClassName="focus-tp-normal"
                />
              )
            })}
          {meetingInfo.screenUuid && !meetingInfo.whiteboardUuid && (
            <div className="screen-video-wrap">
              <VideoCard
                showBorder={false}
                isSubscribeVideo={true}
                isMain={true}
                isMySelf={mainMember.uuid === meetingInfo.myUuid}
                key={mainMember.uuid}
                type={'screen'}
                className={`w-full h-full text-white bg-black`}
                member={mainMember}
                avatarSize={64}
              />
            </div>
          )}

          {!!meetingInfo.whiteboardUuid && !meetingInfo.screenUuid && (
            <WhiteboardView
              isEnable={!!meetingInfo.whiteboardUuid && !meetingInfo.screenUuid}
              className={
                meetingInfo.enableFixedToolbar
                  ? ''
                  : 'nemeeting-whiteboard-custom'
              }
            />
          )}
        </div>
      )}
    </>
  )
}

// 小画面显示（适用于面试间）
const SmallRender: React.FC<SmallRenderProps> = ({ mainHeight }) => {
  const [isShowMyVideo, setIsShowMyVideo] = useState(true)
  const { meetingInfo, memberList } = useContext(MeetingInfoContext)
  const { t } = useTranslation()
  let otherMember: NEMember | undefined
  if (memberList.length > 1) {
    otherMember = memberList[0]
    // 如果第一个用户是本端则去第二项
    if (otherMember.uuid === meetingInfo.localMember.uuid) {
      otherMember = memberList[1]
    }
  }

  return (
    <div className={'meeting-small-layout'}>
      <div className={'other-hasin'}>
        {memberList.length > 1 && otherMember ? (
          <VideoCard
            showBorder={false}
            isSubscribeVideo={true}
            isMain={true}
            isMySelf={false}
            key={otherMember.uuid}
            type={'video'}
            className={`w-full h-full text-white`}
            member={otherMember}
          />
        ) : (
          <p>{t('notJoinedMeeting')}</p>
        )}
      </div>
      {isShowMyVideo && (
        <div className={'self-hasin'}>
          <VideoCard
            showBorder={false}
            isSubscribeVideo={true}
            isMain={true}
            isMySelf={true}
            key={meetingInfo.myUuid}
            type={'video'}
            className={`w-full h-full text-white`}
            member={meetingInfo.localMember}
          />
        </div>
      )}
    </div>
  )
}
const MeetingCanvas: React.FC<MeetingCanvasProps> = (props) => {
  const {
    className,
    mainHeight,
    isSpeaker,
    isFullSharingScreen,
    isLocalScreen,
    onHandleFullSharingScreen,
    isAudioMode,
  } = props
  const { meetingInfo } = useContext(MeetingInfoContext)

  const containerClassName = classNames('nemeeting-canvas-web', className, {
    'speaker-layout-right':
      isSpeaker && meetingInfo.speakerLayoutPlacement === 'right',
  })

  const isWin = window.systemPlatform === 'win32'

  return (
    <>
      {/*渲染大画面还是小画面形式*/}
      {meetingInfo.renderModel === 'small' ? (
        <div className={containerClassName}>
          <SmallRender mainHeight={mainHeight} />
        </div>
      ) : (
        <div
          id="nemeeting-canvas-web"
          className={containerClassName}
          style={{ background: isWin ? 'rgba(0,0,0,0.01)' : 'rgba(0,0,0,0)' }}
        >
          <BigRender
            onHandleFullSharingScreen={() => onHandleFullSharingScreen()}
            mainHeight={mainHeight}
            isAudioMode={isAudioMode}
            isSpeaker={isSpeaker}
            isLocalScreen={isLocalScreen}
            isFullSharingScreen={isFullSharingScreen}
          />
        </div>
      )}
    </>
  )
}

export default React.memo(MeetingCanvas)
