import classNames from 'classnames'
import React, { useEffect, useMemo, useRef, useState } from 'react'

import { Button, Form, Input, ModalProps, Switch, Tag } from 'antd'
import { NEPreviewController } from 'neroom-web-sdk'
import { MeetingSetting } from '../../../../types'
import { SettingTabType } from '../../Setting/Setting'
import { useTranslation } from 'react-i18next'
import UserAvatar from '../../../common/Avatar'
import { getDefaultDeviceId } from '../../../../utils'
import './index.less'
import { worker } from '../../Meeting/Meeting'
import Toast from '../../../common/toast'

type SummitValue = {
  meetingId: string
  password: string
  openCamera: boolean
  openMic: boolean
}

export interface ImmediateMeetingProps extends ModalProps {
  previewController?: NEPreviewController | null
  meetingNum?: string
  nickname?: string
  shortMeetingNum?: string
  submitLoading?: boolean
  setting?: MeetingSetting | null
  onSummit?: (value: SummitValue) => void
  onSettingChange?: (setting: MeetingSetting) => void
  onOpenSetting?: (tab?: SettingTabType) => void
  avatar?: string
}

const ImmediateMeeting: React.FC<ImmediateMeetingProps> = ({
  previewController: initPreviewController,
  setting,
  meetingNum = '',
  shortMeetingNum = '',
  submitLoading,
  nickname,
  avatar,
  onSummit,
  onSettingChange,
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
    meetingPassword: t('meetingPassword'),
  }

  const [form] = Form.useForm()
  const videoPreviewRef = useRef<HTMLDivElement>(null)
  const [cameraId, setCameraId] = useState<string>('')
  const [openAudio, setOpenAudio] = useState<boolean>(false)
  const [openVideo, setOpenVideo] = useState<boolean>(false)
  const [previewController, setPreviewController] = useState<
    NEPreviewController | undefined | null
  >(initPreviewController)
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const mirror = setting?.videoSetting.enableVideoMirroring || false
  const [password, setPassword] = useState<string>('')
  const [showPassword, setShowPassword] = useState<boolean>(false)
  const [usePersonalMeetingNum, setUsePersonalMeetingNum] =
    useState<boolean>(false)
  const displayId = useMemo(() => {
    if (meetingNum) {
      const id = meetingNum

      return id.slice(0, 3) + '-' + id.slice(3, 6) + '-' + id.slice(6)
    }

    return ''
  }, [meetingNum])

  function passwordValidator(value: string) {
    if (!/^\d{6}$/.test(value)) {
      return Promise.reject(i18n.passwordInputPlaceholder)
    }

    return Promise.resolve()
  }

  function onFinish() {
    if (showPassword) {
      passwordValidator(password)
        .then(() => {
          const data = {
            meetingId: usePersonalMeetingNum ? meetingNum : '',
            password: password || '',
            openCamera: openVideo,
            openMic: openAudio,
          }

          onSummit?.(data)
        })
        .catch((error) => {
          Toast.fail(error)
        })
    } else {
      const data = {
        meetingId: usePersonalMeetingNum ? meetingNum : '',
        password: password || '',
        openCamera: openVideo,
        openMic: openAudio,
      }

      onSummit?.(data)
    }
  }

  function onHandleSettingChange({
    openAudio,
    openVideo,
    cameraId,
  }: {
    openAudio: boolean
    openVideo: boolean
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
        videoSetting: {
          ...setting.videoSetting,
          deviceId: cameraId,
        },
      })
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
      if (window.isElectronNative) {
        previewController.setupLocalVideoCanvas()
        previewController.startPreview()
      } else {
        previewController.startPreview(videoPreviewRef.current)
      }

      return () => {
        previewController.stopPreview()
      }
    }
  }, [restProps.open, openVideo, previewController])

  useEffect(() => {
    function getDeviceList() {
      if (previewController) {
        previewController.enumCameraDevices().then(({ data }) => {
          if (data.length > 0) {
            let deviceId = ''
            const videoDevice = data.find(
              (item) => item.deviceId === setting?.videoSetting.deviceId
            )

            if (videoDevice) {
              deviceId = setting?.videoSetting.deviceId || data[0].deviceId
            } else {
              deviceId = data[0].deviceId
            }

            setCameraId(deviceId)
            previewController?.switchDevice({
              type: 'camera',
              deviceId: getDefaultDeviceId(deviceId),
            })
          }
        })
      }
    }

    if (restProps.open) {
      setOpenAudio(setting?.normalSetting?.openAudio ?? false)
      setOpenVideo(setting?.normalSetting?.openVideo ?? false)

      navigator.mediaDevices.addEventListener('devicechange', getDeviceList)
      return () => {
        navigator.mediaDevices.removeEventListener(
          'devicechange',
          getDeviceList
        )
      }
    }
  }, [
    previewController,
    restProps.open,
    setting?.normalSetting.openVideo,
    setting?.normalSetting.openAudio,
    setting?.videoSetting.deviceId,
  ])

  const onUseMeetingNumChange = (checked: boolean) => {
    setUsePersonalMeetingNum(checked)
  }

  const onEnableMeetingPassword = (checked: boolean) => {
    setShowPassword(checked)
    const randomNum = Math.floor(Math.random() * 900000) + 100000

    setPassword(checked ? randomNum.toString() : '')
  }

  const onMeetingPasswordChange = (value: string) => {
    setPassword(value)
  }

  useEffect(() => {
    const canvas = canvasRef.current
    const view = videoPreviewRef.current
    const uuid = 'mySelf'

    if (canvas && view && openVideo) {
      // @ts-ignore
      const offscreen = canvas.transferControlToOffscreen()

      worker.postMessage(
        {
          canvas: offscreen,
          uuid,
        },
        [offscreen]
      )

      const handleMessage = (e: MessageEvent) => {
        const { event, payload } = e.data

        if (event === 'onVideoFrameData') {
          const { data, width, height } = payload

          const viewWidth = view.clientWidth
          const viewHeight = view.clientHeight

          if (viewWidth / (width / height) > viewHeight) {
            canvas.style.height = `${viewHeight}px`
            canvas.style.width = `${viewHeight * (width / height)}px`
          } else {
            canvas.style.width = `${viewWidth}px`
            canvas.style.height = `${viewWidth / (width / height)}px`
          }

          worker.postMessage(
            {
              frame: {
                width,
                height,
                data,
              },
              uuid,
            },
            [data.bytes.buffer]
          )
        }
      }

      window.addEventListener('message', handleMessage)
      return () => {
        window.removeEventListener('message', handleMessage)
      }
    }
  }, [openVideo])

  return (
    <div>
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
            {window.isElectronNative && openVideo && (
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

          <div className="meeting-num-wrapper">
            <div className="meeting-num-item meeting-num-item-first">
              <div
                className="meeting-num-title"
                style={{
                  fontWeight:
                    window.systemPlatform === 'win32' ? 'bold' : '500',
                }}
              >
                {i18n.usePersonalMeetingID}
              </div>
              <div className="meeting-num-switch">
                <Switch onChange={onUseMeetingNumChange}></Switch>
              </div>
            </div>
            {shortMeetingNum && (
              <div className="meeting-num-item meeting-num">
                <div className="label meeting-num-label">
                  {i18n.personalShortMeetingID}
                  &nbsp;
                  <Tag className="internal-use" color="blue">
                    {i18n.internalUse}
                  </Tag>
                </div>
                <div className="num">{shortMeetingNum}</div>
              </div>
            )}
            <div className="meeting-num-item meeting-num">
              <div className="label">{i18n.personalMeetingID}</div>
              <div className="num">{displayId}</div>
            </div>
          </div>
          <div className="meeting-password-wrapper">
            <div className="meeting-password-item-first">
              <div
                className="meeting-password-title"
                style={{
                  fontWeight:
                    window.systemPlatform === 'win32' ? 'bold' : '500',
                }}
              >
                {i18n.meetingPassword}
              </div>
              <div>
                <Switch onChange={onEnableMeetingPassword}></Switch>
              </div>
            </div>
            {showPassword && (
              <div className="meeting-password-input">
                <Input
                  className="immediate-meeting-password-input"
                  placeholder={t('livePasswordTip')}
                  value={password}
                  maxLength={6}
                  allowClear
                  onKeyPress={(event) => {
                    if (!/^\d+$/.test(event.key)) {
                      event.preventDefault()
                    }
                  }}
                  onChange={(event) => {
                    const password = event.target.value.replace(/[^0-9]/g, '')

                    onMeetingPasswordChange?.(password)
                  }}
                />
              </div>
            )}
          </div>
        </div>
      </div>
      <div className="before-meeting-modal-footer">
        <div
          className={classNames('audio-button audio-button-close', {
            'audio-button-open': openAudio,
          })}
          onClick={() => {
            setOpenAudio(!openAudio)
            onHandleSettingChange({
              openAudio: !openAudio,
              openVideo,
              cameraId,
            })
          }}
        >
          <div>
            <svg
              className={classNames('icon iconfont icon-audio', {
                'icon-open': openAudio,
              })}
              aria-hidden="true"
            >
              <use
                xlinkHref={`${
                  openAudio ? '#iconyx-tv-voice-onx' : '#iconyx-tv-voice-offx'
                }`}
              ></use>
            </svg>
          </div>
          <div className="device-list-title">{i18n.mic}</div>
        </div>
        <div
          className={classNames('video-button video-button-close', {
            'video-button-open': openVideo,
          })}
          onClick={() => {
            setOpenVideo(!openVideo)
            onHandleSettingChange({
              openAudio,
              openVideo: !openVideo,
              cameraId,
            })
          }}
        >
          <div>
            <svg
              className={classNames(
                'icon iconfont iconyx-tv-video icon-video',
                {
                  'icon-red': !openVideo,
                }
              )}
              aria-hidden="true"
            >
              <use
                xlinkHref={`${
                  openVideo ? '#iconyx-tv-video-onx' : '#iconyx-tv-video-offx'
                }`}
              ></use>
            </svg>
          </div>
          <div className="device-list-title">{i18n.camera}</div>
        </div>
        <Button
          style={{ marginLeft: 10 }}
          loading={submitLoading}
          className="before-meeting-modal-footer-button"
          disabled={!meetingNum}
          type="primary"
          onClick={() => onFinish()}
        >
          <span className="submit-text">{i18n.submitBtn}</span>
        </Button>
      </div>
    </div>
  )
}

export default ImmediateMeeting
