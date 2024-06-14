import CloseCircleFilled from '@ant-design/icons/CloseCircleFilled'
import PlusCircleOutlined from '@ant-design/icons/PlusCircleOutlined'
import { message, Radio, Slider } from 'antd'
import EventEmitter from 'eventemitter3'
import { NEPreviewController } from 'neroom-web-sdk'
import React, { useEffect, useRef, useState } from 'react'
import { IPCEvent } from '../../../../app/src/types'
import { EventType } from '../../../types'
import { useTranslation } from 'react-i18next'
import { useCanvasSetting } from './useSetting'

interface virtualBackground {
  src: string
  path: string
  isDefault: boolean
}
interface BeautySettingProps {
  beautyLevel: number
  mirror: boolean
  virtualBackgroundPath: string
  onBeautyLevelChange: (level: number) => void
  onVirtualBackgroundChange: (path: string) => void
  startPreview: (canvas: HTMLElement) => void
  stopPreview: () => Promise<void>
  virtualBackgroundList: virtualBackground[]
  getVirtualBackground: () => void
  enableVideoMirroring: boolean
  eventEmitter: EventEmitter
  previewController: NEPreviewController
  inMeeting?: boolean
}
enum tagNERoomVirtualBackgroundSourceStateReason {
  kNERoomVirtualBackgroundSourceStateReasonSuccess = 0 /**< 虚拟背景开启成功 */,
  kNERoomVirtualBackgroundSourceStateReasonImageNotExist = 1 /**< 自定义背景图片不存在 */,
  kNERoomVirtualBackgroundSourceStateReasonImageFormatNotSupported = 2 /**< 自定义背景图片的图片格式无效 */,
  kNERoomVirtualBackgroundSourceStateReasonColorFormatNotSupported = 3 /**< 自定义背景图片的颜色格式无效 */,
  kNERoomVirtualBackgroundSourceStateReasonDeviceNotSupported = 4 /**< 该设备不支持使用虚拟背景 */,
}

const VIRTUAL_ERROR_TOAST = 'virtualErrorToast'

const BeautySetting: React.FC<BeautySettingProps> = ({
  beautyLevel,
  virtualBackgroundPath,
  onBeautyLevelChange,
  onVirtualBackgroundChange,
  getVirtualBackground,
  virtualBackgroundList,
  enableVideoMirroring,
  startPreview,
  stopPreview,
}) => {
  const { t } = useTranslation()
  const i18n = {
    imgNotExit: t('virtualBackgroundError1'),
    imgInvalid: t('virtualBackgroundError2'),
    imgColorInvalid: t('virtualBackgroundError3'),
    deviceNotSupport: t('virtualBackgroundError4'),
    virtualEnableFailed: t('virtualBackgroundError5'),
  }
  const { videoCanvas, canvasRef } = useCanvasSetting()
  const [options, setOptions] = useState([
    { label: t('meetingBeauty'), value: 'beauty', disabled: false },
    { label: t('virtualBackground'), value: 'virtual', disabled: false },
  ])

  const isOpeningFileWindowRef = useRef<boolean>(false) // 防止重复打开文件选择窗口

  const [radioValue, setRadioValue] = useState('')

  function handleVirtualBackgroundChange(path) {
    onVirtualBackgroundChange(path)
  }

  useEffect(() => {
    const globalConfig = JSON.parse(
      localStorage.getItem('nemeeting-global-config') || '{}'
    )
    const isBeautyAvailable = !!globalConfig?.appConfig?.MEETING_BEAUTY?.enable
    const isVirtualBackgroundAvailable =
      !!globalConfig?.appConfig?.MEETING_VIRTUAL_BACKGROUND?.enable

    if (isBeautyAvailable && isVirtualBackgroundAvailable) {
      setRadioValue('beauty')
    } else if (isBeautyAvailable) {
      setRadioValue('virtual')
      const _item = options.find((item) => item.value === 'beauty')

      _item && (_item.disabled = true)
      setOptions([...options])
    } else if (isVirtualBackgroundAvailable) {
      setRadioValue('beauty')
      const _item = options.find((item) => item.value === 'virtual')

      _item && (_item.disabled = true)
      setOptions([...options])
    }
  }, [])

  useEffect(() => {
    if (radioValue === 'virtual' && virtualBackgroundList.length === 0) {
      getVirtualBackground()
    }
  }, [radioValue, virtualBackgroundList])

  useEffect(() => {
    if (radioValue !== 'virtual') {
      return
    }

    const imgList = document.querySelectorAll('.nemeeting-virtual-bg')

    if (!imgList) {
      return
    }

    // 动态加载每一个图片
    imgList.forEach(async (item, index) => {
      //@ts-ignore
      if (imgList[index].src) return
      setTimeout(() => {
        imgList[index].setAttribute('src', virtualBackgroundList[index].src)
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
          default:
            message.error({
              content: i18n.virtualEnableFailed,
              key: VIRTUAL_ERROR_TOAST,
            })
            break
        }
      }
    }

    window.addEventListener('message', handleVirtualBackgroundChange)
    return () => {
      window.removeEventListener('message', handleVirtualBackgroundChange)
    }
  }, [i18n])

  return (
    <div className="setting-wrap beauty-setting w-full ">
      <div
        ref={videoCanvas}
        id="beauty-video-canvas"
        className={`beauty-video-canvas ${
          enableVideoMirroring ? 'video-mirror' : ''
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
          onClick={() => handleVirtualBackgroundChange('')}
        >
          {t('emptyVirtualBackground')}
        </div>
        {virtualBackgroundList.map((item) => (
          <div
            className={`beauty-setting-background-item ${
              item.path === virtualBackgroundPath ? 'virtual-selected-item' : ''
            }`}
            key={item.path}
            onClick={() => handleVirtualBackgroundChange(item.path)}
          >
            {/* @ts-ignore */}
            <img data-src={item.src} alt="" className="nemeeting-virtual-bg" />
            {item.isDefault ? null : (
              <CloseCircleFilled
                onClick={(event) => {
                  if (virtualBackgroundPath === item.path) {
                    handleVirtualBackgroundChange('')
                  }

                  event.stopPropagation()
                  window.ipcRenderer?.send(IPCEvent.beauty, {
                    event: 'removeVirtualBackground',
                    value: {
                      path: item.path,
                    },
                  })
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
              (_, value) => {
                isOpeningFileWindowRef.current = false
                if (value) {
                  handleVirtualBackgroundChange(value)
                }
              }
            )
          }}
        >
          <PlusCircleOutlined />
          {t('addLocalImage')}
        </div>
      </div>
    </div>
  )
}

export default BeautySetting
