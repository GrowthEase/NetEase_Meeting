import { ModalProps } from 'antd'
import React, { useEffect, useRef, useState } from 'react'
import InterpreterSetting from './InterpreterSetting'
import { useTranslation } from 'react-i18next'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import Modal from '../Modal'
import { InterpreterSettingRef } from '../../../types/innerType'
import { InterpretationRes } from '../../../types/type'

interface InterpreterSettingModalProps extends ModalProps {
  className?: string
  inMeeting?: boolean
  onClose?: () => void
}

const InterpreterSettingModal: React.FC<InterpreterSettingModalProps> = ({
  ...resProps
}) => {
  const { t } = useTranslation()
  const { meetingInfo, memberList, inInvitingMemberList } =
    useMeetingInfoContext()
  const { neMeeting, globalConfig } = useGlobalContext()
  const interpreterSettingRef = useRef<InterpreterSettingRef>(null)
  const [interpretation, setInterpretation] = useState<InterpretationRes>()

  const handleCancel = (e) => {
    // 如果存在更新则需要弹窗提醒
    if (interpreterSettingRef.current?.getNeedUpdate()) {
      Modal.confirm({
        title: t('commonTitle'),
        content: t('interpConfirmCancelEditMsg'),
        width: 270,
        onOk: () => {
          resProps.onCancel?.(e)
        },
        cancelText: t('globalCancel'),
        okText: t('globalSure'),
      })
    } else {
      resProps.onCancel?.(e)
    }
  }

  useEffect(() => {
    if (resProps.open) {
      console.log(
        'meetingInfo.interpretation',
        resProps.open,
        meetingInfo.interpretation
      )
      setInterpretation(meetingInfo.interpretation)
    }
  }, [resProps.open, meetingInfo.interpretation])

  return (
    <Modal
      title={t('interpInterpreter')}
      width={520}
      getContainer={false}
      {...resProps}
      onCancel={handleCancel}
      destroyOnClose
      footer={null}
    >
      <InterpreterSetting
        ref={interpreterSettingRef}
        onClose={resProps.onClose}
        inMeeting={resProps.inMeeting}
        isStarted={meetingInfo.interpretation?.started}
        enableCustomLang={
          !!globalConfig?.appConfig.APP_ROOM_RESOURCE.interpretation
            ?.enableCustomLang
        }
        maxCustomLanguageLength={
          globalConfig?.appConfig.APP_ROOM_RESOURCE.interpretation
            ?.maxCustomLanguageLength
        }
        neMeeting={neMeeting}
        memberList={memberList}
        inInvitingMemberList={inInvitingMemberList}
        interpretation={interpretation}
      />
    </Modal>
  )
}

export default InterpreterSettingModal
