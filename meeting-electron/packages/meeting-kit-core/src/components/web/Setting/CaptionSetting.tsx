import { CaretDownOutlined } from '@ant-design/icons'
import { Checkbox, Select, Slider } from 'antd'
import React, { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { MeetingSetting } from '../../../types/innerType'
import { NERoomCaptionTranslationLanguage } from 'neroom-types'
import { getLocalStorageSetting } from '../../../kit'

interface CaptionSettingProps {
  onSizeChange: (size: number) => void
  captionSetting: MeetingSetting['captionSetting']
  onEnableCaptionWhenJoinMeetingChange: (enable: boolean) => void
  onCaptionShowBilingual: (enable: boolean) => void
  onTranslateShowBilingual: (enable: boolean) => void
  onTargetLanguageChange: (lang: NERoomCaptionTranslationLanguage) => void
  showCaption: boolean
  showTranscript: boolean
}

const CaptionSetting: React.FC<CaptionSettingProps> = ({
  onSizeChange,
  captionSetting,
  onEnableCaptionWhenJoinMeetingChange,
  onTargetLanguageChange,
  onCaptionShowBilingual,
  onTranslateShowBilingual,
  showCaption,
  showTranscript,
}) => {
  const { t } = useTranslation()

  const [localCaptionSetting, setLocalCaptionSetting] = useState(captionSetting)

  useEffect(() => {
    captionSetting && setLocalCaptionSetting(captionSetting)
  }, [captionSetting])
  useEffect(() => {
    // 切换标签需要同步漫游配置
    const setting = getLocalStorageSetting()

    if (setting) {
      setLocalCaptionSetting(setting.captionSetting)
    }
  }, [])

  return (
    <div className="setting-wrap normal-setting w-full h-full">
      {showCaption && (
        <>
          <div
            className="normal-setting-title"
            style={{
              fontWeight: 'bold',
            }}
          >
            {t('transcriptionCaptionSettings')}
          </div>
          <div className="nemeeting-setting-caption-size-wrapper">
            <div>{t('transcriptionCaptionTypeSize')}</div>
            <Slider
              marks={{
                12: ' ',
                15: ' ',
                18: ' ',
                21: ' ',
                24: ' ',
              }}
              className="nemeeting-setting-caption-size-slider"
              onChange={onSizeChange}
              defaultValue={localCaptionSetting.fontSize || 15}
              max={24}
              min={12}
              step={3}
            />
          </div>
          <div
            className={`nemeeting-setting-caption-show nemeeting-setting-caption-${
              localCaptionSetting.fontSize || 15
            }`}
          >
            <div className="nemeeting-setting-caption-demo">
              <div className="nemeeting-setting-caption-demo-text">
                {t('transcriptionCaptionExampleSize')}
              </div>
              <div className="nemeeting-setting-caption-demo-en">
                Example of subtitle text size
              </div>
            </div>
          </div>
          <div>
            <Checkbox
              className="checkbox-space"
              checked={localCaptionSetting.autoEnableCaptionsOnJoin}
              onChange={(e) => {
                onEnableCaptionWhenJoinMeetingChange(e.target.checked)
              }}
            >
              {t('transcriptionEnableCaptionOnJoin')}
            </Checkbox>
          </div>
        </>
      )}

      {showTranscript && (
        <>
          <div
            className="normal-setting-title nemeeting-trans-setting-title"
            style={{
              fontWeight: 'bold',
            }}
          >
            {t('transcriptionTranslationSettings')}
            <span className="nemeeting-tran-setting-tip">
              （{t('transcriptionTranslationSettingsTip')}）
            </span>
          </div>
          <div className="normal-setting-language">
            <div
              className="normal-setting-label"
              title={t('transcriptionTargetLang')}
            >
              {t('transcriptionTargetLang')}
            </div>
            <Select
              value={
                localCaptionSetting.targetLanguage ||
                NERoomCaptionTranslationLanguage.NONE
              }
              className="video-device-select"
              suffixIcon={
                <CaretDownOutlined style={{ pointerEvents: 'none' }} />
              }
              onChange={onTargetLanguageChange}
              options={[
                {
                  value: NERoomCaptionTranslationLanguage.NONE,
                  label: t('transcriptionNotTranslated'),
                },
                {
                  value: NERoomCaptionTranslationLanguage.CHINESE,
                  label: t('langChinese'),
                },
                {
                  value: NERoomCaptionTranslationLanguage.ENGLISH,
                  label: t('langEnglish'),
                },
                {
                  value: NERoomCaptionTranslationLanguage.JAPANESE,
                  label: t('langJapanese'),
                },
              ]}
            />
          </div>
          {showCaption && (
            <div>
              <Checkbox
                className="checkbox-space"
                checked={localCaptionSetting.showCaptionBilingual}
                onChange={(e) => {
                  onCaptionShowBilingual(e.target.checked)
                }}
              >
                {t('transcriptionCaptionShowBilingual')}
              </Checkbox>
            </div>
          )}
          {showTranscript && (
            <div>
              <Checkbox
                className="checkbox-space"
                checked={localCaptionSetting.showTranslationBilingual}
                onChange={(e) => {
                  onTranslateShowBilingual(e.target.checked)
                }}
              >
                {t('transcriptionSettingShowBilingual')}
              </Checkbox>
            </div>
          )}
        </>
      )}
    </div>
  )
}

export default CaptionSetting
