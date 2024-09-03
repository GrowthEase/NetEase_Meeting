import React from 'react'
import Modal from '../../common/Modal'
import { ModalProps } from 'antd'
import { NEPreviewController } from 'neroom-types'
import { MeetingSetting } from '../../../types'
import SettingContent, { SettingTabType } from './Setting'
import { useTranslation } from 'react-i18next'

interface SettingProps extends ModalProps {
  previewController: NEPreviewController
  onSettingChange: (setting: MeetingSetting) => void
  onDeviceChange?: (
    type: 'video' | 'speaker' | 'microphone',
    deviceId: string
  ) => void
  defaultTab?: SettingTabType
  inMeeting?: boolean
}

const Setting: React.FC<SettingProps> = ({
  previewController,
  onSettingChange,
  onDeviceChange,
  inMeeting,
  defaultTab = 'normal',
  ...resProps
}) => {
  const { t } = useTranslation()

  return (
    <Modal
      className="nemeeting-setting"
      width={800}
      title={t('settings')}
      maskClosable={false}
      footer={null}
      {...resProps}
    >
      <SettingContent
        inMeeting={inMeeting}
        open={resProps.open}
        defaultTab={defaultTab}
        previewController={previewController}
        onSettingChange={onSettingChange}
        onDeviceChange={onDeviceChange}
      />
    </Modal>
  )
}

export default Setting
