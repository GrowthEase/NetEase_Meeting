// 周期性会议组件
import { Checkbox, DatePicker, Input, Select } from 'antd';
import React, { useEffect, useMemo, useRef } from 'react';
import { useTranslation } from 'react-i18next';
import './index.less';
import CaretDownOutlined from '@ant-design/icons/CaretDownOutlined';
import zh_CN from 'antd/es/date-picker/locale/zh_CN';
import en_US from 'antd/es/date-picker/locale/en_US';
import ja_JP from 'antd/es/date-picker/locale/ja_JP';
import {
  MeetingEndType,
  MeetingRepeatCustomStepUnit,
  MeetingRepeatFrequencyType,
  MeetingRepeatType,
} from '@meeting-module/types';
import classNames from 'classnames';
import dayjs from 'dayjs';
import EventEmitter from 'eventemitter3';
import Toast from '@meeting-module/components/common/toast';

interface PeriodicValue {
  enable?: boolean;
  type?: MeetingRepeatType;
  endType?: MeetingEndType;
  endTimes?: number;
  endDate?: dayjs.Dayjs;
  customizedFrequency?: {
    // 和stepUnit配合使用当值为3的时候 stepUnit为3或者4
    frequencyType?: MeetingRepeatFrequencyType;
    stepUnit?: number;
    stepSize?: number;
    daysOfWeek?: number[];
    daysOfMonth?: number[];
  };
}

interface PeriodicMeetingProps {
  value?: PeriodicValue;
  startTime: dayjs.Dayjs;
  onChange?: (value: PeriodicValue) => void;
  dayjs: typeof dayjs;
  canEdit: boolean;
  eventEmitter: EventEmitter;
}
const PeriodicMeeting: React.FC<PeriodicMeetingProps> = ({
  value,
  onChange,
  dayjs,
  startTime,
  canEdit,
  eventEmitter,
}) => {
  const { t, i18n } = useTranslation();
  const weekdays = [
    t('globalSunday'),
    t('globalMonday'),
    t('globalTuesday'),
    t('globalWednesday'),
    t('globalThursday'),
    t('globalFriday'),
    t('globalSaturday'),
  ];
  // 是否已点击过时间选择器
  const isClickTimePickerRef = useRef(false);
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
      label: (
        <>
          {t('meetingRepeatEveryWeek')}
          <span style={{ color: '#CCCCCC' }}>
            （{weekdays[dayjs(startTime).day()]}）
          </span>
        </>
      ),
      value: MeetingRepeatType.EveryWeek,
    },
    {
      label: (
        <>
          {t('meetingRepeatEveryTwoWeek')}
          <span style={{ color: '#CCCCCC' }}>
            （{weekdays[dayjs(startTime).day()]}）
          </span>
        </>
      ),
      value: MeetingRepeatType.EveryTwoWeek,
    },
    {
      label: (
        <>
          {t('meetingRepeatEveryMonth')}
          <span style={{ color: '#CCCCCC' }}>
            （{dayjs(startTime).format('DD')}）
          </span>
        </>
      ),
      value: MeetingRepeatType.EveryMonth,
    },
    {
      label: t('meetingRepeatCustom'),
      value: MeetingRepeatType.Custom,
    },
  ];
  // 结束于选项
  const EndTypeOptions = [
    {
      label: t('meetingRepeatOneDay'),
      value: MeetingEndType.Day,
    },
    {
      label: t('meetingRepeatTimes'),
      value: MeetingEndType.Times,
    },
  ];
  // 自定义频率选项
  const customTypesOptions = [
    {
      label: t('meetingRepeatUnitDay'),
      value: MeetingRepeatFrequencyType.Day,
    },
    {
      label: t('meetingRepeatUnitWeek'),
      value: MeetingRepeatFrequencyType.Week,
    },
    {
      label: t('meetingRepeatUnitMonth'),
      value: MeetingRepeatFrequencyType.Month,
    },
  ];

  // 周一到周日
  const weekOptions = [
    {
      label: t('globalSunday'),
      value: 1,
    },
    {
      label: t('globalMonday'),
      value: 2,
    },
    {
      label: t('globalTuesday'),
      value: 3,
    },
    {
      label: t('globalWednesday'),
      value: 4,
    },
    {
      label: t('globalThursday'),
      value: 5,
    },
    {
      label: t('globalFriday'),
      value: 6,
    },
    {
      label: t('globalSaturday'),
      value: 7,
    },
  ];

  // 每1-30天/周/月
  const generateCustomUnitOptions = useMemo(() => {
    let size = 30;

    if (
      value?.customizedFrequency?.stepUnit !== MeetingRepeatFrequencyType.Day
    ) {
      size = 12;
    }

    const options: { label: string; value: number }[] = [];

    for (let i = 1; i <= size; i++) {
      options.push({
        label: t('meetingRepeatUnitEvery') + i,
        value: i,
      });
    }

    return options;
  }, [value?.customizedFrequency?.stepUnit, t]);

  // 点击自定义月份中的日期
  const handleDaysOfMonthClick = (day: number) => {
    if (!canEdit) {
      return;
    }

    // 如果当前day已经被选择则从数组中删除，否则添加到数组中
    const daysOfMonth = value?.customizedFrequency?.daysOfMonth || [];
    const index = daysOfMonth.indexOf(day);

    // 如果存在则删除
    if (index > -1) {
      if (day == startTime.date()) {
        Toast.info(
          t('meetingRepeatUncheckTips', {
            date: day,
          }),
          800,
        );
        return;
      }

      daysOfMonth.splice(index, 1);
    } else {
      daysOfMonth.push(day);
      // 添加的时候更新日期。删除不更新
    }

    let endTimes = value?.endTimes || 7;
    // 根据设置的天数动态更新结束时间
    let endDate = value?.endDate;
    const length = daysOfMonth.length;

    if (length > 0) {
      // 对选中日期进行升序排序
      daysOfMonth.sort((preDay, nextDay) => preDay - nextDay);
      const startDate = startTime.date();
      // 找出大于开始日期的日期
      const startDateIndex = daysOfMonth.findIndex((day) => day >= startDate);
      const afterStartCount = length - startDateIndex;
      let monthCount = 0;

      // 如果当月能够满足会议次数
      if (afterStartCount >= endTimes) {
        const lastDate = daysOfMonth[startDateIndex + endTimes - 1];

        if (!isClickTimePickerRef.current) {
          endDate = startTime.date(lastDate);
        }
      } else {
        // 获取最后一个月的天数
        const remainDays = endTimes % length;
        const needMouthCount = Math.floor(endTimes / length);

        // 如果有余数则需要多加一个月
        monthCount = Math.max(
          remainDays > 0 ? needMouthCount : needMouthCount - 1,
          1,
        );
        if (!isClickTimePickerRef.current) {
          // monthCount = remainDays > 0 ? monthCount + 1 : monthCount
          endDate = startTime.add(monthCount, 'month');
          // 获取第一个月开始时间之前的日期数量
          const beforeStartCount = length - afterStartCount;

          if (beforeStartCount > 0) {
            endDate = endDate
              .date(daysOfMonth[length - 1])
              .subtract(beforeStartCount + 1, 'day');
          } else {
            remainDays > 0 &&
              (endDate = endDate.date(daysOfMonth[remainDays - 1]));
          }
        }
      }
    }

    if (value?.endType === MeetingEndType.Day) {
      endTimes = Math.max(daysOfMonth.length, 7);
    }

    // 更新数据
    onChange?.({
      ...value,
      endDate,
      endTimes,
      customizedFrequency: {
        ...value?.customizedFrequency,
        daysOfMonth: daysOfMonth,
      },
    });
  };

  // 返回日期选择组件
  const daysOfMonthOptions = () => {
    // 总共31天
    const items = new Array(31).fill(0).map((_, index) => {
      const day = index + 1;

      return (
        <div key={index} className="nemeeting-days-of-month-item-wrap">
          <div
            className={classNames('nemeeting-days-of-month-item', {
              'nemeeting-days-of-month-item-selected':
                value?.customizedFrequency?.daysOfMonth?.includes(day),
            })}
            onClick={() => handleDaysOfMonthClick(day)}
          >
            {day}
          </div>
        </div>
      );
    });

    return (
      <div
        className="nemeeting-days-of-month"
        style={{ color: canEdit ? '#000' : 'rgba(0, 0, 0, 0.25)' }}
      >
        {!canEdit && <div className="nemeeting-days-of-month-disable"></div>}
        {items}
      </div>
    );
  };

  // 自定义中选择月份中的单位是按照日期还是按照星期
  const monthUnitOptions = [
    {
      label: t('meetingRepeatDate'),
      value: MeetingRepeatCustomStepUnit.MonthOfDay,
    },
    {
      label: t('meetingRepeatWeekday'),
      value: MeetingRepeatCustomStepUnit.MonthOfWeek,
    },
  ];

  // 处理减号按钮
  const handleSubtraction = () => {
    if (!canEdit) {
      return;
    }

    let times = value?.endTimes ?? 1;

    if (times <= 1) {
      times = 2;
    }

    const endTimes = times - 1;
    const endDate = getEndDateByTimes(
      endTimes,
      value?.type || MeetingRepeatType.Everyday,
    );

    onChange?.({
      ...value,
      endDate,
      endTimes: Math.max(endTimes, 1),
    });
  };

  // 处理点击+号按钮
  const handleAdd = () => {
    if (!canEdit) {
      return;
    }

    let times = value?.endTimes ?? 1;

    if (times >= maxMeetingCount) {
      times = maxMeetingCount - 1;
    }

    const endTimes = times + 1;
    const endDate = getEndDateByTimes(
      endTimes,
      value?.type || MeetingRepeatType.Everyday,
    );

    onChange?.({
      ...value,
      endTimes: Math.max(endTimes, 1),
      endDate,
    });
  };

  // 根据不同的重复方式获取结束时间
  const getEndDateByTimes = (
    times: number,
    repeatType?: MeetingRepeatType,
    stepUnit?: MeetingRepeatFrequencyType,
  ) => {
    stepUnit = stepUnit || value?.customizedFrequency?.stepUnit;
    const endTimes = times || 1;
    let day = Math.max(endTimes - 1, 0);

    switch (repeatType) {
      case MeetingRepeatType.Everyday:
        return startTime?.add(day, 'day');
      case MeetingRepeatType.EveryWeekday:
        // 工作日
        return getLastWeekdayByTimes(startTime, day);
      case MeetingRepeatType.EveryTwoWeek:
        return startTime?.add(day * 2, 'week');
      case MeetingRepeatType.EveryWeek:
        return startTime?.add(day, 'week');
      case MeetingRepeatType.EveryMonth:
        return startTime?.add(day, 'month');
      case MeetingRepeatType.Custom:
        day = day * (value?.customizedFrequency?.stepSize || 1);
        if (stepUnit === MeetingRepeatFrequencyType.Month) {
          return startTime?.add(day, 'month');
        } else if (stepUnit === MeetingRepeatFrequencyType.Week) {
          return startTime?.add(day, 'week');
        } else {
          return startTime?.add(day, 'day');
        }

      default:
        return startTime?.add(day, 'day');
    }
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

  // 根据开始日期和结束日期或者有多少个工作日
  const getWeekdayEndTimesByDate = (
    startDate: dayjs.Dayjs,
    endDate: dayjs.Dayjs,
  ) => {
    let count = 0;
    let tmpDate = startDate;

    while (tmpDate.isBefore(endDate)) {
      if (tmpDate.day() !== 0 && tmpDate.day() !== 6) {
        count++;
      }

      tmpDate = tmpDate.add(1, 'day');
    }

    const isWeekend = endDate.day() === 0 || endDate.day() === 6;

    return count + (isWeekend ? 0 : 1);
  };

  // 根据选择的结束日期 获取结束次数
  const getEndTimesByDate = (
    endDate?: dayjs.Dayjs,
    repeatType?: MeetingRepeatType,
  ) => {
    if (!endDate) {
      return 7;
    }

    const diffDays =
      endDate.startOf('day').diff(startTime.startOf('day'), 'day') + 1;
    let endTimes = 7;

    switch (repeatType) {
      case MeetingRepeatType.Everyday:
        endTimes = Math.max(diffDays, 1);
        break;
      case MeetingRepeatType.EveryWeekday:
        // 工作日需要特殊处理
        endTimes = getWeekdayEndTimesByDate(startTime, endDate);
        break;
      // 如果每周需要-1。否则次数会多一次
      case MeetingRepeatType.EveryTwoWeek:
        endTimes = Math.floor((diffDays - 1) / 14 + 1);
        break;
      // 如果每周需要-1。否则次数会多一次
      case MeetingRepeatType.EveryWeek:
        endTimes = Math.floor((diffDays - 1) / 7 + 1);
        break;
      case MeetingRepeatType.EveryMonth:
        endTimes = Math.floor((diffDays - 1) / 30 + 1);
        break;
      case MeetingRepeatType.Custom: {
        const stepUnit = value?.customizedFrequency?.stepUnit;
        const size = value?.customizedFrequency?.stepSize || 1;
        const times = Math.ceil(diffDays / size);

        if (stepUnit === MeetingRepeatFrequencyType.Day) {
          endTimes = Math.max(times, 1);
        } else if (stepUnit === MeetingRepeatFrequencyType.Week) {
          endTimes = Math.floor(times / 7 + 1);
        } else {
          endTimes = Math.floor(times / 30 + 1);
        }

        break;
      }
    }

    return endTimes;
  };

  const weekNameMap = useMemo(() => {
    return {
      0: t('globalSunday'),
      1: t('globalMonday'),
      2: t('globalTuesday'),
      3: t('globalWednesday'),
      4: t('globalThursday'),
      5: t('globalFriday'),
      6: t('globalSaturday'),
    };
  }, [t]);
  // 自定义中选择月份中的单位是按照星期，显示开始日期在第几周的周几
  const daysOfWeekLabel = useMemo(() => {
    if (!startTime) {
      return '';
    }

    const startDate = startTime.date();
    // 返回开始时间在第几周的周几
    const weekNumber = Math.ceil(startDate / 7);
    const dayOfWeek = startTime.day();

    return t('meetingRepeatOrderWeekday', {
      week: weekNumber,
      weekday: weekNameMap[dayOfWeek],
    });
  }, [startTime, t, weekNameMap]);

  function getMaxMeetingCount(type, frequencyType) {
    // 非自定义的情况下 天和周是200次。月是50次。自定义情况下也相同，
    let maxTimes = 200;

    // 如果是自定义，则在选择月的情况下最大50次
    if (type === MeetingRepeatType.Custom) {
      if (frequencyType === MeetingRepeatFrequencyType.Month) {
        maxTimes = 50;
      }
    } else if (
      // 非自定义情况下，月和双周的情况下最大50次
      type === MeetingRepeatType.EveryMonth ||
      type === MeetingRepeatType.EveryTwoWeek
    ) {
      maxTimes = 50;
    }

    return maxTimes;
  }

  const maxMeetingCount = useMemo(() => {
    return getMaxMeetingCount(
      value?.type,
      value?.customizedFrequency?.frequencyType,
    );
  }, [value?.type, value?.customizedFrequency?.frequencyType]);


  const addonBefore = (
    <div className="nemeeting-addon" onClick={handleSubtraction}>
      -
    </div>
  );
  const addonAfter = (
    <div
      className={
        value?.endTimes === maxMeetingCount
          ? 'nemeeting-addon disabled'
          : 'nemeeting-addon'
      }
      onClick={handleAdd}
    >
      +
    </div>
  );

  function getEndDateByStartTime(
    startDate: dayjs.Dayjs,
    endTimes: number,
  ): dayjs.Dayjs {
    return startDate.add(endTimes - 1, 'day');
  }

  useEffect(() => {
    eventEmitter?.on('startTimeChange', (day) => {
      if (isClickTimePickerRef.current) {
        return;
      }

      const newEndDate = getEndDateByStartTime(day, value?.endTimes || 7);

      onChange?.({
        ...value,
        endDate: newEndDate,
      });
    });
    return () => {
      eventEmitter?.off('startTimeChange');
    };
  }, [value, eventEmitter]);

  // 根据获取最大可选日期时间
  function disableDate(current: dayjs.Dayjs) {
    const disabledDate = getEndDateByTimes(
      maxMeetingCount,
      value?.type,
      value?.customizedFrequency?.frequencyType,
    );
    const currentDay = current?.startOf('day');

    return (
      currentDay &&
      (currentDay < startTime?.startOf('day') ||
        currentDay > disabledDate?.startOf('day'))
    );
  }

  function getMaxCountAndEndDate(params: {
    maxMeetingCount: number;
    type?: MeetingRepeatType;
    repeatFrequencyType?: MeetingRepeatFrequencyType;
  }) {
    const { maxMeetingCount, type, repeatFrequencyType } = params;
    let endTimes = value?.endTimes || 7;
    let endDate = value?.endDate || startTime;

    // 如果当前结束选择的是日期不是次数
    if (value?.endType === MeetingEndType.Day) {
      const lastEndDate = getEndDateByTimes(
        maxMeetingCount,
        type,
        repeatFrequencyType,
      );

      if (endDate.isAfter(lastEndDate)) {
        endDate = getEndDateByTimes(7, type, repeatFrequencyType);
      } else {
        if (!isClickTimePickerRef.current) {
          endDate = getEndDateByTimes(
            value?.endTimes || 7,
            type,
            repeatFrequencyType,
          );
        }
      }

      const times = getEndTimesByDate(endDate, type);

      endTimes = times > maxMeetingCount ? 7 : times;
    } else {
      endTimes = Math.min(endTimes, maxMeetingCount);
    }

    return {
      endTimes,
      endDate,
    };
  }

  // 周期会议类型变更处理函数
  function handleRepeatTypeChange(type: MeetingRepeatType) {
    const maxMeetingCount = getMaxMeetingCount(
      type,
      value?.customizedFrequency?.frequencyType,
    );

    const { endDate, endTimes } = getMaxCountAndEndDate({
      maxMeetingCount,
      type,
      repeatFrequencyType: value?.customizedFrequency?.frequencyType,
    });

    onChange?.({
      ...value,
      type,
      endDate,
      endTimes,
    });
  }

  function handleFrequencyTypeChange(unit: MeetingRepeatFrequencyType) {
    const daysOfMonth = value?.customizedFrequency?.daysOfMonth || [];
    const daysOfWeek = value?.customizedFrequency?.daysOfWeek || [];
    const day = startTime.day() + 1;

    const maxMeetingCount = getMaxMeetingCount(value?.type, unit);

    const { endDate: _endDate, endTimes } = getMaxCountAndEndDate({
      maxMeetingCount,
      type: value?.type,
      repeatFrequencyType: unit,
    });

    let endDate = _endDate;

    if (unit == MeetingRepeatFrequencyType.Month) {
      // 判断是否包含当前日期没有的话加入
      if (!daysOfMonth.includes(startTime.date())) {
        daysOfMonth.push(startTime.date());
      }

      if (!isClickTimePickerRef.current) {
        endDate = getEndDateByTimes(
          endTimes || 7,
          value?.type,
          MeetingRepeatFrequencyType.Month,
        );
      }
    } else if (
      unit == MeetingRepeatFrequencyType.Week &&
      !daysOfWeek.includes(day)
    ) {
      daysOfWeek.push(day);
      if (!isClickTimePickerRef.current) {
        endDate = getEndDateByTimes(
          endTimes || 7,
          value?.type,
          MeetingRepeatFrequencyType.Week,
        );
      }
    }

    onChange?.({
      ...value,
      endTimes,
      endDate,
      customizedFrequency: {
        ...value?.customizedFrequency,
        stepSize: 1,
        frequencyType: unit,
        stepUnit: unit,
        daysOfMonth,
        daysOfWeek,
      },
    });
  }

  return (
    <div className="nemeeting-recurring">
      <Checkbox
        checked={!!value?.enable}
        disabled={!canEdit}
        onChange={(e) => {
          onChange?.({
            ...value,
            enable: e.target.checked,
          });
        }}
      >
        {t('meetingRepeatMeetings')}
      </Checkbox>
      {value?.enable && (
        <div>
          <div className="nemeeting-periodic-item">
            <div className="nemeeting-periodic-item-label">
              {t('meetingRepeatLabel')}
            </div>
            <Select
              value={value.type}
              disabled={!canEdit}
              suffixIcon={
                <CaretDownOutlined style={{ pointerEvents: 'none' }} />
              }
              className="nemeeting-periodic-item-content"
              options={repeatOptions}
              onChange={handleRepeatTypeChange}
            />
          </div>
          {value.type === MeetingRepeatType.Custom && (
            <>
              {/* 频率 */}
              <div className="nemeeting-periodic-item">
                <div className="nemeeting-periodic-item-label">
                  {t('meetingRepeatFrequency')}
                </div>
                <Select
                  value={value.customizedFrequency?.stepSize}
                  style={{ marginRight: '9px' }}
                  disabled={!canEdit}
                  suffixIcon={
                    <CaretDownOutlined style={{ pointerEvents: 'none' }} />
                  }
                  className="nemeeting-periodic-item-content"
                  options={generateCustomUnitOptions}
                  onChange={(size) => {
                    let endTimes = value.endTimes || 7;
                    let endDate = value.endDate;

                    // 当前结束类型不是次数，则需要更新次数
                    if (value.endType === MeetingEndType.Day) {
                      value.customizedFrequency &&
                        (value.customizedFrequency.stepSize = size);
                      if (!isClickTimePickerRef.current) {
                        endDate = getEndDateByTimes(
                          endTimes,
                          value.type,
                          value.customizedFrequency?.frequencyType,
                        );
                      }

                      endTimes = getEndTimesByDate(endDate, value.type);
                    }

                    onChange?.({
                      ...value,
                      endTimes,
                      endDate,
                      customizedFrequency: {
                        ...value.customizedFrequency,
                        stepSize: size,
                      },
                    });
                  }}
                />
                <Select
                  value={value.customizedFrequency?.frequencyType}
                  disabled={!canEdit}
                  suffixIcon={
                    <CaretDownOutlined style={{ pointerEvents: 'none' }} />
                  }
                  className="nemeeting-periodic-item-content"
                  options={customTypesOptions}
                  onChange={handleFrequencyTypeChange}
                />
              </div>
              {/* 位于 */}
              {value.customizedFrequency?.frequencyType !==
                MeetingRepeatFrequencyType.Day && (
                <div className="nemeeting-periodic-item nemeeting-periodic-item-frequency">
                  <div
                    className="nemeeting-periodic-item-label"
                    style={{
                      opacity:
                        value.customizedFrequency?.frequencyType ===
                        MeetingRepeatFrequencyType.Month
                          ? 0
                          : 1,
                    }}
                  >
                    {t('meetingRepeatAt')}
                  </div>
                  {value.customizedFrequency?.frequencyType ===
                  MeetingRepeatFrequencyType.Week ? (
                    <div className="nemeeting-periodic-item-content">
                      <Checkbox.Group
                        disabled={!canEdit}
                        options={weekOptions}
                        value={value.customizedFrequency?.daysOfWeek}
                        onChange={(daysOfWeek) => {
                          const startDay = startTime.day() + 1;

                          if (
                            daysOfWeek.findIndex(
                              (item: number) => item === startDay,
                            ) === -1
                          ) {
                            Toast.info(
                              t('meetingRepeatUncheckTips', {
                                date: weekNameMap[startDay - 1],
                              }),
                              800,
                            );
                            return;
                          }

                          onChange?.({
                            ...value,
                            customizedFrequency: {
                              ...value.customizedFrequency,
                              daysOfWeek,
                            },
                          });
                        }}
                      />
                    </div>
                  ) : (
                    <>
                      <div className="nemeeting-periodic-item-content">
                        <Select
                          value={value.customizedFrequency?.stepUnit}
                          style={{ width: '100%', marginBottom: '12px' }}
                          disabled={!canEdit}
                          suffixIcon={
                            <CaretDownOutlined
                              style={{ pointerEvents: 'none' }}
                            />
                          }
                          className="nemeeting-periodic-item-content"
                          options={monthUnitOptions}
                          onChange={(unit) => {
                            onChange?.({
                              ...value,
                              customizedFrequency: {
                                ...value.customizedFrequency,
                                stepUnit: unit,
                              },
                            });
                          }}
                        />
                        {/* 显示星期还是日期 */}
                        {value.customizedFrequency?.stepUnit ===
                        MeetingRepeatCustomStepUnit.MonthOfDay ? (
                          <div className="nemeeting-periodic-item-content">
                            {daysOfMonthOptions()}
                          </div>
                        ) : (
                          <div className="nemeeting-periodic-item-content">
                            <Input value={daysOfWeekLabel} disabled={true} />
                          </div>
                        )}
                      </div>
                    </>
                  )}
                </div>
              )}
            </>
          )}
          {/* 结束于 */}
          <div className="nemeeting-periodic-item">
            <div className="nemeeting-periodic-item-label">
              {t('meetingRepeatEnd')}
            </div>
            <Select
              value={value.endType}
              style={{ marginRight: '9px', maxWidth: '148px' }}
              disabled={!canEdit}
              suffixIcon={
                <CaretDownOutlined style={{ pointerEvents: 'none' }} />
              }
              className="nemeeting-periodic-item-content"
              options={EndTypeOptions}
              onChange={(endType) => {
                onChange?.({
                  ...value,
                  endType,
                });
              }}
            />
            {value.endType === MeetingEndType.Day ? (
              <DatePicker
                value={value.endDate}
                disabled={!canEdit}
                style={{ width: '144px', flex: 'none' }}
                className="nemeeting-periodic-item-content"
                disabledDate={disableDate}
                allowClear={false}
                showNow={false}
                suffixIcon={
                  <svg className="icon iconfont iconrili" aria-hidden="true">
                    <use xlinkHref="#iconrili" />
                  </svg>
                }
                maxDate={getEndDateByTimes(
                  maxMeetingCount,
                  value?.type,
                  value.customizedFrequency?.frequencyType,
                )}
                minDate={startTime}
                locale={
                  {
                    'zh-CN': zh_CN,
                    'en-US': en_US,
                    'ja-JP': ja_JP,
                  }[i18n.language]
                }
                onChange={(date) => {
                  isClickTimePickerRef.current = true;
                  const endTimes = getEndTimesByDate(date, value?.type);

                  console.log('endTimes', endTimes);
                  onChange?.({
                    ...value,
                    endDate: date,
                    endTimes,
                  });
                }}
              />
            ) : (
              <Input
                className="nemeeting-periodic-item-content nemeeting-periodic-times"
                disabled={!canEdit}
                value={value.endTimes}
                addonBefore={addonBefore}
                addonAfter={addonAfter}
                maxLength={4}
                onKeyPress={(event) => {
                  if (!/^\d+$/.test(event.key)) {
                    event.preventDefault();
                  }
                }}
                onChange={(event) => {
                  let times = Number(event.target.value.replace(/[^0-9]/g, ''));

                  if (Number(times) > maxMeetingCount) {
                    times = maxMeetingCount;
                  } else if (Number(times) < 1) {
                    times = 1;
                  }

                  const endDate = getEndDateByTimes(
                    times || 7,
                    value?.type || MeetingRepeatType.Everyday,
                  );

                  onChange?.({
                    ...value,
                    endTimes: Number(times || 1),
                    endDate,
                  });
                }}
              />
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default PeriodicMeeting;
