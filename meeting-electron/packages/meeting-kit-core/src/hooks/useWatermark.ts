import { useEffect } from 'react'
import { useMeetingInfoContext } from '../store'
import { WATERMARK_STRATEGY } from '../types'
import {
  drawWatermark,
  stopDrawWatermark,
  WatermarkParams,
} from '../utils/watermark'

function useWatermark(params?: WatermarkParams & { disabled?: boolean }): void {
  const { meetingInfo } = useMeetingInfoContext()

  useEffect(() => {
    function replaceFormat(format: string, info: Record<string, string>) {
      const regex = /{([^}]+)}/g
      const result = format?.replace(regex, (_, key) => {
        const value = info[key]

        return value ? value : '' // 如果值存在，则返回对应的值，否则返回原字符串
      })

      return result
    }

    if (meetingInfo && !params?.disabled) {
      const localMember = meetingInfo?.localMember
      const needDrawWatermark =
        meetingInfo.meetingNum &&
        meetingInfo.watermark &&
        (meetingInfo.watermark.videoStrategy === WATERMARK_STRATEGY.OPEN ||
          meetingInfo.watermark.videoStrategy === WATERMARK_STRATEGY.FORCE_OPEN)

      if (needDrawWatermark && meetingInfo.watermark) {
        const { videoStyle, videoFormat } = meetingInfo.watermark
        const supportInfo = {
          name: meetingInfo.watermarkConfig?.name || localMember.name,
          phone: meetingInfo.watermarkConfig?.phone || '',
          email: meetingInfo.watermarkConfig?.email || '',
          jobNumber: meetingInfo.watermarkConfig?.jobNumber || '',
        }

        const draw = () => {
          stopDrawWatermark(params?.container)
          drawWatermark({
            content: replaceFormat(videoFormat, supportInfo),
            type: videoStyle,
            ...params,
          })
        }

        draw()
        window.addEventListener('resize', draw)
        return () => {
          window.removeEventListener('resize', draw)
          stopDrawWatermark(params?.container)
        }
      } else {
        stopDrawWatermark(params?.container)
      }
    }
  }, [
    meetingInfo.meetingNum,
    meetingInfo.watermark?.videoFormat,
    meetingInfo.watermark?.videoStrategy,
    meetingInfo.watermark?.videoStyle,
    meetingInfo.localMember?.name,
    meetingInfo.watermarkConfig?.name,
    meetingInfo.watermarkConfig?.phone,
    meetingInfo.watermarkConfig?.email,
    meetingInfo.watermarkConfig?.jobNumber,
    params,
  ])
}

export default useWatermark
