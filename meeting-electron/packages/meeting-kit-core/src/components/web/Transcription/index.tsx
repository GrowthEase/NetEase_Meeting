;``
import React, {
  MutableRefObject,
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react'
import './index.less'
import { Button, Dropdown, MenuProps, Popover } from 'antd'
import { useTranslation } from 'react-i18next'
import {
  NERoomCaptionMessage,
  NERoomCaptionTranslationLanguage,
} from 'neroom-types'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import {
  CaptionMessageUserInfo,
  MeetingSetting,
  NEMeetingInfo,
  Role,
} from '../../../types'
import UserAvatar from '../../common/Avatar'
import { formatDate } from '../../../utils'
import Toast from '../../common/toast'
import {
  AutoSizer,
  CellMeasurer,
  CellMeasurerCache,
  List,
} from 'react-virtualized'
import useTranslationOptions from '../../../hooks/useTranslationOptions'
import { createDefaultCaptionSetting } from '../../../services'
import { useUpdateEffect } from 'ahooks'

const cache = new CellMeasurerCache({
  fixedWidth: true,
  minHeight: 40,
})

interface TranscriptionProps {
  className?: string
  transcriptionMessageList?: NERoomCaptionMessage[]
  messageUserInfosRef?: MutableRefObject<Map<string, CaptionMessageUserInfo>>
  isElectronWindow?: boolean
  visible?: boolean
  onSettingChange: (setting: MeetingSetting) => void
}

interface TranscriptionItemProps {
  className?: string
  message: NERoomCaptionMessage & { avatar?: string; nickname?: string }
  messageUserInfosRef?: MutableRefObject<Map<string, CaptionMessageUserInfo>>
  canShowMainLang?: boolean
  targetLanguage?: NERoomCaptionTranslationLanguage
}

export const TranscriptionItem: React.FC<TranscriptionItemProps> = ({
  message,
  canShowMainLang,
  targetLanguage,
}) => {
  const { t } = useTranslation()
  const selectedTextRef = useRef<string>('')

  const items: MenuProps['items'] = [
    {
      label: t('globalCopy'),
      key: 'copy',
      onClick: () => {
        if (selectedTextRef.current) {
          navigator.clipboard.writeText(selectedTextRef.current)
        } else {
          navigator.clipboard.writeText(message.content)
        }
      },
    },
  ]

  const canShowOriginLanguage = useMemo(() => {
    return (
      canShowMainLang ||
      targetLanguage === NERoomCaptionTranslationLanguage.NONE ||
      !targetLanguage ||
      !message.translationContent
    )
  }, [canShowMainLang, targetLanguage, message.translationContent])

  const canShowTranslationLanguage = useMemo(() => {
    return (
      message.translationContent &&
      targetLanguage !== NERoomCaptionTranslationLanguage.NONE &&
      targetLanguage
    )
  }, [message.translationContent, targetLanguage])

  const transcriptionItems: MenuProps['items'] = [
    {
      label: t('globalCopy'),
      key: 'copy',
      onClick: () => {
        if (selectedTextRef.current) {
          navigator.clipboard.writeText(selectedTextRef.current)
        } else {
          navigator.clipboard.writeText(message.translationContent || '')
        }
      },
    },
  ]

  return message.content ? (
    <div className="nemeeting-transcription-item">
      <UserAvatar
        size={24}
        nickname={message.nickname}
        avatar={message.avatar}
      />
      <div className="nemeeting-transcription-item-name">
        <div className="nemeeting-transcription-item-name-wrapper">
          <div className="nemeeting-transcription-item-nickname">
            {message.nickname}
          </div>
          <div className="nemeeting-transcription-item-time">
            {formatDate(message.timestamp, 'hh:mm:ss')}
          </div>
        </div>

        {canShowOriginLanguage && (
          <Dropdown trigger={['contextMenu']} menu={{ items }}>
            <div
              onMouseUp={() => {
                selectedTextRef.current =
                  window.getSelection()?.toString() || ''
              }}
              className="nemeeting-transcription-item-content"
            >
              {message.content}
            </div>
          </Dropdown>
        )}
        {(canShowTranslationLanguage || canShowMainLang) && (
          <Dropdown
            trigger={['contextMenu']}
            menu={{ items: transcriptionItems }}
          >
            <div
              onMouseUp={() => {
                selectedTextRef.current =
                  window.getSelection()?.toString() || ''
              }}
              className="nemeeting-transcription-item-content"
            >
              {message.translationContent}
            </div>
          </Dropdown>
        )}
      </div>
    </div>
  ) : (
    <div className="nemeeting-transcription-start-tip">
      {message.isFinal
        ? t('transcriptionStoppedTip')
        : t('transcriptionStartedTip')}
    </div>
  )
}

export const Transcription: React.FC<TranscriptionProps> = ({
  transcriptionMessageList,
  messageUserInfosRef,
  isElectronWindow,
  visible,
  onSettingChange,
}) => {
  const { t } = useTranslation()
  const { meetingInfo } = useMeetingInfoContext()
  const { neMeeting } = useGlobalContext()
  const [virtualListHeight, setVirtualListHeight] = useState(0)
  const contentWrapperRef = useRef<HTMLDivElement | null>(null)
  const [scrollToIndex, setScrollToIndex] = useState<number>()
  // 用于解决打开后不会重新渲染列表问题
  const [currentTime, setCurrentTime] = useState(0)
  const isScrolledToBottomRef = useRef(true)
  const transcriptionMessageListRef = useRef(transcriptionMessageList)

  const meetingInfoRef = useRef<NEMeetingInfo>(meetingInfo)

  meetingInfoRef.current = meetingInfo
  transcriptionMessageListRef.current = transcriptionMessageList

  const isHostOrCoHost = useMemo(() => {
    const role = meetingInfo.localMember.role

    return role === Role.host || role === Role.coHost
  }, [meetingInfo.localMember.role])

  const { translationMap, translationOptions } = useTranslationOptions()

  const startTranscription = () => {
    neMeeting?.enableTranscription(true).catch((e) => {
      Toast.fail(e?.msg || e?.message)
    })
  }

  const stopTranscription = () => {
    neMeeting?.enableTranscription(false).catch((e) => {
      Toast.fail(e?.msg || e?.message)
    })
  }

  const handleResize = useCallback(() => {
    setVirtualListHeight(contentWrapperRef.current?.clientHeight || 0)
  }, [])

  useEffect(() => {
    handleResize()
    window.addEventListener('resize', handleResize)
    return () => {
      window.removeEventListener('resize', handleResize)
    }
  }, [handleResize])

  useEffect(() => {
    if (visible) {
      setCurrentTime(new Date().getTime())
      cache.clearAll()

      if (
        transcriptionMessageListRef.current &&
        transcriptionMessageListRef.current.length > 0
      ) {
        setScrollToIndex(transcriptionMessageListRef.current.length - 1)
      }
    }
  }, [visible])

  useEffect(() => {
    if (transcriptionMessageList?.length && isScrolledToBottomRef.current) {
      setScrollToIndex(transcriptionMessageList?.length - 1)
    } else {
      setScrollToIndex(-1)
    }
  }, [transcriptionMessageList?.length])

  const targetTranslationLanguage = useMemo(() => {
    return meetingInfo.setting.captionSetting?.targetLanguage
  }, [meetingInfo.setting.captionSetting?.targetLanguage])

  const showTranslationBilingual = useMemo(() => {
    return meetingInfo.setting.captionSetting.showTranslationBilingual
  }, [meetingInfo.setting.captionSetting.showTranslationBilingual])

  const onTargetLanguageChange = useCallback(
    (lang: NERoomCaptionTranslationLanguage) => {
      const setting = meetingInfoRef.current.setting

      if (!setting.captionSetting) {
        setting.captionSetting = createDefaultCaptionSetting()
      } else {
        setting.captionSetting.targetLanguage = lang
      }

      onSettingChange?.(setting)
    },
    []
  )

  const translationOptionsContent = useMemo(() => {
    return (
      <div
        onClick={(e) => {
          e.stopPropagation()
          e.preventDefault()
        }}
      >
        {translationOptions.map((item) => {
          return (
            <div
              key={item.value}
              className="nemeeting-caption-enable-member-wrapper"
              onClick={(e) => {
                e.stopPropagation()
                e.preventDefault()
                if (item.value === targetTranslationLanguage) {
                  return
                }

                onTargetLanguageChange(item.value)
              }}
            >
              <div>{item.label}</div>
              {item.value == targetTranslationLanguage && (
                <svg
                  className="icon iconfont"
                  aria-hidden="true"
                  style={{ color: '#337EFF' }}
                >
                  <use xlinkHref="#iconcheck-line-regular1x"></use>
                </svg>
              )}
            </div>
          )
        })}
      </div>
    )
  }, [translationOptions, targetTranslationLanguage, onTargetLanguageChange])

  const onTranslationShowBilingual = useCallback(
    (enable: boolean) => {
      const setting = meetingInfoRef.current.setting

      if (!setting.captionSetting) {
        setting.captionSetting = createDefaultCaptionSetting()
      } else {
        setting.captionSetting.showTranslationBilingual = enable
      }

      onSettingChange?.(setting)
    },
    [onSettingChange]
  )

  useUpdateEffect(() => {
    cache.clearAll()
  }, [meetingInfo.setting.captionSetting?.showTranslationBilingual])

  const enableMemberContent = useMemo(() => {
    return (
      <>
        <Popover
          arrow={false}
          rootClassName={'nemeeting-web-caption-translation-options-pop'}
          content={translationOptionsContent}
          title={null}
          trigger="hover"
          placement="right"
        >
          <div className="nemeeting-caption-enable-member-wrapper">
            <div>
              {translationMap[targetTranslationLanguage || ''] ||
                t('transcriptionNotTranslated')}
            </div>
            <svg
              className="icon iconfont"
              aria-hidden="true"
              style={{ fontSize: '14px' }}
            >
              <use xlinkHref="#iconyx-allowx"></use>
            </svg>
          </div>
        </Popover>
        <div className="nemeeting-caption-translation-border"></div>
        <div
          className="nemeeting-caption-enable-member-wrapper"
          onClick={(e) => {
            e.stopPropagation()
            e.preventDefault()
            onTranslationShowBilingual(
              !meetingInfo.setting.captionSetting?.showTranslationBilingual
            )
            cache.clearAll()
          }}
        >
          <div>{t('transcriptionShowBilingual')}</div>
          {meetingInfo.setting.captionSetting?.showTranslationBilingual && (
            <svg
              className="icon iconfont iconcheck-line-regular1x-blue"
              aria-hidden="true"
            >
              <use xlinkHref="#iconcheck-line-regular1x"></use>
            </svg>
          )}
        </div>
      </>
    )
  }, [
    t,
    meetingInfo.isAllowParticipantsEnableCaption,
    meetingInfo.setting.captionSetting?.showTranslationBilingual,
    neMeeting,
    translationMap,
    targetTranslationLanguage,
  ])

  const rowRenderer = ({ index, key, parent, style }) => {
    if (!transcriptionMessageList) {
      return null
    }

    const item = transcriptionMessageList[index]

    return (
      <CellMeasurer
        cache={cache}
        columnIndex={0}
        key={key}
        rowIndex={index}
        parent={parent}
      >
        {({ registerChild }) => (
          <div ref={registerChild} style={style} className="virtual-item">
            <TranscriptionItem
              key={index}
              canShowMainLang={showTranslationBilingual}
              targetLanguage={targetTranslationLanguage}
              message={{
                ...item,
                avatar: messageUserInfosRef?.current?.get(item.fromUserUuid)
                  ?.avatar,
                nickname: messageUserInfosRef?.current?.get(item.fromUserUuid)
                  ?.nickname,
              }}
            />
          </div>
        )}
      </CellMeasurer>
    )
  }

  useEffect(() => {
    // 更新缓存信息
    if (transcriptionMessageList && transcriptionMessageList?.length > 5) {
      const arr = new Array(5).fill(0)

      arr.forEach((_, index) => {
        const cacheIndex = transcriptionMessageList.length - 5 + index

        cache?.clear(cacheIndex, 0)
      })
    } else {
      cache.clearAll()
    }
  }, [transcriptionMessageList])

  const handleScroll = ({ clientHeight, scrollHeight, scrollTop }) => {
    if (
      clientHeight !== undefined &&
      scrollHeight !== undefined &&
      scrollTop !== undefined
    ) {
      const isScrolledToBottom = scrollHeight - clientHeight <= scrollTop + 10

      isScrolledToBottomRef.current = isScrolledToBottom
    }
  }

  return (
    <div className="nemeeting-transcription">
      <div className="nemeeting-transcription-content" ref={contentWrapperRef}>
        <AutoSizer>
          {({ width }) => (
            <List
              width={width}
              className="nemeeting-app-trans-detail-virtual-content"
              height={
                isElectronWindow
                  ? 477
                  : virtualListHeight || contentWrapperRef.current?.clientHeight
              }
              rowCount={transcriptionMessageList?.length || 0}
              rowHeight={cache.rowHeight}
              rowRenderer={rowRenderer}
              scrollToIndex={scrollToIndex}
              onScroll={handleScroll}
              data={currentTime}
            />
          )}
        </AutoSizer>
      </div>
      <div className="nemeeting-transcription-footer">
        <div className="nemeeting-transcription-footer-tip">
          <div className="nemeeting-transcription-footer-tag">
            {t('transcriptionDisclaimer')}
          </div>
        </div>
        {
          <div className="nemeeting-transcription-footer-content">
            {isHostOrCoHost &&
              (meetingInfo.isTranscriptionEnabled ? (
                <Button
                  title={t('transcriptionStop')}
                  className="nemeeting-transcription-btn"
                  onClick={() => stopTranscription()}
                >
                  {t('transcriptionStop')}
                </Button>
              ) : (
                <Button
                  title={t('transcriptionStart')}
                  className="nemeeting-transcription-btn"
                  type="primary"
                  onClick={() => startTranscription()}
                >
                  {t('transcriptionStart')}
                </Button>
              ))}

            <Popover
              arrow={false}
              rootClassName={'nemeeting-web-caption-translation-pop'}
              content={enableMemberContent}
              title={t('transcriptionTargetLang')}
              trigger="click"
            >
              <div className="nemeeting-tran-setting-icon">
                <svg className="icon iconfont" aria-hidden="true">
                  <use xlinkHref="#iconshezhi1"></use>
                </svg>
              </div>
            </Popover>
          </div>
        }
      </div>
    </div>
  )
}
