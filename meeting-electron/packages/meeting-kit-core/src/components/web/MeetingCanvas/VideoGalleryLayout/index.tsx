import React, { useMemo, useRef } from 'react'
import { SortableContainer, SortableElement } from 'react-sortable-hoc'

import { css } from '@emotion/css'
import { useGlobalContext, useMeetingInfoContext } from '../../../../store'
import { ActionType, NEMember, Role } from '../../../../types'
import VideoCard from '../../../common/VideoCard'
import './index.less'
import { useUpdateEffect } from 'ahooks'
import { useTranslation } from 'react-i18next'
import { Button } from 'antd'
import CommonModal from '../../../common/CommonModal'

interface VideoGalleryLayoutIF {
  videoViewWidth: number
  videoViewHeight: number
  handleViewDoubleClick: (member: NEMember) => void
  members: NEMember[]
  pageNum: number
  width?: '100%' | number
  onCallClick?: (member: NEMember) => void
}

interface SortableItemProps extends VideoGalleryLayoutIF {
  member: NEMember
}

const SortableItem = SortableElement<SortableItemProps>((props) => {
  const {
    member,
    members,
    videoViewHeight,
    videoViewWidth,
    handleViewDoubleClick,
    onCallClick,
  } = props
  const { t } = useTranslation()
  const { meetingInfo } = useMeetingInfoContext()
  const onMouseDownRef = useRef(false)

  const { localMember } = meetingInfo

  const videoItemCls = css`
    width: ${videoViewWidth}px;
    height: ${videoViewHeight}px;
  `

  const onMouseMove = () => {
    if (
      onMouseDownRef.current &&
      meetingInfo.remoteViewOrder !== undefined &&
      localMember.role !== Role.host
    ) {
      CommonModal.confirm({
        key: 'followGalleryLayoutConfirm',
        title: t('followGalleryLayoutConfirm'),
        okText: t('globalSure'),
        footer: (
          <div
            style={{
              marginTop: '0px',
            }}
            className="nemeeting-modal-confirm-btns"
          >
            <Button
              key="ok"
              type="primary"
              onClick={() => CommonModal.destroy('followGalleryLayoutConfirm')}
            >
              {t('globalSure')}
            </Button>
          </div>
        ),
      })
      onMouseDownRef.current = false
    }
  }

  return (
    <div
      className={videoItemCls}
      onMouseMove={onMouseMove}
      onMouseDown={() => (onMouseDownRef.current = true)}
    >
      <VideoCard
        onCallClick={() => {
          console.log('ddddd', onCallClick)
          onCallClick?.(member)
        }}
        mirroring={
          meetingInfo.enableVideoMirror && member?.uuid === meetingInfo.myUuid
        }
        onDoubleClick={handleViewDoubleClick}
        isAudioMode={false}
        avatarSize={48}
        showBorder={
          meetingInfo.focusUuid
            ? meetingInfo.focusUuid === member.uuid
            : meetingInfo.showSpeaker
            ? meetingInfo.activeSpeakerUuid === member.uuid
            : false
        }
        isSubscribeVideo={member.isVideoOn}
        isMain={false}
        streamType={members.length > 3 ? 1 : 0}
        isMySelf={member.uuid === meetingInfo.myUuid}
        key={member.uuid}
        type={'video'}
        className={`h-full text-white nemeeting-video-card video-card`}
        member={member}
      />
    </div>
  )
})

const SortableList = SortableContainer<VideoGalleryLayoutIF>(
  ({ members, width, ...resetProps }: VideoGalleryLayoutIF) => {
    const { meetingInfo } = useMeetingInfoContext()

    const { localMember } = meetingInfo

    const disabled = useMemo(() => {
      return (
        resetProps.pageNum !== 0 ||
        (meetingInfo.remoteViewOrder !== undefined &&
          localMember.role !== Role.host)
      )
    }, [resetProps.pageNum, localMember.role, meetingInfo.remoteViewOrder])

    return (
      <div
        className="video-gallery-layout"
        id="video-gallery-layout-container"
        style={{
          width: `${width === '100%' ? '100%' : width + 'px'}`,
          margin: '0 auto',
        }}
      >
        {members.map((member, index) => (
          <SortableItem
            key={member.uuid}
            index={index}
            member={member}
            members={members}
            disabled={disabled}
            {...resetProps}
          />
        ))}
      </div>
    )
  }
)

const VideoGalleryLayout: React.FC<VideoGalleryLayoutIF> = (props) => {
  const { t } = useTranslation()
  const { neMeeting } = useGlobalContext()
  const { meetingInfo, dispatch } = useMeetingInfoContext()
  const { members } = props
  // 用来避免进出导致的 UI 问题
  const [show, setShow] = React.useState(true)

  const currentMoveMember = React.useRef<NEMember>()

  const { localMember } = meetingInfo

  function arrayMove(arr, oldIndex, newIndex) {
    if (newIndex >= arr.length) {
      let k = newIndex - arr.length + 1

      while (k--) {
        arr.push(undefined)
      }
    }

    arr.splice(newIndex, 0, arr.splice(oldIndex, 1)[0])
    return arr
  }

  function getVideoContainerDom(selector: string, member: NEMember) {
    if (!member.isVideoOn) return

    const videoContainerDom = document.querySelector(selector) as HTMLElement

    if (window.isElectronNative && selector.startsWith('.dragging-handle')) {
      //
    } else {
      const videoDom = videoContainerDom.getElementsByClassName(
        'nertc-video-container'
      )[0]

      videoDom?.parentElement?.removeChild(videoDom)
      if (member?.uuid === meetingInfo.myUuid) {
        neMeeting?.rtcController?.setupLocalVideoCanvas(videoContainerDom)
        neMeeting?.rtcController?.playLocalStream('video')
      } else {
        neMeeting?.rtcController?.setupRemoteVideoCanvas(
          videoContainerDom,
          member.uuid
        )
      }
    }
  }

  const onSortEnd = ({ oldIndex, newIndex }) => {
    const member = members[oldIndex]

    getVideoContainerDom(
      `#nemeeting-video-container-${member.uuid}-video`,
      member
    )
    const newMembers = arrayMove(members, oldIndex, newIndex)
    const viewOrder = newMembers.map((member) => member.uuid).join(',')

    dispatch?.({
      type: ActionType.UPDATE_MEETING_INFO,
      data: {
        localViewOrder: viewOrder,
      },
    })
    currentMoveMember.current = undefined
  }

  const onSortStart = ({ index }) => {
    const member = members[index]

    getVideoContainerDom(
      `.dragging-handle #nemeeting-video-container-${member.uuid}-video`,
      member
    )
    currentMoveMember.current = member
  }

  function reRender() {
    setShow(false)
    setTimeout(() => {
      setShow(true)
    })
    currentMoveMember.current = undefined
  }

  useUpdateEffect(() => {
    // 数量变化释放 cell
    reRender()
  }, [members.length])

  useUpdateEffect(() => {
    if (currentMoveMember.current) {
      const index = members.findIndex(
        (member) => member.uuid === currentMoveMember.current?.uuid
      )

      // 如果当前移动的成员不在列表中，则重新渲染
      if (index === -1) {
        reRender()
      }
    }
  }, [members])

  useUpdateEffect(() => {
    if (
      currentMoveMember.current &&
      meetingInfo.remoteViewOrder !== undefined &&
      localMember.role !== Role.host
    ) {
      // 打开主持人更随
      CommonModal.confirm({
        key: 'followGalleryLayoutConfirm',
        title: t('followGalleryLayoutConfirm'),
        okText: t('globalSure'),
        footer: (
          <div
            style={{
              marginTop: '0px',
            }}
            className="nemeeting-modal-confirm-btns"
          >
            <Button
              key="ok"
              type="primary"
              onClick={() => CommonModal.destroy('followGalleryLayoutConfirm')}
            >
              {t('globalSure')}
            </Button>
          </div>
        ),
      })
      reRender()
    }
  }, [meetingInfo.remoteViewOrder])

  return show ? (
    <SortableList
      axis="xy"
      helperClass="dragging-handle"
      pressDelay={150}
      onSortEnd={onSortEnd}
      onSortStart={onSortStart}
      lockToContainerEdges
      getContainer={() =>
        document.getElementById('video-gallery-layout-container') as HTMLElement
      }
      helperContainer={() =>
        document.getElementById('video-gallery-layout-container') as HTMLElement
      }
      {...props}
    />
  ) : null
}

export default VideoGalleryLayout
