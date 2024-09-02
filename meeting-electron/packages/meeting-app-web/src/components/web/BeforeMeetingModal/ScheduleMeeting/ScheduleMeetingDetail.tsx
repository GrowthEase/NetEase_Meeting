import React, { useEffect, useMemo, useState } from 'react';

import { useTranslation } from 'react-i18next';
import {
  MeetingEndType,
  MeetingRepeatCustomStepUnit,
  MeetingRepeatType,
} from '@meeting-module/types';
import {
  copyElementValue,
  getDateFormatString,
  getMeetingDisplayId,
  formatDate,
  getGMTTimeText,
} from '@meeting-module/utils';
import Toast from '@meeting-module/components/common/toast';
import '../index.less';

import useUserInfo from '@meeting-module/hooks/useUserInfo';
import NEContactsService from '@meeting-module/kit/impl/service/meeting_contacts_service';
import {
  InterpretationRes,
  NEMeetingScheduledMember,
} from '@meeting-module/types/type';
import PreviewMemberList from '../ParticipantAdd/PreviewMemberList';
import classNames from 'classnames';
import PreviewInterpreterList from '../ParticipantAdd/PreviewInterpreterList';
import dayjs from 'dayjs';
import { Switch } from 'antd';
import 'dayjs/locale/zh';
import 'dayjs/locale/en';
import 'dayjs/locale/ja';
import {
  AttendeeOffType,
  NECloudRecordStrategyType,
  NEMeetingItem,
} from 'nemeeting-web-sdk';

interface ScheduleMeetingDetailProps {
  meeting?: NEMeetingItem;
  members?: NEMeetingScheduledMember[];
  meetingContactsService?: NEContactsService;
}

const ScheduleMeetingDetail = (props: ScheduleMeetingDetailProps) => {
  const { meeting, members, meetingContactsService } = props;
  const {
    t,
    i18n: { language },
  } = useTranslation();
  const [startTime, setStartTime] = useState<number>(0);
  const [endTime, setEndTime] = useState<number>(0);
  const [meetingStatus, setMeetingStatus] = useState<string>('');
  const [meetingDur, setMeetingDur] = useState<number>(0);
  const [interpretation, setInterpretation] = useState<InterpretationRes>();
  const { userInfo } = useUserInfo();

  const [liveOnlyEmployees, setLiveOnlyEmployees] = useState<boolean>(false);

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
      meetingInviteUrlTips: t('meetingInviteUrlTips'),
      waitingRoom: t('waitingRoom'),
      waitingRoomTip: t('waitingRoomTip'),
      meetingLiveMode: t('meetingLiveMode'),
      meetingRepeatFrequency: t('meetingRepeatFrequency'),
      meetingRepeatQuit: t('meetingRepeatQuit'),
    };
  }, [t]);

  const timestampToMinutes = (timestamp: number) => {
    return Math.floor(timestamp / 60000); // 1分钟 = 60秒 * 1000毫秒
  };

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
  ];

  const convertDateFormat = (dateString: string): string => {
    return dateString?.replace(/\//g, '-');
  };

  // 获取工作日
  const getLastWeekdayByTimes = (
    currentDate: dayjs.Dayjs,
    maxCount: number,
  ): dayjs.Dayjs => {
    let tmpDate = currentDate;

    if (!tmpDate) {
      return dayjs();
    }

    let count = 0;

    while (count < maxCount) {
      tmpDate = tmpDate.add(1, 'day');
      if (tmpDate.day() !== 0 && tmpDate.day() !== 6) {
        // 如果不是周末
        count++;
      }
    }

    return tmpDate;
  };

  const recurringRule = useMemo(() => {
    return meeting?.recurringRule;
  }, [meeting?.recurringRule]);

  // 根据不同的重复方式获取结束时间
  const getEndDateByTimes = (
    repeatType: MeetingRepeatType,
    times?: number,
    stepUnit?: MeetingRepeatCustomStepUnit,
    stepSize?: number,
  ) => {
    const endTimes = times || 1;
    let day = Math.max(endTimes - 1, 0);

    const startDayJsTime = dayjs(Number(startTime));

    switch (repeatType) {
      case MeetingRepeatType.Everyday:
        return startDayJsTime?.add(day, 'day');
      case MeetingRepeatType.EveryWeekday:
        // 工作日
        return getLastWeekdayByTimes(startDayJsTime, day);
      case MeetingRepeatType.EveryTwoWeek:
        return startDayJsTime?.add(day * 2, 'week');
      case MeetingRepeatType.EveryWeek:
        return startDayJsTime?.add(day, 'week');
      case MeetingRepeatType.EveryMonth:
        return startDayJsTime?.add(day, 'month');
      case MeetingRepeatType.Custom:
        day = day * (stepSize || 1);
        if (
          stepUnit === MeetingRepeatCustomStepUnit.MonthOfDay ||
          stepUnit === MeetingRepeatCustomStepUnit.MonthOfWeek
        ) {
          return startDayJsTime?.add(day, 'month');
        } else if (stepUnit === MeetingRepeatCustomStepUnit.Week) {
          return startDayJsTime?.add(day, 'week');
        } else {
          return startDayJsTime?.add(day, 'day');
        }

      default:
        return startDayJsTime?.add(day, 'day');
    }
  };

  const convertDateFromTimes = (
    repeatType: MeetingRepeatType,
    times?: number,
    stepUnit?: MeetingRepeatCustomStepUnit,
    stepSize?: number,
  ) => {
    const endDate = getEndDateByTimes(repeatType, times, stepUnit, stepSize);

    return endDate?.format('YYYY-MM-DD');
  };

  const convertFrequency = (meeting: NEMeetingItem) => {
    const customizedFrequency = meeting.recurringRule?.customizedFrequency;

    const weeksName = [
      t('globalSunday'),
      t('globalMonday'),
      t('globalTuesday'),
      t('globalWednesday'),
      t('globalThursday'),
      t('globalFriday'),
      t('globalSaturday'),
    ];
    let text = '';

    if (customizedFrequency) {
      if (customizedFrequency.stepUnit === 1) {
        text = t('meetingRepeatDay', {
          day: customizedFrequency.stepSize,
        });
      } else if (customizedFrequency.stepUnit === 2) {
        text = t('meetingRepeatDayInWeek', {
          week: customizedFrequency.stepSize,
          day: customizedFrequency.daysOfWeek
            .map((index) => {
              return weeksName[index - 1];
            })
            .join(' '),
        });
      } else if (customizedFrequency.stepUnit === 3) {
        text = t('meetingRepeatDayInMonth', {
          month: customizedFrequency.stepSize,
          day: customizedFrequency.daysOfMonth.join(' '),
        });
      } else if (customizedFrequency.stepUnit === 4) {
        const startDate = dayjs(meeting.startTime).date();
        // 返回开始时间在第几周的周几
        const weekNumber = Math.ceil(startDate / 7);
        const dayOfWeek = dayjs(meeting.startTime).day();

        text = t('meetingRepeatDayInWeekInMonth', {
          month: customizedFrequency.stepSize,
          week: weekNumber,
          weekday: weeksName[dayOfWeek],
        });
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
      );
    }

    return text;
  };

  const handleCopy = (value) => {
    copyElementValue(value, () => {
      Toast.success(t('copySuccess'));
    });
  };

  const audioControl = useMemo(() => {
    const audioControl = meeting?.settings.controls.find(
      (item) => item.type === 'audio',
    );

    if (audioControl) {
      return {
        off: audioControl && audioControl.attendeeOff !== 0,
        attendeeOff:
          audioControl?.attendeeOff === 1
            ? AttendeeOffType.offAllowSelfOn
            : audioControl?.attendeeOff === 2
            ? AttendeeOffType.offNotAllowSelfOn
            : AttendeeOffType.disable,
      };
    }

    return {
      off: false,
      attendeeOff: AttendeeOffType.disable,
    };
  }, [meeting]);

  useEffect(() => {
    if (meeting) {
      setStartTime(meeting.startTime);
      setEndTime(meeting.endTime);
      setMeetingStatus(
        [i18n.notStarted, i18n.inProgress, i18n.ended][meeting.status - 1],
      );
      setMeetingDur(timestampToMinutes(meeting.endTime - meeting.startTime));

      let interpretation: InterpretationRes | undefined = undefined;

      if (
        meeting.interpretationSettings &&
        meeting.interpretationSettings.interpreterList.length > 0
      ) {
        interpretation = {
          interpreters: {},
          channelNames: {},
          started: false,
        };
        meeting.interpretationSettings.interpreterList.forEach((item) => {
          if (interpretation) {
            interpretation.interpreters[item.userId] = [
              item.firstLang,
              item.secondLang,
            ];
          }
        });
      } else {
        interpretation = undefined;
      }

      setInterpretation(interpretation);

      setLiveOnlyEmployees(meeting.live.liveWebAccessControlLevel === 2);
    }
  }, [meeting, i18n]);

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
                language,
              )}
            </div>
          </div>

          <div className="schedule-meeting-status-wrap">
            <div
              className={classNames('schedule-meeting-status', {
                'in-ready-state': meeting && meeting.status === 1,
                'in-progress-state': meeting && meeting.status === 2,
                'in-end-state': meeting && meeting.status === 3,
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
              {getGMTTimeText(meeting?.timezoneId)}
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
                language,
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
                      (item) => item.value === meeting.recurringRule?.type,
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
                {recurringRule && (
                  <div className="nemeeting-repeat-value">
                    {recurringRule.endRule.type === MeetingEndType.Day
                      ? convertDateFormat(recurringRule.endRule.date as string)
                      : convertDateFromTimes(
                          recurringRule.type,
                          recurringRule.endRule.times,
                          recurringRule.customizedFrequency?.stepUnit,
                          recurringRule.customizedFrequency?.stepSize,
                        )}
                  </div>
                )}
              </div>
            </div>
          )}

        <div className="preview-memberList-wrap">
          <PreviewMemberList
            ownerUserUuid={meeting?.ownerUserUuid}
            myUuid={userInfo?.userUuid}
            meetingContactsService={meetingContactsService}
            members={members}
          ></PreviewMemberList>
          {interpretation && interpretation.interpreters && (
            <PreviewInterpreterList
              meetingContactsService={meetingContactsService}
              interpretation={interpretation}
            />
          )}
        </div>
        <div className="schedule-meeting-item-wrap">
          <div className="schedule-meeting-item">
            <div
              className="schedule-meeting-label meeting-id"
              style={{
                fontWeight: 'bold',
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
                fontWeight: 'bold',
              }}
            >
              {i18n.meetingInviteUrlTips}
            </div>
            <div className="schedule-meeting-line-left">
              <div className="schedule-meeting-item-url">
                {meeting?.inviteUrl}
              </div>

              <div
                className="schedule-meeting-invite-url-copy"
                onClick={() => handleCopy(meeting?.inviteUrl)}
              >
                <svg className="icon iconfont copy" aria-hidden="true">
                  <use xlinkHref="#iconfuzhi1"></use>
                </svg>
              </div>
            </div>
          </div>
          {!!meeting?.password && (
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
                  {meeting?.password}
                </div>
                <div
                  className="schedule-meeting-id-copy"
                  onClick={() => handleCopy(meeting?.password)}
                >
                  <svg className="icon iconfont copy" aria-hidden="true">
                    <use xlinkHref="#iconfuzhi1"></use>
                  </svg>
                </div>
              </div>
            </div>
          )}
        </div>
        {meeting?.ownerUserUuid === userInfo?.userUuid && (
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
                  defaultChecked={meeting?.waitingRoomEnabled}
                />
              </div>
            </div>
          </div>
        )}
        {meeting?.ownerUserUuid === userInfo?.userUuid && (
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
                  {audioControl.attendeeOff ===
                  AttendeeOffType.offNotAllowSelfOn
                    ? i18n.autoMuteNotAllowOpen
                    : i18n.autoMuteAllowOpen}
                </span>
              </div>
              <div className="schedule-meeting-switch">
                <Switch disabled={true} defaultChecked={audioControl.off} />
              </div>
            </div>
          </div>
        )}
        {meeting?.ownerUserUuid === userInfo?.userUuid && (
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
                  {t('meetingCloudRecord')}
                </span>
                <span className="switch-tip autoMute-tip">
                  {meeting?.cloudRecordConfig.recordStrategy ===
                  NECloudRecordStrategyType.HOST_JOIN
                    ? t('meetingEnableCouldRecordWhenHostJoin')
                    : t('meetingEnableCouldRecordWhenMemberJoin')}
                </span>
              </div>
              <div className="schedule-meeting-switch">
                <Switch
                  disabled={true}
                  defaultChecked={meeting?.cloudRecordConfig.enable}
                />
              </div>
            </div>
          </div>
        )}
        {meeting?.live.enable ? (
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
                  {meeting?.live.liveUrl}
                </div>
                <div
                  className="schedule-meeting-id-copy"
                  onClick={() => handleCopy(meeting?.live.liveUrl)}
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
  );
};

export default ScheduleMeetingDetail;
