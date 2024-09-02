import React, { useEffect, useMemo, useRef, useState } from 'react'
import Modal from '../../common/Modal'
import './index.less'
import { useTranslation } from 'react-i18next'
import { Button, Checkbox } from 'antd'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import CommonModal from '../../common/CommonModal'
import { MeetingSetting } from '../../../kit'

type ConnectAudioModalProps = {
  onSettingChange: (setting: MeetingSetting) => void
}

const ConnectAudioModal: React.FC<ConnectAudioModalProps> = (props) => {
  const { t } = useTranslation()
  const { neMeeting } = useGlobalContext()
  const { meetingInfo } = useMeetingInfoContext()

  const [open, setOpen] = useState(false)

  const usingComputerAudio = meetingInfo.setting.audioSetting.usingComputerAudio
  const openAudio = meetingInfo.setting.normalSetting.openAudio

  const isUnMutedAudio = useMemo(() => {
    return !!meetingInfo.isUnMutedAudio
  }, [meetingInfo.isUnMutedAudio])

  const isUnMutedAudioRef = useRef(isUnMutedAudio)

  isUnMutedAudioRef.current = isUnMutedAudio

  const unmuteAudioBySelfPermission = useMemo(() => {
    return !!meetingInfo.unmuteAudioBySelfPermission
  }, [meetingInfo.unmuteAudioBySelfPermission])

  const unmuteAudioBySelfPermissionRef = useRef(unmuteAudioBySelfPermission)

  unmuteAudioBySelfPermissionRef.current = unmuteAudioBySelfPermission

  const handleReconnect = () => {
    neMeeting?.reconnectMyAudio().then(() => {
      setOpen(false)
      if (
        (openAudio || isUnMutedAudioRef.current) &&
        unmuteAudioBySelfPermissionRef.current
      ) {
        neMeeting?.unmuteLocalAudio(undefined, true)
      }
    })
  }

  const handleClose = () => {
    CommonModal.confirm({
      title: t('secondaryConfirmTitle'),
      content: t('secondaryConfirmContent'),
      okText: t('usingComputerAudio'),
      cancelText: t('secondaryConfirmCancel'),
      wrapClassName: 'second-connect-audio-modal',
      onOk: () => {
        handleReconnect()
      },
      onCancel: () => {
        setOpen(false)
      },
    })
  }

  useEffect(() => {
    if (!usingComputerAudio) {
      setTimeout(() => {
        neMeeting?.disconnectMyAudio()
      })
      setOpen(true)
    }
  }, [meetingInfo.meetingNum])

  return (
    <Modal
      closable
      width={498}
      open={open}
      footer={null}
      rootClassName="connect-audio-modal"
      maskClosable={false}
      onCancel={() => handleClose()}
    >
      <div className="connect-audio-modal-content">
        <div className="connect-audio-modal-content-title">
          {t('connectAudioTitle')}
        </div>
        <div className="connect-audio-modal-content-desc">
          *{t('usingComputerAudioTips')}
        </div>
        <Button
          type="primary"
          className="connect-audio-modal-content-button"
          style={{
            backgroundColor: '#337EFF',
            width: '315px',
          }}
          onClick={() => {
            handleReconnect()
          }}
        >
          {t('usingComputerAudio')}
        </Button>
        <Checkbox
          className="connect-audio-modal-content-checkbox"
          onChange={(e) => {
            meetingInfo.setting.audioSetting.usingComputerAudio =
              e.target.checked

            props.onSettingChange(meetingInfo.setting)
          }}
        >
          {t('usingComputerAudioInMeeting')}
        </Checkbox>
      </div>
    </Modal>
  )
}

export default ConnectAudioModal
