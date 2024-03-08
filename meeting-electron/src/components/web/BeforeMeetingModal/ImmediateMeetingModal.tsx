import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import classNames from 'classnames'

import './index.less'
import Modal from '../../common/Modal'
import {
  Button,
  Input,
  Form,
  Checkbox,
  ModalProps,
  Popover,
  Divider,
  Tag,
} from 'antd'
import {
  EventType,
  MeetingSetting,
  NERoomBeautyEffectType,
} from '../../../types'
import { NEPreviewController } from 'neroom-web-sdk'
import { SettingTabType } from '../Setting/Setting'
import YUVCanvas from '../../../libs/yuv-canvas'
import EventEmitter from 'eventemitter3'
import { useTranslation } from 'react-i18next'
import UserAvatar from '../../common/Avatar'
import { getDefaultDeviceId } from '../../../utils'

type PasswordValue = {
  enable: boolean
  password: string
}

type PasswordFormItemProps = {
  value?: PasswordValue
  onChange?: (value: PasswordValue) => void
}

const PasswordFormItem: React.FC<PasswordFormItemProps> = ({
  value,
  onChange,
}) => {
  const { t } = useTranslation()
  return (
    <div className="password-form-item">
      <Checkbox
        checked={value?.enable}
        onChange={(e) => {
          if (e.target.checked) {
            const randomNum = Math.floor(Math.random() * 900000) + 100000
            onChange?.({
              enable: e.target.checked,
              password: `${randomNum}` || '',
            })
          } else {
            onChange?.({
              enable: e.target.checked,
              password: '',
            })
          }
        }}
      >
        {t('openMeetingPassword')}
      </Checkbox>
      <Input
        className="immediate-meeting-password-input"
        placeholder={value?.enable ? t('livePasswordTip') : ``}
        disabled={!value?.enable}
        value={value?.password}
        maxLength={6}
        allowClear
        onKeyPress={(event) => {
          if (!/^\d+$/.test(event.key)) {
            event.preventDefault()
          }
        }}
        onChange={(event) => {
          const password = event.target.value.replace(/[^0-9]/g, '')
          onChange?.({
            enable: true,
            password: password,
          })
        }}
      />
    </div>
  )
}

type SummitValue = {
  meetingId: string
  password: string
  openCamera: boolean
  openMic: boolean
}

interface WebDevice {
  deviceId: string
  groupId: string
  kind: string
  label: string
}

interface ImmediateMeetingModalProps extends ModalProps {
  previewController?: NEPreviewController
  meetingNum?: string
  nickname?: string
  shortMeetingNum?: string
  summitLoading?: boolean
  setting?: MeetingSetting | null
  settingOpen?: boolean
  onSummit?: (value: SummitValue) => void
  onSettingChange?: (setting: MeetingSetting) => void
  onOpenSetting?: (tab?: SettingTabType) => void
  eventEmitter: EventEmitter
  avatar?: string
}

const ImmediateMeetingModal: React.FC<ImmediateMeetingModalProps> = ({
  previewController: initPreviewController,
  setting,
  meetingNum = '',
  shortMeetingNum = '',
  summitLoading,
  settingOpen,
  nickname,
  avatar,
  onSummit,
  onSettingChange,
  onOpenSetting,
  eventEmitter,
  ...restProps
}) => {
  const { t } = useTranslation()

  const i18n = {
    title: t('immediateMeeting'),
    usePersonalMeetingID: t('usePersonalMeetingID'),
    passwordInputPlaceholder: t('livePasswordTip'),
    personalMeetingID: t('personalMeetingNum'),
    personalShortMeetingID: t('personalShortMeetingNum'),
    submitBtn: t('immediateMeeting'),
    mic: t('microphone'),
    camera: t('camera'),
    internalUse: t('internalOnly'),
  }

  const [form] = Form.useForm()
  const videoPreviewRef = useRef<HTMLDivElement>(null)
  const [cameraId, setCameraId] = useState<string>('')
  const [micId, setMicId] = useState<string>('')
  const [speakerId, setSpeakerId] = useState<string>('')
  const [openAudio, setOpenAudio] = useState<boolean>(false)
  const [openVideo, setOpenVideo] = useState<boolean>(false)
  const videoRef = useRef<HTMLVideoElement>(null)
  const [previewController, setPreviewController] = useState<
    NEPreviewController | undefined
  >(initPreviewController)
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const mirror = setting?.videoSetting.enableVideoMirroring || false

  const displayId = useMemo(() => {
    if (meetingNum) {
      const id = meetingNum
      return id.slice(0, 3) + '-' + id.slice(3, 6) + '-' + id.slice(6)
    }
    return ''
  }, [meetingNum])

  function passwordValidator(rule, value: PasswordValue) {
    if (value?.enable && !/^\d{6}$/.test(value?.password)) {
      return Promise.reject(i18n.passwordInputPlaceholder)
    }
    return Promise.resolve()
  }
  function onFinish() {
    form.validateFields().then((value) => {
      const data = {
        meetingId: value.useMeetingId ? meetingNum : '',
        password: value.meetingPassword?.password || '',
        openCamera: openVideo,
        openMic: openAudio,
      }
      onSummit?.(data)
    })
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
          // setVideoDeviceList([device])
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
          previewController?.switchDevice({
            type: 'speaker',
            deviceId: getDefaultDeviceId(deviceId),
          })
        }
      })
    }
  }

  useEffect(() => {
    restProps.open && form.resetFields()
  }, [restProps.open, form])

  useEffect(() => {
    if (restProps.open) {
      setPreviewController(initPreviewController)
    }
  }, [restProps.open, initPreviewController, mirror])

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
        const buffer = {
          format: {
            width,
            height,
            chromaWidth: width / 2,
            chromaHeight: height / 2,
            cropLeft: 0, // default
            cropTop: 0, // default
            cropHeight: height,
            cropWidth: width,
            displayWidth: width, // derived from width via cropWidth
            displayHeight: height, // derived from cropHeight
          },
          ...data,
        }
        yuv.drawFrame(buffer)
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
    >
      <div className="before-meeting-modal-content">
        <div className="immediate-meeting-container">
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
          <Form name="basic" autoComplete="off" layout="vertical" form={form}>
            <Form.Item
              name="useMeetingId"
              valuePropName="checked"
              extra={
                shortMeetingNum ? (
                  <div className="use-meeting-id-extra-wrap">
                    <div className="use-meeting-id-extra-item">
                      <span>
                        {i18n.personalShortMeetingID}
                        &nbsp;
                        <Tag color="blue">{i18n.internalUse}</Tag>
                      </span>
                      <span>{shortMeetingNum}</span>
                    </div>
                    <div className="use-meeting-id-extra-item">
                      <span>{i18n.personalMeetingID}</span>
                      <span>{displayId}</span>
                    </div>
                  </div>
                ) : null
              }
            >
              {shortMeetingNum ? (
                <Checkbox>{i18n.usePersonalMeetingID}</Checkbox>
              ) : (
                <Checkbox>
                  {i18n.usePersonalMeetingID + ' ' + displayId}
                </Checkbox>
              )}
            </Form.Item>

            <Form.Item
              name="meetingPassword"
              rules={[{ validator: passwordValidator }]}
            >
              <PasswordFormItem />
            </Form.Item>
          </Form>
        </div>
      </div>
    </Modal>
  )
}
export default ImmediateMeetingModal
