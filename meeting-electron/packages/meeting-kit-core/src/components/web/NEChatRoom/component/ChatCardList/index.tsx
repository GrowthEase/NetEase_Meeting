import React, { useRef, useMemo, useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import dayjs from 'dayjs'
import {
  AutoSizer,
  CellMeasurer,
  CellMeasurerCache,
  List,
} from 'react-virtualized'
import 'react-virtualized/styles.css'
import { languageMap } from '../ChatCard/i18n'
import { useChatRoomContext } from '../../../../../hooks/useChatRoom'
import { useMeetingInfoContext } from '../../../../../store'
import { NERoomChatMessage } from '../../../../../kit'
import ChatCard from '../ChatCard'

import emptyImage from '../../../../../assets/empty-view-msg.png'

import './index.less'
import { ChatRoomProps } from '../..'

const cache = new CellMeasurerCache({
  fixedWidth: true,
  minHeight: 60,
})

const ChatCardList: React.FC<ChatRoomProps> = (props) => {
  const { i18n: i18next, t } = useTranslation()
  const { meetingInfo } = useMeetingInfoContext()
  const {
    messages,
    chatRoomMemberList,
    chatWaitingRoomMemberList,
    onPrivateChatMemberSelected,
    onRemoveMember,
    recallMessage,
    cancelSendFileMessage,
    onResend,
    openFile,
    downloadAttachment,
    cancelDownloadAttachment,
    fetchHistoryMessages,
    clearMessages,
  } = useChatRoomContext()

  const [virtualListHeight, setVirtualListHeight] = useState<number>()
  const [showMsgs, setShowMsgs] = useState<NERoomChatMessage[]>([])
  const [scrollToIndex, setScrollToIndex] = useState(-1)
  const [showToBottom, setShowToBottom] = useState(false)
  const [, setForceUpdate] = useState(0)

  const showMsgsRef = useRef<NERoomChatMessage[]>([])
  const contentWrapperRef = useRef<HTMLDivElement>(null)
  const isScrolledToBottomRef = useRef(true)
  const handleRefreshTimerRef = useRef<ReturnType<typeof setTimeout>>()
  const firstRef = useRef<boolean>(true)

  showMsgsRef.current = showMsgs

  const {
    localMember,
    inWaitingRoom = false,
    waitingRoomChatPermission,
    meetingChatPermission,
  } = meetingInfo

  const isViewHistory = !meetingInfo.meetingNum

  const i18n = languageMap[i18next.language.slice(0, 2)]

  const membersRoleMap = useMemo(() => {
    const map = new Map<string, string | undefined>()

    chatRoomMemberList.forEach((item) => {
      map.set(item.account, item.role)
    })
    return map
  }, [chatRoomMemberList])

  const waitingRoomMembersMap = useMemo(() => {
    const map = new Map<string, string>()

    chatWaitingRoomMemberList.forEach((item) => {
      map.set(item.account, item.account)
    })
    return map
  }, [chatWaitingRoomMemberList])

  function scrollToBottom() {
    setTimeout(() => {
      setScrollToIndex(showMsgs.length - 1)
    })
  }

  /**
   * 虚拟列表滚动处理，滚动到顶部时触发加载更多
   */
  const handleScroll = ({ clientHeight, scrollHeight, scrollTop }) => {
    if (
      clientHeight !== undefined &&
      scrollHeight !== undefined &&
      scrollTop !== undefined
    ) {
      const isScrolledToBottom = scrollHeight - clientHeight <= scrollTop + 10

      isScrolledToBottomRef.current = isScrolledToBottom
      if (isScrolledToBottom) {
        setShowToBottom(false)
      } else {
        setScrollToIndex(-1)
      }

      // // 滚动到顶部
      handleRefreshTimerRef.current &&
        clearTimeout(handleRefreshTimerRef.current)
      if (scrollTop === 0) {
        handleRefreshTimerRef.current = setTimeout(() => {
          fetchHistoryMessages?.(props.meetingId)
        }, 100)
      }
    }
  }

  const handleRowsRendered = ({ startIndex, stopIndex }) => {
    for (let i = startIndex; i <= stopIndex; i++) {
      cache.clear(i, 0)
    }
  }

  const rowRenderer = ({ index, key, parent, style }) => {
    const item = showMsgs[index]
    const role = localMember.role
    const memberRole = membersRoleMap.get(item.from)
    const waitingRoomMember = waitingRoomMembersMap.get(item.from)
    let enablePrivateChat = false
    let enableRemoveMember = false
    let isMemberInRoom = true

    if (!item.isMe) {
      if (role === 'host') {
        enablePrivateChat = true
        enableRemoveMember = true
      } else if (role === 'cohost') {
        enablePrivateChat = true
        if (memberRole !== 'host') {
          enableRemoveMember = true
        }
        // 普通参会者
      } else {
        if (inWaitingRoom) {
          // 等待室
          if (waitingRoomChatPermission === 0) {
            enablePrivateChat = false
          } else {
            enablePrivateChat = true
          }
        } else {
          // 会议中
          if (meetingChatPermission !== 4) {
            if (memberRole === 'host' || memberRole === 'cohost') {
              enablePrivateChat = true
            }

            if (meetingChatPermission === 1) {
              enablePrivateChat = true
            }
          }
        }
      }

      if (memberRole === undefined && waitingRoomMember === undefined) {
        if (inWaitingRoom) {
          enablePrivateChat = false
        } else {
          isMemberInRoom = false
        }

        enableRemoveMember = false
      }
    }

    let time = 0

    if (index === 0) {
      time = item.time
    } else {
      const prevItem = showMsgs[index - 1]

      if (item.time - prevItem.time > 60 * 1000) {
        time = item.time
      }
    }

    return (
      <CellMeasurer
        cache={cache}
        columnIndex={0}
        key={key}
        rowIndex={index}
        parent={parent}
      >
        {({ registerChild }) => (
          <div
            ref={registerChild}
            style={style}
            className="virtual-item"
            id={item.idClient}
          >
            {time > 0 ? (
              <div className="nemeeting-chatroom-content-time">
                {dayjs(time).isSame(dayjs(), 'D')
                  ? dayjs(time).format('HH:mm')
                  : dayjs(time).format('YYYY-MM-DD HH:mm')}
              </div>
            ) : null}
            <ChatCard
              i18n={i18n}
              isWaitingRoom={inWaitingRoom}
              isRooms={false}
              isViewHistory={isViewHistory}
              enablePrivateChat={enablePrivateChat}
              enableRemoveMember={enableRemoveMember}
              key={item.idClient}
              content={item}
              isMemberInRoom={isMemberInRoom}
              onPrivateChat={(id) => {
                onPrivateChatMemberSelected(id)
              }}
              onRemoveMember={onRemoveMember}
              recallMessage={recallMessage}
              cancelMessage={cancelSendFileMessage}
              onResend={onResend}
              openFile={openFile}
              downloadAttachment={downloadAttachment}
              cancelDownload={cancelDownloadAttachment}
              onReDownload={(msg) => {
                if (msg.file && msg.file.filePath) {
                  downloadAttachment?.(msg, msg.file.filePath)
                }
              }}
            />
          </div>
        )}
      </CellMeasurer>
    )
  }

  useEffect(() => {
    const revokeMsgs: NERoomChatMessage[] = []

    const filterMsgs = messages.filter((item) => {
      if (['text', 'image', 'file'].includes(item.type)) {
        return true
      }

      if (
        item.type === 'notification' &&
        item.attach?.type === 'deleteChatroomMsg'
      ) {
        revokeMsgs.push(item)
      }

      return false
    })

    revokeMsgs.forEach((msg) => {
      if (msg.attach) {
        const index = filterMsgs.findIndex(
          (item) =>
            item.idClient === msg.attach?.msgId && item.type !== 'notification'
        )

        if (index > -1) {
          const temp = filterMsgs[index]

          msg.idClient = temp.idClient
          msg.isMe = temp.isMe
          msg.attach.fromNick = temp.fromNick
          filterMsgs[index] = msg
          filterMsgs[index].time = msg.attach.msgTime

          cache.clear(index, 0)
          setForceUpdate((prev) => prev + 1)

          // 撤回消息时，如果是文件消息，需要取消下载
          if (temp.status === 'downloading') {
            cancelDownloadAttachment?.(temp)
          }
        }
      }
    })

    setShowMsgs(filterMsgs)
    if (filterMsgs.length === 0 && firstRef.current) {
      firstRef.current = false
      fetchHistoryMessages?.(props.meetingId)
    }
  }, [messages])

  useEffect(() => {
    // 设置高度
    if (contentWrapperRef.current?.clientHeight) {
      setVirtualListHeight(contentWrapperRef.current?.clientHeight)
    }

    const latestMessage = showMsgs[showMsgs.length - 1]

    // 如果在底部则不显示新消息按钮
    if (isScrolledToBottomRef.current || latestMessage?.isMe) {
      scrollToBottom()
    } else {
      // 如果是自己发送的消息则不显示新消息按钮
      if (messages.length > 0) {
        if (!latestMessage.isMe) {
          setShowToBottom(true)
        }
      }
    }
  }, [showMsgs[showMsgs.length - 1]?.idClient])

  useEffect(() => {
    const handleResize = () => {
      if (contentWrapperRef.current?.clientHeight) {
        setVirtualListHeight(contentWrapperRef.current?.clientHeight)
      }
    }

    handleResize()
    window.addEventListener('resize', handleResize)
    return () => {
      window.removeEventListener('resize', handleResize)
    }
  }, [])

  // 会前查询会议聊天记录的会议id，切换的时候需要清空消息
  useEffect(() => {
    if (props.meetingId) {
      clearMessages?.()
    }
  }, [props.meetingId])

  return (
    <div className={`nemeeting-chatroom-list-wrapper`} ref={contentWrapperRef}>
      {showMsgs.length === 0 && props.meetingId ? (
        <div className="nemeeting-chatroom-list-empty">
          <img src={emptyImage} />
          {t('noChatHistory')}
        </div>
      ) : (
        <>
          {showToBottom && (
            <div
              className={`nemeeting-chatroom-bottom-btn`}
              onClick={() => scrollToBottom()}
            >
              ↓ {t('newMsg')}
            </div>
          )}
          <AutoSizer disableHeight>
            {({ width }) => (
              <List
                className="nemeeting-chatroom-list-content"
                width={width}
                scrollToAlignment="end"
                height={
                  virtualListHeight ?? contentWrapperRef.current?.clientHeight
                }
                rowCount={showMsgs.length}
                rowHeight={cache.rowHeight}
                scrollToIndex={scrollToIndex}
                rowRenderer={rowRenderer}
                onScroll={handleScroll}
                onRowsRendered={handleRowsRendered}
              />
            )}
          </AutoSizer>
        </>
      )}
    </div>
  )
}

export default ChatCardList
