import React, {
  CSSProperties,
  LegacyRef,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react'
import './index.less'
import {
  AttendeeOffType,
  NEMember,
  Role,
  ActionType,
  GlobalContext as GlobalContextInterface,
} from '../../../types'
import { GlobalContext, MeetingInfoContext } from '../../../store'
import useWatch from '../../../hooks/useWatch'
import { useTranslation } from 'react-i18next'

interface VideoCardProps {
  isMySelf: boolean
  member: NEMember
  isMain: boolean
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
}

const VideoCard: React.FC<VideoCardProps> = (props) => {
  const {
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
  } = props
  const { t } = useTranslation()
  const type = props.type || 'video'
  const { dispatch, meetingInfo } = useContext(MeetingInfoContext)
  const { neMeeting } = useContext<GlobalContextInterface>(GlobalContext)
  const viewRef = useRef<HTMLDivElement | null>(null)
  const timer = useRef<any>(null)
  const videoSizeTimer = useRef<any>(null)
  const streamType = useMemo(() => {
    return isMain ? 0 : 1
  }, [isMain])

  const isMainVideo = useMemo<boolean>(() => {
    return isMain && type === 'video'
  }, [isMain, type])

  // 是否需要订阅当前流，非当前页面则不订阅
  const isSubscribeVideo = useMemo(() => {
    return props.isSubscribeVideo !== false
  }, [props.isSubscribeVideo])

  const playRemoteVideo = () => {
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
      neMeeting?.rtcController?.subscribeRemoteVideoStream(
        member.uuid,
        streamType
      )
    }
  }
  const playRemoteSubVideo = () => {
    if (isMySelf || type !== 'screen') {
      return
    }
    viewRef.current &&
      neMeeting?.rtcController?.setupRemoteVideoSubStreamCanvas(
        viewRef.current,
        member.uuid
      )
    neMeeting?.rtcController?.subscribeRemoteVideoSubStream(member.uuid)
  }
  useEffect(() => {
    console.log('videoCard mounted', member.uuid, isSubscribeVideo)
    if (isMySelf) {
      // 设置本端画布
      viewRef.current &&
        neMeeting?.rtcController?.setupLocalVideoCanvas(viewRef.current)

      // isVideoOn存在值则非第一次进入会议
      if (member.isVideoOn) {
        neMeeting?.rtcController?.playLocalStream('video')
      } else {
        // 第一次进入会议
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
      }
    } else {
      if (type === 'screen') {
        playRemoteSubVideo()
      } else {
        if (member.isVideoOn) {
          if (isSubscribeVideo) {
            playRemoteVideo()
          } else {
            console.log('取消订阅1', member.uuid)
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
        console.log('开始取消订阅视频', member.uuid)
        timer.current = setTimeout(() => {
          neMeeting?.rtcController?.unsubscribeRemoteVideoStream(
            member.uuid,
            streamType
          )
          timer.current = null
        }, 10000)
      } else {
        if (timer.current) {
          console.log('开始清除定时器', member.uuid)
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
            console.log('取消订阅2', member.uuid)
            neMeeting?.rtcController?.unsubscribeRemoteVideoStream(
              member.uuid,
              streamType
            )
          }
        }
      } else {
        console.log('取消订阅3', member.uuid)
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
          console.log('未获取到信息重新获取')
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

  useEffect(() => {
    // 获取目标元素
    function getPosition() {
      setTimeout(() => {
        if ((member.isVideoOn && isSubscribeVideo) || type === 'screen') {
          const targetElement = document.getElementById(
            `nemeeting-${member.uuid}-video-card-${type}`
          )
          if (targetElement) {
            console.log('videoCard getPosition', targetElement)
            const observer = new IntersectionObserver((entries) => {
              if (entries[0].isIntersecting) {
                const rect = targetElement.getBoundingClientRect()
                // 计算相对于<body>的位置
                const bodyRect = document.body.getBoundingClientRect()
                const relativePosition = {
                  x: rect.x - bodyRect.x,
                  y: rect.y - bodyRect.y,
                  width: targetElement.clientWidth,
                  height: targetElement.clientHeight,
                }
                // @ts-ignore
                if (window.ipcRenderer) {
                  // @ts-ignore
                  window.ipcRenderer.send('nemeeting-video-card-open', {
                    uuid: member.uuid,
                    position: relativePosition,
                    mirroring,
                    type,
                  })
                }
                // 元素进入视窗，可见
              } else {
                // 元素离开视窗，不可见
                // @ts-ignore
                window.ipcRenderer?.send('nemeeting-video-card-close', {
                  uuid: member.uuid,
                  type,
                })
              }
            })
            observer.observe(targetElement)
          }
        }
      }, 300)
    }
    getPosition()
    window.addEventListener('resize', getPosition)
    return () => {
      window.removeEventListener('resize', getPosition)
      // @ts-ignore
      window.ipcRenderer?.send('nemeeting-video-card-close', {
        uuid: member.uuid,
      })
    }
    // 获取元素相对于视口的位置
  }, [
    member.isVideoOn,
    member.uuid,
    isSubscribeVideo,
    meetingInfo.layout,
    meetingInfo.whiteboardUuid,
    meetingInfo.focusUuid,
    mirroring,
    type,
    meetingInfo.screenUuid,
  ])

  return (
    <div
      id={`nemeeting-${member.uuid}-video-card-${type}`}
      className={`video-view-wrap relative ${member.uuid}-${type}  ${
        showBorder ? 'nemeeting-active-border' : ''
      } ${className || ''}`}
      style={{
        ...style,
        background:
          // @ts-ignore
          window.NERoomNode && member.isVideoOn && isSubscribeVideo
            ? 'transparent'
            : undefined,
      }}
      onClick={(e) => onCardClick(e)}
    >
      {canShowCancelFocusBtn && (
        <div
          onClick={cancelFocus}
          className={`cancel-focus ${focusBtnClassName || ''}`}
        >
          {t('unFocusVideo')}
        </div>
      )}

      {member.properties?.phoneState?.value == '1' && !member.isSharingScreen && (
        <div className={'video-view-phone'}>
          <div className={'video-view-phone-content'}>
            <div>
              <img src={require('../../../assets/hints-error.png')} alt="" />
            </div>
            <div className="answer-ring-phone">{t('answeringPhone')}</div>
          </div>
        </div>
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
        <span className="ios-time">{iosTime || ''}</span>
      </div>
      {((type === 'video' && !member.isVideoOn) ||
        (type === 'screen' && (!member.isSharingScreen || isMySelf))) && (
        <p className={'video-view-nickname absolute'}>
          <span className="icon-audio">
            {member.isAudioOn ? (
              <svg className="icon iconfont" aria-hidden="true">
                <use xlinkHref="#iconyx-tv-voice-onx"></use>
              </svg>
            ) : (
              <svg className="icon icon-red iconfont" aria-hidden="true">
                <use xlinkHref="#iconyx-tv-voice-offx"></use>
              </svg>
            )}
          </span>
          {member.name +
            (type === 'screen' && isMySelf ? t('screenShareLocalTips') : '')}
        </p>
      )}

      <div className={'nickname-tip'}>
        <div className="nickname">
          {type === 'screen' && member.isSharingScreen ? (
            <></>
          ) : member.isAudioOn ? (
            <svg className="icon iconfont" aria-hidden="true">
              <use xlinkHref="#iconyx-tv-voice-onx"></use>
            </svg>
          ) : (
            <svg className="icon icon-red iconfont" aria-hidden="true">
              <use xlinkHref="#iconyx-tv-voice-offx"></use>
            </svg>
          )}
          {member.name}
        </div>
      </div>
    </div>
  )
}

export default React.memo(VideoCard)
