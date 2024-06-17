import React from 'react'
import { useTranslation } from 'react-i18next'
import Modal from '../../common/Modal'
import ImmediateMeeting, { ImmediateMeetingProps } from './ImmediateMeeting'

type ImmediateMeetingModalProps = ImmediateMeetingProps

const ImmediateMeetingModal: React.FC<ImmediateMeetingModalProps> = ({
  ...restProps
}) => {
  const { t } = useTranslation()

  const i18n = {
    title: t('immediateMeeting'),
    usePersonalMeetingID: t('usePersonalMeetingID'),
    passwordInputPlaceholder: t('livePasswordTip'),
    personalMeetingID: t('personalMeetingNum'),
    personalShortMeetingID: t('personalShortMeetingNum'),
    submitBtn: t('immediateMeeting'),
    mic: t('microphone'),
    camera: t('camera'),
    internalUse: t('internalOnly'),
  }

  return (
    <Modal
      title={i18n.title}
      width={375}
      maskClosable={false}
      centered={window.ipcRenderer ? false : true}
      wrapClassName="user-select-none immediateMeeting-meeting-modal-warp"
      footer={null}
      {...restProps}
    >
      <ImmediateMeeting {...restProps}></ImmediateMeeting>
    </Modal>
  )
}

export default ImmediateMeetingModal
