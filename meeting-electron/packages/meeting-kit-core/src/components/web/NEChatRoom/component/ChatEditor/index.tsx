import React, {
  useCallback,
  useEffect,
  useRef,
  forwardRef,
  useImperativeHandle,
  useState,
} from 'react'
import { useTranslation } from 'react-i18next'
import MyIcon from '../Icon'
import Toast from '../../../../common/toast'
import { imageExtensions, imgSizeLimit } from '../../../../../hooks/useChatRoom'

import './index.less'

const convertBase64ToFile = async (content: string): Promise<File> => {
  const arr = content.split(',')
  let mimeType = 'image/png'

  if (arr.length > 0) {
    const mineTypeMatch = arr[0].match(/:(.*?);/)

    if (mineTypeMatch) {
      mimeType = mineTypeMatch[1]
    }
  }

  const fileSuffix = mimeType.split('/')[1]
  const fileName = new Date().getTime() + '.' + fileSuffix

  return fetch(content)
    .then((res) => {
      return res.arrayBuffer()
    })
    .then((buf) => {
      return new File([buf], fileName, {
        type: mimeType,
      })
    })
}

type ChatEditorProps = {
  disabled: number
  onSendTextMsg: (text) => void
  uploadImgHandler: (file: File) => void
}

type IMsgToSend = {
  content: string
  type: 'text' | 'image'
}

export type ChatEditorRef = {
  inputDom: HTMLDivElement | null
  range: Range
}

const ChatEditor = forwardRef<
  ChatEditorRef,
  React.PropsWithChildren<ChatEditorProps>
>((props, ref) => {
  const { disabled, onSendTextMsg, uploadImgHandler } = props
  const { t } = useTranslation()

  const inputWrapperRef = useRef<HTMLDivElement>(null)
  const inputRef = useRef<HTMLDivElement>(null)
  const isFocusRef = useRef<boolean>(false)

  const [range, setRange] = useState<Range>()

  const disabledTips = [
    '',
    t('chatHostMutedEveryone'),
    t('chatHostLeft'),
    t('chatWaitingRoomMuted'),
  ][disabled]

  // 监听粘贴事件，复制图片
  const pasteListener = useCallback((event) => {
    // 未获取焦点情况下不处理监听事件
    if (!isFocusRef.current) {
      return
    }

    const items = event.clipboardData.items
    let file: File | null = null

    if (items && items.length) {
      // 搜索剪切板items，为了支持直接复制图片文件到剪切板
      for (const item of items) {
        if (item.type.indexOf('image') !== -1) {
          // 阻止默认的粘贴行为(不会粘贴图片文件内容)
          event.preventDefault()
          file = item.getAsFile()
          if (file) {
            if (window.isElectronNative) {
              break
            }

            // 判断是否超过文件大小限制
            if (file.size > imgSizeLimit) {
              Toast.fail(t('imageSizeLimit'))
              break
            }

            // 判断图片格式是否正确
            let ext = ''
            const fileNames = file.name.split('.')
            const len = fileNames.length

            if (fileNames && len > 1) {
              ext = fileNames[len - 1].toLowerCase() || ''
            }

            if (!imageExtensions.includes(ext)) {
              Toast.fail(t('imageTypeNotSupport'))
              break
            }

            const reader = new FileReader()

            reader.onload = function (event) {
              const selection = document.getSelection() || window.getSelection()

              if (selection) {
                const range = selection.getRangeAt(0)

                // 清楚当前选中的文字段，覆盖成粘贴的图片
                range.deleteContents()
                // 插入图片
                const imgEl = document.createElement('img')

                if (event.target?.result) {
                  imgEl.src = event.target.result as string
                  range.insertNode(imgEl)
                  // 设置光标位置到图片之后
                  range.setStartAfter(imgEl)
                  // 开始和结束关闭合并
                  range.collapse(true)
                  // 删除所有range进行重置
                  selection.removeAllRanges()
                  // 重新添加回最新range
                  selection.addRange(range)
                }
              }
            }

            reader.readAsDataURL(file)
            break
          }
        }
      }
    }
  }, [])

  const onFocusHandler = () => {
    try {
      const range = window.getSelection()?.getRangeAt(0)

      setRange(range)
    } catch {
      // getRangeAt 可能异常
    }

    isFocusRef.current = true
  }

  const onBlurHandler = () => {
    try {
      const range = window.getSelection()?.getRangeAt(0)

      setRange(range)
    } catch {
      //
    }

    isFocusRef.current = false
  }

  const getMsgsWaitingToSend = (): IMsgToSend[] => {
    // 获取子节点
    const tmpMsgs: IMsgToSend[] = []

    if (!inputRef.current) {
      return tmpMsgs
    }

    const nodes = Array.from(inputRef.current.childNodes) as HTMLImageElement[]
    let text = ''

    // 需要根据图片节点拆分消息发送
    nodes.forEach((node) => {
      // 文本节点
      if (node.nodeType === 3) {
        text += node.nodeValue
      } else if (node.nodeName === 'IMG') {
        const emojiText = node.getAttribute('data-emoji')

        if (emojiText) {
          text += emojiText
        } else {
          // 图片节点
          text &&
            tmpMsgs.push({
              type: 'text',
              content: text,
            })
          text = ''
          tmpMsgs.push({
            type: 'image',
            content: node.src,
          })
        }
      } else if (node.innerText) {
        // 其他节点
        text += node.innerText
      }
    })
    if (text) {
      tmpMsgs.push({
        type: 'text',
        content: text,
      })
      text = ''
    }

    return tmpMsgs
  }

  // 监听回车事件
  const onKeyDown = async (e: React.KeyboardEvent<HTMLDivElement>) => {
    // 回车
    if (e.keyCode === 13) {
      // 阻止默认换行
      e.preventDefault()
      // 性能优化，等待回车才获取输入框元素，而不是每次change获取
      const msgsWaitingToSend = getMsgsWaitingToSend()
      // 内容为空的时候进行提示

      if (
        !msgsWaitingToSend ||
        (msgsWaitingToSend && msgsWaitingToSend.length === 0)
      ) {
        Toast.fail(t('messageEmpty'))
        return
      }

      let flag = true

      for (const msg of msgsWaitingToSend) {
        // 文本消息
        if (msg.type === 'text') {
          if (msg.content.length > 5000) {
            Toast.fail(t('messageLengthLimit'))
            flag = false
            break
          }

          if (!msg.content.trim()) {
            Toast.fail(t('messageEmpty'))
            return
          }

          onSendTextMsg(msg.content.trim())
        } else if (msg.type === 'image') {
          // base64转到file
          try {
            const file = await convertBase64ToFile(msg.content)

            uploadImgHandler(file)
          } catch {
            //
          }
        }
      }

      if (flag) {
        if (inputRef.current) {
          inputRef.current.innerHTML = ''
        }
      }
    }
  }

  useEffect(() => {
    const inputDom = inputRef.current

    inputDom?.addEventListener('paste', pasteListener)
    // 监听滚动事件，如果滚动到底部则隐藏新消息按钮
    return () => {
      inputDom?.removeEventListener('paste', pasteListener)
    }
  }, [])

  useImperativeHandle(
    ref,
    () => ({
      inputDom: inputRef.current,
      range,
    }),
    [range]
  )

  return (
    <>
      {disabled ? (
        <div className="nemeeting-chatroom-editor-disabled">
          <MyIcon
            type="iconjinyan"
            height={20}
            width={20}
            color="rgba(204, 204, 204, 1)"
          />
          <span>{disabledTips}</span>
        </div>
      ) : null}
      <div
        className="nemeeting-chatroom-editor"
        ref={inputWrapperRef}
        style={{ display: disabled ? 'none' : undefined }}
      >
        <div
          className="nemeeting-chatroom-editable"
          onKeyDown={onKeyDown}
          onFocus={onFocusHandler}
          onBlur={onBlurHandler}
          ref={inputRef}
          contentEditable={true}
          data-placeholder={t('inputPlaceholder')}
        />
      </div>
    </>
  )
})

ChatEditor.displayName = 'ChatEditor'

export default ChatEditor
