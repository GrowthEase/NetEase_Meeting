import { useUpdateEffect } from 'ahooks'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import { useCallback, useEffect, useMemo, useRef } from 'react'
import { createDefaultCaptionSetting } from '../services'
import {
  ASRTranslationLanguageToString,
  getLocalStorageSetting,
} from '../utils'
import { ActionType, EventType } from '../types'

export default function useSaveSetting(meetingNum: string) {
  const { meetingInfo, dispatch } = useMeetingInfoContext()
  const { neMeeting } = useGlobalContext()

  const settingRef = useRef(meetingInfo.setting)

  settingRef.current = meetingInfo.setting

  const captionSetting = useMemo(() => {
    return meetingInfo.setting.captionSetting
  }, [meetingInfo.setting.captionSetting])

  const beautySetting = useMemo(() => {
    return meetingInfo.setting.beautySetting
  }, [meetingInfo.setting.beautySetting])

  const accountInfoUpdateHandle = useCallback(
    (res) => {
      if (res.reason === 'CHANGE_SETTINGS') {
        const setting = getLocalStorageSetting()

        if (setting) {
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              setting,
            },
          })
        }
      }
    },
    [dispatch]
  )

  useEffect(() => {
    if (meetingNum) {
      neMeeting?.eventEmitter.on(
        EventType.ReceiveAccountInfoUpdate,
        accountInfoUpdateHandle
      )

      return () => {
        neMeeting?.eventEmitter.off(
          EventType.ReceiveAccountInfoUpdate,
          accountInfoUpdateHandle
        )
      }
    }
  }, [meetingNum])

  useUpdateEffect(() => {
    if (!meetingNum) {
      return
    }

    const setting = settingRef.current
    const captionSetting =
      settingRef.current.captionSetting || createDefaultCaptionSetting()

    neMeeting?.saveSettings({
      beauty: {
        level: setting.beautySetting?.beautyLevel || 0,
      },
      asrTranslationLanguage: ASRTranslationLanguageToString(
        captionSetting?.targetLanguage
      ),
      captionBilingual: !!captionSetting.showCaptionBilingual,
      transcriptionBilingual: !!captionSetting.showTranslationBilingual,
    })
  }, [
    meetingNum,
    captionSetting?.targetLanguage,
    captionSetting?.showCaptionBilingual,
    captionSetting?.showTranslationBilingual,
    beautySetting?.beautyLevel,
  ])
}
