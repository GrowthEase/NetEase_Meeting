import React, { useEffect } from 'react'
import AudioImage0 from '../../../assets/audio/0.png'
import AudioImage1 from '../../../assets/audio/1.png'
import AudioImage2 from '../../../assets/audio/2.png'
import AudioImage3 from '../../../assets/audio/3.png'
import AudioImage4 from '../../../assets/audio/4.png'
import AudioImageDark0 from '../../../assets/audio/dark-0.png'
import AudioImageDark1 from '../../../assets/audio/dark-1.png'
import AudioImageDark2 from '../../../assets/audio/dark-2.png'
import AudioImageDark3 from '../../../assets/audio/dark-3.png'
import AudioImageDark4 from '../../../assets/audio/dark-4.png'
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
  const [openAudioImage, setOpenAudioImage] = React.useState(AudioImage0)
  const { meetingInfo } = useMeetingInfoContext()
  const { eventEmitter } = useGlobalContext()

  const localMember = meetingInfo.localMember

  function getAudioImage(level: number) {
    if (level === 0) {
      setOpenAudioImage(dark ? AudioImageDark0 : AudioImage0)
    } else if (level >= 1 && level < 30) {
      setOpenAudioImage(dark ? AudioImageDark1 : AudioImage1)
    } else if (level >= 31 && level < 70) {
      setOpenAudioImage(dark ? AudioImageDark2 : AudioImage2)
    } else if (level >= 71 && level < 90) {
      setOpenAudioImage(dark ? AudioImageDark3 : AudioImage3)
    } else if (level >= 90) {
      setOpenAudioImage(dark ? AudioImageDark4 : AudioImage4)
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

  return <img src={openAudioImage} className={className} />
}

export default AudioIcon
