import { useEffect } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import { NERoomBeautyEffectType } from '../types/innerType'

export default function usePreviewHandler() {
  const { meetingInfo } = useMeetingInfoContext()
  const { neMeeting } = useGlobalContext()
  useEffect(() => {
    const previewController = neMeeting?.previewController
    if (!previewController || !meetingInfo.setting?.beautySetting) {
      return
    }
    const beautyLevel = meetingInfo.setting?.beautySetting.beautyLevel
    if (beautyLevel <= 0) {
      // @ts-ignore
      previewController.enableBeauty?.(false)
      return
    }
    // @ts-ignore
    previewController.startBeauty?.()
    // @ts-ignore
    previewController.enableBeauty?.(beautyLevel > 0)

    console.log('beautyLevel', beautyLevel)
    //@ts-ignore
    previewController?.setBeautyEffect?.(
      NERoomBeautyEffectType.kNERoomBeautyWhiten,
      beautyLevel / 10
    )
    //@ts-ignore
    previewController?.setBeautyEffect?.(
      NERoomBeautyEffectType.kNERoomBeautySmooth,
      (beautyLevel / 10) * 0.8
    )
    //@ts-ignore
    previewController?.setBeautyEffect?.(
      NERoomBeautyEffectType.kNERoomBeautyFaceRuddy,
      beautyLevel / 10
    )
    //@ts-ignore
    previewController?.setBeautyEffect?.(
      NERoomBeautyEffectType.kNERoomBeautyFaceSharpen,
      beautyLevel / 10
    )
    //@ts-ignore
    previewController?.setBeautyEffect?.(
      NERoomBeautyEffectType.kNERoomBeautyThinFace,
      (beautyLevel / 10) * 0.8
    )
  }, [meetingInfo.setting?.beautySetting?.beautyLevel])
  useEffect(() => {
    const virtualBackgroundPath =
      meetingInfo.setting?.beautySetting?.virtualBackgroundPath
    //@ts-ignore
    neMeeting?.previewController?.enableVirtualBackground?.(
      !!virtualBackgroundPath,
      virtualBackgroundPath
    )
  }, [meetingInfo.setting?.beautySetting?.virtualBackgroundPath])
}
