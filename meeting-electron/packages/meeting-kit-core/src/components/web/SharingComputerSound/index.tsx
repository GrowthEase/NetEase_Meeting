import React, { useMemo } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import { useTranslation } from 'react-i18next'
import './index.less'

const SharingComputerSound = () => {
  const { neMeeting } = useGlobalContext()
  const { meetingInfo } = useMeetingInfoContext()
  const { t } = useTranslation()

  const enable = useMemo(() => {
    return (
      meetingInfo.systemAudioUuid === meetingInfo.myUuid &&
      !meetingInfo.screenUuid
    )
  }, [meetingInfo.screenUuid, meetingInfo.systemAudioUuid, meetingInfo.myUuid])

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
