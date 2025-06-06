import React, { useMemo, useRef } from 'react'
import { useTranslation } from 'react-i18next'
import './index.less'
import { NEMeetingCaptionMessage } from '../../../types'
import { NERoomCaptionTranslationLanguage } from 'neroom-types'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import { MAJOR_AUDIO } from '../../../config'

interface CaptionProps {
  className?: string
  captionMessageList: NEMeetingCaptionMessage[]
  enableCaptionLoading: boolean
  onClick?: () => void
  showCaptionBilingual?: boolean
  targetLanguage?: NERoomCaptionTranslationLanguage
}

interface CaptionMessageItemListProps {
  captionMessageList: NEMeetingCaptionMessage[]
  className?: string
  showCaptionBilingual?: boolean
  targetLanguage?: NERoomCaptionTranslationLanguage
}

interface CaptionMessageItemProps {
  message: NEMeetingCaptionMessage
  targetLanguage?: NERoomCaptionTranslationLanguage
  showCaptionBilingual?: boolean
}

const CaptionMessageItem: React.FC<CaptionMessageItemProps> = ({
  message,
  targetLanguage,
  showCaptionBilingual,
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
        <div className="nemeeting-h5-caption-message-item">
          <div className="nemeeting-h5-caption-message-item-name">
            <div className="nemeeting-ellipsis">{message.fromNickname}</div>
            <div>：</div>
          </div>
          <div className={`nemeeting-h5-caption-message-item-content`}>
            {message.content}
          </div>
        </div>
      )}
      {message.translationContent && !!targetLanguage && (
        <div className="nemeeting-h5-caption-message-item">
          <div className="nemeeting-h5-caption-message-item-name">
            <div className="nemeeting-ellipsis">{message.fromNickname}</div>
            <div>：</div>
          </div>
          <div className={`nemeeting-h5-caption-message-item-content`}>
            {message.translationContent}
          </div>
        </div>
      )}
    </>
  )
}

const CaptionMessageItemList: React.FC<CaptionMessageItemListProps> = ({
  captionMessageList,
  showCaptionBilingual,
  targetLanguage,
}) => {
  return (
    <div className={`nemeeting-h5-caption-message-item-list`}>
      {/* h5目前只能显示两项 */}
      {captionMessageList.slice(-2).map((item, index) => {
        return (
          <CaptionMessageItem
            key={index}
            message={item}
            targetLanguage={targetLanguage}
            showCaptionBilingual={showCaptionBilingual}
          />
        )
      })}
    </div>
  )
}

const Caption: React.FC<CaptionProps> = ({
  className,
  enableCaptionLoading,
  captionMessageList,
  showCaptionBilingual,
  targetLanguage,
  onClick,
}) => {
  const { t } = useTranslation()
  const captionElementRef = useRef<HTMLDivElement>(null)
  const { interpretationSetting } = useGlobalContext()
  const { meetingInfo } = useMeetingInfoContext()

  return (
    <div
      ref={captionElementRef}
      className={`nemeeting-h5-caption ${className || ''}`}
      onClick={() => {
        onClick?.()
      }}
    >
      <div className="nemeeting-h5-caption-header-wrapper">
        <div className="nemeeting-h5-caption-header">
          {t('transcriptionDisclaimer')}
        </div>
      </div>
      <div className="nemeeting-h5-caption-content">
        {meetingInfo.interpretation?.started &&
        interpretationSetting?.listenLanguage &&
        interpretationSetting?.listenLanguage !== MAJOR_AUDIO ? (
          <div className="nemeeting-h5-caption-loading">
            {t('transcriptionCaptionNotAvailableInSubChannel')}
          </div>
        ) : enableCaptionLoading ? (
          <div className="nemeeting-h5-caption-loading">
            {t('transcriptionCaptionLoading')}
          </div>
        ) : (
          <CaptionMessageItemList
            targetLanguage={targetLanguage}
            captionMessageList={captionMessageList}
            showCaptionBilingual={showCaptionBilingual}
          />
        )}
      </div>
    </div>
  )
}

export default React.memo(Caption)
