import React, { useEffect, useMemo, useState } from 'react'

import { useTranslation } from 'react-i18next'
import { CreateMeetingResponse, MeetingRepeatType } from '../../../../types'
import {
  copyElementValue,
  getDateFormatString,
  getMeetingDisplayId,
  formatDate,
} from '../../../../utils'
import Toast from '../../../common/toast'
import '../index.less'

import useUserInfo from '../../../../hooks/useUserInfo'
import NEMeetingService from '../../../../services/NEMeeting'
import {
  InterpretationRes,
  NEMeetingScheduledMember,
} from '../../../../types/type'
import PreviewMemberList from '../ParticipantAdd/PreviewMemberList'
import classNames from 'classnames'
import PreviewInterpreterList from '../ParticipantAdd/PreviewInterpreterList'
import timezones_zh from '../../../../locales/timezones/timezones_zh'
import dayjs from 'dayjs'
import { Switch } from 'antd'
import 'dayjs/locale/zh'
import 'dayjs/locale/en'
import 'dayjs/locale/ja'

interface ScheduleMeetingDetailProps {
  meeting?: CreateMeetingResponse
  neMeeting?: NEMeetingService
  members?: NEMeetingScheduledMember[]
}

const ScheduleMeetingDetail = (props: ScheduleMeetingDetailProps) => {
  const { meeting, neMeeting, members } = props
  const {
    t,
    i18n: { language },
  } = useTranslation()
  const [startTime, setStartTime] = useState<number>(0)
  const [endTime, setEndTime] = useState<number>(0)
  const [meetingStatus, setMeetingStatus] = useState<string>('')
  const [meetingDur, setMeetingDur] = useState<number>(0)
  const [interpretation, setInterpretation] = useState<InterpretationRes>()
  const { userInfo } = useUserInfo()

  const i18n = useMemo(() => {
    return {
      title: t('scheduleMeeting'),
      meetingTitle: t('inviteSubject'),
      meetingTitlePlaceholder: t('subjectTitlePlaceholder'),
      meetingId: t('meetingId'),
      meetingInviteUrl: t('meetingInviteUrl'),
      startTime: t('startTime'),
      endTime: t('endTime'),
      meetingPassword: t('meetingPassword'),
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
      joinBtn: t('meetingJoin'),
      editBtn: t('editScheduleMeeting'),
      saveBtn: t('save'),
      copyBtn: t('meetingCopyInvite'),
      copySuccess: t('copySuccess'),
      onlyEmployees: t('onlyEmployeesAllow'),
      meetingTitleError: t('subjectTitlePlaceholder'),
      autoMuteAllowOpen: t('autoMuteAllowOpen'),
      autoMuteNotAllowOpen: t('autoMuteNotAllowOpen'),
      meetingAttendees: t('meetingAttendees'),
      notStarted: t('notStarted'),
      inProgress: t('inProgress'),
      ended: t('ended'),
      min: t('min'),
      meetingInviteUrlTip: t('meetingInviteUrlTip'),
      waitingRoom: t('waitingRoom'),
      waitingRoomTip: t('waitingRoomTip'),
      meetingLiveMode: t('meetingLiveMode'),
      meetingRepeatFrequency: t('meetingRepeatFrequency'),
      meetingRepeatQuit: t('meetingRepeatQuit'),
    }
  }, [t])

  const timestampToMinutes = (timestamp: number) => {
    return Math.floor(timestamp / 60000) // 1分钟 = 60秒 * 1000毫秒
  }

  // 重复方式
  const repeatOptions = [
    {
      label: t('meetingRepeatEveryday'),
      value: MeetingRepeatType.Everyday,
    },
    {
      label: t('meetingRepeatEveryWeekday'),
      value: MeetingRepeatType.EveryWeekday,
    },
    {
      label: t('meetingRepeatEveryWeek'),
      value: MeetingRepeatType.EveryWeek,
    },
    {
      label: t('meetingRepeatEveryTwoWeek'),
      value: MeetingRepeatType.EveryTwoWeek,
    },
    {
      label: t('meetingRepeatEveryMonth'),
      value: MeetingRepeatType.EveryMonth,
    },
    {
      label: t('meetingRepeatCustom'),
      value: MeetingRepeatType.Custom,
    },
  ]

  const convertDateFormat = (dateString: string): string => {
    return dateString.replace(/\//g, '-')
  }

  const convertFrequency = (meeting: CreateMeetingResponse) => {
    const customizedFrequency = meeting.recurringRule?.customizedFrequency

    const weeksName = [
      t('globalSunday'),
      t('globalMonday'),
      t('globalTuesday'),
      t('globalWednesday'),
      t('globalThursday'),
      t('globalFriday'),
      t('globalSaturday'),
    ]
    let text = ''

    if (customizedFrequency) {
      if (customizedFrequency.stepUnit === 1) {
        text = t('meetingRepeatDay', {
          day: customizedFrequency.stepSize,
        })
      } else if (customizedFrequency.stepUnit === 2) {
        text = t('meetingRepeatDayInWeek', {
          week: customizedFrequency.stepSize,
          day: customizedFrequency.daysOfWeek
            .map((index) => {
              return weeksName[index - 1]
            })
            .join(' '),
        })
      } else if (customizedFrequency.stepUnit === 3) {
        text = t('meetingRepeatDayInMonth', {
          month: customizedFrequency.stepSize,
          day: customizedFrequency.daysOfMonth.join(' '),
        })
      } else if (customizedFrequency.stepUnit === 4) {
        const startDate = dayjs(meeting.startTime).date()
        // 返回开始时间在第几周的周几
        const weekNumber = Math.ceil(startDate / 7)
        const dayOfWeek = dayjs(meeting.startTime).day()

        text = t('meetingRepeatDayInWeekInMonth', {
          month: customizedFrequency.stepSize,
          week: weekNumber,
          weekday: weeksName[dayOfWeek],
        })
      }
    }

    if (text) {
      return (
        <>
          (
          <span className="nemeeting-custom-repeat-value" title={text}>
            {text}
          </span>
          )
        </>
      )
    }

    return text
  }

  const handleCopy = (value) => {
    copyElementValue(value, () => {
      Toast.success(t('copySuccess'))
    })
  }

  const [liveOnlyEmployees, setLiveOnlyEmployees] = useState<boolean>(false)

  console.log('>>>>>>>>>schedule meeting', meeting)
  useEffect(() => {
    if (meeting) {
      setStartTime(meeting.startTime)
      setEndTime(meeting.endTime)
      setMeetingStatus(
        [i18n.notStarted, i18n.inProgress, i18n.ended][meeting.state - 1]
      )
      setMeetingDur(timestampToMinutes(meeting.endTime - meeting.startTime))
      let interpretation: InterpretationRes | undefined = undefined
      const interpretationRes =
        meeting?.settings.roomInfo.roomProperties?.interpretation

      if (interpretationRes) {
        try {
          interpretation = JSON.parse(interpretationRes.value)
        } catch {
          console.log('解析interpretation failed')
        }
      }

      setInterpretation(interpretation)
      const extensionConfig =
        meeting.settings.roomInfo.roomProperties?.live?.extensionConfig

      if (extensionConfig) {
        try {
          setLiveOnlyEmployees(JSON.parse(extensionConfig).onlyEmployeesAllow)
        } catch {
          console.log('解析liveOnlyEmployees失败')
        }
      }
    }
  }, [meeting, i18n])

  return (
    <div className="schedule-meeting-detail-container">
      <div className="schedule-meeting-detail-header">
        <div className="schedule-meeting-detail-title">{meeting?.subject}</div>
        <div className="schedule-meeting-detail">
          <div className="schedule-meeting-start">
            <div className="schedule-meeting-start-title">
              {formatDate(startTime, 'HH:mm', meeting?.timezoneId)}
            </div>
            <div className="schedule-meeting-start-date">
              {formatDate(
                startTime,
                getDateFormatString(language),
                meeting?.timezoneId,
                language
              )}
            </div>
          </div>

          <div className="schedule-meeting-status-wrap">
            <div
              className={classNames('schedule-meeting-status', {
                'in-ready-state': meeting && meeting.state === 1,
                'in-progress-state': meeting && meeting.state === 2,
                'in-end-state': meeting && meeting.state === 3,
              })}
            >
              {meetingStatus}
            </div>
            <div className="schedule-meeting-dur-wrap">
              <div className="schedule-meeting-dur-content">
                <div className="schedule-meeting-dur-line"></div>
                <div className="schedule-meeting-dur">
                  {meetingDur + i18n.min}
                </div>
                <div className="schedule-meeting-dur-line"></div>
              </div>
            </div>
            <div className="schedule-meeting-GMT">
              {
                timezones_zh[meeting?.timezoneId || dayjs.tz.guess()].split(
                  ' '
                )[0]
              }
            </div>
          </div>
          <div className="schedule-meeting-end">
            <div className="schedule-meeting-end-title">
              {formatDate(endTime, 'HH:mm', meeting?.timezoneId)}
            </div>
            <div className="schedule-meeting-end-date">
              {formatDate(
                endTime,
                getDateFormatString(language),
                meeting?.timezoneId,
                language
              )}
            </div>
          </div>
        </div>
      </div>
      <div className="schedule-meeting-item-list-wrap">
        {meeting?.meetingId &&
          meeting.recurringRule &&
          meeting.recurringRule.type !== MeetingRepeatType.NoRepeat && (
            <div className="nemeeting-repeat-wrp">
              <div className="nemeeting-repeat-item">
                <div
                  className="nemeeting-repeat-label"
                  style={{
                    fontWeight:
                      window.systemPlatform === 'win32' ? 'bold' : '500',
                  }}
                >
                  {i18n.meetingRepeatFrequency}
                </div>
                <div className="nemeeting-repeat-value">
                  {
                    repeatOptions.find(
                      (item) => item.value === meeting.recurringRule?.type
                    )?.label
                  }
                  {meeting.recurringRule.type === MeetingRepeatType.Custom &&
                    convertFrequency(meeting)}
                </div>
              </div>
              <div className="nemeeting-repeat-item">
                <div
                  className="nemeeting-repeat-label"
                  style={{
                    fontWeight:
                      window.systemPlatform === 'win32' ? 'bold' : '500',
                  }}
                >
                  {i18n.meetingRepeatQuit}
                </div>
                <div className="nemeeting-repeat-value">
                  {convertDateFormat(meeting.recurringRule?.endRule.date)}
                </div>
              </div>
            </div>
          )}

        <div className="preview-memberList-wrap">
          <PreviewMemberList
            ownerUserUuid={meeting?.ownerUserUuid}
            myUuid={userInfo?.userUuid}
            neMeeting={neMeeting}
            members={members}
          ></PreviewMemberList>
          {interpretation && interpretation.interpreters && (
            <PreviewInterpreterList
              neMeeting={neMeeting}
              interpretation={interpretation}
            />
          )}
        </div>
        <div className="schedule-meeting-item-wrap">
          <div className="schedule-meeting-item">
            <div
              className="schedule-meeting-label meeting-id"
              style={{
                fontWeight: window.systemPlatform === 'win32' ? 'bold' : '500',
              }}
            >
              {i18n.meetingId}
            </div>
            <div className="schedule-meeting-line-left">
              <div className="schedule-meeting-id">
                {getMeetingDisplayId(meeting?.meetingNum)}
              </div>
              <div
                className="schedule-meeting-id-copy"
                onClick={() => handleCopy(meeting?.meetingNum)}
              >
                <svg className="icon iconfont copy" aria-hidden="true">
                  <use xlinkHref="#iconfuzhi1"></use>
                </svg>
              </div>
            </div>
          </div>
          <div className="schedule-meeting-item">
            <div
              className="schedule-meeting-label invite-url"
              style={{
                fontWeight: window.systemPlatform === 'win32' ? 'bold' : '500',
              }}
            >
              {i18n.meetingInviteUrlTip}
            </div>
            <div className="schedule-meeting-line-left">
              <div className="schedule-meeting-item-url">
                {meeting?.meetingInviteUrl}
              </div>

              <div
                className="schedule-meeting-invite-url-copy"
                onClick={() => handleCopy(meeting?.meetingInviteUrl)}
              >
                <svg className="icon iconfont copy" aria-hidden="true">
                  <use xlinkHref="#iconfuzhi1"></use>
                </svg>
              </div>
            </div>
          </div>
          {meeting?.settings.roomInfo.password && (
            <div className="schedule-meeting-item">
              <div
                className="schedule-meeting-label password-label"
                style={{
                  fontWeight:
                    window.systemPlatform === 'win32' ? 'bold' : '500',
                }}
              >
                {i18n.meetingPassword}
              </div>
              <div className="schedule-meeting-line-left">
                <div className="schedule-meeting-item-password">
                  {meeting?.settings.roomInfo.password}
                </div>
                <div
                  className="schedule-meeting-id-copy"
                  onClick={() =>
                    handleCopy(meeting?.settings.roomInfo.password)
                  }
                >
                  <svg className="icon iconfont copy" aria-hidden="true">
                    <use xlinkHref="#iconfuzhi1"></use>
                  </svg>
                </div>
              </div>
            </div>
          )}
        </div>
        <div className="schedule-meeting-item-switch-wrap">
          <div className="schedule-meeting-switch-item">
            <div className="schedule-meeting-switch-label">
              <span
                className="switch-label waiting-room-label"
                style={{
                  fontWeight:
                    window.systemPlatform === 'win32' ? 'bold' : '500',
                }}
              >
                {i18n.waitingRoom}
              </span>
              <span className="switch-tip waiting-room-tip">
                {i18n.waitingRoomTip}
              </span>
            </div>
            <div className="schedule-meeting-switch">
              <Switch
                disabled={true}
                defaultChecked={meeting?.settings.roomInfo.openWaitingRoom}
              />
            </div>
          </div>
        </div>
        <div className="schedule-meeting-item-switch-wrap schedule-meeting-item-switch-auto-mute">
          <div className="schedule-meeting-switch-item">
            <div className="schedule-meeting-switch-label">
              <span
                className="switch-label autoMute-label"
                style={{
                  fontWeight:
                    window.systemPlatform === 'win32' ? 'bold' : '500',
                }}
              >
                {i18n.autoMute}
              </span>
              <span className="switch-tip autoMute-tip">
                {i18n.autoMuteAllowOpen}
              </span>
            </div>
            <div className="schedule-meeting-switch">
              <Switch
                disabled={true}
                defaultChecked={meeting?.settings.roomInfo.openWaitingRoom}
              />
            </div>
          </div>
        </div>
        {meeting?.settings.roomInfo.roomConfig.resource.live ? (
          <div className="schedule-meeting-item-live-wrap">
            <div className="schedule-meeting-item">
              <div
                className="schedule-meeting-label meeting-live-label"
                style={{
                  fontWeight:
                    window.systemPlatform === 'win32' ? 'bold' : '500',
                }}
              >
                {i18n.meetingLive}
              </div>
              <div className="schedule-meeting-line-left">
                <div className="schedule-meeting-item-url meeting-live-url">
                  {meeting?.settings.liveConfig?.liveAddress}
                </div>
                <div
                  className="schedule-meeting-id-copy"
                  onClick={() =>
                    handleCopy(meeting?.settings.liveConfig?.liveAddress)
                  }
                >
                  <svg className="icon iconfont copy" aria-hidden="true">
                    <use xlinkHref="#iconfuzhi1"></use>
                  </svg>
                </div>
              </div>
            </div>
            {liveOnlyEmployees && (
              <div className="schedule-meeting-item">
                <div
                  className="schedule-meeting-label"
                  style={{
                    fontWeight:
                      window.systemPlatform === 'win32' ? 'bold' : '500',
                  }}
                >
                  {i18n.meetingLiveMode}
                </div>
                <div className="schedule-meeting-right">
                  {i18n.onlyEmployees}
                </div>
              </div>
            )}
          </div>
        ) : null}
      </div>
    </div>
  )
}

export default ScheduleMeetingDetail
