import {
  MutableRefObject,
  useCallback,
  useEffect,
  useRef,
  useState,
} from 'react'
import NEMeetingService from '../services/NEMeeting'
import {
  ActionType,
  CaptionMessageUserInfo,
  Dispatch,
  NEMember,
} from '../types'
import { NERoomCaptionMessage } from 'neroom-types'
import Toast from '../components/common/toast'
import { useTranslation } from 'react-i18next'
import { getWindow } from '../kit'

interface CaptionProps {
  neMeeting?: NEMeetingService
  dispatch?: Dispatch
  memberList: NEMember[]
  isElectronSharingScreen?: boolean
  meetingNum: string
  isH5?: boolean
}
// 开始转写消息
const TranscriptionStartMessage = {
  fromUserUuid: '',
  content: '',
  timestamp: 0,
  isFinal: false,
}

// 结束转写消息
const TranscriptionEndMessage = {
  fromUserUuid: '',
  content: '',
  timestamp: 0,
  isFinal: true,
}

interface CaptionRes {
  transcriptionMessageList: NERoomCaptionMessage[]
  messageUserInfosRef: MutableRefObject<Map<string, CaptionMessageUserInfo>>
  hasTranscriptionHistoryMessages: () => boolean
}

export default function useTranscription(params: CaptionProps): CaptionRes {
  const { t } = useTranslation()
  const {
    neMeeting,
    dispatch,
    memberList,
    isElectronSharingScreen,
    meetingNum,
    isH5,
  } = params

  const memberListRef = useRef<NEMember[]>(memberList)

  const messageUserInfosRef = useRef(new Map<string, CaptionMessageUserInfo>())

  // 转写消息历史，每个元素为一段时间内的转写消息
  const transcriptionMessagesRef = useRef<NERoomCaptionMessage[][]>([
    [TranscriptionStartMessage],
  ])

  // 当前阶段内的 Final 消息
  const currentFinalTranscriptionMessages = useRef<NERoomCaptionMessage[]>([])

  const currentNonFinalTranscriptionMessagesMapRef = useRef(
    new Map<string, NERoomCaptionMessage>()
  )

  memberListRef.current = memberList

  const [transcriptionMessageList, setTranscriptionMessageList] = useState<
    NERoomCaptionMessage[]
  >([TranscriptionStartMessage])

  const generateTranscriptionMessageList = useCallback(() => {
    let segments: NERoomCaptionMessage[] = []

    if (neMeeting?.liveTranscriptionController?.isTranscriptionEnabled()) {
      segments = [
        ...currentFinalTranscriptionMessages.current,
        ...currentNonFinalTranscriptionMessagesMapRef.current.values(),
      ].sort((a, b) => a.timestamp - b.timestamp)
    }

    setTranscriptionMessageList(
      [...transcriptionMessagesRef.current, ...segments].flat()
    )
  }, [neMeeting?.liveTranscriptionController])

  const handleReceiveTranscriptionMessageList = useCallback(
    (messages: NERoomCaptionMessage[]) => {
      messages.forEach((message) => {
        const nonFinale =
          currentNonFinalTranscriptionMessagesMapRef.current.get(
            message.fromUserUuid
          )

        if (nonFinale) {
          message.timestamp = nonFinale.timestamp
        }

        if (message.isFinal) {
          currentNonFinalTranscriptionMessagesMapRef.current.delete(
            message.fromUserUuid
          )
          currentFinalTranscriptionMessages.current.push(message)
        } else {
          currentNonFinalTranscriptionMessagesMapRef.current.set(
            message.fromUserUuid,
            message
          )
        }
      })

      generateTranscriptionMessageList()
    },
    [generateTranscriptionMessageList]
  )

  /** 是否有转写历史消息 */
  function hasTranscriptionHistoryMessages(): boolean {
    return (
      currentFinalTranscriptionMessages.current.length > 0 ||
      currentNonFinalTranscriptionMessagesMapRef.current.size > 0 ||
      transcriptionMessagesRef.current.length > 0
    )
  }

  useEffect(() => {
    if (!meetingNum) {
      setTranscriptionMessageList([])
      currentFinalTranscriptionMessages.current = []
      currentNonFinalTranscriptionMessagesMapRef.current.clear()
    }
  }, [meetingNum])

  useEffect(() => {
    const liveTranscriptionController = neMeeting?.liveTranscriptionController

    const listener = {
      onReceiveCaptionMessages: (messages) => {
        messages.forEach((message) => {
          const member = memberListRef.current.find(
            (item) => item.uuid === message.fromUserUuid
          )

          if (member) {
            messageUserInfosRef.current.set(message.fromUserUuid, {
              userId: message.fromUserUuid,
              nickname: member.name,
              avatar: member.avatar,
            })
          }
        })
        if (neMeeting?.liveTranscriptionController?.isTranscriptionEnabled()) {
          handleReceiveTranscriptionMessageList(messages)
        }
      },

      onTranscriptionEnableChanged(enable) {
        if (enable) {
          // 默认已有开启消息一条
          if (transcriptionMessagesRef.current.length > 1) {
            transcriptionMessagesRef.current.push([TranscriptionStartMessage])
          }

          if (!isH5) {
            Toast.info(t('transcriptionStartedNotificationMsg'))
          }
        } else {
          if (!isH5) {
            Toast.info(t('transcriptionStoppedTip'))
          }

          const segments = [
            ...currentFinalTranscriptionMessages.current,
            ...currentNonFinalTranscriptionMessagesMapRef.current.values(),
          ].sort((a, b) => a.timestamp - b.timestamp)

          transcriptionMessagesRef.current.push(segments)
          currentFinalTranscriptionMessages.current = []
          currentNonFinalTranscriptionMessagesMapRef.current.clear()
          transcriptionMessagesRef.current.push([TranscriptionEndMessage])
        }

        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            isTranscriptionEnabled: enable,
          },
        })
        generateTranscriptionMessageList()
      },
    }

    liveTranscriptionController?.addListener(listener)

    return () => {
      liveTranscriptionController?.removeListener(listener)
    }
  }, [
    neMeeting?.liveTranscriptionController,
    dispatch,
    t,
    isH5,
    handleReceiveTranscriptionMessageList,
    generateTranscriptionMessageList,
  ])

  useEffect(() => {
    if (!isElectronSharingScreen) {
      return
    }

    const transcriptionInMeetingWindow = getWindow(
      'transcriptionInMeetingWindow'
    )

    if (transcriptionInMeetingWindow) {
      transcriptionInMeetingWindow?.postMessage(
        {
          event: 'updateData',
          payload: {
            transcriptionMessageList: transcriptionMessageList
              ? JSON.parse(JSON.stringify(transcriptionMessageList))
              : [],
            messageUserInfosRef: messageUserInfosRef.current,
          },
        },
        transcriptionInMeetingWindow.origin
      )
    }
  }, [isElectronSharingScreen, transcriptionMessageList])

  return {
    transcriptionMessageList,
    messageUserInfosRef,
    hasTranscriptionHistoryMessages,
  }
}
