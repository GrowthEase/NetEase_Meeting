import React, { useEffect, useState, useContext, useRef, useMemo } from 'react'
import {
  NERoomChatMessage,
  EventType,
  GlobalContext as GlobalContextInterface,
  BrowserType,
} from '../../../types'
import { GlobalContext, MeetingInfoContext } from '../../../store'
import NEChatRoomUI from '../NEChatRoomUI'
import { handleRecMsgService, handleSendMsgService, formatMsg } from './service'
import './index.less'
import Toast from '../../common/toast'
import { getBrowserType, getClientType, getIosVersion } from '../../../utils'

interface NEChatRoomProps {
  visible: boolean
  onClose: () => void
  unReadChange: (count: number) => void
  receiveMsg: NERoomChatMessage[] | undefined
}

const NEChatRoom: React.FC<NEChatRoomProps> = ({
  visible = false,
  onClose,
  unReadChange,
  receiveMsg,
}) => {
  const { neMeeting } = useContext<GlobalContextInterface>(GlobalContext)
  const { meetingInfo, memberList } = useContext(MeetingInfoContext)
  const [selfShow, setSelfShow] = useState(false)
  const [unReadMsgs, setUnReadMsgsCount] = useState(0)
  const [msgStr, setMsgStr] = useState('')
  const [errorMsg, setErrorMsg] = useState<NERoomChatMessage>()
  const [msgList, setMsgList] = useState<NERoomChatMessage[]>([]) // 聊天室消息
  const localMember = meetingInfo.localMember
  const contentRef = useRef(null)
  const [isFocus, setIsFocus] = useState(false)

  useEffect(() => {
    if (contentRef.current) {
      // @ts-ignore
      contentRef.current.scrollTop = contentRef.current.scrollHeight
    }
  }, [msgList])

  const chatroomUIProps = {
    msgs: msgList,
    resendMsg: onResendMsg,
  }
  useEffect(() => {
    receiveMsg && onReceiveMsgs(receiveMsg)
  }, [receiveMsg])

  useEffect(() => {
    setSelfShow(visible)
    if (visible) {
      unReadChange?.(0)
      setUnReadMsgsCount(0)
    } else {
      unReadChange?.(unReadMsgs)
    }
  }, [visible, unReadMsgs, unReadChange])

  const bottomClassName = useMemo(() => {
    // ios15需要特殊处理浏览器地址栏在底部并且会覆盖输入框
    if (
      getClientType() === 'IOS' &&
      getIosVersion() === '15.0' &&
      getBrowserType() != BrowserType.WX
    ) {
      if (isFocus) {
        return 'ne-chatroom-footer-bottom50'
      } else {
        // 失去焦时，整个界面不会随着键盘滚动到底部需要手动滚动下
        window.scrollBy(0, 1)
      }
    }
    return 'ne-chatroom-footer-bottom0'
  }, [isFocus])

  useEffect(() => {
    console.log(localMember, memberList, 'memberList')
    joinChatroom()
  }, [])

  const onCloseClick = () => {
    onClose?.()
  }

  // 接受消息
  function onReceiveMsgs(data: NERoomChatMessage[]) {
    console.log('--------onReceiveMsgs---------', data)
    const messages = data
    // console.log('收到msg:', messages)
    const type = messages[0].attach && messages[0].attach.type
    const updateListType = [
      'memberExit',
      'memberEnter',
      'kickMember',
      'updateChatroom',
    ]
    handleRecMsg(messages)
    if (type && updateListType.includes(type)) {
      getMembers()
    }
  }

  // 发送消息
  function onSendMsg() {
    if (!(msgStr && msgStr.trim())) {
      Toast.fail('无法发送内容为空的消息')
      return
    }
    if (contentRef.current) {
      // @ts-ignore
      contentRef.current.scrollTop = contentRef.current.scrollHeight
    }
    handleSendMsg({
      text: msgStr,
      type: 'text',
      msgType: 'orientation',
      toAccids: [],
    })
  }

  // 重发消息
  function onResendMsg() {
    console.log(errorMsg, 'errorMsg')
    if (!errorMsg) return
    // 重复消息
    handleSendMsg({
      idClient: errorMsg?.idClient,
      text: errorMsg?.text,
      type: errorMsg?.type,
      msgType: 'resend',
      toAccids: [],
    })
  }

  // 处理收到的消息
  function handleRecMsg(newMsgs: any) {
    const oldMsgs = [...msgList]
    const { msgs, unReadMsgsCount } = handleRecMsgService(newMsgs)
    console.log('--------unReadMsgs---------------', msgs, unReadMsgsCount)
    setUnReadMsgsCount(unReadMsgsCount + unReadMsgs)
    const msgArr = [...oldMsgs, ...msgs]
    setMsgList(msgArr)
  }

  // 发送消息处理
  function handleSendMsg(params: any) {
    handleSendMsgService(neMeeting?.chatController, params)
      .then((msg: NERoomChatMessage) => {
        msg = formatMsg(msg, localMember.uuid)
        const oldMsgs = [...msgList]
        if (msg.resend && msg.status === 'success') {
          // 如果是重新发送的
          const index = oldMsgs.findIndex((item) => {
            return item.idClient === msg.idClient
          })
          if (index > -1) {
            oldMsgs[index] = msg
          }
          setMsgList(oldMsgs)
          return
        } else if (!msg.resend) {
          // 发送失败或者断网消息
          if (msg.status === 'fail' || !msg.status) {
            msg.fromNick = localMember.name || ''
            setErrorMsg(msg)
            Toast.fail('发送失败，请重试')
            return
          }
          // 正常消息
          setMsgList([...oldMsgs, msg])
          setErrorMsg(msg)
        }
        setMsgStr('')
      })
      .catch((err: any) => {
        console.error(err)
      })
  }

  // 进入聊天室
  function joinChatroom() {
    if (neMeeting?.chatController) {
      const chatController = neMeeting.chatController
      chatController
        .joinChatroom()
        .then((res) => {
          console.log('joinChatroom success')
          // getHistoryMsgs()
          getMembers()
        })
        .catch((err) => {
          console.error('joinChatroom err', err)
        })
    }
  }

  // 离开聊天室
  function leaveChatRoom() {
    if (neMeeting?.chatController) {
      const chatController = neMeeting.chatController
      chatController
        .leaveChatroom()
        .then((res) => {
          console.log('leaveChatroom success')
          // getHistoryMsgs()
          getMembers()
        })
        .catch((err) => {
          console.error('leaveChatroom err', err)
        })
    }
  }

  function onHandleFocus() {
    setIsFocus(true)
  }

  function onHandleBlur() {
    setIsFocus(false)
  }

  // 获取历史消息
  // function getHistoryMsgs() {
  //   if (!neMeeting?.chatController) {
  //     console.error('not init chatroom')
  //     return
  //   }
  //   const chatController = neMeeting.chatController
  //   chatController
  //     .getHistoryMsgs()
  //     .then((res) => {
  //       console.log(res, 'getHistoryMsgs')
  //     })
  //     .catch((err) => {
  //       console.error(err, 'getHistoryMsgs err')
  //     })
  // }

  // 获取在线人数
  function getMembers() {
    if (!neMeeting?.chatController) {
      console.error('not init chatroom')
      return
    }
    const MyAccid = localMember.uuid
    let members = memberList
    members = members.filter(
      (item) => item.isInChatroom && item.uuid !== MyAccid
    )
    console.log('---------chatroom members------------', members)
    return members
  }

  return (
    <div
      className={`ne-meeting-chatroom ${selfShow ? 'show' : ''}`}
      onClick={onCloseClick}
    >
      <div
        className={`ne-chatroom-body ${selfShow ? 'show' : ''}`}
        onClick={(e) => {
          e.stopPropagation()
        }}
      >
        <div className="ne-chatroom-header">
          <span className="chatroom-icon-close" onClick={onCloseClick}>
            关闭
          </span>
          <span className="title">聊天</span>
        </div>
        <div className="ne-chatroom-content" ref={contentRef}>
          <NEChatRoomUI {...chatroomUIProps} />
          <div className={`ne-chatroom-footer ${bottomClassName}`}>
            <input
              value={msgStr}
              className="ne-chatroom-input"
              placeholder="请输入消息..."
              onFocus={onHandleFocus}
              onBlur={onHandleBlur}
              onChange={(e) => {
                setMsgStr(e.target.value)
              }}
            />
            <span className="ne-chatroom-btn" onClick={onSendMsg}>
              发送
            </span>
          </div>
        </div>
      </div>
    </div>
  )
}
export default NEChatRoom
