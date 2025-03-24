import classNames from 'classnames'
import React, { useEffect, useMemo } from 'react'
import PCTopButtons from '../../../common/PCTopButtons'
import { useTranslation } from 'react-i18next'
import { useMeetingInfoContext } from '../../../../store'
import useWatermark from '../../../../hooks/useWatermark'
import './index.less'
import VideoCard from '../../../common/VideoCard'
import WhiteboardView from '../WhiteboardView'
import SharingScreenZoom from '../../SharingScreenZoom'
import FullScreenButton from '../../FullScreenButton'
import useFullscreen from '../../../../hooks/useFullscreen'
import { EndDropdown } from '../../ControlBar/Buttons/EndButton'
import { ActionType } from '../../../../kit'
import useMouseInsideWindow from '../../../../hooks/useMouseInsideWindow'

const SecondMonitorView: React.FC = () => {
  useWatermark()
  const { t } = useTranslation()
  const { isFullScreen } = useFullscreen()
  const { isMouseInsideWindow } = useMouseInsideWindow()
  const { meetingInfo, dispatch } = useMeetingInfoContext()
  const [endMeetingAction, setEndMeetingAction] = React.useState<number>(0)
  const [isOpen, setIsOpen] = React.useState(false)

  const isDarkMode = meetingInfo.isDarkMode

  const member = meetingInfo.secondMonitorMember

  const videoCardShow = useMemo(() => {
    if (meetingInfo.isWhiteboardTransparent) {
      return true
    }

    return !meetingInfo.whiteboardUuid
  }, [meetingInfo.whiteboardUuid, meetingInfo.isWhiteboardTransparent])

  function swapSecondMonitor() {
    window.ipcRenderer?.send('DUAL_MONITORS_WIN_SWAP')
  }

  useEffect(() => {
    if (isOpen && member && member.isSharingScreen) {
      const parentWindow = window.parent

      parentWindow?.postMessage(
        {
          event: 'createSecondMonitorRenderer',
        },
        parentWindow.origin
      )
      return () => {
        parentWindow?.postMessage(
          {
            event: 'removeSecondMonitorRenderer',
          },
          parentWindow.origin
        )
      }
    }
  }, [member?.uuid, member?.isSharingScreen, isOpen])

  useEffect(() => {
    if (member?.isSharingScreen) {
      return
    }

    if (meetingInfo.whiteboardUuid && !meetingInfo.isWhiteboardTransparent) {
      return
    }

    if (isOpen && member && member.isVideoOn) {
      const parentWindow = window.parent

      parentWindow?.postMessage(
        {
          event: 'createSecondMonitorRenderer',
        },
        parentWindow.origin
      )
      return () => {
        parentWindow?.postMessage(
          {
            event: 'removeSecondMonitorRenderer',
          },
          parentWindow.origin
        )
      }
    }
  }, [
    member?.uuid,
    member?.isVideoOn,
    isOpen,
    meetingInfo.whiteboardUuid,
    member?.isSharingScreen,
  ])

  useEffect(() => {
    if (meetingInfo.whiteboardUuid && !meetingInfo.isWhiteboardTransparent) {
      const parentWindow = window.parent

      parentWindow?.postMessage(
        {
          event: 'removeSecondMonitorRenderer',
        },
        parentWindow.origin
      )
    }
  }, [meetingInfo.whiteboardUuid, meetingInfo.isWhiteboardTransparent])

  if (member) {
    member.isSharingScreenView = member.isSharingScreen
    member.isSharingWhiteboardView = member.isSharingWhiteboard
  }

  useEffect(() => {
    window.ipcRenderer?.on('DUAL_MONITORS_WIN_END', () => {
      setEndMeetingAction(3)
    })
  }, [])

  useEffect(() => {
    setTimeout(() => {
      document.title = t('appTitle')
    })
  }, [])

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event } = e.data

      if (event === 'windowOpen') {
        setIsOpen(true)
      } else if (event === 'windowClosed') {
        setIsOpen(false)
      }
    }

    window.addEventListener('message', handleMessage)
    return () => {
      window.removeEventListener('message', handleMessage)
    }
  }, [])

  return isOpen ? (
    <div
      className={classNames(
        'h-full relative meeting-web-wrapper flex second-monitor-view-wrapper',
        {
          ['light-theme']: !isDarkMode,
        }
      )}
    >
      {isFullScreen ? null : (
        <div className="second-monitor-view-drag-bar">
          <div className="drag-region" />
          {t('appTitle')}
          <PCTopButtons />
        </div>
      )}
      <EndDropdown
        endMeetingAction={endMeetingAction}
        onCancel={() => {
          setEndMeetingAction(0)
        }}
      />
      <SharingScreenZoom />
      {meetingInfo.whiteboardUuid ? null : isMouseInsideWindow ? (
        <div
          className="second-monitor-view-switch"
          onClick={() => {
            swapSecondMonitor()
          }}
        >
          <svg
            className="icon iconfont ne-interpreter-switch"
            aria-hidden="true"
          >
            <use xlinkHref="#iconqiehuan"></use>
          </svg>
          {t('swapSecondMonitor')}
        </div>
      ) : null}

      <div className="second-monitor-view-container">
        {isMouseInsideWindow ? (
          <div className="nemeeting-top-right-wrap">
            <FullScreenButton
              className="nemeeting-top-right-item"
              isFullScreen={isFullScreen ?? false}
            />
          </div>
        ) : null}
        {videoCardShow && member ? (
          <VideoCard
            onDoubleClick={(member) => {
              dispatch?.({
                type: ActionType.UPDATE_MEETING_INFO,
                data: {
                  pinVideoUuid: member.uuid,
                },
              })
            }}
            mirroring={
              meetingInfo.enableVideoMirror &&
              member?.uuid === meetingInfo.myUuid
            }
            showBorder={false}
            isSubscribeVideo={false}
            isSecondMonitor={true}
            isMain={true}
            operateExtraTop
            isMySelf={member.uuid === meetingInfo.myUuid}
            key={member.uuid}
            type={member.isSharingScreen ? 'screen' : 'video'}
            className={`w-full h-full text-white bg-black`}
            member={member}
            avatarSize={64}
          />
        ) : null}
        {meetingInfo.whiteboardUuid ? (
          <WhiteboardView
            isEnable={!!meetingInfo.whiteboardUuid && !meetingInfo.screenUuid}
            className={
              meetingInfo.enableFixedToolbar
                ? ''
                : 'nemeeting-whiteboard-custom'
            }
          />
        ) : null}
      </div>
    </div>
  ) : null
}

export default React.memo(SecondMonitorView)
