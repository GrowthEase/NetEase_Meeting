import { useTranslation } from 'react-i18next'
import './index.less'
import Slider from 'antd-mobile/es/components/slider'
import Switch from 'antd-mobile/es/components/switch'
import {
  InterpretationRes,
  NEMeetingInterpretationSettings,
  NEMember,
} from '../../../types/type'
import NEMeetingService from '../../../services/NEMeeting'
import { useInterpreterLang } from '../../../hooks/useInterpreterLang'
import React, { useMemo, useState } from 'react'
import { MAJOR_AUDIO } from '../../../config'

interface InterpretationProps {
  className?: string
  visible?: boolean
  onClose?: () => void
  defaultMajorVolume: number
  defaultListeningVolume: number
  interpretation?: InterpretationRes
  interpretationSetting?: NEMeetingInterpretationSettings
  neMeeting?: NEMeetingService
  localMember?: NEMember
}
const Interpretation: React.FC<InterpretationProps> = ({
  className,
  onClose,
  visible,
  defaultMajorVolume,
  interpretation,
  interpretationSetting,
  neMeeting,
  localMember,
  defaultListeningVolume,
}) => {
  const { t } = useTranslation()
  const [showLanguage, setShowLanguage] = useState(false)
  const {
    languageMap,
    listeningOptions,
    onPlayoutVolumeChange,
    onMuteChange,
    majorVolume,
    handleListeningLanguageChange,
    handleListenMajor,
  } = useInterpreterLang({
    interpretation,
    neMeeting,
    interpretationSetting,
    isInterpreter: false,
    myUuid: localMember?.uuid || '',
    defaultListeningVolume,
    defaultMajorVolume,
  })
  const handleClose = (e: React.MouseEvent) => {
    onClose?.()
    e.stopPropagation()
  }

  const onSliderChange = (value: number | [number, number]) => {
    if (Array.isArray(value)) {
      return
    }

    onPlayoutVolumeChange(value)
  }

  const onChangeListeningLanguage = (language: string) => {
    handleListeningLanguageChange(language)
    setShowLanguage(false)
  }

  const onClickListenMajor = () => {
    setShowLanguage(false)
    handleListenMajor()
  }

  const currentListeningLang = useMemo(() => {
    const listenLanguage =
      languageMap[interpretationSetting?.listenLanguage || ''] ||
      interpretationSetting?.listenLanguage

    return interpretationSetting?.isListenMajor
      ? `${listenLanguage}+${languageMap[MAJOR_AUDIO]}`
      : listenLanguage
  }, [
    languageMap,
    interpretationSetting?.listenLanguage,
    interpretationSetting?.isListenMajor,
  ])

  return (
    <div
      className={`ne-meeting-interpretation-h5 ${
        visible ? 'ne-meeting-interp-show' : ''
      } ${className || ''}`}
      onClick={(e) => handleClose(e)}
    >
      <div
        className={`ne-meeting-interp-content-h5 ${
          visible ? 'ne-meeting-interp-show' : ''
        }`}
        onClick={(e) => {
          e.stopPropagation()
        }}
      >
        <div className="ne-meeting-interp-header">{t('interpretation')}</div>
        <div className="ne-meeting-interp-content-wrapper">
          {!showLanguage ? (
            <div>
              <div className="ne-meeting-interp-tip">
                {t('interpSelectListenLanguage')}
              </div>
              <div
                className="ne-meeting-interp-content-item"
                onClick={() => setShowLanguage(true)}
              >
                <div>{currentListeningLang}</div>
                <svg
                  className="icon iconfont ne-meeting-interp-itme-icon"
                  aria-hidden="true"
                >
                  <use xlinkHref="#iconyx-allowx"></use>
                </svg>
              </div>
              {interpretationSetting?.isListenMajor && (
                <>
                  <div className="ne-meeting-interp-tip">
                    {t('interpMajorAudioVolume')}
                  </div>
                  <div className="ne-meeting-interp-content-item">
                    <div>{t('participantMute')}</div>
                    <Switch
                      checked={interpretationSetting?.muted}
                      onChange={(checked) => onMuteChange(checked, majorVolume)}
                    />
                  </div>
                  {interpretationSetting?.muted ? null : (
                    <div className="ne-meeting-interp-content-item">
                      <div className="ne-meeting-interp-content-slider">
                        <svg
                          className="icon iconfont ne-interp-slider-icon"
                          aria-hidden="true"
                        >
                          <use xlinkHref="#iconsound-medium"></use>
                        </svg>
                        <Slider
                          style={{ flex: 1 }}
                          value={majorVolume}
                          defaultValue={defaultMajorVolume}
                          onChange={onSliderChange}
                        />
                        <svg
                          className="icon iconfont ne-interp-slider-icon"
                          aria-hidden="true"
                        >
                          <use xlinkHref="#iconsound-loud"></use>
                        </svg>
                      </div>
                    </div>
                  )}
                </>
              )}
            </div>
          ) : (
            <div style={{ paddingBottom: '56px' }}>
              {listeningOptions.map((option) => (
                <div
                  key={option.value}
                  className="ne-meeting-interp-content-item"
                  onClick={() => onChangeListeningLanguage(option.value)}
                >
                  <div>{option.label}</div>
                  {interpretationSetting?.listenLanguage === option.value && (
                    <svg
                      className="icon iconfont ne-interp-slider-icon"
                      aria-hidden="true"
                      style={{ color: '#337EFF' }}
                    >
                      <use xlinkHref="#iconcheck-line-regular1x"></use>
                    </svg>
                  )}
                </div>
              ))}
              {interpretationSetting?.listenLanguage !== MAJOR_AUDIO && (
                <div
                  className="ne-meeting-interp-content-item"
                  onClick={() => onClickListenMajor()}
                >
                  <div>{t('interpListenMajorAudioMeanwhile')}</div>
                  {interpretationSetting?.isListenMajor && (
                    <svg
                      className="icon iconfont ne-interp-slider-icon"
                      aria-hidden="true"
                      style={{ color: '#337EFF' }}
                    >
                      <use xlinkHref="#iconcheck-line-regular1x"></use>
                    </svg>
                  )}
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

export default Interpretation
