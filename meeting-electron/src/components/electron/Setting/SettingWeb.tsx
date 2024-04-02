import React, { useEffect, useMemo, useRef, useState } from 'react'
import Setting, { SettingTabType } from '../../web/Setting/Setting'
import { MeetingSetting } from '../../../types'
import NERoom, {
  NEPreviewController,
  NEPreviewRoomContext,
} from 'neroom-web-sdk'
import eleIpc from '../../../services/electron'
import { IPCEvent } from '../../../../app/src/types'
import { LOCALSTORAGE_MEETING_SETTING } from '../../../../app/src/config'

const isElectron = !!window.ipcRenderer
// 设置页面用于Electron独立页面
const SeetingWeb: React.FC = () => {
  const [settingModalTab, setSettingModalTab] =
    useState<SettingTabType>('normal')
  const [setting, setSetting] = useState<MeetingSetting | null>(null)
  const [inMeeting, setInMeeting] = useState(false)
  const [showSetting, setShowSetting] = useState(false)
  const settingRef = useRef<MeetingSetting | null>()
  const [previewController, setPreviewController] = useState<
    NEPreviewController | any
  >()
  const [previewContext, setPreviewContext] = useState<
    NEPreviewRoomContext | any
  >()
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
    }
    let roomkit
    if (window.ipcRenderer) {
      roomkit = new window.NERoom()
    } else {
      roomkit = NERoom.getInstance()
      setPreviewContext(roomkit.roomService.getPreviewRoomContext())
    }
    roomkit
      .initialize({
        appKey: 'test',
      })
      .then(() => {
        setPreviewContext(roomkit.roomService.getPreviewRoomContext())
        setPreviewController(
          roomkit.roomService.getPreviewRoomContext()?.previewController
        )
      })

    window.ipcRenderer?.on(
      IPCEvent.showSettingWindow,
      (event, { isShow, type, inMeeting }) => {
        console.log('showSettingWindow', { isShow, type })
        const settingStr = localStorage.getItem(LOCALSTORAGE_MEETING_SETTING)
        console.log('settingStr', settingStr)
        if (settingStr) {
          try {
            settingRef.current = JSON.parse(settingStr) as MeetingSetting
            console.log('settingStrRef', settingRef.current)
            setSetting(settingRef.current)
          } catch (error) {}
        }
        setShowSetting(isShow)
        setInMeeting(inMeeting)
        if (isShow) {
          setSettingModalTab(type)
        } else {
          setSettingModalTab('normal')
        }
      }
    )

    window.ipcRenderer?.on(IPCEvent.meetingStatus, (event, value) => {
      console.log('meetingStatus', value)
      const { inMeeting } = value
      setInMeeting(inMeeting)
    })

    window.ipcRenderer?.on(
      IPCEvent.changeSettingDeviceFromControlBar,
      (event, { type, deviceId }) => {
        // 'video' | 'speaker' | 'microphone'
        console.log('changeSettingDeviceFromControlBar11111111', {
          type,
          deviceId,
        })
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
    )
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
      {previewController && showSetting && (
        <Setting
          defaultTab={settingModalTab}
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

export default SeetingWeb
