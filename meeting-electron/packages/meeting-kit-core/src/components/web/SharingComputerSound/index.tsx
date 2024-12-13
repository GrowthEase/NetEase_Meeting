import React, { useEffect, useMemo } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import { useTranslation } from 'react-i18next'
import './index.less'
import { UserEventType } from '../../../kit'

const SharingComputerSound = () => {
  const { neMeeting, outEventEmitter } = useGlobalContext()
  const { meetingInfo } = useMeetingInfoContext()
  const { t } = useTranslation()

  const enable = useMemo(() => {
    return (
      meetingInfo.systemAudioUuid === meetingInfo.myUuid &&
      !meetingInfo.screenUuid
    )
  }, [meetingInfo.screenUuid, meetingInfo.systemAudioUuid, meetingInfo.myUuid])

  useEffect(() => {
    outEventEmitter?.on(UserEventType.StopSharingComputerSound, () => {
      neMeeting?.stopShareSystemAudio?.()
    })

    return () => {
      outEventEmitter?.off(UserEventType.StopSharingComputerSound)
    }
  }, [outEventEmitter])

  return enable ? (
    <div className="sharing-computer-sound-wrapper">
      <div className="sharing-computer-sound-tips">
        <svg className="icon iconfont " aria-hidden="true">
          <use xlinkHref="#icondiannaoshengyingongxiang"></use>
        </svg>
        {t('sharingComputerSound')}
      </div>
      <div
        className="sharing-computer-sound-end"
        onClick={() => {
          neMeeting?.stopShareSystemAudio?.()
        }}
      >
        {t('screenShareStop')}
      </div>
    </div>
  ) : null
}

export default SharingComputerSound
