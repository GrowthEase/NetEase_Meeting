import React, {
  useContext,
  useEffect,
  useMemo,
  useReducer,
  useRef,
  useState,
} from 'react'
import { Swiper, SwiperSlide } from 'swiper/react'
import './index.less'
import { Pagination } from 'swiper'
import 'swiper/css'
import 'swiper/css/pagination'
import VideoCard from '../../common/VideoCard'
import { NEMember } from '../../../types'
import { MeetingInfoContext } from '../../../store'
import { groupMembersService } from './service'
import WhiteboardView from './WhiteboardView'
import { getClientType } from '../../../utils'

interface MeetingCanvasProps {
  className?: string
  onActiveIndexChanged: (activeIndex: number) => void
}
const MeetingCanvas: React.FC<MeetingCanvasProps> = (props) => {
  const { className, onActiveIndexChanged } = props
  // const [groupMembers, setGroupMembers] = useState<Array<NEMember[]>>([])
  const [groupNum, setGroupNum] = useState<number>(4)
  const [fullScreenIndex, setFullScreenIndex] = useState(0)
  const { meetingInfo, memberList } = useContext(MeetingInfoContext)
  // 当前显示页面index
  const [activeIndex, setActiveIndex] = useState(0)
  const [iosTime, setIosTime] = useState(0)
  const [showPagination, setShowPagination] = useState(true)

  const viewType = useMemo(() => {
    return !!meetingInfo.screenUuid ? 'screen' : 'video'
  }, [meetingInfo.screenUuid])

  // 对成员列表进行排序
  const groupMembers = useMemo(() => {
    const groupMembers = groupMembersService({
      memberList,
      groupNum,
      screenUuid: meetingInfo.screenUuid,
      focusUuid: meetingInfo.focusUuid,
      myUuid: meetingInfo.localMember.uuid,
      activeSpeakerUuid: meetingInfo.activeSpeakerUuid,
      groupType: 'h5',
      enableSortByVoice: !!meetingInfo.enableSortByVoice,
    })
    return groupMembers
  }, [
    memberList,
    memberList.length,
    meetingInfo.hostUuid,
    meetingInfo.focusUuid,
    meetingInfo.activeSpeakerUuid,
    meetingInfo.screenUuid,
  ])

  useEffect(() => {
    // 屏幕共享
    if (meetingInfo.screenUuid) {
      setFullScreenIndex(0)
    }
  }, [meetingInfo.screenUuid])

  // 返回第一页，解决ios滑动到页面重新回来video标签遮挡。需要重新渲染
  useEffect(() => {
    onActiveIndexChanged && onActiveIndexChanged(activeIndex)
    // 切换到非第一页，ios需要重新渲染防止vidoe遮挡昵称
    if (activeIndex !== 0 && getClientType() === 'IOS') {
      setShowPagination(false)
      setTimeout(() => {
        setShowPagination(true)
      }, 500)
    }
  }, [activeIndex])

  // 在第一页，当大屏的渲染人员变更后，video标签遮挡右上角小屏要重新渲染
  useEffect(() => {
    if (activeIndex === 0) {
      setTimeout(() => {
        setIosTime(Math.random())
      }, 800)
    }
  }, [groupMembers])

  function handleCardClick(uuid: string, index: number, event: any) {
    if (index !== fullScreenIndex) {
      event.stopPropagation()
    }
    if (meetingInfo.screenUuid === uuid) return
    setFullScreenIndex(index)
  }

  return (
    <div className={`meeting-canvas ${className}`}>
      <Swiper
        spaceBetween={50}
        slidesPerView={1}
        modules={[Pagination]}
        pagination={showPagination}
        className={'meeting-canvas-swiper h-full w-full'}
        onActiveIndexChange={(swp) => setActiveIndex(swp.activeIndex)}
      >
        {groupMembers.map((members, index: number) => {
          {
            return (
              <SwiperSlide
                className={'swiper-slide flex flex-wrap relative'}
                key={index}
              >
                {/*第一页展示大小屏*/}
                {index === 0
                  ? members.map((member: NEMember, i: number) => {
                      return (
                        <VideoCard
                          isMySelf={member.uuid === meetingInfo.myUuid}
                          key={`${member.uuid}-main-${i}-${
                            i === 0 ? viewType : 'video'
                          }`}
                          isSubscribeVideo={index === activeIndex}
                          isMain={i === 0}
                          type={i === 0 ? viewType : 'video'}
                          iosTime={i !== fullScreenIndex ? iosTime : 0}
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
                    })
                  : members.map((member: NEMember, i: number) => {
                      return (
                        <VideoCard
                          canPinVideo={
                            memberList.length > 1 && member.isVideoOn
                          }
                          showBorder={
                            meetingInfo.focusUuid
                              ? meetingInfo.focusUuid === member.uuid
                              : meetingInfo.activeSpeakerUuid === member.uuid
                          }
                          isSubscribeVideo={index === activeIndex}
                          isMain={false}
                          isMySelf={member.uuid === meetingInfo.myUuid}
                          key={member.uuid}
                          type={'video'}
                          className={`w-full h-full text-white w-1/2 h-1/2`}
                          member={member}
                        />
                      )
                    })}
              </SwiperSlide>
            )
          }
        })}
      </Swiper>
      {meetingInfo?.whiteboardUuid && (
        <WhiteboardView className={'whiteboard-index'} />
      )}
    </div>
  )
}
export default React.memo(MeetingCanvas)
