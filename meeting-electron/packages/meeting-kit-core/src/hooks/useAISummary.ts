import { useMemo } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import { Toast } from '../kit'
import { useTranslation } from 'react-i18next'

const useAISummary = () => {
  // 重复开启
  const codeAlreadyStarted = 1044

  const { neMeeting, globalConfig } = useGlobalContext()
  const { meetingInfo } = useMeetingInfoContext()
  const { t } = useTranslation()

  // 是否支持 AI 总结
  const isAISummarySupported = useMemo(() => {
    return !!globalConfig?.appConfig.APP_ROOM_RESOURCE.summary
  }, [globalConfig?.appConfig.APP_ROOM_RESOURCE.summary])

  // 是否已经开启 AI 总结
  const isAISummaryStarted = useMemo(() => {
    return !!meetingInfo.smartSummary
  }, [meetingInfo.smartSummary])

  // 开启 AI 总结
  function startAISummary() {
    neMeeting?.startAISummaryApi().catch((err) => {
      if (err.code === codeAlreadyStarted) {
        return
      }

      Toast.fail(t('cloudRecordingAISummaryFailed'))
    })
  }

  // 关闭 AI 总结
  function stopAISummary() {
    // 暂时不做任何处理
  }

  return {
    isAISummarySupported,
    isAISummaryStarted,
    startAISummary,
    stopAISummary,
  }
}

export default useAISummary
