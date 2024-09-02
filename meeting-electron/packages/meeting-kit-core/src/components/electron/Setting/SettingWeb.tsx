import React, { useEffect, useRef, useState } from 'react'
import Setting, { SettingTabType } from '../../web/Setting/Setting'
import { MeetingSetting } from '../../../types'
import { NEPreviewController, NEPreviewRoomContext } from 'neroom-types'
import { IPCEvent } from '../../../app/src/types'

import { getLocalStorageSetting, setLocalStorageSetting } from '../../../utils'

interface SettingWebProps {
  previewContext: NEPreviewRoomContext
  previewController: NEPreviewController
  inMeeting: boolean
  defaultTab?: SettingTabType
}
// 设置页面用于Electron独立页面
const SettingWeb: React.FC<SettingWebProps> = ({
  previewContext,
  previewController,
  inMeeting,
  defaultTab = 'normal',
}) => {
  const [setting, setSetting] = useState<MeetingSetting | null>(null)
  const settingRef = useRef<MeetingSetting | null>()

  useEffect(() => {
    settingRef.current = getLocalStorageSetting()
    setSetting(settingRef.current)

    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data

      if (event === IPCEvent.changeSettingDeviceFromControlBar) {
        const { type, deviceId } = payload

        if (!settingRef.current) {
          return
        }

        switch (type) {
          case 'video':
            settingRef.current.videoSetting.deviceId = deviceId
            break
          case 'playout':
            settingRef.current.audioSetting.playoutDeviceId = deviceId
            break
          case 'record':
            settingRef.current.audioSetting.recordDeviceId = deviceId
            break
        }

        setSetting({ ...settingRef.current })
      }
    }

    window.addEventListener('message', handleMessage)

    return () => {
      window.removeEventListener('message', handleMessage)
    }
  }, [])

  function onSettingChange(setting: MeetingSetting) {
    setSetting(setting)
    settingRef.current = setting
    setLocalStorageSetting(JSON.stringify(setting))
    window.ipcRenderer?.send(IPCEvent.changeSetting, setting)
  }

  function onDeviceChange(
    type: 'video' | 'speaker' | 'microphone',
    deviceId: string,
    deviceName?: string
  ) {
    window.ipcRenderer?.send(IPCEvent.changeSettingDevice, {
      type,
      deviceId,
      deviceName,
    })
  }

  return (
    <div className="nemeeting-setting">
      {previewController && setting && (
        <Setting
          defaultTab={defaultTab}
          onSettingChange={onSettingChange}
          onDeviceChange={onDeviceChange}
          previewController={previewController}
          previewContext={previewContext}
          inMeeting={inMeeting}
          open
        />
      )}
    </div>
  )
}

export default SettingWeb
