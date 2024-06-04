import { useEffect } from 'react'
import { useMeetingInfoContext } from '../store'
import { WATERMARK_STRATEGY } from '../types'
import {
  drawWatermark,
  stopDrawWatermark,
  WatermarkParams,
} from '../utils/watermark'

function useWatermark(params?: WatermarkParams): void {
  const { meetingInfo } = useMeetingInfoContext()

  useEffect(() => {
    if (meetingInfo) {
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
        function replaceFormat(format: string, info: Record<string, string>) {
          const regex = /{([^}]+)}/g
          const result = format.replace(regex, (match, key) => {
            const value = info[key]
            return value ? value : match // 如果值存在，则返回对应的值，否则返回原字符串
          })
          return result
        }
        function draw() {
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
  }, [meetingInfo, params])
}

export default useWatermark
