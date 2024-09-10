/* eslint-disable @typescript-eslint/explicit-module-boundary-types */
import { NERoomChatMessage } from '../../../types/innerType'

interface CommonError {
  code: number | string
  message: string
}

export function handleRecMsgService(msgs: NERoomChatMessage[]): {
  msgs: NERoomChatMessage[]
  unReadMsgsCount: number
} {
  let unReadMsgsCount = 0 // 获取未读消息

  msgs = msgs
    .filter((msg: NERoomChatMessage) => {
      if (['text', 'image', 'audio', 'video', 'file'].includes(msg.type)) {
        unReadMsgsCount += 1
      }

      return (
        ['text', 'image', 'audio', 'video', 'file'].includes(msg.type) ||
        (msg.type === 'notification' &&
          msg.attach?.type &&
          ['deleteChatroomMsg', 'historyMessage'].includes(msg.attach.type))
      )
    })
    .map((msg: NERoomChatMessage) => {
      msg = formatMsg(msg)
      return msg
    })
  return {
    msgs,
    unReadMsgsCount,
  }
}

const handleMap = {
  group: (request, params) => {
    console.log('params', params)
    return request
      .sendGroupTextMessage(params.toAccids, params.text)
      .then((res) => {
        return res.data
      })
      .catch((err: unknown) => {
        const error = err as CommonError

        return error
      })
  },
  orientation: (request, params) => {
    console.log('params', params)
    return request
      .sendBroadcastTextMessage(params.text)
      .then((res) => {
        return res.data
      })
      .catch((err: unknown) => {
        const error = err as CommonError

        return error
      })
  },
  resend: (request, params) => {
    console.log('params', params)
    return request
      .resendTextMessage(params.text, params.idClient, params.toAccids)
      .then((res) => {
        console.log(res, 'resend success')
        return res.data
      })
      .catch((err: unknown) => {
        const error = err as CommonError

        console.log(err, 'resend err')
        return error
      })
  },
}

export function handleSendMsgService(
  request,
  params: {
    msgType: 'orientation' | 'group' | 'resend'
    type: string
    text: string
  }
) {
  return handleMap[params.msgType](request, params)
}

export function formatMsg(
  msg: NERoomChatMessage,
  myUuid?: string
): NERoomChatMessage {
  myUuid && (msg.isMe = msg.from === myUuid)
  return msg
}
