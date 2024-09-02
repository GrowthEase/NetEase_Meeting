import React, { useCallback, useMemo, useState } from 'react'
import { useTranslation } from 'react-i18next'
import './index.less'
import useTranslationOptions from '../../../hooks/useTranslationOptions'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import { ActionSheet, Switch } from 'antd-mobile/es'
import { MeetingSetting } from '../../../types'
import { createDefaultCaptionSetting } from '../../../services'
import { NERoomCaptionTranslationLanguage } from 'neroom-types'

interface SettingProps {
  className?: string
  visible?: boolean
  onClose?: () => void
  onSettingChange: (setting: MeetingSetting) => void
}
const Setting: React.FC<SettingProps> = ({
  className,
  visible,
  onClose,
  onSettingChange,
}) => {
  const { neMeeting } = useGlobalContext()
  const { t } = useTranslation()
  const { meetingInfo } = useMeetingInfoContext()
  const [showLanguageOptions, setShowLanguageOptions] = useState(false)

  const { translationMap, translationOptions } = useTranslationOptions()

  const targetLanguage = useMemo(() => {
    return meetingInfo.setting.captionSetting?.targetLanguage
  }, [meetingInfo.setting.captionSetting?.targetLanguage])
  const handleClose = (e: React.MouseEvent) => {
    onClose?.()
    e.stopPropagation()
  }

  const onTargetLanguageChange = useCallback(
    (lang: NERoomCaptionTranslationLanguage) => {
      const setting = meetingInfo.setting

      if (!setting.captionSetting) {
        setting.captionSetting = createDefaultCaptionSetting()
      } else {
        setting.captionSetting.targetLanguage = lang
      }

      onSettingChange?.(setting)
    },
    [onSettingChange]
  )

  const onCaptionShowBilingual = useCallback(
    (enable: boolean) => {
      const setting = meetingInfo.setting

      if (!setting.captionSetting) {
        setting.captionSetting = createDefaultCaptionSetting()
      } else {
        setting.captionSetting.showCaptionBilingual = enable
      }

      onSettingChange?.(setting)
    },
    [onSettingChange]
  )

  const actions = useMemo(() => {
    return translationOptions.map((item) => {
      return {
        text: (
          <div className="nemeeting-tran-action-item">
            <div>{item.label}</div>
            {item.value == targetLanguage && (
              <svg
                className="icon iconfont"
                aria-hidden="true"
                style={{ color: '#337EFF' }}
              >
                <use xlinkHref="#iconcheck-line-regular1x"></use>
              </svg>
            )}
          </div>
        ),
        key: item.value,
        onClick: () => {
          if (item.value === targetLanguage) {
            return
          }

          setShowLanguageOptions(false)
          neMeeting?.setCaptionTranslationLanguage(item.value)
          onTargetLanguageChange(item.value)
        },
      }
    })
  }, [translationOptions, onTargetLanguageChange, targetLanguage])

  return (
    <div
      className={`ne-meeting-setting-h5 ${
        visible ? 'ne-meeting-setting-show' : ''
      } ${className || ''}`}
      onClick={(e) => handleClose(e)}
    >
      <div
        className={`ne-meeting-setting-content-h5 ${
          visible ? 'ne-meeting-setting-show' : ''
        }`}
        onClick={(e) => {
          e.stopPropagation()
        }}
      >
        <div className="ne-meeting-setting-header">
          {t('transcriptionTranslationSettings')}
        </div>
        <div className="ne-meeting-setting-content-wrapper">
          <div className="ne-meeting-tran-setting">
            <div className="ne-meeting-setting-tran-title">
              <svg
                className="icon iconfont"
                aria-hidden="true"
                style={{ marginRight: '4px' }}
              >
                <use xlinkHref="#iconshezhi-12px"></use>
              </svg>
              <div>{t('transcriptionTranslationSettings')}</div>
            </div>
            <div
              className="ne-meeting-setting-tran-item"
              onClick={() => {
                setShowLanguageOptions(true)
              }}
            >
              <div className="ne-meeting-setting-tran-item-title">
                {t('transcriptionTargetLang')}
              </div>
              <div className="ne-meeting-setting-tran-item-end">
                {translationMap[targetLanguage || ''] ||
                  t('transcriptionNotTranslated')}
                <svg
                  className="icon iconfont"
                  aria-hidden="true"
                  style={{ fontSize: '14px', marginLeft: '12px' }}
                >
                  <use xlinkHref="#iconyx-allowx"></use>
                </svg>
              </div>
            </div>
            <div className="ne-meeting-setting-tran-item">
              <div className="ne-meeting-setting-tran-item-title">
                {t('transcriptionCaptionShowBilingual')}
              </div>
              <div className="ne-meeting-setting-tran-item-end">
                <Switch
                  checked={
                    meetingInfo.setting?.captionSetting?.showCaptionBilingual
                  }
                  onChange={(checked) => onCaptionShowBilingual(checked)}
                />
              </div>
            </div>
          </div>
        </div>
      </div>
      <ActionSheet
        popupClassName="nemeeting-tran-action-wrapper"
        visible={showLanguageOptions}
        actions={actions}
        getContainer={null}
        onClose={() => setShowLanguageOptions(false)}
      />
    </div>
  )
}

export default React.memo(Setting)
