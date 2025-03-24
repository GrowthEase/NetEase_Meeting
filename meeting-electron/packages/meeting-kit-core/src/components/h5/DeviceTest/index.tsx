import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import './index.less'
import { Button, Modal } from 'antd-mobile/es'
import { useTranslation } from 'react-i18next'
import AudioIcon from '../../common/AudioIcon'
import { useGlobalContext } from '../../../store'
import { NEPreviewController } from 'neroom-types'
import { BrowserType, MeetingErrorCode } from '../../../kit'
import {
  isiPhone14,
  getIosVersion,
  getBrowserType,
  getClientType,
} from '../../../utils'

interface DeviceTestProps {
  className?: string
  open?: boolean
  onCancel?: () => void
  onJoin?: () => void
}
interface DeviceTestResultProps {
  deviceInfo: DeviceInfo
  isOK: boolean
  isIphone14AndIOS16?: boolean
}
interface DeviceTestAudioProps {
  previewController?: NEPreviewController
  startRecordDone?: (e?: RTCError) => void
}
interface DeviceTestVideoProps {
  previewController?: NEPreviewController
  startPreviewDone?: (e?: RTCError) => void
}

type RTCError = {
  code: number
  data: {
    code: number
    message: string
    name: string
  }
}
enum DeviceStatus {
  OK,
  // 无权限
  NoPermission,
  // 异常
  Abnormal,
}
interface DeviceInfo {
  video: DeviceStatus
  audio: DeviceStatus
  loudspeaker: DeviceStatus
}
type StepType = 'video' | 'audio' | 'end'

// 设备检测
const DeviceTestResult: React.FC<DeviceTestResultProps> = ({
  deviceInfo,
  isOK,
  isIphone14AndIOS16,
}) => {
  const { t } = useTranslation()

  const deviceStatusMap = useMemo(() => {
    return {
      [DeviceStatus.OK]: t('deviceTestOk'),
      [DeviceStatus.Abnormal]: t('deviceTestAbnormal'),
      [DeviceStatus.NoPermission]: t('deviceTestNoPermission'),
    }
  }, [t])

  const deviceStatusLabel = useCallback(
    (status: DeviceStatus) => {
      const colorMap = {
        [DeviceStatus.OK]: '#26BD71',
        [DeviceStatus.Abnormal]: '#FF7903',
        [DeviceStatus.NoPermission]: '#F24957',
      }

      return (
        <span style={{ color: colorMap[status] }}>
          {deviceStatusMap[status]}
        </span>
      )
    },
    [deviceStatusMap]
  )

  return (
    <div className="nemeeting-device-test-content-end">
      {/* 结果图标 */}
      <div
        className={`nemeeting-device-test-end-icon-wrap ${
          isOK
            ? 'nemeeting-device-test-end-success'
            : 'nemeeting-device-test-end-error'
        }`}
      >
        <div className="nemeeting-device-test-end-icon">
          {isOK ? (
            <svg className="icon-tool icon iconfont" aria-hidden="true">
              <use xlinkHref="#iconchenggong"></use>
            </svg>
          ) : (
            <svg className="icon-tool icon iconfont" aria-hidden="true">
              <use xlinkHref="#iconSubtract"></use>
            </svg>
          )}
        </div>
        <div className="nemeeting-device-test-end-icon-label">
          {t(isOK ? 'deviceTestNormal' : 'deviceTestError')}
        </div>
      </div>
      {/* 测试项目 */}
      <div className="nemeeting-device-test-end-content">
        <div className="nemeeting-device-test-end-content-title">
          <div className="nemeeting-device-test-end-content-title-item">
            {t('deviceTestItem')}
          </div>
          <div className="nemeeting-device-test-end-content-title-item">
            {t('deviceTestResult')}
          </div>
        </div>
        <div className="nemeeting-device-test-end-content-item">
          <div className="nemeeting-device-test-end-content-item-label">
            {t('camera')}
          </div>
          <div className="nemeeting-device-test-end-content-item-label">
            {deviceStatusLabel(deviceInfo.video)}
          </div>
        </div>
        {!isIphone14AndIOS16 && (
          <>
            <div className="nemeeting-device-test-end-content-item">
              <div className="nemeeting-device-test-end-content-item-label">
                {t('microphone')}
              </div>
              <div className="nemeeting-device-test-end-content-item-label">
                {deviceStatusLabel(deviceInfo.audio)}
              </div>
            </div>
            <div className="nemeeting-device-test-end-content-item">
              <div className="nemeeting-device-test-end-content-item-label">
                {t('speaker')}
              </div>
              <div className="nemeeting-device-test-end-content-item-label">
                {deviceStatusLabel(deviceInfo.loudspeaker)}
              </div>
            </div>
          </>
        )}
      </div>
      {!isOK && (
        <div className="nemeeting-device-test-result-tip">
          {t('deviceTestAbnormalTip')}
        </div>
      )}
    </div>
  )
}

const DeviceTestAudio: React.FC<DeviceTestAudioProps> = ({
  previewController,
  startRecordDone,
}) => {
  const { t } = useTranslation()
  const [audioLevel, setAudioLevel] = useState(0)

  useEffect(() => {
    if (previewController) {
      previewController
        .startRecordDeviceTest((code, level) => {
          setAudioLevel(level as number)
        })
        .then(() => {
          startRecordDone?.()
          // 播放本地采集的音量
          // @ts-expect-error 内部声明为暴露
          previewController._rtc.playLocalStream('audio', {
            audio: true,
          })
        })
        .catch((e) => {
          startRecordDone?.(e)
        })

      return () => {
        previewController.stopRecordDeviceTest()
      }
    }
  }, [previewController])

  return (
    <div className="nemeeting-device-test-content-audio">
      <div className="nemeeting-device-test-audio">
        <div className="nemeeting-device-test-audio-icon-wrapper">
          <AudioIcon
            className="nemeeting-device-test-audio-icon"
            dark
            audioLevel={audioLevel}
          />
        </div>
      </div>
      <div className="nemeeting-device-test-tip">
        {t('deviceTestAudioSpeak')}
      </div>
      <div className="nemeeting-device-test-tip">{t('deviceTestAudioTip')}</div>
    </div>
  )
}

const DeviceTestVideo: React.FC<DeviceTestVideoProps> = ({
  previewController,
  startPreviewDone,
}) => {
  const { t } = useTranslation()

  const myCanvasRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (previewController && myCanvasRef.current) {
      previewController
        .startPreview(myCanvasRef.current)
        .then(() => {
          startPreviewDone?.()
        })
        .catch((e) => {
          startPreviewDone?.(e)
        })

      return () => {
        previewController.stopPreview()
      }
    }
  }, [previewController])

  return (
    <div className="nemeeting-device-test-content-video">
      <div className="nemeeting-device-test-video" ref={myCanvasRef}>
        <svg className="icon-no-video icon iconfont" aria-hidden="true">
          <use xlinkHref="#iconkaiqishexiangtou"></use>
        </svg>
      </div>
      <div className="nemeeting-device-test-tip">{t('deviceTestVideoTip')}</div>
    </div>
  )
}

const DeviceTest: React.FC<DeviceTestProps> = ({
  className,
  open,
  onCancel,
  onJoin,
}) => {
  const { t } = useTranslation()
  const { neMeeting } = useGlobalContext()
  const [currentStep, setCurrentStep] = useState<StepType>('video')
  const [deviceInfo, setDeviceInfo] = useState<DeviceInfo>({
    video: DeviceStatus.OK,
    audio: DeviceStatus.OK,
    loudspeaker: DeviceStatus.OK,
  })
  const deviceInfoRef = useRef<DeviceInfo>(deviceInfo)

  deviceInfoRef.current = deviceInfo

  const isOK = useMemo(() => {
    return (
      deviceInfo.audio === DeviceStatus.OK &&
      deviceInfo.video === DeviceStatus.OK &&
      deviceInfo.loudspeaker === DeviceStatus.OK
    )
  }, [deviceInfo])

  const previewController = useMemo(() => {
    return neMeeting?.previewController || undefined
  }, [neMeeting?.previewController])

  const isIOS = useMemo(() => {
    return getClientType() === 'IOS'
  }, [])
  const isIphone14AndIOS16 = useMemo(() => {
    return isIOS && isiPhone14() && getIosVersion()?.split('.')?.[0] == '16'
  }, [isIOS])

  const isWX = useMemo(() => {
    return getBrowserType() === BrowserType.WX
  }, [])

  // 看得到
  function handleCanSee() {
    // iphone14并且是ios16系统不做音频检测，否则新创建的stream会中将无法开启音频
    if (isIphone14AndIOS16) {
      setCurrentStep('end')
    } else {
      setCurrentStep('audio')
    }

    setDeviceInfo({
      ...deviceInfo,
      video: DeviceStatus.OK,
    })
  }

  // 看不到
  function handleCannotSee() {
    // 如果已是没有权限状态则不需要设置为异常
    if (deviceInfo.video === DeviceStatus.OK) {
      setDeviceInfo({
        ...deviceInfo,
        video: DeviceStatus.Abnormal,
      })
    }

    if (isIphone14AndIOS16) {
      setCurrentStep('end')
    } else {
      setCurrentStep('audio')
    }
  }

  // 能够听到
  function handleCanHear() {
    setDeviceInfo({
      ...deviceInfo,
      audio: DeviceStatus.OK,
      loudspeaker: DeviceStatus.OK,
    })
    setCurrentStep('end')
  }

  // 听不到
  function handleCannotHear() {
    setCurrentStep('end')
    const info = { ...deviceInfo }

    info.loudspeaker = DeviceStatus.Abnormal

    console.log('deviceInfo', deviceInfo)
    setDeviceInfo(info)
  }

  function handleJoinRoom() {
    onJoin?.()
  }

  function handleLeaveRoom() {
    if (isWX && !isIOS) {
      //@ts-expect-error 微信环境会有该变量
      WeixinJSBridge?.call('closeWindow')
    }

    onCancel?.()
  }

  const startPreviewDone = useCallback((e?: RTCError) => {
    if (!e) {
      return
    }

    console.log('startPreview', e)
    // 如果开启失败是权限问题则设置权限原因
    if (
      e?.data?.name === 'NotAllowedError' ||
      e.code === MeetingErrorCode.NoPermission
    ) {
      setDeviceInfo({
        ...deviceInfoRef.current,
        video: DeviceStatus.NoPermission,
      })
    } else {
      setDeviceInfo({
        ...deviceInfoRef.current,
        video: DeviceStatus.Abnormal,
      })
    }
  }, [])

  const startRecordDone = useCallback((e?: RTCError) => {
    if (!e) {
      setDeviceInfo({
        ...deviceInfoRef.current,
        audio: DeviceStatus.OK,
      })
      return
    }

    // 如果开启失败是权限问题则设置权限原因
    if (
      e?.data?.name === 'NotAllowedError' ||
      e.code === MeetingErrorCode.NoPermission
    ) {
      setDeviceInfo({
        ...deviceInfoRef.current,
        audio: DeviceStatus.NoPermission,
      })
    } else {
      setDeviceInfo({
        ...deviceInfoRef.current,
        audio: DeviceStatus.Abnormal,
      })
    }
  }, [])

  const VideoStatusIcon = useMemo(() => {
    if (deviceInfo.video === DeviceStatus.OK) {
      return (
        <svg
          className="icon-tool icon iconfont"
          aria-hidden="true"
          style={{ fontSize: '16px' }}
        >
          <use xlinkHref="#iconchenggong"></use>
        </svg>
      )
    } else {
      return (
        <svg
          className="icon-tool icon iconfont"
          aria-hidden="true"
          style={{ fontSize: '16px' }}
        >
          <use xlinkHref="#iconSubtract"></use>
        </svg>
      )
    }
  }, [deviceInfo.video])

  return (
    <Modal
      visible={open}
      destroyOnClose={true}
      content={
        <div className={`nemeeting-device-test ${className || ''}`}>
          <div className="nemeeting-device-test-title">
            {t('deviceTestTitle')}
          </div>
          <div className="nemeeting-device-test-wrapper">
            {/* 设备检测结果页面 */}
            {currentStep === 'end' ? (
              <DeviceTestResult
                isOK={isOK}
                deviceInfo={deviceInfo}
                isIphone14AndIOS16={isIphone14AndIOS16}
              />
            ) : (
              <>
                <div className="nemeeting-device-test-tab">
                  {/* 视频检查图标 */}
                  <div className={`nemeeting-device-test-tab-item`}>
                    <div className="nemeeting-device-test-tab-item-icon-wrap">
                      <div
                        className={`nemeeting-device-test-tab-item-icon ${
                          currentStep === 'video'
                            ? 'nemeeting-device-test-tab-item-active'
                            : ''
                        }`}
                      >
                        {currentStep === 'audio' ? (
                          VideoStatusIcon
                        ) : (
                          <svg
                            className="icon-tool icon iconfont"
                            aria-hidden="true"
                          >
                            <use xlinkHref="#iconguanbishexiangtou-mianxing"></use>
                          </svg>
                        )}
                      </div>
                    </div>

                    <div
                      className={`nemeeting-device-test-tab-item-label ${
                        currentStep === 'video'
                          ? 'nemeeting-device-test-tab-item-label-active'
                          : ''
                      }`}
                    >
                      {t('deviceVideoTest')}
                    </div>
                  </div>

                  {/* 音频检查图标 */}
                  {!isIphone14AndIOS16 && (
                    <>
                      {/* 分割线 */}
                      <div className="nemeeting-device-test-tab-line">
                        <div className="nemeeting-device-test-tab-divider"></div>
                      </div>
                      <div className={`nemeeting-device-test-tab-item`}>
                        <div className="nemeeting-device-test-tab-item-icon-wrap">
                          <div
                            className={`nemeeting-device-test-tab-item-icon ${
                              currentStep === 'audio'
                                ? 'nemeeting-device-test-tab-item-active'
                                : ''
                            }`}
                          >
                            <svg
                              className="icon-tool icon iconfont"
                              aria-hidden="true"
                            >
                              <use xlinkHref="#iconyinliang0hei"></use>
                            </svg>
                          </div>
                        </div>

                        <div
                          className={`nemeeting-device-test-tab-item-label ${
                            currentStep === 'audio'
                              ? 'nemeeting-device-test-tab-item-label-active'
                              : ''
                          }`}
                        >
                          {t('deviceAudioTest')}
                        </div>
                      </div>
                    </>
                  )}
                </div>
                <div className="nemeeting-device-test-content">
                  {/* 视频检测页面 */}
                  {currentStep === 'video' && (
                    <DeviceTestVideo
                      previewController={previewController}
                      startPreviewDone={startPreviewDone}
                    />
                  )}
                  {/* 音频检测页面 */}
                  {currentStep === 'audio' && (
                    <DeviceTestAudio
                      previewController={previewController}
                      startRecordDone={startRecordDone}
                    />
                  )}
                </div>
              </>
            )}
          </div>

          <div className="nemeeting-device-test-footer">
            {currentStep === 'video' && (
              <>
                <Button
                  className="nemeeting-device-test-btn"
                  onClick={handleCannotSee}
                  color="primary"
                  fill="outline"
                >
                  {t('deviceTestCannotSee')}
                </Button>
                <Button
                  onClick={handleCanSee}
                  className="nemeeting-device-test-btn nemeeting-device-test-btn-r"
                  color="primary"
                >
                  {t('deviceTestCanSee')}
                </Button>
              </>
            )}
            {currentStep === 'audio' && (
              <>
                <Button
                  className="nemeeting-device-test-btn"
                  onClick={handleCannotHear}
                  color="primary"
                  fill="outline"
                >
                  {t('deviceTestCannotHear')}
                </Button>
                <Button
                  className="nemeeting-device-test-btn nemeeting-device-test-btn-r"
                  onClick={handleCanHear}
                  color="primary"
                >
                  {t('deviceTestCanHear')}
                </Button>
              </>
            )}
            {currentStep === 'end' &&
              (isOK ? (
                <Button
                  className="nemeeting-device-test-btn"
                  style={{ minWidth: '269px' }}
                  onClick={handleJoinRoom}
                  color="primary"
                >
                  {t('meetingJoin')}
                </Button>
              ) : (
                <>
                  <Button
                    className="nemeeting-device-test-btn"
                    onClick={handleJoinRoom}
                    color="primary"
                    fill="outline"
                  >
                    {t('enterMeetingToast')}
                  </Button>
                  <Button
                    className="nemeeting-device-test-btn nemeeting-device-test-btn-r"
                    onClick={handleLeaveRoom}
                    color="primary"
                  >
                    {isWX && !isIOS ? t('globalClosePage') : t('IkonwIt')}
                  </Button>
                </>
              ))}
          </div>
        </div>
      }
    />
  )
}

export default React.memo(DeviceTest)
