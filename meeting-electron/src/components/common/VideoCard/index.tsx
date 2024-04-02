import React, {
  CSSProperties,
  LegacyRef,
  MutableRefObject,
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
  AttendeeOffType,
  AvatarSize,
  EventType,
  GlobalContext as GlobalContextInterface,
  NEMember,
  Role,
} from '../../../types'
import AudioIcon from '../AudioIcon'
import './index.less'

import { debounce, substringByByte3 } from '../../../utils'
import UserAvatar from '../Avatar'
import AudioCard from './audioCard'
import { worker } from '../../web/Meeting/Meeting'

interface VideoCardProps {
  isMySelf: boolean
  member: NEMember
  isMain: boolean
  sliderMembersLength?: number
  streamType?: 0 | 1
  type?: 'video' | 'screen'
  isSubscribeVideo?: boolean // 是否订阅视频流
  className?: string
  showBorder?: boolean // 是否显示绿框
  onClick?: (e: any) => void
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
  unsubscribeMembersTimerMap?: MutableRefObject<Record<string, any>>
}

const VideoCard: React.FC<VideoCardProps> = (props) => {
  const {
    streamType = 0,
    sliderMembersLength,
    member,
    className,
    onClick,
    isMySelf,
    isMain,
    showBorder,
    iosTime,
    canShowCancelFocusBtn,
    focusBtnClassName,
    style,
    mirroring,
    avatarSize,
    isAudioMode,
    onDoubleClick,
    unsubscribeMembersTimerMap,
  } = props
  const { t } = useTranslation()
  const type = props.type || 'video'
  const { dispatch, meetingInfo } = useContext(MeetingInfoContext)
  const { neMeeting, eventEmitter } =
    useContext<GlobalContextInterface>(GlobalContext)
  const viewRef = useRef<HTMLDivElement | null>(null)
  const canvasRef = useRef<HTMLCanvasElement | null>(null)
  const timer = useRef<any>(null)
  const videoSizeTimer = useRef<any>(null)
  const refreshRateCountRef = useRef<number>(0)
  const resolutionWidthRef = useRef<number>(0)
  const resolutionHeightRef = useRef<number>(0)
  const [refreshRate, setRefreshRate] = useState<number>(0)

  const isMainVideo = useMemo<boolean>(() => {
    return isMain && type === 'video'
  }, [isMain, type])

  // 是否需要订阅当前流，非当前页面则不订阅
  const isSubscribeVideo = useMemo(() => {
    return props.isSubscribeVideo !== false
  }, [props.isSubscribeVideo])

  const isCanvasVisible = useMemo(() => {
    return (
      type === 'screen' ||
      (member.isVideoOn && isSubscribeVideo && type === 'video')
    )
  }, [type, member.isVideoOn, isSubscribeVideo])

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
          if (
            unsubscribeMembersTimerMap &&
            unsubscribeMembersTimerMap.current[member.uuid]
          ) {
            clearTimeout(unsubscribeMembersTimerMap.current[member.uuid])
            unsubscribeMembersTimerMap.current[member.uuid] = null
            delete unsubscribeMembersTimerMap.current[member.uuid]
          }
        },
        window.isElectronNative ? 100 : 0
      )
    }
  }, 300)

  const showCancelFocusBtn = useMemo(() => {
    return (
      canShowCancelFocusBtn &&
      !meetingInfo.isRooms &&
      meetingInfo.showFocusBtn !== false
    )
  }, [canShowCancelFocusBtn, meetingInfo.isRooms, meetingInfo.showFocusBtn])

  const canShowCancelPinBtn = useMemo(() => {
    return (
      (!canShowCancelFocusBtn || !meetingInfo.showFocusBtn) &&
      isMain &&
      !meetingInfo.focusUuid &&
      meetingInfo.pinVideoUuid === member.uuid &&
      type !== 'screen'
    )
  }, [
    showCancelFocusBtn,
    meetingInfo.pinVideoUuid,
    member.uuid,
    type,
    meetingInfo.focusUuid,
  ])
  const canShowMainPinBtn = useMemo(() => {
    return (
      isMain && !meetingInfo.focusUuid && type != 'screen' && member.isVideoOn
    )
  }, [meetingInfo.focusUuid, isMain, type, member.isVideoOn])
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
  const nickName = useMemo(() => {
    return substringByByte3(member.name, 20)
  }, [member.name])

  useEffect(() => {
    if (member.isVideoOn && type !== 'screen') {
      if (!isMySelf) {
        playRemoteVideo()
      }
    }
  }, [streamType])
  useEffect(() => {
    if (isMySelf) {
      // 设置本端画布
      viewRef.current &&
        neMeeting?.rtcController?.setupLocalVideoCanvas(viewRef.current)
      // isVideoOn存在值则非第一次进入会议
      if (member.isVideoOn) {
        neMeeting?.rtcController?.playLocalStream('video')
      } else {
        //  第一次进入会议，且不是 Electron
        // if (!window.isElectronNative) {
        const isHost = member.role === Role.host || member.role === Role.coHost
        // 如果开启音视频进入会议
        if (
          meetingInfo.isUnMutedVideo &&
          (meetingInfo.videoOff === AttendeeOffType.disable || isHost)
        ) {
          neMeeting?.unmuteLocalVideo()
        }

        if (
          meetingInfo.isUnMutedAudio &&
          (meetingInfo.audioOff === AttendeeOffType.disable || isHost)
        ) {
          neMeeting?.unmuteLocalAudio()
        }
        // 后续设置为false
        dispatch &&
          dispatch({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              isUnMutedVideo: false,
              isUnMutedAudio: false,
            },
          })
        // }
      }
    } else {
      if (type === 'screen') {
        playRemoteSubVideo()
      } else {
        if (member.isVideoOn) {
          if (isSubscribeVideo) {
            playRemoteVideo()
          } else {
            timer.current = setTimeout(() => {
              neMeeting?.unsubscribeRemoteVideoStream(member.uuid, streamType)
              timer.current = null
            }, 5000)
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
        timer.current = setTimeout(() => {
          neMeeting?.unsubscribeRemoteVideoStream(member.uuid, streamType)
          timer.current = null
        }, 10000)
      } else {
        if (timer.current) {
          clearTimeout(timer.current)
          timer.current = null
        }
        playRemoteVideo()
      }
    }
  })
  useWatch<boolean>(member.isVideoOn, (preIsVideoOn) => {
    if (member.isVideoOn === preIsVideoOn) {
      return
    }
    if (type === 'screen') {
      return
    } else {
      // 非视频共享view
      if (member.isVideoOn) {
        if (isMySelf) {
          // 本端直接播放
          neMeeting?.rtcController?.playLocalStream('video')
        } else {
          if (isSubscribeVideo) {
            playRemoteVideo()
          } else {
            neMeeting?.unsubscribeRemoteVideoStream(member.uuid, streamType)
          }
        }
      } else {
        // 非本端取消订阅
        !isMySelf &&
          neMeeting?.unsubscribeRemoteVideoStream(member.uuid, streamType)
      }
    }
  })
  useWatch<boolean>(member.isSharingScreen, (preIsSharingScreen) => {
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

  function onCardClick(e: any) {
    onClick?.(e)
  }
  // 透明白板需要，根据不同分辨率保存当前主画面的大小
  const setMainVideoSize = async () => {
    if (isMainVideo && member.isVideoOn) {
      videoSizeTimer.current && clearTimeout(videoSizeTimer.current)
      videoSizeTimer.current = null
      const videoSize = {
        width: 0,
        height: 0,
      }
      const mainDom = viewRef.current as HTMLElement
      let videoInfo
      if (isMySelf) {
        const localVideoStats = await neMeeting?.getLocalVideoStats()
        if (localVideoStats && localVideoStats.length > 0) {
          const videoStat = localVideoStats[0]
          videoInfo = {
            renderResolutionWidth: videoStat.captureResolutionWidth,
            renderResolutionHeight: videoStat.captureResolutionHeight,
          }
        } else {
          videoSizeTimer.current = setTimeout(() => {
            setMainVideoSize()
          }, 1500)
          return
        }
      } else {
        const videoStats = await neMeeting?.getRemoteVideoStats()
        if (videoStats && videoStats.length > 0) {
          const videoStat = videoStats.find(
            (_member) => _member.userUuid == String(member.rtcUid)
          )
          if (videoStat) {
            const layer = videoStat.layers[0]
            videoInfo = {
              renderResolutionWidth: layer.RenderResolutionWidth,
              renderResolutionHeight: layer.RenderResolutionHeight,
            }
          }
        } else {
          videoSizeTimer.current = setTimeout(() => {
            setMainVideoSize()
          }, 1500)
          return
        }
      }
      if (videoInfo) {
        // const videoStat = videoInfo.layers[0]
        if (
          videoInfo.renderResolutionHeight >= videoInfo.renderResolutionWidth
        ) {
          videoSize.height = mainDom.clientHeight
          videoSize.width =
            mainDom.clientHeight *
            (videoInfo.renderResolutionWidth / videoInfo.renderResolutionHeight)
        } else {
          videoSize.width = mainDom.clientWidth
          videoSize.height =
            mainDom.clientWidth *
            (videoInfo.renderResolutionHeight / videoInfo.renderResolutionWidth)
        }
      }
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          mainVideoSize: {
            width: videoSize.width,
            height: videoSize.height,
          },
        },
      })
    }
  }

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

  const handleVideoFrame = useCallback(
    (canvas) => {
      return (uuid, bSubVideo, data, _, width, height) => {
        if (uuid === member.uuid) {
          if (
            (bSubVideo && type === 'screen') ||
            (!bSubVideo && type === 'video')
          ) {
            if (canvas && viewRef.current) {
              const viewWidth = viewRef.current.clientWidth
              const viewHeight = viewRef.current.clientHeight
              if (viewWidth / (width / height) > viewHeight) {
                canvas.style.height = `${viewHeight}px`
                canvas.style.width = `${viewHeight * (width / height)}px`
              } else {
                canvas.style.width = `${viewWidth}px`
                canvas.style.height = `${viewWidth / (width / height)}px`
              }
            }
            resolutionWidthRef.current = width
            resolutionHeightRef.current = height
            refreshRateCountRef.current++
          }
        }
      }
    },
    [member.uuid, type]
  )

  useEffect(() => {
    if (meetingInfo.isDebugMode) {
      const timer = setInterval(() => {
        setRefreshRate(refreshRateCountRef.current)
        refreshRateCountRef.current = 0
      }, 1000)
      return () => {
        clearInterval(timer)
      }
    }
  }, [meetingInfo.isDebugMode])

  useEffect(() => {
    if (member.isSharingScreen && type === 'screen') {
      const canvas = canvasRef.current
      if (canvas && viewRef.current) {
        // @ts-ignore
        const offscreen = canvas.transferControlToOffscreen()
        worker.postMessage(
          {
            canvas: offscreen,
            uuid: member.uuid,
            type,
          },
          [offscreen]
        )
        const handle = handleVideoFrame(canvas)
        eventEmitter?.on(EventType.onVideoFrameData, handle)
        return () => {
          eventEmitter?.off(EventType.onVideoFrameData, handle)
          worker.postMessage({
            removeCanvas: true,
            uuid: member.uuid,
            type,
          })
        }
      }
    }
  }, [
    eventEmitter,
    member.isSharingScreen,
    type,
    handleVideoFrame,
    member.uuid,
  ])

  useEffect(() => {
    if (member.isVideoOn && isSubscribeVideo && type === 'video') {
      const canvas = canvasRef.current
      if (canvas && viewRef.current) {
        // @ts-ignore
        const offscreen = canvas.transferControlToOffscreen()
        worker.postMessage(
          {
            canvas: offscreen,
            uuid: member.uuid,
            type,
          },
          [offscreen]
        )
        const handle = handleVideoFrame(canvas)
        eventEmitter?.on(EventType.onVideoFrameData, handle)
        return () => {
          eventEmitter?.off(EventType.onVideoFrameData, handle)
          worker.postMessage({
            removeCanvas: true,
            uuid: member.uuid,
            type,
          })
        }
      }
    }
  }, [
    eventEmitter,
    type,
    member.isVideoOn,
    isSubscribeVideo,
    handleVideoFrame,
    member.uuid,
  ])

  return isAudioMode ? (
    <AudioCard
      member={member}
      style={{ ...style }}
      className={`relative ${member.uuid}-${type}  ${
        showBorder ? 'nemeeting-active-border' : ''
      } ${className || ''}`}
      onClick={(e) => onCardClick(e)}
    >
      <span className="nemeeting-ios-time" ref={viewRef}></span>
    </AudioCard>
  ) : (
    <div
      id={`nemeeting-${member.uuid}-video-card-${type}`}
      className={`video-view-wrap relative ${member.uuid}-${type}  ${
        showBorder ? 'nemeeting-active-border' : ''
      } ${className || ''}`}
      style={{
        ...style,
      }}
      onDoubleClick={(e) => {
        handleDoubleClick()
      }}
      onClick={(e) => onCardClick(e)}
    >
      {!!meetingInfo.isDebugMode && (
        <div className="resolution">
          {resolutionWidthRef.current}x{resolutionHeightRef.current}{' '}
          {refreshRate}Hz
        </div>
      )}
      {showCancelFocusBtn || canShowCancelPinBtn ? (
        <div
          onClick={() => cancelFocus(showCancelFocusBtn ? 'focus' : 'pin')}
          className={`cancel-focus ${focusBtnClassName || ''}`}
        >
          <svg className="icon iconfont icongudingshipin" aria-hidden="true">
            <use xlinkHref="#icongudingshipin"></use>
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
            <svg className="icon iconfont icongudingshipin" aria-hidden="true">
              <use xlinkHref="#icongudingshipin"></use>
            </svg>
            <span className="cancel-focus-title">{t('meetingPinView')}</span>
          </div>
        )
      )}

      {member.properties?.phoneState?.value == '1' &&
        !member.isSharingScreen && (
          <>
            <div className={`video-view-phone-nickname`}>
              <div className={'video-view-phone-content'}>
                <div className="nemeeting-audio-card nemeeting-audio-phone-card">
                  {/* {!member.isAudioOn && (
                    <svg className="icon icon-red iconfont" aria-hidden="true">
                      <use xlinkHref="#iconyx-tv-voice-offx"></use>
                    </svg>
                  )} */}
                  <UserAvatar
                    size={avatarSize || 32}
                    nickname={member.name}
                    avatar={member.avatar}
                    className=""
                  />
                  <div className="nemeeting-audio-card-phone-icon">
                    <svg
                      className="icon iconfont nemeeting-icon-phone"
                      style={{ fontSize: avatarSize == 32 ? '18px' : '32px' }}
                      aria-hidden="true"
                    >
                      <use xlinkHref="#icondianhua"></use>
                    </svg>
                  </div>
                </div>
              </div>
              <div className="answer-ring-phone">{t('answeringPhone')}</div>
            </div>
          </>
        )}
      <div
        ref={viewRef}
        className={`video-view h-full w-full ${member.uuid}-${type}-${isMain} ${
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
        {isCanvasVisible && window.isElectronNative && (
          <canvas ref={canvasRef} className="nemeeting-video-view-canvas" />
        )}
        <span className="nemeeting-ios-time">{iosTime || ''}</span>
      </div>
      {((type === 'video' && !member.isVideoOn) ||
        (type === 'screen' && (!member.isSharingScreen || isMySelf))) && (
        <UserAvatar
          size={avatarSize || 32}
          nickname={member.name}
          avatar={member.avatar}
          className="video-view-nickname-avatar absolute"
        />
      )}

      <div className={'nickname-tip'}>
        <div className="nickname">
          {member.isAudioConnected ? (
            member.isAudioOn ? (
              <AudioIcon
                className="icon iconfont"
                audioLevel={member.volume || 0}
                memberId={member.uuid}
              />
            ) : (
              <svg className="icon icon-red iconfont" aria-hidden="true">
                <use xlinkHref="#iconyx-tv-voice-offx"></use>
              </svg>
            )
          ) : null}
          {nickName}
        </div>
      </div>
    </div>
  )
}

export default React.memo(VideoCard)
