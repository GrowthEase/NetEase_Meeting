import { ExclamationCircleFilled, LoadingOutlined } from '@ant-design/icons'
import { useTranslation } from 'react-i18next'
import { Button, Dropdown, Image, MenuProps, message, Progress } from 'antd'
import React, { useEffect, useMemo, useState } from 'react'
import reactStringReplace from 'react-string-replace'
import { getLocalStorageSetting } from '../../../../../utils'
import { CommonModal, NERoomChatMessage, UserAvatar } from '../../../../../kit'
import MyIcon from '../Icon'

import Emoji from '../../../../common/Emoji'

import './index.less'

export function t(string: string, values: Record<string, string>): string {
  return string.replace(/{{(.*?)}}/g, (match, p1) => values[p1])
}

export const addUrlSearch = (url: string, search: string): string => {
  const urlObj = new URL(url)

  urlObj.search += (urlObj.search.startsWith('?') ? '&' : '?') + search
  return urlObj.href
}

export const matchExt = (extname: string): string => {
  const regMap: { [key: string]: RegExp } = {
    pdf: /pdf$/i,
    word: /(doc|docx)$/i,
    excel: /(xls|xlsx)$/i,
    ppt: /(ppt|pptx)$/i,
    txt: /(txt|html)$/i,
    image: /(png|jpg|jpeg|bmp)$/i,
    audio: /(mp3|aac|pcm|wav)$/i,
    video: /(mov|mp4|flv)$/i,
    zip: /(rar|zip|7z|gz|tar|biz)$/i,
  }

  return Object.keys(regMap).find((key) => regMap[key].test(extname)) || ''
}

export const parseFileSize = (size: number, level = 0): string => {
  const fileSizeMap: { [key: number]: string } = {
    0: 'B',
    1: 'KB',
    2: 'MB',
    3: 'GB',
    4: 'TB',
  }

  const handler = (size: number, level: number): string => {
    if (level >= Object.keys(fileSizeMap).length) {
      return 'the file is too big'
    }

    if (size < 1024) {
      return `${size}${fileSizeMap[level]}`
    }

    return handler(Math.round(size / 1024), level + 1)
  }

  return handler(size, level)
}

export const fileIconMap = {
  pdf: 'iconPDF',
  word: 'iconWord',
  excel: 'iconExcel',
  ppt: 'iconPPT',
  zip: 'iconRAR',
  txt: 'iconwenjian',
  image: 'icontupian2',
  audio: 'iconyinle',
  video: 'iconshipin',
}

type Message = NERoomChatMessage

interface IProps {
  i18n: Record<string, string>
  isWaitingRoom: boolean
  content: Message
  isRooms: boolean
  isViewHistory: boolean
  prefix?: string
  enableRemoveMember?: boolean
  enablePrivateChat?: boolean
  isMemberInRoom?: boolean
  onResend?: (msg: Message) => void
  onReDownload?: (msg: Message) => void
  recallMessage?: (msg: Message) => void
  cancelMessage?: (msg: Message) => void
  downloadAttachment?: (msg: Message, path: string) => void
  cancelDownload?: (msg: Message) => void
  openFile?: (msg: Message, isDir: boolean) => void
  onPrivateChat?: (id: string) => void
  onRemoveMember?: (id: string) => void
}

const ChatCard: React.FC<IProps> = ({
  i18n,
  content,
  prefix = 'chatroom',
  isRooms,
  isViewHistory,
  enableRemoveMember,
  enablePrivateChat,
  isMemberInRoom,
  onResend,
  onReDownload,
  cancelMessage,
  downloadAttachment,
  cancelDownload,
  openFile,
  recallMessage,
  onPrivateChat,
  onRemoveMember,
}) => {
  const { t: i18nTranslation } = useTranslation()
  const { isMe, fromNick, status, type, isPrivate, fromAvatar } = content
  const [imagePreviewVisible, setImagePreviewVisible] = useState(false)
  const [avatarDropdownOpen, setAvatarDropdownOpen] = useState(false)

  const textBgColor: React.CSSProperties = useMemo(() => {
    return {
      backgroundColor: isMe ? '#cce1ff' : '#f2f3f5',
    }
  }, [isMe])

  const renderSendStatus = (resend: () => void) => {
    if (status === 'fail') {
      return (
        <div className={`${prefix}-btn-resend`}>
          <Button
            danger
            ghost
            style={{
              border: 'none',
              width: 'auto',
              height: 'auto',
              color: '#FC596A',
            }}
            onClick={isMe ? resend : () => onReDownload?.(content)}
            icon={<ExclamationCircleFilled />}
          />
        </div>
      )
    }

    return null
  }

  const renderCardInfo = () => {
    let nickLabel

    if (isMe) {
      if (isPrivate) {
        // 我的私聊等候室
        if (content.chatroomType === 1) {
          nickLabel = (
            <>
              <span
                className={`${prefix}-chat-card-nickname-private`}
              >{`(${i18n.chatPrivateInWaitingRoom})`}</span>
              <span className={`${prefix}-chat-card-nickname-text`}>
                {t(i18n.chatISaidTo, { userName: content.toNickname || '' })}
              </span>
            </>
          )
        } else {
          nickLabel = (
            <>
              <span
                className={`${prefix}-chat-card-nickname-private`}
              >{`(${i18n.chatPrivate})`}</span>
              <span className={`${prefix}-chat-card-nickname-text`}>
                {t(i18n.chatISaidTo, { userName: content.toNickname || '' })}
              </span>
            </>
          )
        }
      } else {
        if (content.chatroomType === 1) {
          nickLabel = i18n.chatISaidToWaitingRoom
        } else {
          nickLabel = fromNick
        }
      }
    } else {
      if (isPrivate) {
        if (content.chatroomType === 1) {
          nickLabel = (
            <>
              <span className={`${prefix}-chat-card-nickname-text`}>
                {t(i18n.chatSaidToMe, { userName: content.fromNick })}
              </span>
              <span
                className={`${prefix}-chat-card-nickname-private`}
              >{`(${i18n.chatPrivateInWaitingRoom})`}</span>
            </>
          )
        } else {
          nickLabel = (
            <>
              <span className={`${prefix}-chat-card-nickname-text`}>
                {t(i18n.chatSaidToMe, { userName: content.fromNick })}
              </span>
              <span
                className={`${prefix}-chat-card-nickname-private`}
              >{`(${i18n.chatPrivate})`}</span>
            </>
          )
        }
      } else {
        if (content.chatroomType === 1) {
          nickLabel = t(i18n.chatSaidToWaitingRoom, { userName: fromNick })
        } else {
          nickLabel = fromNick
        }
      }
    }

    const items: MenuProps['items'] = [
      {
        label: (
          <span className={isMemberInRoom ? undefined : `${prefix}-c999`}>
            {i18n.chatPrivate}
          </span>
        ),
        key: '1',
        onClick: () => {
          onPrivateChat?.(content.from)
        },
        disabled: !enablePrivateChat,
      },
      {
        label: i18n.participantRemove,
        key: '2',
        onClick: () => {
          onRemoveMember?.(content.from)
        },
        disabled: !enableRemoveMember,
      },
    ].filter((item) => !item.disabled)

    return (
      <div className={`${prefix}-chat-card-info`}>
        {isMe ? (
          <>
            <span className={`${prefix}-chat-card-nickname`} title={fromNick}>
              {nickLabel}
            </span>
            <UserAvatar avatar={fromAvatar} nickname={fromNick} size={22} />
          </>
        ) : (
          <>
            <Dropdown
              trigger={items.length > 0 ? ['click'] : []}
              menu={{ items }}
              placement="bottomLeft"
              autoAdjustOverflow={false}
              open={avatarDropdownOpen}
              onOpenChange={setAvatarDropdownOpen}
            >
              <div style={items.length > 0 ? { cursor: 'pointer' } : undefined}>
                <UserAvatar avatar={fromAvatar} nickname={fromNick} size={22} />
              </div>
            </Dropdown>
            <span className={`${prefix}-chat-card-nickname`} title={fromNick}>
              {nickLabel}
            </span>
          </>
        )}
      </div>
    )
  }

  const renderText = (text: string) => {
    let selectedText = ''

    const items: MenuProps['items'] = [
      {
        label: i18n.copy,
        key: '1',
        onClick: () => {
          if (selectedText) {
            navigator.clipboard.writeText(selectedText)
          } else {
            navigator.clipboard.writeText(text)
          }
        },
      },
    ]

    if (isMe) {
      items.push({
        label: i18n.recall,
        key: '2',
        onClick: () => {
          recallMessage?.(content)
        },
      })
    }

    let renderText = reactStringReplace(
      text,
      /(https?:\/\/\S+)/gi,
      (match, i) => (
        <a
          key={i}
          href={match}
          target="_blank"
          onClick={(e) => {
            // 打开链接
            if (window.ipcRenderer) {
              e.preventDefault()
              window.ipcRenderer.send('open-browser-window', match)
            }
          }}
          rel="noreferrer"
        >
          {match}
        </a>
      )
    )

    renderText = reactStringReplace(renderText, /(\[.*?\])/gi, (match, i) => {
      return <Emoji key={i} emojiKey={match} size={20} />
    })

    return (
      <>
        {renderCardInfo()}
        <div className={`${prefix}-chat-card-content`}>
          {renderSendStatus(() => {
            onResend?.(content)
          })}
          <Dropdown
            trigger={['contextMenu']}
            menu={{ items }}
            getPopupContainer={() =>
              document.getElementById(
                'nemeeting-chatroom-wrapper-dom'
              ) as HTMLDivElement
            }
          >
            <div className={`${prefix}-chat-card-text`} style={textBgColor}>
              <div
                className={`${prefix}-chat-card-text-item`}
                onMouseUp={() => {
                  selectedText = window.getSelection()?.toString() || ''
                }}
              >
                {renderText}
              </div>
            </div>
          </Dropdown>
        </div>
      </>
    )
  }

  const renderImage = (data: Message['file']) => {
    const items: MenuProps['items'] = []

    if (window.isElectronNative && !isRooms && !isViewHistory) {
      items.push({
        label: i18n.saveAs,
        key: '1',
        onClick: () => {
          handleDownloadAttachment(true)
        },
      })
    }

    if (isMe && status === 'success') {
      items.push({
        label: i18n.recall,
        key: '2',
        onClick: () => {
          recallMessage?.(content)
        },
      })
    }

    return (
      <>
        {renderCardInfo()}
        <div
          className={`${prefix}-chat-card-content ${prefix}-chat-card-image-content`}
        >
          {renderSendStatus(() => {
            onResend?.(content)
          })}
          <div style={{ flex: 1 }}>
            <Dropdown
              trigger={items.length > 0 ? ['contextMenu'] : []}
              menu={{ items }}
            >
              {data ? (
                <Image
                  preview={
                    isViewHistory
                      ? false
                      : {
                          visible: imagePreviewVisible,
                          onVisibleChange: (value) => {
                            // 如果消息已经被删除，则不显示预览
                            if (!document.getElementById(content.idClient)) {
                              setImagePreviewVisible(false)
                            } else {
                              setImagePreviewVisible(value)
                            }
                          },
                          getContainer: () => {
                            // 如果消息已经被删除，则不显示预览
                            if (!document.getElementById(content.idClient)) {
                              setImagePreviewVisible(false)
                            }

                            return document.body
                          },
                        }
                  }
                  className={`${prefix}-chat-card-img`}
                  src={addUrlSearch(data.url, `download=${data.name}`)}
                  fallback={data.url}
                />
              ) : null}
            </Dropdown>
          </div>
          {/*图片添加下载按钮*/}
          {!isViewHistory &&
            data &&
            data.url &&
            status === 'success' &&
            (!window.isElectronNative ? (
              <div className={`${prefix}-chat-card-file-footer`}>
                <a
                  style={{ marginLeft: 10 }}
                  href={addUrlSearch(data.url, `download=${data.name}`)}
                  target="_blank"
                  rel="noreferrer"
                >
                  {i18n.download}
                </a>
              </div>
            ) : null)}
          {data && data.url && status === 'sending' ? (
            <div className={`${prefix}-loading-mask`}>
              <LoadingOutlined className={`${prefix}-icon-loading`} />
            </div>
          ) : (
            ''
          )}
        </div>
      </>
    )
  }

  const renderFile = (data: Message['file']) => {
    if (!data) {
      return
    }

    const items: MenuProps['items'] = []

    if (isMe && status === 'success') {
      items.push({
        label: i18n.recall,
        key: '2',
        onClick: () => {
          recallMessage?.(content)
        },
      })
    }

    const fileExt = '.' + data.ext

    return (
      <>
        {renderCardInfo()}
        <Dropdown
          trigger={items.length > 0 ? ['contextMenu'] : []}
          menu={{ items }}
        >
          <div className={`${prefix}-chat-card-fill-content`}>
            {renderSendStatus(() => {
              onResend?.(content)
            })}
            <a
              className={`${prefix}-chat-card-file`}
              href={
                status === 'success' && !window.isElectronNative
                  ? addUrlSearch(data.url, `download=${data.name}`)
                  : 'javascript:void(0);'
              }
              onClick={(e) => {
                if (window.isElectronNative || isViewHistory) {
                  e.preventDefault()
                }

                isRooms && message.error(i18n.cannotViewTheFile)
              }}
              style={
                status === 'fail' || isViewHistory
                  ? {
                      height: '100%',
                    }
                  : undefined
              }
              target="_blank"
              rel="noreferrer"
            >
              <MyIcon
                type={fileIconMap[matchExt(data.ext)] || 'iconweishibiewenjian'}
                width="32"
                height="32"
              />
              <div className={`${prefix}-chat-card-file-content`}>
                <div className={`${prefix}-chat-card-file-name`}>
                  <div className="file-name-text">
                    {data.name.replace(fileExt, '')}
                  </div>
                  <div className="file-name-ext">{fileExt}</div>
                </div>
                {(status === 'sending' || status === 'downloading') &&
                content.progress?.percentage ? (
                  <Progress
                    percent={content.progress?.percentage}
                    size="small"
                    showInfo={false}
                  />
                ) : (
                  <div className={`${prefix}-chat-card-file-size`}>
                    {parseFileSize(data.size)}
                  </div>
                )}
              </div>
            </a>
            {status === 'downloading' ? (
              <div className={`${prefix}-chat-card-file-footer`}>
                {content.progress?.percentage !== undefined ? (
                  <Button
                    type="link"
                    onClick={() => {
                      cancelDownload?.(content)
                    }}
                  >
                    {i18n.cancelDownload}
                  </Button>
                ) : (
                  ''
                  // <LoadingOutlined style={{ marginLeft: 20 }} />
                )}
              </div>
            ) : status === 'sending' ? (
              <div className={`${prefix}-chat-card-file-footer`}>
                {content.progress?.percentage !== undefined ? (
                  <Button
                    type="link"
                    onClick={() => {
                      handleAbortFile()
                    }}
                  >
                    {i18n.cancelSend}
                  </Button>
                ) : (
                  ''
                  // <LoadingOutlined style={{ marginLeft: 20 }} />
                )}
              </div>
            ) : !isViewHistory && status === 'success' ? (
              !window.isElectronNative ? (
                <div className={`${prefix}-chat-card-file-footer`}>
                  <a
                    style={{ marginLeft: 15 }}
                    href={addUrlSearch(data.url, `download=${data.name}`)}
                    target="_blank"
                    rel="noreferrer"
                  >
                    {i18n.download}
                  </a>
                </div>
              ) : data.filePath ? (
                <div className={`${prefix}-chat-card-file-footer`}>
                  <a
                    style={{ marginLeft: 15 }}
                    onClick={() => {
                      openFile?.(content, false)
                    }}
                  >
                    {i18n.openFile}
                  </a>
                  <a
                    style={{ marginLeft: 15 }}
                    onClick={() => {
                      openFile?.(content, true)
                    }}
                  >
                    {i18n.openDir}
                  </a>
                </div>
              ) : isRooms ? null : (
                <div className={`${prefix}-chat-card-file-footer`}>
                  <a
                    style={{ marginLeft: 15 }}
                    onClick={() => {
                      handleDownloadAttachment(false)
                    }}
                  >
                    {i18n.download}
                  </a>
                  <a
                    style={{ marginLeft: 15 }}
                    onClick={() => {
                      handleDownloadAttachment(true)
                    }}
                  >
                    {i18n.saveAs}
                  </a>
                </div>
              )
            ) : (
              ''
            )}
          </div>
        </Dropdown>
      </>
    )
  }

  const renderNotification = (attach: Message['attach']) => {
    if (isViewHistory || !attach) {
      return null
    }

    if (attach.type === 'historyMessage') {
      const dividingLineLength = Math.floor(
        (25 - i18n.historyMessage.length) / 2
      )
      let lineText = ''

      if (dividingLineLength > 0) {
        lineText = new Array(dividingLineLength).fill('-').join('')
      }

      return (
        <div className={`${prefix}-chat-card-noti-wrapper`}>
          <div className={`${prefix}-chatCardNotiContent`}>
            {lineText}
            &nbsp;{i18n.historyMessage}&nbsp;
            {lineText}
          </div>
        </div>
      )
    }

    if (attach.type === 'deleteChatroomMsg') {
      return (
        <div className={`${prefix}-chat-card-noti-wrapper`}>
          <div className={`${prefix}-chatCardNotiContent`}>
            {content.isMe ? i18n.you : `“${attach.fromNick}”`}
            {i18n.deleteChatroomMsg}
          </div>
        </div>
      )
    }

    return null
  }

  const renderNoSupport = () => {
    return (
      <>
        {renderCardInfo()}
        <div className={`${prefix}-chat-card-text`} style={textBgColor}>
          {i18n.messageNotSupport}
        </div>
      </>
    )
  }

  // 取消文件发送
  const handleAbortFile = () => {
    cancelMessage?.(content)
  }

  const handleDownloadAttachment = (saveAs: boolean) => {
    if (!saveAs) {
      let downloadPath: string | undefined
      const setting = getLocalStorageSetting()

      downloadPath = setting?.normalSetting?.downloadPath

      if (!downloadPath) {
        downloadPath = window.ipcRenderer?.sendSync(
          'nemeeting-download-path',
          'get'
        )
      }

      const isWin = window.systemPlatform === 'win32'

      downloadAttachment?.(
        content,
        downloadPath + (isWin ? '\\' : '/') + content.file?.name
      )
    } else {
      window.ipcRenderer?.send('nemeeting-file-save-as', {
        defaultPath: content.file?.name,
        filePath: content.file?.filePath,
      })
      window.ipcRenderer?.once(
        'nemeeting-file-save-as-reply',
        (_, filePath) => {
          filePath && downloadAttachment?.(content, filePath)
        }
      )
    }
  }

  useEffect(() => {
    if (!enableRemoveMember && !enablePrivateChat) {
      setAvatarDropdownOpen(false)
    }
  }, [enableRemoveMember, enablePrivateChat])

  useEffect(() => {
    function closeDropdown() {
      setAvatarDropdownOpen(false)
    }

    if (avatarDropdownOpen) {
      document.addEventListener('scroll', closeDropdown, true)
      return () => {
        document.removeEventListener('scroll', closeDropdown, true)
      }
    }
  }, [avatarDropdownOpen])

  useEffect(() => {
    return () => {
      setImagePreviewVisible(false)
    }
  }, [])

  useEffect(() => {
    if (content && imagePreviewVisible) {
      CommonModal.warning({
        title: i18nTranslation('commonTitle'),
        content: i18nTranslation('messageRecalled'),
      })
    }
  }, [content])

  return (
    <div
      id={content.idClient}
      className={`${prefix}-chat-card-wrapper`}
      style={{
        alignItems:
          type === 'notification' ? 'center' : isMe ? 'flex-end' : 'flex-start',
      }}
    >
      {(() => {
        switch (content.type) {
          case 'text':
            return renderText(content.text)
          case 'image':
            return renderImage(content.file)
          case 'file':
            return renderFile(content.file)
          case 'notification':
            return renderNotification(content.attach)
          default:
            return renderNoSupport()
        }
      })()}
    </div>
  )
}

export default ChatCard
