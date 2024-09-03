import React, { useState, useRef, useEffect } from 'react'
import { useTranslation } from 'react-i18next'
import classNames from 'classnames'
import './index.less'
import PrivateChatMemberPopover from '../../web/NEChatRoom/component/PrivateChatMemberPopover'
import { useChatRoomContext } from '../../../hooks/useChatRoom'
import Toast from '../toast'
import BulletScreenMessageList from './BulletScreenMessageList'
import { IPCEvent } from '../../../app/src/types'
import { useMeetingInfoContext } from '../../../store'
import {
  ActionType,
  getLocalStorageSetting,
  setLocalStorageSetting,
} from '../../../kit'

type BulletScreenMessageProps = {
  className?: string
  isElectronScreenSharing?: boolean
  inputToolbarHidden?: boolean
}
const BulletScreenMessage: React.FC<BulletScreenMessageProps> = (props) => {
  const { inputToolbarHidden } = props
  const { t } = useTranslation()
  const { meetingInfo, dispatch } = useMeetingInfoContext()
  const { onSendTextMsg, disabled } = useChatRoomContext()

  const inputRef = useRef<HTMLInputElement>(null)
  const expandBtnHoverTimerRef = useRef<NodeJS.Timeout | number>()
  const inputFocusTimerRef = useRef<NodeJS.Timeout | number>()

  const [expandBtnHover, setExpandBtnHover] = useState(false)
  const [inputFocus, setInputFocus] = useState(false)

  const expand = !meetingInfo.setting.normalSetting.foldChatMessageBarrage

  function handleExpandBtnClick(enable: boolean) {
    const _setting = getLocalStorageSetting()

    if (_setting) {
      _setting.normalSetting.foldChatMessageBarrage = !enable

      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          setting: _setting,
        },
      })

      setLocalStorageSetting(JSON.stringify(_setting))
    }
  }

  // 监听回车事件
  const onKeyDown = async (e: React.KeyboardEvent<HTMLDivElement>) => {
    if (inputRef.current) {
      const textContent = inputRef.current?.value.trim()

      // 回车
      if (e.keyCode === 13) {
        // 阻止默认换行
        e.preventDefault()
        // 性能优化，等待回车才获取输入框元素，而不是每次change获取

        if (textContent.length === 0) {
          Toast.fail(t('messageEmpty'))
          return
        }

        if (textContent.length > 5000) {
          Toast.fail(t('messageLengthLimit'))
          return
        }

        onSendTextMsg(textContent)

        inputRef.current.value = ''
      }
    }
  }

  useEffect(() => {
    if (disabled !== 0) {
      inputRef.current?.blur()
    }
  }, [disabled])

  return (
    <div
      id="nemeeting-bullet-screen-message-container-dom"
      className={classNames(
        'nemeeting-bullet-screen-message-container',
        props.className,
        {
          ['nemeeting-bullet-screen-message-container-expand']: expand,
        }
      )}
      onWheel={() => {
        window.isChildWindow &&
          window.ipcRenderer?.send(IPCEvent.IgnoreMouseEvents, true)
      }}
      onMouseMove={() => {
        window.isChildWindow &&
          window.ipcRenderer?.send(IPCEvent.IgnoreMouseEvents, true)
      }}
      onClick={() => {
        window.isChildWindow &&
          window.ipcRenderer?.send(IPCEvent.IgnoreMouseEvents, true)
      }}
    >
      <>
        {expand && <BulletScreenMessageList />}
        <div
          className={classNames(
            'nemeeting-bullet-screen-message-input-container',
            {
              ['nemeeting-bullet-screen-message-input-container-focus']:
                inputFocus,
              ['nemeeting-bullet-screen-message-input-container-hide']:
                (!inputFocus && inputToolbarHidden) || !expand,
            }
          )}
          onWheel={(event) => {
            event.stopPropagation()
          }}
          onMouseMove={(event) => {
            event.stopPropagation()
          }}
          onClick={(event) => {
            event.stopPropagation()
          }}
          onMouseEnter={() => {
            window.isChildWindow &&
              window.ipcRenderer?.send(IPCEvent.IgnoreMouseEvents, false)
          }}
          onMouseLeave={() => {
            window.isChildWindow &&
              window.ipcRenderer?.send(IPCEvent.IgnoreMouseEvents, true)
          }}
        >
          {inputFocus ? (
            <PrivateChatMemberPopover
              onOpenChange={(open) => {
                if (!open) {
                  inputRef.current?.focus()
                }
              }}
              renderPrivateChatMember={(
                privateChatMemberId,
                privateChatMember
              ) => {
                return (
                  <div
                    className="private-chat-member"
                    onClick={() => {
                      if (inputFocusTimerRef.current) {
                        clearTimeout(inputFocusTimerRef.current)
                        inputFocusTimerRef.current = undefined
                      }

                      setInputFocus(true)
                    }}
                  >
                    <span className="private-chat-member-name">
                      {privateChatMember ? (
                        <>
                          <div className="private-chat-member-name-text">
                            {privateChatMember.nick}
                          </div>
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
                      <use xlinkHref="#iconjiantou-xia-copy"></use>
                    </svg>
                  </div>
                )
              }}
              getPopupContainer={() => {
                return document.getElementById(
                  'nemeeting-bullet-screen-message-container-dom'
                ) as HTMLDivElement
              }}
              onPrivateChatMemberSelected={() => {
                inputRef.current?.focus()
              }}
            />
          ) : null}

          {disabled !== 0 ? (
            <>
              <svg className="icon iconfont jinyan-icon" aria-hidden="true">
                <use xlinkHref="#icondanmujinyan"></use>
              </svg>
              <div className="nemeeting-bullet-screen-message-input-divider" />
            </>
          ) : null}
          <input
            ref={inputRef}
            placeholder={
              disabled === 0
                ? t('meetingSaySomeThing')
                : t('meetingKeepSilence')
            }
            style={{
              fontSize: '12px',
            }}
            onFocus={() => {
              if (disabled !== 0) {
                const disabledTips = [
                  '',
                  t('chatHostMutedEveryone'),
                  t('chatHostLeft'),
                  t('chatWaitingRoomMuted'),
                ][disabled]

                Toast.info(disabledTips)
                inputRef.current?.blur()
              } else {
                setInputFocus(true)
              }
            }}
            onBlur={() => {
              if (inputFocusTimerRef.current) {
                clearTimeout(inputFocusTimerRef.current)
                inputFocusTimerRef.current = undefined
              }

              inputFocusTimerRef.current = setTimeout(() => {
                setInputFocus(false)
                inputFocusTimerRef.current = undefined
              }, 200)
            }}
            onKeyDown={onKeyDown}
          />
          <div className="nemeeting-bullet-screen-message-input-divider" />
          <div
            className="nemeeting-bullet-screen-message-fold-btn"
            onClick={() => handleExpandBtnClick(false)}
            onMouseEnter={() => {
              if (expandBtnHoverTimerRef.current) {
                clearTimeout(expandBtnHoverTimerRef.current)
                expandBtnHoverTimerRef.current = undefined
              }

              setExpandBtnHover(true)
            }}
            onMouseLeave={() => {
              expandBtnHoverTimerRef.current = setTimeout(() => {
                setExpandBtnHover(false)
                expandBtnHoverTimerRef.current = undefined
              }, 1000)
            }}
          >
            <svg className="icon iconfont" aria-hidden="true">
              <use xlinkHref="#iconyx-returnx"></use>
            </svg>
            {expandBtnHover && <div>{t('meetingClose')}</div>}
          </div>
        </div>
      </>
      {!expand && !inputToolbarHidden ? (
        <div
          className="nemeeting-bullet-screen-message-container-expand-btn"
          onWheel={(event) => {
            event.stopPropagation()
          }}
          onMouseMove={(event) => {
            event.stopPropagation()
          }}
          onClick={(event) => {
            handleExpandBtnClick(true)
            setExpandBtnHover(false)
            event.stopPropagation()
          }}
          onMouseEnter={() => {
            window.isChildWindow &&
              window.ipcRenderer?.send(IPCEvent.IgnoreMouseEvents, false)
          }}
          onMouseLeave={() => {
            window.isChildWindow &&
              window.ipcRenderer?.send(IPCEvent.IgnoreMouseEvents, true)
          }}
        >
          <svg className="icon iconfont" aria-hidden="true">
            <use xlinkHref="#icondanmu"></use>
          </svg>
        </div>
      ) : null}
    </div>
  )
}

export default BulletScreenMessage
