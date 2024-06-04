import { NEMeetingInfo, NEMember } from '../../../types'
import { Swiper, SwiperSlide } from 'swiper/react'
import { Pagination } from 'swiper'
import VideoCard from '../../common/VideoCard'
import React, { useCallback, useEffect, useState } from 'react'
import useAudioMode from '../../../hooks/useAudioMode'

interface AudioModeCanvasH5Props {
  meetingInfo: NEMeetingInfo
  memberList: NEMember[]
}
const defaultColumnWidth = 102
const defaultColumnHeight = 128
const AudioModeCanvas: React.FC<AudioModeCanvasH5Props> = ({
  meetingInfo,
  memberList,
}) => {
  // 是否竖屏
  const [isPortrait, setIsPortrait] = useState(true)
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
  const onSizeChange = useCallback((event: Event) => {
    console.log('setIsPortrait>>>', screen.orientation.angle === 0)
    setIsPortrait(screen.orientation.angle === 0)
  }, [])
  useEffect(() => {
    window.addEventListener('resize', onSizeChange)
    return () => {
      window.removeEventListener('resize', onSizeChange)
    }
  }, [])

  // 计算当前视图排放个数
  const calculateColumnCountAndLineCount = (isPortrait: boolean) => {
    let columnCount = 4
    let lineCount = 3
    // 竖屏模式4行3列
    if (isPortrait) {
      columnCount = 3
      lineCount = 4
    } else {
      // 横屏模式2行7列
      columnCount = 7
      lineCount = 2
    }
    console.log('columnCount>>', columnCount, 'lineCount>>', lineCount)
    setColumnCount(columnCount)
    setLineCount(lineCount)
  }
  useEffect(() => {
    calculateColumnCountAndLineCount(isPortrait)
  }, [isPortrait])
  return (
    <div
      className={'gallery-slider swiper-view-wrap nemeeting-audio-mode-wrap'}
    >
      <Swiper
        onSwiper={(swiper) => (swiperInstanceRef.current = swiper)}
        spaceBetween={50}
        slidesPerView={1}
        modules={[Pagination]}
        pagination={true}
        className={'meeting-canvas-swiper meeting-audio-mode-canvas-swiper'}
        onActiveIndexChange={(swp) => {
          setActiveIndex(swp.activeIndex)
        }}
      >
        {groupMemberList.map((lineMembers, index: number) => {
          {
            return (
              <SwiperSlide className={'nemeeting-swiper-slide'} key={index}>
                {/*第一页展示大小屏*/}
                {lineMembers.map((members, i: number) => {
                  return (
                    <div className="nemeeting-audio-line" key={i}>
                      {members.map((member, j) => {
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
                            className={`h-full text-white nemeeting-video-card video-card`}
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
            )
          }
        })}
      </Swiper>
    </div>
  )
}

export default AudioModeCanvas
