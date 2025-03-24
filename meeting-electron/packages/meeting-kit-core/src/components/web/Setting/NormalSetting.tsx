import { CheckboxChangeEvent } from 'antd/es/checkbox'
import CaretDownOutlined from '@ant-design/icons/CaretDownOutlined'

import { useTranslation } from 'react-i18next'
import React, { useEffect } from 'react'
import { Button, Checkbox, Popover, Select, Radio } from 'antd'
import { IPCEvent } from '../../../app/src/types'
import { MeetingSetting } from '../../../kit'

interface NormalSettingProps {
  inMeeting?: boolean
  setting: MeetingSetting['normalSetting']
  onSettingChange: (setting: MeetingSetting['normalSetting']) => void
  onOpenVideoChange: (e: CheckboxChangeEvent) => void
  onOpenAudioChange: (e: CheckboxChangeEvent) => void
  onShowTimeChange: (e: CheckboxChangeEvent) => void
  onShowSpeakerListChange: (e: CheckboxChangeEvent) => void
  onShowToolbarChange: (e: CheckboxChangeEvent) => void
  onEnableTransparentWhiteboardChange: (e: CheckboxChangeEvent) => void
  onEnableVoicePriorityDisplay: (e: CheckboxChangeEvent) => void
  onEnableShowNotYetJoinedMembers: (e: CheckboxChangeEvent) => void
  onAutomaticSavingOfMeetingChatRecords: (e: CheckboxChangeEvent) => void
  onLeaveTheMeetingRequiresConfirmation: (e: CheckboxChangeEvent) => void
  onDownloadPathChange: (path: string) => void
  onLanguageChange: (value: string) => void
  onChatMessageNotificationTypeChange: (value: number) => void
}
const NormalSetting: React.FC<NormalSettingProps> = ({
  inMeeting,
  setting,
  onSettingChange,
  onShowSpeakerListChange,
  onShowTimeChange,
  onOpenAudioChange,
  onOpenVideoChange,
  onShowToolbarChange,
  onEnableTransparentWhiteboardChange,
  onEnableVoicePriorityDisplay,
  onDownloadPathChange,
  onLanguageChange,
  onChatMessageNotificationTypeChange,
  onLeaveTheMeetingRequiresConfirmation,
  onEnableShowNotYetJoinedMembers,
  onAutomaticSavingOfMeetingChatRecords,
}) => {
  const { t } = useTranslation()

  const defaultLanguage =
    {
      zh: 'zh-CN',
      en: 'en-US',
      ja: 'ja-JP',
    }[navigator.language.split('-')[0]] || 'en-US'

  const languageValue = setting.language || defaultLanguage

  function onShowParticipationTime(e: CheckboxChangeEvent) {
    setting.showParticipationTime = e.target.checked
    onSettingChange({ ...setting })
  }

  function onEnterFullscreen(e: CheckboxChangeEvent) {
    setting.enterFullscreen = e.target.checked
    onSettingChange({ ...setting })
  }

  function onDualMonitors(e: CheckboxChangeEvent) {
    setting.dualMonitors = e.target.checked
    // 同时勾中全屏进入
    if (setting.dualMonitors && !inMeeting) {
      setting.enterFullscreen = true
    }

    onSettingChange({ ...setting })
  }

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
            checked={setting.showParticipationTime ?? false}
            onChange={onShowParticipationTime}
          >
            {t('settingShowParticipationTime')}
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
            checked={setting.leaveTheMeetingRequiresConfirmation ?? true}
            onChange={onLeaveTheMeetingRequiresConfirmation}
          >
            <span>{t('settingLeaveTheMeetingRequiresConfirmation')}</span>
          </Checkbox>
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
        {window.isElectronNative ? (
          <div className="normal-setting-item">
            <Checkbox checked={setting.dualMonitors} onChange={onDualMonitors}>
              <span>{t('settingDualMonitors')}</span>
            </Checkbox>
            <Popover
              trigger={'hover'}
              placement={'top'}
              content={
                <div className="toolbar-tip">{t('settingDualMonitorsTip')}</div>
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
        ) : null}
        {window.isElectronNative ? (
          <div className="normal-setting-item">
            <Checkbox
              checked={setting.enterFullscreen}
              onChange={onEnterFullscreen}
            >
              <span>{t('settingEnterFullscreen')}</span>
            </Checkbox>
          </div>
        ) : null}
        <div className="normal-setting-item">
          <Checkbox
            checked={!setting.enableShowNotYetJoinedMembers}
            onChange={onEnableShowNotYetJoinedMembers}
          >
            <span>{t('settingHideNotYetJoinedMembers')}</span>
          </Checkbox>
          <Popover
            trigger={'hover'}
            placement={'top'}
            content={
              <div className="toolbar-tip">
                {t('settingHideNotYetJoinedMembersTip')}
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
      {
        <div>
          <div
            className="normal-setting-title"
            style={{
              fontWeight: 'bold',
            }}
          >
            {t('chat')}
          </div>
          <div className="normal-setting-download" style={{ marginBottom: 20 }}>
            <div className="normal-setting-label">
              {t('settingChatMessageNotification')}
            </div>
            <Radio.Group
              onChange={(e) =>
                onChatMessageNotificationTypeChange(e.target.value)
              }
              value={setting.chatMessageNotificationType}
              defaultValue={0}
            >
              <Radio value={0}>
                {t('settingChatMessageNotificationBarrage')}
              </Radio>
              <Radio value={1}>
                {t('settingChatMessageNotificationBubble')}
              </Radio>
              <Radio value={2}>
                {t('settingChatMessageNotificationNoReminder')}
              </Radio>
            </Radio.Group>
          </div>
          {setting.downloadPath ? (
            <div
              className="normal-setting-download"
              style={{ marginBottom: 20 }}
            >
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
          ) : null}
          {setting.downloadPath ? (
            <div className="normal-setting-item">
              <Checkbox
                checked={setting.automaticSavingOfMeetingChatRecords}
                onChange={onAutomaticSavingOfMeetingChatRecords}
              >
                <span>{t('settingAutomaticSavingOfMeetingChatRecords')}</span>
              </Checkbox>
              <Popover
                trigger={'hover'}
                placement={'top'}
                content={
                  <div className="toolbar-tip">
                    {t('settingAutomaticSavingOfMeetingChatRecordsTips')}
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
          ) : null}
        </div>
      }
      {inMeeting ? null : (
        <div>
          <div
            className="normal-setting-title"
            style={{
              fontWeight: 'bold',
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
