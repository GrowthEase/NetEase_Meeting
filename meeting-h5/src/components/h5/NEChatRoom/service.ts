/* eslint-disable @typescript-eslint/explicit-module-boundary-types */
import { NERoomChatMessage } from '../../../types/innerType'
import { formatDate } from '../../../utils'

export function handleRecMsgService(msgs: NERoomChatMessage[]): any {
  let unReadMsgsCount = 0 // 获取未读消息
  msgs = msgs
    .filter((msg: NERoomChatMessage) => {
      if (['text', 'image', 'audio', 'video', 'file'].includes(msg.type)) {
        unReadMsgsCount += 1
      }
      return (
        ['text', 'image', 'audio', 'video', 'file'].includes(msg.type) ||
        (msg.type === 'notification' && msg.text)
      )
    })
    .map((msg: any) => {
      msg = formatMsg(msg)
      return msg
    })
  return {
    msgs,
    unReadMsgsCount,
  }
}

const handleMap = {
  group: (request: any, params: any) => {
    console.log('params', params)
    return request
      .sendGroupTextMessage(params.toAccids, params.text)
      .then((res: any) => {
        return res.data
      })
      .catch((err: any) => {
        return err
      })
  },
  orientation: (request: any, params: any) => {
    console.log('params', params)
    return request
      .sendBroadcastTextMessage(params.text)
      .then((res: any) => {
        return res.data
      })
      .catch((err: any) => {
        return err
      })
  },
  resend: (request: any, params: any) => {
    console.log('params', params)
    return request
      .resendTextMessage(params.text, params.idClient, params.toAccids)
      .then((res: any) => {
        console.log(res, 'resend success')
        return res.data
      })
      .catch((err: any) => {
        console.log(err, 'resend err')
        return err
      })
  },
}

export function handleSendMsgService(
  request: any,
  params: {
    msgType: 'orientation' | 'group' | 'resend'
    type: string
    text: string
  }
) {
  return handleMap[params.msgType](request, params)
}

export function formatMsg(msg: NERoomChatMessage, myUuid?: string): any {
  msg.time = formatDate(msg.time, 'yyyy-MM-dd hh:mm:ss')
  myUuid && (msg.isMe = msg.from === myUuid)
  return msg
}
