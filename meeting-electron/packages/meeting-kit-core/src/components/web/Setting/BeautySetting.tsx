import CloseCircleFilled from '@ant-design/icons/CloseCircleFilled'
import PlusCircleOutlined from '@ant-design/icons/PlusCircleOutlined'
import { message, Radio, Slider, Checkbox } from 'antd'
import EventEmitter from 'eventemitter3'
import { NEPreviewController } from 'neroom-types'
import React, { useEffect, useMemo, useRef, useState } from 'react'
import { IPCEvent } from '../../../app/src/types'
import { EventType } from '../../../types'
import { useTranslation } from 'react-i18next'
import { useCanvasSetting } from './useSetting'
import { useMount, useUpdateEffect } from 'ahooks'
import CommonModal from '../../common/CommonModal'
import Toast from '../../common/toast'
import { CheckboxChangeEvent } from 'antd/es/checkbox'

interface virtualBackground {
  src: string
  path: string
  isDefault: boolean
  type: 'image' | 'video'
}
interface BeautySettingProps {
  beautyLevel: number
  mirror: boolean
  virtualBackgroundPath: string
  enableVirtualBackgroundForce?: boolean
  onBeautyLevelChange: (level: number) => void
  onVirtualBackgroundChange: (
    path: string,
    force: boolean,
    type: number
  ) => void
  startPreview: (canvas: HTMLElement) => void
  stopPreview: () => Promise<void>
  virtualBackgroundList: virtualBackground[]
  getVirtualBackground: () => void
  enableVideoMirroring: boolean
  eventEmitter: EventEmitter
  previewController: NEPreviewController
  inMeeting?: boolean
  onEnableVideoMirroringChange: (e: CheckboxChangeEvent) => void
  defaultTab?: 'beauty' | 'virtual'
}
enum tagNERoomVirtualBackgroundSourceStateReason {
  kNERoomVirtualBackgroundSourceStateReasonSuccess = 0 /**< 虚拟背景开启成功 */,
  kNERoomVirtualBackgroundSourceStateReasonImageNotExist = 1 /**< 自定义背景图片不存在 */,
  kNERoomVirtualBackgroundSourceStateReasonImageFormatNotSupported = 2 /**< 自定义背景图片的图片格式无效 */,
  kNERoomVirtualBackgroundSourceStateReasonColorFormatNotSupported = 3 /**< 自定义背景图片的颜色格式无效 */,
  kNERoomVirtualBackgroundSourceStateReasonDeviceNotSupported = 4 /**< 该设备不支持使用虚拟背景 */,
  kNERoomVirtualBackgroundSourceStateReasonVideoDecodeFail = 5 /**< 不支持的视频格式 */,
  kNERtcErrVirtualBackgroundNoSuchFile = 30032 /**< 虚拟背景文件不存在 */,
  kNERtcErrVirtualBackgroundExceedFileLimit = 30033 /**< 虚拟背景文件超过大小限制 */,
  kNERtcErrVirtualBackgroundFormatNotSupported = 30034 /**< type 为图片传入非 jpg 或 png 文件 */,
  kNERtcErrVirtualBackgroundSourceTypeNotSupported = 30035 /**< type不是 BACKGROUND_COLOR、BACKGROUND_IMG、BACKGROUND_VIDEO */,
}

enum tagNEBackgroundSourceType {
  kNEBackgroundColor = 1 /**< 背景图像为纯色（默认） */,
  kNEBackgroundImage = 2 /**< 背景图像只支持 PNG 或 JPG 格式的文件 */,
  kNEBackgroundVideo = 4 /**< 背景图像只支持 mov 或  mp4 格式的文件 */,
}

const VIRTUAL_ERROR_TOAST = 'virtualErrorToast'

const BeautySetting: React.FC<BeautySettingProps> = ({
  previewController,
  beautyLevel,
  virtualBackgroundPath,
  enableVirtualBackgroundForce = false,
  onBeautyLevelChange,
  onVirtualBackgroundChange,
  getVirtualBackground,
  virtualBackgroundList,
  enableVideoMirroring,
  startPreview,
  stopPreview,
  onEnableVideoMirroringChange,
  defaultTab,
}) => {
  const { t } = useTranslation()

  const i18n = useMemo(() => {
    return {
      imgNotExit: t('virtualBackgroundError1'),
      imgInvalid: t('virtualBackgroundError2'),
      imgColorInvalid: t('virtualBackgroundError3'),
      deviceNotSupport: t('virtualBackgroundError4'),
      virtualEnableFailed: t('virtualBackgroundError5'),
      VideoDecodeFail: t('virtualBackgroundError6'),
      NoSuchFile: t('virtualBackgroundError7'),
      ExceedFileLimit: t('virtualBackgroundError8'),
      FormatNotSupported: t('virtualBackgroundError9'),
      SourceTypeNotSupported: t('virtualBackgroundError10'),
    }
  }, [t])

  const { videoCanvas, canvasRef } = useCanvasSetting()
  const [options, setOptions] = useState([
    { label: t('meetingBeauty'), value: 'beauty', disabled: false },
    { label: t('virtualBackground'), value: 'virtual', disabled: false },
  ])
  const [previewMirror, setPreviewMirror] = useState(false)

  const isOpeningFileWindowRef = useRef<boolean>(false) // 防止重复打开文件选择窗口
  // 虚拟背景硬件支持 0： 支持，1：由于设备硬件或系统原因，当前设备不支持该功能 2：可以强制开启
  const virtualBackgroundSupportedTypeRef = useRef<number>(0)
  // const notRemindMeAgainRef = useRef<boolean>(false) // 是否不再提示

  const [radioValue, setRadioValue] = useState(defaultTab || '')

  const [cancelPath, setCancelPath] = useState('')
  const cancelPathRef = useRef('')

  function handleVirtualBackgroundChange(path, type) {
    if (virtualBackgroundSupportedTypeRef.current === 1) {
      Toast.fail(t('virtualBackgroundNotSupported'))
      return
    }
    if (
      path !== '' &&
      virtualBackgroundSupportedTypeRef.current === 2 &&
      !virtualBackgroundPath
    ) {
      CommonModal.confirm({
        title: t('virtualBackgroundSupportedTitle'),
        content: (
          <div>
            <div>{t('virtualBackgroundSupportedDesc')}</div>
          </div>
        ),
        okText: t('virtualBackgroundSupportedDescBtn'),
        okType: 'danger',
        onOk: () => {
          onVirtualBackgroundChange(path, true, type)
        },
      })
      return
    }

    onVirtualBackgroundChange(path, enableVirtualBackgroundForce, type)
  }

  useMount(() => {
    const globalConfig = JSON.parse(
      localStorage.getItem('nemeeting-global-config') || '{}'
    )
    const isBeautyAvailable = !!globalConfig?.appConfig?.MEETING_BEAUTY?.enable
    const isVirtualBackgroundAvailable = !!globalConfig?.appConfig
      ?.MEETING_VIRTUAL_BACKGROUND?.enable

    if (isBeautyAvailable && isVirtualBackgroundAvailable) {
      if (!radioValue) {
        setRadioValue('beauty')
      }
    } else if (isVirtualBackgroundAvailable) {
      setRadioValue('virtual')
      const _item = options.find((item) => item.value === 'beauty')

      _item && (_item.disabled = true)
      setOptions([...options])
    } else if (isBeautyAvailable) {
      setRadioValue('beauty')
      const _item = options.find((item) => item.value === 'virtual')

      _item && (_item.disabled = true)
      setOptions([...options])
    }
  })

  useUpdateEffect(() => {
    setRadioValue(defaultTab || 'beauty')
  }, [defaultTab])

  useUpdateEffect(() => {
    if (radioValue === 'virtual' && virtualBackgroundList.length === 0) {
      getVirtualBackground()
    }
  }, [radioValue, virtualBackgroundList.length])

  useEffect(() => {
    if (radioValue !== 'virtual') {
      return
    }

    const mediaList = document.querySelectorAll(
      '.nemeeting-virtual-bg'
    ) as NodeListOf<HTMLImageElement>

    if (!mediaList) {
      return
    }

    // 动态加载每一个图片
    mediaList.forEach(async (item, index) => {
      if (mediaList[index].src) return
      setTimeout(() => {
        if (virtualBackgroundList[index].type === 'video') {
          mediaList[index].setAttribute(
            'src',
            'media://' + virtualBackgroundList[index].path
          )
        } else {
          mediaList[index].setAttribute('src', virtualBackgroundList[index].src)
        }
      }, 300 + index * 50)
    })
  }, [virtualBackgroundList, radioValue])

  useEffect(() => {
    return () => {
      message.destroy(VIRTUAL_ERROR_TOAST)
    }
  }, [])

  useEffect(() => {
    if (window.isElectronNative) {
      videoCanvas.current && startPreview(videoCanvas.current)
      return () => {
        stopPreview()
      }
    } else {
      stopPreview().finally(() => {
        videoCanvas.current && startPreview(videoCanvas.current)
      })
    }
  }, [])

  useEffect(() => {
    function handleVirtualBackgroundChange(
      e: MessageEvent<{
        event: string
        payload: {
          enabled: boolean
          reason: number
        }
      }>
    ) {
      const { payload, event } = e.data
      if (event !== EventType.rtcVirtualBackgroundSourceEnabled) return

      const { enabled, reason } = payload

      if (!enabled) {
        message.destroy(VIRTUAL_ERROR_TOAST)
        switch (reason) {
          case tagNERoomVirtualBackgroundSourceStateReason.kNERoomVirtualBackgroundSourceStateReasonImageNotExist:
            message.error({
              content: i18n.imgNotExit,
              key: VIRTUAL_ERROR_TOAST,
            })
            break
          case tagNERoomVirtualBackgroundSourceStateReason.kNERoomVirtualBackgroundSourceStateReasonImageFormatNotSupported:
            message.error({
              content: i18n.imgInvalid,
              key: VIRTUAL_ERROR_TOAST,
            })
            break
          case tagNERoomVirtualBackgroundSourceStateReason.kNERoomVirtualBackgroundSourceStateReasonColorFormatNotSupported:
            message.error({
              content: i18n.imgColorInvalid,
              key: VIRTUAL_ERROR_TOAST,
            })
            break
          case tagNERoomVirtualBackgroundSourceStateReason.kNERoomVirtualBackgroundSourceStateReasonDeviceNotSupported:
            message.error({
              content: i18n.deviceNotSupport,
              key: VIRTUAL_ERROR_TOAST,
            })
            break
          case tagNERoomVirtualBackgroundSourceStateReason.kNERtcErrVirtualBackgroundNoSuchFile:
            message.error({
              content: i18n.NoSuchFile,
              key: VIRTUAL_ERROR_TOAST,
            })
            break
          case tagNERoomVirtualBackgroundSourceStateReason.kNERtcErrVirtualBackgroundExceedFileLimit:
            message.error({
              content: i18n.ExceedFileLimit,
              key: VIRTUAL_ERROR_TOAST,
            })
            break
          case tagNERoomVirtualBackgroundSourceStateReason.kNERtcErrVirtualBackgroundFormatNotSupported:
            message.error({
              content: i18n.FormatNotSupported,
              key: VIRTUAL_ERROR_TOAST,
            })
            break
          case tagNERoomVirtualBackgroundSourceStateReason.kNERtcErrVirtualBackgroundSourceTypeNotSupported:
            message.error({
              content: i18n.SourceTypeNotSupported,
              key: VIRTUAL_ERROR_TOAST,
            })
            break
          default:
            message.error({
              content: i18n.virtualEnableFailed,
              key: VIRTUAL_ERROR_TOAST,
            })
            break
        }
      } else {
        if (
          reason ==
          tagNERoomVirtualBackgroundSourceStateReason.kNERoomVirtualBackgroundSourceStateReasonVideoDecodeFail
        ) {
          message.error({
            content: i18n.VideoDecodeFail,
            key: VIRTUAL_ERROR_TOAST,
          })
        } else if (
          reason ===
          tagNERoomVirtualBackgroundSourceStateReason.kNERoomVirtualBackgroundSourceStateReasonSuccess
        ) {
          if (!!cancelPathRef.current) {
            //SDK不能马上释放资源，延迟remove
            setTimeout(() => {
              window.ipcRenderer?.send(IPCEvent.beauty, {
                event: 'removeVirtualBackground',
                value: {
                  path: cancelPathRef.current,
                },
              })
              setCancelPath('')
            }, 500)
          }
        }
      }
    }

    // 获取是否支持虚拟背景
    previewController
      .getVirtualBackgroundSupportedType?.()
      // @ts-expect-error 多窗口，同步转异步
      .then((value) => {
        virtualBackgroundSupportedTypeRef.current = value
      })

    window.addEventListener('message', handleVirtualBackgroundChange)

    return () => {
      window.removeEventListener('message', handleVirtualBackgroundChange)
    }
  }, [i18n])

  useEffect(() => {
    if (!enableVideoMirroring) {
      setPreviewMirror(false)
    } else {
      setPreviewMirror(true)
    }
  }, [enableVideoMirroring])

  useEffect(() => {
    cancelPathRef.current = cancelPath
  }, [cancelPath])

  return (
    <>
      <div className="setting-wrap beauty-setting w-full ">
        <div
          ref={videoCanvas}
          id="beauty-video-canvas"
          className={`beauty-video-canvas ${
            previewMirror ? 'video-mirror' : ''
          }`}
        >
          <canvas className="nemeeting-video-view-canvas" ref={canvasRef} />
        </div>
        <Radio.Group
          className="beauty-video-radio-group"
          options={options}
          value={radioValue}
          onChange={(e) => setRadioValue(e.target.value)}
          optionType="button"
          buttonStyle="solid"
        />
        <div
          className="beauty-setting-slider"
          style={{ display: radioValue === 'beauty' ? 'flex' : 'none' }}
        >
          <div className="beauty-effect-title">{t('beautyEffect')}</div>
          <div className="beauty-setting-slider-line-wrapper">
            <div
              className="beauty-setting-none iconjinzhi"
              onClick={() => {
                onBeautyLevelChange(0)
              }}
            >
              <svg className={'icon iconfont'} aria-hidden="true">
                <use xlinkHref="#iconjinzhi"></use>
              </svg>
            </div>
            <div className="beauty-setting-slider-line">
              <Slider
                value={beautyLevel}
                min={0}
                max={10}
                step={1}
                onChange={(value) => {
                  onBeautyLevelChange(value)
                }}
              />
            </div>
            <div
              onClick={() => {
                onBeautyLevelChange(10)
              }}
              className="beauty-setting-full iconmeiyanxiaoguo"
            >
              <svg className={'icon iconfont'} aria-hidden="true">
                <use xlinkHref="#iconmeiyanxiaoguo"></use>
              </svg>
            </div>
          </div>
        </div>
        <div
          className="beauty-setting-background-list"
          style={{ display: radioValue === 'virtual' ? 'block' : 'none' }}
        >
          <div
            className={`beauty-setting-background-item empty-background ${
              virtualBackgroundPath ? '' : 'virtual-selected-item'
            }`}
            onClick={() =>
              handleVirtualBackgroundChange(
                '',
                tagNEBackgroundSourceType.kNEBackgroundImage
              )
            }
          >
            {t('emptyVirtualBackground')}
          </div>
          {virtualBackgroundList.map((item) => (
            <div
              className={`beauty-setting-background-item ${
                item.path === virtualBackgroundPath
                  ? 'virtual-selected-item'
                  : ''
              }`}
              key={item.path}
              onClick={() =>
                handleVirtualBackgroundChange(
                  item.path,
                  item.type === 'image'
                    ? tagNEBackgroundSourceType.kNEBackgroundImage
                    : tagNEBackgroundSourceType.kNEBackgroundVideo
                )
              }
            >
              {item.type === 'image' ? (
                <img
                  data-src={item.src}
                  alt=""
                  className="nemeeting-virtual-bg"
                />
              ) : (
                <React.Fragment>
                  <video
                    style={{ width: '100%', height: '100%' }}
                    data-src={item.src}
                    className="nemeeting-virtual-bg"
                  ></video>
                  <svg className="icon iconfont">
                    <use xlinkHref="#iconshipinxunibeijing"></use>
                  </svg>
                </React.Fragment>
              )}

              {item.isDefault ? null : (
                <CloseCircleFilled
                  onClick={async (event) => {
                    event.stopPropagation()
                    if (item.type === 'video') {
                      if (virtualBackgroundPath === item.path) {
                        setCancelPath(item.path)
                        handleVirtualBackgroundChange(
                          '',
                          tagNEBackgroundSourceType.kNEBackgroundImage
                        )
                      } else {
                        window.ipcRenderer?.send(IPCEvent.beauty, {
                          event: 'removeVirtualBackground',
                          value: {
                            path: item.path,
                          },
                        })
                      }
                    } else {
                      if (virtualBackgroundPath === item.path) {
                        handleVirtualBackgroundChange(
                          '',
                          tagNEBackgroundSourceType.kNEBackgroundImage
                        )
                      }
                      window.ipcRenderer?.send(IPCEvent.beauty, {
                        event: 'removeVirtualBackground',
                        value: {
                          path: item.path,
                        },
                      })
                    }
                  }}
                />
              )}
            </div>
          ))}
          <div
            className="beauty-setting-background-item add-background"
            onClick={() => {
              if (isOpeningFileWindowRef.current) return
              isOpeningFileWindowRef.current = true
              window.ipcRenderer?.send(IPCEvent.beauty, {
                event: 'addVirtualBackground',
              })
              window.ipcRenderer?.once(
                IPCEvent.addVirtualBackgroundReply,
                (_, value, type, error) => {
                  isOpeningFileWindowRef.current = false
                  if (error) {
                    message.error(t('fileSizeLimit500MB'))
                    return
                  }
                  if (value) {
                    handleVirtualBackgroundChange(value, type)
                  }
                }
              )
            }}
          >
            <PlusCircleOutlined />
            {t('addLocalImage')}
          </div>
        </div>
        {enableVideoMirroring && (
          <Radio.Group
            defaultValue={true}
            value={previewMirror}
            onChange={(e) => {
              setPreviewMirror(e.target.value)
            }}
            buttonStyle="solid"
            className="video-mirror-radio"
          >
            <Radio.Button value={true}>{t('lootAtMyself')}</Radio.Button>
            <Radio.Button value={false}>{t('lookAtMe')}</Radio.Button>
          </Radio.Group>
        )}
      </div>
      <div className="video-mirror-check">
        <Checkbox
          checked={enableVideoMirroring}
          onChange={onEnableVideoMirroringChange}
        >
          {t('mirrorVideo')}
        </Checkbox>
      </div>
    </>
  )
}

export default BeautySetting
