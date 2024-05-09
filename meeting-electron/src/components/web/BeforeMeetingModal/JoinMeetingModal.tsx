import classNames from 'classnames'
import React, { useCallback, useEffect, useRef, useState } from 'react'

import CaretDownOutlined from '@ant-design/icons/CaretDownOutlined'
import CaretUpOutlined from '@ant-design/icons/CaretUpOutlined'
import { Button, Dropdown, Form, Input, MenuProps, ModalProps } from 'antd'
import EventEmitter from 'eventemitter3'
import { NEDeviceBaseInfo, NEPreviewController } from 'neroom-web-sdk'
import { useTranslation } from 'react-i18next'
import YUVCanvas from '../../../libs/yuv-canvas'
import {
  EventType,
  MeetingSetting,
  NERoomBeautyEffectType,
} from '../../../types'
import { getYuvFrame } from '../../../utils/yuvFrame'
import { getDefaultDeviceId, getMeetingDisplayId } from '../../../utils'
import Modal from '../../common/Modal'
import Toast from '../../common/toast'
import { SettingTabType } from '../Setting/Setting'
import './index.less'
import UserAvatar from '../../common/Avatar'

type SummitValue = {
  meetingId: string
  openCamera: boolean
  openMic: boolean
}
type RecentMeetingList = {
  meetingNum: string
  subject: string
}[]

interface WebDevice {
  deviceId: string
  groupId: string
  kind: string
  label: string
}

interface JoinMeetingModalProps extends ModalProps {
  previewController?: NEPreviewController
  meetingNum?: string
  summitLoading?: boolean
  setting?: MeetingSetting | null
  settingOpen?: boolean
  nickname?: string
  avatar?: string
  recentMeetingList?: RecentMeetingList
  onSummit?: (value: SummitValue) => void
  onSettingChange?: (setting: MeetingSetting) => void
  onOpenSetting?: (tab?: SettingTabType) => void
  onClearRecentMeetingList?: () => void
  eventEmitter: EventEmitter
}

const JoinMeetingModal: React.FC<JoinMeetingModalProps> = ({
  previewController: initPreviewController,
  summitLoading,
  setting,
  nickname,
  avatar,
  settingOpen,
  onSummit,
  onSettingChange,
  onOpenSetting,
  onClearRecentMeetingList,
  eventEmitter,
  ...restProps
}) => {
  const { t } = useTranslation()

  const i18n = {
    title: t('meetingJoin'),
    inputPlaceholder: t('meetingIDInputPlaceholder'),
    submitBtn: t('meetingJoin'),
    mic: t('microphone'),
    camera: t('camera'),
    clearAll: t('clearAll'),
    clearAllSuccess: t('clearAllSuccess'),
  }

  const videoPreviewRef = useRef<HTMLDivElement>(null)
  const [cameraId, setCameraId] = useState<string>('')
  const [micId, setMicId] = useState<string>('')
  const [speakerId, setSpeakerId] = useState<string>('')
  const [meetingNum, setMeetingNum] = useState<string>('')
  const [openAudio, setOpenAudio] = useState<boolean>(false)
  const [openVideo, setOpenVideo] = useState<boolean>(false)
  const [openRecentMeetingList, setOpenRecentMeetingList] = useState(false)
  const [recentMeetingList, setRecentMeetingList] = useState<RecentMeetingList>(
    []
  )
  const videoRef = useRef<HTMLVideoElement>(null)
  const [previewController, setPreviewController] = useState<
    NEPreviewController | undefined
  >(initPreviewController)
  const canvasRef = useRef<HTMLCanvasElement>(null)

  const mirror = setting?.videoSetting.enableVideoMirroring || false

  const items: MenuProps['items'] = [
    ...recentMeetingList.map((item) => ({
      key: item.meetingNum,
      label: (
        <div className="recent-meeting-item">
          <div className="recent-meeting-item-title">{item.subject}</div>
          <div>{getMeetingDisplayId(item.meetingNum)}</div>
        </div>
      ),
      onClick: () => {
        setMeetingNum(item.meetingNum)
        setOpenRecentMeetingList(false)
      },
    })),

    {
      key: 'clear',
      label: <div className="recent-meeting-clear">{i18n.clearAll}</div>,
      onClick: () => {
        onClearRecentMeetingList?.()
        setRecentMeetingList([])
        Toast.success(i18n.clearAllSuccess)
      },
    },
  ]

  function onFinish() {
    const data = {
      meetingId: meetingNum.replace(/-/g, '').replace(/\s/g, ''),
      openCamera: openVideo,
      openMic: openAudio,
    }
    onSummit?.(data)
  }

  function onHandleSettingChange({
    openAudio,
    openVideo,
    speakerId,
    micId,
    cameraId,
  }: {
    openAudio: boolean
    openVideo: boolean
    speakerId: string
    micId: string
    cameraId: string
  }) {
    setting &&
      onSettingChange &&
      onSettingChange({
        ...setting,
        normalSetting: {
          ...setting.normalSetting,
          openAudio,
          openVideo,
        },
        audioSetting: {
          ...setting.audioSetting,
          playoutDeviceId: speakerId,
          recordDeviceId: micId,
        },
        videoSetting: {
          ...setting.videoSetting,
          deviceId: cameraId,
        },
      })
  }

  function getDeviceList() {
    if (previewController) {
      //@ts-ignore
      previewController.enumCameraDevices().then(({ data }) => {
        if (data.length > 0) {
          let deviceId = ''
          if (
            data.find(
              (item) => item.deviceId === setting?.videoSetting.deviceId
            )
          ) {
            deviceId = setting?.videoSetting.deviceId || data[0].deviceId
          } else {
            deviceId = data[0].deviceId
          }
          setCameraId(deviceId)
          const device = data.find((item) => item.deviceId === deviceId)
          previewController?.switchDevice({
            type: 'camera',
            deviceId: getDefaultDeviceId(deviceId),
          })
        }
      })
      //@ts-ignore
      previewController.enumRecordDevices().then(({ data }) => {
        if (data.length > 0) {
          let deviceId = ''
          if (
            data.find(
              (item) => item.deviceId === setting?.audioSetting.recordDeviceId
            )
          ) {
            deviceId = setting?.audioSetting.recordDeviceId || data[0].deviceId
          } else {
            deviceId = data[0].deviceId
          }
          setMicId(deviceId)
          const device = data.find((item) => item.deviceId === deviceId)
          previewController?.switchDevice({
            type: 'microphone',
            deviceId: getDefaultDeviceId(deviceId),
          })
        }
      })
      //@ts-ignore
      previewController.enumPlayoutDevices().then(({ data }) => {
        if (data.length > 0) {
          let deviceId = ''
          if (
            data.find(
              (item) => item.deviceId === setting?.audioSetting.playoutDeviceId
            )
          ) {
            deviceId = setting?.audioSetting.playoutDeviceId || data[0].deviceId
          } else {
            deviceId = data[0].deviceId
          }
          setSpeakerId(deviceId)
          const device = data.find((item) => item.deviceId === deviceId)
          previewController?.switchDevice({
            type: 'speaker',
            deviceId: getDefaultDeviceId(deviceId),
          })
        }
      })
    }
  }

  const setBeautyEffect = useCallback(() => {
    const beautySetting = setting?.beautySetting
    if (beautySetting && beautySetting.beautyLevel > 0) {
      const beautyLevel = beautySetting.beautyLevel
      // @ts-ignore
      previewController.startBeauty?.()
      // @ts-ignore
      previewController.enableBeauty?.(true)
      // @ts-ignore
      previewController.setBeautyEffect?.(
        NERoomBeautyEffectType.kNERoomBeautyWhiten,
        beautyLevel / 10
      )
      // @ts-ignore
      previewController.setBeautyEffect?.(
        NERoomBeautyEffectType.kNERoomBeautySmooth,
        (beautyLevel / 10) * 0.8
      )
      // @ts-ignore
      previewController.setBeautyEffect?.(
        NERoomBeautyEffectType.kNERoomBeautyFaceRuddy,
        beautyLevel / 10
      )
      // @ts-ignore
      previewController.setBeautyEffect?.(
        NERoomBeautyEffectType.kNERoomBeautyFaceSharpen,
        beautyLevel / 10
      )
      // @ts-ignore
      previewController.setBeautyEffect?.(
        NERoomBeautyEffectType.kNERoomBeautyThinFace,
        (beautyLevel / 10) * 0.8
      )
    }
    if (beautySetting && beautySetting.virtualBackgroundPath) {
      // @ts-ignore
      previewController.enableVirtualBackground?.(
        true,
        beautySetting.virtualBackgroundPath
      )
    }
  }, [setting?.beautySetting, previewController])

  useEffect(() => {
    if (restProps.open) {
      setPreviewController(initPreviewController)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [restProps.open, initPreviewController, mirror])
  useEffect(() => {
    if (restProps.meetingNum) {
      setMeetingNum(restProps.meetingNum)
    }
  }, [restProps.meetingNum])

  useEffect(() => {
    const result = restProps?.recentMeetingList?.reduce(
      (unique: RecentMeetingList, o) => {
        if (!unique.some((obj) => obj.meetingNum === o.meetingNum)) {
          unique.push(o)
        }
        return unique
      },
      []
    )
    setRecentMeetingList(result || [])
  }, [restProps?.recentMeetingList])

  useEffect(() => {
    if (
      previewController &&
      videoPreviewRef.current &&
      restProps.open &&
      openVideo
    ) {
      if (window.isElectronNative || !settingOpen) {
        previewController.setupLocalVideoCanvas(videoPreviewRef.current)
        const timer = setTimeout(() => {
          videoPreviewRef.current &&
            previewController.startPreview(videoPreviewRef.current)
          setBeautyEffect()
        }, 500)

        return () => {
          clearTimeout(timer)
          previewController.stopPreview()
        }
      }
    }
  }, [
    restProps.open,
    openVideo,
    previewController,
    settingOpen,
    setBeautyEffect,
  ])

  useEffect(() => {
    if (restProps.open) {
      if (setting) {
        setOpenAudio(setting.normalSetting.openAudio)
        setOpenVideo(setting.normalSetting.openVideo)
      }
      getDeviceList()
      navigator.mediaDevices.addEventListener('devicechange', getDeviceList)
      return () => {
        navigator.mediaDevices.removeEventListener(
          'devicechange',
          getDeviceList
        )
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [
    previewController,
    restProps.open,
    setting?.normalSetting.openVideo,
    setting?.normalSetting.openAudio,
  ])

  useEffect(() => {
    if (restProps.open && window.isElectronNative) {
      const canvas = canvasRef.current
      const yuv = YUVCanvas.attach(canvas)
      function handleVideoFrameData(
        uuid,
        bSubVideo,
        data,
        type,
        width,
        height
      ) {
        if (canvas && videoPreviewRef.current) {
          canvas.style.height = `${videoPreviewRef.current.clientHeight}px`
        }
        yuv.drawFrame(getYuvFrame(data, width, height))
      }
      if (window.isElectronNative) {
        eventEmitter.on(EventType.previewVideoFrameData, handleVideoFrameData)
      }
      return () => {
        if (window.isElectronNative) {
          yuv.clear()
          eventEmitter.off(
            EventType.previewVideoFrameData,
            handleVideoFrameData
          )
        }
      }
    }
  }, [restProps.open])

  return (
    <div
      onClick={() => {
        setTimeout(() => {
          setOpenRecentMeetingList(false)
        }, 200)
      }}
    >
      <Modal
        title={i18n.title}
        width={375}
        maskClosable={false}
        centered={window.ipcRenderer ? false : true}
        wrapClassName="user-select-none"
        footer={
          <div className="before-meeting-modal-footer">
            <div
              className="audio-button"
              onClick={() => {
                setOpenAudio(!openAudio)
                onHandleSettingChange({
                  openAudio: !openAudio,
                  openVideo,
                  speakerId,
                  micId,
                  cameraId,
                })
              }}
            >
              <svg
                className={classNames('icon iconfont', {
                  'icon-red': !openAudio,
                })}
                aria-hidden="true"
              >
                <use
                  xlinkHref={`${
                    openAudio ? '#iconyx-tv-voice-onx' : '#iconyx-tv-voice-offx'
                  }`}
                ></use>
              </svg>
              <span className="device-list-title">{i18n.mic}</span>
            </div>
            <div
              className="video-button"
              onClick={() => {
                setOpenVideo(!openVideo)
                onHandleSettingChange({
                  openAudio,
                  openVideo: !openVideo,
                  speakerId,
                  micId,
                  cameraId,
                })
              }}
            >
              <svg
                className={classNames('icon iconfont', {
                  'icon-red': !openVideo,
                })}
                aria-hidden="true"
              >
                <use
                  xlinkHref={`${
                    openVideo ? '#iconyx-tv-video-onx' : '#iconyx-tv-video-offx'
                  }`}
                ></use>
              </svg>
              <span className="device-list-title">{i18n.camera}</span>
            </div>
            <Button
              style={{ marginLeft: 10 }}
              loading={summitLoading}
              className="before-meeting-modal-footer-button"
              disabled={!meetingNum}
              type="primary"
              onClick={() => onFinish()}
            >
              {i18n.submitBtn}
            </Button>
          </div>
        }
        {...restProps}
        afterClose={() => {
          setMeetingNum('')
          restProps.afterClose?.()
        }}
      >
        <div className="before-meeting-modal-content">
          <div
            ref={videoPreviewRef}
            className={`video-preview ${
              setting?.videoSetting.enableVideoMirroring
                ? 'nemeeting-video-mirror'
                : ''
            }`}
          >
            {window.isElectronNative && (
              <canvas
                style={{
                  display: openVideo ? 'block' : 'none',
                }}
                className="nemeeting-video-view-canvas"
                ref={canvasRef}
              />
            )}
            <UserAvatar
              style={{
                display: openVideo ? 'none' : 'block',
              }}
              className="user-avatar"
              nickname={nickname || ''}
              size={48}
              avatar={avatar}
            />
          </div>
        </div>
        <Form
          name="basic"
          autoComplete="off"
          onClick={(e) => {
            e.stopPropagation()
          }}
        >
          <Dropdown
            trigger={[]}
            menu={{ items }}
            placement="bottom"
            autoAdjustOverflow={false}
            open={openRecentMeetingList && recentMeetingList.length > 0}
            onOpenChange={(open) => setOpenRecentMeetingList(open)}
            rootClassName="recent-meeting-dropdown"
            getPopupContainer={(node) => node}
            destroyPopupOnHide
          >
            <Input
              placeholder={i18n.inputPlaceholder}
              value={meetingNum}
              allowClear
              onChange={(e) => {
                if (/^[0-9-]*$/.test(e.target.value)) {
                  setMeetingNum(e.target.value)
                }
              }}
              suffix={
                recentMeetingList.length > 0 ? (
                  openRecentMeetingList ? (
                    <CaretUpOutlined
                      onClick={() => {
                        setTimeout(() => {
                          setOpenRecentMeetingList(false)
                        }, 250)
                      }}
                    />
                  ) : (
                    <CaretDownOutlined
                      onClick={() => {
                        setTimeout(() => {
                          setOpenRecentMeetingList(true)
                        }, 250)
                      }}
                    />
                  )
                ) : null
              }
            />
          </Dropdown>
        </Form>
      </Modal>
    </div>
  )
}
export default JoinMeetingModal
