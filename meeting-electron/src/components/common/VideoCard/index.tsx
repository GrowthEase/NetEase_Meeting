import debounce from 'lodash/debounce'
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
import YUVCanvas from '../../../libs/yuv-canvas'
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

import errorHitImg from '../../../assets/hints-error.png'
import { substringByByte3 } from '../../../utils'
import UserAvatar from '../Avatar'
import AudioCard from './audioCard'

interface VideoCardProps {
  isMySelf: boolean
  member: NEMember
  isMain: boolean
  sliderMembersLength?: number
  streamType?: number
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
  // 是否需要提前订阅大流
  avatarSize?: AvatarSize
  isAudioMode?: boolean
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
    videoViewPosition,
    avatarSize,
    isAudioMode,
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
  const [resolutionWidth, setResolutionWidth] = useState<number>(0)
  const [resolutionHeight, setResolutionHeight] = useState<number>(0)
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
          neMeeting?.rtcController?.subscribeRemoteVideoStream(
            member.uuid,
            streamType
          )
        },
        window.isElectronNative ? 100 : 0
      )
    }
  }, 300)

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
        if (!window.isElectronNative) {
          const isHost =
            member.role === Role.host || member.role === Role.coHost
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
        }
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
              neMeeting?.rtcController?.unsubscribeRemoteVideoStream(
                member.uuid,
                streamType
              )
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
          neMeeting?.rtcController?.unsubscribeRemoteVideoStream(
            member.uuid,
            streamType
          )
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
            neMeeting?.rtcController?.unsubscribeRemoteVideoStream(
              member.uuid,
              streamType
            )
          }
        }
      } else {
        // 非本端取消订阅
        !isMySelf &&
          neMeeting?.rtcController?.unsubscribeRemoteVideoStream(
            member.uuid,
            streamType
          )
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

  const cancelFocus = () => {
    neMeeting?.sendHostControl(31, member.uuid)
  }

  /** 多窗口模式
  const getPosition = () => {
    if ((member.isVideoOn && isSubscribeVideo) || type === 'screen') {
      const targetElement = document.getElementById(
        `nemeeting-${member.uuid}-video-card-${type}`
      )
      if (targetElement) {
        const rect = targetElement.getBoundingClientRect()
        // 计算相对于<body>的位置
        const bodyRect = document.body.getBoundingClientRect()
        const relativePosition = {
          x: rect.x - bodyRect.x,
          y: rect.y - bodyRect.y,
          width: targetElement.clientWidth,
          height: targetElement.clientHeight,
        }
        window.ipcRenderer?.send('nemeeting-video-card-open', {
          uuid: member.uuid,
          position: relativePosition,
          mirroring,
          type,
          isMySelf: member.uuid === meetingInfo.localMember.uuid,
          streamType,
        })
      }
    }
  }
  */

  /** 多窗口模式
  useEffect(() => {
    if (window.isElectronNative) {
      window.ipcRenderer?.send('nemeeting-video-card-close', {
        uuid: member.uuid,
        type,
      })

      const windowResizeTimer: any = null

      const timer = setTimeout(() => {
        getPosition()
      }, 0)

      const targetElement = document.getElementById(
        `nemeeting-${member.uuid}-video-card-${type}`
      )

      let isResize = false

      const ro = new ResizeObserver((entries) => {
        if (entries.length > 0 && isResize) {
          windowResizeTimer && clearTimeout(windowResizeTimer)
          getPosition()
        } else {
          isResize = true
        }
      })
      ro.observe(targetElement as HTMLElement)

      window.addEventListener('resize', getPosition)

      return () => {
        window.ipcRenderer?.send('nemeeting-video-card-close', {
          uuid: member.uuid,
          type,
        })
        clearTimeout(timer)

        ro.unobserve(targetElement as HTMLElement)
        windowResizeTimer && clearTimeout(windowResizeTimer)
        window.removeEventListener('resize', getPosition)
      }
    }

    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [
    member.isVideoOn,
    member.uuid,
    isSubscribeVideo,
    meetingInfo.layout,
    meetingInfo.whiteboardUuid,
    meetingInfo.focusUuid,
    // 先取出订阅，否则在设置页面修改镜像时候，画面会直接没有，渲染到主画面上
    // mirroring,
    type,
    meetingInfo.screenUuid,
    meetingInfo.isRooms,
    sliderMembersLength,
  ])
  */

  /**  多窗口模式
  useUpdateEffect(() => {
    if (window.isElectronNative) {
      getPosition()
    }
  }, [videoViewPosition])
  */

  useEffect(() => {
    // 处理 Electron  入会
    if (isMySelf && window.isElectronNative) {
      function handleMemberJoinRtcChannel(members) {
        const my = members.find((item) => item.uuid === member.uuid)
        if (my && !member.isVideoOn) {
          const isHost =
            member.role === Role.host || member.role === Role.coHost
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
        }
      }
      eventEmitter?.on(
        EventType.MemberJoinRtcChannel,
        handleMemberJoinRtcChannel
      )
      return () => {
        eventEmitter?.off(
          EventType.MemberJoinRtcChannel,
          handleMemberJoinRtcChannel
        )
      }
    }
  }, [isMySelf, eventEmitter, member, meetingInfo, neMeeting, dispatch])

  const handleVideoFrame = useCallback(
    (yuvCanvas, canvas) => {
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
            const uvWidth = width / 2
            let pixelStorei = 1
            if (uvWidth % 8 === 0) {
              pixelStorei = 8
            } else if (uvWidth % 4 === 0) {
              pixelStorei = 4
            } else if (uvWidth % 2 === 0) {
              pixelStorei = 2
            }
            const buffer = {
              format: {
                width,
                height,
                chromaWidth: width / 2,
                chromaHeight: height / 2,
                cropLeft: 0, // default
                cropTop: 0, // default
                cropHeight: height,
                cropWidth: width,
                displayWidth: width, // derived from width via cropWidth
                displayHeight: height, // derived from cropHeight
                pixelStorei, // default
              },
              ...data,
            }
            yuvCanvas.drawFrame(buffer)
            setResolutionWidth(width)
            setResolutionHeight(height)
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
        const yuv = YUVCanvas.attach(canvas)
        const handle = handleVideoFrame(yuv, canvas)
        eventEmitter?.on(EventType.onVideoFrameData, handle)
        return () => {
          yuv.clear()
          yuv.destroy()
          eventEmitter?.off(EventType.onVideoFrameData, handle)
        }
      }
    }
  }, [eventEmitter, member.isSharingScreen, type, handleVideoFrame])

  useEffect(() => {
    if (member.isVideoOn && isSubscribeVideo && type === 'video') {
      const canvas = canvasRef.current
      if (canvas && viewRef.current) {
        const yuv = YUVCanvas.attach(canvas)
        const handle = handleVideoFrame(yuv, canvas)
        eventEmitter?.on(EventType.onVideoFrameData, handle)
        return () => {
          yuv.clear()
          yuv.destroy()
          eventEmitter?.off(EventType.onVideoFrameData, handle)
        }
      }
    }
  }, [eventEmitter, type, member.isVideoOn, isSubscribeVideo, handleVideoFrame])

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
        ...((window.isElectronNative && member.isVideoOn && isSubscribeVideo) ||
        type === 'screen'
          ? {
              // background: 'transparent',
              // border: showBorder ? undefined : 'none',
            }
          : {}),
      }}
      onClick={(e) => onCardClick(e)}
    >
      {!!meetingInfo.isDebugMode && (
        <div className="resolution">
          {resolutionWidth}x{resolutionHeight} {refreshRate}Hz
        </div>
      )}
      {canShowCancelFocusBtn &&
        !meetingInfo.isRooms &&
        meetingInfo.showFocusBtn !== false && (
          <div
            onClick={cancelFocus}
            className={`cancel-focus ${focusBtnClassName || ''}`}
          >
            <svg className="icon iconfont" aria-hidden="true">
              <use xlinkHref="#iconjiaodianshipin"></use>
            </svg>
            <span className="cancel-focus-title">{t('unFocusVideo')}</span>
          </div>
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
