import React, { useCallback, useEffect, useRef, useState } from 'react'
import VideoCard from '../../common/VideoCard'
import { NEMeetingInfo, NEMember } from '../../../types'
import { Swiper, SwiperSlide } from 'swiper/react'
import { Navigation } from 'swiper'
import { debounce } from '../../../utils'
import classNames from 'classnames'
import useAudioMode from '../../../hooks/useAudioMode'

interface AudioModeCanvasProps {
  meetingInfo: NEMeetingInfo
  memberList: NEMember[]
  onCallClick?: (member: NEMember) => void
}

const defaultColumnWidth = 102
const defaultColumnHeight = 128

const AudioModeCanvas: React.FC<AudioModeCanvasProps> = ({
  memberList,
  meetingInfo,
  onCallClick,
}) => {
  const audioModeRef = useRef<HTMLDivElement | null>(null)
  const audioModeWrapRef = useRef<HTMLDivElement | null>(null)
  const [preAndNextBtnOffset, setPreAndNextBtnOffset] = useState(0)

  // const masonryRef = useRef<any>(null)

  const {
    groupMemberList,
    activeIndex,
    setColumnCount,
    setLineCount,
    setActiveIndex,
    swiperInstanceRef,
  } = useAudioMode({
    meetingInfo,
    memberList,
  })

  const calculateColumnCountAndLineCount = useCallback(
    (width: number, height: number) => {
      // 48是左右上下padding
      width = width + 48
      height = height + 48

      let columnCount = 7
      let lineCount = 3

      /**
       * 如果宽度在960~1360之间，每行放7个
       * 如果宽度在1360~1760之间，每行放10个
       * 如果宽度大于1760，每行放12个
       */
      if (width <= 1360) {
        columnCount = 7
      } else if (width <= 1760) {
        columnCount = 10
      } else if (width > 1760) {
        columnCount = 12
      }

      setColumnCount(columnCount)
      setPreAndNextBtnOffset(
        Math.max((width - columnCount * defaultColumnWidth) / 2 - 90, 0)
      )
      /**
       * 高度在640~840之间，每列放3个
       * 高度在1360~1760之间，每列放4个
       * 高度大于1040，每列放5个
       */
      if (height <= 840) {
        lineCount = 3
      } else if (height <= 1040) {
        lineCount = 4
      } else if (height > 1040) {
        lineCount = 5
      }

      setLineCount(lineCount)
    },

    []
  )

  const onResize = useCallback(
    (entries: ResizeObserverEntry[]) => {
      for (const entry of entries) {
        const { width, height } = entry.contentRect

        calculateColumnCountAndLineCount(width, height)
      }
    },
    [calculateColumnCountAndLineCount]
  )

  useEffect(() => {
    const wrapDom = audioModeWrapRef.current
    let observer: ResizeObserver
    const debounceOnResize = debounce(onResize, 100)

    if (wrapDom) {
      observer = new ResizeObserver(debounceOnResize)
      observer.observe(wrapDom)
    }

    return () => {
      if (wrapDom && observer) {
        observer.unobserve(wrapDom)
        observer.disconnect()
      }
    }
  }, [onResize])

  return (
    <div
      className={'gallery-slider swiper-view-wrap nemeeting-audio-mode-wrap'}
      ref={audioModeWrapRef}
    >
      <div
        ref={audioModeRef}
        className="nemeeting-swiper-slider nemeeting-audio-mode"
      >
        {/*左右切换视图按钮-左*/}
        {/*左右切换视图按钮*/}
        <>
          <div
            id={'meetingSwiperButtonPrev'}
            className={classNames(
              'slider-button-prev slider-button-gallery-prev nemeting-aduio-mode-swiper-btn',
              {
                'meeting-swiper-button-disabled':
                  activeIndex === 0 || groupMemberList.length <= 1,
              }
            )}
            style={{ left: preAndNextBtnOffset + 'px' }}
            onClick={() => {
              setActiveIndex(activeIndex - 1)
            }}
          />
          <div
            id={'meetingSwiperButtonNext'}
            className={classNames(
              'slider-button-next slider-button-gallery-next nemeting-aduio-mode-swiper-btn',
              {
                'meeting-swiper-button-disabled':
                  activeIndex === groupMemberList.length - 1 ||
                  groupMemberList.length <= 1,
              }
            )}
            style={{ right: preAndNextBtnOffset + 'px' }}
            onClick={() => {
              setActiveIndex(activeIndex + 1)
            }}
          />
        </>
        <Swiper
          onSwiper={(swiper) => (swiperInstanceRef.current = swiper)}
          modules={[Navigation]}
          className={'meeting-canvas-swiper-web swiper-no-swiping'}
        >
          {groupMemberList.map((lineMembers, index) => {
            return index === activeIndex ? (
              <SwiperSlide className={'nemeeting-swiper-slide'} key={index}>
                {lineMembers.map((members, i) => {
                  return (
                    <div className="nemeeting-audio-line" key={i}>
                      {members.map((member) => {
                        return (
                          <VideoCard
                            isAudioMode={true}
                            showBorder={
                              meetingInfo.focusUuid
                                ? meetingInfo.focusUuid === member.uuid
                                : meetingInfo.showSpeaker
                                ? meetingInfo.activeSpeakerUuid === member.uuid
                                : false
                            }
                            isMain={false}
                            isMySelf={member.uuid === meetingInfo.myUuid}
                            key={member.uuid}
                            className={`h-full text-white nemeeting-video-card video-card card-for-1`}
                            onCallClick={onCallClick}
                            member={member}
                            style={{
                              height: defaultColumnHeight + 'px',
                              width: defaultColumnWidth + 'px',
                            }}
                          />
                        )
                      })}
                    </div>
                  )
                })}
              </SwiperSlide>
            ) : null
          })}
        </Swiper>
      </div>
    </div>
  )
}

export default React.memo(AudioModeCanvas)
