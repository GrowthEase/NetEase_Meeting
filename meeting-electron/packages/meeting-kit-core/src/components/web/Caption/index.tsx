import { LoadingOutlined } from '@ant-design/icons'
import { Popover, Slider, SliderSingleProps, Spin } from 'antd'
import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import './index.less'
import { NEMeetingCaptionMessage } from '../../../types'
import { Rnd } from 'react-rnd'
import { NERoomCaptionTranslationLanguage } from 'neroom-types'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import useTranslationOptions from '../../../hooks/useTranslationOptions'
import { MAJOR_AUDIO } from '../../../config'

export interface CaptionProps {
  className?: string
  captionMessageList: NEMeetingCaptionMessage[]
  enableCaptionLoading: boolean
  fontSize: number
  onSizeChange?: (fontSize: number) => void
  onClose?: () => void
  isAllowParticipantsEnableCaption: boolean
  onAllowParticipantsEnableCaption: (allow: boolean) => void
  isHostOrCoHost?: boolean
  isElectronWindow?: boolean
  onMouseOver?: () => void
  onMouseOut?: () => void
  isElectronSharingScreen?: boolean
  showCaptionBilingual: boolean
  onCaptionShowBilingual?: (enable: boolean) => void
  onTargetLanguageChange?: (lang: NERoomCaptionTranslationLanguage) => void
  targetLanguage?: NERoomCaptionTranslationLanguage
}

interface CaptionMessageItemListProps {
  captionMessageList: NEMeetingCaptionMessage[]
  className?: string
  showCaptionBilingual?: boolean
  targetLanguage?: NERoomCaptionTranslationLanguage
  fontSize: number
}

interface CaptionMessageItemProps {
  message: NEMeetingCaptionMessage
  fontSize: number
  targetLanguage?: NERoomCaptionTranslationLanguage
  showCaptionBilingual?: boolean
}

const CaptionMessageItem: React.FC<CaptionMessageItemProps> = ({
  message,
  fontSize,
  showCaptionBilingual,
  targetLanguage,
}) => {
  const canShowMainLang = useMemo(() => {
    return (
      showCaptionBilingual ||
      targetLanguage === NERoomCaptionTranslationLanguage.NONE ||
      !targetLanguage
    )
  }, [showCaptionBilingual, targetLanguage])

  return (
    <>
      {canShowMainLang && (
        <div className="nemeeting-web-caption-message-item">
          <div
            className={`nemeeting-web-caption-message-item-name nemeeting-web-caption-message-name-${fontSize}`}
          >
            <div className="nemeeting-ellipsis">{message.fromNickname}</div>
            <div>：</div>
          </div>
          <div
            className={`nemeeting-web-caption-message-item-content nemeeting-web-caption-message-height-${fontSize}`}
          >
            {message.content}
          </div>
        </div>
      )}

      {message.translationContent && !!targetLanguage && (
        <div className="nemeeting-web-caption-message-item">
          <div
            className={`nemeeting-web-caption-message-item-name nemeeting-web-caption-message-name-${fontSize}`}
          >
            <div className="nemeeting-ellipsis">{message.fromNickname}</div>
            <div>：</div>
          </div>
          <div
            className={`nemeeting-web-caption-message-item-content nemeeting-web-caption-msg-tran nemeeting-web-caption-message-height-${fontSize}`}
          >
            {message.translationContent}
          </div>
        </div>
      )}
    </>
  )
}

const CaptionMessageItemList: React.FC<CaptionMessageItemListProps> = ({
  captionMessageList,
  fontSize,
  showCaptionBilingual,
  targetLanguage,
}) => {
  return (
    <div
      className={`nemeeting-web-caption-message-item-list nemeeting-web-caption-message-size-${fontSize}`}
    >
      {captionMessageList.length > 0
        ? captionMessageList.map((item, index) => {
            return (
              <CaptionMessageItem
                key={index}
                message={item}
                fontSize={fontSize}
                showCaptionBilingual={showCaptionBilingual}
                targetLanguage={targetLanguage}
              />
            )
          })
        : null}
    </div>
  )
}

export const Caption: React.FC<CaptionProps> = ({
  enableCaptionLoading,
  captionMessageList,
  fontSize,
  onSizeChange,
  isAllowParticipantsEnableCaption,
  onClose,
  onAllowParticipantsEnableCaption,
  isHostOrCoHost,
  isElectronWindow,
  onMouseOut,
  onMouseOver,
  onCaptionShowBilingual,
  onTargetLanguageChange,
  showCaptionBilingual,
  targetLanguage,
}) => {
  const { t } = useTranslation()
  const { interpretationSetting } = useGlobalContext()
  const { meetingInfo } = useMeetingInfoContext()

  const { translationMap, translationOptions } = useTranslationOptions()

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
                if (item.value === targetLanguage) {
                  return
                }

                onTargetLanguageChange?.(item.value)
              }}
            >
              <div>{item.label}</div>
              {item.value == targetLanguage && (
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
  }, [translationOptions, targetLanguage])

  const translationContent = useMemo(() => {
    return (
      <div
        onClick={(e) => {
          e.stopPropagation()
          e.preventDefault()
        }}
      >
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
              {translationMap[targetLanguage || ''] ||
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
          onClick={() => {
            onCaptionShowBilingual?.(!showCaptionBilingual)
          }}
          className="nemeeting-caption-enable-member-wrapper"
        >
          <div>{t('transcriptionShowBilingual')}</div>
          {showCaptionBilingual && (
            <svg
              className="icon iconfont"
              aria-hidden="true"
              style={{ color: '#337EFF' }}
            >
              <use xlinkHref="#iconcheck-line-regular1x"></use>
            </svg>
          )}
        </div>
      </div>
    )
  }, [
    showCaptionBilingual,
    translationOptionsContent,
    targetLanguage,
    translationMap,
  ])
  const enableMemberContent = useMemo(() => {
    return (
      <div
        className="nemeeting-caption-enable-member-wrapper"
        onClick={(e) => {
          e.stopPropagation()
          e.preventDefault()
          onAllowParticipantsEnableCaption(!isAllowParticipantsEnableCaption)
        }}
      >
        <div>{t('transcriptionAllowEnableCaption')}</div>
        {isAllowParticipantsEnableCaption && (
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
  }, [t, isAllowParticipantsEnableCaption, onAllowParticipantsEnableCaption])

  const sizeContent = useMemo(() => {
    const marks: SliderSingleProps['marks'] = {
      12: ' ',
      15: ' ',
      18: ' ',
      21: ' ',
      24: ' ',
    }

    return (
      <div className="nemeeting-caption-size-content">
        <div className="nemeeting-caption-size-label">
          {t('transcriptionCaptionSmall')}
        </div>
        <Slider
          marks={marks}
          className="nemeeting-caption-size-slider"
          onChange={onSizeChange}
          defaultValue={fontSize}
          max={24}
          min={12}
          step={3}
        />
        <div className="nemeeting-caption-size-label">
          {t('transcriptionCaptionBig')}
        </div>
      </div>
    )
  }, [t, fontSize, onSizeChange])

  return (
    <div
      style={{ height: '100%' }}
      onMouseOver={() => onMouseOver?.()}
      onMouseOut={() => onMouseOut?.()}
    >
      <div
        className={`nemeeting-web-caption-header ${
          isElectronWindow ? 'nemeeting-web-caption-header-show' : ''
        }`}
      >
        {isElectronWindow && (
          <div className="nemeeting-web-caption-header-dray"></div>
        )}

        <div className="nemeeting-web-caption-disclaimer">
          {t('transcriptionDisclaimer')}
        </div>

        <div className="nemeeting-web-caption-icon-wrapper">
          {!isElectronWindow && (
            <>
              <Popover
                arrow={false}
                rootClassName={'nemeeting-web-caption-translation-pop'}
                content={translationContent}
                title={t('transcriptionTargetLang')}
                trigger="hover"
              >
                <div className="nemeeting-web-caption-icon-item">
                  <svg className="icon iconfont" aria-hidden="true">
                    <use xlinkHref="#iconzimufanyi"></use>
                  </svg>
                </div>
              </Popover>
              <Popover
                arrow={false}
                rootClassName={'nemeeting-web-caption-size-pop'}
                content={sizeContent}
                title={t('transcriptionCaptionFontSize')}
                trigger="hover"
              >
                <div className="nemeeting-web-caption-icon-item">
                  <svg className="icon iconfont" aria-hidden="true">
                    <use xlinkHref="#iconzimuzihao"></use>
                  </svg>
                </div>
              </Popover>
            </>
          )}

          {isHostOrCoHost && (
            <Popover
              arrow={false}
              rootClassName={'nemeeting-web-caption-size-pop'}
              content={enableMemberContent}
              title={t('meetingAllowMembersTo')}
              trigger="hover"
            >
              <div className="nemeeting-web-caption-icon-item">
                <svg className="icon iconfont" aria-hidden="true">
                  <use xlinkHref="#iconzimugengduo"></use>
                </svg>
              </div>
            </Popover>
          )}

          <div
            className="nemeeting-web-caption-icon-item"
            onClick={() => onClose?.()}
          >
            <svg className="icon iconfont" aria-hidden="true">
              <use xlinkHref="#iconzimuguanbi"></use>
            </svg>
          </div>
        </div>
      </div>
      <div className="nemeeting-web-caption-content">
        {meetingInfo.interpretation?.started &&
        interpretationSetting?.listenLanguage &&
        interpretationSetting?.listenLanguage !== MAJOR_AUDIO ? (
          <div className="nemeeting-web-caption-loading">
            {t('transcriptionCaptionNotAvailableInSubChannel')}
          </div>
        ) : enableCaptionLoading ? (
          <div className="nemeeting-web-caption-loading">
            <Spin indicator={<LoadingOutlined spin />} size="small" />
            {t('transcriptionCaptionLoading')}
          </div>
        ) : (
          <CaptionMessageItemList
            captionMessageList={captionMessageList}
            fontSize={fontSize}
            showCaptionBilingual={showCaptionBilingual}
            targetLanguage={targetLanguage}
          />
        )}
      </div>
    </div>
  )
}

const WebCaption: React.FC<CaptionProps> = (props) => {
  const [width, setWidth] = useState('492px')
  const [position, setPosition] = useState({ x: 0, y: 0 })

  const captionElementRef = useRef<Rnd | null>(null)

  // 保存百分比位置
  const positionInfoRef = useRef({ left: 0, top: 0 })

  const wrapDomRef = useRef<Element | null>(null)

  const onResize = useCallback((entries: ResizeObserverEntry[]) => {
    for (const entry of entries) {
      const { width, height } = entry.contentRect
      const captionEle = captionElementRef.current?.getSelfElement()

      if (height <= 65) {
        return
      }

      // 当容器窗口尺寸变化时候需要重新设置位置
      if (captionEle) {
        // 获取当前speakerEle的位置
        const { left, top } = captionEle.getBoundingClientRect()

        let captionLeft = left
        let captionTop = top

        let captionWidth = captionEle.clientWidth

        let needUpdateXPosition = false
        let needUpdateYPosition = false
        let needUpdateSize = false

        if (left + captionEle.clientWidth > width) {
          if (captionWidth >= width) {
            captionWidth = width - 4
            captionLeft = 2
            needUpdateSize = true
          } else {
            captionLeft = width - captionEle.clientWidth - 2
          }

          needUpdateXPosition = true
        }

        if (top + captionEle.clientHeight > height) {
          captionTop = height - captionEle.clientHeight - 62
          needUpdateYPosition = true
        }

        setPosition({
          x: needUpdateXPosition
            ? captionLeft
            : width * positionInfoRef.current.left,
          y: needUpdateYPosition
            ? captionTop
            : height * positionInfoRef.current.top,
        })
        needUpdateSize && setWidth(`${captionWidth}px`)
      }
    }
  }, [])

  useEffect(() => {
    const wrapDom = document.querySelector('.meeting-web')
    let observer: ResizeObserver

    if (wrapDom) {
      observer = new ResizeObserver(onResize)
      observer.observe(wrapDom)
    }

    return () => {
      if (wrapDom && observer) {
        observer.unobserve(wrapDom)
        observer.disconnect()
      }
    }
  }, [onResize])

  useEffect(() => {
    const wrapDom = document.querySelector('.meeting-web')

    wrapDomRef.current = wrapDom
    let y = (wrapDom?.clientHeight || 0) - 300

    const x = (wrapDom?.clientWidth || 0) / 2 - 246

    y = y <= 0 ? 540 : y

    setPositionInfo(x, y)

    // 底部居中
    setPosition({
      x,
      y,
    })
  }, [])

  // 保存百分比。用于父窗口变化之后相对位置不变
  function setPositionInfo(x: number, y: number) {
    const wrapDom = wrapDomRef.current

    const captionEle = captionElementRef.current?.getSelfElement()

    if (wrapDom && captionEle) {
      positionInfoRef.current = {
        left: x / wrapDom.clientWidth,
        top: y / wrapDom.clientHeight,
      }

      console.warn(positionInfoRef.current)
    }
  }

  return (
    <Rnd
      ref={(c) => (captionElementRef.current = c)}
      enableResizing={{ top: false, bottom: false, left: true, right: true }}
      minWidth={492}
      minHeight={38}
      position={{ x: position.x, y: position.y }}
      size={{ width, height: 'auto' }}
      onDragStop={(e, d) => {
        setPosition({ x: d.x, y: d.y })
        setPositionInfo(d.x, d.y)
      }}
      onResizeStop={(e, direction, ref, delta, position) => {
        setWidth(ref.style.width)
        setPosition({
          ...position,
        })
      }}
      bounds={'#nemeeting-canvas-web'}
      className={`nemeeting-web-caption ${props.className || ''}`}
    >
      <Caption {...props} />
    </Rnd>
  )
}

export default React.memo(WebCaption)
