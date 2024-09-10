import React, { useMemo } from 'react'
import { useMeetingInfoContext } from '../../../store'
import { useTranslation } from 'react-i18next'
import './index.less'
import { ActionType } from '../../../kit'

const BackSharingViewButton = () => {
  const { meetingInfo, dispatch } = useMeetingInfoContext()
  const { t } = useTranslation()

  const enable = useMemo(() => {
    return (
      (meetingInfo.screenUuid || meetingInfo.whiteboardUuid) &&
      meetingInfo.pinVideoUuid
    )
  }, [meetingInfo])

  return enable ? (
    <div
      className="back-sharing-view-button"
      onClick={() => {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            pinVideoUuid: '',
          },
        })
      }}
    >
      {t('backSharingView')}
    </div>
  ) : null
}

export default BackSharingViewButton
