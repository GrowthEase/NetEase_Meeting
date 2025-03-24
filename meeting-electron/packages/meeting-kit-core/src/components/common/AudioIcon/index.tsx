import React, { useEffect } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import { EventType } from '../../../types'

interface AudioIconProps {
  audioLevel?: number
  className?: string
  dark?: boolean
  memberId?: string
}

const AudioIcon: React.FC<AudioIconProps> = (props) => {
  const { audioLevel = 0, className, dark = false, memberId } = props
  const [openAudioImage, setOpenAudioImage] = React.useState('iconyinliang0hei')
  const { meetingInfo } = useMeetingInfoContext()
  const { eventEmitter } = useGlobalContext()

  const localMember = meetingInfo.localMember

  function getAudioImage(level: number) {
    if (level === 0) {
      setOpenAudioImage(!dark ? 'iconyinliang0' : 'iconyinliang0hei')
    } else if (level >= 1 && level < 30) {
      setOpenAudioImage(!dark ? 'iconyinliang11' : 'iconyinliang1hei')
    } else if (level >= 31 && level < 70) {
      setOpenAudioImage(!dark ? 'iconyinliang21' : 'iconyinliang2hei')
    } else if (level >= 71 && level < 90) {
      setOpenAudioImage(!dark ? 'iconyinliang3' : 'iconyinliang3hei')
    } else if (level >= 90) {
      setOpenAudioImage(!dark ? 'iconyinliang4' : 'iconyinliang4hei')
    }
  }

  useEffect(() => {
    if (!memberId) {
      return
    }

    if (memberId === meetingInfo.localMember.uuid) {
      eventEmitter?.on(EventType.RtcLocalAudioVolumeIndication, getAudioImage)
      return () => {
        eventEmitter?.off(
          EventType.RtcLocalAudioVolumeIndication,
          getAudioImage
        )
      }
    } else {
      const handleAudioVolumeIndication = (
        arr: { userUuid: string; volume: number }[]
      ) => {
        arr.forEach((item) => {
          if (item.userUuid === memberId) {
            getAudioImage(item.volume)
          }
        })
      }

      eventEmitter?.on(
        EventType.RtcAudioVolumeIndication,
        handleAudioVolumeIndication
      )
      return () => {
        eventEmitter?.off(
          EventType.RtcAudioVolumeIndication,
          handleAudioVolumeIndication
        )
      }
    }
  }, [eventEmitter, localMember.uuid, meetingInfo.isInterpreter])

  useEffect(() => {
    getAudioImage(audioLevel)
  }, [audioLevel, dark])

  return (
    <svg className={`icon iconfont ${className || ''}`} aria-hidden="true">
      <use xlinkHref={`#${openAudioImage}`} />
    </svg>
  )
}

export default AudioIcon
