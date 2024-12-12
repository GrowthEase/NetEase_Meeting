import React, { useEffect, useMemo, useRef, useState } from 'react'
import classNames from 'classnames'
import './index.less'
import { getLocalStorageSetting, meetingDuration } from '../../../utils'
import { useMeetingInfoContext } from '../../../store'
import { Dropdown, MenuProps } from 'antd'
import { useTranslation } from 'react-i18next'
import { ActionType, setLocalStorageSetting } from '../../../kit'

interface MeetingDurationProps {
  className?: string
}
// 会议持续时间
const MeetingDuration: React.FC<MeetingDurationProps> = React.memo(
  ({ className }: MeetingDurationProps) => {
    const { t } = useTranslation()
    const { meetingInfo, dispatch } = useMeetingInfoContext()
    const timerRef = useRef<null | ReturnType<typeof setTimeout>>()
    const [durationTime, setDurationTime] = useState('')
    const [joinMeetingTime, setJoinMeetingTime] = useState(0)

    const normalSetting = meetingInfo.setting.normalSetting

    const showTimeType = useMemo(() => {
      return normalSetting.showTimeType ?? 0
    }, [normalSetting.showTimeType])

    const startTime = useMemo(() => {
      if (
        normalSetting.showDurationTime &&
        normalSetting.showParticipationTime
      ) {
        return [meetingInfo.rtcStartTime, joinMeetingTime][showTimeType]
      } else if (normalSetting.showDurationTime) {
        return meetingInfo.rtcStartTime
      } else {
        return joinMeetingTime
      }
    }, [
      normalSetting.showDurationTime,
      normalSetting.showParticipationTime,
      joinMeetingTime,
      meetingInfo.rtcStartTime,
      showTimeType,
    ])

    const showSwitch = useMemo(() => {
      return (
        normalSetting.showDurationTime && normalSetting.showParticipationTime
      )
    }, [normalSetting.showDurationTime, normalSetting.showParticipationTime])

    const show = useMemo(() => {
      return (
        normalSetting.showDurationTime || normalSetting.showParticipationTime
      )
    }, [normalSetting.showDurationTime, normalSetting.showParticipationTime])

    function onShowTimeTypeChange(value: number) {
      const _setting = getLocalStorageSetting()

      if (_setting) {
        _setting.normalSetting.showTimeType = value

        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            setting: _setting,
          },
        })

        setLocalStorageSetting(JSON.stringify(_setting))
      }
    }

    useEffect(() => {
      if (meetingInfo.meetingNum) {
        setJoinMeetingTime(Date.now())
      }
    }, [meetingInfo.meetingNum])

    useEffect(() => {
      const _startTime = Math.min(startTime, new Date().getTime())

      setDurationTime(meetingDuration(_startTime))
      timerRef.current = setInterval(() => {
        setDurationTime(meetingDuration(_startTime))
      }, 1000)

      return () => {
        timerRef.current && clearInterval(timerRef.current)
        timerRef.current = undefined
      }
    }, [startTime])

    const items: MenuProps['items'] = [
      {
        key: '1',
        label: (
          <div
            className="nemeeting-dropdown-menu-item-content"
            onClick={() => onShowTimeTypeChange(0)}
          >
            {t('settingShowMeetingElapsedTime')}
            {showTimeType === 0 ? (
              <svg className="icon iconfont" aria-hidden="true">
                <use xlinkHref="#iconcheck-line-regular1x"></use>
              </svg>
            ) : null}
          </div>
        ),
      },
      {
        key: '2',
        label: (
          <div
            className="nemeeting-dropdown-menu-item-content"
            onClick={() => onShowTimeTypeChange(1)}
          >
            {t('settingShowParticipationElapsedTime')}
            {showTimeType === 1 ? (
              <svg className="icon iconfont" aria-hidden="true">
                <use xlinkHref="#iconcheck-line-regular1x"></use>
              </svg>
            ) : null}
          </div>
        ),
      },
    ]

    return show ? (
      <Dropdown
        menu={{ items }}
        trigger={showSwitch ? ['click'] : []}
        rootClassName="nemeeting-duration-dropdown"
        getPopupContainer={(node) => node}
      >
        <div
          className={classNames('nemeeting-duration', className, {
            ['nemeeting-duration-click']: showSwitch,
          })}
        >
          {durationTime}
          {showSwitch ? (
            <svg className="icon iconfont button-allow" aria-hidden="true">
              <use xlinkHref="#iconyx-allowx"></use>
            </svg>
          ) : null}
        </div>
      </Dropdown>
    ) : null
  }
)

MeetingDuration.displayName = 'MeetingDuration'

export default MeetingDuration
