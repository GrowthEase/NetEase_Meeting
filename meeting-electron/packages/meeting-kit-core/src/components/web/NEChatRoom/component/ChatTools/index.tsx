import React, { useMemo, useRef } from 'react'
import { useTranslation } from 'react-i18next'
import { Button, Popover } from 'antd'
import UserAvatar from '../../../../common/Avatar'
import { useGlobalContext, useMeetingInfoContext } from '../../../../../store'
import PrivateChatMemberPopover from '../PrivateChatMemberPopover'
import { hostAction, Role, Toast } from '../../../../../kit'
import MyIcon from '../Icon'

import './index.less'
import ChatEditor, { ChatEditorRef } from '../ChatEditor'
import {
  fileSizeLimit,
  imgSizeLimit,
  useChatRoomContext,
  imageExtensions,
  fileExtensions,
} from '../../../../../hooks/useChatRoom'
import ChatEmojiPopover from '../ChatEmoji'
import { getEmojiPath } from '../../../../common/Emoji'
import { ChatRoomProps } from '../..'

const ChatTools: React.FC<ChatRoomProps> = (props) => {
  const { t } = useTranslation()
  const { neMeeting, globalConfig } = useGlobalContext()
  const { meetingInfo } = useMeetingInfoContext()
  const chatEditorRef = useRef<ChatEditorRef>(null)
  const {
    messages,
    disabled,
    onSendFileMsg,
    onSendTextMsg,
    exportChatroomHistoryMessageList,
  } = useChatRoomContext()

  const isHost =
    meetingInfo.localMember.role === Role.host ||
    meetingInfo.localMember.role === Role.coHost

  const [privateChatLabel, setPrivateChatLabel] = React.useState(
    t('chatSendTo')
  )

  const enableImageMessage = useMemo(() => {
    return (
      globalConfig?.appConfig.MEETING_CHATROOM?.enableImageMessage !== false &&
      meetingInfo.chatroomConfig?.enableImageMessage !== false
    )
  }, [globalConfig, meetingInfo.chatroomConfig])

  const enableFileMessage = useMemo(() => {
    return (
      globalConfig?.appConfig.MEETING_CHATROOM?.enableFileMessage !== false &&
      meetingInfo.chatroomConfig?.enableFileMessage !== false
    )
  }, [globalConfig, meetingInfo.chatroomConfig])

  const meetingChatPermission = useMemo(() => {
    return meetingInfo.meetingChatPermission
  }, [meetingInfo.meetingChatPermission])

  const waitingRoomChatPermission = useMemo(() => {
    return meetingInfo.waitingRoomChatPermission
  }, [meetingInfo.waitingRoomChatPermission])

  async function inputFile(type: 'image' | 'file'): Promise<File> {
    return new Promise((resolve, reject) => {
      const fileInput = document.createElement('input')

      fileInput.type = 'file'
      const accept = type === 'image' ? imageExtensions : fileExtensions

      fileInput.accept = accept
      fileInput.onchange = (e) => {
        const file = (e.target as HTMLInputElement).files?.[0]

        if (file) {
          const ext = file.name && file.name.split('.').pop()?.toLowerCase()

          if (ext && !accept.includes(ext)) {
            Toast.fail(t('fileTypeNotSupport'))
            reject()
          }

          if (type === 'file' && file.size > fileSizeLimit) {
            Toast.fail(t('chatFileSizeExceedTheLimit'))
            reject()
          }

          if (type === 'image' && file.size > imgSizeLimit) {
            Toast.fail(t('chatImageSizeExceedTheLimit'))
            reject()
          }

          resolve(Object.assign(file, { url: URL.createObjectURL(file) }))
        }

        fileInput.parentElement?.removeChild(fileInput)
      }

      document.body.appendChild(fileInput)
      fileInput.click()
    })
  }

  function onMeetingChatPermissionChange(permission: number) {
    neMeeting?.sendHostControl(hostAction.changeChatPermission, '', permission)
  }

  function onWaitingRoomChatPermissionChange(permission: number) {
    neMeeting?.sendHostControl(
      hostAction.changeWaitingRoomChatPermission,
      '',
      permission
    )
  }

  function handleExportChatHistory() {
    if (props.meetingId) {
      exportChatroomHistoryMessageList?.(props.meetingId)
    } else {
      exportChatroomHistoryMessageList?.()
    }
  }

  function handleSelectFile() {
    window.ipcRenderer?.removeAllListeners('nemeeting-choose-file-done')
    window.ipcRenderer?.once(
      'nemeeting-choose-file-done',
      (_, { type, file }) => {
        if (navigator.onLine) {
          if (type === 'image' && file.size > imgSizeLimit) {
            Toast.fail(t('imageSizeLimit'))
            return
          }

          if (type === 'file' && file.size > fileSizeLimit) {
            Toast.fail(t('fileSizeLimit'))
            return
          }
        } else {
          Toast.fail(t('networkError'))
        }

        onSendFileMsg(type, file)
      }
    )
  }

  function renderRoleText(role?: string) {
    switch (role) {
      case 'host':
        return (
          <div className="private-chat-member-role">{`(${t('host')})`}</div>
        )
      case 'cohost':
        return (
          <div className="private-chat-member-role">{`(${t('coHost')})`}</div>
        )
      default:
        return null
    }
  }

  function renderEmoji() {
    return (
      <ChatEmojiPopover
        disabled={disabled !== 0}
        onClick={(emojiKey) => {
          const inputDom = chatEditorRef.current?.inputDom
          let range = chatEditorRef.current?.range

          if (!range) {
            inputDom?.focus()
            range = window.getSelection()?.getRangeAt(0)
          }

          const image = new Image()

          image.src = getEmojiPath(emojiKey) ?? ''

          image.style.width = '20px'
          image.style.margin = '0 1px 0 0'
          image.style.verticalAlign = 'text-bottom'
          image.setAttribute('data-emoji', emojiKey)

          const selection = window.getSelection()

          if (range) {
            range.deleteContents()
            range.insertNode(image)
            // // 设置光标位置到图片之后
            range.setStartAfter(image)
            // 开始和结束关闭合并
            range.collapse(true)
            // 删除所有range进行重置
            selection?.removeAllRanges()
            // 重新添加回最新range
            selection?.addRange(range)
          }
        }}
      >
        <div className="nemeeting-chatroom-tools-button">
          <MyIcon type="iconbiaoqing" color="#53576A" width="20" height="20" />
        </div>
      </ChatEmojiPopover>
    )
  }

  function renderUpload(type: 'image' | 'file') {
    const enable = type === 'image' ? enableImageMessage : enableFileMessage

    if (!enable) {
      return null
    }

    const iconType = type === 'image' ? 'icontupian1' : 'iconwenjian1'
    const extensions = type === 'image' ? imageExtensions : fileExtensions

    return (
      <div className="nemeeting-chatroom-tools-button">
        <MyIcon
          type={iconType}
          color="#53576A"
          width="20"
          height="20"
          onClick={() => {
            if (window.isElectronNative) {
              handleSelectFile()
              window.ipcRenderer?.send('nemeeting-choose-file', {
                type,
                extensions: extensions.split(',').map((i) => i.slice(1)),
              })
            } else {
              inputFile(type).then((file) => {
                onSendFileMsg(type, file)
              })
            }
          }}
        />
      </div>
    )
  }

  function renderPermission() {
    const meetingChatPermissions = [
      { key: 1, label: t('chatFree') },
      { key: 2, label: t('chatPublicOnly') },
      { key: 3, label: t('chatPrivateHostOnly') },
      { key: 4, label: t('chatMuted') },
    ]

    const waitingChatPermissions = [
      { key: 1, label: t('chatWaitingRoomPrivateHostOnly') },
    ]

    const content = (
      <div className="permission-content">
        <div className="permission-content-session">
          <div
            className="permission-content-session-link"
            onClick={() => handleExportChatHistory()}
          >
            {t('exportChatHistory')}
          </div>
        </div>
        <div className="permission-content-session">
          <div className="permission-content-session-title">
            {t('chatPermissionInMeeting')}
          </div>
          {meetingChatPermissions.map((item) => (
            <div
              className="permission-content-session-item"
              key={item.key}
              onClick={() => onMeetingChatPermissionChange?.(item.key)}
            >
              <div className="permission-content-session-item-text">
                {item.label}
              </div>
              {meetingChatPermission === item.key ? (
                <MyIcon
                  type="iconcheck-line-regular1x"
                  height={14}
                  width={14}
                  color="#337EFF"
                />
              ) : null}
            </div>
          ))}
        </div>
        <div className="permission-content-session" style={{ marginBottom: 0 }}>
          <div className="permission-content-session-title">
            {t('chatPermissionInWaitingRoom')}
          </div>
          {waitingChatPermissions.map((item) => (
            <div
              className="permission-content-session-item"
              key={item.key}
              onClick={() => {
                if (waitingRoomChatPermission === item.key) {
                  onWaitingRoomChatPermissionChange?.(0)
                } else {
                  onWaitingRoomChatPermissionChange?.(item.key)
                }
              }}
            >
              <div
                className="permission-content-session-item-text"
                title={item.label}
              >
                {item.label}
              </div>
              {waitingRoomChatPermission === item.key ? (
                <MyIcon
                  type="iconcheck-line-regular1x"
                  height={14}
                  width={14}
                  color="#337EFF"
                />
              ) : null}
            </div>
          ))}
        </div>
      </div>
    )

    return (
      <>
        <div className="nemeeting-chatroom-tools-button-divider" />
        <div className="nemeeting-chatroom-tools-button">
          <Popover
            trigger={['click']}
            placement="topRight"
            overlayClassName="permission-popover"
            getPopupContainer={(node) => node.parentNode as HTMLElement}
            content={content}
            arrow={false}
            autoAdjustOverflow={false}
          >
            <MyIcon
              type="iconliaotianshezhi"
              color="#53576A"
              width="20"
              height="20"
            />
          </Popover>
        </div>
      </>
    )
  }

  return props.meetingId ? (
    <div className="nemeeting-chatroom-export-wrapper ">
      <Button
        className="nemeeting-chatroom-export-button"
        onClick={handleExportChatHistory}
        type="primary"
        disabled={messages.length === 0}
      >
        {t('exportChatHistory')}
      </Button>
    </div>
  ) : (
    <>
      <div className="nemeeting-chatroom-tools">
        {disabled ? null : (
          <div className="nemeeting-chatroom-tools-private-chat">
            <div className="private-chat-label">{privateChatLabel}</div>
            <PrivateChatMemberPopover
              renderPrivateChatMember={(
                privateChatMemberId,
                privateChatMember
              ) => {
                let privateChatLabel = meetingInfo.inWaitingRoom
                  ? t('chatPrivate')
                  : t('chatSendTo')

                if (privateChatMember) {
                  privateChatLabel = privateChatMember.waitingRoom
                    ? t('chatPrivateInWaitingRoom')
                    : t('chatPrivate')
                }

                setPrivateChatLabel(privateChatLabel)

                return (
                  <div className="private-chat-member">
                    {privateChatMember ? (
                      <UserAvatar
                        size={16}
                        nickname={privateChatMember.nick}
                        avatar={privateChatMember.avatar}
                      />
                    ) : (
                      <svg className="icon iconfont" aria-hidden="true">
                        <use xlinkHref="#iconsuoyouren-24px"></use>
                      </svg>
                    )}
                    <span className="private-chat-member-name">
                      {privateChatMember ? (
                        <>
                          <div className="private-chat-member-name-text">
                            {privateChatMember.nick}
                          </div>
                          {renderRoleText(privateChatMember.role)}
                        </>
                      ) : privateChatMemberId === 'waitingRoomAll' ? (
                        <div className="private-chat-member-name-text">
                          {t('chatAllMembersInWaitingRoom')}
                        </div>
                      ) : (
                        <div className="private-chat-member-name-text">
                          {t('chatAllMembersInMeeting')}
                        </div>
                      )}
                    </span>
                    <svg className="icon iconfont" aria-hidden="true">
                      <use xlinkHref="#icona-xialajiantou-xianxing-14px1"></use>
                    </svg>
                  </div>
                )
              }}
              getPopupContainer={() => {
                return document.getElementById(
                  'nemeeting-chatroom-wrapper-dom'
                ) as HTMLDivElement
              }}
            />
          </div>
        )}
        <div
          className="nemeeting-chatroom-tools-buttons"
          style={{ display: disabled ? 'none' : undefined }}
        >
          {renderEmoji()}
          {renderUpload('image')}
          {renderUpload('file')}
          {isHost ? renderPermission() : null}
        </div>
      </div>
      <ChatEditor
        ref={chatEditorRef}
        disabled={disabled}
        onSendTextMsg={(text) => {
          onSendTextMsg(text)
        }}
        uploadImgHandler={(file) => {
          onSendFileMsg('image', file)
        }}
      />
    </>
  )
}

export default ChatTools
