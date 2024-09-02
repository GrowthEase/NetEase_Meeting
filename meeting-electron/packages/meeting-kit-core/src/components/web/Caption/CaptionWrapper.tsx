import React, { useEffect, useMemo, useRef, useState } from 'react'
import useCaption from '../../../hooks/useCaption'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import Caption from '.'
import { ActionType, MeetingEventType, MeetingSetting } from '../../../types'
import { createDefaultCaptionSetting } from '../../../services'
import { getWindow } from '../../../utils/windowsProxy'
import { NERoomCaptionTranslationLanguage } from 'neroom-types'

interface CaptionWrapperProps {
  className?: string
  isElectronSharingScreen?: boolean
  isHostOrCoHost: boolean
  onSettingChange: (setting: MeetingSetting) => void
  openMeetingWindow: (payload: {
    name: string
    url?: string
    postMessageData?: { event: string; payload: Record<string, string> }
  }) => void
}

const CaptionWrapper: React.FC<CaptionWrapperProps> = ({
  isElectronSharingScreen,
  isHostOrCoHost,
  onSettingChange,
  openMeetingWindow,
}) => {
  const { neMeeting } = useGlobalContext()
  const { meetingInfo, dispatch, memberList } = useMeetingInfoContext()
  // 用于字幕第一次不加载等加载过一次之后不再销毁而是不渲染，用于保存上一次的位置
  const [needShowCaption, setNeedShowCaption] = useState(false)
  const meetingInfoRef = useRef(meetingInfo)

  meetingInfoRef.current = meetingInfo
  const { captionMessageList, enableCaption } = useCaption({
    neMeeting,
    dispatch,
    memberList,
    meetingNum: meetingInfo.meetingNum,
    isMouseOverCaption: meetingInfo.isMouseOverCaption,
    canShowCaption: meetingInfo.canShowCaption,
  })
  const captionMessageListRef = useRef(captionMessageList)

  captionMessageListRef.current = captionMessageList
  const canShowCaption = useMemo(() => {
    return (
      (meetingInfo.isCaptionsEnabled || meetingInfo.enableCaptionLoading) &&
      (meetingInfo.canShowCaption || meetingInfo.isMouseOverCaption)
    )
  }, [
    meetingInfo.canShowCaption,
    meetingInfo.isCaptionsEnabled,
    meetingInfo.enableCaptionLoading,
    meetingInfo.isMouseOverCaption,
  ])

  useEffect(() => {
    neMeeting?.eventEmitter.on(MeetingEventType.openCaption, () => {
      enableCaption(!meetingInfo.isCaptionsEnabled)
      if (isElectronSharingScreen) {
        openMeetingWindow({
          name: 'captionWindow',
          postMessageData: {
            event: 'updateData',
            payload: {
              meetingInfo: JSON.parse(JSON.stringify(meetingInfoRef.current)),
              captionMessageList: captionMessageListRef.current
                ? JSON.parse(JSON.stringify(captionMessageListRef.current))
                : [],
            },
          },
        })
      }
    })
    return () => {
      neMeeting?.eventEmitter.off(MeetingEventType.openCaption)
    }
  }, [
    neMeeting,
    isElectronSharingScreen,
    enableCaption,
    meetingInfo.isCaptionsEnabled,
  ])

  useEffect(() => {
    if (isElectronSharingScreen) {
      if (canShowCaption) {
        openMeetingWindow({
          name: 'captionWindow',
          postMessageData: {
            event: 'updateData',
            payload: {
              meetingInfo: meetingInfoRef.current
                ? JSON.parse(JSON.stringify(meetingInfoRef.current))
                : undefined,
              captionMessageList: captionMessageListRef.current
                ? JSON.parse(JSON.stringify(captionMessageListRef.current))
                : undefined,
            },
          },
        })
      } else {
        const captionWindow = getWindow('captionWindow')

        if (!captionWindow) {
          return
        }

        captionWindow.postMessage(
          {
            event: 'closeCaptionWindow',
          },
          captionWindow.origin
        )
      }
    }
  }, [isElectronSharingScreen, canShowCaption])
  useEffect(() => {
    if (canShowCaption && !needShowCaption) {
      setNeedShowCaption(true)
    }
  }, [canShowCaption, needShowCaption])

  useEffect(() => {
    return () => {
      if (meetingInfoRef.current.isCaptionsEnabled) {
        enableCaption(false)
      }
    }
  }, [enableCaption])

  useEffect(() => {
    if (isElectronSharingScreen) {
      const captionWindow = getWindow('captionWindow')

      captionWindow?.postMessage(
        {
          event: 'updateData',
          payload: {
            captionMessageList: captionMessageList
              ? JSON.parse(JSON.stringify(captionMessageList))
              : [],
          },
        },
        captionWindow.origin
      )
    }
  }, [isElectronSharingScreen, captionMessageList])

  useEffect(() => {
    if (canShowCaption && !needShowCaption) {
      setNeedShowCaption(true)
    }
  }, [canShowCaption, needShowCaption])
  const onAllowParticipantsEnableCaption = (allow: boolean) => {
    neMeeting?.liveTranscriptionController?.allowParticipantsEnableCaption(
      allow
    )
  }

  function onCaptionSizeChange(size: number): void {
    const setting = meetingInfo.setting

    if (!setting.captionSetting) {
      setting.captionSetting = createDefaultCaptionSetting()
    } else {
      setting.captionSetting.fontSize = size
    }

    onSettingChange(setting)
  }

  function onCaptionShowBilingual(enable: boolean): void {
    const setting = meetingInfo.setting

    if (!setting.captionSetting) {
      setting.captionSetting = createDefaultCaptionSetting()
    } else {
      setting.captionSetting.showCaptionBilingual = enable
    }

    onSettingChange(setting)
  }

  function onTargetLanguageChange(
    lang: NERoomCaptionTranslationLanguage
  ): void {
    const setting = meetingInfo.setting

    if (!setting.captionSetting) {
      setting.captionSetting = createDefaultCaptionSetting()
    } else {
      setting.captionSetting.targetLanguage = lang
    }

    onSettingChange(setting)
  }

  const onClickCloseCaption = () => {
    enableCaption(false)
  }

  return (canShowCaption || needShowCaption) && !isElectronSharingScreen ? (
    <Caption
      onMouseOut={() => {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            isMouseOverCaption: false,
          },
        })
      }}
      onMouseOver={() => {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            isMouseOverCaption: true,
          },
        })
      }}
      className={`nemeeting-web-caption-wrapper ${
        canShowCaption ? '' : 'nemeeting-web-caption-hidden'
      }`}
      fontSize={meetingInfo.setting.captionSetting?.fontSize || 15}
      onAllowParticipantsEnableCaption={onAllowParticipantsEnableCaption}
      onCaptionShowBilingual={onCaptionShowBilingual}
      onTargetLanguageChange={onTargetLanguageChange}
      isHostOrCoHost={isHostOrCoHost}
      onSizeChange={onCaptionSizeChange}
      onClose={onClickCloseCaption}
      captionMessageList={captionMessageList}
      showCaptionBilingual={
        !!meetingInfo.setting.captionSetting?.showCaptionBilingual
      }
      targetLanguage={meetingInfo.setting.captionSetting?.targetLanguage}
      isAllowParticipantsEnableCaption={
        meetingInfo.isAllowParticipantsEnableCaption
      }
      enableCaptionLoading={!!meetingInfo.enableCaptionLoading}
    />
  ) : null
}

export default React.memo(CaptionWrapper)
