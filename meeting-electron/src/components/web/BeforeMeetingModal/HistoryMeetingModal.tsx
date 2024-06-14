import React, { useEffect, useState } from 'react'

import { ModalProps } from 'antd'
import { NERoomService } from 'neroom-web-sdk'
import { useTranslation } from 'react-i18next'
import NEMeetingService from '../../../services/NEMeeting'

import { EventType } from '../../../types'
import EventEmitter from 'eventemitter3'
import classNames from 'classnames'
import Modal from '../../common/Modal'
import HistoryMeeting from './HistoryMeeting'

interface HistoryMeetingProps extends ModalProps {
  roomService?: NERoomService
  accountId?: string
  neMeeting?: NEMeetingService
  meetingId?: string
  onBack?: () => void
  eventEmitter: EventEmitter
}

const HistoryMeetingModal: React.FC<HistoryMeetingProps> = ({
  roomService,
  accountId,
  neMeeting,
  eventEmitter,
  onCancel,
  ...restProps
}) => {
  const { t } = useTranslation()
  const [open, setOpen] = useState<boolean>()
  const [meetingId, setMeetingId] = useState<string>()
  const [pageMode, setPageMode] = useState<'list' | 'detail'>('list')

  useEffect(() => {
    setMeetingId(restProps.meetingId)
  }, [restProps.meetingId])

  useEffect(() => {
    setOpen(restProps.open)
  }, [restProps.open])

  useEffect(() => {
    eventEmitter.on(
      EventType.OnHistoryMeetingPageModeChanged,
      (mode: 'list' | 'detail') => {
        setPageMode(mode)
      }
    )
  }, [])
  return (
    <Modal
      title={<span className="modal-title">{t('historyMeeting')}</span>}
      width={375}
      maskClosable={false}
      footer={null}
      wrapClassName={classNames('history-meeting-modal', {
        'history-meeting-modal-detail-wrap': pageMode === 'detail',
      })}
      styles={{
        body: { padding: 0 },
      }}
      onCancel={(e) => {
        onCancel?.(e)
        eventEmitter.emit(EventType.OnHistoryMeetingPageModeChanged, 'list')
      }}
      {...restProps}
      open={open}
    >
      <HistoryMeeting
        open={restProps.open}
        roomService={roomService}
        accountId={accountId}
        neMeeting={neMeeting}
        meetingId={meetingId}
        eventEmitter={eventEmitter}
        onBack={() => {
          setMeetingId(undefined)
        }}
      />
    </Modal>
  )
}

export default HistoryMeetingModal
