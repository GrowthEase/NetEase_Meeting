import { MeetingDeviceInfo } from '../../../types'
import { CheckboxChangeEvent } from 'antd/es/checkbox'
import { NEDeviceBaseInfo } from 'neroom-types'
import { useTranslation } from 'react-i18next'
import { useCanvasSetting } from './useSetting'
import React, { useEffect, useMemo } from 'react'
import CaretDownOutlined from '@ant-design/icons/CaretDownOutlined'

import { Checkbox, Popover, Radio, Select } from 'antd'

interface VideoSettingProps {
  onDeviceChange: (value: string, deviceInfo: MeetingDeviceInfo) => void
  onResolutionChange: (value: number) => void
  onEnableVideoMirroringChange: (e: CheckboxChangeEvent) => void
  onGalleryModeMaxCountChange: (value: number) => void
  videoDeviceList: (NEDeviceBaseInfo & { default?: boolean })[]
  startPreview: (canvas: HTMLElement) => void
  stopPreview: () => Promise<void>
  enableTransparentWhiteboard: boolean
  openVideo: boolean
  onOpenVideoChange: (e: CheckboxChangeEvent) => void
  onShowMemberNameChange: (e: CheckboxChangeEvent) => void
  onEnableHideMyVideo: (e: CheckboxChangeEvent) => void
  onEnableHideVideoOffAttendees: (e: CheckboxChangeEvent) => void
  setting: {
    deviceId: string
    isDefaultDevice?: boolean
    resolution: number
    enableVideoMirroring: boolean
    galleryModeMaxCount: number
    showMemberName: boolean
    enableHideVideoOffAttendees?: boolean
    enableHideMyVideo?: boolean
  }
}

const VideoSetting: React.FC<VideoSettingProps> = ({
  onDeviceChange,
  onResolutionChange,
  videoDeviceList,
  startPreview,
  onEnableVideoMirroringChange,
  onGalleryModeMaxCountChange,
  stopPreview,
  setting,
  openVideo,
  onOpenVideoChange,
  onShowMemberNameChange,
  onEnableHideMyVideo,
  onEnableHideVideoOffAttendees,
}) => {
  const { t } = useTranslation()
  const { videoCanvas, canvasRef } = useCanvasSetting()

  function handleChange(
    deviceId: string,
    deviceInfo: MeetingDeviceInfo | MeetingDeviceInfo[]
  ) {
    onDeviceChange(deviceId, deviceInfo as MeetingDeviceInfo)
  }

  function handleResolutionChange() {
    onResolutionChange(Number(setting.resolution) === 720 ? 1080 : 720)
  }

  const videDeviceName = useMemo(() => {
    if (setting.isDefaultDevice) {
      return videoDeviceList.find((item) => item.default)?.deviceName
    } else {
      return videoDeviceList.find(
        (item) => item.deviceId === setting.deviceId && !item.default
      )?.deviceName
    }
  }, [setting.deviceId, setting.isDefaultDevice, videoDeviceList])

  useEffect(() => {
    if (window.isElectronNative) {
      videoCanvas.current && startPreview(videoCanvas.current)
    } else {
      stopPreview().finally(() => {
        videoCanvas.current && startPreview(videoCanvas.current)
      })
    }

    return () => {
      stopPreview()
    }
  }, [])
  return (
    <div className="setting-wrap w-full h-full video-setting">
      <div
        ref={videoCanvas}
        id="nemeeting-preview-video-dom"
        className={`video-canvas ${
          setting.enableVideoMirroring ? 'video-mirror' : ''
        }`}
      >
        <canvas className="nemeeting-video-view-canvas" ref={canvasRef} />
      </div>
      <div className="video-setting-item">
        <div
          style={{
            fontWeight: 'bold',
          }}
          className="video-setting-title setting-title camera-label"
        >
          {t('camera')}
        </div>
        <div className="video-setting-content">
          <Select
            value={videDeviceName}
            className="video-device-select"
            fieldNames={{
              label: 'deviceName',
              value: 'deviceName',
            }}
            suffixIcon={<CaretDownOutlined style={{ pointerEvents: 'none' }} />}
            onChange={handleChange}
            options={videoDeviceList}
          />
          <div className="video-mirror-check">
            <Checkbox
              checked={setting.enableVideoMirroring}
              onChange={onEnableVideoMirroringChange}
            >
              {t('mirrorVideo')}
            </Checkbox>
          </div>
          <div className="video-resolution-check">
            <Checkbox
              // disabled={enableTransparentWhiteboard}
              checked={Number(setting.resolution) === 1080}
              onChange={handleResolutionChange}
            >
              {t('HDMode')}{' '}
              <Popover content={t('HDModeTip')}>
                <svg className="icon iconfont icona-45" aria-hidden="true">
                  <use xlinkHref="#icona-45"></use>
                </svg>
              </Popover>
            </Checkbox>
          </div>
          <div className="video-open">
            <Checkbox checked={openVideo} onChange={onOpenVideoChange}>
              {t('openCameraInMeeting')}
            </Checkbox>
          </div>
          <div className="video-open">
            <Checkbox
              checked={setting.showMemberName ?? true}
              onChange={onShowMemberNameChange}
            >
              {t('settingShowName')}
            </Checkbox>
          </div>
          <div className="video-open">
            <Checkbox
              checked={setting.enableHideVideoOffAttendees}
              onChange={onEnableHideVideoOffAttendees}
            >
              <span>{t('settingHideVideoOffAttendees')}</span>
            </Checkbox>
          </div>
          <div className="video-open">
            <Checkbox
              checked={setting.enableHideMyVideo}
              onChange={onEnableHideMyVideo}
            >
              <span>{t('settingHideMyVideo')}</span>
            </Checkbox>
          </div>
        </div>
      </div>
      <div className="video-setting-item">
        <div
          style={{
            fontWeight: 'bold',
          }}
          className="video-setting-title setting-title camera-label"
        >
          {t('layoutSettings')}
        </div>
        <div className="video-setting-content">
          <div className="radio-title">{t('galleryModeMaxCount')}</div>
          <Radio.Group
            value={setting.galleryModeMaxCount}
            defaultValue={16}
            onChange={(e) => onGalleryModeMaxCountChange(e.target.value)}
          >
            <Radio value={9} className="radio-item">
              {t('galleryModeScreens', { count: 9 })}
            </Radio>
            <Radio value={16}>{t('galleryModeScreens', { count: 16 })}</Radio>
          </Radio.Group>
        </div>
      </div>
      {/* <div className="video-setting-item">
          <div className="video-setting-title setting-title">本端分辨率</div>
          <div className="video-setting-content">
            <Radio.Group
              onChange={handleResolutionChange}
              value={Number(setting.resolution)}
            >
              <Space>
                {videoProfiles.map((item) => (
                  <Radio key={item.value} value={item.value}>
                    {item.label}
                  </Radio>
                ))}
              </Space>
            </Radio.Group>
          </div>
        </div> */}
    </div>
  )
}

export default VideoSetting
