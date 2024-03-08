import React, { useEffect } from 'react'

import './index.less'
import Modal from '../../common/Modal'
import {
  Button,
  Input,
  Form,
  Checkbox,
  ModalProps,
  DatePicker,
  DatePickerProps,
  message,
  Radio,
  Popover,
} from 'antd'
import TimePicker from 'antd/es/time-picker'
import dayjs from 'dayjs'
import weekday from 'dayjs/plugin/weekday'
import localeData from 'dayjs/plugin/localeData'
import { useTranslation } from 'react-i18next'
import {
  AttendeeOffType,
  CreateMeetingResponse,
  GetMeetingConfigResponse,
} from '../../../types'
import { getMeetingDisplayId } from '../../../utils'
import { copyElementValue } from '../../../utils'
import Toast from '../../common/toast'

import en_US from 'antd/es/date-picker/locale/en_US'
import zh_CN from 'antd/es/date-picker/locale/zh_CN'
import ja_JP from 'antd/es/date-picker/locale/ja_JP'

dayjs.extend(weekday)
dayjs.extend(localeData)

const DatePickerFormItem: React.FC<DatePickerProps> = (props) => {
  const { i18n } = useTranslation()
  return (
    <div className="date-picker-form-item">
      <DatePicker
        className="date-picker"
        {...props}
        format={'YYYY-MM-DD'}
        showToday={false}
        locale={
          {
            'zh-CN': zh_CN,
            'en-US': en_US,
            'ja-JP': ja_JP,
          }[i18n.language]
        }
      />
      <TimePicker
        className="time-picker"
        {...props}
        value={props.value}
        changeOnBlur
        format={'HH:mm'}
        minuteStep={30}
      />
    </div>
  )
}

type PasswordValue = {
  enable: boolean
  password: string
  enableWaitingRoom?: boolean
}

type PasswordFormItemProps = {
  value?: PasswordValue
  onChange?: (value: PasswordValue) => void
  disabled?: boolean
  enableWaitingRoom: boolean
}

const PasswordFormItem: React.FC<PasswordFormItemProps> = ({
  value,
  onChange,
  disabled,
  enableWaitingRoom,
}) => {
  const { t } = useTranslation()

  const handleCopy = (value: string) => {
    copyElementValue(value, () => {
      Toast.success(t('copySuccess'))
    })
  }
  return (
    <div className="password-form-item">
      <Checkbox
        checked={value?.enable}
        disabled={disabled}
        onChange={(e) => {
          if (e.target.checked) {
            const randomNum = Math.floor(Math.random() * 900000) + 100000
            onChange?.({
              enable: e.target.checked,
              password: `${randomNum}` || '',
              enableWaitingRoom: value?.enableWaitingRoom,
            })
          } else {
            onChange?.({
              enable: e.target.checked,
              password: '',
              enableWaitingRoom: value?.enableWaitingRoom,
            })
          }
        }}
      >
        {t('openMeetingPassword')}
      </Checkbox>
      {value?.enable && (
        <div className="password-disable-wrapper">
          <Input
            placeholder={value?.enable ? t('livePasswordTip') : ``}
            disabled={!value?.enable || disabled}
            value={value?.password}
            maxLength={6}
            allowClear
            onKeyPress={(event) => {
              if (!/^\d+$/.test(event.key)) {
                event.preventDefault()
              }
            }}
            onChange={(event) => {
              const password = event.target.value.replace(/[^0-9]/g, '')
              onChange?.({
                enable: true,
                password: password,
                enableWaitingRoom: value?.enableWaitingRoom,
              })
            }}
          />
          {value?.password && disabled && (
            <Button type="link" onClick={() => handleCopy(value.password)}>
              {t('copyLink')}
            </Button>
          )}
        </div>
      )}
      {enableWaitingRoom && (
        <div>
          <Checkbox
            disabled={disabled}
            onChange={(e) => {
              onChange?.({
                enableWaitingRoom: e.target.checked,
                enable: !!value?.enable,
                password: value?.password || '',
              })
            }}
            checked={value?.enableWaitingRoom}
          >
            {t('waitingRoom')}{' '}
            <Popover content={t('waitingRoomTip')}>
              <svg className="icon iconfont icona-45" aria-hidden="true">
                <use xlinkHref="#icona-45"></use>
              </svg>
            </Popover>
          </Checkbox>
        </div>
      )}
    </div>
  )
}

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
}

interface ScheduleMeetingModalProps extends ModalProps {
  meeting?: CreateMeetingResponse
  nickname?: string
  submitLoading?: boolean
  appLiveAvailable?: boolean
  onCancelMeeting?: () => void
  onJoinMeeting?: (meetingNum: string) => void
  onSummit?: (value: SummitValue) => void
  globalConfig: GetMeetingConfigResponse | null
}

const ScheduleMeetingModal: React.FC<ScheduleMeetingModalProps> = ({
  meeting,
  nickname,
  submitLoading,
  appLiveAvailable,
  onCancelMeeting,
  onJoinMeeting,
  onSummit,
  globalConfig,
  ...restProps
}) => {
  const { t } = useTranslation()

  const i18n = {
    title: t('scheduleMeeting'),
    meetingTitle: t('inviteSubject'),
    meetingTitlePlaceholder: t('subjectTitlePlaceholder'),
    meetingId: t('meetingId'),
    meetingInviteUrl: t('meetingInviteUrl'),
    startTime: t('startTime'),
    endTime: t('endTime'),
    meetingPassword: t('security'),
    passwordInputPlaceholder: t('livePasswordTip'),
    openMeetingPassword: t('openMeetingPassword'),
    meetingSetting: t('meetingSetting'),
    autoMute: t('autoMute'),
    meetingLive: t('meetingLive'),
    meetingLiveUrl: t('liveLink'),
    openMeetingLive: t('openMeetingLive'),
    cancelTips: t('cancelScheduleMeetingTips'),
    noCancel: t('noCancelScheduleMeeting'),
    submitBtn: t('scheduleMeeting'),
    cancelBtn: t('cancelScheduleMeeting'),
    joinBtn: t('joinMeeting'),
    editBtn: t('editScheduleMeeting'),
    saveBtn: t('save'),
    copyBtn: t('copy'),
    copySuccess: t('copySuccess'),
    onlyEmployees: t('onlyEmployeesAllow'),
    meetingTitleError: t('subjectTitlePlaceholder'),
    autoMuteAllowOpen: t('autoMuteAllowOpen'),
    autoMuteNotAllowOpen: t('autoMuteNotAllowOpen'),
  }

  const [form] = Form.useForm()

  const startTime = Form.useWatch('startTime', form)
  const endTime = Form.useWatch('endTime', form)
  const openLive = Form.useWatch('openLive', form)
  const openAutoMute = Form.useWatch('audioOff', form)

  const [isDetail, setIsDetail] = React.useState(false)

  function passwordValidator(rule: any, value: PasswordValue) {
    if (value?.enable && !/^\d{6}$/.test(value?.password)) {
      return Promise.reject(i18n.passwordInputPlaceholder)
    }
    return Promise.resolve()
  }

  function startDisabledDate(current: dayjs.Dayjs) {
    return current && current < dayjs().startOf('day')
  }

  function startDisabledTime() {
    const date = form.getFieldValue('startTime')
    if (date > dayjs().endOf('day')) {
      return {
        disabledHours: () => [],
        disabledMinutes: () => [],
        disabledSeconds: () => [],
      }
    } else {
      return {
        disabledHours: () => {
          const hours: number[] = []
          const minHour =
            dayjs().minute() >= 30 ? dayjs().hour() + 1 : dayjs().hour()
          for (let i = 0; i < minHour; i++) {
            hours.push(i)
          }
          return hours
        },
        disabledMinutes: (selectedHour: number) => {
          let minutes: number[] = []
          if (selectedHour === dayjs().hour()) {
            for (let i = 0; i < dayjs().minute(); i++) {
              minutes.push(i)
            }
          } else {
            minutes = []
          }
          return minutes
        },
        disabledSeconds: () => [],
      }
    }
  }

  function endDisabledDate(current: dayjs.Dayjs) {
    const startTime = form.getFieldValue('startTime')
    return (
      current &&
      (current < startTime.startOf('day') ||
        current > startTime.add(1, 'day').endOf('day'))
    )
  }

  function endDisabledTime() {
    const startTime = form.getFieldValue('startTime')
    const date = form.getFieldValue('endTime')

    if (date > startTime.endOf('day')) {
      return {
        disabledHours: () => {
          const hours: number[] = []
          for (let i = 23; i > startTime.hour(); i--) {
            hours.push(i)
          }
          return hours
        },
        disabledMinutes: (selectedHour: number) => {
          const minutes: number[] = []

          if (selectedHour === startTime.hour() && startTime.minute() === 0) {
            minutes.push(30)
          }
          return minutes
        },
        disabledSeconds: () => [],
      }
    } else {
      return {
        disabledHours: () => {
          const hours: number[] = []
          const maxHour =
            startTime.minute() === 30 ? startTime.hour() + 1 : startTime.hour()
          for (let i = 0; i < maxHour; i++) {
            hours.push(i)
          }

          return hours
        },
        disabledMinutes: () => {
          const minutes: number[] = []
          if (date.hour() === startTime.hour()) {
            for (let i = 0; i <= startTime.minute(); i++) {
              minutes.push(i)
            }
          }
          return minutes
        },
        disabledSeconds: () => [],
      }
    }
  }

  function onFinish() {
    form.validateFields().then((values) => {
      console.log(values)
      if (!values.subject.trim()) {
        message.warning(i18n.meetingTitleError)
        return
      }
      const data: any = {
        meetingId: meeting?.meetingId,
        subject: values.subject.trim(),
        password: values.meetingPassword?.password || '',
        startTime: values.startTime.startOf('minute').valueOf(),
        endTime: values.endTime.startOf('minute').valueOf(),
        openLive: values.openLive,
        liveOnlyEmployees: values.liveOnlyEmployees,
        enableWaitingRoom: values.meetingPassword?.enableWaitingRoom,
      }
      if (values.audioOff) {
        data.audioOff = true
        data.attendeeAudioOffType = values.attendeeAudioOffType
      }
      onSummit?.(data)
    })
  }

  const handleCopy = (value: string) => {
    copyElementValue(value, () => {
      Toast.success(i18n.copySuccess)
    })
  }

  useEffect(() => {
    if (restProps.open) {
      if (meeting) {
        console.log('meeting>>>>>>', meeting)
        setIsDetail(true)
        let liveOnlyEmployees = false
        const extensionConfig =
          meeting.settings.roomInfo.roomProperties?.live?.extensionConfig
        if (extensionConfig) {
          try {
            liveOnlyEmployees = JSON.parse(extensionConfig).onlyEmployeesAllow
          } catch {}
        }
        form.setFieldsValue({
          subject: meeting.subject,
          startTime: dayjs(meeting.startTime),
          endTime: dayjs(meeting.endTime),
          meetingPassword: {
            enable: !!meeting.settings.roomInfo.password,
            password: meeting.settings.roomInfo.password,
            enableWaitingRoom: meeting?.settings.roomInfo.openWaitingRoom,
          },
          audioOff: false,
          // 新字段audioOff已启用，留着用于兼容老版本
          attendeeAudioOffType:
            meeting.settings.roomInfo.roomProperties?.audioOff?.value?.split(
              '_'
            )[0] == AttendeeOffType.disable
              ? false
              : true,
          openLive: meeting?.settings.roomInfo.roomConfig.resource.live,
          liveOnlyEmployees: liveOnlyEmployees,
        })
        const audioOff = meeting.settings.roomInfo.roomProperties?.audioOff
        if (audioOff) {
          const audioOffValue = audioOff.value?.split('_')[0]
          if (audioOffValue != AttendeeOffType.disable) {
            form.setFieldsValue({
              audioOff: true,
              attendeeAudioOffType: audioOffValue,
            })
          }
        }
      } else {
        setIsDetail(false)
        let startTime
        if (dayjs().minute() < 30) {
          startTime = dayjs().minute(30).second(0)
        } else {
          startTime = dayjs().add(1, 'hour').minute(0).second(0)
        }
        form.setFieldsValue({
          subject: `${nickname}预约的会议`,
          startTime: startTime,
          endTime: startTime.add(30, 'minute'),
          meetingPassword: {
            enable: false,
            password: '',
            enableWaitingRoom: false,
          },
          attendeeAudioOffType: AttendeeOffType.offAllowSelfOn,
          audioOff: false,
          openLive: false,
          liveOnlyEmployees: false,
        })
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [restProps.open, meeting])

  useEffect(() => {
    if (restProps.open) {
      const endTime = form.getFieldValue('endTime')
      if (endTime.subtract(30, 'minute') < startTime) {
        form.setFieldValue('endTime', startTime.add(30, 'minute'))
      }
      if (endTime > startTime?.add(1, 'day')) {
        form.setFieldValue('endTime', startTime.add(1, 'day'))
      }
    }
  }, [restProps.open, startTime, form])

  useEffect(() => {
    if (restProps.open) {
      const startTime = form.getFieldValue('startTime')
      if (endTime?.subtract(30, 'minute') < startTime) {
        form.setFieldValue('endTime', startTime.add(30, 'minute'))
      }
      if (endTime > startTime?.add(1, 'day')) {
        form.setFieldValue('endTime', startTime.add(1, 'day'))
      }
    }
  }, [restProps.open, endTime, form])

  useEffect(() => {
    if (openAutoMute && !form.getFieldValue('attendeeAudioOffType')) {
      form.setFieldValue('attendeeAudioOffType', AttendeeOffType.offAllowSelfOn)
    }
  }, [openAutoMute])

  return (
    <Modal
      title={i18n.title}
      width={375}
      maskClosable={false}
      destroyOnClose
      wrapClassName="user-select-none"
      footer={
        <div className="before-meeting-modal-footer before-meeting-schedule-modal-footer">
          {isDetail && meeting?.state === 1 && (
            <Button
              className="before-meeting-modal-footer-button"
              onClick={() => {
                Modal.confirm({
                  title: i18n.cancelBtn,
                  content: i18n.cancelTips,
                  okText: i18n.cancelBtn,
                  cancelText: i18n.noCancel,
                  onOk: () => {
                    onCancelMeeting?.()
                  },
                })
              }}
              danger
            >
              {i18n.cancelBtn}
            </Button>
          )}
          {isDetail && meeting?.state === 1 && (
            <Button
              type="primary"
              className="before-meeting-modal-footer-button"
              ghost
              onClick={() => setIsDetail(false)}
            >
              {i18n.editBtn}
            </Button>
          )}
          {isDetail && (
            <Button
              className="before-meeting-modal-footer-button"
              type="primary"
              onClick={() => meeting && onJoinMeeting?.(meeting.meetingNum)}
            >
              {i18n.joinBtn}
            </Button>
          )}
          {!isDetail && (
            <Button
              className="before-meeting-modal-footer-button"
              type="primary"
              loading={submitLoading}
              onClick={() => onFinish()}
            >
              {meeting ? i18n.saveBtn : i18n.submitBtn}
            </Button>
          )}
        </div>
      }
      {...restProps}
    >
      <div className="before-meeting-modal-content">
        <div className="schedule-meeting-container">
          <Form name="basic" autoComplete="off" layout="vertical" form={form}>
            <Form.Item
              name="subject"
              label={i18n.meetingTitle}
              rules={[
                { required: true, message: i18n.meetingTitlePlaceholder },
              ]}
            >
              <Input
                placeholder={i18n.meetingTitlePlaceholder}
                maxLength={30}
                allowClear
                disabled={isDetail}
              />
            </Form.Item>
            {meeting && isDetail && (
              <Form.Item name="meetingId" label={i18n.meetingId}>
                <div className="schedule-detail-item">
                  <Input
                    disabled={true}
                    value={getMeetingDisplayId(meeting?.meetingNum)}
                  />
                  <Button
                    type="link"
                    onClick={() => handleCopy(meeting.meetingNum)}
                  >
                    {i18n.copyBtn}
                  </Button>
                </div>
              </Form.Item>
            )}
            {meeting && isDetail && (
              <Form.Item name="meetingInviteUrl" label={i18n.meetingInviteUrl}>
                <div className="schedule-detail-item">
                  <Input disabled={true} value={meeting.meetingInviteUrl} />
                  <Button
                    type="link"
                    onClick={() => handleCopy(meeting.meetingInviteUrl)}
                  >
                    {i18n.copyBtn}
                  </Button>
                </div>
              </Form.Item>
            )}
            <Form.Item name="startTime" label={i18n.startTime}>
              <DatePickerFormItem
                // showTime={{ minuteStep: 30, showSecond: false }}
                allowClear={false}
                disabledDate={startDisabledDate}
                disabledTime={startDisabledTime}
                format={'YYYY-MM-DD HH:mm'}
                showNow={false}
                disabled={isDetail}
              />
            </Form.Item>
            <Form.Item name="endTime" label={i18n.endTime}>
              <DatePickerFormItem
                // showTime={{ minuteStep: 30, showSecond: false }}
                allowClear={false}
                disabledDate={endDisabledDate}
                disabledTime={endDisabledTime}
                format={'YYYY-MM-DD HH:mm'}
                showNow={false}
                disabled={isDetail}
              />
            </Form.Item>
            <Form.Item
              className="password-form-item-wrapper"
              name="meetingPassword"
              label={i18n.meetingPassword}
              rules={[{ validator: passwordValidator }]}
            >
              <PasswordFormItem
                disabled={isDetail}
                enableWaitingRoom={
                  !!globalConfig?.appConfig?.APP_ROOM_RESOURCE.waitingRoom
                }
              />
            </Form.Item>
            <Form.Item
              name="audioOff"
              label={i18n.meetingSetting}
              valuePropName="checked"
              style={{ marginBottom: openAutoMute ? 0 : 24 }}
            >
              <Checkbox disabled={isDetail}>{i18n.autoMute}</Checkbox>
            </Form.Item>
            {openAutoMute && (
              <Form.Item name="attendeeAudioOffType" style={{ marginLeft: 24 }}>
                <Radio.Group disabled={isDetail}>
                  <Radio
                    className="attendee-radio-first"
                    value={AttendeeOffType.offAllowSelfOn}
                  >
                    {i18n.autoMuteAllowOpen}
                  </Radio>
                  <Radio
                    className="attendee-radio"
                    value={AttendeeOffType.offNotAllowSelfOn}
                  >
                    {i18n.autoMuteNotAllowOpen}
                  </Radio>
                </Radio.Group>
              </Form.Item>
            )}
            {appLiveAvailable && (
              <Form.Item
                name="openLive"
                label={i18n.meetingLive}
                valuePropName="checked"
              >
                {isDetail &&
                meeting?.settings.roomInfo.roomConfig.resource.live ? (
                  <div className="schedule-detail-item">
                    <span>{i18n.meetingLiveUrl}&nbsp;&nbsp;</span>
                    <Input
                      disabled={true}
                      value={meeting?.settings.liveConfig?.liveAddress}
                    />
                    <Button
                      type="link"
                      onClick={() =>
                        handleCopy(
                          meeting?.settings.liveConfig?.liveAddress || ''
                        )
                      }
                    >
                      {i18n.copyBtn}
                    </Button>
                  </div>
                ) : (
                  <Checkbox disabled={isDetail}>
                    {i18n.openMeetingLive}
                  </Checkbox>
                )}
              </Form.Item>
            )}

            {openLive ? (
              <Form.Item
                name="liveOnlyEmployees"
                valuePropName="checked"
                style={{ marginLeft: isDetail ? 0 : 24 }}
                className="live-only-employees-form-item"
              >
                <Checkbox disabled={isDetail}>{i18n.onlyEmployees}</Checkbox>
              </Form.Item>
            ) : null}
          </Form>
        </div>
      </div>
    </Modal>
  )
}
export default ScheduleMeetingModal
