import { useTranslation } from 'react-i18next'
import React from 'react'
import { Radio, Checkbox, Space } from 'antd'
import { MeetingSetting, NECloudRecordStrategyType } from '../../../types'
import './index.less'

interface RecordSettingProps {
  setting: MeetingSetting['recordSetting']
  onAutoCloudRecordChange: (checked: boolean) => void
  onAutoCloudRecordStrategyChange: (value: number) => void
}
const RecordSetting: React.FC<RecordSettingProps> = ({
  setting,
  onAutoCloudRecordChange,
  onAutoCloudRecordStrategyChange,
}) => {
  const { t } = useTranslation()

  return (
    <div className="setting-wrap record-setting w-full h-full">
      <div className="record-setting-item">
        <div
          style={{
            fontWeight: 'bold',
          }}
          className="setting-title"
        >
          {t('autoRecord')}
        </div>
        <div className="record-setting-content">
          <div className="record-setting-content-item">
            <Checkbox
              className="checkbox-space"
              checked={setting.autoCloudRecord}
              onChange={(e) => {
                onAutoCloudRecordChange(e.target.checked)
              }}
            >
              {t('meetingCloudRecord')}
            </Checkbox>
            {setting.autoCloudRecord && (
              <div className="record-setting-content-sub-item">
                <Radio.Group
                  onChange={(e) => {
                    onAutoCloudRecordStrategyChange(e.target.value)
                  }}
                  value={setting.autoCloudRecordStrategy}
                >
                  <Space direction="vertical">
                    <Radio value={NECloudRecordStrategyType.HOST_JOIN}>
                      {t('meetingEnableCouldRecordWhenHostJoin')}
                    </Radio>
                    <Radio value={NECloudRecordStrategyType.MEMBER_JOIN}>
                      {t('meetingEnableCouldRecordWhenMemberJoin')}
                    </Radio>
                  </Space>
                </Radio.Group>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

export default RecordSetting
