import { CheckboxChangeEvent } from 'antd/es/checkbox'
import CaretDownOutlined from '@ant-design/icons/CaretDownOutlined'

import { useTranslation } from 'react-i18next'
import React, { useEffect } from 'react'
import { Button, Checkbox, Popover, Select } from 'antd'
import { IPCEvent } from '../../../../app/src/types'

interface NormalSettingProps {
  inMeeting?: boolean
  setting: {
    openVideo: boolean
    openAudio: boolean
    showDurationTime: boolean
    showSpeakerList: boolean
    showToolbar: boolean
    enableTransparentWhiteboard: boolean
    enableVoicePriorityDisplay: boolean
    downloadPath: string
    language: string
  }
  onOpenVideoChange: (e: CheckboxChangeEvent) => void
  onOpenAudioChange: (e: CheckboxChangeEvent) => void
  onShowTimeChange: (e: CheckboxChangeEvent) => void
  onShowSpeakerListChange: (e: CheckboxChangeEvent) => void
  onShowToolbarChange: (e: CheckboxChangeEvent) => void
  onEnableTransparentWhiteboardChange: (e: CheckboxChangeEvent) => void
  onEnableVoicePriorityDisplay: (e: CheckboxChangeEvent) => void
  onDownloadPathChange: (path: string) => void
  onLanguageChange: (value: string) => void
}
const NormalSetting: React.FC<NormalSettingProps> = ({
  inMeeting,
  setting,
  onShowSpeakerListChange,
  onShowTimeChange,
  onOpenAudioChange,
  onOpenVideoChange,
  onShowToolbarChange,
  onEnableTransparentWhiteboardChange,
  onEnableVoicePriorityDisplay,
  onDownloadPathChange,
  onLanguageChange,
}) => {
  const { t } = useTranslation()

  const defaultLanguage =
    {
      zh: 'zh-CN',
      en: 'en-US',
      ja: 'ja-JP',
    }[navigator.language.split('-')[0]] || 'en-US'

  const languageValue = setting.language || defaultLanguage

  function handleDownloadPathChange() {
    window.ipcRenderer?.send(IPCEvent.downloadPath, 'set')
    window.ipcRenderer?.once(IPCEvent.downloadPathReply, (event, arg) => {
      onDownloadPathChange(arg)
    })
  }

  useEffect(() => {
    if (!setting.downloadPath && window.isElectronNative) {
      const downloadPath =
        window.ipcRenderer?.sendSync(IPCEvent.downloadPath, 'get') || ''

      onDownloadPathChange(downloadPath)
    }
    // 一定要订阅 setting 变更，否则会导致 downloadPath 无法更新
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [setting])

  return (
    <div className="setting-wrap normal-setting w-full h-full">
      <div>
        {/* <div className="normal-setting-title">{t('meeting')}</div> */}
        <div className="normal-setting-item">
          <Checkbox checked={setting.openVideo} onChange={onOpenVideoChange}>
            {t('openCameraInMeeting')}
          </Checkbox>
        </div>

        <div className="normal-setting-item">
          <Checkbox checked={setting.openAudio} onChange={onOpenAudioChange}>
            {t('openMicInMeeting')}
          </Checkbox>
        </div>

        <div className="normal-setting-item">
          <Checkbox
            checked={setting.showDurationTime}
            onChange={onShowTimeChange}
          >
            {t('showMeetingTime')}
          </Checkbox>
        </div>
        <div className="normal-setting-item">
          <Checkbox
            checked={setting.showSpeakerList}
            onChange={onShowSpeakerListChange}
          >
            {t('showCurrentSpeaker')}
          </Checkbox>
        </div>
        <div className="normal-setting-item">
          <Checkbox
            checked={setting.showToolbar}
            onChange={onShowToolbarChange}
          >
            <span>{t('alwaysDisplayToolbar')}</span>
          </Checkbox>
          <Popover
            trigger={'hover'}
            placement={'top'}
            content={
              <div className="toolbar-tip">{t('alwaysDisplayToolbarTip')}</div>
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
        <div className="normal-setting-item">
          <Checkbox
            checked={setting.enableTransparentWhiteboard}
            onChange={onEnableTransparentWhiteboardChange}
          >
            <span>{t('setWhiteboardTransparency')}</span>
          </Checkbox>
          <Popover
            trigger={'hover'}
            placement={'top'}
            content={
              <div className="toolbar-tip">
                {t('setWhiteboardTransparencyTip')}
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
        </div>
        <div className="normal-setting-item">
          <Checkbox
            checked={setting.enableVoicePriorityDisplay}
            onChange={onEnableVoicePriorityDisplay}
          >
            <span>{t('settingVoicePriorityDisplay')}</span>
          </Checkbox>
          <Popover
            trigger={'hover'}
            placement={'top'}
            content={
              <div className="toolbar-tip">
                {t('settingVoicePriorityDisplayTip')}
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
        </div>
      </div>
      {setting.downloadPath && (
        <div>
          <div
            className="normal-setting-title"
            style={{
              fontWeight: window.systemPlatform === 'win32' ? 'bold' : '500',
            }}
          >
            {t('chat')}
          </div>
          <div className="normal-setting-download">
            <div className="normal-setting-label">{t('downloadPath')}</div>
            <Popover
              trigger="hover"
              content={
                <div style={{ width: '300px', wordWrap: 'break-word' }}>
                  {setting.downloadPath}
                </div>
              }
            >
              <div className="normal-setting-download-path">
                {setting.downloadPath}
              </div>
            </Popover>
            <Button
              type="primary"
              ghost
              style={{ marginLeft: 20 }}
              onClick={handleDownloadPathChange}
            >
              {t('chosePath')}
            </Button>
          </div>
        </div>
      )}
      {inMeeting ? null : (
        <div>
          <div
            className="normal-setting-title"
            style={{
              fontWeight: window.systemPlatform === 'win32' ? 'bold' : '500',
            }}
          >
            {t('chooseLanguage')}
          </div>
          <div className="normal-setting-language">
            {/* <div className="normal-setting-label">{t('chooseLanguage')}</div> */}
            <Select
              value={languageValue}
              className="video-device-select"
              suffixIcon={
                // @ts-ignore
                <CaretDownOutlined style={{ pointerEvents: 'none' }} />
              }
              onChange={onLanguageChange}
              options={[
                { value: 'zh-CN', label: '简体中文' },
                { value: 'en-US', label: 'English' },
                { value: 'ja-JP', label: '日本語' },
              ]}
            />
          </div>
        </div>
      )}
    </div>
  )
}

export default NormalSetting
