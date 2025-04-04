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
import { NEMeetingInviteStatus } from '../../../kit'
import WhiteboardView from '../../web/MeetingCanvas/WhiteboardView'
import { Button } from 'antd'
import Emoticons from '../Emoticons'
import classNames from 'classnames'
import RendererManager from '../../../libs/Renderer/RendererManager'

interface VideoCardProps {
  isMySelf: boolean
  member: NEMember
  isMain: boolean
  streamType?: 0 | 1
  type?: 'video' | 'screen' | 'whiteboard'
  speakerRightResizing?: boolean
  isSubscribeVideo?: boolean // 是否订阅视频流
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
  } = props
  const { t } = useTranslation()
  const type = props.type || 'video'
  const { dispatch, meetingInfo } = useContext(MeetingInfoContext)
  const {
    neMeeting,
    eventEmitter,
    outEventEmitter,
  } = useContext<GlobalContextInterface>(GlobalContext)
  const viewRef = useRef<HTMLDivElement | null>(null)
  const annotationRef = useRef<HTMLDivElement | null>(null)
  const timer = useRef<null | ReturnType<typeof setTimeout>>(null)
  const mouseLeaveTimerRef = useRef<null | ReturnType<typeof setTimeout>>(null)
  const screenShareVideoResolutionRef = useRef<{
    width: number
    height: number
  }>({ width: 0, height: 0 })
  const [isMouseLeave, setIsMouseLeave] = useState<boolean>(true)

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
      viewRef.current &&
        neMeeting?.rtcController?.setupRemoteVideoCanvas(
          viewRef.current,
          member.uuid
        )
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

    viewRef.current &&
      neMeeting?.rtcController?.setupRemoteVideoSubStreamCanvas(
        viewRef.current,
        member.uuid
      )
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
      // 设置本端画布
      viewRef.current &&
        neMeeting?.rtcController?.setupLocalVideoCanvas(viewRef.current)
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
        meetingInfo.isUnMutedVideo &&
        ((meetingInfo.unmuteVideoBySelfPermission &&
          !meetingInfo.videoAllOff) ||
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
        meetingInfo.isUnMutedAudio &&
        (meetingInfoRef.current.setting.audioSetting.usingComputerAudio ||
          isH5) &&
        ((meetingInfo.unmuteAudioBySelfPermission &&
          !meetingInfo.audioAllOff) ||
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
          viewRef.current &&
            neMeeting?.rtcController?.setupLocalVideoCanvas(viewRef.current)
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

  useEffect(() => {
    if (window.isElectronNative) {
      if (
        (member.isVideoOn && isSubscribeVideo && type === 'video') ||
        (member.isSharingScreen && type === 'screen')
      ) {
        if (viewRef.current) {
          const context = {
            view: viewRef.current,
            userUuid: member.uuid,
            sourceType: type,
          }
          const render = RendererManager.instance.createRenderer(context)

          if (type === 'screen') {
            const canvasDom = viewRef.current.getElementsByTagName('canvas')[0]

            const observer = new ResizeObserver(() => {
              if (annotationRef.current) {
                annotationRef.current.style.width = canvasDom.clientWidth + 'px'
                annotationRef.current.style.height =
                  canvasDom.clientHeight + 'px'
              }
            })

            observer.observe(canvasDom)
          }

          return () => {
            RendererManager.instance.removeRenderer(context, render)
          }
        }
      }
    }
  }, [
    eventEmitter,
    type,
    member.isVideoOn,
    isSubscribeVideo,
    member.uuid,
    member.isSharingScreen,
  ])

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

    if (type === 'screen' && !window.isElectronNative && viewDom) {
      const observer = new ResizeObserver(() => {
        resize(screenShareVideoResolutionRef.current)
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
              <use xlinkHref="#iconyx-baiban" />
            </svg>
          ) : (
            <svg className="icon iconfont" aria-hidden="true">
              <use xlinkHref="#iconyx-tv-sharescreen1x" />
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
                (type === 'video' && member.isVideoOn) ||
                (type === 'screen' && member.isSharingScreen && !isMySelf)
                  ? 'block'
                  : 'none',
            }}
          >
            {type === 'screen' ? (
              <div
                className="video-view-screen-share-annotation"
                style={{
                  display: meetingInfo.annotationEnabled ? 'block' : 'none',
                  pointerEvents:
                    !isMain || speakerRightResizing ? 'none' : 'visible',
                }}
                ref={annotationRef}
              >
                <AnnotationView isMain={isMain} isEnable={true} />
              </div>
            ) : null}
            <span className="nemeeting-ios-time">{iosTime || ''}</span>
          </div>
          {((type === 'video' && !member.isVideoOn) ||
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
          {!member.isSharingScreenView && !nicknameHide && (
            <div className="nick-and-focus-wrap">
              <div className={'nickname-tip'}>
                <div className="nickname">
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
                        <use xlinkHref="#iconyx-tv-voice-offx"></use>
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
