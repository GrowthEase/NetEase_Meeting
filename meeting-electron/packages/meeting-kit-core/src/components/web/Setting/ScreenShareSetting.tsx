import { useTranslation } from 'react-i18next'
import React from 'react'
import { Radio, Checkbox, Space, Popover, Select } from 'antd'
import { MeetingSetting } from '../../../types'
import './index.less'
import { createDefaultSetting } from '../../../services'

interface ScreenShareSettingProps {
  setting?: MeetingSetting['screenShareSetting']
  onSettingChange: (setting: MeetingSetting['screenShareSetting']) => void
}
const ScreenShareSetting: React.FC<ScreenShareSettingProps> = (props) => {
  const setting = props.setting ?? createDefaultSetting()['screenShareSetting']

  const { t } = useTranslation()

  const handleSideBySideModeChange = (checked) => {
    setting.sideBySideModeOpen = checked
    props.onSettingChange({ ...setting })
  }

  const handleScreenShareOptionInMeetingChange = (opt) => {
    setting.screenShareOptionInMeeting = opt
    props.onSettingChange({ ...setting })
  }

  const handleSharedLimitFrameRateEnableChange = (checked) => {
    setting.sharedLimitFrameRateEnable = checked
    props.onSettingChange({ ...setting })
  }

  const handleSharedLimitFrameRateChange = (value) => {
    setting.sharedLimitFrameRate = value
    props.onSettingChange({ ...setting })
  }

  return (
    <div className="setting-wrap screen-share-setting w-full h-full">
      <div className="screen-share-setting-item">
        <div
          style={{
            fontWeight: 'bold',
          }}
          className="setting-title screen-share-setting-title"
        >
          {t('windowSizeWhenSharingTheScreen')}
        </div>
        <Checkbox
          checked={setting.sideBySideModeOpen}
          onChange={(e) => handleSideBySideModeChange(e.target.checked)}
          style={{
            height: '16px',
          }}
        >
          <span>{t('sideBySideMode')}</span>
          <Popover
            trigger={'hover'}
            placement={'top'}
            content={
              <div className="toolbar-tip">{t('sideBySideModeTips')}</div>
            }
          >
            <span>
              <svg
                className="icon iconfont icona-45 nemeeting-blacklist-tip"
                aria-hidden="true"
              >
                <use xlinkHref="#icona-45"></use>
              </svg>
            </span>
          </Popover>
        </Checkbox>
      </div>
      {window.isElectronNative ? (
        <div className="screen-share-setting-item">
          <div
            style={{
              fontWeight: 'bold',
            }}
            className="setting-title screen-share-setting-title"
          >
            {t('whenIShareMyScreenInMeeting')}
          </div>
          <Radio.Group
            value={setting.screenShareOptionInMeeting}
            onChange={(e) => {
              handleScreenShareOptionInMeetingChange(e.target.value)
            }}
            className="screen-share-setting-group-content"
          >
            <Space direction="vertical">
              <Radio value={0}>{t('showAllSharingOptions')}</Radio>
              <Radio value={1}>
                {t('automaticDesktopSharing')}
                <Popover
                  trigger={'hover'}
                  placement={'top'}
                  content={
                    <div className="toolbar-tip">
                      {t('automaticDesktopSharingTips')}
                    </div>
                  }
                >
                  <span>
                    <svg
                      className="icon iconfont icona-45 nemeeting-blacklist-tip"
                      aria-hidden="true"
                    >
                      <use xlinkHref="#icona-45"></use>
                    </svg>
                  </span>
                </Popover>
              </Radio>
            </Space>
          </Radio.Group>
        </div>
      ) : null}
      <div className="screen-share-setting-item">
        <div
          style={{
            fontWeight: 'bold',
          }}
          className="setting-title screen-share-setting-title"
        >
          {t('advancedSettings')}
        </div>
        <div
          className="screen-share-setting-item-content"
          style={{
            height: '16px',
          }}
        >
          <Checkbox
            checked={setting.sharedLimitFrameRateEnable}
            onChange={(e) =>
              handleSharedLimitFrameRateEnableChange(e.target.checked)
            }
          >
            <span>{t('sharedLimitFrameRate')}</span>
          </Checkbox>
          <Select
            defaultValue={20}
            disabled={!setting.sharedLimitFrameRateEnable}
            value={setting.sharedLimitFrameRate}
            style={{ width: 80 }}
            onChange={handleSharedLimitFrameRateChange}
            suffixIcon={null}
            labelRender={({ label }) => (
              <span className="screen-share-setting-select-label">
                {label} <span>{t('sharedLimitFrameRateUnit')}</span>
              </span>
            )}
            options={[
              { value: 5, label: 5 },
              { value: 10, label: 10 },
              { value: 15, label: 15 },
              { value: 20, label: 20 },
              { value: 30, label: 30 },
            ]}
          />
          <Popover
            trigger={'hover'}
            placement={'top'}
            content={
              <div className="toolbar-tip">{t('sharedLimitFrameRateTips')}</div>
            }
          >
            <span>
              <svg
                className="icon iconfont icona-45 nemeeting-blacklist-tip"
                aria-hidden="true"
              >
                <use xlinkHref="#icona-45"></use>
              </svg>
            </span>
          </Popover>
        </div>
      </div>
    </div>
  )
}

export default ScreenShareSetting
