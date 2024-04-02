import CloseCircleFilled from '@ant-design/icons/CloseCircleFilled'
import PlusCircleOutlined from '@ant-design/icons/PlusCircleOutlined'
import { message, Radio, Slider } from 'antd'
import EventEmitter from 'eventemitter3'
import { NEPreviewController } from 'neroom-web-sdk'
import { useEffect, useRef, useState } from 'react'
import { IPCEvent } from '../../../../app/src/types'
import YUVCanvas from '../../../libs/yuv-canvas'
import { EventType, NERoomBeautyEffectType } from '../../../types'
import { getYuvFrame } from '../../../utils/yuvFrame'
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
  mirror,
  virtualBackgroundPath,
  onBeautyLevelChange,
  onVirtualBackgroundChange,
  getVirtualBackground,
  virtualBackgroundList,
  enableVideoMirroring,
  previewController,
  eventEmitter,
  inMeeting,
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

  function handleBeautyLevelChange(beautyLevel: number) {
    //@ts-ignore
    previewController?.setBeautyEffect(
      NERoomBeautyEffectType.kNERoomBeautyWhiten,
      beautyLevel / 10
    )
    //@ts-ignore
    previewController?.setBeautyEffect(
      NERoomBeautyEffectType.kNERoomBeautySmooth,
      (beautyLevel / 10) * 0.8
    )
    //@ts-ignore
    previewController?.setBeautyEffect(
      NERoomBeautyEffectType.kNERoomBeautyFaceRuddy,
      beautyLevel / 10
    )
    //@ts-ignore
    previewController?.setBeautyEffect(
      NERoomBeautyEffectType.kNERoomBeautyFaceSharpen,
      beautyLevel / 10
    )
    //@ts-ignore
    previewController?.setBeautyEffect(
      NERoomBeautyEffectType.kNERoomBeautyThinFace,
      (beautyLevel / 10) * 0.8
    )
  }

  function handleVirtualBackgroundChange(path) {
    onVirtualBackgroundChange(path)
    //@ts-ignore
    // previewController?.enableVirtualBackground(!!path, path)

    window.ipcRenderer?.removeAllListeners(
      EventType.rtcVirtualBackgroundSourceEnabled
    )
    window.ipcRenderer?.once(
      EventType.rtcVirtualBackgroundSourceEnabled,
      (_, value) => {
        const { enabled, reason } = value
        if (enabled) {
          onVirtualBackgroundChange(path)
        } else {
          message.destroy(VIRTUAL_ERROR_TOAST)
          onVirtualBackgroundChange('')
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
    )
  }

  // 根据权限判断是否显示美颜和虚拟背景
  const handleOptionsAvailable = () => {
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
  }

  useEffect(() => {
    if (!previewController) {
      return
    }
    handleOptionsAvailable()
    const targetElement = document.getElementById(`beauty-video-canvas`)
    if (targetElement) {
      const rect = targetElement.getBoundingClientRect()
      // 计算相对于<body>的位置
      const bodyRect = document.body.getBoundingClientRect()
      const relativePosition = {
        x: rect.x - bodyRect.x,
        y: rect.y - bodyRect.y,
        width: targetElement.clientWidth,
        height: targetElement.clientHeight,
      }
      handleBeautyLevelChange(beautyLevel)
      virtualBackgroundPath &&
        handleVirtualBackgroundChange(virtualBackgroundPath)
    }
    if (!inMeeting) {
      //@ts-ignore
      previewController.startBeauty()
      //@ts-ignore
      previewController.enableBeauty(true)
      //@ts-ignore
      previewController.setupLocalVideoCanvas(targetElement)
    }
    // if(window.isWins32) {
    // windows 如果设置页面和会中页面同时打开设备会占用，所以统一到会中渲染进程开启
    window.ipcRenderer?.send(IPCEvent.previewController, {
      method: 'startPreview',
      args: [],
    })
  }, [previewController])

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
        style={{ display: radioValue === 'beauty' ? 'block' : 'none' }}
      >
        {t('beautyEffect')}
        <Slider
          value={beautyLevel}
          min={0}
          max={10}
          step={1}
          onChange={(value) => {
            onBeautyLevelChange(value)
            handleBeautyLevelChange(value)
          }}
        />
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
        {virtualBackgroundList.map((item, index) => (
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
                  window.ipcRenderer?.send('nemeeting-beauty', {
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
            window.ipcRenderer?.send('nemeeting-beauty', {
              event: 'addVirtualBackground',
            })
            window.ipcRenderer?.once(
              'addVirtualBackground-reply',
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
