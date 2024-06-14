import { Checkbox, Slider, Divider, Dropdown, MenuProps } from 'antd'
import React, { useEffect, useMemo, useRef } from 'react'
import { useTranslation } from 'react-i18next'
import {
  InterpretationRes,
  NEMeetingInterpretationSettings,
} from '../../../types/type'
import { useInterpreterLang } from '../../../hooks/useInterpreterLang'
import CloseOutlined from '@ant-design/icons/CloseOutlined'
import NEMeetingService from '../../../services/NEMeeting'
import { useGlobalContext } from '../../../store'
import { ActionType, NEMember, Role } from '../../../types'
import { MAJOR_AUDIO } from '../../../config'
import { useUpdateEffect } from 'ahooks'

interface InterpretationWindowProps {
  className?: string
  interpretation?: InterpretationRes
  interpretationSetting?: NEMeetingInterpretationSettings
  isInterpreter?: boolean
  defaultMajorVolume: number
  defaultListeningVolume: number
  neMeeting?: NEMeetingService
  localMember: NEMember
  onClickManagement?: () => void
  onClose?: () => void
  onMaxWindow?: () => void
  floatingWindow?: boolean
  isMiniWindow?: boolean
  onClickMiniWindow?: (isMini: boolean) => void
  onOpenSelectChange?: (open: boolean) => void
  style?: React.CSSProperties
}

const InterpretationWindow: React.FC<InterpretationWindowProps> = ({
  className,
  interpretation,
  interpretationSetting,
  defaultMajorVolume,
  isInterpreter,
  neMeeting,
  localMember,
  onClickManagement,
  onClose,
  isMiniWindow,
  floatingWindow,
  onMaxWindow,
  onClickMiniWindow,
  defaultListeningVolume,
  onOpenSelectChange,
  style,
}) => {
  const { t } = useTranslation()

  const myUuid = useMemo(() => {
    return localMember.uuid
  }, [localMember.uuid])

  const {
    languageMap,
    listeningOptions,
    onPlayoutVolumeChange,
    onMuteChange,
    handleListeningLanguageChange,
    speakerOptions,
    handleListenMajor,
    majorVolume,
  } = useInterpreterLang({
    interpretation,
    interpretationSetting,
    neMeeting,
    myUuid,
    defaultMajorVolume,
    isInterpreter,
    defaultListeningVolume,
  })
  const { dispatch } = useGlobalContext()
  const [openSelect, setOpenSelect] = React.useState(false)

  const headerRef = useRef<HTMLDivElement>(null)
  const interpretationWindowRef = useRef<HTMLDivElement>(null)

  const isHost = useMemo(() => {
    return localMember.role === Role.host || localMember.role === Role.coHost
  }, [localMember.role])

  const onClickChangeListeningLanguageChange = (
    value: string,
    disable?: boolean
  ) => {
    if (disable) {
      return
    }

    handleListeningLanguageChange(value)
  }

  const items: MenuProps['items'] = useMemo(() => {
    return listeningOptions.map((option) => {
      return {
        key: option.value,
        label: (
          <div
            key={option.value}
            className={`ne-interp-language-item ${
              option.disabled ? 'ne-interp-language-item-disabled' : ''
            }`}
            onClick={() =>
              onClickChangeListeningLanguageChange(
                option.value,
                option.disabled
              )
            }
          >
            <div className="ne-interp-language-item-content nemeeting-ellipsis">
              <div className="nemeeting-ellipsis">{option.label}</div>
              {interpretationSetting?.listenLanguage === option.value && (
                <svg
                  className="icon iconfont ne-interp-slider-icon"
                  aria-hidden="true"
                >
                  <use xlinkHref="#iconcheck-line-regular1x"></use>
                </svg>
              )}
            </div>
          </div>
        ),
      }
    })
  }, [
    listeningOptions,
    interpretationSetting?.listenLanguage,
    handleListeningLanguageChange,
  ])

  useEffect(() => {
    if (floatingWindow) {
      return
    }

    // header 支持鼠标拖动
    const headerEle = headerRef.current
    const interpretationWindowEle = interpretationWindowRef.current
    const container = document.getElementById('meeting-web')

    if (!headerEle || !interpretationWindowEle || !container) return
    let disX = 0
    let disY = 0
    const handleMouseDone = (e: MouseEvent) => {
      const { left, top } = interpretationWindowEle.getBoundingClientRect()

      // 拖动窗口
      disX = e.clientX - left
      disY = e.clientY - top
      const move = (e: MouseEvent) => {
        const { clientX, clientY } = e

        // 不能超过容器左右边界
        if (clientX - disX <= 2) {
          interpretationWindowEle.style.left = '2px'
        } else if (
          clientX - disX >=
          container.clientWidth - interpretationWindowEle.clientWidth - 2
        ) {
          interpretationWindowEle.style.left =
            container.clientWidth -
            interpretationWindowEle.clientWidth -
            2 +
            'px'
        } else {
          interpretationWindowEle.style.left = clientX - disX + 'px'
        }

        // 不能超过容器上下边界
        if (clientY - disY <= 2) {
          interpretationWindowEle.style.top = '2px'
        } else if (
          clientY - disY >=
          container.clientHeight - interpretationWindowEle.clientHeight - 2
        ) {
          interpretationWindowEle.style.top =
            container.clientHeight -
            interpretationWindowEle.clientHeight -
            2 +
            'px'
        } else {
          // 需要去除顶部header
          if (window.isElectronNative) {
            interpretationWindowEle.style.top = clientY - disY - 28 + 'px'
          } else {
            interpretationWindowEle.style.top = clientY - disY + 'px'
          }
        }
      }

      const up = () => {
        document.removeEventListener('mousemove', move)
        document.removeEventListener('mouseup', up)
      }

      document.addEventListener('mousemove', move)
      document.addEventListener('mouseup', up)
    }

    headerEle.addEventListener('mousedown', handleMouseDone)
    return () => {
      headerEle.removeEventListener('mousedown', handleMouseDone)
    }
  }, [floatingWindow])

  const handleMiniWindow = () => {
    onClickMiniWindow?.(!isMiniWindow)
  }

  const activeTag = useMemo(() => {
    const speakerLanguage = interpretationSetting?.speakerLanguage

    return speakerLanguage
  }, [interpretationSetting?.speakerLanguage])

  const onChangeSpeakerLanguage = async (language: string) => {
    const preLang = interpretationSetting?.speakerLanguage

    if (preLang === language) {
      console.log('切换语言相同')
      return
    }

    let listenLanguage = interpretationSetting?.listenLanguage
    let needChangeListeningLang = false

    // 如果收听语言和切换的语音相同则需要把收听语言切到另外一个翻译语言
    if (language != MAJOR_AUDIO && language == listenLanguage) {
      listenLanguage = speakerOptions.find(
        (option) => option.value != language && option.value != MAJOR_AUDIO
      )?.value
      if (listenLanguage) {
        needChangeListeningLang = true
      }
    }

    dispatch?.({
      type: ActionType.UPDATE_GLOBAL_CONFIG,
      data: {
        interpretationSetting: {
          listenLanguage: listenLanguage || MAJOR_AUDIO,
          speakerLanguage: language,
        },
      },
    })
    if (needChangeListeningLang && listenLanguage) {
      neMeeting?.rtcController?.adjustChannelPlaybackSignalVolume(
        language,
        defaultListeningVolume
      )
    }

    if (!preLang || preLang === MAJOR_AUDIO) {
      await neMeeting?.enableAndPubAudio(false, '')
    } else {
      const preChannelName = interpretation?.channelNames[preLang]

      preChannelName &&
        (await neMeeting?.enableAndPubAudio(false, preChannelName))
    }

    const channelName =
      language === MAJOR_AUDIO ? '' : interpretation?.channelNames[language]

    await neMeeting?.enableAndPubAudio(true, channelName || '')
  }

  const renderLabel = useMemo(() => {
    const listenLang =
      languageMap[interpretationSetting?.listenLanguage || ''] ||
      interpretationSetting?.listenLanguage

    return interpretationSetting?.isListenMajor
      ? `${listenLang}+${languageMap[MAJOR_AUDIO]}`
      : listenLang
  }, [
    languageMap,
    interpretationSetting?.listenLanguage,
    interpretationSetting?.isListenMajor,
  ])

  useUpdateEffect(() => {
    onOpenSelectChange?.(openSelect)
  }, [openSelect])

  return !floatingWindow ? (
    <div
      className={`nemeeting-interp-window ${className || ''}`}
      ref={interpretationWindowRef}
      style={style}
    >
      <div className="nemeetin-interp-win-header" ref={headerRef}>
        <div className="ne-interp-win-title">{t('interpretation')}</div>
        <div className="ne-interp-win-header-operator">
          {(isHost || isInterpreter) && (
            <svg
              style={{ marginRight: '12px', cursor: 'pointer' }}
              className="icon iconfont ne-interp-slider-icon"
              aria-hidden="true"
              onClick={() => handleMiniWindow()}
            >
              <use
                xlinkHref={`${
                  isMiniWindow ? '#icona-Frame3' : '#icona-Frame1'
                }`}
              ></use>
            </svg>
          )}

          <CloseOutlined
            onClick={() => onClose?.()}
            style={{ color: '#fff', width: '16px', height: '16px' }}
          />
        </div>
      </div>
      {!isMiniWindow && (
        <div className="ne-interp-win-content">
          {isInterpreter && (
            <div
              className="ne-interp-win-inter"
              title={t('interpSpeakerTip', {
                language1: renderLabel,
                language2: interpretationSetting?.speakerLanguage
                  ? languageMap[interpretationSetting?.speakerLanguage] ||
                    interpretationSetting?.speakerLanguage
                  : '',
              })}
            >
              {t('interpSpeakerTip', {
                language1: renderLabel,
                language2: interpretationSetting?.speakerLanguage
                  ? languageMap[interpretationSetting?.speakerLanguage] ||
                    interpretationSetting?.speakerLanguage
                  : '',
              })}
            </div>
          )}
          <div>
            <div className="ne-interp-win-listen nemeeting-ellipsis">
              {t('interpSelectListenLanguage')}
            </div>
            <Dropdown
              open={openSelect}
              overlayClassName="ne-interp-language-select"
              autoAdjustOverflow={window.isElectronNative ? false : true}
              onOpenChange={(open) => setOpenSelect(open)}
              placement={'bottomLeft'}
              trigger={['click', 'hover']}
              menu={{ items }}
              dropdownRender={(menu) => (
                <div className="ne-interp-language-dropdown">
                  <div className="ne-interp-language-major-tip nemeeting-ellipsis">
                    <div className="nemeeting-ellipsis">
                      {t('interpSelectListenLanguage')}
                    </div>
                  </div>
                  {menu}
                  {interpretationSetting?.listenLanguage !== MAJOR_AUDIO && (
                    <>
                      <Divider
                        style={{
                          marginBottom: '8px',
                          marginTop: '0',
                          background: 'rgba(255, 255, 255, 0.16)',
                        }}
                      />
                      <div
                        className="ne-interp-language-major"
                        onClick={() => handleListenMajor()}
                      >
                        {t('interpListenMajorAudioMeanwhile')}
                        {interpretationSetting?.isListenMajor && (
                          <svg
                            className="icon iconfont ne-interp-slider-icon"
                            aria-hidden="true"
                          >
                            <use xlinkHref="#iconcheck-line-regular1x"></use>
                          </svg>
                        )}
                      </div>
                    </>
                  )}
                </div>
              )}
            >
              <div
                className="nemeeting-interp-drop-name nemeeting-ellipsis"
                onClick={() => setOpenSelect(true)}
              >
                <div className="nemeeting-ellipsis">{renderLabel}</div>
              </div>
            </Dropdown>
          </div>
          {isInterpreter && (
            <div style={{ marginTop: '12px' }}>
              <div className="ne-interp-win-listen">
                {t('interpOutputLanguage')}
              </div>
              <div className="ne-interp-win-tab">
                {speakerOptions.map((option) => {
                  return (
                    <div
                      onClick={() => onChangeSpeakerLanguage(option.value)}
                      key={option.value}
                      className={`ne-interp-win-tab-item nemeeting-ellipsis ${
                        activeTag === option.value
                          ? 'ne-interp-win-tab-item-selected'
                          : ''
                      }`}
                    >
                      <span className="ne-interp-win-tab-item-label nemeeting-ellipsis">
                        {option.label}
                      </span>
                    </div>
                  )
                })}
              </div>
            </div>
          )}
          {interpretationSetting?.isListenMajor && (
            <div className="ne-interp-major">
              <div className="ne-interp-major-content">
                <div>{t('interpMajorAudioVolume')}</div>
                <Checkbox
                  onChange={(e) => onMuteChange(e.target.checked, majorVolume)}
                  style={{ color: '#fff' }}
                >
                  {t('participantMute')}
                </Checkbox>
              </div>
              {!interpretationSetting.muted && (
                <div className="ne-interp-slider-wrapper">
                  <svg
                    className="icon iconfont ne-interp-slider-icon"
                    aria-hidden="true"
                  >
                    <use xlinkHref="#iconsound-medium"></use>
                  </svg>
                  <Slider
                    style={{ flex: 1 }}
                    max={100}
                    onChange={onPlayoutVolumeChange}
                    className="output-slider"
                    value={majorVolume}
                    defaultValue={defaultMajorVolume}
                  />
                  <svg
                    className="icon iconfont ne-interp-slider-icon"
                    aria-hidden="true"
                  >
                    <use xlinkHref="#iconsound-loud"></use>
                  </svg>
                </div>
              )}
            </div>
          )}
          {isHost && (
            <div
              className="ne-interp-major ne-interp-manager"
              onClick={() => onClickManagement?.()}
            >
              <div>{t('interpManagement')}</div>
              <svg
                className="icon iconfont ne-interp-manager-icon"
                aria-hidden="true"
              >
                <use xlinkHref="#iconyx-allowx"></use>
              </svg>
            </div>
          )}
        </div>
      )}
    </div>
  ) : (
    <div
      className={`nemeeting-interp-floating ${className || ''}`}
      onClick={() => onMaxWindow?.()}
    >
      <svg
        className="icon iconfont"
        aria-hidden="true"
        style={{ color: '#fff', fontSize: '24px' }}
      >
        <use xlinkHref="#icontongshengchuanyi"></use>
      </svg>
    </div>
  )
}

export default InterpretationWindow
