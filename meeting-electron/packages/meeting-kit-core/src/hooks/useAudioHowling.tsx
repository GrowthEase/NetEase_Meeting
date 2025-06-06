import { useEffect, useRef } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import { EventType } from '../kit'
import { useTranslation } from 'react-i18next'
import CommonModal from '../components/common/CommonModal'

const useAudioHowling = () => {
  const { t } = useTranslation()
  const { eventEmitter, neMeeting } = useGlobalContext()
  const { meetingInfo } = useMeetingInfoContext()
  const meetingInfoRef = useRef(meetingInfo)
  const isHowlingRemindRef = useRef(false)

  meetingInfoRef.current = meetingInfo

  const localMember = meetingInfo.localMember

  useEffect(() => {
    if (localMember.isAudioOn) {
      isHowlingRemindRef.current = false
    }
  }, [localMember.isAudioOn])

  useEffect(() => {
    if (localMember.isAudioConnected) {
      isHowlingRemindRef.current = false
    }
  }, [localMember.isAudioConnected])

  useEffect(() => {
    eventEmitter?.on(EventType.AudioHowling, (data) => {
      const localMember = meetingInfoRef.current?.localMember

      // 如果本地音频是开启的，并且是连接的
      if (
        localMember &&
        localMember.isAudioConnected &&
        !isHowlingRemindRef.current &&
        data
      ) {
        CommonModal.confirm({
          key: 'audioHowling',
          title: t('audioHasHowlingTitle'),
          content: t('audioHasHowling'),
          okText: t('audioHowlingOk'),
          onOk: () => {
            neMeeting?.disconnectMyAudio()
          },
          onCancel: () => {
            isHowlingRemindRef.current = true
          },
        })
      }
    })
  }, [])
}

export default useAudioHowling
