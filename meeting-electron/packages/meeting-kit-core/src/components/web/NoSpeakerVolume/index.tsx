import React, { useEffect, useMemo, useRef } from 'react'
import classNames from 'classnames'
import './index.less'
import { useTranslation } from 'react-i18next'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import { Button } from 'antd'
import { IPCEvent } from '../../../app/src/types'
import { MeetingSetting } from '../../../types'

interface NoSpeakerVolumeProps {
  className?: string
  onSettingChange: (setting: MeetingSetting) => void
}
// 无扬声器提示
const NoSpeakerVolume: React.FC<NoSpeakerVolumeProps> = React.memo(
  ({ className, onSettingChange }: NoSpeakerVolumeProps) => {
    const { neMeeting } = useGlobalContext()
    const { meetingInfo } = useMeetingInfoContext()
    const { t } = useTranslation()

    const meetingInfoRef = useRef(meetingInfo)
    const openTimer = React.useRef<NodeJS.Timeout>()
    const [open, setOpen] = React.useState(false)

    meetingInfoRef.current = meetingInfo
    const previewController = neMeeting?.previewController
    const { localMember } = meetingInfo

    const isElectronSharingScreen = useMemo(() => {
      return window.isElectronNative && localMember.isSharingScreen
    }, [localMember.isSharingScreen])

    function onAdjustSpeakerVolume() {
      // 设置扬声器音量
      const setting = meetingInfoRef.current.setting

      setting.audioSetting.playouOutputtVolume = 50
      onSettingChange(setting)

      previewController?.setPlayoutDeviceMute?.(false)
      previewController?.setPlayoutDeviceVolume?.(50)

      setOpen(false)
    }

    useEffect(() => {
      if (!localMember.isAudioConnected) {
        openTimer.current && clearTimeout(openTimer.current)
        setOpen(false)
        return
      }

      openTimer.current = setTimeout(() => {
        const mute = neMeeting?.rtcController?.getPlayoutDeviceMute?.()
        const volume = neMeeting?.rtcController?.getPlayoutDeviceVolume?.()
        const settingVolume =
          meetingInfo.setting.audioSetting.playouOutputtVolume

        if (mute || volume === 0 || settingVolume === 0) {
          setOpen(true)
        }
      }, 1000)
    }, [
      localMember.isAudioConnected,
      meetingInfo.setting.audioSetting.playoutDeviceId,
    ])

    useEffect(() => {
      if (open && isElectronSharingScreen) {
        window.ipcRenderer?.send(IPCEvent.sharingScreen, {
          method: 'openToast',
        })

        return () => {
          window.ipcRenderer?.send(IPCEvent.sharingScreen, {
            method: 'closeToast',
          })
        }
      }
    }, [open, isElectronSharingScreen])

    return window.isElectronNative && open ? (
      <div className={classNames('nemeeting-no-speaker-volume', className)}>
        {t('noSpeakerVolume')}
        <Button onClick={() => onAdjustSpeakerVolume()} type="primary">
          {t('adjustSpeakerVolume')}
        </Button>
        <svg
          className="icon nemeeting-close-icon"
          aria-hidden="true"
          onClick={() => {
            setOpen(false)
          }}
        >
          <use xlinkHref="#iconyx-pc-closex"></use>
        </svg>
      </div>
    ) : null
  }
)

NoSpeakerVolume.displayName = 'NoSpeakerVolume'

export default NoSpeakerVolume
