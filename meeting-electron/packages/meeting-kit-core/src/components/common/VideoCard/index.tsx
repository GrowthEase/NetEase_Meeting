import React, {
  CSSProperties,
  LegacyRef,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react'
import { useTranslation } from 'react-i18next'
import useWatch from '../../../hooks/useWatch'
import { GlobalContext, MeetingInfoContext } from '../../../store'
import {
  ActionType,
  AvatarSize,
  EventType,
  GlobalContext as GlobalContextInterface,
  NEMember,
} from '../../../types'
import AudioIcon from '../AudioIcon'
import './index.less'

import { debounce, substringByByte3 } from '../../../utils'
import UserAvatar from '../Avatar'
import AudioCard from './audioCard'
import AnnotationView from '../AnnotationView'
import { CommonModal, NEMeetingInviteStatus } from '../../../kit'
import WhiteboardView from '../../web/MeetingCanvas/WhiteboardView'
import { Button, Dropdown } from 'antd'
import Emoticons from '../Emoticons'
import classNames from 'classnames'
import {
  TransformWrapper,
  TransformComponent,
  ReactZoomPanPinchContentRef,
} from 'react-zoom-pan-pinch'
import useScreenSharingTransform from '../../../hooks/useScreenSharingTransform'
import useVideoShortcutOperation from '../../../hooks/useVideoShortcutOperation'
import useNetworkQuality from '../../../hooks/useNetworkQuality'

interface VideoCardProps {
  isMySelf: boolean
  member: NEMember
  isMain: boolean
  streamType?: 0 | 1
  type?: 'video' | 'screen' | 'whiteboard'
  speakerRightResizing?: boolean
  isSubscribeVideo?: boolean // 是否订阅视频流
  isSecondMonitor?: boolean // 是否副屏
  className?: string
  showBorder?: boolean // 是否显示绿框
  onClick?: (e: React.MouseEvent<HTMLDivElement>) => void
  iosTime?: number // 在第一页，当大屏的渲染人员变更后，video标签遮挡右上角小屏, 要重新渲染小视图
  canShowCancelFocusBtn?: boolean
  focusBtnClassName?: string
  style?: CSSProperties
  ref?: LegacyRef<HTMLDivElement> | undefined
  // 是否镜像
  mirroring?: boolean
  videoViewPosition?: number
  avatarSize?: AvatarSize
  isAudioMode?: boolean
  onDoubleClick?: (member: NEMember) => void
  noPin?: boolean
  onCallClick?: (member: NEMember) => void
  isH5?: boolean
  showInPhoneTip?: boolean
  operateExtraTop?: boolean
}

const VideoCard: React.FC<VideoCardProps> = (props) => {
  const {
    streamType = 0,
    member,
    className,
    onClick,
    isMySelf,
    isMain,
    showBorder,
    iosTime,
    canShowCancelFocusBtn,
    focusBtnClassName,
    speakerRightResizing,
    style,
    mirroring,
    avatarSize,
    isAudioMode,
    onDoubleClick,
    noPin,
    onCallClick,
    isH5,
    isSecondMonitor,
    showInPhoneTip,
    operateExtraTop,
  } = props
  const { t } = useTranslation()
  const type = props.type || 'video'
  const { dispatch, meetingInfo } = useContext(MeetingInfoContext)
  const { neMeeting, eventEmitter, outEventEmitter } =
    useContext<GlobalContextInterface>(GlobalContext)
  const viewRef = useRef<HTMLDivElement | null>(null)
  const canvasContainerRef = useRef<HTMLDivElement | null>(null)
  const annotationRef = useRef<HTMLDivElement | null>(null)
  const transformWrapperRef = useRef<ReactZoomPanPinchContentRef | null>(null)
  const timer = useRef<null | ReturnType<typeof setTimeout>>(null)
  const mouseLeaveTimerRef = useRef<null | ReturnType<typeof setTimeout>>(null)
  const screenShareVideoResolutionRef = useRef<{
    width: number
    height: number
  }>({ width: 0, height: 0 })
  const [isMouseLeave, setIsMouseLeave] = useState<boolean>(true)
  const {
    onTransformed,
    onCanvasResize,
    onWrapperResize,
    onWheelStop,
    scaleRef,
    minScale,
    maxScale,
    zoomToast,
  } = useScreenSharingTransform({
    transformWrapperRef: transformWrapperRef.current,
  })

  const { operatorItems } = useVideoShortcutOperation({
    member,
    isMySelf,
    isSecondMonitor,
  })
  const { isNetworkQualityBad } = useNetworkQuality(member)

  // 是否需要订阅当前流，非当前页面则不订阅
  const isSubscribeVideo = useMemo(() => {
    return props.isSubscribeVideo !== false
  }, [props.isSubscribeVideo])

  const meetingInfoRef = useRef(meetingInfo)

  meetingInfoRef.current = meetingInfo

  const playRemoteVideo = debounce(() => {
    if (isMySelf) {
      return
    }

    if (!isSubscribeVideo) {
      console.warn('非当前页不播放视频')
    } else {
      // 开始订阅流
      // 定时器是为了 Electron 问题，第一次入会订阅不到流，rtc 没初始化成功。 后面需要改
      setTimeout(
        () => {
          console.warn(
            '开始订阅大小流',
            member.uuid,
            member.name,
            streamType === 0 ? '大流' : '小流'
          )
          neMeeting?.subscribeRemoteVideoStream(member.uuid, streamType)
        },
        window.isElectronNative ? 100 : 0
      )
    }
  }, 300)

  const showCancelFocusBtn = useMemo(() => {
    if (meetingInfo.screenUuid || meetingInfo.whiteboardUuid) {
      return false
    } else {
      return (
        canShowCancelFocusBtn &&
        !meetingInfo.isRooms &&
        meetingInfo.showFocusBtn !== false
      )
    }
  }, [
    canShowCancelFocusBtn,
    meetingInfo.isRooms,
    meetingInfo.showFocusBtn,
    meetingInfo.screenUuid,
    meetingInfo.whiteboardUuid,
  ])

  const canShowCancelPinBtn = useMemo(() => {
    if (showCancelFocusBtn) {
      return false
    }

    if (meetingInfo.pinVideoUuid === member.uuid && type === 'video') {
      return true
    }
  }, [
    meetingInfo.pinVideoUuid,
    member.uuid,
    type,
    meetingInfo.focusUuid,
    meetingInfo.showFocusBtn,
    showCancelFocusBtn,
    isMain,
  ])

  const canShowMainPinBtn = useMemo(() => {
    return (
      isMain &&
      !meetingInfo.focusUuid &&
      type != 'screen' &&
      member.isVideoOn &&
      !noPin
    )
  }, [meetingInfo.focusUuid, isMain, type, member.isVideoOn, noPin])
  const playRemoteSubVideo = () => {
    if (isMySelf || type !== 'screen') {
      return
    }

    setTimeout(
      () => {
        neMeeting?.rtcController?.subscribeRemoteVideoSubStream(member.uuid)
      },
      window.isElectronNative ? 100 : 1000
    )
  }

  const nicknameHide = useMemo(() => {
    if (
      meetingInfo.setting.videoSetting.showMemberName === false &&
      isMouseLeave
    ) {
      return true
    }

    return false
  }, [isMouseLeave, meetingInfo.setting.videoSetting.showMemberName])

  const nickName = useMemo(() => {
    return ' ' + substringByByte3(member.name, 20)
  }, [member.name, member.isVideoOn, meetingInfo.setting.videoSetting])

  useEffect(() => {
    if (member.isVideoOn && type !== 'screen') {
      if (!isMySelf) {
        playRemoteVideo()
      }
    }
  }, [streamType, isMySelf, member.isVideoOn, type])

  useEffect(() => {
    if (isMySelf) {
      // isVideoOn存在值则非第一次进入会议
      if (member.isVideoOn && type === 'video') {
        neMeeting?.rtcController?.playLocalStream('video')
      } else {
        //  第一次进入会议
        handleUnmuteMediaWhenJoin()
      }
    } else {
      if (type === 'screen') {
        playRemoteSubVideo()
      } else {
        if (member.isVideoOn) {
          if (isSubscribeVideo) {
            playRemoteVideo()
          } else {
            // timer.current = setTimeout(() => {
            //   neMeeting?.unsubscribeRemoteVideoStream(member.uuid, streamType)
            //   timer.current = null
            // }, 5000)
            // neMeeting?.rtcController?.unsubscribeRemoteVideoStream(
            //   member.uuid,
            //   streamType
            // )
          }
        }
      }
    }

    return () => {
      timer.current && clearTimeout(timer.current)
    }
  }, [])

  useWatch<boolean>(isSubscribeVideo, (preIsSubscribe) => {
    if (preIsSubscribe === isSubscribeVideo || type === 'screen') {
      return
    }

    if (member.isVideoOn) {
      if (!isSubscribeVideo) {
        // timer.current = setTimeout(() => {
        //   neMeeting?.unsubscribeRemoteVideoStream(member.uuid, streamType)
        //   timer.current = null
        // }, 10000)
      } else {
        if (timer.current) {
          clearTimeout(timer.current)
          timer.current = null
        }

        playRemoteVideo()
      }
    }
  })
  const handleUnmuteMediaWhenJoin = useCallback(() => {
    const meetingInfo = meetingInfoRef.current
    const isHost = meetingInfo.hostUuid === member.uuid

    // 如果开启音视频进入会议
    if (member.isInRtcChannel) {
      if (
        meetingInfoRef.current.isUnMutedVideo &&
        ((meetingInfoRef.current.unmuteVideoBySelfPermission &&
          !meetingInfoRef.current.videoAllOff) ||
          isHost)
      ) {
        console.warn('开启视频')
        neMeeting?.unmuteLocalVideo()
        // 后续设置为false
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            isUnMutedVideo: false,
          },
        })
      }

      if (
        meetingInfoRef.current.isUnMutedAudio &&
        (meetingInfoRef.current.setting.audioSetting.usingComputerAudio ||
          isH5) &&
        ((meetingInfoRef.current.unmuteAudioBySelfPermission &&
          !meetingInfoRef.current.audioAllOff) ||
          isHost)
      ) {
        neMeeting?.unmuteLocalAudio()
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            isUnMutedAudio: false,
          },
        })
      }
    }
  }, [dispatch, neMeeting, member.uuid, member.isInRtcChannel])

  useEffect(() => {
    if (member.isInRtcChannel && isMySelf) {
      handleUnmuteMediaWhenJoin()
    }
  }, [member.isInRtcChannel, handleUnmuteMediaWhenJoin, isMySelf])

  useWatch<boolean>(member.isVideoOn, (preIsVideoOn) => {
    if (member.isVideoOn === preIsVideoOn) {
      return
    }

    if (type === 'screen') {
      return
    } else {
      // 非视频共享view
      if (member.isVideoOn && type === 'video') {
        if (isMySelf) {
          // 本端直接播放
          neMeeting?.rtcController?.playLocalStream('video')
        } else {
          if (isSubscribeVideo) {
            playRemoteVideo()
          } else {
            // neMeeting?.unsubscribeRemoteVideoStream(member.uuid, streamType)
          }
        }
      } else {
        // 非本端取消订阅
        // !isMySelf &&
        // neMeeting?.unsubscribeRemoteVideoStream(member.uuid, streamType)
      }
    }
  })
  useWatch<boolean>(member.isSharingScreen, () => {
    if (type === 'screen') {
      if (isMySelf) {
        if (member.isSharingScreen) {
          neMeeting?.rtcController?.startScreenShare()
        } else {
          neMeeting?.rtcController?.stopScreenShare()
        }
      } else {
        playRemoteSubVideo()
      }
    }
  })

  function onCardClick(e: React.MouseEvent<HTMLDivElement>) {
    // neMeeting?.rtcController?.takeRemoteSnapshot(member.uuid, 0, )
    onClick?.(e)
  }

  // 透明白板需要，根据不同分辨率保存当前主画面的大小
  // const setMainVideoSize = async () => {
  //   if (isMainVideo && member.isVideoOn) {
  //     videoSizeTimer.current && clearTimeout(videoSizeTimer.current)
  //     videoSizeTimer.current = null
  //     const videoSize = {
  //       width: 0,
  //       height: 0,
  //     }
  //     const mainDom = viewRef.current as HTMLElement
  //     let videoInfo

  //     if (isMySelf) {
  //       const localVideoStats = await neMeeting?.getLocalVideoStats()

  //       if (localVideoStats && localVideoStats.length > 0) {
  //         const videoStat = localVideoStats[0]

  //         videoInfo = {
  //           renderResolutionWidth: videoStat.captureResolutionWidth,
  //           renderResolutionHeight: videoStat.captureResolutionHeight,
  //         }
  //       } else {
  //         videoSizeTimer.current = setTimeout(() => {
  //           setMainVideoSize()
  //         }, 1500)
  //         return
  //       }
  //     } else {
  //       const videoStats = await neMeeting?.getRemoteVideoStats()

  //       if (videoStats && videoStats.length > 0) {
  //         const videoStat = videoStats.find(
  //           (_member) => _member.userUuid == String(member.rtcUid)
  //         )

  //         if (videoStat) {
  //           const layer = videoStat.layers[0]

  //           videoInfo = {
  //             renderResolutionWidth: layer.RenderResolutionWidth,
  //             renderResolutionHeight: layer.RenderResolutionHeight,
  //           }
  //         }
  //       } else {
  //         videoSizeTimer.current = setTimeout(() => {
  //           setMainVideoSize()
  //         }, 1500)
  //         return
  //       }
  //     }

  //     if (videoInfo) {
  //       // const videoStat = videoInfo.layers[0]
  //       if (
  //         videoInfo.renderResolutionHeight >= videoInfo.renderResolutionWidth
  //       ) {
  //         videoSize.height = mainDom.clientHeight
  //         videoSize.width =
  //           mainDom.clientHeight *
  //           (videoInfo.renderResolutionWidth / videoInfo.renderResolutionHeight)
  //       } else {
  //         videoSize.width = mainDom.clientWidth
  //         videoSize.height =
  //           mainDom.clientWidth *
  //           (videoInfo.renderResolutionHeight / videoInfo.renderResolutionWidth)
  //       }
  //     }

  //     dispatch?.({
  //       type: ActionType.UPDATE_MEETING_INFO,
  //       data: {
  //         mainVideoSize: {
  //           width: videoSize.width,
  //           height: videoSize.height,
  //         },
  //       },
  //     })
  //   }
  // }

  const cancelFocus = (type: 'focus' | 'pin') => {
    if (type === 'focus') {
      neMeeting?.sendHostControl(31, member.uuid)
    } else {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          pinVideoUuid: '',
        },
      })
    }
  }

  const handleDoubleClick = () => {
    onDoubleClick?.(member)
  }

  const pinView = () => {
    onDoubleClick?.(member)
  }

  const resizeTransformWrapper = debounce(() => {
    const videoDom = canvasContainerRef.current

    if (videoDom) {
      const canvasDom = videoDom.getElementsByTagName('canvas')[0]

      if (canvasDom && canvasDom.clientWidth && canvasDom.clientHeight) {
        videoDom.style.width = canvasDom.clientWidth + 'px'
        videoDom.style.height = canvasDom.clientHeight + 'px'
      }

      if (
        transformWrapperRef.current &&
        videoDom.parentElement?.parentElement
      ) {
        transformWrapperRef.current.zoomToElement(
          videoDom.parentElement.parentElement,
          scaleRef.current,
          0
        )
      }
    }
  }, 300)

  useEffect(() => {
    if (
      window.isElectronNative &&
      member.isSharingScreen &&
      type === 'screen'
    ) {
      const videoDom = canvasContainerRef.current

      if (videoDom) {
        if (type === 'screen') {
          const observer = new MutationObserver(() => {
            const canvasDom = videoDom.getElementsByTagName('canvas')[0]

            const observer = new ResizeObserver(() => {
              if (annotationRef.current) {
                annotationRef.current.style.width = canvasDom.clientWidth + 'px'
                annotationRef.current.style.height =
                  canvasDom.clientHeight + 'px'
              }

              resizeTransformWrapper()

              canvasDom && onCanvasResize(canvasDom)
            })

            canvasDom && onCanvasResize(canvasDom)
            canvasDom && observer.observe(canvasDom)
          })

          observer.observe(videoDom, { childList: true })
        }
      }
    }
  }, [type, isSubscribeVideo, member.uuid, member.isSharingScreen])

  useEffect(() => {
    if (member.isVideoOn && type === 'video' && isSubscribeVideo) {
      const videoDom = viewRef.current

      if (videoDom) {
        if (isMySelf) {
          neMeeting?.rtcController?.setupLocalVideoCanvas(videoDom)
          neMeeting?.rtcController?.playLocalStream('video')
          return () => {
            neMeeting?.rtcController?.removeLocalVideoCanvas?.(videoDom)
          }
        } else {
          neMeeting?.rtcController?.setupRemoteVideoCanvas(
            videoDom,
            member.uuid
          )
          return () => {
            neMeeting?.rtcController?.removeRemoteVideoCanvas?.(
              member.uuid,
              videoDom
            )
          }
        }
      }
    }
  }, [member.isVideoOn, type, isSubscribeVideo, member.uuid, isMySelf])

  useEffect(() => {
    if (member.isSharingScreen && type === 'screen') {
      const videoDom = canvasContainerRef.current

      if (videoDom) {
        neMeeting?.rtcController?.setupRemoteVideoSubStreamCanvas(
          videoDom,
          member.uuid
        )
        return () => {
          neMeeting?.rtcController?.removeRemoteVideoSubStreamCanvas?.(
            member.uuid,
            videoDom
          )
        }
      }
    }
  }, [type, isSubscribeVideo, member.uuid, member.isSharingScreen])

  useEffect(() => {
    function resize(data: { width: number; height: number }) {
      screenShareVideoResolutionRef.current = data
      const { width, height } = data
      const annotation = annotationRef.current

      if (annotation && viewRef.current) {
        const viewWidth = viewRef.current.clientWidth
        const viewHeight = viewRef.current.clientHeight

        if (viewWidth / (width / height) > viewHeight) {
          annotation.style.height = `${viewHeight}px`
          annotation.style.width = `${viewHeight * (width / height)}px`
        } else {
          annotation.style.width = `${viewWidth}px`
          annotation.style.height = `${viewWidth / (width / height)}px`
        }
      }
    }

    const viewDom = viewRef.current

    function resizeCanvasContainer() {
      const canvasContainer = canvasContainerRef.current

      if (viewDom && canvasContainer) {
        canvasContainer.style.width = viewDom.clientWidth + 'px'
        canvasContainer.style.height = viewDom.clientHeight + 'px'

        const canvasDom = canvasContainer.getElementsByTagName('canvas')[0]

        if (canvasDom) {
          const canvas = canvasDom
          const view = canvasContainer
          const width = canvas.width
          const height = canvas.height

          const viewWidth = view.clientWidth
          const viewHeight = view.clientHeight

          if (viewWidth / (width / height) > viewHeight) {
            canvas.style.height = `${viewHeight}px`
            canvas.style.width = `auto`
          } else {
            canvas.style.width = `${viewWidth}px`
            canvas.style.height = `auto`
          }
        }
      }
    }

    if (viewDom) {
      const observer = new ResizeObserver(() => {
        !window.isElectronNative &&
          resize(screenShareVideoResolutionRef.current)
        resizeCanvasContainer()
        resizeTransformWrapper()
        onWrapperResize(transformWrapperRef.current)
      })

      observer.observe(viewDom)
      eventEmitter?.on(EventType.RtcScreenShareVideoResize, resize)
      return () => {
        eventEmitter?.off(EventType.RtcScreenShareVideoResize, resize)
        observer.unobserve(viewDom)
        observer.disconnect()
      }
    }
  }, [type, neMeeting, eventEmitter])

  useEffect(() => {
    if (!meetingInfo.screenUuid) {
      CommonModal.destroy('screenShareStop')
    }
  }, [meetingInfo.screenUuid])

  function handleCallClick() {
    onCallClick?.(member)
  }

  function handleStopShareScreen() {
    outEventEmitter?.emit('enableShareScreen')
  }

  const inviteStateContent = useMemo(() => {
    switch (member.inviteState) {
      case NEMeetingInviteStatus.waitingCall:
      case NEMeetingInviteStatus.calling:
      case NEMeetingInviteStatus.waitingJoin:
        return (
          <div
            className="invite-state-wrapper"
            style={{
              fontSize: '14px',
            }}
          >
            {t('sipCalling')}
          </div>
        )
      case NEMeetingInviteStatus.rejected:
      case NEMeetingInviteStatus.noAnswer:
      case NEMeetingInviteStatus.error:
      case NEMeetingInviteStatus.canceled:
      case NEMeetingInviteStatus.busy:
        return (
          <div
            className="invite-state-wrapper"
            onClick={() => handleCallClick?.()}
          >
            {t('notJoined')}
          </div>
        )
      default:
        return null
    }
  }, [member.inviteState])

  const CallingIcon = useMemo(() => {
    switch (member.inviteState) {
      case NEMeetingInviteStatus.rejected:
      case NEMeetingInviteStatus.noAnswer:
      case NEMeetingInviteStatus.error:
      case NEMeetingInviteStatus.canceled:
      case NEMeetingInviteStatus.busy:
        return (
          <div
            className="invite-state-icon"
            onClick={() => onCallClick?.(member)}
            style={{
              width: '16px',
              height: '16px',
              left: `calc(50% + ${avatarSize ? avatarSize / 2 - 16 : 16}px)`,
              top: `calc(50% - ${avatarSize ? avatarSize / 2 : 16}px)`,
            }}
          >
            <svg className="icon iconfont" aria-hidden="true">
              <use xlinkHref="#iconhujiao1"></use>
            </svg>
          </div>
        )
      default:
        return null
    }
  }, [member.inviteState])

  function renderSharingViewUserLabel() {
    if (member.isSharingScreenView || member.isSharingWhiteboardView) {
      return (
        <div className="sharing-view-user-label">
          {member.isSharingWhiteboardView ? (
            <svg className="icon iconfont" aria-hidden="true">
              <use xlinkHref="#iconbaiban-mianxing" />
            </svg>
          ) : (
            <svg className="icon iconfont" aria-hidden="true">
              <use xlinkHref="#icontouping-mianxing" />
            </svg>
          )}
          <div className="sharing-view-user-label-name">{member.name}</div>
          <div>
            {member.isSharingScreenView
              ? t('screenSharingViewUserLabel')
              : t('whiteBoardSharingViewUserLabel')}
          </div>
        </div>
      )
    }

    return null
  }

  const isInPhone = useMemo(() => {
    return member.properties?.phoneState?.value == '1'
  }, [member.properties?.phoneState?.value])

  return isAudioMode ? (
    <AudioCard
      member={member}
      style={{
        ...style,
      }}
      className={`relative ${member.uuid}-${type}  ${
        showBorder ? 'nemeeting-active-border' : ''
      } ${className || ''}`}
      onClick={(e) => onCardClick(e)}
      onCallClick={handleCallClick}
    >
      <span className="nemeeting-ios-time" ref={viewRef}></span>
    </AudioCard>
  ) : (
    <div
      id={`nemeeting-${member.uuid}-video-card-${type}`}
      className={classNames(
        `video-view-wrap relative ${member.uuid}-${type}  ${
          showBorder ? 'nemeeting-active-border' : ''
        } ${className || ''}`,
        {
          [`nemeeting-main-video-card`]: isMain,
        }
      )}
      style={{
        ...style,
        background: '#3D3D3D',
      }}
      onDoubleClick={() => {
        handleDoubleClick()
      }}
      onClick={(e) => onCardClick(e)}
      onMouseLeave={() => {
        mouseLeaveTimerRef.current = setTimeout(() => {
          setIsMouseLeave(true)
        }, 2000)
      }}
      onMouseEnter={() => {
        mouseLeaveTimerRef.current && clearTimeout(mouseLeaveTimerRef.current)
        setIsMouseLeave(false)
      }}
    >
      {type !== 'whiteboard' ? (
        <>
          {type === 'video' ? (
            <div
              className={classNames('nemeeting-video-card-emoticons-container')}
            >
              <Emoticons
                size={56}
                isHandsUp={member.isHandsUp}
                userUuid={member.uuid}
                onlyHandsUp
              />
              <Emoticons size={56} userUuid={member.uuid} />
            </div>
          ) : null}
          <div
            // 标记video container
            id={`nemeeting-video-container-${member.uuid}-${type}`}
            ref={viewRef}
            className={`video-view h-full w-full ${
              member.uuid
            }-${type}-${isMain} ${
              mirroring && type === 'video' ? 'nemeeting-video-mirror' : ''
            }`}
            style={{
              display:
                (type === 'video' && member.isVideoOn && !isInPhone) ||
                (type === 'screen' && member.isSharingScreen && !isMySelf)
                  ? 'block'
                  : 'none',
            }}
          >
            {zoomToast ? (
              <div className="nemeeting-canvas-zoom-toast">{zoomToast}</div>
            ) : null}
            {type === 'screen' ? (
              <>
                <div className="nemeeting-canvas-transform-wrapper">
                  <TransformWrapper
                    ref={transformWrapperRef}
                    minScale={minScale}
                    maxScale={maxScale}
                    initialScale={1}
                    onTransformed={onTransformed}
                    onWheelStop={onWheelStop}
                    disabled={isH5}
                  >
                    <TransformComponent>
                      <div
                        id={`nemeeting-canvas-container-${member.uuid}-${type}`}
                        className="nemeeting-canvas-container"
                        ref={canvasContainerRef}
                      >
                        <div
                          className="video-view-screen-share-annotation"
                          style={{
                            display: meetingInfo.annotationEnabled
                              ? 'block'
                              : 'none',
                            pointerEvents:
                              !isMain ||
                              speakerRightResizing ||
                              !meetingInfo.annotationDrawEnabled
                                ? 'none'
                                : 'visible',
                          }}
                          ref={annotationRef}
                        >
                          <AnnotationView isMain={isMain} isEnable={true} />
                        </div>
                      </div>
                    </TransformComponent>
                  </TransformWrapper>
                </div>
              </>
            ) : null}
            <span className="nemeeting-ios-time">{iosTime || ''}</span>
          </div>
          {((type === 'video' && (!member.isVideoOn || isInPhone)) ||
            (type === 'screen' && !isMain && isMySelf)) && (
            <div
              className="h-full w-full"
              style={{
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
                backgroundColor:
                  member.inviteState === NEMeetingInviteStatus.waitingJoin ||
                  member.inviteState === NEMeetingInviteStatus.waitingCall
                    ? 'rgba(0, 0, 0, 0.64)'
                    : 'none',
              }}
            >
              <UserAvatar
                onCallClick={handleCallClick}
                size={avatarSize || 32}
                nickname={member.name}
                avatar={member.avatar}
                inviteState={member.inviteState}
                className="video-view-nickname-avatar absolute"
              />
              {inviteStateContent}
              {CallingIcon}
            </div>
          )}
          {/* 本端正在共享 */}
          {type === 'screen' && isMySelf && isMain && (
            <div
              className="h-full w-full"
              style={{
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
              }}
            >
              <div>
                <p>{t('screenShareMyself')}</p>
                <Button
                  danger
                  className="nemeeting-screen-stop-btn"
                  onClick={handleStopShareScreen}
                >
                  {t('screenShareStop')}
                </Button>
              </div>
            </div>
          )}
          {/* 更多快捷操作 */}
          {!isH5 && !member.inviteState && (
            <Dropdown
              getPopupContainer={() =>
                document.querySelector('.meeting-web-wrapper') || document.body
              }
              rootClassName="nemeeting-member-operator-dropdown"
              trigger={['click']}
              menu={{ items: operatorItems }}
              placement="bottomRight"
            >
              <div
                className={classNames('nemeeting-video-card-operate', {
                  ['nemeeting-video-card-operate-extra-top']: operateExtraTop,
                })}
              >
                <svg className="icon iconfont icon-operator" aria-hidden="true">
                  <use xlinkHref="#iconzimugengduo"></use>
                </svg>
              </div>
            </Dropdown>
          )}

          {/* 系统通话提醒 */}
          {isInPhone && (
            <div className="nemeeting-invite-state">
              <div
                className="invite-state-wrapper"
                style={{
                  fontSize: '24px',
                }}
              >
                <div className="nemeeting-answeringPhone-icon">
                  <svg className="icon iconfont" aria-hidden="true">
                    <use xlinkHref="#icondaihujiao"></use>
                  </svg>
                </div>
                {showInPhoneTip && (
                  <div className="nemeeting-answeringPhone-tip">
                    {t('answeringPhone')}
                  </div>
                )}
              </div>
            </div>
          )}
          {!member.isSharingScreenView && !nicknameHide && (
            <div className="nick-and-focus-wrap">
              <div className={'nickname-tip'}>
                <div className="nickname">
                  {isNetworkQualityBad && (
                    <svg
                      className="icon iconfont icon-hover icon-red nemeeting-card-network"
                      aria-hidden="true"
                    >
                      <use xlinkHref="#icona-zu684" />
                    </svg>
                  )}
                  {!member.inviteState && member.isAudioConnected ? (
                    member.isAudioOn ? (
                      <AudioIcon
                        className="icon iconfont"
                        audioLevel={member.volume || 0}
                        memberId={member.uuid}
                      />
                    ) : (
                      <svg
                        className="icon icon-red iconfont"
                        aria-hidden="true"
                      >
                        <use xlinkHref="#iconkaiqimaikefeng-mianxing"></use>
                      </svg>
                    )
                  ) : null}
                  {nickName}
                </div>
              </div>
              {showCancelFocusBtn || canShowCancelPinBtn ? (
                <div
                  onClick={() =>
                    cancelFocus(showCancelFocusBtn ? 'focus' : 'pin')
                  }
                  className={`cancel-focus ${focusBtnClassName || ''}`}
                >
                  <svg
                    className="icon iconfont icongudingshipin"
                    aria-hidden="true"
                  >
                    <use xlinkHref="#iconquxiaosuoding"></use>
                  </svg>
                  <span className="cancel-focus-title">
                    {showCancelFocusBtn
                      ? t('participantUnassignActiveSpeaker')
                      : t('meetingUnpin')}
                  </span>
                </div>
              ) : (
                canShowMainPinBtn && (
                  <div
                    onClick={() => pinView()}
                    className={`cancel-focus ${focusBtnClassName || ''}`}
                  >
                    <svg
                      className="icon iconfont icongudingshipin"
                      aria-hidden="true"
                    >
                      <use xlinkHref="#iconsuodingshipin"></use>
                    </svg>
                    <span className="cancel-focus-title">
                      {t('meetingPinView')}
                    </span>
                  </div>
                )
              )}
            </div>
          )}
        </>
      ) : (
        <WhiteboardView
          isEnable={!!meetingInfo.whiteboardUuid && !meetingInfo.screenUuid}
          className={
            meetingInfo.enableFixedToolbar ? '' : 'nemeeting-whiteboard-custom'
          }
          isMainWindow={isMain}
        />
      )}
      {renderSharingViewUserLabel()}
    </div>
  )
}

export default React.memo(VideoCard)
