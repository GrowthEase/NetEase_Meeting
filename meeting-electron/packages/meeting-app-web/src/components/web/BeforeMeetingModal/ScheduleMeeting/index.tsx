import React, {
  forwardRef,
  useCallback,
  useEffect,
  useImperativeHandle,
  useMemo,
  useRef,
  useState,
} from 'react';

import {
  Button,
  Checkbox,
  DatePicker,
  DatePickerProps,
  Form,
  Input,
  message,
  Popover,
  Select,
  Radio,
  ModalProps,
} from 'antd';
import TimePicker from 'antd/es/time-picker';
import dayjs from 'dayjs';
import localeData from 'dayjs/plugin/localeData';
import weekday from 'dayjs/plugin/weekday';
import weekOfYear from 'dayjs/plugin/weekOfYear';
import timezone from 'dayjs/plugin/timezone';
import utc from 'dayjs/plugin/utc';
import { useTranslation } from 'react-i18next';
import {
  AttendeeOffType,
  CreateMeetingResponse,
  EventType,
  InterpreterSettingRef,
  MeetingEndType,
  MeetingRepeatCustomStepUnit,
  MeetingRepeatFrequencyType,
  MeetingRepeatType,
  BeforeMeetingConfig,
  NECloudRecordStrategyType,
} from '@meeting-module/types';
import {
  copyElementValue,
  getGMTTimeText,
  getMeetingDisplayId,
} from '@meeting-module/utils';
import Modal from '@meeting-module/components/common/Modal';
import Toast from '@meeting-module/components/common/toast';
import '../index.less';

import en_US from 'antd/es/date-picker/locale/en_US';
import ja_JP from 'antd/es/date-picker/locale/ja_JP';
import zh_CN from 'antd/es/date-picker/locale/zh_CN';
import timezones_en from '@meeting-module/locales/timezones/timezones_en';
import timezones_ja from '@meeting-module//locales/timezones/timezones_ja';
import timezones_zh from '@meeting-module//locales/timezones/timezones_zh';

import useUserInfo from '@meeting-module/hooks/useUserInfo';
import {
  InterpretationRes,
  NEMeetingInterpreter,
  NEMeetingScheduledMember,
  Role,
} from '@meeting-module/types/type';
import ParticipantAdd from '../ParticipantAdd';
import PreviewMemberList from '../ParticipantAdd/PreviewMemberList';
import PeriodicMeeting from '../PeriodicMeeting';
import ScheduleMeetingDetail from './ScheduleMeetingDetail';
import InterpreterSetting from '@meeting-module/components/common/Interpretation/InterpreterSetting';
import classNames from 'classnames';

import EventEmitter from 'eventemitter3';
import {
  copyElementValueLineBreak,
  formatDate,
  NEContactsService,
  NEMeetingItem,
} from 'nemeeting-web-sdk';
import CommonModal from '@meeting-module/components/common/CommonModal';

dayjs.extend(weekday);
dayjs.extend(localeData);
dayjs.extend(weekOfYear);
dayjs.extend(utc);
dayjs.extend(timezone);

type PasswordValue = {
  enable: boolean;
  password: string;
  enableWaitingRoom?: boolean;
};

type PasswordFormItemProps = {
  value?: PasswordValue;
  onChange?: (value: PasswordValue) => void;
  disabled?: boolean;
  enableWaitingRoom: boolean;
};

export type ScheduleMeetingRef = {
  handleCancelEditMeeting: () => void;
  handleEdit: () => void;
  setOpenRecurringModalTypeCancel: () => void;
};

const DatePickerFormItem: React.FC<DatePickerProps> = (props) => {
  const { i18n } = useTranslation();

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
        suffixIcon={
          <svg className="icon iconfont iconrili" aria-hidden="true">
            <use xlinkHref="#iconrili" />
          </svg>
        }
      />
      <TimePicker
        className="time-picker"
        {...props}
        value={props.value}
        locale={
          {
            'zh-CN': zh_CN,
            'en-US': en_US,
            'ja-JP': ja_JP,
          }[i18n.language]
        }
        changeOnBlur
        format={'HH:mm'}
        minuteStep={30}
        suffixIcon={
          <svg
            className="icon iconfont iconjiantou-xia-copy"
            aria-hidden="true"
          >
            <use xlinkHref="#iconjiantou-xia-copy" />
          </svg>
        }
      />
    </div>
  );
};

const PasswordFormItem: React.FC<PasswordFormItemProps> = ({
  value,
  onChange,
  disabled,
}) => {
  const { t } = useTranslation();

  const handleCopy = (value: string) => {
    copyElementValue(value, () => {
      Toast.success(t('copySuccess'));
    });
  };

  return (
    <div className="password-form-item">
      <Checkbox
        checked={value?.enable}
        disabled={disabled}
        onChange={(e) => {
          if (e.target.checked) {
            const randomNum = Math.floor(Math.random() * 900000) + 100000;

            onChange?.({
              enable: e.target.checked,
              password: `${randomNum}` || '',
              enableWaitingRoom: value?.enableWaitingRoom,
            });
          } else {
            onChange?.({
              enable: e.target.checked,
              password: '',
              enableWaitingRoom: value?.enableWaitingRoom,
            });
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
                event.preventDefault();
              }
            }}
            onChange={(event) => {
              const password = event.target.value.replace(/[^0-9]/g, '');

              onChange?.({
                enable: true,
                password: password,
                enableWaitingRoom: value?.enableWaitingRoom,
              });
            }}
          />
          {value?.password && disabled && (
            <Button type="link" onClick={() => handleCopy(value.password)}>
              {t('globalCopy')}
            </Button>
          )}
        </div>
      )}
      {/* {enableWaitingRoom && (
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
        )} */}
    </div>
  );
};

type SummitValue = {
  subject: string;
  password: string;
  startTime: number;
  endTime: number;
  openLive: boolean;
  audioOff: boolean;
  liveOnlyEmployees: boolean;
  meetingId?: number;
  attendeeAudioOffType?: AttendeeOffType;
  enableWaitingRoom?: boolean;
  enableJoinBeforeHost?: boolean;
  enableGuestJoin?: boolean;
  recurringRule?: CreateMeetingResponse['recurringRule'];
  scheduledMembers?: NEMeetingScheduledMember[];
  interpretation?: CreateMeetingResponse['interpretation'];
  timezoneId?: CreateMeetingResponse['timezoneId'];
  cloudRecordConfig?: CreateMeetingResponse['cloudRecordConfig'];
};

interface ScheduleMeetingModalProps extends ModalProps {
  meeting?: NEMeetingItem;
  nickname?: string;
  submitLoading?: boolean;
  appLiveAvailable?: boolean;
  onCancelMeeting?: (cancelRecurringMeeting?: boolean) => void;
  onJoinMeeting?: (meetingNum: string) => void;
  onSummit?: (value: SummitValue) => void;
  globalConfig?: BeforeMeetingConfig;
  onCancel?: () => void;
  eventEmitter: EventEmitter;
  meetingContactsService?: NEContactsService;
}

const ScheduleMeeting = forwardRef<
  ScheduleMeetingRef,
  React.PropsWithChildren<ScheduleMeetingModalProps>
>((props, ref) => {
  const {
    meeting,
    nickname,
    submitLoading,
    appLiveAvailable,
    onCancelMeeting,
    onJoinMeeting,
    onSummit,
    globalConfig,
    eventEmitter,
    ...restProps
  } = props;
  const {
    t,
    i18n: { language },
  } = useTranslation();

  const i18n = useMemo(() => {
    return {
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
      timezone: t('timezone'),
      interpretation: t('interpretation'),
      meetingCopyInviteInfo: t('meetingCopyInviteInfo'),
    };
  }, [t]);

  const [editRecurringType, setEditRecurringType] = useState<
    'current' | 'all' | ''
  >('');
  const [openRecurringModalType, setOpenRecurringModalType] = useState<
    'edit' | 'exitEdit' | 'cancel' | ''
  >('');

  const [openInterpretationSetting, setOpenInterpretationSetting] =
    useState(false);

  const cancelRecurringRef = useRef(false);

  const [form] = Form.useForm();

  const startTime = Form.useWatch('startTime', form);
  const endTime = Form.useWatch('endTime', form);
  const openLive = Form.useWatch('openLive', form);
  const openAutoMute = Form.useWatch('audioOff', form);
  const autoCloudRecord = Form.useWatch('autoCloudRecord', form);
  const enableInterpretation = Form.useWatch('enableInterpretation', form);
  const timezoneId = Form.useWatch('timezoneId', form);
  const interpretation = Form.useWatch<InterpretationRes>(
    'interpretation',
    form,
  );
  const enableGuestJoin = Form.useWatch('enableGuestJoin', form);
  const formScheduledMembers = Form.useWatch('scheduledMembers', form);

  const [isDetail, setIsDetail] = React.useState(false);
  const [scheduledMembers, setScheduledMembers] = useState<
    NEMeetingScheduledMember[] | undefined
  >(undefined);
  const { userInfo, getUserInfo } = useUserInfo();
  const interprerSettingRef = useRef<InterpreterSettingRef>(null);
  const timezonesOptions = useMemo(() => {
    const timezones = {
      'zh-CN': timezones_zh,
      'en-US': timezones_en,
      'ja-JP': timezones_ja,
    }[language];

    return timezones
      ? Object.keys(timezones).map((key) => {
          return {
            value: key,
            label: timezones[key],
          };
        })
      : [];
  }, [language]);

  function passwordValidator(_, value: PasswordValue) {
    if (value?.enable && !/^\d{6}$/.test(value?.password)) {
      return Promise.reject(i18n.passwordInputPlaceholder);
    }

    return Promise.resolve();
  }

  function startDisabledDate(current: dayjs.Dayjs) {
    return current && current < dayjs().startOf('day');
  }

  function startDisabledTime() {
    const date = form.getFieldValue('startTime');

    if (date > dayjs().endOf('day')) {
      return {
        disabledHours: () => [],
        disabledMinutes: () => [],
        disabledSeconds: () => [],
      };
    } else {
      return {
        disabledHours: () => {
          const hours: number[] = [];
          const minHour =
            dayjs().minute() >= 30 ? dayjs().hour() + 1 : dayjs().hour();

          for (let i = 0; i < minHour; i++) {
            hours.push(i);
          }

          return hours;
        },
        disabledMinutes: (selectedHour: number) => {
          let minutes: number[] = [];

          if (selectedHour === dayjs().hour()) {
            for (let i = 0; i < dayjs().minute(); i++) {
              minutes.push(i);
            }
          } else {
            minutes = [];
          }

          return minutes;
        },
        disabledSeconds: () => [],
      };
    }
  }

  function endDisabledDate(current: dayjs.Dayjs) {
    const startTime = form.getFieldValue('startTime');

    return (
      current &&
      (current < startTime.startOf('day') ||
        current > startTime.add(1, 'day').endOf('day'))
    );
  }

  function endDisabledTime(data) {
    const startTime = form.getFieldValue('startTime');

    if (data > startTime.endOf('day')) {
      return {
        disabledHours: () => {
          const hours: number[] = [];

          for (let i = 23; i > startTime.hour(); i--) {
            hours.push(i);
          }

          return hours;
        },
        disabledMinutes: (selectedHour: number) => {
          const minutes: number[] = [];

          if (selectedHour === startTime.hour() && startTime.minute() === 0) {
            minutes.push(30);
          }

          return minutes;
        },
        disabledSeconds: () => [],
      };
    } else {
      return {
        disabledHours: () => {
          const hours: number[] = [];
          const maxHour =
            startTime.minute() === 30 ? startTime.hour() + 1 : startTime.hour();

          for (let i = 0; i < maxHour; i++) {
            hours.push(i);
          }

          return hours;
        },
        disabledMinutes: () => {
          const minutes: number[] = [];

          if (data.hour() === startTime.hour()) {
            for (let i = 0; i <= startTime.minute(); i++) {
              minutes.push(i);
            }
          }

          return minutes;
        },
        disabledSeconds: () => [],
      };
    }
  }

  function onFinish() {
    form.validateFields().then((values) => {
      console.log(values);
      if (!values.subject.trim()) {
        message.warning(i18n.meetingTitleError);
        return;
      }

      const data: SummitValue = {
        meetingId: meeting?.meetingId,
        subject: values.subject.trim(),
        password: values.meetingPassword?.password || '',
        startTime: values.startTime.startOf('minute').valueOf(),
        endTime: values.endTime.startOf('minute').valueOf(),
        openLive: values.openLive,
        liveOnlyEmployees: values.liveOnlyEmployees,
        enableWaitingRoom: values.enableWaitingRoom,
        enableGuestJoin: values.enableGuestJoin,
        enableJoinBeforeHost: values.enableJoinBeforeHost,
        scheduledMembers: values.scheduledMembers,
        interpretation: values.interpretation,
        timezoneId: values.timezoneId,
        cloudRecordConfig: {
          enable: values.autoCloudRecord,
          recordStrategy: values.autoCloudRecordStrategy,
        },
        audioOff: values.audioOff,
        attendeeAudioOffType: values.audioOff
          ? values.attendeeAudioOffType
          : undefined,
      };

      const oldRecurringRule = meeting?.recurringRule;

      // 如果开启周期性会议
      if (
        values.repeat?.enable ||
        (oldRecurringRule &&
          oldRecurringRule.type !== MeetingRepeatType.NoRepeat)
      ) {
        // 编辑模式保存，如果选择修改周期会议才传更新周期会议数据
        if (meeting?.meetingId && editRecurringType === 'current') {
          onSummit?.(data);
          return;
        }

        const customizedFrequency = values.repeat.customizedFrequency;

        data.recurringRule = {
          type: values.repeat?.enable
            ? values.repeat.type
            : MeetingRepeatType.NoRepeat,
          endRule: {
            type: values.repeat.endType,
            times:
              values.repeat.endType === MeetingEndType.Times
                ? values.repeat.endTimes
                : undefined, // 如果是次数，传次数，否则传undefined
            date:
              values.repeat.endType === MeetingEndType.Day
                ? values.repeat.endDate?.format('YYYY/MM/DD')
                : undefined, // 如果是日期，传日期，否则传undefined
          },
        };
        // 如果是自定义周期性会议，传自定义周期性会议，否则传undefined
        data.recurringRule.customizedFrequency = {
          stepSize: customizedFrequency.stepSize,
          stepUnit: customizedFrequency.stepUnit,
          daysOfWeek: customizedFrequency.daysOfWeek,
          daysOfMonth: customizedFrequency.daysOfMonth,
        };
      }

      onSummit?.(data);
    });
  }

  const handleCopy = (value: string) => {
    copyElementValue(value, () => {
      Toast.success(i18n.copySuccess);
    });
  };

  const getDefaultRepeatInfo = (startTime: dayjs.Dayjs) => {
    return {
      enable: false,
      startTime: startTime,
      type: MeetingRepeatType.Everyday,
      endType: MeetingEndType.Day,
      endTimes: 7,
      endDate: startTime?.add(6, 'day'),
      customizedFrequency: {
        frequencyType: MeetingRepeatFrequencyType.Day,
        stepUnit: MeetingRepeatCustomStepUnit.Day,
        stepSize: 1,
        daysOfWeek: [],
        daysOfMonth: [],
      },
    };
  };

  function setEditMeetingInfo(meeting: NEMeetingItem, defaultRepeatInfo) {
    console.log('meeting>>>>>>', meeting);
    setIsDetail(true);
    let liveOnlyEmployees = false;

    liveOnlyEmployees = meeting.live.liveWebAccessControlLevel === 2;

    const interpretation = {
      interpreters: {},
      started: false,
    };

    if (meeting.interpretationSettings) {
      meeting.interpretationSettings.interpreterList.forEach((item) => {
        interpretation.interpreters[item.userId] = [
          item.firstLang,
          item.secondLang,
        ];
      });
    }

    form.setFieldsValue({
      subject: meeting.subject,
      startTime: dayjs(meeting.startTime),
      endTime: dayjs(meeting.endTime),
      meetingPassword: {
        enable: !!meeting.password,
        password: meeting.password,
        enableWaitingRoom: meeting?.waitingRoomEnabled,
      },
      audioOff: false,
      // 新字段audioOff已启用，留着用于兼容老版本
      attendeeAudioOffType: AttendeeOffType.offAllowSelfOn,
      openLive: meeting?.live.enable,
      enableJoinBeforeHost: meeting.enableJoinBeforeHost,
      liveOnlyEmployees: liveOnlyEmployees,
      scheduledMembers: meeting.scheduledMemberList,
      enableWaitingRoom: meeting?.waitingRoomEnabled,
      enableGuestJoin: meeting.enableGuestJoin,
      interpretation,
      enableInterpretation:
        !!interpretation?.interpreters &&
        Object.keys(interpretation?.interpreters).length > 0,
      timezoneId: meeting.timezoneId || dayjs.tz.guess(),
      autoCloudRecord: meeting.cloudRecordConfig?.enable,
      autoCloudRecordStrategy: meeting.cloudRecordConfig?.recordStrategy || 0,
    });
    if (meeting.scheduledMemberList && meeting.scheduledMemberList.length > 0) {
      const userInfo = getUserInfo();

      if (
        userInfo?.userUuid &&
        !meeting.scheduledMemberList.find(
          (item) => item.userUuid === userInfo?.userUuid,
        )
      ) {
        meeting.scheduledMemberList.unshift({
          userUuid: meeting?.ownerUserUuid || '',
          role: Role.host,
        });
      }

      form.setFieldValue('scheduledMembers', meeting.scheduledMemberList);
      setScheduledMembers(meeting.scheduledMemberList);
    } else {
      const scheduledMembers = [
        {
          userUuid: meeting?.ownerUserUuid || '',
          role: Role.host,
        },
      ];

      setScheduledMembers(scheduledMembers);
      form.setFieldValue('scheduledMembers', scheduledMembers);
    }

    const audioControl = meeting.settings.controls.find(
      (item) => item.type === 'video',
    );

    if (audioControl) {
      const attendeeAudio = {
        off: audioControl && audioControl.attendeeOff !== 0,
        attendeeOff:
          audioControl?.attendeeOff === 1
            ? AttendeeOffType.offAllowSelfOn
            : audioControl?.attendeeOff === 2
            ? AttendeeOffType.offNotAllowSelfOn
            : AttendeeOffType.disable,
      };

      form.setFieldsValue({
        audioOff: attendeeAudio.off,
        attendeeAudioOffType: attendeeAudio.attendeeOff,
      });
    }

    const recurringRule = meeting.recurringRule;
    let repeatInfo: {
      enable: boolean;
      type: MeetingRepeatType;
      endType: MeetingEndType;
      endTimes: number;
      endDate: dayjs.Dayjs;
      customizedFrequency?: {
        stepSize: number;
        stepUnit: MeetingRepeatCustomStepUnit;
        daysOfWeek: number[];
        daysOfMonth: number[];
        frequencyType: number;
      };
    };

    if (recurringRule && recurringRule.type != MeetingRepeatType.NoRepeat) {
      repeatInfo = {
        enable: true,
        type: recurringRule.type,
        endType: recurringRule.endRule.type,
        endTimes: recurringRule.endRule.times || 7,
        endDate: recurringRule.endRule.date
          ? dayjs(recurringRule.endRule.date)
          : dayjs(meeting.startTime).add(7, 'day'),
      };
      const customizedFrequency = recurringRule.customizedFrequency;
      const stepUnit =
        customizedFrequency?.stepUnit || MeetingRepeatCustomStepUnit.Day;

      repeatInfo.customizedFrequency = {
        stepSize: customizedFrequency?.stepSize || 1,
        stepUnit,
        daysOfWeek: customizedFrequency?.daysOfWeek || [],
        daysOfMonth: customizedFrequency?.daysOfMonth || [],
        frequencyType:
          stepUnit > 2 ? MeetingRepeatFrequencyType.Month : stepUnit,
      };
    } else {
      repeatInfo = defaultRepeatInfo;
    }

    form.setFieldValue('repeat', { ...repeatInfo });
  }

  useEffect(() => {
    if (restProps.open) {
      let startTime;

      if (dayjs().minute() < 30) {
        startTime = dayjs().minute(30).second(0);
      } else {
        startTime = dayjs().add(1, 'hour').minute(0).second(0);
      }

      if (meeting) {
        console.log('setEditMeetingInfo>>>>>>>>>>', meeting);

        setEditMeetingInfo(meeting, getDefaultRepeatInfo(startTime));
      } else {
        setIsDetail(false);
        form.setFieldsValue({
          subject: `${nickname}预约的会议`,
          startTime: startTime,
          endTime: startTime.add(30, 'minute'),
          meetingPassword: {
            enable: false,
            password: '',
            enableWaitingRoom: false,
          },
          enableJoinBeforeHost: true,
          repeat: getDefaultRepeatInfo(startTime),
          attendeeAudioOffType: AttendeeOffType.offAllowSelfOn,
          audioOff: false,
          openLive: false,
          liveOnlyEmployees: false,
          enableWaitingRoom: false,
          enableGuestJoin: false,
          scheduledMembers: [],
          timezoneId: dayjs.tz.guess(),
          autoCloudRecord: false,
          autoCloudRecordStrategy: 0,
        });
      }

      // 重置
      setEditRecurringType('');
      cancelRecurringRef.current = false;
    }
  }, [restProps.open, meeting]);

  useEffect(() => {
    if (restProps.open) {
      const endTime = form.getFieldValue('endTime');

      if (endTime.subtract(30, 'minute') < startTime) {
        form.setFieldValue('endTime', startTime.add(30, 'minute'));
      }

      if (endTime > startTime?.add(1, 'day')) {
        form.setFieldValue('endTime', startTime.add(1, 'day'));
      }
    }
  }, [restProps.open, startTime, form]);

  useEffect(() => {
    if (restProps.open) {
      const startTime = form.getFieldValue('startTime');
      const endTime = form.getFieldValue('endTime');

      form.setFieldValue('startTime', startTime.tz(timezoneId));
      form.setFieldValue('endTime', endTime.tz(timezoneId));
    }
  }, [restProps.open, timezoneId, form]);

  useEffect(() => {
    if (restProps.open) {
      const startTime = form.getFieldValue('startTime');

      if (endTime?.subtract(30, 'minute') < startTime) {
        form.setFieldValue('endTime', startTime.add(30, 'minute'));
      }

      if (endTime > startTime?.add(1, 'day')) {
        form.setFieldValue('endTime', startTime.add(1, 'day'));
      }
    }
  }, [restProps.open, endTime, form]);

  useEffect(() => {
    if (openAutoMute && !form.getFieldValue('attendeeAudioOffType')) {
      form.setFieldValue(
        'attendeeAudioOffType',
        AttendeeOffType.offAllowSelfOn,
      );
    }
  }, [openAutoMute, form]);

  const handleEdit = () => {
    const recurringRule = meeting?.recurringRule;

    if (recurringRule && recurringRule.type != MeetingRepeatType.NoRepeat) {
      setOpenRecurringModalType('edit');
    } else {
      setIsDetail(false);
    }
  };

  // 处理编辑本次还是全部周期性会议
  const handleEditRecurring = (type: 'current' | 'all') => {
    setEditRecurringType(type);
    setOpenRecurringModalType('');
    setIsDetail(false);
  };

  const handleOpenInterpInterpreter = () => {
    if (!window.isElectronNative) {
      setOpenInterpretationSetting(true);
    } else {
      const parentWindow = window.parent;

      console.warn('interpreterSetting', interpretation, scheduledMembers);
      parentWindow?.postMessage(
        {
          event: 'openWindow',
          payload: {
            name: 'interpreterSettingWindow',
            postMessageData: {
              event: 'updateData',
              payload: {
                globalConfig: JSON.parse(JSON.stringify(globalConfig)),
                scheduledMembers: formScheduledMembers
                  ? JSON.parse(JSON.stringify(formScheduledMembers))
                  : undefined,
                interpretation: interpretation
                  ? JSON.parse(JSON.stringify(interpretation))
                  : undefined,
                isOpen: true,
              },
            },
          },
        },
        parentWindow.origin,
      );
    }
  };

  const onSaveInterpreters = useCallback(
    (interpreters: NEMeetingInterpreter[]) => {
      const interpreterMap: { [key: string]: string[] } = {};

      interpreters?.forEach((item) => {
        if (item.userId) {
          interpreterMap[item.userId] = [item.firstLang, item.secondLang];
        }
      });
      const started =
        enableInterpretation && Object.keys(interpreterMap).length > 0;

      if (started) {
        form.setFieldValue('interpretation', {
          interpreters: interpreterMap,
          started: false,
        });
      } else {
        form.setFieldValue('interpretation', {
          started: false,
        });
      }

      setOpenInterpretationSetting(false);
    },
    [form, enableInterpretation],
  );

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      switch (event) {
        case 'onSaveInterpreters':
          onSaveInterpreters(payload.interpreters);
          break;
        case 'onDeleteScheduleMember':
          onDeleteScheduleMember(payload.userUuid);
          break;
        case 'onDeleteInterpreterAndAddressBookMember':
          onDeleteInterpreter(payload.userUuid);
          break;
        default:
          break;
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, [onSaveInterpreters]);

  const handleCancelInterpretationSetting = () => {
    if (interprerSettingRef.current?.getNeedSave()) {
      CommonModal.confirm({
        title: t('commonTitle'),
        content: t('interpConfirmCancelEditMsg'),
        width: 400,
        onOk: () => {
          setOpenInterpretationSetting(false);
        },
        cancelText: t('globalCancel'),
        okText: t('globalSure'),
      });
    } else {
      setOpenInterpretationSetting(false);
    }
  };

  const modalTile = useMemo(() => {
    switch (openRecurringModalType) {
      case 'edit':
        return i18n.editBtn;
      case 'cancel':
        return i18n.cancelBtn;
      case 'exitEdit':
        return t('meetingLeaveEditTips');
      default:
        return '';
    }
  }, [openRecurringModalType, i18n, t]);

  const onDeleteScheduleMember = (userUuid: string) => {
    const tmpScheduledMembers = [...formScheduledMembers];
    // 删除当前用户
    const index = tmpScheduledMembers.findIndex(
      (item) => item.userUuid === userUuid,
    );

    if (index > -1) {
      tmpScheduledMembers.splice(index, 1);
    }

    form.setFieldValue('scheduledMembers', tmpScheduledMembers);
    setScheduledMembers(tmpScheduledMembers);
  };

  const onDeleteInterpreter = (userUuid: string) => {
    const localInterpretation = { ...interpretation };
    const interpreters = localInterpretation?.interpreters;

    if (interpreters && interpreters[userUuid]) {
      delete interpreters[userUuid];
    }

    localInterpretation.interpreters = interpreters;
    form.setFieldValue('interpretation', localInterpretation);
  };

  // 弹窗内容
  const modalContent = useMemo(() => {
    switch (openRecurringModalType) {
      case 'edit':
        return (
          <div className={'schedule-recurring-edit-modal-content'}>
            {t('meetingRepeatEditing')}
          </div>
        );
      case 'cancel':
        return (
          <div className="nemeeting-schedule-cancel">
            <div>{i18n.cancelTips}</div>
            {meeting?.recurringRule &&
              meeting?.recurringRule?.type != MeetingRepeatType.NoRepeat && (
                <Checkbox
                  value={cancelRecurringRef.current}
                  style={{ marginTop: '12px' }}
                  onChange={(e) => {
                    cancelRecurringRef.current = e.target.checked;
                  }}
                >
                  {t('meetingRepeatCancelAll')}
                </Checkbox>
              )}
          </div>
        );
      case 'exitEdit':
        return (
          <div className={'schedule-recurring-edit-modal-content'}>
            {t('meetingLeaveEditTips2')}
          </div>
        );
      default:
        return '';
    }
  }, [openRecurringModalType, meeting?.recurringRule, i18n, t]);

  // 弹窗底部按钮
  const modalFooter = useMemo(() => {
    switch (openRecurringModalType) {
      // 编辑会议弹窗
      case 'edit':
        return (
          <div className="schedule-recurring-edit-modal-footer">
            <Button
              shape="round"
              className="schedule-edit-modal-footer-button"
              onClick={() => handleEditRecurring('current')}
              type="primary"
            >
              {t('meetingRepeatEditCurrent')}
            </Button>
            <Button
              style={{ margin: '0 12px' }}
              shape="round"
              className="schedule-edit-modal-footer-button"
              onClick={() => handleEditRecurring('all')}
              ghost
              type="primary"
            >
              {t('meetingRepeatEditAll')}
            </Button>
            <Button
              shape="round"
              className="schedule-edit-modal-footer-button"
              onClick={() => setOpenRecurringModalType('')}
            >
              {t('globalCancel')}
            </Button>
          </div>
        );
      // 取消会议弹窗
      case 'cancel':
        return (
          <div className="schedule-recurring-edit-modal-footer">
            <Button
              style={{ marginRight: '12px' }}
              shape="round"
              className="schedule-edit-modal-footer-button"
              onClick={() => {
                onCancelMeeting?.(cancelRecurringRef.current);
                setOpenRecurringModalType('');
              }}
              type="primary"
            >
              {t('cancelScheduleMeeting')}
            </Button>
            <Button
              shape="round"
              className="schedule-edit-modal-footer-button"
              onClick={() => setOpenRecurringModalType('')}
            >
              {t('noCancelScheduleMeeting')}
            </Button>
          </div>
        );

      // 退出会议编辑弹窗
      case 'exitEdit':
        return (
          <div className="schedule-recurring-edit-modal-footer">
            <Button
              style={{ marginRight: '12px' }}
              shape="round"
              className="schedule-edit-modal-footer-button"
              onClick={() => {
                setOpenRecurringModalType('');
                setTimeout(() => {
                  restProps.onCancel?.();
                });
              }}
              type="primary"
            >
              {t('meetingRepeatCancelEdit')}
            </Button>
            <Button
              shape="round"
              className="schedule-edit-modal-footer-button"
              onClick={() => setOpenRecurringModalType('')}
            >
              {t('meetingEditContinue')}
            </Button>
          </div>
        );
    }
  }, [openRecurringModalType]);

  const setOpenRecurringModalTypeCancel = () => {
    setOpenRecurringModalType('cancel');
  };

  const displayId = useMemo(() => {
    if (meeting?.meetingNum) {
      const id = meeting.meetingNum;

      return id.slice(0, 3) + '-' + id.slice(3, 6) + '-' + id.slice(6);
    }

    return '';
  }, [meeting?.meetingNum]);

  const handleCancelEditMeeting = useCallback(() => {
    const recurringRule = meeting?.recurringRule;

    // 当前编辑的是周期性会议
    if (
      !isDetail &&
      recurringRule &&
      recurringRule?.type != MeetingRepeatType.NoRepeat
    ) {
      setOpenRecurringModalType('exitEdit');
    } else {
      if (!isDetail && meeting) {
        setOpenRecurringModalType('exitEdit');
      } else {
        restProps.onCancel?.();
      }
    }
  }, [isDetail, meeting?.recurringRule]);

  const showEditBtn = useMemo(() => {
    if (meeting) {
      return meeting?.ownerUserUuid === userInfo?.userUuid;
    } else {
      return true;
    }
  }, [meeting?.ownerUserUuid, userInfo?.userUuid]);

  useImperativeHandle(
    ref,
    () => ({
      handleCancelEditMeeting,
      handleEdit,
      setOpenRecurringModalTypeCancel,
    }),
    [handleCancelEditMeeting, handleEdit, setOpenRecurringModalTypeCancel],
  );

  useEffect(() => {
    eventEmitter.emit(
      EventType.OnScheduledMeetingPageModeChanged,
      isDetail ? 'detail' : 'edit',
    );
  }, [isDetail]);

  return (
    <div className="schedule-meeting-container-wrap">
      <div
        className={classNames('before-meeting-modal-content', {
          'schedule-meeting-content-edit': !isDetail,
        })}
      >
        <div className="schedule-meeting-container">
          {isDetail ? (
            <ScheduleMeetingDetail
              meeting={meeting}
              meetingContactsService={props.meetingContactsService}
              members={scheduledMembers}
            />
          ) : (
            <Form
              className={classNames({
                'schedule-meeting-windows': window.systemPlatform === 'win32',
              })}
              name="basic"
              autoComplete="off"
              layout="vertical"
              form={form}
            >
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
                  allowClear={true}
                  disabled={isDetail}
                />
              </Form.Item>
              {isDetail ? (
                <PreviewMemberList
                  ownerUserUuid={meeting?.ownerUserUuid}
                  meetingContactsService={props.meetingContactsService}
                  members={scheduledMembers}
                  myUuid={userInfo?.userUuid}
                />
              ) : (
                globalConfig?.appConfig?.MEETING_SCHEDULED_MEMBER_CONFIG
                  ?.enable && (
                  <Form.Item
                    name="scheduledMembers"
                    label={`${i18n.meetingAttendees}  (${
                      formScheduledMembers?.length || 1
                    })`}
                  >
                    <ParticipantAdd
                      onDeleteInterpreter={onDeleteInterpreter}
                      interpretation={interpretation}
                      canEdit={!isDetail}
                      meetingContactsService={props.meetingContactsService}
                      globalConfig={globalConfig}
                      ownerUserUuid={meeting?.ownerUserUuid}
                    />
                  </Form.Item>
                )
              )}
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
                      {t('globalCopy')}
                    </Button>
                  </div>
                </Form.Item>
              )}
              {meeting && isDetail && (
                <Form.Item
                  name="meetingInviteUrl"
                  label={i18n.meetingInviteUrl}
                >
                  <div className="schedule-detail-item">
                    <Input disabled={true} value={meeting.inviteUrl} />
                    <Button
                      type="link"
                      onClick={() => handleCopy(meeting.inviteUrl)}
                    >
                      {i18n.copyBtn}
                    </Button>
                  </div>
                </Form.Item>
              )}
              <Form.Item name="startTime" label={i18n.startTime}>
                <DatePickerFormItem
                  // showTime={{ minuteStep: 30, showSecond: false }}
                  onChange={(data) => {
                    eventEmitter?.emit('startTimeChange', data);
                  }}
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
              <Form.Item name="timezoneId" label={i18n.timezone}>
                <Select
                  options={timezonesOptions}
                  suffixIcon={
                    <svg
                      className="icon iconfont  iconjiantou-xia-copy"
                      aria-hidden="true"
                    >
                      <use xlinkHref="#iconjiantou-xia-copy"></use>
                    </svg>
                  }
                  disabled={isDetail}
                ></Select>
              </Form.Item>
              {meeting?.meetingId &&
                meeting.recurringRule &&
                meeting.recurringRule.type !== MeetingRepeatType.NoRepeat &&
                !isDetail &&
                editRecurringType === 'current' && (
                  <div className="nemeeting-repeat-edit-tip">
                    <span className="nemeeting-repeat-edit-tip-line" />
                    <span className="nemeeting-repeat-edit-tip-content">
                      {t('meetingRepeatEditTips')}
                    </span>
                    <span className="nemeeting-repeat-edit-tip-line" />
                  </div>
                )}
              {meeting?.meetingId &&
              meeting.recurringRule &&
              meeting.recurringRule.type !== MeetingRepeatType.NoRepeat &&
              !isDetail &&
              editRecurringType === 'current'
                ? null
                : startTime && (
                    <Form.Item
                      name="repeat"
                      noStyle
                      style={{ marginBottom: '15px' }}
                    >
                      <PeriodicMeeting
                        eventEmitter={eventEmitter}
                        canEdit={!isDetail}
                        dayjs={dayjs}
                        startTime={startTime}
                      />
                    </Form.Item>
                  )}
              <Form.Item
                className="password-form-item-wrapper"
                name="meetingPassword"
                label={i18n.meetingPassword}
                rules={[{ validator: passwordValidator }]}
                style={{ marginBottom: 0 }}
              >
                {(!meeting?.ownerUserUuid ||
                  meeting?.ownerUserUuid == userInfo?.userUuid) && (
                  <PasswordFormItem
                    disabled={isDetail}
                    enableWaitingRoom={
                      !!globalConfig?.appConfig?.APP_ROOM_RESOURCE.waitingRoom
                    }
                  />
                )}
              </Form.Item>
              {globalConfig?.appConfig?.APP_ROOM_RESOURCE.waitingRoom ? (
                <Form.Item
                  name="enableWaitingRoom"
                  valuePropName="checked"
                  style={{ marginBottom: 0 }}
                >
                  <Checkbox disabled={isDetail}>
                    <span className="checkbox-item waiting-room">
                      {t('waitingRoom')}
                      <Popover content={t('waitingRoomTip')}>
                        <svg
                          className="icon iconfont icona-45"
                          aria-hidden="true"
                        >
                          <use xlinkHref="#icona-45"></use>
                        </svg>
                      </Popover>
                    </span>
                  </Checkbox>
                </Form.Item>
              ) : null}
              {globalConfig?.appConfig?.APP_ROOM_RESOURCE.guest ? (
                <Form.Item
                  name="enableGuestJoin"
                  valuePropName="checked"
                  className="meeting-guest-join"
                  extra={
                    enableGuestJoin ? (
                      <span style={{ color: '#FF7903' }}>
                        {t('meetingGuestJoinSecurityNotice')}
                      </span>
                    ) : (
                      ''
                    )
                  }
                >
                  <Checkbox disabled={isDetail}>
                    <span className="checkbox-item">
                      {t('meetingGuestJoin')}{' '}
                      <Popover content={t('meetingGuestJoinEnableTip')}>
                        <svg
                          className="icon iconfont icona-45"
                          aria-hidden="true"
                        >
                          <use xlinkHref="#icona-45"></use>
                        </svg>
                      </Popover>
                    </span>
                  </Checkbox>
                </Form.Item>
              ) : null}
              <div
                style={{
                  fontWeight:
                    window.systemPlatform === 'win32' ? 'bold' : '500',
                }}
                className="nemeeting-schedule-setting"
              >
                {i18n.meetingSetting}
              </div>
              <Form.Item
                name="audioOff"
                valuePropName="checked"
                noStyle
                style={{ marginBottom: openAutoMute ? 0 : 24 }}
              >
                <Checkbox style={{ lineHeight: '32px' }} disabled={isDetail}>
                  {i18n.autoMute}
                </Checkbox>
              </Form.Item>
              {openAutoMute && (
                <Form.Item
                  name="attendeeAudioOffType"
                  style={{
                    marginLeft: 24,
                    marginBottom: 0,
                  }}
                >
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
              <Form.Item
                className="enable-join-before-host"
                name="enableJoinBeforeHost"
                valuePropName="checked"
                style={{
                  marginBottom: !globalConfig?.appConfig?.APP_ROOM_RESOURCE
                    .record
                    ? 24
                    : 0,
                }}
              >
                <Checkbox disabled={isDetail}>
                  {t('meetingJoinBeforeHost')}
                </Checkbox>
              </Form.Item>
              {!!globalConfig?.appConfig?.APP_ROOM_RESOURCE.record && (
                <>
                  <Form.Item
                    name="autoCloudRecord"
                    valuePropName="checked"
                    style={{ marginBottom: autoCloudRecord ? 0 : 24 }}
                  >
                    <Checkbox
                      style={{ lineHeight: '32px' }}
                      disabled={isDetail}
                    >
                      {t('meetingCloudRecord')}
                    </Checkbox>
                  </Form.Item>

                  {autoCloudRecord && (
                    <Form.Item
                      name="autoCloudRecordStrategy"
                      style={{
                        marginLeft: 24,
                      }}
                    >
                      <Radio.Group disabled={isDetail}>
                        <Radio
                          className="attendee-radio-first"
                          value={NECloudRecordStrategyType.HOST_JOIN}
                        >
                          {t('meetingEnableCouldRecordWhenHostJoin')}
                        </Radio>
                        <br />
                        <Radio
                          className="attendee-radio"
                          value={NECloudRecordStrategyType.MEMBER_JOIN}
                        >
                          {t('meetingEnableCouldRecordWhenMemberJoin')}
                        </Radio>
                      </Radio.Group>
                    </Form.Item>
                  )}
                </>
              )}
              {appLiveAvailable && (
                <Form.Item
                  name="openLive"
                  rootClassName="open-live-form-item-wrap"
                  label={i18n.meetingLive}
                  valuePropName="checked"
                >
                  {isDetail && meeting?.live.enable ? (
                    <div className="schedule-detail-item">
                      <span>{i18n.meetingLiveUrl}&nbsp;&nbsp;</span>
                      <Input disabled={true} value={meeting?.live.liveUrl} />
                      <Button
                        type="link"
                        onClick={() => handleCopy(meeting?.live.liveUrl || '')}
                      >
                        {i18n.copyBtn}
                      </Button>
                    </div>
                  ) : (
                    <Checkbox disabled={isDetail}>
                      <span>{i18n.openMeetingLive}</span>
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
              {globalConfig?.appConfig.APP_ROOM_RESOURCE.interpretation
                ?.enable && (
                <>
                  <Form.Item
                    name="enableInterpretation"
                    valuePropName="checked"
                    label={i18n.interpretation}
                    rootClassName="schedule-interp-wrap"
                  >
                    <Checkbox disabled={isDetail}>
                      {t('interpretation')}
                    </Checkbox>
                  </Form.Item>
                  {enableInterpretation && (
                    <Form.Item name="interpretation" noStyle>
                      <div className="nemeeting-form-interp">
                        <div>{t('interpInterpreter')}</div>
                        <div
                          className="nemeeting-form-interp-input"
                          onClick={() => handleOpenInterpInterpreter()}
                        >
                          <span>
                            {interpretation?.interpreters
                              ? Object.keys(interpretation.interpreters).length
                              : 0}
                          </span>
                          <svg
                            className="icon iconfont iconjiantou-xia-copy"
                            aria-hidden="true"
                            style={{ color: '#999999', fontSize: '12px' }}
                          >
                            <use xlinkHref="#iconjiantou-you" />
                          </svg>
                        </div>
                      </div>
                    </Form.Item>
                  )}
                </>
              )}
            </Form>
          )}
        </div>
      </div>

      <div className="before-meeting-modal-footer before-meeting-schedule-modal-footer">
        {/* {isDetail && meeting?.state === 1 && showEditBtn && (
          <Button
            className="before-meeting-modal-footer-button"
            onClick={() => {
              setOpenRecurringModalType('cancel');
            }}
            danger
          >
            {i18n.cancelBtn}
          </Button>
        )}
        {isDetail && meeting?.status === 1 && showEditBtn && (
          <Button
            type="primary"
            className="before-meeting-modal-footer-button before-meeting-modal-footer-button-edit"
            ghost
            onClick={() => handleEdit()}
          >
            {i18n.editBtn}
          </Button>
        )} */}
        {isDetail && (
          <Button
            className="schedule-meeting-detail-footer-button"
            style={{ marginRight: '8px' }}
            onClick={() => {
              const ownerNickname = meeting?.ownerNickname || '';
              const defaultMeetingInfoTitle = t('defaultMeetingInfoTitle');
              const inviteSubject = `${t('inviteSubject')}\n${
                meeting?.subject || ''
              }`;
              const inviteTime = `${t('inviteTime')}\n${formatDate(
                meeting?.startTime as number,
              )} - ${formatDate(meeting?.endTime as number)} ${getGMTTimeText(
                meeting?.timezoneId,
              )}`;
              const meetingId = `${t('meetingId')}\n${displayId}`;

              let copiedValue = `${ownerNickname}${defaultMeetingInfoTitle}\n\n${inviteSubject}\n\n${inviteTime}\n\n${meetingId}`;

              if (meeting?.sipCid) {
                const sip = `${t('sip')}\n${meeting?.sipCid}`;

                copiedValue += `\n\n${sip}`;
              }

              if (meeting?.password) {
                copiedValue += `\n\n${t('meetingPassword')}\n${
                  meeting.password
                }`;
              }

              if (meeting?.inviteUrl) {
                copiedValue += `\n\n${t('meetingInviteUrl')}\n${
                  meeting.inviteUrl
                }`;
              }

              copyElementValueLineBreak(`${copiedValue}`, () => {
                Toast.success(t('copySuccess'));
              });
            }}
          >
            {i18n.meetingCopyInviteInfo}
          </Button>
        )}
        {isDetail && (
          <Button
            className="schedule-meeting-detail-footer-button"
            type="primary"
            onClick={() => meeting && onJoinMeeting?.(meeting.meetingNum)}
          >
            {i18n.joinBtn}
          </Button>
        )}
        {!isDetail && showEditBtn && (
          <Button
            className="before-meeting-modal-footer-button-submit"
            type="primary"
            loading={submitLoading}
            onClick={() => onFinish()}
          >
            {meeting ? i18n.saveBtn : i18n.submitBtn}
          </Button>
        )}
      </div>
      {/*是否编辑周期性会议弹窗*/}
      <Modal
        title={modalTile}
        width={375}
        className={'schedule-recurring-edit-modal'}
        open={!!openRecurringModalType}
        destroyOnClose
        onCancel={() => setOpenRecurringModalType('')}
        wrapClassName="schedule-recurring-edit-modal-wrap"
        getContainer={false}
        footer={modalFooter}
      >
        {modalContent}
      </Modal>
      <Modal
        open={openInterpretationSetting}
        title={t('interpInterpreter')}
        width={520}
        getContainer={false}
        destroyOnClose
        onCancel={() => handleCancelInterpretationSetting()}
        centered
        footer={null}
      >
        <InterpreterSetting
          enableCustomLang={
            !!globalConfig?.appConfig?.APP_ROOM_RESOURCE?.interpretation
              ?.enableCustomLang
          }
          maxCustomLanguageLength={
            globalConfig?.appConfig.APP_ROOM_RESOURCE.interpretation
              ?.maxCustomLanguageLength
          }
          scheduleMembers={scheduledMembers}
          ref={interprerSettingRef}
          interpretation={interpretation}
          onDeleteScheduleMember={onDeleteScheduleMember}
          onSaveInterpreters={onSaveInterpreters}
          onClose={() => handleCancelInterpretationSetting()}
          inMeeting={false}
          meetingContactsService={props.meetingContactsService}
        />
      </Modal>
    </div>
  );
});

ScheduleMeeting.displayName = 'ScheduleMeeting';

export default ScheduleMeeting;
