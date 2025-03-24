import { useTranslation } from 'react-i18next'
import React, { useEffect, useState } from 'react'
import { Radio, Checkbox, Space, Popover, Button } from 'antd'
import { MeetingSetting, NECloudRecordStrategyType } from '../../../types'
import { IPCEvent } from '../../../app/src/types'
import Toast from '../../common/toast'
import './index.less'
import './RecordSetting.less'
import { useGlobalContext } from '../../../store'

interface RecordSettingProps {
  setting: MeetingSetting['recordSetting']
  onAutoCloudRecordChange: (checked: boolean) => void
  onAutoCloudRecordStrategyChange: (value: number) => void
  onLocalRecordAudioChange: (checked: boolean) => void
  onLocalRecordNickNameChange: (checked: boolean) => void
  onLocalRecordTimestampChange: (value: boolean) => void
  onLocalRecordScreenShareAndVideoChange: (value: boolean) => void
  onLocalRecordScreenShareSideBySideVideoChange: (checked: boolean) => void
  onLocalRecordDefaultPathChange: (value: string) => void
  onSettingChange: (setting: MeetingSetting['recordSetting']) => void
}
const RecordSetting: React.FC<RecordSettingProps> = ({
  setting,
  onAutoCloudRecordChange,
  onAutoCloudRecordStrategyChange,
  onLocalRecordAudioChange,
  onLocalRecordNickNameChange,
  onLocalRecordTimestampChange,
  onLocalRecordScreenShareAndVideoChange,
  onLocalRecordScreenShareSideBySideVideoChange,
  onLocalRecordDefaultPathChange,
  onSettingChange,
}) => {
  const { t } = useTranslation()
  const { globalConfig } = useGlobalContext()
  const [defaultPath, setDefaultPath] = useState('')
  const [remainingSpace, setRemainingSpace] = useState('189G')

  const cloudRecordEnable = globalConfig?.appConfig?.APP_ROOM_RESOURCE.record
  const localRecordEnable =
    globalConfig?.appConfig?.APP_ROOM_RESOURCE.localRecord

  //本地录制设置内容：打开文件夹让用户选择默认下载路径
  //本地录制设置内容：打开文件夹让用户选择默认下载路径
  function handleDownloadPathChange() {
    window.ipcRenderer?.send(IPCEvent.downloadPath, 'set')
    window.ipcRenderer?.once(IPCEvent.downloadPathReply, (event, arg) => {
      onLocalRecordDefaultPathChange(arg)
    })
  }

  //本地录制设置内容：打开当前下载路径
  function openFile() {
    if (!setting.localRecordDefaultPath) {
      return
    }

    window.ipcRenderer?.send('nemeeting-open-file', {
      isDir: true,
      filePath: setting.localRecordDefaultPath,
    })

    window.ipcRenderer?.removeAllListeners('nemeeting-open-file-reply')
    window.ipcRenderer?.once('nemeeting-open-file-reply', (_, exist) => {
      if (!exist) {
        Toast.info(t('localRecordOpenFileTitle'))
      }
    })
  }

  //将录制下载路径换成sdk的默认下载路径(/Users/xxx/Downloads/)
  function resetDownloadPath() {
    onLocalRecordDefaultPathChange(defaultPath)
  }

  function handleCloudRecordSelectAtLeastOneCloudRecordingMode(key: string) {
    const keys = [
      'cloudRecordSeparateRecordingCurrentSpeaker',
      'cloudRecordSeparateRecordingGalleryView',
      'cloudRecordSeparateRecordingSharedScreen',
      'cloudRecordCurrentSpeakerWithSharedScreen',
      'cloudRecordGalleryViewWithSharedScreen',
      'cloudRecordSeparateAudioFile',
    ].filter((k) => k !== key)

    if (keys.every((k) => !setting[k])) {
      Toast.info(t('cloudRecordSelectAtLeastOneCloudRecordingMode'))
      return true
    }

    return false
  }

  // 录制带有共享屏幕的当前演讲者
  function handleCloudRecordCurrentSpeakerWithSharedScreen(checked: boolean) {
    if (
      !checked &&
      handleCloudRecordSelectAtLeastOneCloudRecordingMode(
        'cloudRecordCurrentSpeakerWithSharedScreen'
      )
    ) {
      return
    }

    onSettingChange({
      ...setting,
      cloudRecordCurrentSpeakerWithSharedScreen: checked,
    })
  }

  // 录制带有共享屏幕的画廊视图
  function handleCloudRecordGalleryViewWithSharedScreenChange(
    checked: boolean
  ) {
    if (
      !checked &&
      handleCloudRecordSelectAtLeastOneCloudRecordingMode(
        'cloudRecordGalleryViewWithSharedScreen'
      )
    ) {
      return
    }

    onSettingChange({
      ...setting,
      cloudRecordGalleryViewWithSharedScreen: checked,
    })
  }

  // 当前演讲者
  function handleCloudRecordSeparateRecordingCurrentSpeakerChange(
    checked: boolean
  ) {
    if (
      !checked &&
      handleCloudRecordSelectAtLeastOneCloudRecordingMode(
        'cloudRecordSeparateRecordingCurrentSpeaker'
      )
    ) {
      return
    }

    onSettingChange({
      ...setting,
      cloudRecordSeparateRecordingCurrentSpeaker: checked,
    })
  }

  // 画廊视图
  function handleCloudRecordSeparateRecordingGalleryViewChange(
    checked: boolean
  ) {
    if (
      !checked &&
      handleCloudRecordSelectAtLeastOneCloudRecordingMode(
        'cloudRecordSeparateRecordingGalleryView'
      )
    ) {
      return
    }

    onSettingChange({
      ...setting,
      cloudRecordSeparateRecordingGalleryView: checked,
    })
  }

  // 共享的屏幕
  function handleCloudRecordSeparateRecordingSharedScreenChange(
    checked: boolean
  ) {
    if (
      !checked &&
      handleCloudRecordSelectAtLeastOneCloudRecordingMode(
        'cloudRecordSeparateRecordingSharedScreen'
      )
    ) {
      return
    }

    onSettingChange({
      ...setting,
      cloudRecordSeparateRecordingSharedScreen: checked,
    })
  }

  function handleCloudRecordThenCurrentSpeakerGalleryViewAndSharedScreenSeparately(
    checked: boolean
  ) {
    if (
      !checked &&
      !setting.cloudRecordCurrentSpeakerWithSharedScreen &&
      !setting.cloudRecordGalleryViewWithSharedScreen &&
      !setting.cloudRecordSeparateAudioFile
    ) {
      Toast.info(t('cloudRecordSelectAtLeastOneCloudRecordingMode'))
      return
    }

    onSettingChange({
      ...setting,
      cloudRecordSeparateRecordingCurrentSpeaker: checked,
      cloudRecordSeparateRecordingGalleryView: checked,
      cloudRecordSeparateRecordingSharedScreen: checked,
    })
  }

  function handleCloudRecordSeparateAudioFileChange(checked: boolean) {
    if (
      !checked &&
      handleCloudRecordSelectAtLeastOneCloudRecordingMode(
        'cloudRecordSeparateAudioFile'
      )
    ) {
      return
    }

    onSettingChange({ ...setting, cloudRecordSeparateAudioFile: checked })
  }

  useEffect(() => {
    if (!defaultPath) {
      const localRecordDefaultPath =
        window.ipcRenderer?.sendSync(IPCEvent.downloadPath, 'get') || ''

      if (!setting.localRecordDefaultPath) {
        onLocalRecordDefaultPathChange(localRecordDefaultPath)
      }

      setDefaultPath(localRecordDefaultPath)
    }

    try {
      window.ipcRenderer
        ?.invoke('check-disk-space', {
          directory: setting.localRecordDefaultPath,
        })
        .then((info) => {
          console.log('剩余空间: ', info)
          setRemainingSpace(info)
        })
    } catch (e) {
      console.warn('剩余空间获取error : ', e)
    }
    // 一定要订阅 setting 变更，否则会导致 localRecordDefaultPath 无法更新
    // 这里先修改否则会死循环
  }, [defaultPath, setting.localRecordDefaultPath])

  // 所有云端录制的配置为 undefined 时，默认录制当前演讲者；老用户升级
  useEffect(() => {
    if (
      setting.cloudRecordCurrentSpeakerWithSharedScreen === undefined &&
      setting.cloudRecordGalleryViewWithSharedScreen === undefined &&
      setting.cloudRecordSeparateRecordingCurrentSpeaker === undefined &&
      setting.cloudRecordSeparateRecordingGalleryView === undefined &&
      setting.cloudRecordSeparateRecordingSharedScreen === undefined &&
      setting.cloudRecordSeparateAudioFile === undefined
    ) {
      onSettingChange({
        ...setting,
        cloudRecordCurrentSpeakerWithSharedScreen: true,
      })
    }
  }, [])

  return (
    <div className="setting-wrap normal-setting w-full h-full record-setting">
      {window.isElectronNative && localRecordEnable ? (
        <div>
          <div
            className="record-setting-item"
            style={{
              marginBottom: 0,
            }}
          >
            <div
              style={{
                fontWeight: 'bold',
                fontSize: 16,
              }}
              className="setting-title"
            >
              {t('localRecord')}
            </div>
          </div>
          <div
            style={{
              fontWeight: 'bold',
            }}
            className="setting-title"
          >
            {t('localRecordPath')}
          </div>
          <div
            className="normal-setting-download"
            style={{
              marginBottom: '10px',
            }}
          >
            <Popover
              trigger="hover"
              content={
                <div style={{ width: 460, wordWrap: 'break-word' }}>
                  {setting.localRecordDefaultPath || defaultPath}
                </div>
              }
            >
              <div
                className="normal-setting-download-path"
                style={{
                  width: 460,
                  display: 'flex',
                  justifyContent: 'space-between',
                  padding: '8px 6px',
                  border: '1px solid #3991fd',
                  fontSize: 16,
                }}
              >
                <div
                  style={{
                    width: 400,
                    overflow: 'hidden',
                    whiteSpace: 'nowrap',
                    textOverflow: 'ellipsis',
                  }}
                >
                  {setting.localRecordDefaultPath || defaultPath}
                </div>
                <div onClick={handleDownloadPathChange}>
                  <span>
                    <svg
                      className="icon iconfont"
                      aria-hidden="true"
                      style={{ color: '#3991fd' }}
                    >
                      <use xlinkHref="#iconbianji"></use>
                    </svg>
                  </span>
                </div>
              </div>
            </Popover>
          </div>
          <div className="setting-title">
            {`${t('remaining')}: ${remainingSpace}`}

            <Button
              type="primary"
              ghost
              style={{ marginLeft: 200, fontSize: 14, height: 25, padding: 4 }}
              onClick={openFile}
            >
              {t('openDir')}
            </Button>
            <Button
              type="primary"
              ghost
              style={{ marginLeft: 5, fontSize: 14, height: 25, padding: 4 }}
              onClick={resetDownloadPath}
            >
              {t('resetDefaultDir')}
            </Button>
          </div>
          {/* <div style={{ display: 'flex'}}>
            <div
              style={{ marginBottom: 20, fontSize: 12}}
            >
              <span className="history-meeting-title">
              {t('localRecordTipFirst')}
              </span>
              <span style={{ color: '#337eff'}} className="history-meeting-title">
                {`${t('localRecordTipSecond')}`}
              </span>
              <span className="history-meeting-title">
                {`${t('localRecordTipThird')}`}
              </span>
            </div>
          </div> */}

          <div className="normal-setting-item">
            <Checkbox
              className="checkbox-space"
              checked={setting.localRecordAudio}
              onChange={(e) => {
                onLocalRecordAudioChange(e.target.checked)
              }}
            >
              {t('localRecordAudio')}
            </Checkbox>
          </div>
          <div className="normal-setting-item">
            <Checkbox
              className="checkbox-space"
              checked={setting.localRecordNickName}
              onChange={(e) => {
                onLocalRecordNickNameChange(e.target.checked)
              }}
            >
              {t('localRecordNickName')}
            </Checkbox>
          </div>
          <div className="normal-setting-item">
            <Checkbox
              checked={setting.localRecordTimestamp}
              onChange={(e) => {
                onLocalRecordTimestampChange(e.target.checked)
              }}
            >
              <span>{t('localRecordTimestamp')}</span>
            </Checkbox>
            <Popover
              trigger={'hover'}
              placement={'top'}
              content={
                <div className="toolbar-tip">
                  {t('localRecordTimestampTip')}
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
              className="checkbox-space"
              checked={setting.localRecordScreenShareAndVideo}
              onChange={(e) => {
                onLocalRecordScreenShareAndVideoChange(e.target.checked)
              }}
            >
              {t('localRecordScreenShareAndVideo')}
            </Checkbox>
          </div>

          {setting.localRecordScreenShareAndVideo ? (
            <div
              className="normal-setting-item"
              style={{
                marginLeft: 20,
              }}
            >
              <Checkbox
                className="checkbox-space"
                checked={setting.localRecordScreenShareSideBySideVideo}
                onChange={(e) => {
                  onLocalRecordScreenShareSideBySideVideoChange(
                    e.target.checked
                  )
                }}
              >
                {t('localRecordScreenShareSideBySideVideo')}
              </Checkbox>
            </div>
          ) : null}
        </div>
      ) : null}

      {cloudRecordEnable ? (
        <>
          <div className="record-setting-item">
            <div
              style={{
                fontWeight: 'bold',
                fontSize: 16,
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
              </div>
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

          <div className="record-setting-item">
            <div
              style={{
                fontWeight: 'bold',
                fontSize: 16,
              }}
              className="setting-title"
            >
              {t('cloudRecordMode')}
              <span className="setting-sub-title">
                {t('cloudRecordModeTip')}
              </span>
            </div>
            <div className="record-setting-content">
              <div className="record-setting-content-item">
                <Checkbox
                  className="checkbox-space"
                  checked={setting.cloudRecordCurrentSpeakerWithSharedScreen}
                  onChange={(e) => {
                    handleCloudRecordCurrentSpeakerWithSharedScreen(
                      e.target.checked
                    )
                  }}
                >
                  {t('cloudRecordTheCurrentSpeakerWithSharedScreen')}
                </Checkbox>
              </div>
              <div className="record-setting-content-item">
                <Checkbox
                  className="checkbox-space"
                  checked={setting.cloudRecordGalleryViewWithSharedScreen}
                  onChange={(e) => {
                    handleCloudRecordGalleryViewWithSharedScreenChange(
                      e.target.checked
                    )
                  }}
                >
                  {t('cloudRecordGalleryViewWithSharedScreen')}
                </Checkbox>
                <Popover
                  trigger={'hover'}
                  placement={'top'}
                  content={
                    <div className="toolbar-tip">
                      {t('cloudRecordGalleryViewWithSharedScreenTip')}
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
              <div className="record-setting-content-item">
                <Checkbox
                  className="checkbox-space"
                  checked={
                    setting.cloudRecordSeparateRecordingCurrentSpeaker ||
                    setting.cloudRecordSeparateRecordingGalleryView ||
                    setting.cloudRecordSeparateRecordingSharedScreen
                  }
                  onChange={(e) => {
                    handleCloudRecordThenCurrentSpeakerGalleryViewAndSharedScreenSeparately(
                      e.target.checked
                    )
                  }}
                >
                  {t(
                    'cloudRecordThenCurrentSpeakerGalleryViewAndSharedScreenSeparately'
                  )}
                </Checkbox>
              </div>
              <div className="record-setting-content-sub-item">
                <Checkbox
                  className="checkbox-space"
                  checked={setting.cloudRecordSeparateRecordingCurrentSpeaker}
                  onChange={(e) => {
                    handleCloudRecordSeparateRecordingCurrentSpeakerChange(
                      e.target.checked
                    )
                  }}
                >
                  {t('cloudRecordSeparateRecordingCurrentSpeaker')}
                </Checkbox>
              </div>
              <div className="record-setting-content-sub-item">
                <Checkbox
                  className="checkbox-space"
                  checked={setting.cloudRecordSeparateRecordingGalleryView}
                  onChange={(e) => {
                    handleCloudRecordSeparateRecordingGalleryViewChange(
                      e.target.checked
                    )
                  }}
                >
                  {t('cloudRecordSeparateRecordingGalleryView')}
                </Checkbox>
              </div>
              <div className="record-setting-content-sub-item">
                <Checkbox
                  className="checkbox-space"
                  checked={setting.cloudRecordSeparateRecordingSharedScreen}
                  onChange={(e) => {
                    handleCloudRecordSeparateRecordingSharedScreenChange(
                      e.target.checked
                    )
                  }}
                >
                  {t('cloudRecordSeparateRecordingSharedScreen')}
                </Checkbox>
              </div>
              <div className="record-setting-content-item">
                <Checkbox
                  className="checkbox-space"
                  checked={setting.cloudRecordSeparateAudioFile}
                  onChange={(e) => {
                    handleCloudRecordSeparateAudioFileChange(e.target.checked)
                  }}
                >
                  {t('cloudRecordSeparateAudioFile')}
                </Checkbox>
              </div>
            </div>
          </div>
        </>
      ) : null}
    </div>
  )
}

export default RecordSetting
