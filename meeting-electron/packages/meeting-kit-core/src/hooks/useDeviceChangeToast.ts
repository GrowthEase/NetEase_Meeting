import { useEffect, useRef } from 'react'
import { useMeetingInfoContext } from '../store'
import { NEDeviceBaseInfo } from 'neroom-types'
import { Toast } from '../kit'
import { useTranslation } from 'react-i18next'

type Props = {
  microphones: NEDeviceBaseInfo[]
  speakers: NEDeviceBaseInfo[]
  selectedMicrophone?: string
  selectedSpeaker?: string
}

const useDeviceChangeToast = (props: Props) => {
  const { microphones, speakers, selectedMicrophone, selectedSpeaker } = props
  const { meetingInfo } = useMeetingInfoContext()
  const { t } = useTranslation()

  const selectedMicrophoneTimerRef = useRef<null | ReturnType<
    typeof setTimeout
  >>()
  const selectedSpeakerTimerRef = useRef<null | ReturnType<typeof setTimeout>>()

  const { localMember } = meetingInfo

  useEffect(() => {
    if (!localMember.isAudioConnected) {
      selectedMicrophoneTimerRef.current &&
        clearTimeout(selectedMicrophoneTimerRef.current)
      return
    }

    selectedMicrophoneTimerRef.current = setTimeout(() => {
      if (selectedMicrophone) {
        const deviceInfo = microphones.find(
          (item) =>
            item.deviceId == selectedMicrophone &&
            !!meetingInfo.setting.audioSetting.isDefaultRecordDevice ==
              !!item.default
        )

        deviceInfo &&
          Toast.info(`${t('currentMicDevice')}: ${deviceInfo.deviceName}`, 3000)
      }
    }, 1000)
  }, [selectedMicrophone, localMember.isAudioConnected])

  useEffect(() => {
    if (!localMember.isAudioConnected) {
      selectedSpeakerTimerRef.current &&
        clearTimeout(selectedSpeakerTimerRef.current)
      return
    }

    selectedSpeakerTimerRef.current = setTimeout(() => {
      if (selectedSpeaker) {
        const deviceInfo = speakers.find(
          (item) =>
            item.deviceId == selectedSpeaker &&
            !!meetingInfo.setting.audioSetting.isDefaultPlayoutDevice ==
              !!item.default
        )

        deviceInfo &&
          Toast.info(
            `${t('currentSpeakerDevice')}: ${deviceInfo.deviceName}`,
            3000
          )
      }
    }, 1000)
  }, [selectedSpeaker, localMember.isAudioConnected])
}

export default useDeviceChangeToast
