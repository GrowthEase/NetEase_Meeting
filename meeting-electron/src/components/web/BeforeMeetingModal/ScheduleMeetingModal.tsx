import React, { useEffect, useRef, useState } from 'react'

import { ModalProps } from 'antd'
import dayjs from 'dayjs'
import localeData from 'dayjs/plugin/localeData'
import weekday from 'dayjs/plugin/weekday'
import weekOfYear from 'dayjs/plugin/weekOfYear'
import timezone from 'dayjs/plugin/timezone'
import utc from 'dayjs/plugin/utc'
import { useTranslation } from 'react-i18next'
import {
  AttendeeOffType,
  CreateMeetingResponse,
  EventType,
  GetMeetingConfigResponse,
} from '../../../types'
import Modal from '../../common/Modal'
import './index.less'

import EventEmitter from 'eventemitter3'
import NEMeetingService from '../../../services/NEMeeting'
import { NEMeetingScheduledMember } from '../../../types/type'

import classNames from 'classnames'
import ScheduleMeeting from './ScheduleMeeting'

dayjs.extend(weekday)
dayjs.extend(localeData)
dayjs.extend(weekOfYear)
dayjs.extend(utc)
dayjs.extend(timezone)

type SummitValue = {
  subject: string
  password: string
  startTime: number
  endTime: number
  openLive: boolean
  audioOff: boolean
  liveOnlyEmployees: boolean
  meetingId?: number
  attendeeAudioOffType?: AttendeeOffType
  enableWaitingRoom?: boolean
  enableJoinBeforeHost?: boolean
  enableGuestJoin?: boolean
  recurringRule?: any
  scheduledMembers?: NEMeetingScheduledMember[]
}

interface ScheduleMeetingModalProps extends ModalProps {
  meeting?: CreateMeetingResponse
  nickname?: string
  submitLoading?: boolean
  appLiveAvailable?: boolean
  onCancelMeeting?: (cancelRecurringMeeting?: boolean) => void
  onJoinMeeting?: (meetingNum: string) => void
  onSummit?: (value: SummitValue) => void
  globalConfig?: GetMeetingConfigResponse
  onCancel?: () => void
  eventEmitter: EventEmitter
  neMeeting?: NEMeetingService
}

const ScheduleMeetingModal: React.FC<ScheduleMeetingModalProps> = (props) => {
  const { eventEmitter, ...restProps } = props
  const { t } = useTranslation()
  const scheduleMeetingRef = useRef<ScheduleMeetingRef>(null)
  const [pageMode, setPageMode] = useState<'detail' | 'edit' | 'create'>(
    'create'
  )

  useEffect(() => {
    eventEmitter.on(EventType.OnScheduledMeetingPageModeChanged, (mode) => {
      setPageMode(mode)
    })
    return () => {
      eventEmitter.off(EventType.OnScheduledMeetingPageModeChanged)
    }
  }, [])

  return (
    <Modal
      title={pageMode !== 'detail' ? t('scheduleMeeting') : ' '}
      width={375}
      maskClosable={false}
      destroyOnClose
      wrapClassName={classNames(
        'user-select-none schedule-meeting-modal-wrap-class',
        {
          'schedule-meeting-modal-wrap-detail': pageMode === 'detail',
        }
      )}
      footer={null}
      {...restProps}
      onCancel={() => {
        scheduleMeetingRef.current?.handleCancelEditMeeting()
      }}
    >
      <ScheduleMeeting ref={scheduleMeetingRef} {...props} />
    </Modal>
  )
}

export type ScheduleMeetingRef = {
  handleCancelEditMeeting: () => void
}

export default ScheduleMeetingModal
