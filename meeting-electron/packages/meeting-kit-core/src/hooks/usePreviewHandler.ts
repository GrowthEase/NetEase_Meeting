import { useEffect } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import { NERoomBeautyEffectType } from '../types/innerType'
import { EventType } from '../types'
import { getWindow } from '../kit'

export default function usePreviewHandler(): void {
  const { meetingInfo } = useMeetingInfoContext()
  const { neMeeting, globalConfig } = useGlobalContext()

  const isBeautyAvailable = !!globalConfig?.appConfig?.MEETING_BEAUTY?.enable
  const isVirtualBackgroundAvailable = !!globalConfig?.appConfig
    ?.MEETING_VIRTUAL_BACKGROUND?.enable

  useEffect(() => {
    if (!isBeautyAvailable) {
      return
    }

    const previewController = neMeeting?.previewController

    if (!previewController || !meetingInfo.setting?.beautySetting) {
      return
    }

    const beautyLevel = meetingInfo.setting?.beautySetting.beautyLevel

    if (beautyLevel <= 0) {
      previewController.enableBeauty?.(false)
      return
    }

    previewController.startBeauty?.()
    previewController.enableBeauty?.(beautyLevel > 0)
    previewController?.setBeautyEffect?.(
      NERoomBeautyEffectType.kNERoomBeautyWhiten,
      beautyLevel / 10
    )
    previewController?.setBeautyEffect?.(
      NERoomBeautyEffectType.kNERoomBeautySmooth,
      (beautyLevel / 10) * 0.8
    )
    previewController?.setBeautyEffect?.(
      NERoomBeautyEffectType.kNERoomBeautyFaceRuddy,
      beautyLevel / 10
    )
    previewController?.setBeautyEffect?.(
      NERoomBeautyEffectType.kNERoomBeautyFaceSharpen,
      beautyLevel / 10
    )
    previewController?.setBeautyEffect?.(
      NERoomBeautyEffectType.kNERoomBeautyThinFace,
      (beautyLevel / 10) * 0.8
    )
  }, [
    meetingInfo.setting?.beautySetting?.beautyLevel,
    neMeeting?.previewController,
    isBeautyAvailable,
  ])
  useEffect(() => {
    if (!isVirtualBackgroundAvailable) {
      return
    }

    const virtualBackgroundPath =
      meetingInfo.setting?.beautySetting?.virtualBackgroundPath

    const enableVirtualBackgroundForce =
      meetingInfo.setting?.beautySetting?.enableVirtualBackgroundForce ?? false

    const virtualBackgroundType =
      meetingInfo.setting?.beautySetting?.virtualBackgroundType || 2

    const result =
      neMeeting?.previewController?.enableVirtualBackground?.(
        !!virtualBackgroundPath &&
          meetingInfo.setting.beautySetting?.enableVirtualBackground !== false,
        virtualBackgroundPath,
        enableVirtualBackgroundForce,
        virtualBackgroundType
      ) || 0
    const message = {
      event: EventType.rtcVirtualBackgroundSourceEnabled,
      payload: {
        enabled: result === 0,
        reason: result,
      },
    }
    const settingWindow = getWindow('settingWindow')
    settingWindow?.postMessage(message, settingWindow.origin)
  }, [
    meetingInfo.setting?.beautySetting?.virtualBackgroundPath,
    meetingInfo.setting?.beautySetting?.enableVirtualBackground,
    neMeeting?.previewController,
    isVirtualBackgroundAvailable,
  ])
}
