import React from 'react'
import { Transcription } from '.'
import useTranscription from '../../../hooks/useTranscription'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import {
  CaptionMessageUserInfo,
  MeetingEventType,
  MeetingSetting,
} from '../../../types'
import { useMount, useUpdateEffect } from 'ahooks'

interface TranscriptionWrapperProps {
  visible: boolean
  isElectronSharingScreen?: boolean
  onSettingChange: (setting: MeetingSetting) => void
  openMeetingWindow: (payload: {
    name: string
    url?: string
    postMessageData?: {
      event: string
      payload: Record<string, string | Map<string, CaptionMessageUserInfo>>
    }
  }) => void
}
const TranscriptionWrapper: React.FC<TranscriptionWrapperProps> = ({
  visible,
  isElectronSharingScreen,
  openMeetingWindow,
  onSettingChange,
}) => {
  const { neMeeting } = useGlobalContext()
  const { meetingInfo, dispatch, memberList } = useMeetingInfoContext()

  const meetingInfoRef = React.useRef(meetingInfo)

  meetingInfoRef.current = meetingInfo

  const { transcriptionMessageList, messageUserInfosRef } = useTranscription({
    neMeeting,
    dispatch,
    memberList,
    meetingNum: meetingInfo.meetingNum,
    isElectronSharingScreen,
  })

  const transcriptionMessageListRef = React.useRef(transcriptionMessageList)

  transcriptionMessageListRef.current = transcriptionMessageList

  useUpdateEffect(() => {
    neMeeting?.eventEmitter.emit(
      MeetingEventType.transcriptionMsgCountChange,
      transcriptionMessageList.length
    )
  }, [transcriptionMessageList.length])

  useMount(() => {
    neMeeting?.eventEmitter.on(MeetingEventType.openTranscriptionWindow, () => {
      openMeetingWindow({
        name: 'transcriptionInMeetingWindow',
        postMessageData: {
          event: 'updateData',
          payload: {
            transcriptionMessageList: transcriptionMessageListRef.current
              ? JSON.parse(JSON.stringify(transcriptionMessageListRef.current))
              : [],
            messageUserInfosRef: messageUserInfosRef.current,
            meetingInfo: meetingInfoRef.current
              ? JSON.parse(JSON.stringify(meetingInfoRef.current))
              : meetingInfoRef.current,
          },
        },
      })
    })
  })

  return (
    <Transcription
      onSettingChange={onSettingChange}
      visible={visible}
      transcriptionMessageList={transcriptionMessageList}
      messageUserInfosRef={messageUserInfosRef}
    />
  )
}

export default React.memo(TranscriptionWrapper)
