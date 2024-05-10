import React, { useEffect, useMemo, useRef, useState } from 'react'
import Setting, { SettingTabType } from '../../web/Setting/Setting'
import { MeetingSetting } from '../../../types'
import { NEPreviewController, NEPreviewRoomContext } from 'neroom-web-sdk'
import eleIpc from '../../../services/electron'
import { IPCEvent } from '../../../../app/src/types'
import { LOCALSTORAGE_MEETING_SETTING } from '../../../../app/src/config'
import { createDefaultSetting } from '../../../services'

const isElectron = !!window.ipcRenderer

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
  const [settingModalTab, setSettingModalTab] =
    useState<SettingTabType>('normal')
  const [setting, setSetting] = useState<MeetingSetting | null>(null)
  const [showSetting, setShowSetting] = useState(true)
  const settingRef = useRef<MeetingSetting | null>()

  const eleIpcIns = useMemo(
    () => (isElectron ? eleIpc.getInstance() : null),
    []
  )

  useEffect(() => {
    const settingStr = localStorage.getItem(LOCALSTORAGE_MEETING_SETTING)
    console.log('settingStr', settingStr)
    if (settingStr) {
      try {
        settingRef.current = JSON.parse(settingStr) as MeetingSetting
        console.log('settingStrRef', settingRef.current)
        setSetting(settingRef.current)
      } catch (error) {}
    } else {
      setSetting(createDefaultSetting())
    }

    // window.ipcRenderer?.on(
    //   IPCEvent.showSettingWindow,
    //   (event, { isShow, type, inMeeting }) => {
    //     console.log('showSettingWindow', { isShow, type })
    //     const settingStr = localStorage.getItem(LOCALSTORAGE_MEETING_SETTING)
    //     console.log('settingStr', settingStr)
    //     if (settingStr) {
    //       try {
    //         settingRef.current = JSON.parse(settingStr) as MeetingSetting
    //         console.log('settingStrRef', settingRef.current)
    //         setSetting(settingRef.current)
    //       } catch (error) {}
    //     }
    //     setShowSetting(isShow)
    //     if (isShow) {
    //       setSettingModalTab(type)
    //     } else {
    //       setSettingModalTab('normal')
    //     }
    //   }
    // )

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
    localStorage.setItem('ne-meeting-setting', JSON.stringify(setting))
    // electron 环境
    if (eleIpcIns) {
      eleIpcIns.sendMessage(IPCEvent.changeSetting, setting)
    }
  }
  function onDeviceChange(
    type: 'video' | 'speaker' | 'microphone',
    deviceId: string,
    deviceName?: string
  ) {
    // electron 环境
    if (eleIpcIns) {
      eleIpcIns.sendMessage(IPCEvent.changeSettingDevice, {
        type,
        deviceId,
        deviceName,
      })
    }
  }
  return (
    <div className="nemeeting-setting">
      {previewController && setting && (
        <Setting
          defaultTab={defaultTab}
          setting={setting}
          onSettingChange={onSettingChange}
          onDeviceChange={onDeviceChange}
          previewController={previewController}
          previewContext={previewContext}
          inMeeting={inMeeting}
        />
      )}
    </div>
  )
}

export default SettingWeb
